import { z } from 'zod'
import prisma from '../../../utils/prisma'
import { successResponse, errorResponse, unauthorizedResponse, forbiddenResponse, notFoundResponse } from '../../../utils/response'

const updateMerchantSchema = z.object({
  name: z.string().min(1).optional(),
  isActive: z.boolean().optional(),
})

export default defineEventHandler(async (event) => {
  const user = event.context.user
  
  if (!user) {
    return unauthorizedResponse()
  }
  
  if (user.role !== 'SUPER_ADMIN') {
    return forbiddenResponse('ບໍ່ມີສິດເຂົ້າເຖິງ')
  }
  
  const id = getRouterParam(event, 'id')
  if (!id) {
    return errorResponse('ບໍ່ພົບ ID')
  }
  
  const body = await readBody(event)
  const result = updateMerchantSchema.safeParse(body)
  
  if (!result.success) {
    return errorResponse(result.error.errors[0].message)
  }
  
  const merchant = await prisma.merchant.findUnique({
    where: { id },
  })
  
  if (!merchant) {
    return notFoundResponse('ບໍ່ພົບ Merchant')
  }
  
  const updated = await prisma.merchant.update({
    where: { id },
    data: result.data,
    include: {
      users: {
        select: { id: true, email: true, fullName: true, role: true },
      },
      stores: {
        select: { id: true, name: true },
      },
    },
  })
  
  // Log action
  await prisma.auditLog.create({
    data: {
      actorId: user.userId,
      action: 'UPDATE_MERCHANT',
      entity: 'Merchant',
      entityId: id,
      meta: result.data,
    },
  })
  
  return successResponse(updated, 'ອັບເດດສຳເລັດ')
})

