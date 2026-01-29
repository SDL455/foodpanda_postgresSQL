import prisma from '../../../utils/prisma'
import { successResponse, unauthorizedResponse, errorResponse } from '../../../utils/response'
import { verifyToken, getTokenFromHeader } from '../../../utils/jwt'

/**
 * PATCH /api/mobile/rider/status
 * ອັບເດດສະຖານະ online/offline ຂອງ rider
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
  const { status, currentLat, currentLng } = body

  // Validate status
  const validStatuses = ['AVAILABLE', 'OFFLINE']
  if (!status || !validStatuses.includes(status)) {
    return errorResponse('ສະຖານະບໍ່ຖືກຕ້ອງ (AVAILABLE ຫຼື OFFLINE)', 400)
  }

  try {
    // Check if rider has active delivery
    if (status === 'OFFLINE') {
      const activeDelivery = await prisma.delivery.findFirst({
        where: {
          riderId,
          deliveredAt: null,
        }
      })

      if (activeDelivery) {
        return errorResponse('ບໍ່ສາມາດ Offline ໄດ້ ເພາະມີງານສົ່ງຢູ່', 400)
      }
    }

    const updatedRider = await prisma.rider.update({
      where: { id: riderId },
      data: {
        status,
        lastSeenAt: new Date(),
        ...(currentLat && { currentLat }),
        ...(currentLng && { currentLng }),
      },
      select: {
        id: true,
        status: true,
        lastSeenAt: true,
      }
    })

    return successResponse({
      message: status === 'AVAILABLE' ? 'ເປີດຮັບງານແລ້ວ' : 'ປິດຮັບງານແລ້ວ',
      data: updatedRider
    })

  } catch (error: any) {
    console.error('Error updating rider status:', error)
    return errorResponse(error.message || 'ເກີດຂໍ້ຜິດພາດ', 500)
  }
})
