import prisma from '../../../utils/prisma'
import { successResponse, unauthorizedResponse, errorResponse } from '../../../utils/response'
import { verifyToken, getTokenFromHeader } from '../../../utils/jwt'

/**
 * PATCH /api/mobile/rider/location
 * ອັບເດດ location ຂອງ rider (ສົ່ງເປັນ background)
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
  const { lat, lng, accuracy, speed } = body

  if (!lat || !lng) {
    return errorResponse('ກະລຸນາລະບຸ lat ແລະ lng', 400)
  }

  try {
    // Update rider current location
    await prisma.rider.update({
      where: { id: riderId },
      data: {
        currentLat: lat,
        currentLng: lng,
        lastSeenAt: new Date(),
      }
    })

    // Add to location history
    await prisma.riderLocationHistory.create({
      data: {
        riderId,
        lat,
        lng,
        accuracy,
        speed,
      }
    })

    // Update delivery location if rider has active delivery
    await prisma.delivery.updateMany({
      where: {
        riderId,
        deliveredAt: null,
      },
      data: {
        currentLat: lat,
        currentLng: lng,
      }
    })

    return successResponse({
      message: 'ອັບເດດ location ສຳເລັດ'
    })

  } catch (error: any) {
    console.error('Error updating rider location:', error)
    return errorResponse(error.message || 'ເກີດຂໍ້ຜິດພາດ', 500)
  }
})
