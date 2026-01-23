import prisma from '../../../utils/prisma'
import { successResponse } from '../../../utils/response'

export default defineEventHandler(async (event) => {
  const query = getQuery(event)
  const page = parseInt(query.page as string) || 1
  const limit = parseInt(query.limit as string) || 20
  const search = query.search as string || ''
  const categoryId = query.categoryId as string || ''
  const storeId = query.storeId as string || ''
  const popular = query.popular === 'true'
  
  const where: any = {
    isAvailable: true,
    store: {
      isActive: true,
    },
  }
  
  if (search) {
    where.OR = [
      { name: { contains: search, mode: 'insensitive' } },
      { description: { contains: search, mode: 'insensitive' } },
    ]
  }
  
  if (categoryId) {
    where.categoryId = categoryId
  }
  
  if (storeId) {
    where.storeId = storeId
  }
  
  const orderBy: any = popular 
    ? { totalSold: 'desc' }
    : { createdAt: 'desc' }
  
  const products = await prisma.product.findMany({
    where,
    select: {
      id: true,
      name: true,
      description: true,
      basePrice: true,
      currency: true,
      image: true,
      isAvailable: true,
      totalSold: true,
      category: {
        select: {
          id: true,
          name: true,
        },
      },
      store: {
        select: {
          id: true,
          name: true,
          logo: true,
          rating: true,
          deliveryFee: true,
          estimatedPrepTime: true,
        },
      },
      variants: {
        select: {
          id: true,
          name: true,
          priceDelta: true,
          isAvailable: true,
        },
      },
    },
    orderBy,
    skip: (page - 1) * limit,
    take: limit,
  })
  
  const total = await prisma.product.count({ where })
  
  // Transform to match mobile app format
  const transformedProducts = products.map(product => ({
    id: product.id,
    name: product.name,
    description: product.description,
    price: product.basePrice,
    currency: product.currency,
    image: product.image,
    is_available: product.isAvailable,
    total_sold: product.totalSold,
    category: product.category ? {
      id: product.category.id,
      name: product.category.name,
    } : null,
    store: {
      id: product.store.id,
      name: product.store.name,
      logo: product.store.logo,
      rating: product.store.rating,
      delivery_fee: product.store.deliveryFee,
      estimated_prep_time: product.store.estimatedPrepTime,
    },
    variants: product.variants.map(v => ({
      id: v.id,
      name: v.name,
      price_delta: v.priceDelta,
      is_available: v.isAvailable,
    })),
  }))
  
  return successResponse({
    products: transformedProducts,
    pagination: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
    },
  })
})
