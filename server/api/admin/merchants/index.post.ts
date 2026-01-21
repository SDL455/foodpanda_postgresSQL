import { z } from "zod";
import prisma from "../../../utils/prisma";
import { hashPassword } from "../../../utils/password";
import {
  successResponse,
  errorResponse,
  unauthorizedResponse,
  forbiddenResponse,
} from "../../../utils/response";

const createMerchantSchema = z.object({
  name: z.string().min(1, "ກະລຸນາປ້ອນຊື່"),
  ownerEmail: z.string().email("ອີເມລບໍ່ຖືກຕ້ອງ"),
  ownerPassword: z.string().min(6, "ລະຫັດຜ່ານຕ້ອງມີຢ່າງໜ້ອຍ 6 ຕົວອັກສອນ"),
  ownerFullName: z.string().optional(),
  ownerPhone: z.string().optional(),
});

export default defineEventHandler(async (event) => {
  const user = event.context.user;

  if (!user) {
    return unauthorizedResponse();
  }

  if (user.role !== "SUPER_ADMIN") {
    return forbiddenResponse("ບໍ່ມີສິດເຂົ້າເຖິງ");
  }

  const body = await readBody(event);
  const result = createMerchantSchema.safeParse(body);

  if (!result.success) {
    return errorResponse(result.error.errors[0].message);
  }

  const { name, ownerEmail, ownerPassword, ownerFullName, ownerPhone } =
    result.data;

  // Check if email exists
  const existingUser = await prisma.user.findUnique({
    where: { email: ownerEmail },
  });

  if (existingUser) {
    return errorResponse("ອີເມລນີ້ຖືກໃຊ້ແລ້ວ");
  }

  // Create merchant with owner
  const passwordHash = await hashPassword(ownerPassword);

  const merchant = await prisma.merchant.create({
    data: {
      name,
      users: {
        create: {
          email: ownerEmail,
          passwordHash,
          fullName: ownerFullName,
          phone: ownerPhone,
          role: "MERCHANT_OWNER",
        },
      },
    },
    include: {
      users: {
        select: { id: true, email: true, fullName: true, role: true },
      },
    },
  });

  // Log action
  await prisma.auditLog.create({
    data: {
      actorId: user.userId,
      action: "CREATE_MERCHANT",
      entity: "Merchant",
      entityId: merchant.id,
      meta: { merchantName: name, ownerEmail },
    },
  });

  return successResponse(merchant, "ສ້າງ Merchant ສຳເລັດ");
});
