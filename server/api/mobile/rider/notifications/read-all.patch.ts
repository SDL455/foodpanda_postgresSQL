import prisma from '../../../../utils/prisma'
import { successResponse, unauthorizedResponse, errorResponse } from '../../../../utils/response'
import { verifyToken, getTokenFromHeader } from '../../../../utils/jwt'

/**
 * PATCH /api/mobile/rider/notifications/read-all
 * ໝາຍວ່າອ່ານທຸກ notifications ແລ້ວ
 */
export default defineEventHandler(async (event) => {
  // Verify rider token
  const token = getTokenFromHeader(event)
  if (!token) {
    return unauthorizedResponse('ກະລຸນາເຂົ້າສູ່ລະບົບ')
  }

  const payload = verifyToken(token)
  if (!payload || !('riderId' in payload)) {
    return unauthorizedResponse('Token ບໍ່ຖືກຕ້ອງ ຫຼື ບໍ່ແມ່ນ Rider')
  }

  const riderId = payload.riderId as string

  try {
    // Mark all notifications as read
    await prisma.notification.updateMany({
      where: {
        riderId,
        isRead: false,
      },
      data: {
        isRead: true,
        readAt: new Date(),
      },
    })

    return successResponse({
      message: 'ໝາຍວ່າອ່ານທັງໝົດແລ້ວສຳເລັດ'
    })

  } catch (error: any) {
    console.error('Error marking all notifications as read:', error)
    return errorResponse(error.message || 'ເກີດຂໍ້ຜິດພາດ', 500)
  }
})
