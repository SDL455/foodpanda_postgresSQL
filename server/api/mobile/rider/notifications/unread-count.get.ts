import prisma from '../../../../utils/prisma'
import { successResponse, unauthorizedResponse, errorResponse } from '../../../../utils/response'
import { verifyToken, getTokenFromHeader } from '../../../../utils/jwt'

/**
 * GET /api/mobile/rider/notifications/unread-count
 * ດຶງຈຳນວນ notifications ທີ່ຍັງບໍ່ທັນອ່ານ
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
    const count = await prisma.notification.count({
      where: {
        riderId,
        isRead: false,
      },
    })

    return successResponse({
      data: { count }
    })

  } catch (error: any) {
    console.error('Error fetching unread count:', error)
    return errorResponse(error.message || 'ເກີດຂໍ້ຜິດພາດ', 500)
  }
})
