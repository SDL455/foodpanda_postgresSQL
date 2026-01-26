import prisma from '../../../utils/prisma'
import { successResponse, unauthorizedResponse } from '../../../utils/response'

export default defineEventHandler(async (event) => {
  const user = event.context.user
  
  if (!user) {
    return unauthorizedResponse()
  }
  
  // ຊອກຫາ Customer ID
  let customerId = user.userId
  
  // ຖ້າບໍ່ພົບ Customer ດ້ວຍ userId, ລອງຫາຈາກ email
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
  
  const addresses = await prisma.customerAddress.findMany({
    where: { customerId },
    orderBy: [
      { isDefault: 'desc' },
      { createdAt: 'desc' },
    ],
  })
  
  return successResponse(addresses)
})
