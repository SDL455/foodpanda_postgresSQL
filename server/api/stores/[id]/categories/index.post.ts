import { z } from 'zod'
import prisma from '../../../../utils/prisma'
import { successResponse, errorResponse, unauthorizedResponse, forbiddenResponse, notFoundResponse } from '../../../../utils/response'

const createCategorySchema = z.object({
  name: z.string().min(1, 'ກະລຸນາປ້ອນຊື່ໝວດໝູ່'),
  image: z.string().optional(),
  sortOrder: z.number().optional(),
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
  const result = createCategorySchema.safeParse(body)
  
  if (!result.success) {
    return errorResponse(result.error.errors[0].message)
  }
  
  // Check if category name already exists in this store
  const existing = await prisma.category.findUnique({
    where: {
      storeId_name: {
        storeId,
        name: result.data.name,
      },
    },
  })
  
  if (existing) {
    return errorResponse('ຊື່ໝວດໝູ່ນີ້ມີຢູ່ແລ້ວ')
  }
  
  const category = await prisma.category.create({
    data: {
      ...result.data,
      storeId,
    },
  })
  
  return successResponse(category, 'ສ້າງໝວດໝູ່ສຳເລັດ')
})

