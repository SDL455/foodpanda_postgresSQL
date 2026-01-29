import prisma from '../../../../../utils/prisma'
import { successResponse, unauthorizedResponse, errorResponse } from '../../../../../utils/response'
import { verifyToken, getTokenFromHeader } from '../../../../../utils/jwt'
import { notifyCustomerOrderStatus } from '../../../../../services/notification'

/**
 * PATCH /api/mobile/rider/deliveries/:id/status
 * ອັບເດດສະຖານະ delivery
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
  const body = await readBody(event)
  const { status, currentLat, currentLng, note } = body

  if (!orderId) {
    return errorResponse('ກະລຸນາລະບຸ Order ID', 400)
  }

  if (!status) {
    return errorResponse('ກະລຸນາລະບຸສະຖານະ', 400)
  }

  // Valid status transitions for rider
  const validStatuses = ['PICKED_UP', 'DELIVERING', 'DELIVERED']
  if (!validStatuses.includes(status)) {
    return errorResponse('ສະຖານະບໍ່ຖືກຕ້ອງ', 400)
  }

  try {
    // Check if order exists and belongs to this rider
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

    if (order.delivery?.riderId !== riderId) {
      return errorResponse('ທ່ານບໍ່ມີສິດອັບເດດ Order ນີ້', 403)
    }

    // Validate status transition
    const currentStatus = order.status
    const validTransitions: Record<string, string[]> = {
      'PICKED_UP': ['DELIVERING'],
      'DELIVERING': ['DELIVERED'],
    }

    if (currentStatus !== status && !validTransitions[currentStatus]?.includes(status)) {
      return errorResponse(`ບໍ່ສາມາດປ່ຽນຈາກ ${currentStatus} ເປັນ ${status}`, 400)
    }

    // Prepare update data
    const orderUpdateData: any = { status }
    const deliveryUpdateData: any = {}

    if (status === 'DELIVERING') {
      // Mark as delivering
      if (currentLat && currentLng) {
        deliveryUpdateData.currentLat = currentLat
        deliveryUpdateData.currentLng = currentLng
      }
    } else if (status === 'DELIVERED') {
      // Mark as delivered
      orderUpdateData.deliveredAt = new Date()
      deliveryUpdateData.deliveredAt = new Date()
      orderUpdateData.paymentStatus = order.paymentMethod === 'CASH' ? 'PAID' : order.paymentStatus
    }

    if (note) {
      deliveryUpdateData.note = note
    }

    // Update location if provided
    if (currentLat && currentLng) {
      deliveryUpdateData.currentLat = currentLat
      deliveryUpdateData.currentLng = currentLng
    }

    // Update order and delivery
    const [updatedOrder] = await prisma.$transaction([
      prisma.order.update({
        where: { id: orderId },
        data: orderUpdateData,
      }),
      prisma.delivery.update({
        where: { id: order.delivery!.id },
        data: deliveryUpdateData,
      }),
      // If delivered, update rider status back to available
      ...(status === 'DELIVERED'
        ? [
            prisma.rider.update({
              where: { id: riderId },
              data: { status: 'AVAILABLE' },
            }),
            // Add rider earning
            prisma.riderEarning.create({
              data: {
                riderId: riderId,
                amount: order.deliveryFee,
                type: 'DELIVERY',
                note: `ສົ່ງ Order #${order.orderNo} ສຳເລັດ`,
              }
            }),
          ]
        : []),
    ])

    // Send notification to customer
    const notificationTypes: Record<string, any> = {
      'DELIVERING': 'ORDER_DELIVERING',
      'DELIVERED': 'ORDER_DELIVERED',
    }

    if (notificationTypes[status]) {
      await notifyCustomerOrderStatus(orderId, notificationTypes[status])
    }

    return successResponse({
      message: 'ອັບເດດສະຖານະສຳເລັດ',
      data: {
        orderId: updatedOrder.id,
        orderNo: updatedOrder.orderNo,
        status: updatedOrder.status,
      }
    })

  } catch (error: any) {
    console.error('Error updating delivery status:', error)
    return errorResponse(error.message || 'ເກີດຂໍ້ຜິດພາດ', 500)
  }
})
