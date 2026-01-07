import { z } from 'zod'
import prisma from '../../utils/prisma'
import { verifyPassword } from '../../utils/password'
import { signToken } from '../../utils/jwt'
import { successResponse, errorResponse } from '../../utils/response'

const loginSchema = z.object({
  email: z.string().email('ອີເມລບໍ່ຖືກຕ້ອງ'),
  password: z.string().min(6, 'ລະຫັດຜ່ານຕ້ອງມີຢ່າງໜ້ອຍ 6 ຕົວອັກສອນ'),
})

export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  
  // Validate input
  const result = loginSchema.safeParse(body)
  if (!result.success) {
    return errorResponse(result.error.errors[0].message)
  }
  
  const { email, password } = result.data
  
  // Find user
  const user = await prisma.user.findUnique({
    where: { email },
    include: {
      merchant: true,
    },
  })
  
  if (!user) {
    return errorResponse('ອີເມລ ຫຼື ລະຫັດຜ່ານບໍ່ຖືກຕ້ອງ', 401)
  }
  
  if (!user.isActive) {
    return errorResponse('ບັນຊີຂອງທ່ານຖືກປິດໃຊ້ງານ', 403)
  }
  
  // Verify password
  const isValid = await verifyPassword(password, user.passwordHash)
  if (!isValid) {
    return errorResponse('ອີເມລ ຫຼື ລະຫັດຜ່ານບໍ່ຖືກຕ້ອງ', 401)
  }
  
  // Generate token
  const token = signToken({
    userId: user.id,
    email: user.email,
    role: user.role,
    merchantId: user.merchantId || undefined,
  })
  
  return successResponse({
    token,
    user: {
      id: user.id,
      email: user.email,
      fullName: user.fullName,
      avatar: user.avatar,
      role: user.role,
      merchant: user.merchant,
    },
  }, 'ເຂົ້າສູ່ລະບົບສຳເລັດ')
})

