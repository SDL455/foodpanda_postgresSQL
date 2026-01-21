import { z } from 'zod'
import prisma from '../../utils/prisma'
import { successResponse, errorResponse, unauthorizedResponse } from '../../utils/response'
import { verifyToken, getTokenFromHeader } from '../../utils/jwt'

const registerTokenSchema = z.object({
  fcmToken: z.string().min(1),
  platform: z.enum(['android', 'ios']),
  deviceId: z.string().optional(),
  deviceName: z.string().optional(),
  appVersion: z.string().optional(),
})

export default defineEventHandler(async (event) => {
  // Get user from token
  const token = getTokenFromHeader(event)
  if (!token) {
    return unauthorizedResponse('ກະລຸນາເຂົ້າສູ່ລະບົບ')
  }

  const payload = verifyToken(token)
  if (!payload) {
    return unauthorizedResponse('Token ບໍ່ຖືກຕ້ອງ')
  }

  const body = await readBody(event)
  const result = registerTokenSchema.safeParse(body)

  if (!result.success) {
    return errorResponse(result.error.errors[0].message)
  }

  const { fcmToken, platform, deviceId, deviceName, appVersion } = result.data

  // Determine if customer or rider
  const isCustomer = 'customerId' in payload || payload.type === 'customer'
  const isRider = 'riderId' in payload || payload.type === 'rider'

  const customerId = isCustomer ? (payload as any).customerId || (payload as any).userId : null
  const riderId = isRider ? (payload as any).riderId || (payload as any).userId : null

  // Upsert device token
  const deviceToken = await prisma.deviceToken.upsert({
    where: { fcmToken },
    update: {
      customerId,
      riderId,
      platform,
      deviceId,
      deviceName,
      appVersion,
      isActive: true,
      updatedAt: new Date(),
    },
    create: {
      fcmToken,
      customerId,
      riderId,
      platform,
      deviceId,
      deviceName,
      appVersion,
      isActive: true,
    },
  })

  return successResponse(deviceToken, 'ລົງທະບຽນ Token ສຳເລັດ')
})

