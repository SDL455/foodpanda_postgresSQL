import { z } from 'zod'
import prisma from '../../../utils/prisma'
import { successResponse, errorResponse, unauthorizedResponse, notFoundResponse, forbiddenResponse } from '../../../utils/response'
import { verifyToken, getTokenFromHeader } from '../../../utils/jwt'
import { notifyCustomerOrderStatus, sendNotification } from '../../../services/notification'

const cancelOrderSchema = z.object({
  order_id: z.string().min(1),
  reason: z.string().nullable().optional(),
})

export default defineEventHandler(async (event) => {
  try {
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
    const result = cancelOrderSchema.safeParse(body)
    
    if (!result.success) {
      return errorResponse(result.error.issues[0]?.message ?? 'ຂໍ້ມູນບໍ່ຖືກຕ້ອງ')
    }
    
    const { order_id, reason } = result.data
    
    // Get order and verify ownership
    const order = await prisma.order.findUnique({
      where: { id: order_id },
      include: {
        store: {
          select: { id: true, name: true, merchantId: true },
        },
      },
    })
    
    if (!order) {
      return notFoundResponse('ບໍ່ພົບ Order')
    }
    
    // Verify that the order belongs to the customer
    if (order.customerId !== customerId) {
      return forbiddenResponse('ທ່ານບໍ່ມີສິດຍົກເລີກ Order ນີ້')
    }
    
    // Check if order can be cancelled
    // Only PENDING and CONFIRMED orders can be cancelled by customer
    if (order.status !== 'PENDING' && order.status !== 'CONFIRMED') {
      return errorResponse(
        `ບໍ່ສາມາດຍົກເລີກ Order ທີ່ມີສະຖານະ ${order.status} ໄດ້`
      )
    }
    
    // Update order status to CANCELLED
    const updatedOrder = await prisma.order.update({
      where: { id: order_id },
      data: {
        status: 'CANCELLED',
        cancelledAt: new Date(),
        cancelReason: reason || 'ລູກຄ້າຍົກເລີກ',
      },
      include: {
        store: {
          select: { id: true, name: true },
        },
        items: true,
      },
    })
    
    // Send notifications
    try {
      // Notify customer
      await notifyCustomerOrderStatus(order_id, 'ORDER_CANCELLED', {
        reason: reason || 'ລູກຄ້າຍົກເລີກ',
      })
      
      // Notify store about cancellation
      const store = await prisma.store.findUnique({
        where: { id: order.storeId },
        include: {
          merchant: {
            include: {
              users: { where: { isActive: true } },
            },
          },
        },
      })
      
      if (store?.merchant?.users && store.merchant.users.length > 0) {
        await Promise.all(
          store.merchant.users.map((user) =>
            sendNotification({
              type: 'ORDER_CANCELLED',
              userId: user.id,
              orderId: order_id,
              data: {
                orderNo: order.orderNo,
                total: order.total,
                storeName: store.name,
                reason: reason || 'ລູກຄ້າຍົກເລີກ',
              },
            })
          )
        )
      }
    } catch (error) {
      console.error('Failed to send notifications:', error)
      // Don't fail the request if notification fails
    }
    
    return successResponse(updatedOrder, 'ຍົກເລີກ Order ສຳເລັດ')
  } catch (error: any) {
    console.error('Error cancelling order:', error)
    return errorResponse(
      error?.message || 'ເກີດຂໍ້ຜິດພາດໃນການຍົກເລີກ Order. ກະລຸນາລອງໃໝ່ອີກຄັ້ງ'
    )
  }
})
