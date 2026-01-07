import prisma from '../../../../utils/prisma'
import { successResponse, notFoundResponse, errorResponse } from '../../../../utils/response'

export default defineEventHandler(async (event) => {
  const storeId = getRouterParam(event, 'id')
  if (!storeId) {
    return errorResponse('ບໍ່ພົບ Store ID')
  }
  
  const query = getQuery(event)
  const page = parseInt(query.page as string) || 1
  const limit = parseInt(query.limit as string) || 20
  const categoryId = query.categoryId as string || ''
  const search = query.search as string || ''
  
  const store = await prisma.store.findUnique({
    where: { id: storeId },
  })
  
  if (!store) {
    return notFoundResponse('ບໍ່ພົບຮ້ານ')
  }
  
  const where: any = { storeId }
  
  if (categoryId) {
    where.categoryId = categoryId
  }
  
  if (search) {
    where.name = { contains: search, mode: 'insensitive' }
  }
  
  const [products, total] = await Promise.all([
    prisma.product.findMany({
      where,
      include: {
        category: {
          select: { id: true, name: true },
        },
        variants: true,
        images: {
          orderBy: { sortOrder: 'asc' },
        },
        stock: true,
      },
      orderBy: { createdAt: 'desc' },
      skip: (page - 1) * limit,
      take: limit,
    }),
    prisma.product.count({ where }),
  ])
  
  return successResponse({
    products,
    pagination: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
    },
  })
})

