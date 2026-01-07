import prisma from '../../../utils/prisma'
import { successResponse, notFoundResponse, errorResponse } from '../../../utils/response'

export default defineEventHandler(async (event) => {
  const id = getRouterParam(event, 'id')
  if (!id) {
    return errorResponse('ບໍ່ພົບ Store ID')
  }
  
  const store = await prisma.store.findUnique({
    where: { id, isActive: true },
    include: {
      categories: {
        where: { isActive: true },
        orderBy: { sortOrder: 'asc' },
        include: {
          products: {
            where: { isAvailable: true },
            include: {
              variants: {
                where: { isAvailable: true },
              },
              images: {
                orderBy: { sortOrder: 'asc' },
              },
            },
          },
        },
      },
      reviews: {
        take: 10,
        orderBy: { createdAt: 'desc' },
        include: {
          customer: {
            select: { fullName: true, avatar: true },
          },
        },
      },
      _count: {
        select: { reviews: true },
      },
    },
  })
  
  if (!store) {
    return notFoundResponse('ບໍ່ພົບຮ້ານ')
  }
  
  return successResponse(store)
})

