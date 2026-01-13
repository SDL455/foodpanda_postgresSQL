import prisma from "../../utils/prisma";
import { successResponse, unauthorizedResponse } from "../../utils/response";

export default defineEventHandler(async (event) => {
  const user = event.context.user;

  if (!user) {
    return unauthorizedResponse();
  }

  const query = getQuery(event);
  const page = parseInt(query.page as string) || 1;
  const limit = parseInt(query.limit as string) || 10;
  const groupByMerchant = query.groupByMerchant === "true";

  let where: any = {};

  // If merchant user, only show their stores
  if (user.role !== "SUPER_ADMIN" && user.merchantId) {
    where.merchantId = user.merchantId;
  }

  // For admin - group stores by merchant
  if (user.role === "SUPER_ADMIN" && groupByMerchant) {
    const merchants = await prisma.merchant.findMany({
      orderBy: { createdAt: "desc" },
      include: {
        stores: {
          include: {
            _count: {
              select: {
                products: true,
                orders: true,
                categories: true,
              },
            },
          },
          orderBy: { createdAt: "desc" },
        },
        _count: {
          select: {
            stores: true,
          },
        },
      },
    });

    return successResponse({
      merchants,
      groupedByMerchant: true,
    });
  }

  const [stores, total] = await Promise.all([
    prisma.store.findMany({
      where,
      include: {
        merchant: {
          select: {
            id: true,
            name: true,
          },
        },
        _count: {
          select: {
            products: true,
            orders: true,
            categories: true,
          },
        },
      },
      orderBy: { createdAt: "desc" },
      skip: (page - 1) * limit,
      take: limit,
    }),
    prisma.store.count({ where }),
  ]);

  return successResponse({
    stores,
    pagination: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
    },
  });
});
