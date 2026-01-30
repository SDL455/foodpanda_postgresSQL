# 🍕 Foodpanda Store Dashboard - Setup Guide

## ⚠️ ບັນຫາທີ່ຕົວຈິງ (Root Cause)

Rider ບໍ່ເຫັນ delivery ເພາະ:
1. **Order ຍັງເປັນ `PENDING`** - ກຳລັງລໍຖ້າ store ຢືນຢັນ
2. **Store ບໍ່ມີ UI** - ບໍ່ມີວິທີອັບເດດ order status
3. **Riders ເບິ່ງເฉພາະ `READY_FOR_PICKUP` orders** - ເບິ່ງ `server/api/mobile/rider/deliveries/index.get.ts` ເສັ້ນ 46-48

---

## 📁 ໂຄງສ້າງແຟ້ມທີ່ສ້າງໃໝ່

```
server/
├── api/
│   ├── auth/
│   │   └── store/
│   │       └── login.post.ts          ← Store login API
│   └── mobile/
│       └── store/
│           └── orders/
│               ├── index.get.ts       ← Get store orders
│               ├── [id]/
│               │   ├── index.get.ts   ← Get order detail
│               │   └── status.patch.ts ← Update order status
│
foodpanda/
├── lib/
│   ├── pages/
│   │   └── store/
│   │       ├── controllers/
│   │       │   └── store_orders_controller.dart
│   │       └── views/
│   │           └── store_orders_view.dart
│   └── data/
│       └── repositories/
│           └── store_repository.dart
```

---

## 🚀 ວິທີ Setup

### Step 1: ອັບເດດ JWT ສຳລັບ Store Token

ບັນ `server/utils/jwt.ts` - ຈື່ຕ້ອງ support `storeId` ໃນ token:

```typescript
export interface TokenPayload {
  userId?: string
  riderId?: string
  storeId?: string      // ← ເພີ່ມ store
  storeName?: string
  merchantId?: string
}
```

### Step 2: ອັບເດດ Store Model (Prisma)

ບັນ `prisma/schema.prisma` - ເພີ່ມ `password` ວ່າ store:

```prisma
model Store {
  id                String    @id @default(cuid())
  merchantId        String
  name              String
  phone             String?
  address           String?
  lat               Float?
  lng               Float?
  logo              String?
  passwordHash      String?   // ← ເພີ່ມ ນີ້
  // ... ອື່ນ
}
```

Run migration:
```bash
npx prisma migrate dev --name add_store_password
npx prisma generate
```

### Step 3: Deploy API Endpoints

ໄຟລ์ທັງໝົດໃນ `server/` ແມ່ນສ້າງແລ້ວ - ພຽງຣನ:

```bash
npm run dev
```

### Step 4: Build Flutter Store Dashboard

Add routes ໃນ `main.dart`:

```dart
GetPage(
  name: '/store/orders',
  page: () => StoreOrdersView(),
  binding: BindingsBuilder(() {
    Get.lazyPut(() => StoreOrdersController());
  }),
),
```

Add navigation ໃນ store user's home:

```dart
ElevatedButton(
  onPressed: () => Get.toNamed('/store/orders'),
  child: Text('ຄຳສັ່ງຊື້'),
),
```

---

## 🧪 ວິທີ Test

### ທົ່ວ 1: ດຳເນີນ Test Script

```bash
cd /c/SDL/foodpanda/foodpanda_postgresSQL
bash test-flow.sh
```

### ທົ່ວ 2: Manual Test (ສື່อ postman/curl)

#### A) Store Login
```bash
curl -X POST http://localhost:3000/api/auth/store/login \
  -H "Content-Type: application/json" \
  -d '{
    "storeId": "demo-store",
    "password": "demo-store123"
  }'
```

**Response:**
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGci...",
    "store": {
      "id": "demo-store",
      "name": "ຮ້ານເຝີລາວ",
      "phone": "020 1234 5678",
      "address": "ຖະໜົນລ້ານຊ້າງ"
    }
  }
}
```

#### B) Customer Place Order
```bash
curl -X POST http://localhost:3000/api/mobile/orders \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer CUSTOMER_TOKEN" \
  -d '{
    "storeId": "demo-store",
    "deliveryAddress": "ຖະໜົນລ້ານຊ້າງ",
    "deliveryLat": 17.9757,
    "deliveryLng": 102.6331,
    "paymentMethod": "CASH",
    "items": [{"productId": "prod1", "quantity": 2}]
  }'
```

#### C) Store View Orders
```bash
curl -X GET http://localhost:3000/api/mobile/store/orders?type=pending \
  -H "Authorization: Bearer STORE_TOKEN"
```

#### D) Store Confirm Order
```bash
curl -X PATCH http://localhost:3000/api/mobile/store/orders/ORDER_ID/status \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer STORE_TOKEN" \
  -d '{"status": "CONFIRMED"}'
```

#### E) Store Mark Ready
```bash
curl -X PATCH http://localhost:3000/api/mobile/store/orders/ORDER_ID/status \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer STORE_TOKEN" \
  -d '{"status": "READY_FOR_PICKUP"}'
```

#### F) Rider See Available Deliveries
```bash
curl -X GET http://localhost:3000/api/mobile/rider/deliveries?type=available \
  -H "Authorization: Bearer RIDER_TOKEN"
```

---

## 📊 Order Status Flow

```
PENDING 
  ↓ (Store ຢືນຢັນ)
CONFIRMED
  ↓ (Store ເລີ່ມກະກຽມ)
PREPARING
  ↓ (Store ກະກຽມສຳເລັດ)
READY_FOR_PICKUP ← ⭐ Riders ເຫັນ ທີ່ນີ້!
  ↓ (Rider ຮັບ)
PICKED_UP
  ↓ (Rider ກຳລັງສົ່ງ)
DELIVERING
  ↓ (Rider ສົ່ງສຳເລັດ)
DELIVERED ✅
```

---

## 🔔 Notification Flow

ເມື່ອ order ກາຍເປັນ `READY_FOR_PICKUP`:
1. **API** ເອີ້ນ `notifyAllAvailableRiders(orderId)` (store/orders/[id]/status.patch.ts ເສັ້ນ 115-117)
2. **Notification Service** ສ້າງ notification ແລະ ສົ່ງ FCM push
3. **Riders App** ໄດ້ຮັບ push notification
4. **Riders App** ໂຫຼດ deliveries ໃໝ່ ເລື້ອຍ (polling ຫຼື websocket)
5. **Riders** ເຫັນ order ໃໝ່ ໃນ "Available" tab

---

## ⚙️ Configuration

### API Constants (Dart)
Update `api_constants.dart` ຖ້າ IP ທີ່ຕ່າງ:

```dart
static const String _deviceIp = '192.168.100.38'; // ← ປ່ຽນ IP ນີ້
static const bool _useRealDevice = true;
```

### JWT Secret (Backend)
Ensure `.env` ມີ:
```
JWT_SECRET=your_secret_key_here
```

---

## 🐛 Troubleshooting

### ❌ Riders still don't see orders

**Check:**
1. Order status is `READY_FOR_PICKUP` - verify in DB:
   ```sql
   SELECT id, orderNo, status FROM "Order" ORDER BY createdAt DESC LIMIT 1;
   ```

2. Notification sent - check logs:
   ```
   Error sending FCM notification: ...
   ```

3. Rider has FCM token registered:
   ```sql
   SELECT * FROM "DeviceToken" WHERE riderId = 'rider_id';
   ```

### ❌ Store login fails

**Check:**
1. Store exists in DB:
   ```sql
   SELECT * FROM "Store" WHERE id = 'demo-store';
   ```

2. Password correct - currently hardcoded as `storeId + '123'`

### ❌ Rider app doesn't reload

**Add auto-refresh:**
1. In `RiderDeliveryController.onInit()` - add periodic refresh
2. Or use WebSocket for real-time updates

---

## 📝 Next Steps

1. ✅ Create store login UI
2. ✅ Create store orders list UI  
3. ✅ Create order detail modal
4. ✅ Add real-time updates (WebSocket)
5. ✅ Add store password hashing (bcryptjs)
6. ✅ Add order assignment logic

---

## 📞 Support

For issues:
1. Check server logs: `npm run dev`
2. Check database: `npx prisma studio`
3. Check Flutter logs: `flutter logs`
4. Check FCM/Firebase console

---

**ສຸກ ໆ! 🎉**
