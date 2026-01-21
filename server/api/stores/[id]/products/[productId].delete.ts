import prisma from '../../../../utils/prisma'
import { successResponse, errorResponse, unauthorizedResponse, forbiddenResponse, notFoundResponse } from '../../../../utils/response'

export default defineEventHandler(async (event) => {
  const user = event.context.user
  
  if (!user) {
    return unauthorizedResponse()
  }
  
  const storeId = getRouterParam(event, 'id')
  const productId = getRouterParam(event, 'productId')
  
  if (!storeId || !productId) {
    return errorResponse('ບໍ່ພົບ ID')
  }
  
  const store = await prisma.store.findUnique({
    where: { id: storeId },
  })
  
  if (!store) {
    return notFoundResponse('ບໍ່ພົບຮ້ານ')
  }
  
  // Check access
  if (user.role !== 'SUPER_ADMIN' && store.merchantId !== user.merchantId) {
    return forbiddenResponse('ບໍ່ມີສິດເຂົ້າເຖິງ')
  }
  
  const existingProduct = await prisma.product.findFirst({
    where: { id: productId, storeId },
  })
  
  if (!existingProduct) {
    return notFoundResponse('ບໍ່ພົບສິນຄ້າ')
  }
  
  await prisma.product.delete({
    where: { id: productId },
  })
  
  // Log action
  await prisma.auditLog.create({
    data: {
      actorId: user.userId,
      action: 'DELETE_PRODUCT',
      entity: 'Product',
      entityId: productId,
      meta: { productName: existingProduct.name, storeId },
    },
  })
  
  return successResponse(null, 'ລຶບສິນຄ້າສຳເລັດ')
})
