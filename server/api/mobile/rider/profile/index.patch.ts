import prisma from '../../../../utils/prisma'
import { successResponse, unauthorizedResponse, errorResponse } from '../../../../utils/response'
import { verifyToken, getTokenFromHeader } from '../../../../utils/jwt'

/**
 * PATCH /api/mobile/rider/profile
 * ອັບເດດ profile ຂອງ rider
 */
export default defineEventHandler(async (event) => {
  // Verify rider token
  const token = getTokenFromHeader(event)
  if (!token) {
    return unauthorizedResponse('ກະລຸນາເຂົ້າສູ່ລະບົບ')
  }

  const payload = verifyToken(token)
  if (!payload || !('riderId' in payload)) {
    return unauthorizedResponse('Token ບໍ່ຖືກຕ້ອງ ຫຼື ບໍ່ແມ່ນ Rider')
  }

  const riderId = payload.riderId as string
  const body = await readBody(event)

  const { fullName, phone, avatar, vehicleType, vehiclePlate } = body

  try {
    const updatedRider = await prisma.rider.update({
      where: { id: riderId },
      data: {
        ...(fullName && { fullName }),
        ...(phone && { phone }),
        ...(avatar && { avatar }),
        ...(vehicleType && { vehicleType }),
        ...(vehiclePlate && { vehiclePlate }),
      },
      select: {
        id: true,
        email: true,
        phone: true,
        fullName: true,
        avatar: true,
        vehicleType: true,
        vehiclePlate: true,
        status: true,
        isActive: true,
        isVerified: true,
      }
    })

    return successResponse({
      message: 'ອັບເດດ Profile ສຳເລັດ',
      data: updatedRider
    })

  } catch (error: any) {
    console.error('Error updating rider profile:', error)
    return errorResponse(error.message || 'ເກີດຂໍ້ຜິດພາດ', 500)
  }
})
