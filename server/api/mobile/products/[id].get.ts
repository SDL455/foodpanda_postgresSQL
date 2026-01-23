import prisma from '../../../utils/prisma'
import { successResponse, errorResponse } from '../../../utils/response'

export default defineEventHandler(async (event) => {
  const id = getRouterParam(event, 'id')
  
  if (!id) {
    return errorResponse('Product ID is required', 400)
  }
  
  const product = await prisma.product.findUnique({
    where: { id },
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
          coverImage: true,
          rating: true,
          deliveryFee: true,
          estimatedPrepTime: true,
          minOrderAmount: true,
          address: true,
          openTime: true,
          closeTime: true,
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
      images: {
        select: {
          id: true,
          url: true,
          sortOrder: true,
        },
        orderBy: { sortOrder: 'asc' },
      },
    },
  })
  
  if (!product) {
    return errorResponse('Product not found', 404)
  }
  
  // Transform to match mobile app format
  const transformedProduct = {
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
      cover_image: product.store.coverImage,
      rating: product.store.rating,
      delivery_fee: product.store.deliveryFee,
      estimated_prep_time: product.store.estimatedPrepTime,
      min_order_amount: product.store.minOrderAmount,
      address: product.store.address,
      open_time: product.store.openTime,
      close_time: product.store.closeTime,
    },
    variants: product.variants.map(v => ({
      id: v.id,
      name: v.name,
      price_delta: v.priceDelta,
      is_available: v.isAvailable,
    })),
    images: product.images.map(img => ({
      id: img.id,
      url: img.url,
      sort_order: img.sortOrder,
    })),
  }
  
  return successResponse(transformedProduct)
})
