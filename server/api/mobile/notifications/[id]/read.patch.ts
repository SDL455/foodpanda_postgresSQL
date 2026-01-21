import prisma from '../../../../utils/prisma'
import { successResponse, unauthorizedResponse, notFoundResponse } from '../../../../utils/response'
import { verifyToken, getTokenFromHeader } from '../../../../utils/jwt'

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
  const notificationId = getRouterParam(event, 'id')

  if (!notificationId) {
    return notFoundResponse('ບໍ່ພົບ ID')
  }

  // Check notification exists and belongs to customer
  const notification = await prisma.notification.findFirst({
    where: {
      id: notificationId,
      customerId,
    },
  })

  if (!notification) {
    return notFoundResponse('ບໍ່ພົບການແຈ້ງເຕືອນ')
  }

  // Mark as read
  const updated = await prisma.notification.update({
    where: { id: notificationId },
    data: {
      isRead: true,
      readAt: new Date(),
    },
  })

  return successResponse(updated, 'ໝາຍວ່າອ່ານແລ້ວ')
})

