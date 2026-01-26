import prisma from '../../../utils/prisma'
import { successResponse, unauthorizedResponse, errorResponse } from '../../../utils/response'

export default defineEventHandler(async (event) => {
  const user = event.context.user
  
  console.log('=== CREATE ADDRESS REQUEST ===')
  console.log('User context:', user)
  
  if (!user) {
    console.log('No user found in context')
    return unauthorizedResponse()
  }
  
  const body = await readBody(event)
  console.log('Request body:', body)
  
  const { label, address, latitude, longitude, detail, is_default } = body
  
  // Validation
  if (!label || !address) {
    console.log('Validation failed: missing label or address')
    return errorResponse('ກະລຸນາໃສ່ຊື່ ແລະ ທີ່ຢູ່', 400)
  }
  
  if (latitude === undefined || longitude === undefined) {
    console.log('Validation failed: missing coordinates')
    return errorResponse('ກະລຸນາດຶງຕຳແໜ່ງ GPS', 400)
  }
  
  try {
    // ກວດສອບວ່າ customer ມີຢູ່ບໍ
    let customer = await prisma.customer.findUnique({
      where: { id: user.userId }
    })
    
    // ຖ້າບໍ່ພົບ Customer, ລອງຫາຈາກ email
    if (!customer && user.email) {
      customer = await prisma.customer.findFirst({
        where: { email: user.email }
      })
    }
    
    // ຖ້າຍັງບໍ່ພົບ, ສ້າງ Customer ໃໝ່ (ສຳລັບ Merchant ທີ່ຢາກທົດສອບ)
    if (!customer) {
      console.log('Customer not found, creating new one for:', user.email)
      customer = await prisma.customer.create({
        data: {
          firebaseUid: `merchant_${user.userId}`,
          email: user.email,
          authProvider: 'EMAIL',
          isActive: true,
        }
      })
    }
    
    console.log('Customer found/created:', customer.id)
    const customerId = customer.id
    
    // ຖ້າຕັ້ງເປັນທີ່ຢູ່ຫຼັກ, ຍົກເລີກທີ່ຢູ່ຫຼັກເກົ່າ
    if (is_default) {
      await prisma.customerAddress.updateMany({
        where: { customerId },
        data: { isDefault: false },
      })
    }
    
    // ສ້າງທີ່ຢູ່ໃໝ່
    const newAddress = await prisma.customerAddress.create({
      data: {
        customerId,
        label: String(label),
        address: String(address),
        lat: Number(latitude),
        lng: Number(longitude),
        note: detail ? String(detail) : null,
        isDefault: Boolean(is_default),
      },
    })
    
    console.log('Address created successfully:', newAddress.id)
    return successResponse(newAddress, 'ເພີ່ມທີ່ຢູ່ສຳເລັດແລ້ວ')
  } catch (error: any) {
    console.error('=== ERROR CREATING ADDRESS ===')
    console.error('Error name:', error.name)
    console.error('Error message:', error.message)
    console.error('Error stack:', error.stack)
    return errorResponse(`ບໍ່ສາມາດເພີ່ມທີ່ຢູ່ໄດ້: ${error.message}`, 500)
  }
})
