import { z } from 'zod'
import prisma from '../../../utils/prisma'
import { successResponse, errorResponse, unauthorizedResponse, notFoundResponse } from '../../../utils/response'
import { verifyToken, getTokenFromHeader } from '../../../utils/jwt'
import { sendNotification, notifyStoreNewOrder } from '../../../services/notification'

const createOrderSchema = z.object({
  storeId: z.string().min(1),
  addressId: z.string().optional(),
  deliveryAddress: z.string().min(1),
  deliveryLat: z.number(),
  deliveryLng: z.number(),
  deliveryNote: z.string().optional(),
  paymentMethod: z.enum(['CASH', 'BANK_TRANSFER', 'MOBILE_PAYMENT']),
  items: z.array(z.object({
    productId: z.string(),
    quantity: z.number().min(1),
    note: z.string().optional(),
    variantIds: z.array(z.string()).optional(),
  })).min(1),
})

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
  
  const body = await readBody(event)
  const result = createOrderSchema.safeParse(body)
  
  if (!result.success) {
    return errorResponse(result.error.issues[0]?.message ?? 'ຂໍ້ມູນບໍ່ຖືກຕ້ອງ')
  }
  
  const { storeId, addressId, deliveryAddress, deliveryLat, deliveryLng, deliveryNote, paymentMethod, items } = result.data
  
  // Check store
  const store = await prisma.store.findUnique({
    where: { id: storeId, isActive: true },
  })
  
  if (!store) {
    return notFoundResponse('ບໍ່ພົບຮ້ານ')
  }
  
  // Get products and calculate total
  const productIds = items.map(i => i.productId)
  const products = await prisma.product.findMany({
    where: { id: { in: productIds }, storeId, isAvailable: true },
    include: { variants: true },
  })
  
  if (products.length !== productIds.length) {
    return errorResponse('ມີສິນຄ້າບາງລາຍການບໍ່ສາມາດສັ່ງຊື້ໄດ້')
  }
  
  // Calculate subtotal
  let subtotal = 0
  const orderItems: any[] = []
  
  for (const item of items) {
    const product = products.find(p => p.id === item.productId)!
    let unitPrice = product.basePrice
    
    // Add variant prices
    const variantData: any[] = []
    if (item.variantIds && item.variantIds.length > 0) {
      for (const variantId of item.variantIds) {
        const variant = product.variants.find(v => v.id === variantId)
        if (variant) {
          unitPrice += variant.priceDelta
          variantData.push({
            variantId: variant.id,
            variantName: variant.name,
            priceDelta: variant.priceDelta,
          })
        }
      }
    }
    
    const totalPrice = unitPrice * item.quantity
    subtotal += totalPrice
    
    orderItems.push({
      productId: product.id,
      productName: product.name,
      productImage: product.image,
      quantity: item.quantity,
      unitPrice,
      totalPrice,
      note: item.note,
      variants: {
        create: variantData,
      },
    })
  }
  
  // Check min order amount
  if (subtotal < store.minOrderAmount) {
    return errorResponse(`ຍອດສັ່ງຊື້ຂັ້ນຕ່ຳແມ່ນ ${store.minOrderAmount.toLocaleString()} ກີບ`)
  }
  
  const deliveryFee = store.deliveryFee
  const total = subtotal + deliveryFee
  
  // Create order
  const order = await prisma.order.create({
    data: {
      customerId,
      storeId,
      addressId,
      deliveryAddress,
      deliveryLat,
      deliveryLng,
      deliveryNote,
      subtotal,
      deliveryFee,
      total,
      paymentMethod,
      items: {
        create: orderItems,
      },
    },
    include: {
      store: {
        select: { id: true, name: true, phone: true },
      },
      items: {
        include: { variants: true },
      },
    },
  })
  
  // Update store total orders
  await prisma.store.update({
    where: { id: storeId },
    data: { totalOrders: { increment: 1 } },
  })
  
  // Send notifications
  try {
    // Notify customer that order was placed
    await sendNotification({
      type: 'ORDER_PLACED',
      customerId,
      orderId: order.id,
      data: {
        orderNo: order.orderNo,
        storeName: store.name,
        total: order.total,
      },
    })
    
    // Notify store about new order
    await notifyStoreNewOrder(order.id)
  } catch (error) {
    console.error('Failed to send notifications:', error)
    // Don't fail the request if notification fails
  }
  
  return successResponse(order, 'ສັ່ງຊື້ສຳເລັດ')
})
