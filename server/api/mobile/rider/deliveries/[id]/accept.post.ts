import prisma from '../../../../../utils/prisma'
import { successResponse, unauthorizedResponse, errorResponse } from '../../../../../utils/response'
import { verifyToken, getTokenFromHeader } from '../../../../../utils/jwt'
import { notifyCustomerOrderStatus } from '../../../../../services/notification'

/**
 * POST /api/mobile/rider/deliveries/:id/accept
 * Rider ຮັບ delivery
 */
export default defineEventHandler(async (event) => {
  // Verify rider token
  const token = getTokenFromHeader(event)
  if (!token) {
    return unauthorizedResponse('ກະລຸນາເຂົ້າສູ່ລະບົບ')
  }

  const payload = verifyToken(token)
  if (!payload || !('riderId' in payload)) {
    return unauthorizedResponse('Token ບໍ່ຖືກຕ້ອງ ຫຼື ບໍ່ແມ່ນ Rider')
  }

  const riderId = payload.riderId as string
  const orderId = getRouterParam(event, 'id')

  if (!orderId) {
    return errorResponse('ກະລຸນາລະບຸ Order ID', 400)
  }

  try {
    // Check if rider is active and available
    const rider = await prisma.rider.findUnique({
      where: { id: riderId },
    })

    if (!rider || !rider.isActive) {
      return errorResponse('ບັນຊີ Rider ບໍ່ພ້ອມໃຊ້ງານ', 400)
    }

    if (rider.status === 'BUSY') {
      return errorResponse('ທ່ານມີງານສົ່ງຢູ່ແລ້ວ ກະລຸນາສົ່ງໃຫ້ສຳເລັດກ່ອນ', 400)
    }

    // Check if order exists and is ready for pickup
    const order = await prisma.order.findUnique({
      where: { id: orderId },
      include: {
        delivery: true,
        store: { select: { name: true } },
      }
    })

    if (!order) {
      return errorResponse('ບໍ່ພົບ Order', 404)
    }

    if (order.status !== 'READY_FOR_PICKUP') {
      return errorResponse('Order ບໍ່ພ້ອມໃຫ້ຮັບ', 400)
    }

    // Check if already has a rider
    if (order.delivery?.riderId) {
      return errorResponse('Order ນີ້ຖືກຮັບແລ້ວໂດຍ Rider ອື່ນ', 400)
    }

    // Update order status and assign rider
    const [updatedOrder, updatedDelivery] = await prisma.$transaction([
      // Update order status
      prisma.order.update({
        where: { id: orderId },
        data: {
          status: 'PICKED_UP',
          pickedUpAt: new Date(),
        },
        include: {
          store: { select: { name: true, address: true, lat: true, lng: true } },
          customer: { select: { fullName: true, phone: true } },
        }
      }),

      // Update or create delivery
      order.delivery
        ? prisma.delivery.update({
            where: { id: order.delivery.id },
            data: {
              riderId: riderId,
              assignedAt: new Date(),
              pickedUpAt: new Date(),
            }
          })
        : prisma.delivery.create({
            data: {
              orderId: orderId,
              riderId: riderId,
              assignedAt: new Date(),
              pickedUpAt: new Date(),
            }
          }),

      // Update rider status to BUSY
      prisma.rider.update({
        where: { id: riderId },
        data: { status: 'BUSY' },
      }),
    ])

    // Send notification to customer
    await notifyCustomerOrderStatus(orderId, 'ORDER_PICKED_UP', {
      riderName: rider.fullName,
      riderPhone: rider.phone,
    })

    return successResponse({
      message: 'ຮັບ Order ສຳເລັດ',
      data: {
        orderId: updatedOrder.id,
        orderNo: updatedOrder.orderNo,
        status: updatedOrder.status,
        store: updatedOrder.store,
        customer: updatedOrder.customer,
        deliveryAddress: updatedOrder.deliveryAddress,
        deliveryLat: updatedOrder.deliveryLat,
        deliveryLng: updatedOrder.deliveryLng,
        total: updatedOrder.total,
      }
    })

  } catch (error: any) {
    console.error('Error accepting delivery:', error)
    return errorResponse(error.message || 'ເກີດຂໍ້ຜິດພາດ', 500)
  }
})
