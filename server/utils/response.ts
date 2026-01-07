import { H3Event } from 'h3'

export interface ApiResponse<T = any> {
  success: boolean
  data?: T
  message?: string
  error?: string
}

export function successResponse<T>(data: T, message?: string): ApiResponse<T> {
  return {
    success: true,
    data,
    message,
  }
}

export function errorResponse(error: string, statusCode: number = 400): never {
  throw createError({
    statusCode,
    message: error,
  })
}

export function unauthorizedResponse(message: string = 'Unauthorized'): never {
  throw createError({
    statusCode: 401,
    message,
  })
}

export function forbiddenResponse(message: string = 'Forbidden'): never {
  throw createError({
    statusCode: 403,
    message,
  })
}

export function notFoundResponse(message: string = 'Not found'): never {
  throw createError({
    statusCode: 404,
    message,
  })
}

