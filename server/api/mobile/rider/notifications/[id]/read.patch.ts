import prisma from "../../../../../utils/prisma";
import {
  successResponse,
  unauthorizedResponse,
  errorResponse,
} from "../../../../../utils/response";
import { verifyToken, getTokenFromHeader } from "../../../../../utils/jwt";

/**
 * PATCH /api/mobile/rider/notifications/:id/read
 * ໝາຍວ່າອ່ານ notification ແລ້ວ
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
  const notificationId = getRouterParam(event, "id");

  if (!notificationId) {
    return errorResponse("ກະລຸນາລະບຸ Notification ID", 400);
  }

  try {
    // Check if notification belongs to this rider
    const notification = await prisma.notification.findFirst({
      where: {
        id: notificationId,
        riderId,
      },
    });

    if (!notification) {
      return errorResponse("ບໍ່ພົບ Notification", 404);
    }

    // Mark as read
    await prisma.notification.update({
      where: { id: notificationId },
      data: {
        isRead: true,
        readAt: new Date(),
      },
    });

    return successResponse({
      message: "ໝາຍວ່າອ່ານແລ້ວສຳເລັດ",
    });
  } catch (error: any) {
    console.error("Error marking notification as read:", error);
    return errorResponse(error.message || "ເກີດຂໍ້ຜິດພາດ", 500);
  }
});
