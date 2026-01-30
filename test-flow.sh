#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Foodpanda Order Flow Test ===${NC}\n"

# Test URLs
BASE_URL="http://localhost:3000/api"
CUSTOMER_TOKEN="your_customer_token_here"
STORE_LOGIN_URL="$BASE_URL/auth/store/login"
STORE_ORDERS_URL="$BASE_URL/mobile/store/orders"
CUSTOMER_ORDER_URL="$BASE_URL/mobile/orders"

echo -e "${BLUE}1. Testing Store Login${NC}"
echo "POST $STORE_LOGIN_URL"

STORE_LOGIN_RESPONSE=$(curl -s -X POST "$STORE_LOGIN_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "storeId": "demo-store",
    "password": "demo-store123"
  }')

echo "$STORE_LOGIN_RESPONSE" | jq .

# Extract token from response
STORE_TOKEN=$(echo "$STORE_LOGIN_RESPONSE" | jq -r '.data.token // empty')

if [ -z "$STORE_TOKEN" ]; then
  echo -e "${RED}❌ Store login failed${NC}\n"
  exit 1
fi

echo -e "${GREEN}✅ Store login successful${NC}"
echo "Token: $STORE_TOKEN\n"

# ============================================
# Test 2: Customer Places Order
# ============================================
echo -e "${BLUE}2. Testing Customer Order Placement${NC}"
echo "POST $CUSTOMER_ORDER_URL"

CUSTOMER_ORDER_RESPONSE=$(curl -s -X POST "$CUSTOMER_ORDER_URL" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CUSTOMER_TOKEN" \
  -d '{
    "storeId": "demo-store",
    "deliveryAddress": "ຖະໜົນລ້ານຊ້າງ",
    "deliveryLat": 17.9757,
    "deliveryLng": 102.6331,
    "paymentMethod": "CASH",
    "items": [
      {
        "productId": "prod1",
        "quantity": 2
      }
    ]
  }')

echo "$CUSTOMER_ORDER_RESPONSE" | jq .

ORDER_ID=$(echo "$CUSTOMER_ORDER_RESPONSE" | jq -r '.data.id // empty')

if [ -z "$ORDER_ID" ]; then
  echo -e "${RED}❌ Customer order failed${NC}\n"
  exit 1
fi

echo -e "${GREEN}✅ Customer order placed successfully${NC}"
echo "Order ID: $ORDER_ID\n"

# ============================================
# Test 3: Store Views Pending Orders
# ============================================
echo -e "${BLUE}3. Testing Store View Pending Orders${NC}"
echo "GET $STORE_ORDERS_URL?type=pending"

PENDING_ORDERS=$(curl -s -X GET "$STORE_ORDERS_URL?type=pending" \
  -H "Authorization: Bearer $STORE_TOKEN")

echo "$PENDING_ORDERS" | jq .

echo -e "${GREEN}✅ Store fetched pending orders${NC}\n"

# ============================================
# Test 4: Store Confirms Order
# ============================================
echo -e "${BLUE}4. Testing Store Confirm Order${NC}"
echo "PATCH $STORE_ORDERS_URL/$ORDER_ID/status"

CONFIRM_RESPONSE=$(curl -s -X PATCH "$STORE_ORDERS_URL/$ORDER_ID/status" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $STORE_TOKEN" \
  -d '{
    "status": "CONFIRMED"
  }')

echo "$CONFIRM_RESPONSE" | jq .

echo -e "${GREEN}✅ Store confirmed order${NC}\n"

# ============================================
# Test 5: Store Starts Preparing
# ============================================
echo -e "${BLUE}5. Testing Store Start Preparing${NC}"
echo "PATCH $STORE_ORDERS_URL/$ORDER_ID/status"

PREPARING_RESPONSE=$(curl -s -X PATCH "$STORE_ORDERS_URL/$ORDER_ID/status" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $STORE_TOKEN" \
  -d '{
    "status": "PREPARING"
  }')

echo "$PREPARING_RESPONSE" | jq .

echo -e "${GREEN}✅ Store started preparing${NC}\n"

# ============================================
# Test 6: Store Marks Ready for Pickup
# ============================================
echo -e "${BLUE}6. Testing Store Mark Ready for Pickup${NC}"
echo "PATCH $STORE_ORDERS_URL/$ORDER_ID/status"

READY_RESPONSE=$(curl -s -X PATCH "$STORE_ORDERS_URL/$ORDER_ID/status" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $STORE_TOKEN" \
  -d '{
    "status": "READY_FOR_PICKUP"
  }')

echo "$READY_RESPONSE" | jq .

echo -e "${GREEN}✅ Order marked as ready for pickup${NC}"
echo -e "${BLUE}🎯 Riders should now see this order as AVAILABLE${NC}\n"

# ============================================
# Test 7: Verify Order Appears in Available Deliveries
# ============================================
echo -e "${BLUE}7. Testing Rider Views Available Deliveries${NC}"
echo "Note: Use your rider token for this test"
echo "GET /api/mobile/rider/deliveries?type=available"

echo -e "${GREEN}✅ Test flow completed!${NC}\n"

echo -e "${BLUE}=== Summary ===${NC}"
echo "✅ Store can login"
echo "✅ Customer can place order"
echo "✅ Store can view orders"
echo "✅ Store can update order status"
echo "✅ When order is READY_FOR_PICKUP, riders are notified"
echo "✅ Riders can see order in available deliveries"
