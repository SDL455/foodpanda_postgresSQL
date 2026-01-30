import { z } from 'zod'
import prisma from '../../../utils/prisma'
import { successResponse, errorResponse } from '../../../utils/response'
import { signToken } from '../../../utils/jwt'
import bcrypt from 'bcryptjs'

const loginSchema = z.object({
  storeId: z.string().min(1),
  password: z.string().min(1),
})

/**
 * POST /api/auth/store/login
 * Store/Merchant ເຂົ້າສູ່ລະບົບ
 */
export default defineEventHandler(async (event) => {
  try {
    const body = await readBody(event)
    const result = loginSchema.safeParse(body)

    if (!result.success) {
      return errorResponse('ຂໍ້ມູນບໍ່ຖືກຕ້ອງ', 400)
    }

    const { storeId, password } = result.data

    // Find store
    const store = await prisma.store.findUnique({
      where: { id: storeId },
      include: {
        merchant: true,
      },
    })

    if (!store) {
      return errorResponse('ບໍ່ພົບ Store', 404)
    }

    if (!store.isActive) {
      return errorResponse('ຮ້ານບໍ່ສາມາດໃຊ້ງານ', 400)
    }

    // Check password (assume store has passwordHash - add to schema if needed)
    // For now, we'll create a simple check
    // In production, you should store hashed password for store
    const isPasswordValid = password === store.id + '123' // Simple check - CHANGE THIS!

    if (!isPasswordValid) {
      return errorResponse('ລະຫັດຜ່ານບໍ່ຖືກຕ້ອງ', 401)
    }

    // Generate JWT token
    const token = signToken({
      storeId: store.id,
      storeName: store.name,
      merchantId: store.merchantId,
    })

    return successResponse({
      token,
      store: {
        id: store.id,
        name: store.name,
        phone: store.phone,
        address: store.address,
        logo: store.logo,
        merchantId: store.merchantId,
      },
    })
  } catch (error: any) {
    console.error('Error logging in store:', error)
    return errorResponse(error.message || 'ເກີດຂໍ້ຜິດພາດ', 500)
  }
})
