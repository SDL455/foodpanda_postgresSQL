import prisma from '../../../../../utils/prisma'
import { successResponse, unauthorizedResponse, errorResponse } from '../../../../../utils/response'

export default defineEventHandler(async (event) => {
  const user = event.context.user
  
  if (!user) {
    return unauthorizedResponse()
  }
  
  const id = getRouterParam(event, 'id')
  
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
    
    // ຍົກເລີກທີ່ຢູ່ຫຼັກເກົ່າທັງໝົດ
    await prisma.customerAddress.updateMany({
      where: { 
        customerId,
        id: { not: id }
      },
      data: { isDefault: false },
    })
    
    // ຕັ້ງທີ່ຢູ່ນີ້ເປັນທີ່ຢູ່ຫຼັກ
    const updatedAddress = await prisma.customerAddress.update({
      where: { id },
      data: { isDefault: true },
    })
    
    return successResponse(updatedAddress, 'ຕັ້ງເປັນທີ່ຢູ່ຫຼັກສຳເລັດແລ້ວ')
  } catch (error) {
    console.error('Error setting default address:', error)
    return errorResponse('ບໍ່ສາມາດຕັ້ງເປັນທີ່ຢູ່ຫຼັກໄດ້', 500)
  }
})
