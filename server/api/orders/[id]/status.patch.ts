import { z } from 'zod'
import prisma from '../../../utils/prisma'
import { successResponse, errorResponse, unauthorizedResponse, forbiddenResponse, notFoundResponse } from '../../../utils/response'
import { notifyCustomerOrderStatus } from '../../../services/notification'
import type { NotificationType } from '@prisma/client'

const updateStatusSchema = z.object({
  status: z.enum(['CONFIRMED', 'PREPARING', 'READY_FOR_PICKUP', 'CANCELLED']),
  cancelReason: z.string().optional(),
})

// Map order status to notification type
const statusToNotificationType: Record<string, NotificationType> = {
  CONFIRMED: 'ORDER_CONFIRMED',
  PREPARING: 'ORDER_PREPARING',
  READY_FOR_PICKUP: 'ORDER_READY',
  CANCELLED: 'ORDER_CANCELLED',
}

export default defineEventHandler(async (event) => {
  const user = event.context.user
  
  if (!user) {
    return unauthorizedResponse()
  }
  
  const id = getRouterParam(event, 'id')
  if (!id) {
    return errorResponse('ບໍ່ພົບ ID')
  }
  
  const order = await prisma.order.findUnique({
    where: { id },
    include: {
      store: true,
    },
  })
  
  if (!order) {
    return notFoundResponse('ບໍ່ພົບ Order')
  }
  
  // Check access
  if (user.role !== 'SUPER_ADMIN' && order.store.merchantId !== user.merchantId) {
    return forbiddenResponse('ບໍ່ມີສິດເຂົ້າເຖິງ')
  }
  
  const body = await readBody(event)
  const result = updateStatusSchema.safeParse(body)
  
  if (!result.success) {
    return errorResponse(result.error.issues[0]?.message ?? 'ຂໍ້ມູນບໍ່ຖືກຕ້ອງ')
  }
  
  const { status, cancelReason } = result.data
  
  // Build update data
  const updateData: any = { status }
  
  switch (status) {
    case 'CONFIRMED':
      updateData.confirmedAt = new Date()
      break
    case 'PREPARING':
      updateData.preparedAt = new Date()
      break
    case 'READY_FOR_PICKUP':
      // Create delivery record if not exists
      const existingDelivery = await prisma.delivery.findUnique({
        where: { orderId: id },
      })
      if (!existingDelivery) {
        await prisma.delivery.create({
          data: { orderId: id },
        })
      }
      break
    case 'CANCELLED':
      updateData.cancelledAt = new Date()
      updateData.cancelReason = cancelReason
      break
  }
  
  const updated = await prisma.order.update({
    where: { id },
    data: updateData,
    include: {
      customer: {
        select: { id: true, fullName: true, phone: true },
      },
      store: {
        select: { id: true, name: true },
      },
      items: true,
      delivery: true,
    },
  })
  
  // Send notification to customer
  try {
    const notificationType = statusToNotificationType[status]
    if (notificationType) {
      await notifyCustomerOrderStatus(id, notificationType, {
        reason: cancelReason,
      })
    }
  } catch (error) {
    console.error('Failed to send notification:', error)
    // Don't fail the request if notification fails
  }
  
  return successResponse(updated, 'ອັບເດດສະຖານະສຳເລັດ')
})
