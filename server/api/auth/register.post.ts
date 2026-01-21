import { z } from "zod";
import prisma from "../../utils/prisma";
import { hashPassword } from "../../utils/password";
import { signToken } from "../../utils/jwt";
import { successResponse, errorResponse } from "../../utils/response";
import { randomBytes } from "crypto";

const registerSchema = z.object({
  email: z.string({ message: "ກະລຸນາປ້ອນອີເມລ" }).email("ອີເມລບໍ່ຖືກຕ້ອງ"),
  password: z
    .string({ message: "ກະລຸນາປ້ອນລະຫັດຜ່ານ" })
    .min(6, "ລະຫັດຜ່ານຕ້ອງມີຢ່າງໜ້ອຍ 6 ຕົວອັກສອນ"),
  name: z.string({ message: "ກະລຸນາປ້ອນຊື່" }).min(1, "ກະລຸນາປ້ອນຊື່"),
  phone: z.string().optional().nullable(),
});

export default defineEventHandler(async (event) => {
  const body = await readBody(event);

  // Validate input
  const result = registerSchema.safeParse(body);
  if (!result.success) {
    return errorResponse(result.error.issues[0].message);
  }

  const { email, password, name, phone } = result.data;

  // Check if email already exists
  const existingCustomer = await prisma.customer.findFirst({
    where: { email },
  });

  if (existingCustomer) {
    return errorResponse("ອີເມລນີ້ຖືກໃຊ້ແລ້ວ", 400);
  }

  // Generate a unique firebaseUid for email/password users
  // In production, this should be handled by Firebase Auth
  const firebaseUid = `email_${randomBytes(16).toString("hex")}`;

  // Hash password
  const passwordHash = await hashPassword(password);

  // Create customer
  const customer = await prisma.customer.create({
    data: {
      firebaseUid,
      authProvider: "EMAIL",
      email,
      phone,
      fullName: name,
      passwordHash,
      lastLoginAt: new Date(),
    },
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
    "ລົງທະບຽນສຳເລັດ"
  );
});
