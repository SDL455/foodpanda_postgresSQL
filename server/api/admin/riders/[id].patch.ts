import { z } from 'zod'
import prisma from '../../../utils/prisma'
import { successResponse, errorResponse, unauthorizedResponse, forbiddenResponse, notFoundResponse } from '../../../utils/response'

const updateRiderSchema = z.object({
  fullName: z.string().min(1).optional(),
  phone: z.string().min(8).optional(),
  vehicleType: z.string().optional(),
  vehiclePlate: z.string().optional(),
  isActive: z.boolean().optional(),
  isVerified: z.boolean().optional(),
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
  const result = updateRiderSchema.safeParse(body)
  
  if (!result.success) {
    return errorResponse(result.error.issues[0]?.message ?? 'ຂໍ້ມູນບໍ່ຖືກຕ້ອງ')
  }
  
  const rider = await prisma.rider.findUnique({
    where: { id },
  })
  
  if (!rider) {
    return notFoundResponse('ບໍ່ພົບ Rider')
  }
  
  const updated = await prisma.rider.update({
    where: { id },
    data: result.data,
    select: {
      id: true,
      email: true,
      phone: true,
      fullName: true,
      vehicleType: true,
      vehiclePlate: true,
      status: true,
      isActive: true,
      isVerified: true,
      createdAt: true,
    },
  })
  
  // Log action
  await prisma.auditLog.create({
    data: {
      actorId: user.userId,
      action: 'UPDATE_RIDER',
      entity: 'Rider',
      entityId: id,
      meta: result.data,
    },
  })
  
  return successResponse(updated, 'ອັບເດດສຳເລັດ')
})

