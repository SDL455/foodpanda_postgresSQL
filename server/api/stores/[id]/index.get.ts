import prisma from '../../../utils/prisma'
import { successResponse, unauthorizedResponse, forbiddenResponse, notFoundResponse, errorResponse } from '../../../utils/response'

export default defineEventHandler(async (event) => {
  const user = event.context.user
  
  if (!user) {
    return unauthorizedResponse()
  }
  
  const id = getRouterParam(event, 'id')
  if (!id) {
    return errorResponse('ບໍ່ພົບ ID')
  }
  
  const store = await prisma.store.findUnique({
    where: { id },
    include: {
      categories: {
        orderBy: { sortOrder: 'asc' },
      },
      _count: {
        select: {
          products: true,
          orders: true,
          reviews: true,
        },
      },
    },
  })
  
  if (!store) {
    return notFoundResponse('ບໍ່ພົບຮ້ານ')
  }
  
  // Check access
  if (user.role !== 'SUPER_ADMIN' && store.merchantId !== user.merchantId) {
    return forbiddenResponse('ບໍ່ມີສິດເຂົ້າເຖິງ')
  }
  
  return successResponse(store)
})

