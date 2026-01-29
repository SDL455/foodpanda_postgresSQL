import prisma from '../../../../utils/prisma'
import { successResponse, unauthorizedResponse, errorResponse } from '../../../../utils/response'
import { verifyToken, getTokenFromHeader } from '../../../../utils/jwt'

/**
 * GET /api/mobile/rider/notifications
 * ດຶງ notifications ສຳລັບ rider
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

  // Get query params
  const query = getQuery(event)
  const page = parseInt(query.page as string) || 1
  const limit = parseInt(query.limit as string) || 20
  const skip = (page - 1) * limit

  try {
    const [notifications, total] = await Promise.all([
      prisma.notification.findMany({
        where: { riderId },
        orderBy: { createdAt: 'desc' },
        skip,
        take: limit,
      }),
      prisma.notification.count({
        where: { riderId },
      }),
    ])

    const totalPages = Math.ceil(total / limit)

    return successResponse({
      data: notifications,
      meta: {
        total,
        page,
        limit,
        totalPages,
      }
    })

  } catch (error: any) {
    console.error('Error fetching rider notifications:', error)
    return errorResponse(error.message || 'ເກີດຂໍ້ຜິດພາດ', 500)
  }
})
