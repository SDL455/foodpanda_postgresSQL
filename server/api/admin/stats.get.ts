import prisma from '../../utils/prisma'
import { successResponse, unauthorizedResponse, forbiddenResponse } from '../../utils/response'

export default defineEventHandler(async (event) => {
  const user = event.context.user
  
  if (!user) {
    return unauthorizedResponse()
  }
  
  if (user.role !== 'SUPER_ADMIN') {
    return forbiddenResponse('ບໍ່ມີສິດເຂົ້າເຖິງ')
  }
  
  // Get current date range
  const today = new Date()
  today.setHours(0, 0, 0, 0)
  
  const startOfMonth = new Date(today.getFullYear(), today.getMonth(), 1)
  
  // Parallel queries for better performance
  const [
    totalCustomers,
    newCustomersToday,
    newCustomersThisMonth,
    totalMerchants,
    activeMerchants,
    totalStores,
    activeStores,
    totalRiders,
    activeRiders,
    availableRiders,
    totalOrders,
    todayOrders,
    pendingOrders,
    todayRevenue,
    monthRevenue,
  ] = await Promise.all([
    // Customers
    prisma.customer.count(),
    prisma.customer.count({
      where: { createdAt: { gte: today } }
    }),
    prisma.customer.count({
      where: { createdAt: { gte: startOfMonth } }
    }),
    
    // Merchants
    prisma.merchant.count(),
    prisma.merchant.count({
      where: { isActive: true }
    }),
    
    // Stores
    prisma.store.count(),
    prisma.store.count({
      where: { isActive: true }
    }),
    
    // Riders
    prisma.rider.count(),
    prisma.rider.count({
      where: { isActive: true }
    }),
    prisma.rider.count({
      where: { status: 'AVAILABLE' }
    }),
    
    // Orders
    prisma.order.count(),
    prisma.order.count({
      where: { createdAt: { gte: today } }
    }),
    prisma.order.count({
      where: { status: 'PENDING' }
    }),
    
    // Revenue
    prisma.order.aggregate({
      where: {
        createdAt: { gte: today },
        status: { in: ['DELIVERED', 'CONFIRMED', 'PREPARING', 'READY_FOR_PICKUP', 'PICKED_UP', 'DELIVERING'] }
      },
      _sum: { total: true }
    }),
    prisma.order.aggregate({
      where: {
        createdAt: { gte: startOfMonth },
        status: { in: ['DELIVERED', 'CONFIRMED', 'PREPARING', 'READY_FOR_PICKUP', 'PICKED_UP', 'DELIVERING'] }
      },
      _sum: { total: true }
    }),
  ])
  
  // Recent customers
  const recentCustomers = await prisma.customer.findMany({
    take: 5,
    orderBy: { createdAt: 'desc' },
    select: {
      id: true,
      fullName: true,
      email: true,
      phone: true,
      avatar: true,
      authProvider: true,
      createdAt: true,
      _count: {
        select: { orders: true }
      }
    }
  })
  
  return successResponse({
    customers: {
      total: totalCustomers,
      newToday: newCustomersToday,
      newThisMonth: newCustomersThisMonth,
    },
    merchants: {
      total: totalMerchants,
      active: activeMerchants,
    },
    stores: {
      total: totalStores,
      active: activeStores,
    },
    riders: {
      total: totalRiders,
      active: activeRiders,
      available: availableRiders,
    },
    orders: {
      total: totalOrders,
      today: todayOrders,
      pending: pendingOrders,
    },
    revenue: {
      today: todayRevenue._sum.total || 0,
      month: monthRevenue._sum.total || 0,
    },
    recentCustomers,
  })
})
