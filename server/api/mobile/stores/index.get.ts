import prisma from '../../../utils/prisma'
import { successResponse } from '../../../utils/response'

export default defineEventHandler(async (event) => {
  const query = getQuery(event)
  const page = parseInt(query.page as string) || 1
  const limit = parseInt(query.limit as string) || 20
  const search = query.search as string || ''
  const lat = parseFloat(query.lat as string) || 0
  const lng = parseFloat(query.lng as string) || 0
  
  const where: any = {
    isActive: true,
  }
  
  if (search) {
    where.OR = [
      { name: { contains: search, mode: 'insensitive' } },
      { description: { contains: search, mode: 'insensitive' } },
    ]
  }
  
  const stores = await prisma.store.findMany({
    where,
    select: {
      id: true,
      name: true,
      description: true,
      address: true,
      lat: true,
      lng: true,
      coverImage: true,
      logo: true,
      openTime: true,
      closeTime: true,
      minOrderAmount: true,
      deliveryFee: true,
      estimatedPrepTime: true,
      rating: true,
      totalOrders: true,
      _count: {
        select: { reviews: true },
      },
    },
    orderBy: { rating: 'desc' },
    skip: (page - 1) * limit,
    take: limit,
  })
  
  // TODO: Calculate distance and sort by distance if lat/lng provided
  
  const total = await prisma.store.count({ where })
  
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

