import { z } from 'zod'
import bcrypt from 'bcryptjs'
import prisma from '../../utils/prisma'
import { successResponse, errorResponse, unauthorizedResponse } from '../../utils/response'

const updateProfileSchema = z.object({
  fullName: z.string().min(1).optional(),
  phone: z.string().optional(),
  avatar: z.string().optional(),
  currentPassword: z.string().optional(),
  newPassword: z.string().min(6).optional(),
})

export default defineEventHandler(async (event) => {
  const user = event.context.user
  
  if (!user) {
    return unauthorizedResponse()
  }
  
  const body = await readBody(event)
  const result = updateProfileSchema.safeParse(body)
  
  if (!result.success) {
    return errorResponse(result.error.errors[0].message)
  }
  
  const { fullName, phone, avatar, currentPassword, newPassword } = result.data
  
  // If changing password, verify current password
  if (newPassword) {
    if (!currentPassword) {
      return errorResponse('ກະລຸນາປ້ອນລະຫັດຜ່ານປັດຈຸບັນ')
    }
    
    const dbUser = await prisma.user.findUnique({
      where: { id: user.userId },
    })
    
    if (!dbUser) {
      return unauthorizedResponse('ບໍ່ພົບຜູ້ໃຊ້')
    }
    
    const isValidPassword = await bcrypt.compare(currentPassword, dbUser.passwordHash)
    if (!isValidPassword) {
      return errorResponse('ລະຫັດຜ່ານປັດຈຸບັນບໍ່ຖືກຕ້ອງ')
    }
  }
  
  // Prepare update data
  const updateData: any = {}
  
  if (fullName !== undefined) updateData.fullName = fullName
  if (phone !== undefined) updateData.phone = phone
  if (avatar !== undefined) updateData.avatar = avatar
  if (newPassword) {
    updateData.passwordHash = await bcrypt.hash(newPassword, 12)
  }
  
  const updated = await prisma.user.update({
    where: { id: user.userId },
    data: updateData,
    select: {
      id: true,
      email: true,
      fullName: true,
      phone: true,
      avatar: true,
      role: true,
    }
  })
  
  // Log action
  await prisma.auditLog.create({
    data: {
      actorId: user.userId,
      action: 'UPDATE_PROFILE',
      entity: 'User',
      entityId: user.userId,
      meta: { fields: Object.keys(updateData).filter(k => k !== 'passwordHash') },
    },
  })
  
  return successResponse(updated, 'ອັບເດດໂປຣໄຟລ໌ສຳເລັດ')
})
