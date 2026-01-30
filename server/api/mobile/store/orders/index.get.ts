import prisma from '../../../../utils/prisma'
import { successResponse, unauthorizedResponse, errorResponse } from '../../../../utils/response'
import { verifyToken, getTokenFromHeader } from '../../../../utils/jwt'

/**
 * GET /api/mobile/store/orders
 * ດຶງລາຍການ orders ຂອງ store
 * - pending: ກຳລັງລໍຖ້າຮ້ານຢືນຢັນ
 * - preparing: ກຳລັງກະກຽມ
 * - ready: ພ້ອມສົ່ງ
 * - completed: ສົ່ງສຳເລັດ
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

  // Get query params
  const query = getQuery(event)
  const type = (query.type as string) || 'pending' // pending, preparing, ready, completed
  const page = parseInt(query.page as string) || 1
  const limit = parseInt(query.limit as string) || 20
  const skip = (page - 1) * limit

  try {
    let whereClause: any = { storeId }

    switch (type) {
      case 'pending':
        // Orders ທີ່ກຳລັງລໍຖ້າຮ້ານຢືນຢັນ
        whereClause.status = 'PENDING'
        break

      case 'preparing':
        // Orders ທີ່ກຳລັງກະກຽມ
        whereClause.status = 'PREPARING'
        break

      case 'ready':
        // Orders ທີ່ພ້ອມສົ່ງ
        whereClause.status = 'READY_FOR_PICKUP'
        break

      case 'completed':
        // Orders ທີ່ສົ່ງສຳເລັດ
        whereClause.status = 'DELIVERED'
        break

      default:
        return errorResponse('ປະເພດບໍ່ຖືກຕ້ອງ', 400)
    }

    const [orders, total] = await Promise.all([
      prisma.order.findMany({
        where: whereClause,
        include: {
          customer: {
            select: {
              id: true,
              fullName: true,
              phone: true,
              avatar: true,
            },
          },
          items: {
            include: {
              product: {
                select: {
                  name: true,
                  image: true,
                },
              },
            },
          },
          delivery: true,
        },
        orderBy: { createdAt: 'desc' },
        skip,
        take: limit,
      }),
      prisma.order.count({ where: whereClause }),
    ])

    // Transform to order format
    const orderList = orders.map((order) => ({
      id: order.id,
      orderNo: order.orderNo,
      status: order.status,

      // Customer info
      customerName: order.customer.fullName || 'ລູກຄ້າ',
      customerPhone: order.customer.phone || '',
      customerAvatar: order.customer.avatar,
      customerAddress: order.deliveryAddress,

      // Order details
      items: order.items.map((item) => ({
        name: item.productName,
        quantity: item.quantity,
        image: item.productImage,
        unitPrice: item.unitPrice,
        totalPrice: item.totalPrice,
        note: item.note,
      })),
      itemCount: order.items.reduce((sum, item) => sum + item.quantity, 0),

      // Prices
      subtotal: order.subtotal,
      deliveryFee: order.deliveryFee,
      total: order.total,

      // Payment
      paymentMethod: order.paymentMethod,
      paymentStatus: order.paymentStatus,

      // Delivery info
      delivery: order.delivery
        ? {
            id: order.delivery.id,
            riderId: order.delivery.riderId,
            status: order.delivery.riderId ? 'assigned' : 'pending',
            assignedAt: order.delivery.assignedAt,
            pickedUpAt: order.delivery.pickedUpAt,
            deliveredAt: order.delivery.deliveredAt,
          }
        : null,

      // Note
      deliveryNote: order.deliveryNote,

      // Timestamps
      createdAt: order.createdAt,
      confirmedAt: order.confirmedAt,
      preparedAt: order.preparedAt,
    }))

    return successResponse({
      data: orderList,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
        type,
      },
    })
  } catch (error: any) {
    console.error('Error fetching store orders:', error)
    return errorResponse(error.message || 'ເກີດຂໍ້ຜິດພາດ', 500)
  }
})
