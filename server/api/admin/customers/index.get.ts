import prisma from '../../../utils/prisma'
import { successResponse, unauthorizedResponse, forbiddenResponse } from '../../../utils/response'

export default defineEventHandler(async (event) => {
  const user = event.context.user
  
  if (!user) {
    return unauthorizedResponse()
  }
  
  if (user.role !== 'SUPER_ADMIN') {
    return forbiddenResponse('ບໍ່ມີສິດເຂົ້າເຖິງ')
  }
  
  const query = getQuery(event)
  const page = Number(query.page) || 1
  const limit = Number(query.limit) || 10
  const search = query.search as string | undefined
  const provider = query.provider as string | undefined
  const status = query.status as string | undefined
  
  const where: any = {}
  
  if (search) {
    where.OR = [
      { fullName: { contains: search, mode: 'insensitive' } },
      { email: { contains: search, mode: 'insensitive' } },
      { phone: { contains: search, mode: 'insensitive' } },
    ]
  }
  
  if (provider) {
    where.authProvider = provider
  }
  
  // Filter by status (active/inactive)
  if (status === 'active') {
    where.isActive = true
  } else if (status === 'inactive') {
    where.isActive = false
  }
  
  const [customers, total, activeCustomers] = await Promise.all([
    prisma.customer.findMany({
      where,
      skip: (page - 1) * limit,
      take: limit,
      orderBy: { createdAt: 'desc' },
      select: {
        id: true,
        fullName: true,
        email: true,
        phone: true,
        avatar: true,
        authProvider: true,
        isActive: true,
        createdAt: true,
        lastLoginAt: true,
        _count: {
          select: {
            orders: true,
            reviews: true,
            favorites: true,
          }
        }
      }
    }),
    prisma.customer.count({ where }),
    prisma.customer.count({ where: { ...where, isActive: true } }),
  ])
  
  // Get total spent for each customer
  const customerIds = customers.map(c => c.id)
  const totalSpentData = await prisma.order.groupBy({
    by: ['customerId'],
    where: {
      customerId: { in: customerIds },
      status: 'DELIVERED'
    },
    _sum: { total: true }
  })
  
  // Map total spent to customers
  const totalSpentMap = new Map(
    totalSpentData.map(item => [item.customerId, item._sum.total || 0])
  )
  
  const customersWithSpent = customers.map(customer => ({
    ...customer,
    totalSpent: totalSpentMap.get(customer.id) || 0,
  }))
  
  return successResponse({
    customers: customersWithSpent,
    pagination: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
    },
    stats: {
      active: activeCustomers,
    }
  })
})
