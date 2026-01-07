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
  const status = query.status as string || ''
  const storeId = query.storeId as string || ''
  
  let where: any = {}
  
  // If merchant user, only show their orders
  if (user.role !== 'SUPER_ADMIN' && user.merchantId) {
    const stores = await prisma.store.findMany({
      where: { merchantId: user.merchantId },
      select: { id: true },
    })
    where.storeId = { in: stores.map(s => s.id) }
  }
  
  if (status) {
    where.status = status
  }
  
  if (storeId) {
    where.storeId = storeId
  }
  
  const [orders, total] = await Promise.all([
    prisma.order.findMany({
      where,
      include: {
        customer: {
          select: { id: true, fullName: true, phone: true, avatar: true },
        },
        store: {
          select: { id: true, name: true, phone: true },
        },
        items: {
          include: {
            variants: true,
          },
        },
        delivery: {
          include: {
            rider: {
              select: { id: true, fullName: true, phone: true },
            },
          },
        },
      },
      orderBy: { createdAt: 'desc' },
      skip: (page - 1) * limit,
      take: limit,
    }),
    prisma.order.count({ where }),
  ])
  
  return successResponse({
    orders,
    pagination: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
    },
  })
})

