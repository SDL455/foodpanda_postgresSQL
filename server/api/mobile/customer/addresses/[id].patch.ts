import prisma from '../../../../utils/prisma'
import { successResponse, unauthorizedResponse, errorResponse } from '../../../../utils/response'

export default defineEventHandler(async (event) => {
  const user = event.context.user
  
  if (!user) {
    return unauthorizedResponse()
  }
  
  const id = getRouterParam(event, 'id')
  const body = await readBody(event)
  const { label, address, latitude, longitude, detail, is_default } = body
  
  if (!id) {
    return errorResponse('ບໍ່ພົບ ID ທີ່ຢູ່', 400)
  }
  
  try {
    // ຊອກຫາ Customer ID
    let customerId = user.userId
    const customerById = await prisma.customer.findUnique({
      where: { id: user.userId }
    })
    if (!customerById && user.email) {
      const customerByEmail = await prisma.customer.findFirst({
        where: { email: user.email }
      })
      if (customerByEmail) {
        customerId = customerByEmail.id
      }
    }
    
    // ກວດສອບວ່າທີ່ຢູ່ເປັນຂອງ user ນີ້
    const existingAddress = await prisma.customerAddress.findFirst({
      where: { 
        id, 
        customerId 
      },
    })
    
    if (!existingAddress) {
      return errorResponse('ບໍ່ພົບທີ່ຢູ່ນີ້', 404)
    }
    
    // ຖ້າຕັ້ງເປັນທີ່ຢູ່ຫຼັກ, ຍົກເລີກທີ່ຢູ່ຫຼັກເກົ່າ
    if (is_default) {
      await prisma.customerAddress.updateMany({
        where: { 
          customerId,
          id: { not: id }
        },
        data: { isDefault: false },
      })
    }
    
    // ອັບເດດທີ່ຢູ່
    const updatedAddress = await prisma.customerAddress.update({
      where: { id },
      data: {
        ...(label !== undefined && { label }),
        ...(address !== undefined && { address }),
        ...(latitude !== undefined && { lat: latitude }),
        ...(longitude !== undefined && { lng: longitude }),
        ...(detail !== undefined && { note: detail }),
        ...(is_default !== undefined && { isDefault: is_default }),
      },
    })
    
    return successResponse(updatedAddress, 'ອັບເດດທີ່ຢູ່ສຳເລັດແລ້ວ')
  } catch (error) {
    console.error('Error updating address:', error)
    return errorResponse('ບໍ່ສາມາດອັບເດດທີ່ຢູ່ໄດ້', 500)
  }
})
