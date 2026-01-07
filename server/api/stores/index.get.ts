import prisma from '../../utils/prisma'
import { successResponse, unauthorizedResponse } from '../../utils/response'

export default defineEventHandler(async (event) => {
  const user = event.context.user
  
  if (!user) {
    return unauthorizedResponse()
  }
  
  const query = getQuery(event)
  const page = parseInt(query.page as string) || 1
  const limit = parseInt(query.limit as string) || 10
  
  let where: any = {}
  
  // If merchant user, only show their stores
  if (user.role !== 'SUPER_ADMIN' && user.merchantId) {
    where.merchantId = user.merchantId
  }
  
  const [stores, total] = await Promise.all([
    prisma.store.findMany({
      where,
      include: {
        _count: {
          select: {
            products: true,
            orders: true,
            categories: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
      skip: (page - 1) * limit,
      take: limit,
    }),
    prisma.store.count({ where }),
  ])
  
  return successResponse({
    stores,
    pagination: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
    },
  })
})

