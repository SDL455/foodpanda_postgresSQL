import { z } from "zod";
import prisma from "../../utils/prisma";
import {
  successResponse,
  errorResponse,
  unauthorizedResponse,
  forbiddenResponse,
} from "../../utils/response";

const createStoreSchema = z.object({
  name: z.string().min(1, "ກະລຸນາປ້ອນຊື່ຮ້ານ"),
  description: z.string().optional(),
  phone: z.string().optional(),
  address: z.string().optional(),
  lat: z.number().optional(),
  lng: z.number().optional(),
  openTime: z.string().optional(),
  closeTime: z.string().optional(),
  minOrderAmount: z.number().optional(),
  deliveryFee: z.number().optional(),
  estimatedPrepTime: z.number().optional(),
});

export default defineEventHandler(async (event) => {
  const user = event.context.user;

  if (!user) {
    return unauthorizedResponse();
  }

  if (!["SUPER_ADMIN", "MERCHANT_OWNER"].includes(user.role)) {
    return forbiddenResponse("ບໍ່ມີສິດສ້າງຮ້ານ");
  }

  if (!user.merchantId && user.role !== "SUPER_ADMIN") {
    return errorResponse("ບໍ່ພົບ Merchant");
  }

  const body = await readBody(event);
  const result = createStoreSchema.safeParse(body);

  if (!result.success) {
    return errorResponse(result.error.issues[0]?.message ?? 'ຂໍ້ມູນບໍ່ຖືກຕ້ອງ');
  }

  // For admin, merchantId must be provided
  let merchantId = user.merchantId;
  if (user.role === "SUPER_ADMIN") {
    if (!body.merchantId) {
      return errorResponse("ກະລຸນາເລືອກ Merchant");
    }
    merchantId = body.merchantId;
  }

  const store = await prisma.store.create({
    data: {
      ...result.data,
      merchantId: merchantId!,
    },
  });

  // Log action
  await prisma.auditLog.create({
    data: {
      actorId: user.userId,
      action: "CREATE_STORE",
      entity: "Store",
      entityId: store.id,
      meta: { storeName: store.name },
    },
  });

  return successResponse(store, "ສ້າງຮ້ານສຳເລັດ");
});
