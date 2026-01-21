<template>
    <div>
        <div class="page-header">
            <h1>Dashboard</h1>
        </div>

        <!-- Admin Stats -->
        <template v-if="authStore.isAdmin">
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon primary">
                        <UserOutlined />
                    </div>
                    <div class="stat-value">{{ adminStats.customers?.total || 0 }}</div>
                    <div class="stat-label">ລູກຄ້າທັງໝົດ</div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon success">
                        <TeamOutlined />
                    </div>
                    <div class="stat-value">{{ adminStats.merchants?.total || 0 }}</div>
                    <div class="stat-label">ເຈົ້າຂອງຮ້ານ</div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon warning">
                        <ShopOutlined />
                    </div>
                    <div class="stat-value">{{ adminStats.stores?.total || 0 }}</div>
                    <div class="stat-label">ຮ້ານຄ້າ</div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon info">
                        <CarOutlined />
                    </div>
                    <div class="stat-value">{{ adminStats.riders?.total || 0 }}</div>
                    <div class="stat-label">ຄົນສົ່ງ</div>
                </div>
            </div>

            <!-- Second Row Stats -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon primary">
                        <ShoppingCartOutlined />
                    </div>
                    <div class="stat-value">{{ adminStats.orders?.today || 0 }}</div>
                    <div class="stat-label">ຄຳສັ່ງຊື້ມື້ນີ້</div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon success">
                        <DollarOutlined />
                    </div>
                    <div class="stat-value">{{ formatCurrency(adminStats.revenue?.today || 0) }}</div>
                    <div class="stat-label">ລາຍຮັບມື້ນີ້</div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon warning">
                        <ClockCircleOutlined />
                    </div>
                    <div class="stat-value">{{ adminStats.orders?.pending || 0 }}</div>
                    <div class="stat-label">ລໍຖ້າຢືນຢັນ</div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon info">
                        <UserAddOutlined />
                    </div>
                    <div class="stat-value">{{ adminStats.customers?.newToday || 0 }}</div>
                    <div class="stat-label">ລູກຄ້າໃໝ່ມື້ນີ້</div>
                </div>
            </div>

            <!-- Recent Customers for Admin -->
            <div class="card" style="margin-bottom: 24px;">
                <div class="card-header">
                    <h2>ລູກຄ້າໃໝ່ລ່າສຸດ</h2>
                    <a-button type="link" @click="$router.push('/admin/customers')">
                        ເບິ່ງທັງໝົດ
                    </a-button>
                </div>

                <a-table :columns="customerColumns" :data-source="adminStats.recentCustomers || []" :loading="loading"
                    :pagination="false" row-key="id">
                    <template #bodyCell="{ column, record }">
                        <template v-if="column.key === 'customer'">
                            <a-space>
                                <a-avatar :src="record.avatar" size="small">
                                    {{ record.fullName?.charAt(0) || record.email?.charAt(0) || 'C' }}
                                </a-avatar>
                                <div>
                                    <div>{{ record.fullName || 'ບໍ່ມີຊື່' }}</div>
                                    <div style="font-size: 12px; color: #666;">{{ record.email }}</div>
                                </div>
                            </a-space>
                        </template>

                        <template v-if="column.key === 'provider'">
                            <a-tag :color="getProviderColor(record.authProvider)">
                                {{ getProviderText(record.authProvider) }}
                            </a-tag>
                        </template>

                        <template v-if="column.key === 'orders'">
                            {{ record._count?.orders || 0 }}
                        </template>

                        <template v-if="column.key === 'createdAt'">
                            {{ formatDate(record.createdAt) }}
                        </template>
                    </template>
                </a-table>
            </div>
        </template>

        <!-- Merchant Stats -->
        <template v-else>
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon primary">
                        <ShoppingCartOutlined />
                    </div>
                    <div class="stat-value">{{ merchantStats.todayOrders }}</div>
                    <div class="stat-label">ຄຳສັ່ງຊື້ມື້ນີ້</div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon success">
                        <DollarOutlined />
                    </div>
                    <div class="stat-value">{{ formatCurrency(merchantStats.todayRevenue) }}</div>
                    <div class="stat-label">ລາຍຮັບມື້ນີ້</div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon warning">
                        <ClockCircleOutlined />
                    </div>
                    <div class="stat-value">{{ merchantStats.pendingOrders }}</div>
                    <div class="stat-label">ລໍຖ້າຢືນຢັນ</div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon info">
                        <AppstoreOutlined />
                    </div>
                    <div class="stat-value">{{ merchantStats.totalProducts }}</div>
                    <div class="stat-label">ສິນຄ້າທັງໝົດ</div>
                </div>
            </div>
        </template>

        <!-- Recent Orders (For both) -->
        <div class="card">
            <div class="card-header">
                <h2>ຄຳສັ່ງຊື້ລ່າສຸດ</h2>
                <a-button type="link" @click="$router.push('/orders')">
                    ເບິ່ງທັງໝົດ
                </a-button>
            </div>

            <a-table :columns="orderColumns" :data-source="recentOrders" :loading="loading" :pagination="false"
                row-key="id">
                <template #bodyCell="{ column, record }">
                    <template v-if="column.key === 'orderNo'">
                        <a @click="viewOrder(record)">{{ record.orderNo }}</a>
                    </template>

                    <template v-if="column.key === 'customer'">
                        <a-space>
                            <a-avatar :src="record.customer?.avatar" size="small">
                                {{ record.customer?.fullName?.charAt(0) || "C" }}
                            </a-avatar>
                            {{ record.customer?.fullName || "ບໍ່ມີຊື່" }}
                        </a-space>
                    </template>

                    <template v-if="column.key === 'total'">
                        {{ formatCurrency(record.total) }}
                    </template>

                    <template v-if="column.key === 'status'">
                        <span :class="['status-badge', record.status.toLowerCase()]">
                            {{ getStatusText(record.status) }}
                        </span>
                    </template>

                    <template v-if="column.key === 'createdAt'">
                        {{ formatDate(record.createdAt) }}
                    </template>
                </template>
            </a-table>
        </div>
    </div>
</template>

<script setup lang="ts">
import {
    ShoppingCartOutlined,
    DollarOutlined,
    ClockCircleOutlined,
    AppstoreOutlined,
    UserOutlined,
    UserAddOutlined,
    TeamOutlined,
    ShopOutlined,
    CarOutlined,
} from "@ant-design/icons-vue";
import dayjs from "dayjs";

definePageMeta({
    middleware: "auth",
});

const api = useApi();
const authStore = useAuthStore();

const loading = ref(false);

// Admin stats
const adminStats = ref<any>({});

// Merchant stats
const merchantStats = ref({
    todayOrders: 0,
    todayRevenue: 0,
    pendingOrders: 0,
    totalProducts: 0,
});

const recentOrders = ref<any[]>([]);

const orderColumns = [
    { title: "ເລກທີ່", key: "orderNo", dataIndex: "orderNo" },
    { title: "ລູກຄ້າ", key: "customer" },
    { title: "ຮ້ານ", key: "store", dataIndex: ["store", "name"] },
    { title: "ລວມ", key: "total" },
    { title: "ສະຖານະ", key: "status" },
    { title: "ເວລາ", key: "createdAt" },
];

const customerColumns = [
    { title: "ລູກຄ້າ", key: "customer" },
    { title: "ເຂົ້າລະບົບຜ່ານ", key: "provider" },
    { title: "ຄຳສັ່ງຊື້", key: "orders" },
    { title: "ວັນທີສະໝັກ", key: "createdAt" },
];

const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat("lo-LA", {
        style: "currency",
        currency: "LAK",
        minimumFractionDigits: 0,
    }).format(amount);
};

const formatDate = (date: string) => {
    return dayjs(date).format("DD/MM/YYYY HH:mm");
};

const getStatusText = (status: string) => {
    const texts: Record<string, string> = {
        PENDING: "ລໍຖ້າ",
        CONFIRMED: "ຢືນຢັນແລ້ວ",
        PREPARING: "ກຳລັງກະກຽມ",
        READY_FOR_PICKUP: "ພ້ອມສົ່ງ",
        PICKED_UP: "ຮັບແລ້ວ",
        DELIVERING: "ກຳລັງສົ່ງ",
        DELIVERED: "ສຳເລັດ",
        CANCELLED: "ຍົກເລີກ",
    };
    return texts[status] || status;
};

const getProviderColor = (provider: string) => {
    const colors: Record<string, string> = {
        GOOGLE: "red",
        FACEBOOK: "blue",
        APPLE: "default",
        EMAIL: "green",
        PHONE: "orange",
    };
    return colors[provider] || "default";
};

const getProviderText = (provider: string) => {
    const texts: Record<string, string> = {
        GOOGLE: "Google",
        FACEBOOK: "Facebook",
        APPLE: "Apple",
        EMAIL: "Email",
        PHONE: "ເບີໂທ",
    };
    return texts[provider] || provider;
};

const viewOrder = (order: any) => {
    navigateTo(`/orders/${order.id}`);
};

const fetchAdminDashboard = async () => {
    loading.value = true;
    try {
        // Fetch admin stats
        const statsResult = await api.get<any>("/api/admin/stats");
        adminStats.value = statsResult.data;

        // Fetch recent orders
        const ordersResult = await api.get<any>("/api/orders", { limit: 5 });
        recentOrders.value = ordersResult.data.orders || [];
    } catch (error) {
        console.error("Failed to fetch admin dashboard data:", error);
    } finally {
        loading.value = false;
    }
};

const fetchMerchantDashboard = async () => {
    loading.value = true;
    try {
        // Fetch recent orders
        const ordersResult = await api.get<any>("/api/orders", { limit: 5 });
        recentOrders.value = ordersResult.data.orders || [];

        // Calculate stats
        merchantStats.value.pendingOrders = recentOrders.value.filter(
            (o: any) => o.status === "PENDING"
        ).length;
    } catch (error) {
        console.error("Failed to fetch merchant dashboard data:", error);
    } finally {
        loading.value = false;
    }
};

onMounted(() => {
    if (authStore.isAdmin) {
        fetchAdminDashboard();
    } else {
        fetchMerchantDashboard();
    }
});
</script>
