import prisma from '../../../utils/prisma'
import { successResponse, unauthorizedResponse, forbiddenResponse } from '../../../utils/response'

export default defineEventHandler(async (event) => {
  const user = event.context.user
  
  if (!user) {
    return unauthorizedResponse()
  }
  
  if (user.role !== 'SUPER_ADMIN') {
    return forbiddenResponse('ບໍ່ມີສິດເຂົ້າເຖິງ')
  }
  
  const query = getQuery(event)
  const page = parseInt(query.page as string) || 1
  const limit = parseInt(query.limit as string) || 10
  const search = query.search as string || ''
  const status = query.status as string || ''
  
  const where: any = {}
  
  if (search) {
    where.OR = [
      { fullName: { contains: search, mode: 'insensitive' } },
      { email: { contains: search, mode: 'insensitive' } },
      { phone: { contains: search } },
    ]
  }
  
  if (status && ['AVAILABLE', 'BUSY', 'OFFLINE'].includes(status)) {
    where.status = status
  }
  
  const [riders, total] = await Promise.all([
    prisma.rider.findMany({
      where,
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
        _count: {
          select: { deliveries: true },
        },
      },
      orderBy: { createdAt: 'desc' },
      skip: (page - 1) * limit,
      take: limit,
    }),
    prisma.rider.count({ where }),
  ])
  
  return successResponse({
    riders,
    pagination: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
    },
  })
})

