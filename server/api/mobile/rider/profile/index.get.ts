import prisma from '../../../../utils/prisma'
import { successResponse, unauthorizedResponse, errorResponse } from '../../../../utils/response'
import { verifyToken, getTokenFromHeader } from '../../../../utils/jwt'

/**
 * GET /api/mobile/rider/profile
 * ດຶງ profile ຂອງ rider
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
    const rider = await prisma.rider.findUnique({
      where: { id: riderId },
      select: {
        id: true,
        email: true,
        phone: true,
        fullName: true,
        avatar: true,
        vehicleType: true,
        vehiclePlate: true,
        status: true,
        isActive: true,
        isVerified: true,
        currentLat: true,
        currentLng: true,
        lastSeenAt: true,
        createdAt: true,
      }
    })

    if (!rider) {
      return errorResponse('ບໍ່ພົບ Rider', 404)
    }

    // Get stats
    const today = new Date()
    today.setHours(0, 0, 0, 0)

    const [
      todayDeliveries,
      todayEarnings,
      totalDeliveries,
      totalEarnings,
    ] = await Promise.all([
      // Today's deliveries
      prisma.delivery.count({
        where: {
          riderId,
          deliveredAt: { gte: today },
        }
      }),
      // Today's earnings
      prisma.riderEarning.aggregate({
        where: {
          riderId,
          createdAt: { gte: today },
        },
        _sum: { amount: true },
      }),
      // Total deliveries
      prisma.delivery.count({
        where: {
          riderId,
          deliveredAt: { not: null },
        }
      }),
      // Total earnings
      prisma.riderEarning.aggregate({
        where: { riderId },
        _sum: { amount: true },
      }),
    ])

    return successResponse({
      data: {
        ...rider,
        stats: {
          todayDeliveries,
          todayEarnings: todayEarnings._sum.amount || 0,
          totalDeliveries,
          totalEarnings: totalEarnings._sum.amount || 0,
        }
      }
    })

  } catch (error: any) {
    console.error('Error fetching rider profile:', error)
    return errorResponse(error.message || 'ເກີດຂໍ້ຜິດພາດ', 500)
  }
})
