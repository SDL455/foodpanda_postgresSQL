import { z } from 'zod'
import prisma from '../../../../utils/prisma'
import { successResponse, errorResponse, unauthorizedResponse, forbiddenResponse, notFoundResponse } from '../../../../utils/response'

const createProductSchema = z.object({
  name: z.string().min(1, 'ກະລຸນາປ້ອນຊື່ສິນຄ້າ'),
  description: z.string().optional(),
  basePrice: z.number().min(0, 'ລາຄາຕ້ອງບໍ່ຕ່ຳກວ່າ 0'),
  categoryId: z.string().optional(),
  sku: z.string().optional(),
  image: z.string().optional(),
  isAvailable: z.boolean().optional(),
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
  if (!storeId) {
    return errorResponse('ບໍ່ພົບ Store ID')
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
  
  const body = await readBody(event)
  const result = createProductSchema.safeParse(body)
  
  if (!result.success) {
    return errorResponse(result.error.errors[0].message)
  }
  
  const { variants, ...productData } = result.data
  
  const product = await prisma.product.create({
    data: {
      ...productData,
      storeId,
      variants: variants ? {
        create: variants,
      } : undefined,
      stock: {
        create: {
          quantity: 0,
        },
      },
    },
    include: {
      category: true,
      variants: true,
      stock: true,
    },
  })
  
  // Log action
  await prisma.auditLog.create({
    data: {
      actorId: user.userId,
      action: 'CREATE_PRODUCT',
      entity: 'Product',
      entityId: product.id,
      meta: { productName: product.name, storeId },
    },
  })
  
  return successResponse(product, 'ສ້າງສິນຄ້າສຳເລັດ')
})

