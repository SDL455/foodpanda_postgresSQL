import { z } from "zod";
import prisma from "../../utils/prisma";
import { verifyPassword } from "../../utils/password";
import { signToken } from "../../utils/jwt";
import { successResponse, errorResponse } from "../../utils/response";

const loginSchema = z.object({
  email: z.string().email("ອີເມລບໍ່ຖືກຕ້ອງ"),
  password: z.string().min(6, "ລະຫັດຜ່ານຕ້ອງມີຢ່າງໜ້ອຍ 6 ຕົວອັກສອນ"),
});

export default defineEventHandler(async (event) => {
  const body = await readBody(event);

  // Validate input
  const result = loginSchema.safeParse(body);
  if (!result.success) {
    return errorResponse(result.error.issues[0].message);
  }

  const { email, password } = result.data;

  // Try to find user (admin/merchant) first
  let user = await prisma.user.findUnique({
    where: { email },
    include: {
      merchant: true,
    },
  });

  if (user) {
    // Admin/Merchant login
    if (!user.isActive) {
      return errorResponse("ບັນຊີຂອງທ່ານຖືກປິດໃຊ້ງານ", 403);
    }

    // Verify password
    const isValid = await verifyPassword(password, user.passwordHash);
    if (!isValid) {
      return errorResponse("ອີເມລ ຫຼື ລະຫັດຜ່ານບໍ່ຖືກຕ້ອງ", 401);
    }

    // Generate token
    const token = signToken({
      userId: user.id,
      email: user.email,
      role: user.role,
      merchantId: user.merchantId || undefined,
    });

    return successResponse(
      {
        token,
        user: {
          id: user.id,
          email: user.email,
          fullName: user.fullName,
          avatar: user.avatar,
          role: user.role,
          merchant: user.merchant,
        },
      },
      "ເຂົ້າສູ່ລະບົບສຳເລັດ"
    );
  }

  // Try to find customer
  const customer = await prisma.customer.findFirst({
    where: {
      email,
    },
  });

  if (!customer) {
    return errorResponse("ອີເມລ ຫຼື ລະຫັດຜ່ານບໍ່ຖືກຕ້ອງ", 401);
  }

  if (!customer.isActive) {
    return errorResponse("ບັນຊີຂອງທ່ານຖືກປິດໃຊ້ງານ", 403);
  }

  // Verify password
  if (!customer.passwordHash) {
    return errorResponse("ອີເມລ ຫຼື ລະຫັດຜ່ານບໍ່ຖືກຕ້ອງ", 401);
  }

  const isValid = await verifyPassword(password, customer.passwordHash);
  if (!isValid) {
    return errorResponse("ອີເມລ ຫຼື ລະຫັດຜ່ານບໍ່ຖືກຕ້ອງ", 401);
  }

  // Update last login
  await prisma.customer.update({
    where: { id: customer.id },
    data: { lastLoginAt: new Date() },
  });

  // Generate token
  const token = signToken({
    userId: customer.id,
    email: customer.email || "",
    role: "CUSTOMER" as any,
  });

  return successResponse(
    {
      token,
      user: {
        id: customer.id,
        email: customer.email,
        phone: customer.phone,
        fullName: customer.fullName,
        avatar: customer.avatar,
        authProvider: customer.authProvider,
      },
    },
    "ເຂົ້າສູ່ລະບົບສຳເລັດ"
  );
});
