import prisma from '../../../utils/prisma'
import { successResponse, unauthorizedResponse } from '../../../utils/response'
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

  // Count unread notifications
  const count = await prisma.notification.count({
    where: {
      customerId,
      isRead: false,
    },
  })

  return successResponse({ count })
})

