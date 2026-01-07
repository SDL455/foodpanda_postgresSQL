import jwt from 'jsonwebtoken'
import type { UserRole } from '@prisma/client'

export interface JwtPayload {
  userId: string
  email: string
  role: UserRole
  merchantId?: string
}

export interface RiderJwtPayload {
  riderId: string
  email: string
  type: 'rider'
}

export function signToken(payload: JwtPayload | RiderJwtPayload): string {
  const config = useRuntimeConfig()
  return jwt.sign(payload, config.jwtSecret, {
    expiresIn: config.jwtExpiresIn,
  })
}

export function verifyToken(token: string): JwtPayload | RiderJwtPayload | null {
  try {
    const config = useRuntimeConfig()
    return jwt.verify(token, config.jwtSecret) as JwtPayload | RiderJwtPayload
  } catch {
    return null
  }
}

export function getTokenFromHeader(event: any): string | null {
  const authHeader = getHeader(event, 'Authorization')
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return null
  }
  return authHeader.slice(7)
}

