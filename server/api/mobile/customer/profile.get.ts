import prisma from '../../../utils/prisma'
import { successResponse, unauthorizedResponse } from '../../../utils/response'

export default defineEventHandler(async (event) => {
  const user = event.context.user
  
  if (!user) {
    return unauthorizedResponse()
  }
  
  // Get customer with stats
  const customer = await prisma.customer.findUnique({
    where: { id: user.userId },
    include: {
      addresses: {
        orderBy: { isDefault: 'desc' },
      },
      _count: {
        select: {
          orders: true,
          favorites: true,
          reviews: true,
        },
      },
    },
  })
  
  if (!customer) {
    return unauthorizedResponse('ບໍ່ພົບຂໍ້ມູນລູກຄ້າ')
  }
  
  // Calculate total spent
  const totalSpent = await prisma.order.aggregate({
    where: {
      customerId: user.userId,
      status: 'DELIVERED',
    },
    _sum: { total: true },
  })
  
  return successResponse({
    id: customer.id,
    email: customer.email,
    phone: customer.phone,
    fullName: customer.fullName,
    avatar: customer.avatar,
    authProvider: customer.authProvider,
    isActive: customer.isActive,
    createdAt: customer.createdAt,
    lastLoginAt: customer.lastLoginAt,
    addresses: customer.addresses,
    _count: customer._count,
    totalSpent: totalSpent._sum.total || 0,
  })
})
