import { z } from "zod";
import prisma from "../../../utils/prisma";
import { verifyPassword } from "../../../utils/password";
import { signToken } from "../../../utils/jwt";
import { successResponse, errorResponse } from "../../../utils/response";

const riderLoginSchema = z.object({
  email: z.string().email("ອີເມລບໍ່ຖືກຕ້ອງ"),
  password: z.string().min(6, "ລະຫັດຜ່ານຕ້ອງມີຢ່າງໜ້ອຍ 6 ຕົວອັກສອນ"),
});

export default defineEventHandler(async (event) => {
  const body = await readBody(event);

  // Validate input
  const result = riderLoginSchema.safeParse(body);
  if (!result.success) {
    return errorResponse(result.error.issues[0].message);
  }

  const { email, password } = result.data;

  // Find rider
  const rider = await prisma.rider.findUnique({
    where: { email },
  });

  if (!rider) {
    return errorResponse("ອີເມລ ຫຼື ລະຫັດຜ່ານບໍ່ຖືກຕ້ອງ", 401);
  }

  if (!rider.isActive) {
    return errorResponse("ບັນຊີຂອງທ່ານຖືກປິດໃຊ້ງານ", 403);
  }

  if (!rider.isVerified) {
    return errorResponse("ບັນຊີຂອງທ່ານຍັງບໍ່ໄດ້ຮັບການຢືນຢັນ", 403);
  }

  // Verify password
  const isValid = await verifyPassword(password, rider.passwordHash);
  if (!isValid) {
    return errorResponse("ອີເມລ ຫຼື ລະຫັດຜ່ານບໍ່ຖືກຕ້ອງ", 401);
  }

  // Update last seen
  await prisma.rider.update({
    where: { id: rider.id },
    data: { lastSeenAt: new Date() },
  });

  // Generate token
  const token = signToken({
    riderId: rider.id,
    email: rider.email,
    type: "rider",
  });

  return successResponse(
    {
      token,
      rider: {
        id: rider.id,
        email: rider.email,
        phone: rider.phone,
        fullName: rider.fullName,
        avatar: rider.avatar,
        vehicleType: rider.vehicleType,
        vehiclePlate: rider.vehiclePlate,
        status: rider.status,
        isActive: rider.isActive,
        isVerified: rider.isVerified,
        currentLat: rider.currentLat,
        currentLng: rider.currentLng,
        lastSeenAt: rider.lastSeenAt,
      },
    },
    "ເຂົ້າສູ່ລະບົບສຳເລັດ"
  );
});
