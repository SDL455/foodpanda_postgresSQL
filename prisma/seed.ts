import { PrismaClient } from "@prisma/client";
import { PrismaPg } from "@prisma/adapter-pg";
import { Pool } from "pg";
import bcrypt from "bcryptjs";
import "dotenv/config";

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

const adapter = new PrismaPg(pool);

const prisma = new PrismaClient({ adapter });

async function main() {
  console.log("🌱 Seeding database...");

  // Create Super Admin
  const adminPassword = await bcrypt.hash("admin123", 12);
  const admin = await prisma.user.upsert({
    where: { email: "admin@foodpanda.com" },
    update: {},
    create: {
      email: "admin@foodpanda.com",
      passwordHash: adminPassword,
      fullName: "Super Admin",
      role: "SUPER_ADMIN",
    },
  });
  console.log(" Created admin:", admin.email);

  // Create Merchant
  const merchantPassword = await bcrypt.hash("merchant123", 12);
  const merchant = await prisma.merchant.upsert({
    where: { id: "demo-merchant" },
    update: {},
    create: {
      id: "demo-merchant",
      name: "ຮ້ານອາຫານລາວ",
      users: {
        create: {
          email: "merchant@foodpanda.com",
          passwordHash: merchantPassword,
          fullName: "ເຈົ້າຂອງຮ້ານ",
          role: "MERCHANT_OWNER",
        },
      },
    },
  });
  console.log(" Created merchant:", merchant.name);

  // Create Store
  const store = await prisma.store.upsert({
    where: { id: "demo-store" },
    update: {},
    create: {
      id: "demo-store",
      merchantId: merchant.id,
      name: "ຮ້ານເຝີລາວ",
      description: "ເຝີລາວແທ້ໆ ລົດຊາດອ່ອຍ",
      phone: "020 1234 5678",
      address: "ຖະໜົນລ້ານຊ້າງ, ນະຄອນຫຼວງວຽງຈັນ",
      lat: 17.9757,
      lng: 102.6331,
      openTime: "07:00",
      closeTime: "21:00",
      deliveryFee: 15000,
      minOrderAmount: 30000,
    },
  });
  console.log(" Created store:", store.name);

  // Create Categories
  const categories = await Promise.all([
    prisma.category.upsert({
      where: { storeId_name: { storeId: store.id, name: "ເຝີ" } },
      update: {},
      create: { storeId: store.id, name: "ເຝີ", sortOrder: 1 },
    }),
    prisma.category.upsert({
      where: { storeId_name: { storeId: store.id, name: "ເຄື່ອງດື່ມ" } },
      update: {},
      create: { storeId: store.id, name: "ເຄື່ອງດື່ມ", sortOrder: 2 },
    }),
  ]);
  console.log(" Created categories:", categories.length);

  // Create Products
  const products = await Promise.all([
    prisma.product.create({
      data: {
        storeId: store.id,
        categoryId: categories[0].id,
        name: "ເຝີຊີ້ນງົວ",
        description: "ເຝີຊີ້ນງົວສົດໆ ນ້ຳແກງກະດູກ",
        basePrice: 35000,
        variants: {
          create: [
            { name: "ທຳມະດາ", priceDelta: 0 },
            { name: "ພິເສດ", priceDelta: 10000 },
          ],
        },
        stock: {
          create: { quantity: 100 },
        },
      },
    }),
    prisma.product.create({
      data: {
        storeId: store.id,
        categoryId: categories[0].id,
        name: "ເຝີໄກ່",
        description: "ເຝີໄກ່ນຸ້ມ",
        basePrice: 30000,
        stock: {
          create: { quantity: 100 },
        },
      },
    }),
    prisma.product.create({
      data: {
        storeId: store.id,
        categoryId: categories[1].id,
        name: "ນ້ຳໝາກນາວ",
        description: "ນ້ຳໝາກນາວສົດ",
        basePrice: 10000,
        stock: {
          create: { quantity: 50 },
        },
      },
    }),
  ]);
  console.log(" Created products:", products.length);

  // Create Rider
  const riderPassword = await bcrypt.hash("rider123", 12);
  const rider = await prisma.rider.upsert({
    where: { email: "rider@foodpanda.com" },
    update: {},
    create: {
      email: "rider@foodpanda.com",
      phone: "020 9876 5432",
      passwordHash: riderPassword,
      fullName: "ນາຍສົມຈິດ",
      vehicleType: "ລົດຈັກ",
      vehiclePlate: "1234",
      isVerified: true,
    },
  });
  console.log(" Created rider:", rider.fullName);

  // Create Demo Customer
  const customer = await prisma.customer.upsert({
    where: { firebaseUid: "demo-customer" },
    update: {},
    create: {
      firebaseUid: "demo-customer",
      email: "customer@example.com",
      phone: "020 1111 2222",
      fullName: "ນາງສອນ",
      authProvider: "EMAIL",
      addresses: {
        create: {
          label: "ບ້ານ",
          address: "ບ້ານໂພນສະອາດ, ເມືອງໄຊເສດຖາ",
          lat: 17.98,
          lng: 102.64,
          isDefault: true,
        },
      },
    },
  });
  console.log(" Created customer:", customer.fullName);

  // Create AppConfig
  await prisma.appConfig.upsert({
    where: { key: "min_app_version_android" },
    update: {},
    create: {
      key: "min_app_version_android",
      value: "1.0.0",
      description: "Minimum Android app version",
    },
  });
  await prisma.appConfig.upsert({
    where: { key: "min_app_version_ios" },
    update: {},
    create: {
      key: "min_app_version_ios",
      value: "1.0.0",
      description: "Minimum iOS app version",
    },
  });
  console.log(" Created app configs");

  console.log(" Seeding completed!");
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
