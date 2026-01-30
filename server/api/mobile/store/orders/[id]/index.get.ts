import prisma from '../../../../../utils/prisma'
import { successResponse, unauthorizedResponse, errorResponse, notFoundResponse } from '../../../../../utils/response'
import { verifyToken, getTokenFromHeader } from '../../../../../utils/jwt'

/**
 * GET /api/mobile/store/orders/:id
 * ດຶງລາຍລະອຽດ order ຕົວຍ່າງ
 */
export default defineEventHandler(async (event) => {
  // Verify store token
  const token = getTokenFromHeader(event)
  if (!token) {
    return unauthorizedResponse('ກະລຸນາເຂົ້າສູ່ລະບົບ')
  }

  const payload = verifyToken(token)
  if (!payload || !('storeId' in payload)) {
    return unauthorizedResponse('Token ບໍ່ຖືກຕ້ອງ ຫຼື ບໍ່ແມ່ນ Store')
  }

  const storeId = payload.storeId as string
  const orderId = getRouterParam(event, 'id')

  if (!orderId) {
    return errorResponse('ກະລຸນາລະບຸ Order ID', 400)
  }

  try {
    const order = await prisma.order.findUnique({
      where: { id: orderId },
      include: {
        customer: {
          select: {
            id: true,
            fullName: true,
            phone: true,
            avatar: true,
          },
        },
        store: {
          select: {
            id: true,
            name: true,
            address: true,
            phone: true,
          },
        },
        items: {
          include: {
            product: {
              select: {
                id: true,
                name: true,
                image: true,
              },
            },
            variants: true,
          },
        },
        delivery: {
          include: {
            rider: {
              select: {
                id: true,
                fullName: true,
                phone: true,
                avatar: true,
              },
            },
          },
        },
      },
    })

    if (!order) {
      return notFoundResponse('ບໍ່ພົບ Order')
    }

    if (order.storeId !== storeId) {
      return errorResponse('ບໍ່ມີສິດເຂົ້າເຖິງ Order ນີ້', 403)
    }

    // Transform response
    const orderDetail = {
      id: order.id,
      orderNo: order.orderNo,
      status: order.status,

      // Customer info
      customer: {
        id: order.customer.id,
        fullName: order.customer.fullName,
        phone: order.customer.phone,
        avatar: order.customer.avatar,
      },

      // Delivery address
      deliveryAddress: order.deliveryAddress,
      deliveryLat: order.deliveryLat,
      deliveryLng: order.deliveryLng,
      deliveryNote: order.deliveryNote,

      // Items
      items: order.items.map((item) => ({
        id: item.id,
        productId: item.productId,
        productName: item.productName,
        productImage: item.productImage,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
        totalPrice: item.totalPrice,
        note: item.note,
        variants: item.variants.map((v) => ({
          id: v.id,
          name: v.variantName,
          priceDelta: v.priceDelta,
        })),
      })),

      // Prices
      subtotal: order.subtotal,
      deliveryFee: order.deliveryFee,
      total: order.total,

      // Payment
      paymentMethod: order.paymentMethod,
      paymentStatus: order.paymentStatus,

      // Rider/Delivery info
      delivery: order.delivery
        ? {
            id: order.delivery.id,
            status: order.delivery.riderId ? 'assigned' : 'pending',
            assignedAt: order.delivery.assignedAt,
            pickedUpAt: order.delivery.pickedUpAt,
            deliveredAt: order.delivery.deliveredAt,
            rider: order.delivery.rider
              ? {
                  id: order.delivery.rider.id,
                  fullName: order.delivery.rider.fullName,
                  phone: order.delivery.rider.phone,
                  avatar: order.delivery.rider.avatar,
                }
              : null,
          }
        : null,

      // Timestamps
      createdAt: order.createdAt,
      confirmedAt: order.confirmedAt,
      preparedAt: order.preparedAt,
      pickedUpAt: order.pickedUpAt,
      deliveredAt: order.deliveredAt,
    }

    return successResponse(orderDetail)
  } catch (error: any) {
    console.error('Error fetching order detail:', error)
    return errorResponse(error.message || 'ເກີດຂໍ້ຜິດພາດ', 500)
  }
})
