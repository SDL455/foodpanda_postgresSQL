import prisma from '../../../../utils/prisma'
import { successResponse, notFoundResponse, errorResponse } from '../../../../utils/response'

export default defineEventHandler(async (event) => {
  const storeId = getRouterParam(event, 'id')
  if (!storeId) {
    return errorResponse('ບໍ່ພົບ Store ID')
  }
  
  const store = await prisma.store.findUnique({
    where: { id: storeId },
  })
  
  if (!store) {
    return notFoundResponse('ບໍ່ພົບຮ້ານ')
  }
  
  const categories = await prisma.category.findMany({
    where: { storeId },
    include: {
      _count: {
        select: { products: true },
      },
    },
    orderBy: { sortOrder: 'asc' },
  })
  
  return successResponse(categories)
})

