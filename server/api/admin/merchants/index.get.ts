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
  
  const where = search ? {
    name: { contains: search, mode: 'insensitive' as const },
  } : {}
  
  const [merchants, total] = await Promise.all([
    prisma.merchant.findMany({
      where,
      include: {
        stores: {
          select: { id: true, name: true },
        },
        users: {
          select: { id: true, email: true, fullName: true, role: true },
        },
        _count: {
          select: { stores: true, users: true },
        },
      },
      orderBy: { createdAt: 'desc' },
      skip: (page - 1) * limit,
      take: limit,
    }),
    prisma.merchant.count({ where }),
  ])
  
  return successResponse({
    merchants,
    pagination: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
    },
  })
})

