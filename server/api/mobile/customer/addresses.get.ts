import prisma from '../../../utils/prisma'
import { successResponse, unauthorizedResponse } from '../../../utils/response'

export default defineEventHandler(async (event) => {
  const user = event.context.user
  
  if (!user) {
    return unauthorizedResponse()
  }
  
  const addresses = await prisma.customerAddress.findMany({
    where: { customerId: user.userId },
    orderBy: [
      { isDefault: 'desc' },
      { createdAt: 'desc' },
    ],
  })
  
  return successResponse(addresses)
})
