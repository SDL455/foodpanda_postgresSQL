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
            select: { id: true, name: true, logo: true }
          },
          items: {
            include: {
              product: {
                select: {
                  id: true,
                  name: true,
                  image: true,
                  basePrice: true,
                  totalSold: true,
                  category: {
                    select: { id: true, name: true }
                  }
                }
              }
            }
          }
        }
      },
      reviews: {
        take: 5,
        orderBy: { createdAt: 'desc' },
        include: {
          store: {
            select: { id: true, name: true, logo: true }
          }
        }
      },
      favorites: {
        include: {
          store: {
            select: {
              id: true,
              name: true,
              logo: true,
              address: true,
              rating: true,
              isActive: true,
              _count: {
                select: { products: true }
              }
            }
          }
        },
        orderBy: { createdAt: 'desc' }
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
  
  // Get unique stores the customer has ordered from
  const orderedStores = await prisma.order.findMany({
    where: { customerId: id },
    select: {
      store: {
        select: { id: true, name: true, logo: true }
      }
    },
    distinct: ['storeId'],
    take: 10
  })
  
  // Get popular products ordered by this customer (aggregated from order items)
  const orderedProductsMap = new Map<string, {
    product: any,
    quantity: number,
    orderCount: number
  }>()
  
  customer.orders.forEach(order => {
    order.items.forEach((item: any) => {
      if (item.product) {
        const existing = orderedProductsMap.get(item.product.id)
        if (existing) {
          existing.quantity += item.quantity
          existing.orderCount += 1
        } else {
          orderedProductsMap.set(item.product.id, {
            product: item.product,
            quantity: item.quantity,
            orderCount: 1
          })
        }
      }
    })
  })
  
  // Sort by quantity ordered (most popular first)
  const popularProducts = Array.from(orderedProductsMap.values())
    .sort((a, b) => b.quantity - a.quantity)
    .slice(0, 10)
  
  // Filter for side dishes (products in categories containing certain keywords)
  const sideDishKeywords = ['ຄຽງ', 'ເຂົ້າ', 'ເຄື່ອງດື່ມ', 'ຂອງຫວານ', 'side', 'drink', 'dessert', 'rice']
  const sideDishes = Array.from(orderedProductsMap.values())
    .filter(item => {
      const categoryName = item.product.category?.name?.toLowerCase() || ''
      return sideDishKeywords.some(keyword => categoryName.includes(keyword.toLowerCase()))
    })
    .sort((a, b) => b.quantity - a.quantity)
    .slice(0, 10)
  
  return successResponse({
    ...customer,
    totalSpent: totalSpent._sum.total || 0,
    orderedStores: orderedStores.map(o => o.store),
    popularProducts,
    sideDishes,
  })
})
