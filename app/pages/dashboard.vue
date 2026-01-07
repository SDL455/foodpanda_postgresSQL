<template>
    <div>
        <div class="page-header">
            <h1>Dashboard</h1>
        </div>

        <!-- Stats -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon primary">
                    <ShoppingCartOutlined />
                </div>
                <div class="stat-value">{{ stats.todayOrders }}</div>
                <div class="stat-label">ຄຳສັ່ງຊື້ມື້ນີ້</div>
            </div>

            <div class="stat-card">
                <div class="stat-icon success">
                    <DollarOutlined />
                </div>
                <div class="stat-value">{{ formatCurrency(stats.todayRevenue) }}</div>
                <div class="stat-label">ລາຍຮັບມື້ນີ້</div>
            </div>

            <div class="stat-card">
                <div class="stat-icon warning">
                    <ClockCircleOutlined />
                </div>
                <div class="stat-value">{{ stats.pendingOrders }}</div>
                <div class="stat-label">ລໍຖ້າຢືນຢັນ</div>
            </div>

            <div class="stat-card">
                <div class="stat-icon info">
                    <AppstoreOutlined />
                </div>
                <div class="stat-value">{{ stats.totalProducts }}</div>
                <div class="stat-label">ສິນຄ້າທັງໝົດ</div>
            </div>
        </div>

        <!-- Recent Orders -->
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
                                {{ record.customer?.fullName?.charAt(0) || 'C' }}
                            </a-avatar>
                            {{ record.customer?.fullName || 'ບໍ່ມີຊື່' }}
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
} from '@ant-design/icons-vue'
import dayjs from 'dayjs'

definePageMeta({
    middleware: 'auth',
})

const api = useApi()

const loading = ref(false)
const stats = ref({
    todayOrders: 0,
    todayRevenue: 0,
    pendingOrders: 0,
    totalProducts: 0,
})
const recentOrders = ref<any[]>([])

const orderColumns = [
    { title: 'ເລກທີ່', key: 'orderNo', dataIndex: 'orderNo' },
    { title: 'ລູກຄ້າ', key: 'customer' },
    { title: 'ຮ້ານ', key: 'store', dataIndex: ['store', 'name'] },
    { title: 'ລວມ', key: 'total' },
    { title: 'ສະຖານະ', key: 'status' },
    { title: 'ເວລາ', key: 'createdAt' },
]

const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('lo-LA', {
        style: 'currency',
        currency: 'LAK',
        minimumFractionDigits: 0,
    }).format(amount)
}

const formatDate = (date: string) => {
    return dayjs(date).format('DD/MM/YYYY HH:mm')
}

const getStatusText = (status: string) => {
    const texts: Record<string, string> = {
        PENDING: 'ລໍຖ້າ',
        CONFIRMED: 'ຢືນຢັນແລ້ວ',
        PREPARING: 'ກຳລັງກະກຽມ',
        READY_FOR_PICKUP: 'ພ້ອມສົ່ງ',
        PICKED_UP: 'ຮັບແລ້ວ',
        DELIVERING: 'ກຳລັງສົ່ງ',
        DELIVERED: 'ສຳເລັດ',
        CANCELLED: 'ຍົກເລີກ',
    }
    return texts[status] || status
}

const viewOrder = (order: any) => {
    navigateTo(`/orders/${order.id}`)
}

const fetchDashboardData = async () => {
    loading.value = true
    try {
        // Fetch recent orders
        const ordersResult = await api.get<any>('/api/orders', { limit: 5 })
        recentOrders.value = ordersResult.data.orders || []

        // Calculate stats
        stats.value.pendingOrders = recentOrders.value.filter(
            (o: any) => o.status === 'PENDING'
        ).length
    } catch (error) {
        console.error('Failed to fetch dashboard data:', error)
    } finally {
        loading.value = false
    }
}

onMounted(() => {
    fetchDashboardData()
})
</script>
