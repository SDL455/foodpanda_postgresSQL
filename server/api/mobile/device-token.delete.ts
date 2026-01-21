import { z } from 'zod'
import prisma from '../../utils/prisma'
import { successResponse, errorResponse } from '../../utils/response'

const deleteTokenSchema = z.object({
  fcmToken: z.string().min(1),
})

export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  const result = deleteTokenSchema.safeParse(body)

  if (!result.success) {
    return errorResponse(result.error.errors[0].message)
  }

  const { fcmToken } = result.data

  // Deactivate token (soft delete)
  await prisma.deviceToken.updateMany({
    where: { fcmToken },
    data: { isActive: false },
  })

  return successResponse(null, 'ຍົກເລີກ Token ສຳເລັດ')
})

