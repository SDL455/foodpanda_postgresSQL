import { z } from "zod";
import prisma from "../../../utils/prisma";
import { hashPassword } from "../../../utils/password";
import {
  successResponse,
  errorResponse,
  unauthorizedResponse,
  forbiddenResponse,
} from "../../../utils/response";

const createRiderSchema = z.object({
  email: z.string().email("ອີເມລບໍ່ຖືກຕ້ອງ"),
  phone: z.string().min(8, "ເບີໂທບໍ່ຖືກຕ້ອງ"),
  password: z.string().min(6, "ລະຫັດຜ່ານຕ້ອງມີຢ່າງໜ້ອຍ 6 ຕົວອັກສອນ"),
  fullName: z.string().min(1, "ກະລຸນາປ້ອນຊື່"),
  vehicleType: z.string().optional(),
  vehiclePlate: z.string().optional(),
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
  const result = createRiderSchema.safeParse(body);

  if (!result.success) {
    return errorResponse(result.error.issues[0].message);
  }

  const { email, phone, password, fullName, vehicleType, vehiclePlate } =
    result.data;

  // Check if email or phone exists
  const existingRider = await prisma.rider.findFirst({
    where: {
      OR: [{ email }, { phone }],
    },
  });

  if (existingRider) {
    return errorResponse("ອີເມລ ຫຼື ເບີໂທນີ້ຖືກໃຊ້ແລ້ວ");
  }

  const passwordHash = await hashPassword(password);

  const rider = await prisma.rider.create({
    data: {
      email,
      phone,
      passwordHash,
      fullName,
      vehicleType,
      vehiclePlate,
      isVerified: true, // Auto-verify riders created by admin
    },
    select: {
      id: true,
      email: true,
      phone: true,
      fullName: true,
      vehicleType: true,
      vehiclePlate: true,
      status: true,
      isActive: true,
      isVerified: true,
      createdAt: true,
    },
  });

  // Log action
  await prisma.auditLog.create({
    data: {
      actorId: user.userId,
      action: "CREATE_RIDER",
      entity: "Rider",
      entityId: rider.id,
      meta: { email, phone, fullName },
    },
  });

  return successResponse(rider, "ສ້າງ Rider ສຳເລັດ");
});
