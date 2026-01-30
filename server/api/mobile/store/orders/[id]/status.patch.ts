import { z } from 'zod'
import prisma from '../../../../../utils/prisma'
import { successResponse, unauthorizedResponse, errorResponse, notFoundResponse } from '../../../../../utils/response'
import { verifyToken, getTokenFromHeader } from '../../../../../utils/jwt'
import { notifyCustomerOrderStatus, notifyAllAvailableRiders } from '../../../../../services/notification'
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

/**
 * PATCH /api/mobile/store/orders/:id/status
 * ອັບເດດສະຖານະ order ຈາກ store
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

  const body = await readBody(event)
  const result = updateStatusSchema.safeParse(body)

  if (!result.success) {
    return errorResponse(result.error.issues[0]?.message ?? 'ຂໍ້ມູນບໍ່ຖືກຕ້ອງ', 400)
  }

  const { status, cancelReason } = result.data

  try {
    // Check order exists and belongs to this store
    const order = await prisma.order.findUnique({
      where: { id: orderId },
      include: {
        store: true,
        customer: {
          select: { id: true, fullName: true, phone: true },
        },
      },
    })

    if (!order) {
      return notFoundResponse('ບໍ່ພົບ Order')
    }

    if (order.storeId !== storeId) {
      return errorResponse('ບໍ່ມີສິດເຂົ້າເຖິງ Order ນີ້', 403)
    }

    // Validate status transition
    const validTransitions: Record<string, string[]> = {
      PENDING: ['CONFIRMED', 'CANCELLED'],
      CONFIRMED: ['PREPARING', 'CANCELLED'],
      PREPARING: ['READY_FOR_PICKUP', 'CANCELLED'],
      READY_FOR_PICKUP: ['PICKED_UP'], // Rider ຮັບ
      CANCELLED: [],
    }

    if (!validTransitions[order.status]?.includes(status)) {
      return errorResponse(
        `ບໍ່ສາມາດອັບເດດຈາກ ${order.status} ເປັນ ${status}`,
        400
      )
    }

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
          where: { orderId },
        })
        if (!existingDelivery) {
          await prisma.delivery.create({
            data: { orderId },
          })
        }
        break
      case 'CANCELLED':
        updateData.cancelledAt = new Date()
        updateData.cancelReason = cancelReason
        break
    }

    // Update order
    const updated = await prisma.order.update({
      where: { id: orderId },
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

    // Send notifications
    try {
      const notificationType = statusToNotificationType[status]
      if (notificationType) {
        // Notify customer about order status change
        await notifyCustomerOrderStatus(orderId, notificationType, {
          reason: cancelReason,
        })
      }

      // Notify riders when order is ready for pickup
      if (status === 'READY_FOR_PICKUP') {
        await notifyAllAvailableRiders(orderId)
      }
    } catch (notifError) {
      console.error('Failed to send notification:', notifError)
      // Don't fail the request if notification fails
    }

    return successResponse(updated, 'ອັບເດດສະຖານະສຳເລັດ')
  } catch (error: any) {
    console.error('Error updating order status:', error)
    return errorResponse(error.message || 'ເກີດຂໍ້ຜິດພາດ', 500)
  }
})
