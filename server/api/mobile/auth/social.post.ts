import { z } from 'zod'
import prisma from '../../../utils/prisma'
import { signToken } from '../../../utils/jwt'
import { successResponse, errorResponse } from '../../../utils/response'

// TODO: In production, verify Firebase ID token
// import admin from 'firebase-admin'

const socialAuthSchema = z.object({
  firebaseUid: z.string().min(1),
  provider: z.enum(['GOOGLE', 'FACEBOOK', 'APPLE', 'EMAIL', 'PHONE']),
  email: z.string().email().optional(),
  phone: z.string().optional(),
  fullName: z.string().optional(),
  avatar: z.string().optional(),
  googleId: z.string().optional(),
  facebookId: z.string().optional(),
  appleId: z.string().optional(),
})

export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  const result = socialAuthSchema.safeParse(body)
  
  if (!result.success) {
    return errorResponse(result.error.errors[0].message)
  }
  
  const { firebaseUid, provider, email, phone, fullName, avatar, googleId, facebookId, appleId } = result.data
  
  // TODO: Verify Firebase ID token in production
  // const decodedToken = await admin.auth().verifyIdToken(idToken)
  // if (decodedToken.uid !== firebaseUid) {
  //   return errorResponse('Invalid token', 401)
  // }
  
  // Find or create customer
  let customer = await prisma.customer.findUnique({
    where: { firebaseUid },
  })
  
  if (!customer) {
    // Create new customer
    customer = await prisma.customer.create({
      data: {
        firebaseUid,
        authProvider: provider,
        email,
        phone,
        fullName,
        avatar,
        googleId,
        facebookId,
        appleId,
        lastLoginAt: new Date(),
      },
    })
  } else {
    // Update last login
    customer = await prisma.customer.update({
      where: { id: customer.id },
      data: {
        lastLoginAt: new Date(),
        // Update info if provided
        ...(fullName && { fullName }),
        ...(avatar && { avatar }),
      },
    })
  }
  
  // Generate token (for API access)
  const token = signToken({
    userId: customer.id,
    email: customer.email || '',
    role: 'CUSTOMER' as any,
  })
  
  return successResponse({
    token,
    customer: {
      id: customer.id,
      email: customer.email,
      phone: customer.phone,
      fullName: customer.fullName,
      avatar: customer.avatar,
      authProvider: customer.authProvider,
    },
  }, 'ເຂົ້າສູ່ລະບົບສຳເລັດ')
})

