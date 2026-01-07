import prisma from '../../utils/prisma'
import { successResponse, unauthorizedResponse } from '../../utils/response'

export default defineEventHandler(async (event) => {
  const user = event.context.user
  
  if (!user) {
    return unauthorizedResponse('ກະລຸນາເຂົ້າສູ່ລະບົບ')
  }
  
  const dbUser = await prisma.user.findUnique({
    where: { id: user.userId },
    include: {
      merchant: {
        include: {
          stores: true,
        },
      },
    },
  })
  
  if (!dbUser) {
    return unauthorizedResponse('ບໍ່ພົບຜູ້ໃຊ້')
  }
  
  return successResponse({
    id: dbUser.id,
    email: dbUser.email,
    fullName: dbUser.fullName,
    avatar: dbUser.avatar,
    role: dbUser.role,
    merchant: dbUser.merchant,
  })
})

