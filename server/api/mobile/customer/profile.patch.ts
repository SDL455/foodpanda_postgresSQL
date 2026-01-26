import { z } from 'zod'
import prisma from '../../../utils/prisma'
import { successResponse, errorResponse, unauthorizedResponse } from '../../../utils/response'

const updateProfileSchema = z.object({
  fullName: z.string().min(1).optional(),
  phone: z.string().optional().nullable(),
  avatar: z.string().optional().nullable(),
})

export default defineEventHandler(async (event) => {
  const user = event.context.user
  
  if (!user) {
    return unauthorizedResponse()
  }
  
  const body = await readBody(event)
  const result = updateProfileSchema.safeParse(body)
  
  if (!result.success) {
    return errorResponse(result.error.issues[0]?.message ?? 'ຂໍ້ມູນບໍ່ຖືກຕ້ອງ')
  }
  
  const { fullName, phone, avatar } = result.data
  
  // Check if customer exists
  const existingCustomer = await prisma.customer.findUnique({
    where: { id: user.userId },
  })
  
  if (!existingCustomer) {
    return unauthorizedResponse('ບໍ່ພົບຂໍ້ມູນລູກຄ້າ')
  }
  
  // Prepare update data
  const updateData: any = {}
  
  if (fullName !== undefined) updateData.fullName = fullName
  if (phone !== undefined) updateData.phone = phone
  if (avatar !== undefined) updateData.avatar = avatar
  
  // Update customer
  const updated = await prisma.customer.update({
    where: { id: user.userId },
    data: updateData,
    select: {
      id: true,
      email: true,
      phone: true,
      fullName: true,
      avatar: true,
      authProvider: true,
      isActive: true,
      createdAt: true,
      lastLoginAt: true,
    },
  })
  
  return successResponse(updated, 'ອັບເດດໂປຣໄຟລ໌ສຳເລັດ')
})
