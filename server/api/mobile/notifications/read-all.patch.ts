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

  // Mark all as read
  const result = await prisma.notification.updateMany({
    where: {
      customerId,
      isRead: false,
    },
    data: {
      isRead: true,
      readAt: new Date(),
    },
  })

  return successResponse(
    { updatedCount: result.count },
    `ໝາຍວ່າອ່ານແລ້ວ ${result.count} ລາຍການ`
  )
})

