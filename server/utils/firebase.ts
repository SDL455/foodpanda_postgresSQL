import admin from 'firebase-admin'

// Initialize Firebase Admin SDK
// ໝາຍເຫດ: ຕ້ອງສ້າງ Service Account ຈາກ Firebase Console
// ແລະ ເກັບໄວ້ໃນ environment variable ຫຼື file

let firebaseApp: admin.app.App | null = null

export function initializeFirebase() {
  if (firebaseApp) {
    return firebaseApp
  }

  try {
    // ວິທີທີ 1: ໃຊ້ Environment Variable (ແນະນຳສຳລັບ Production)
    const serviceAccountJson = process.env.FIREBASE_SERVICE_ACCOUNT
    
    if (serviceAccountJson) {
      const serviceAccount = JSON.parse(serviceAccountJson)
      firebaseApp = admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
      })
    } else {
      // ວິທີທີ 2: ໃຊ້ Application Default Credentials (ສຳລັບ Development)
      firebaseApp = admin.initializeApp({
        credential: admin.credential.applicationDefault(),
      })
    }

    console.log('✅ Firebase Admin SDK initialized successfully')
    return firebaseApp
  } catch (error) {
    console.error('❌ Failed to initialize Firebase Admin SDK:', error)
    return null
  }
}

export function getFirebaseAdmin() {
  if (!firebaseApp) {
    initializeFirebase()
  }
  return admin
}

export function getMessaging() {
  const adminInstance = getFirebaseAdmin()
  return adminInstance.messaging()
}

// ============================================
// FCM Message Types
// ============================================

export interface FCMNotification {
  title: string
  body: string
  imageUrl?: string
}

export interface FCMData {
  [key: string]: string
}

export interface SendNotificationOptions {
  tokens: string[]
  notification: FCMNotification
  data?: FCMData
}

// ============================================
// Send FCM Push Notification
// ============================================

export async function sendFCMNotification(options: SendNotificationOptions): Promise<{
  successCount: number
  failureCount: number
  failedTokens: string[]
}> {
  const { tokens, notification, data } = options

  if (!tokens || tokens.length === 0) {
    return { successCount: 0, failureCount: 0, failedTokens: [] }
  }

  try {
    const messaging = getMessaging()

    const message: admin.messaging.MulticastMessage = {
      tokens,
      notification: {
        title: notification.title,
        body: notification.body,
        imageUrl: notification.imageUrl,
      },
      data: data || {},
      android: {
        priority: 'high',
        notification: {
          sound: 'default',
          clickAction: 'FLUTTER_NOTIFICATION_CLICK',
          channelId: 'foodpanda_notifications',
        },
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
          },
        },
      },
    }

    const response = await messaging.sendEachForMulticast(message)

    // ເກັບ tokens ທີ່ສົ່ງບໍ່ສຳເລັດ
    const failedTokens: string[] = []
    response.responses.forEach((resp, idx) => {
      if (!resp.success) {
        failedTokens.push(tokens[idx])
        console.error(`Failed to send to token ${tokens[idx]}:`, resp.error)
      }
    })

    return {
      successCount: response.successCount,
      failureCount: response.failureCount,
      failedTokens,
    }
  } catch (error) {
    console.error('Error sending FCM notification:', error)
    return {
      successCount: 0,
      failureCount: tokens.length,
      failedTokens: tokens,
    }
  }
}

// ============================================
// Send to Single Token
// ============================================

export async function sendFCMToToken(
  token: string,
  notification: FCMNotification,
  data?: FCMData
): Promise<boolean> {
  const result = await sendFCMNotification({
    tokens: [token],
    notification,
    data,
  })
  return result.successCount > 0
}

