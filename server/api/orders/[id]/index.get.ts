import prisma from '../../../utils/prisma'
import { successResponse, unauthorizedResponse, forbiddenResponse, notFoundResponse, errorResponse } from '../../../utils/response'

export default defineEventHandler(async (event) => {
  const user = event.context.user
  
  if (!user) {
    return unauthorizedResponse()
  }
  
  const id = getRouterParam(event, 'id')
  if (!id) {
    return errorResponse('ບໍ່ພົບ ID')
  }
  
  const order = await prisma.order.findUnique({
    where: { id },
    include: {
      customer: {
        select: { id: true, fullName: true, phone: true, email: true, avatar: true },
      },
      store: {
        select: { id: true, name: true, phone: true, address: true, merchantId: true },
      },
      items: {
        include: {
          product: {
            select: { id: true, name: true, image: true },
          },
          variants: true,
        },
      },
      delivery: {
        include: {
          rider: {
            select: { id: true, fullName: true, phone: true, vehicleType: true, vehiclePlate: true },
          },
        },
      },
      payment: true,
      review: true,
    },
  })
  
  if (!order) {
    return notFoundResponse('ບໍ່ພົບ Order')
  }
  
  // Check access
  if (user.role !== 'SUPER_ADMIN' && order.store.merchantId !== user.merchantId) {
    return forbiddenResponse('ບໍ່ມີສິດເຂົ້າເຖິງ')
  }
  
  return successResponse(order)
})

