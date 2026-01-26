import prisma from '../../../../utils/prisma'
import { successResponse, unauthorizedResponse, errorResponse } from '../../../../utils/response'

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
    
    // ກວດສອບວ່າບໍ່ມີ order ທີ່ໃຊ້ທີ່ຢູ່ນີ້
    const ordersCount = await prisma.order.count({
      where: { addressId: id },
    })
    
    if (ordersCount > 0) {
      return errorResponse('ບໍ່ສາມາດລຶບທີ່ຢູ່ນີ້ເພາະມີ order ໃຊ້ຢູ່', 400)
    }
    
    // ລຶບທີ່ຢູ່
    await prisma.customerAddress.delete({
      where: { id },
    })
    
    return successResponse(null, 'ລຶບທີ່ຢູ່ສຳເລັດແລ້ວ')
  } catch (error) {
    console.error('Error deleting address:', error)
    return errorResponse('ບໍ່ສາມາດລຶບທີ່ຢູ່ໄດ້', 500)
  }
})
