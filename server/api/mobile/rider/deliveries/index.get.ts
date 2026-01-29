import prisma from "../../../../utils/prisma";
import {
  successResponse,
  unauthorizedResponse,
  errorResponse,
} from "../../../../utils/response";
import { verifyToken, getTokenFromHeader } from "../../../../utils/jwt";

/**
 * GET /api/mobile/rider/deliveries
 * ດຶງລາຍການ delivery ສຳລັບ rider
 * - available: orders ທີ່ READY_FOR_PICKUP ແລະ ຍັງບໍ່ມີ rider
 * - active: orders ທີ່ rider ກຳລັງສົ່ງ
 * - completed: orders ທີ່ rider ສົ່ງສຳເລັດແລ້ວ
 */
export default defineEventHandler(async (event) => {
  // Verify rider token
  const token = getTokenFromHeader(event);
  if (!token) {
    return unauthorizedResponse("ກະລຸນາເຂົ້າສູ່ລະບົບ");
  }

  const payload = verifyToken(token);
  if (!payload || !("riderId" in payload)) {
    return unauthorizedResponse("Token ບໍ່ຖືກຕ້ອງ ຫຼື ບໍ່ແມ່ນ Rider");
  }

  const riderId = payload.riderId as string;

  // Get query params
  const query = getQuery(event);
  const type = (query.type as string) || "available"; // available, active, completed
  const page = parseInt(query.page as string) || 1;
  const limit = parseInt(query.limit as string) || 20;
  const skip = (page - 1) * limit;

  try {
    let whereClause: any = {};
    let deliveryWhereClause: any = {};

    switch (type) {
      case "available":
        // Orders ທີ່ພ້ອມໃຫ້ຮັບ (READY_FOR_PICKUP ແລະ ຍັງບໍ່ມີ rider)
        // In PostgreSQL: check for orders where delivery doesn't exist OR delivery.riderId is null
        whereClause = {
          status: "READY_FOR_PICKUP",
          OR: [{ delivery: null }, { delivery: { riderId: null } }],
        };
        break;

      case "active":
        // Orders ທີ່ rider ກຳລັງສົ່ງ
        whereClause = {
          status: { in: ["PICKED_UP", "DELIVERING"] },
          delivery: {
            riderId: riderId,
          },
        };
        break;

      case "completed":
        // Orders ທີ່ rider ສົ່ງສຳເລັດແລ້ວ
        whereClause = {
          status: "DELIVERED",
          delivery: {
            riderId: riderId,
          },
        };
        break;

      default:
        return errorResponse("ປະເພດບໍ່ຖືກຕ້ອງ", 400);
    }

    const [orders, total] = await Promise.all([
      prisma.order.findMany({
        where: whereClause,
        include: {
          store: {
            select: {
              id: true,
              name: true,
              address: true,
              lat: true,
              lng: true,
              phone: true,
              logo: true,
            },
          },
          customer: {
            select: {
              id: true,
              fullName: true,
              phone: true,
              avatar: true,
            },
          },
          items: {
            include: {
              product: {
                select: {
                  name: true,
                  image: true,
                },
              },
            },
          },
          delivery: true,
        },
        orderBy: { createdAt: type === "completed" ? "desc" : "asc" },
        skip,
        take: limit,
      }),
      prisma.order.count({ where: whereClause }),
    ]);

    // Transform to delivery format
    const deliveries = orders.map((order) => ({
      id: order.delivery?.id || order.id,
      orderId: order.id,
      orderNo: order.orderNo,
      status: order.status,

      // Customer info
      customerName: order.customer.fullName || "ລູກຄ້າ",
      customerPhone: order.customer.phone || "",
      customerAvatar: order.customer.avatar,
      customerAddress: order.deliveryAddress,
      customerLat: order.deliveryLat,
      customerLng: order.deliveryLng,
      deliveryNote: order.deliveryNote,

      // Store info
      storeName: order.store.name,
      storePhone: order.store.phone,
      storeLogo: order.store.logo,
      storeAddress: order.store.address,
      storeLat: order.store.lat,
      storeLng: order.store.lng,

      // Order details
      items: order.items.map((item) => ({
        name: item.productName,
        quantity: item.quantity,
        image: item.productImage,
      })),
      itemCount: order.items.reduce((sum, item) => sum + item.quantity, 0),

      // Prices
      subtotal: order.subtotal,
      deliveryFee: order.deliveryFee,
      total: order.total,

      // Payment
      paymentMethod: order.paymentMethod,
      paymentStatus: order.paymentStatus,

      // Delivery info
      distance: order.delivery?.distance,
      estimatedTime: order.delivery?.estimatedTime,

      // Timestamps
      createdAt: order.createdAt,
      confirmedAt: order.confirmedAt,
      pickedUpAt: order.pickedUpAt,
      deliveredAt: order.deliveredAt,
    }));

    return successResponse({
      data: deliveries,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
        type,
      },
    });
  } catch (error: any) {
    console.error("Error fetching rider deliveries:", error);
    return errorResponse(error.message || "ເກີດຂໍ້ຜິດພາດ", 500);
  }
});
