import prisma from '../../../../utils/prisma'
import { successResponse, unauthorizedResponse, errorResponse } from '../../../../utils/response'
import { verifyToken, getTokenFromHeader } from '../../../../utils/jwt'

/**
 * GET /api/mobile/rider/earnings
 * ດຶງລາຍງານລາຍຮັບຂອງ rider
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
  const period = (query.period as string) || 'today' // today, week, month, all
  const page = parseInt(query.page as string) || 1
  const limit = parseInt(query.limit as string) || 20
  const skip = (page - 1) * limit

  try {
    // Calculate date range
    let startDate: Date | undefined
    const now = new Date()

    switch (period) {
      case 'today':
        startDate = new Date(now.setHours(0, 0, 0, 0))
        break
      case 'week':
        startDate = new Date(now.setDate(now.getDate() - 7))
        startDate.setHours(0, 0, 0, 0)
        break
      case 'month':
        startDate = new Date(now.setMonth(now.getMonth() - 1))
        startDate.setHours(0, 0, 0, 0)
        break
      case 'all':
        startDate = undefined
        break
    }

    const whereClause = {
      riderId,
      ...(startDate && { createdAt: { gte: startDate } }),
    }

    // Get earnings and stats
    const [earnings, total, totalAmount, deliveryCount] = await Promise.all([
      prisma.riderEarning.findMany({
        where: whereClause,
        orderBy: { createdAt: 'desc' },
        skip,
        take: limit,
      }),
      prisma.riderEarning.count({ where: whereClause }),
      prisma.riderEarning.aggregate({
        where: whereClause,
        _sum: { amount: true },
      }),
      prisma.delivery.count({
        where: {
          riderId,
          deliveredAt: { not: null },
          ...(startDate && { deliveredAt: { gte: startDate } }),
        }
      }),
    ])

    // Get earnings by day (for chart)
    const dailyEarnings = await prisma.$queryRaw`
      SELECT 
        DATE(created_at) as date,
        SUM(amount) as total
      FROM "RiderEarning"
      WHERE rider_id = ${riderId}
        ${startDate ? prisma.$queryRaw`AND created_at >= ${startDate}` : prisma.$queryRaw``}
      GROUP BY DATE(created_at)
      ORDER BY date DESC
      LIMIT 30
    `

    return successResponse({
      data: {
        transactions: earnings,
        summary: {
          totalEarnings: totalAmount._sum.amount || 0,
          totalDeliveries: deliveryCount,
          averagePerDelivery: deliveryCount > 0 
            ? Math.round((totalAmount._sum.amount || 0) / deliveryCount) 
            : 0,
        },
        chart: dailyEarnings,
      },
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
        period,
      }
    })

  } catch (error: any) {
    console.error('Error fetching rider earnings:', error)
    return errorResponse(error.message || 'ເກີດຂໍ້ຜິດພາດ', 500)
  }
})
