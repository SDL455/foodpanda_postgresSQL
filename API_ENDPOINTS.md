# ລາຍການ API Endpoints ທັງໝົດ

## Base URL

- **Web App**: `/api`
- **Mobile App**: `http://localhost:3000/api`

---

# 🌐 Web App APIs

## 🔐 Authentication APIs

### 1. POST `/api/auth/login`

**ລາຍລະອຽດ**: ເຂົ້າສູ່ລະບົບ
**Method**: `POST`
**Authentication**: ❌ ບໍ່ຕ້ອງການ
**Request Body**:

```json
{
  "email": "string",
  "password": "string"
}
```

**Response**:

```json
{
  "success": true,
  "data": {
    "token": "string",
    "user": { ... }
  }
}
```

**ໃຊ້ໃນ**: `app/stores/auth.ts`

### 2. GET `/api/auth/me`

**ລາຍລະອຽດ**: ເອົາຂໍ້ມູນຜູ້ໃຊ້ທີ່ກຳລັງເຂົ້າສູ່ລະບົບ
**Method**: `GET`
**Authentication**: ✅ ຕ້ອງການ (Bearer Token)
**Response**:

```json
{
  "success": true,
  "data": {
    "id": "string",
    "email": "string",
    "fullName": "string",
    "role": "string",
    "merchant": { ... }
  }
}
```

**ໃຊ້ໃນ**: `app/stores/auth.ts`, `app/app.vue`

---

## 🏪 Store Management APIs

### 3. GET `/api/stores`

**ລາຍລະອຽດ**: ດຶງຂໍ້ມູນສາງທັງໝົດ
**Method**: `GET`
**Authentication**: ✅ ຕ້ອງການ
**Query Parameters**:

- `page` (optional)
- `limit` (optional)

**ໃຊ້ໃນ**: `app/pages/stores/index.vue`, `app/pages/products/index.vue`

### 4. POST `/api/stores`

**ລາຍລະອຽດ**: ສ້າງສາງໃໝ່
**Method**: `POST`
**Authentication**: ✅ ຕ້ອງການ
**Request Body**: Store object

**ໃຊ້ໃນ**: `app/pages/stores/index.vue`

### 5. GET `/api/stores/[id]`

**ລາຍລະອຽດ**: ດຶງຂໍ້ມູນສາງຕາມ ID
**Method**: `GET`
**Authentication**: ✅ ຕ້ອງການ

### 6. PATCH `/api/stores/[id]`

**ລາຍລະອຽດ**: ອັບເດດຂໍ້ມູນສາງ
**Method**: `PATCH`
**Authentication**: ✅ ຕ້ອງການ

### 7. GET `/api/stores/[id]/products`

**ລາຍລະອຽດ**: ດຶງຂໍ້ມູນສິນຄ້າຂອງສາງ
**Method**: `GET`
**Authentication**: ✅ ຕ້ອງການ
**Query Parameters**:

- `page` (optional)
- `limit` (optional)

**ໃຊ້ໃນ**: `app/pages/products/index.vue`

### 8. POST `/api/stores/[id]/products`

**ລາຍລະອຽດ**: ສ້າງສິນຄ້າໃໝ່ສຳລັບສາງ
**Method**: `POST`
**Authentication**: ✅ ຕ້ອງການ
**Request Body**: Product object

**ໃຊ້ໃນ**: `app/pages/products/index.vue`

### 9. GET `/api/stores/[id]/categories`

**ລາຍລະອຽດ**: ດຶງຂໍ້ມູນໝວດໝູ່ສິນຄ້າຂອງສາງ
**Method**: `GET`
**Authentication**: ✅ ຕ້ອງການ

**ໃຊ້ໃນ**: `app/pages/products/index.vue`

### 10. POST `/api/stores/[id]/categories`

**ລາຍລະອຽດ**: ສ້າງໝວດໝູ່ໃໝ່ສຳລັບສາງ
**Method**: `POST`
**Authentication**: ✅ ຕ້ອງການ

---

## 📦 Order Management APIs

### 11. GET `/api/orders`

**ລາຍລະອຽດ**: ດຶງຂໍ້ມູນຄຳສັ່ງຊື້ທັງໝົດ
**Method**: `GET`
**Authentication**: ✅ ຕ້ອງການ
**Query Parameters**:

- `page` (optional)
- `limit` (optional)
- `status` (optional)

**ໃຊ້ໃນ**: `app/pages/orders/index.vue`, `app/pages/dashboard.vue`

### 12. GET `/api/orders/[id]`

**ລາຍລະອຽດ**: ດຶງຂໍ້ມູນລາຍລະອຽດຄຳສັ່ງຊື້
**Method**: `GET`
**Authentication**: ✅ ຕ້ອງການ

**ໃຊ້ໃນ**: `app/pages/orders/index.vue`

### 13. PATCH `/api/orders/[id]/status`

**ລາຍລະອຽດ**: ອັບເດດສະຖານະຄຳສັ່ງຊື້
**Method**: `PATCH`
**Authentication**: ✅ ຕ້ອງການ
**Request Body**:

```json
{
  "status": "string",
  "cancelReason": "string" // optional, ໃຊ້ເມື່ອຍົກເລີກ
}
```

**ໃຊ້ໃນ**: `app/pages/orders/index.vue`

---

## 👥 Admin APIs - Merchants

### 14. GET `/api/admin/merchants`

**ລາຍລະອຽດ**: ດຶງຂໍ້ມູນຜູ້ຄ້າທັງໝົດ (Admin only)
**Method**: `GET`
**Authentication**: ✅ ຕ້ອງການ (SUPER_ADMIN)
**Query Parameters**:

- `page` (optional)
- `limit` (optional)
- `search` (optional)

**ໃຊ້ໃນ**: `app/pages/admin/merchants.vue`

### 15. POST `/api/admin/merchants`

**ລາຍລະອຽດ**: ສ້າງຜູ້ຄ້າໃໝ່ (Admin only)
**Method**: `POST`
**Authentication**: ✅ ຕ້ອງການ (SUPER_ADMIN)

**ໃຊ້ໃນ**: `app/pages/admin/merchants.vue`

### 16. PATCH `/api/admin/merchants/[id]`

**ລາຍລະອຽດ**: ອັບເດດຂໍ້ມູນຜູ້ຄ້າ (Admin only)
**Method**: `PATCH`
**Authentication**: ✅ ຕ້ອງການ (SUPER_ADMIN)

**ໃຊ້ໃນ**: `app/pages/admin/merchants.vue`

---

## 🏍️ Admin APIs - Riders

### 17. GET `/api/admin/riders`

**ລາຍລະອຽດ**: ດຶງຂໍ້ມູນຄົນສົ່ງທັງໝົດ (Admin only)
**Method**: `GET`
**Authentication**: ✅ ຕ້ອງການ (SUPER_ADMIN)
**Query Parameters**:

- `page` (optional)
- `limit` (optional)
- `search` (optional)

**ໃຊ້ໃນ**: `app/pages/admin/riders.vue`

### 18. POST `/api/admin/riders`

**ລາຍລະອຽດ**: ສ້າງຄົນສົ່ງໃໝ່ (Admin only)
**Method**: `POST`
**Authentication**: ✅ ຕ້ອງການ (SUPER_ADMIN)

**ໃຊ້ໃນ**: `app/pages/admin/riders.vue`

### 19. PATCH `/api/admin/riders/[id]`

**ລາຍລະອຽດ**: ອັບເດດຂໍ້ມູນຄົນສົ່ງ (Admin only)
**Method**: `PATCH`
**Authentication**: ✅ ຕ້ອງການ (SUPER_ADMIN)

**ໃຊ້ໃນ**: `app/pages/admin/riders.vue`

---

# 📱 Mobile App APIs

## 🔐 Authentication APIs

### 1. POST `/api/mobile/auth/social`

**ລາຍລະອຽດ**: ເຂົ້າສູ່ລະບົບແບບ Social Login (Google, Facebook)
**Method**: `POST`
**Authentication**: ❌ ບໍ່ຕ້ອງການ

**ໃຊ້ໃນ**: Flutter App - `ApiEndpoints.socialAuth`

---

## 🏪 Store APIs

### 2. GET `/api/mobile/stores`

**ລາຍລະອຽດ**: ດຶງຂໍ້ມູນສາງທັງໝົດ
**Method**: `GET`
**Authentication**: ✅ ຕ້ອງການ

**ໃຊ້ໃນ**: Flutter App - `ApiEndpoints.stores`

### 3. GET `/api/mobile/stores/[id]`

**ລາຍລະອຽດ**: ດຶງຂໍ້ມູນລາຍລະອຽດສາງ
**Method**: `GET`
**Authentication**: ✅ ຕ້ອງການ

**ໃຊ້ໃນ**: Flutter App - `ApiEndpoints.storeDetail(id)`

---

## 📦 Order APIs

### 4. POST `/api/mobile/orders`

**ລາຍລະອຽດ**: ສ້າງຄຳສັ່ງຊື້ໃໝ່
**Method**: `POST`
**Authentication**: ✅ ຕ້ອງການ

**ໃຊ້ໃນ**: Flutter App - `ApiEndpoints.orders`

### 5. GET `/api/mobile/orders/[id]`

**ລາຍລະອຽດ**: ດຶງຂໍ້ມູນລາຍລະອຽດຄຳສັ່ງຊື້
**Method**: `GET`
**Authentication**: ✅ ຕ້ອງການ

**ໃຊ້ໃນ**: Flutter App - `ApiEndpoints.orderDetail(id)`

---

## 🔔 Notification APIs

### 6. GET `/api/mobile/notifications`

**ລາຍລະອຽດ**: ດຶງຂໍ້ມູນແຈ້ງເຕືອນທັງໝົດ
**Method**: `GET`
**Authentication**: ✅ ຕ້ອງການ

**ໃຊ້ໃນ**: Flutter App - `ApiEndpoints.notifications`

### 7. GET `/api/mobile/notifications/unread-count`

**ລາຍລະອຽດ**: ດຶງຈຳນວນແຈ້ງເຕືອນທີ່ຍັງບໍ່ໄດ້ອ່ານ
**Method**: `GET`
**Authentication**: ✅ ຕ້ອງການ

**ໃຊ້ໃນ**: Flutter App - `ApiEndpoints.notificationsUnreadCount`

### 8. PATCH `/api/mobile/notifications/[id]/read`

**ລາຍລະອຽດ**: ອານຸຍາດແຈ້ງເຕືອນເປັນອ່ານແລ້ວ
**Method**: `PATCH`
**Authentication**: ✅ ຕ້ອງການ

**ໃຊ້ໃນ**: Flutter App - `ApiEndpoints.notificationRead(id)`

### 9. PATCH `/api/mobile/notifications/read-all`

**ລາຍລະອຽດ**: ອານຸຍາດແຈ້ງເຕືອນທັງໝົດເປັນອ່ານແລ້ວ
**Method**: `PATCH`
**Authentication**: ✅ ຕ້ອງການ

**ໃຊ້ໃນ**: Flutter App - `ApiEndpoints.notificationsReadAll`

---

## 📱 Device Token APIs

### 10. POST `/api/mobile/device-token`

**ລາຍລະອຽດ**: ບັນທຶກ Device Token ສຳລັບ Push Notifications
**Method**: `POST`
**Authentication**: ✅ ຕ້ອງການ

**ໃຊ້ໃນ**: Flutter App - `ApiEndpoints.deviceToken`

### 11. DELETE `/api/mobile/device-token`

**ລາຍລະອຽດ**: ລຶບ Device Token
**Method**: `DELETE`
**Authentication**: ✅ ຕ້ອງການ

**ໃຊ້ໃນ**: Flutter App - `ApiEndpoints.deviceToken`

---

## 📊 ສະຫຼຸບ

### ຈຳນວນ API ທັງໝົດ: **30 Endpoints**

---

## 🌐 Web App APIs: **19 Endpoints**

**ແບ່ງຕາມປະເພດ:**

- 🔐 Authentication: **2 endpoints**

  - POST `/api/auth/login`
  - GET `/api/auth/me`

- 🏪 Store Management: **8 endpoints**

  - GET `/api/stores`
  - POST `/api/stores`
  - GET `/api/stores/[id]`
  - PATCH `/api/stores/[id]`
  - GET `/api/stores/[id]/products`
  - POST `/api/stores/[id]/products`
  - GET `/api/stores/[id]/categories`
  - POST `/api/stores/[id]/categories`

- 📦 Order Management: **3 endpoints**

  - GET `/api/orders`
  - GET `/api/orders/[id]`
  - PATCH `/api/orders/[id]/status`

- 👥 Admin - Merchants: **3 endpoints**

  - GET `/api/admin/merchants`
  - POST `/api/admin/merchants`
  - PATCH `/api/admin/merchants/[id]`

- 🏍️ Admin - Riders: **3 endpoints**
  - GET `/api/admin/riders`
  - POST `/api/admin/riders`
  - PATCH `/api/admin/riders/[id]`

**ແບ່ງຕາມວິທີ:**

- GET: 10 endpoints
- POST: 6 endpoints
- PATCH: 3 endpoints

---

## 📱 Mobile App APIs: **11 Endpoints**

**ແບ່ງຕາມປະເພດ:**

- 🔐 Authentication: **1 endpoint**

  - POST `/api/mobile/auth/social`

- 🏪 Stores: **2 endpoints**

  - GET `/api/mobile/stores`
  - GET `/api/mobile/stores/[id]`

- 📦 Orders: **2 endpoints**

  - POST `/api/mobile/orders`
  - GET `/api/mobile/orders/[id]`

- 🔔 Notifications: **4 endpoints**

  - GET `/api/mobile/notifications`
  - GET `/api/mobile/notifications/unread-count`
  - PATCH `/api/mobile/notifications/[id]/read`
  - PATCH `/api/mobile/notifications/read-all`

- 📱 Device Token: **2 endpoints**
  - POST `/api/mobile/device-token`
  - DELETE `/api/mobile/device-token`

**ແບ່ງຕາມວິທີ:**

- GET: 5 endpoints
- POST: 3 endpoints
- PATCH: 2 endpoints
- DELETE: 1 endpoint

---

## 📈 ສະຖິຕິລວມ

**ຈຳນວນທັງໝົດ:**

- 🌐 Web App: **19 endpoints**
- 📱 Mobile App: **11 endpoints**
- **ລວມ: 30 endpoints**

**ແບ່ງຕາມວິທີທັງໝົດ:**

- GET: 15 endpoints
- POST: 9 endpoints
- PATCH: 5 endpoints
- DELETE: 1 endpoint

**ສິດການເຂົ້າເຖິງ:**

- Admin Only (SUPER_ADMIN): 6 endpoints
- Merchant (MERCHANT_OWNER/MERCHANT_STAFF): ສາມາດໃຊ້ໄດ້ສ່ວນໃຫຍ່
- Public: 2 endpoints (login, social auth)

---

## 🔑 Authentication

**Header Format:**

```
Authorization: Bearer <token>
```

**Token ໄດ້ມາຈາກ:**

- `/api/auth/login` (Web)
- `/api/mobile/auth/social` (Mobile)

---

## 📝 ໝາຍເຫດ

- ✅ ຕ້ອງການ Authentication = ຕ້ອງມີ Bearer Token ໃນ Header
- ❌ ບໍ່ຕ້ອງການ Authentication = ສາມາດເຂົ້າເຖິງໄດ້ບໍ່ຕ້ອງມີ Token
- Admin APIs ຕ້ອງການ Role: `SUPER_ADMIN`
- Merchant APIs ຕ້ອງການ Role: `MERCHANT_OWNER` ຫຼື `MERCHANT_STAFF`
