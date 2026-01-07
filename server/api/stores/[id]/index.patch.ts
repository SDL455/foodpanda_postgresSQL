import { z } from 'zod'
import prisma from '../../../utils/prisma'
import { successResponse, errorResponse, unauthorizedResponse, forbiddenResponse, notFoundResponse } from '../../../utils/response'

const updateStoreSchema = z.object({
  name: z.string().min(1).optional(),
  description: z.string().optional(),
  phone: z.string().optional(),
  address: z.string().optional(),
  lat: z.number().optional(),
  lng: z.number().optional(),
  coverImage: z.string().optional(),
  logo: z.string().optional(),
  openTime: z.string().optional(),
  closeTime: z.string().optional(),
  minOrderAmount: z.number().optional(),
  deliveryFee: z.number().optional(),
  estimatedPrepTime: z.number().optional(),
  isActive: z.boolean().optional(),
})

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
  })
  
  if (!store) {
    return notFoundResponse('ບໍ່ພົບຮ້ານ')
  }
  
  // Check access
  if (user.role !== 'SUPER_ADMIN' && store.merchantId !== user.merchantId) {
    return forbiddenResponse('ບໍ່ມີສິດເຂົ້າເຖິງ')
  }
  
  const body = await readBody(event)
  const result = updateStoreSchema.safeParse(body)
  
  if (!result.success) {
    return errorResponse(result.error.errors[0].message)
  }
  
  const updated = await prisma.store.update({
    where: { id },
    data: result.data,
  })
  
  // Log action
  await prisma.auditLog.create({
    data: {
      actorId: user.userId,
      action: 'UPDATE_STORE',
      entity: 'Store',
      entityId: id,
      meta: result.data,
    },
  })
  
  return successResponse(updated, 'ອັບເດດສຳເລັດ')
})

