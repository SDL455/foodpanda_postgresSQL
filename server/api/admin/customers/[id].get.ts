import prisma from '../../../utils/prisma'
import { successResponse, unauthorizedResponse, forbiddenResponse, notFoundResponse } from '../../../utils/response'

export default defineEventHandler(async (event) => {
  const user = event.context.user
  
  if (!user) {
    return unauthorizedResponse()
  }
  
  if (user.role !== 'SUPER_ADMIN') {
    return forbiddenResponse('ບໍ່ມີສິດເຂົ້າເຖິງ')
  }
  
  const id = getRouterParam(event, 'id')
  if (!id) {
    return notFoundResponse('ບໍ່ພົບ ID')
  }
  
  const customer = await prisma.customer.findUnique({
    where: { id },
    include: {
      addresses: true,
      orders: {
        take: 10,
        orderBy: { createdAt: 'desc' },
        include: {
          store: {
            select: { id: true, name: true }
          }
        }
      },
      reviews: {
        take: 5,
        orderBy: { createdAt: 'desc' },
        include: {
          store: {
            select: { id: true, name: true }
          }
        }
      },
      _count: {
        select: {
          orders: true,
          reviews: true,
          favorites: true,
        }
      }
    }
  })
  
  if (!customer) {
    return notFoundResponse('ບໍ່ພົບລູກຄ້າ')
  }
  
  // Calculate total spent
  const totalSpent = await prisma.order.aggregate({
    where: {
      customerId: id,
      status: 'DELIVERED'
    },
    _sum: { total: true }
  })
  
  return successResponse({
    ...customer,
    totalSpent: totalSpent._sum.total || 0,
  })
})
