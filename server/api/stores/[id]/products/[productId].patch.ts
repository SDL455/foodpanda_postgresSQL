import { z } from 'zod'
import prisma from '../../../../utils/prisma'
import { successResponse, errorResponse, unauthorizedResponse, forbiddenResponse, notFoundResponse } from '../../../../utils/response'

const updateProductSchema = z.object({
  name: z.string().min(1).optional(),
  description: z.string().optional(),
  basePrice: z.number().min(0).optional(),
  categoryId: z.string().nullable().optional(),
  sku: z.string().optional(),
  image: z.string().optional(),
  images: z.array(z.string()).optional(),
  isAvailable: z.boolean().optional(),
  stockQuantity: z.number().optional(),
  variants: z.array(z.object({
    name: z.string(),
    priceDelta: z.number().optional(),
  })).optional(),
})

export default defineEventHandler(async (event) => {
  const user = event.context.user
  
  if (!user) {
    return unauthorizedResponse()
  }
  
  const storeId = getRouterParam(event, 'id')
  const productId = getRouterParam(event, 'productId')
  
  if (!storeId || !productId) {
    return errorResponse('ບໍ່ພົບ ID')
  }
  
  const store = await prisma.store.findUnique({
    where: { id: storeId },
  })
  
  if (!store) {
    return notFoundResponse('ບໍ່ພົບຮ້ານ')
  }
  
  // Check access
  if (user.role !== 'SUPER_ADMIN' && store.merchantId !== user.merchantId) {
    return forbiddenResponse('ບໍ່ມີສິດເຂົ້າເຖິງ')
  }
  
  const existingProduct = await prisma.product.findFirst({
    where: { id: productId, storeId },
  })
  
  if (!existingProduct) {
    return notFoundResponse('ບໍ່ພົບສິນຄ້າ')
  }
  
  const body = await readBody(event)
  const result = updateProductSchema.safeParse(body)
  
  if (!result.success) {
    return errorResponse(result.error.issues[0]?.message ?? 'ຂໍ້ມູນບໍ່ຖືກຕ້ອງ')
  }
  
  const { variants, images, stockQuantity, ...productData } = result.data
  
  // Update product in transaction
  const product = await prisma.$transaction(async (tx) => {
    // Update images if provided
    if (images !== undefined) {
      // Delete existing images
      await tx.productImage.deleteMany({
        where: { productId },
      })
      
      // Create new images
      if (images.length > 0) {
        await tx.productImage.createMany({
          data: images.map((url, index) => ({
            productId,
            url,
            sortOrder: index,
          })),
        })
      }
    }
    
    // Update variants if provided
    if (variants !== undefined) {
      // Delete existing variants
      await tx.productVariant.deleteMany({
        where: { productId },
      })
      
      // Create new variants
      if (variants.length > 0) {
        await tx.productVariant.createMany({
          data: variants.map(v => ({
            productId,
            name: v.name,
            priceDelta: v.priceDelta || 0,
          })),
        })
      }
    }
    
    // Update stock if provided
    if (stockQuantity !== undefined) {
      await tx.stockItem.upsert({
        where: { productId },
        update: { quantity: stockQuantity },
        create: { productId, quantity: stockQuantity },
      })
    }
    
    // Update product
    return tx.product.update({
      where: { id: productId },
      data: productData,
      include: {
        category: true,
        variants: true,
        images: true,
        stock: true,
      },
    })
  })
  
  // Log action
  await prisma.auditLog.create({
    data: {
      actorId: user.userId,
      action: 'UPDATE_PRODUCT',
      entity: 'Product',
      entityId: product.id,
      meta: { productName: product.name, storeId },
    },
  })
  
  return successResponse(product, 'ອັບເດດສິນຄ້າສຳເລັດ')
})
