import prisma from '../../../utils/prisma'
import { unauthorizedResponse } from '../../../utils/response'
import { verifyToken, getTokenFromHeader } from '../../../utils/jwt'

export default defineEventHandler(async (event) => {
  // Get customer from token
  const token = getTokenFromHeader(event)
  if (!token) {
    return unauthorizedResponse('ກະລຸນາເຂົ້າສູ່ລະບົບ')
  }
  
  const payload = verifyToken(token)
  if (!payload || !('userId' in payload)) {
    return unauthorizedResponse('Token ບໍ່ຖືກຕ້ອງ')
  }
  
  const customerId = payload.userId
  
  const query = getQuery(event)
  const page = parseInt(query.page as string) || 1
  const limit = parseInt(query.limit as string) || 20
  const status = query.status as string || ''
  
  // Build where clause
  let where: any = { customerId }
  
  // Filter by status type
  if (status === 'active') {
    // Active orders: pending, confirmed, preparing, ready, picked_up, delivering
    where.status = {
      in: ['PENDING', 'CONFIRMED', 'PREPARING', 'READY_FOR_PICKUP', 'PICKED_UP', 'DELIVERING']
    }
  } else if (status === 'history') {
    // History orders: delivered, cancelled
    where.status = {
      in: ['DELIVERED', 'CANCELLED']
    }
  }
  
  const [orders, total] = await Promise.all([
    prisma.order.findMany({
      where,
      include: {
        store: {
          select: {
            id: true,
            name: true,
            phone: true,
            logo: true,
            coverImage: true,
            address: true,
            rating: true,
            estimatedPrepTime: true,
          },
        },
        items: {
          include: {
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
                currentLat: true,
                currentLng: true,
              },
            },
          },
        },
      },
      orderBy: { createdAt: 'desc' },
      skip: (page - 1) * limit,
      take: limit,
    }),
    prisma.order.count({ where }),
  ])
  
  // Transform orders to match mobile app format
  const transformedOrders = orders.map(order => ({
    id: order.id,
    user_id: order.customerId,
    restaurant: {
      id: order.store.id,
      name: order.store.name,
      phone: order.store.phone,
      logo: order.store.logo,
      cover_image: order.store.coverImage,
      display_image: order.store.coverImage || order.store.logo,
      address: order.store.address,
      rating: order.store.rating,
      prep_time: order.store.estimatedPrepTime,
    },
    items: order.items.map(item => ({
      id: item.id,
      product_id: item.productId,
      name: item.productName,
      image: item.productImage,
      quantity: item.quantity,
      unit_price: item.unitPrice,
      total_price: item.totalPrice,
      note: item.note,
      variants: item.variants.map(v => ({
        id: v.id,
        name: v.variantName,
        price_delta: v.priceDelta,
      })),
    })),
    subtotal: order.subtotal,
    delivery_fee: order.deliveryFee,
    discount: order.discount,
    total: order.total,
    status: mapOrderStatus(order.status),
    delivery_address: order.deliveryAddress,
    delivery_latitude: order.deliveryLat,
    delivery_longitude: order.deliveryLng,
    payment_method: order.paymentMethod,
    is_paid: order.paymentStatus === 'PAID',
    note: order.deliveryNote,
    driver_name: order.delivery?.rider?.fullName || null,
    driver_phone: order.delivery?.rider?.phone || null,
    driver_latitude: order.delivery?.rider?.currentLat || null,
    driver_longitude: order.delivery?.rider?.currentLng || null,
    created_at: order.createdAt.toISOString(),
    estimated_delivery: order.delivery?.estimatedTime 
      ? new Date(Date.now() + order.delivery.estimatedTime * 60000).toISOString() 
      : null,
    delivered_at: order.deliveredAt?.toISOString() || null,
  }))
  
  return {
    success: true,
    data: transformedOrders,
    pagination: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
    },
  }
})

// Map database OrderStatus to mobile app status format
function mapOrderStatus(status: string): string {
  const statusMap: Record<string, string> = {
    'PENDING': 'pending',
    'CONFIRMED': 'confirmed',
    'PREPARING': 'preparing',
    'READY_FOR_PICKUP': 'ready',
    'PICKED_UP': 'onTheWay',
    'DELIVERING': 'onTheWay',
    'DELIVERED': 'delivered',
    'CANCELLED': 'cancelled',
  }
  return statusMap[status] || 'pending'
}
