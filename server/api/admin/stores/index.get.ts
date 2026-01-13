import prisma from "../../../utils/prisma";
import {
  successResponse,
  unauthorizedResponse,
  forbiddenResponse,
} from "../../../utils/response";

export default defineEventHandler(async (event) => {
  const user = event.context.user;

  if (!user) {
    return unauthorizedResponse();
  }

  if (user.role !== "SUPER_ADMIN") {
    return forbiddenResponse("ບໍ່ມີສິດເຂົ້າເຖິງ");
  }

  const query = getQuery(event);
  const page = Number(query.page) || 1;
  const limit = Number(query.limit) || 10;
  const search = query.search as string | undefined;

  const where: any = {};

  if (search) {
    where.OR = [
      { name: { contains: search, mode: "insensitive" } },
      { address: { contains: search, mode: "insensitive" } },
    ];
  }

  const [stores, total] = await Promise.all([
    prisma.store.findMany({
      where,
      skip: (page - 1) * limit,
      take: limit,
      orderBy: { createdAt: "desc" },
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
            reviews: true,
          },
        },
      },
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
