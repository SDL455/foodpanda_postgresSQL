import prisma from '../utils/prisma'
import { sendFCMNotification, type FCMNotification, type FCMData } from '../utils/firebase'
import type { NotificationType } from '@prisma/client'

// ============================================
// Notification Content Templates
// ============================================

interface NotificationContent {
  title: string
  body: string
}

const notificationTemplates: Record<NotificationType, (data?: any) => NotificationContent> = {
  ORDER_PLACED: (data) => ({
    title: 'ສັ່ງຊື້ສຳເລັດ',
    body: `Order #${data?.orderNo || ''} ໄດ້ຖືກສົ່ງໄປຍັງຮ້ານແລ້ວ`,
  }),
  ORDER_CONFIRMED: (data) => ({
    title: 'ຮ້ານຢືນຢັນແລ້ວ',
    body: `Order #${data?.orderNo || ''} ຮ້ານ ${data?.storeName || ''} ກຳລັງກະກຽມ`,
  }),
  ORDER_PREPARING: (data) => ({
    title: 'ກຳລັງກະກຽມ',
    body: `Order #${data?.orderNo || ''} ກຳລັງຖືກກະກຽມ`,
  }),
  ORDER_READY: (data) => ({
    title: 'ພ້ອມສົ່ງ',
    body: `Order #${data?.orderNo || ''} ພ້ອມໃຫ້ Rider ມາຮັບແລ້ວ`,
  }),
  ORDER_PICKED_UP: (data) => ({
    title: 'Rider ຮັບແລ້ວ',
    body: `Order #${data?.orderNo || ''} Rider ກຳລັງມາຫາທ່ານ`,
  }),
  ORDER_DELIVERING: (data) => ({
    title: 'ກຳລັງຈັດສົ່ງ',
    body: `Order #${data?.orderNo || ''} ກຳລັງຖືກຈັດສົ່ງ`,
  }),
  ORDER_DELIVERED: (data) => ({
    title: 'ສົ່ງສຳເລັດ',
    body: `Order #${data?.orderNo || ''} ໄດ້ຖືກສົ່ງສຳເລັດແລ້ວ ຂອບໃຈທີ່ໃຊ້ບໍລິການ`,
  }),
  ORDER_CANCELLED: (data) => ({
    title: 'ຍົກເລີກ Order',
    body: `Order #${data?.orderNo || ''} ໄດ້ຖືກຍົກເລີກ${data?.reason ? `: ${data.reason}` : ''}`,
  }),
  NEW_ORDER: (data) => ({
    title: 'ມີ Order ໃໝ່!',
    body: `Order #${data?.orderNo || ''} ມູນຄ່າ ${formatPrice(data?.total || 0)}`,
  }),
  NEW_DELIVERY: (data) => ({
    title: 'ມີງານສົ່ງໃໝ່!',
    body: `Order #${data?.orderNo || ''} ຈາກ ${data?.storeName || ''} ໄປ ${data?.address || ''}`,
  }),
  DELIVERY_ASSIGNED: (data) => ({
    title: 'ໄດ້ຮັບມອບໝາຍງານ',
    body: `ທ່ານໄດ້ຮັບມອບໝາຍໃຫ້ສົ່ງ Order #${data?.orderNo || ''}`,
  }),
  PROMOTION: (data) => ({
    title: data?.title || 'ໂປຣໂມຊັ່ນພິເສດ!',
    body: data?.body || 'ກວດເບິ່ງໂປຣໂມຊັ່ນໃໝ່ໄດ້ເລີຍ',
  }),
  CHAT_MESSAGE: (data) => ({
    title: data?.senderName || 'ຂໍ້ຄວາມໃໝ່',
    body: data?.message || 'ທ່ານໄດ້ຮັບຂໍ້ຄວາມໃໝ່',
  }),
  SYSTEM: (data) => ({
    title: data?.title || 'ແຈ້ງເຕືອນລະບົບ',
    body: data?.body || '',
  }),
}

function formatPrice(amount: number): string {
  return new Intl.NumberFormat('lo-LA', {
    style: 'currency',
    currency: 'LAK',
  }).format(amount)
}

// ============================================
// Send Notification Functions
// ============================================

interface SendNotificationOptions {
  type: NotificationType
  customerId?: string
  riderId?: string
  userId?: string
  orderId?: string
  data?: Record<string, any>
  customContent?: NotificationContent
  image?: string
}

/**
 * Send notification to a user
 * - Saves to database
 * - Sends push notification via FCM
 */
export async function sendNotification(options: SendNotificationOptions) {
  const { type, customerId, riderId, userId, orderId, data, customContent, image } = options

  // Get notification content
  const content = customContent || notificationTemplates[type]?.(data) || {
    title: 'ແຈ້ງເຕືອນ',
    body: '',
  }

  // Create notification record in database
  const notification = await prisma.notification.create({
    data: {
      type,
      customerId,
      riderId,
      userId,
      orderId,
      title: content.title,
      body: content.body,
      image,
      data: data || {},
    },
  })

  // Get FCM tokens
  let tokens: string[] = []

  if (customerId) {
    const deviceTokens = await prisma.deviceToken.findMany({
      where: { customerId, isActive: true },
      select: { fcmToken: true },
    })
    tokens = deviceTokens.map((t) => t.fcmToken)
  } else if (riderId) {
    const deviceTokens = await prisma.deviceToken.findMany({
      where: { riderId, isActive: true },
      select: { fcmToken: true },
    })
    tokens = deviceTokens.map((t) => t.fcmToken)
  }

  // Send FCM notification
  if (tokens.length > 0) {
    const fcmNotification: FCMNotification = {
      title: content.title,
      body: content.body,
      imageUrl: image,
    }

    const fcmData: FCMData = {
      type,
      notificationId: notification.id,
      ...(orderId && { orderId }),
      ...(data && Object.fromEntries(
        Object.entries(data).map(([k, v]) => [k, String(v)])
      )),
    }

    const result = await sendFCMNotification({
      tokens,
      notification: fcmNotification,
      data: fcmData,
    })

    // Update notification with send status
    await prisma.notification.update({
      where: { id: notification.id },
      data: {
        isSent: result.successCount > 0,
        sentAt: result.successCount > 0 ? new Date() : null,
        fcmError: result.failureCount > 0 ? `Failed: ${result.failedTokens.join(', ')}` : null,
      },
    })

    // Deactivate failed tokens
    if (result.failedTokens.length > 0) {
      await prisma.deviceToken.updateMany({
        where: { fcmToken: { in: result.failedTokens } },
        data: { isActive: false },
      })
    }

    return {
      notification,
      fcmResult: result,
    }
  }

  return {
    notification,
    fcmResult: null,
  }
}

// ============================================
// Helper Functions for Common Notifications
// ============================================

/**
 * Send order status notification to customer
 */
export async function notifyCustomerOrderStatus(
  orderId: string,
  status: NotificationType,
  additionalData?: Record<string, any>
) {
  const order = await prisma.order.findUnique({
    where: { id: orderId },
    include: {
      customer: true,
      store: { select: { name: true } },
    },
  })

  if (!order) {
    throw new Error('Order not found')
  }

  return sendNotification({
    type: status,
    customerId: order.customerId,
    orderId,
    data: {
      orderNo: order.orderNo,
      storeName: order.store.name,
      total: order.total,
      ...additionalData,
    },
  })
}

/**
 * Send new order notification to store/merchant
 */
export async function notifyStoreNewOrder(orderId: string) {
  const order = await prisma.order.findUnique({
    where: { id: orderId },
    include: {
      store: {
        include: {
          merchant: {
            include: {
              users: { where: { isActive: true } },
            },
          },
        },
      },
    },
  })

  if (!order) {
    throw new Error('Order not found')
  }

  // Check if merchant exists and has users
  if (!order.store.merchant || !order.store.merchant.users || order.store.merchant.users.length === 0) {
    console.warn(`No active merchant users found for order ${orderId}`)
    return []
  }

  // Notify all merchant users
  const notifications = await Promise.all(
    order.store.merchant.users.map((user) =>
      sendNotification({
        type: 'NEW_ORDER',
        userId: user.id,
        orderId,
        data: {
          orderNo: order.orderNo,
          total: order.total,
          storeName: order.store.name,
        },
      })
    )
  )

  return notifications
}

/**
 * Send new delivery notification to rider
 */
export async function notifyRiderNewDelivery(orderId: string, riderId: string) {
  const order = await prisma.order.findUnique({
    where: { id: orderId },
    include: {
      store: { select: { name: true, address: true } },
    },
  })

  if (!order) {
    throw new Error('Order not found')
  }

  return sendNotification({
    type: 'NEW_DELIVERY',
    riderId,
    orderId,
    data: {
      orderNo: order.orderNo,
      storeName: order.store.name,
      storeAddress: order.store.address,
      address: order.deliveryAddress,
    },
  })
}

/**
 * Send new delivery notification to all available riders
 */
export async function notifyAllAvailableRiders(orderId: string) {
  const order = await prisma.order.findUnique({
    where: { id: orderId },
    include: {
      store: { select: { name: true, address: true } },
    },
  })

  if (!order) {
    throw new Error('Order not found')
  }

  // Get all available riders
  const availableRiders = await prisma.rider.findMany({
    where: {
      status: 'AVAILABLE',
      isActive: true,
    },
    select: { id: true },
  })

  // Notify all available riders
  const notifications = await Promise.all(
    availableRiders.map((rider) =>
      sendNotification({
        type: 'NEW_DELIVERY',
        riderId: rider.id,
        orderId,
        data: {
          orderNo: order.orderNo,
          storeName: order.store.name,
          storeAddress: order.store.address,
          address: order.deliveryAddress,
          total: order.total,
        },
      })
    )
  )

  return {
    sentCount: notifications.length,
    notifications,
  }
}

/**
 * Send promotion notification to all customers
 */
export async function sendPromotionToAllCustomers(
  title: string,
  body: string,
  image?: string
) {
  const customers = await prisma.customer.findMany({
    where: { isActive: true },
    select: { id: true },
  })

  const notifications = await Promise.all(
    customers.map((customer) =>
      sendNotification({
        type: 'PROMOTION',
        customerId: customer.id,
        customContent: { title, body },
        image,
      })
    )
  )

  return {
    sentCount: notifications.length,
    notifications,
  }
}

