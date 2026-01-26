import { z } from 'zod'
import prisma from '../../../utils/prisma'
import { successResponse, errorResponse, unauthorizedResponse, forbiddenResponse, notFoundResponse } from '../../../utils/response'

const updateCustomerSchema = z.object({
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
    return notFoundResponse('ບໍ່ພົບ ID')
  }
  
  const customer = await prisma.customer.findUnique({
    where: { id },
  })
  
  if (!customer) {
    return notFoundResponse('ບໍ່ພົບລູກຄ້າ')
  }
  
  const body = await readBody(event)
  const result = updateCustomerSchema.safeParse(body)
  
  if (!result.success) {
    return errorResponse(result.error.issues[0]?.message ?? 'ຂໍ້ມູນບໍ່ຖືກຕ້ອງ')
  }
  
  const updated = await prisma.customer.update({
    where: { id },
    data: result.data,
  })
  
  // Log action
  await prisma.auditLog.create({
    data: {
      actorId: user.userId,
      action: 'UPDATE_CUSTOMER',
      entity: 'Customer',
      entityId: id,
      meta: result.data,
    },
  })
  
  return successResponse(updated, 'ອັບເດດສຳເລັດ')
})
