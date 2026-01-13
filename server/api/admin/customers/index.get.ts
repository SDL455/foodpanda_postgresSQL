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
  const page = Number(query.page) || 1
  const limit = Number(query.limit) || 10
  const search = query.search as string | undefined
  
  const where: any = {}
  
  if (search) {
    where.OR = [
      { fullName: { contains: search, mode: 'insensitive' } },
      { email: { contains: search, mode: 'insensitive' } },
      { phone: { contains: search, mode: 'insensitive' } },
    ]
  }
  
  const [customers, total] = await Promise.all([
    prisma.customer.findMany({
      where,
      skip: (page - 1) * limit,
      take: limit,
      orderBy: { createdAt: 'desc' },
      select: {
        id: true,
        fullName: true,
        email: true,
        phone: true,
        avatar: true,
        authProvider: true,
        isActive: true,
        createdAt: true,
        lastLoginAt: true,
        _count: {
          select: {
            orders: true,
            reviews: true,
            favorites: true,
          }
        }
      }
    }),
    prisma.customer.count({ where }),
  ])
  
  return successResponse({
    customers,
    pagination: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
    }
  })
})
