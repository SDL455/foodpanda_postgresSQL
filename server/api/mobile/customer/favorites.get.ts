import prisma from '../../../utils/prisma'
import { successResponse, unauthorizedResponse } from '../../../utils/response'

export default defineEventHandler(async (event) => {
  const user = event.context.user
  
  if (!user) {
    return unauthorizedResponse()
  }
  
  const favorites = await prisma.favoriteStore.findMany({
    where: { customerId: user.userId },
    include: {
      store: {
        select: {
          id: true,
          name: true,
          logo: true,
          coverImage: true,
          address: true,
          rating: true,
          isActive: true,
          deliveryFee: true,
          estimatedPrepTime: true,
          _count: {
            select: { products: true },
          },
        },
      },
    },
    orderBy: { createdAt: 'desc' },
  })
  
  return successResponse(favorites.map(f => ({
    id: f.id,
    createdAt: f.createdAt,
    store: f.store,
  })))
})
