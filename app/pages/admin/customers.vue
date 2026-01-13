<template>
    <div>
        <div class="page-header">
            <h1>ຈັດການລູກຄ້າ</h1>
        </div>

        <!-- Stats Cards -->
        <div class="stats-grid" style="margin-bottom: 24px;">
            <div class="stat-card">
                <div class="stat-icon primary">
                    <UserOutlined />
                </div>
                <div class="stat-value">{{ customerStats.total }}</div>
                <div class="stat-label">ລູກຄ້າທັງໝົດ</div>
            </div>
            <div class="stat-card">
                <div class="stat-icon success">
                    <UserAddOutlined />
                </div>
                <div class="stat-value">{{ customerStats.newToday }}</div>
                <div class="stat-label">ລູກຄ້າໃໝ່ມື້ນີ້</div>
            </div>
            <div class="stat-card">
                <div class="stat-icon info">
                    <CalendarOutlined />
                </div>
                <div class="stat-value">{{ customerStats.newThisMonth }}</div>
                <div class="stat-label">ລູກຄ້າໃໝ່ເດືອນນີ້</div>
            </div>
        </div>

        <!-- Search -->
        <div class="card" style="margin-bottom: 16px;">
            <a-input-search v-model:value="searchText" placeholder="ຄົ້ນຫາລູກຄ້າ (ຊື່, ອີເມລ, ເບີໂທ)..."
                style="max-width: 400px;" @search="fetchCustomers" />
        </div>

        <!-- Table -->
        <div class="card">
            <a-table :columns="columns" :data-source="customers" :loading="loading" :pagination="pagination"
                row-key="id" @change="handleTableChange">
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

                    <template v-if="column.key === 'authProvider'">
                        <a-tag :color="getProviderColor(record.authProvider)">
                            {{ getProviderText(record.authProvider) }}
                        </a-tag>
                    </template>

                    <template v-if="column.key === 'orders'">
                        {{ record._count?.orders || 0 }} ຄຳສັ່ງ
                    </template>

                    <template v-if="column.key === 'status'">
                        <a-tag :color="record.isActive ? 'green' : 'red'">
                            {{ record.isActive ? 'ໃຊ້ງານ' : 'ປິດໃຊ້ງານ' }}
                        </a-tag>
                    </template>

                    <template v-if="column.key === 'createdAt'">
                        {{ formatDate(record.createdAt) }}
                    </template>

                    <template v-if="column.key === 'actions'">
                        <a-space>
                            <a-button size="small" @click="viewCustomer(record)">
                                <EyeOutlined />
                            </a-button>
                            <a-button size="small" :type="record.isActive ? 'default' : 'primary'" danger
                                @click="toggleActive(record)">
                                {{ record.isActive ? 'ປິດ' : 'ເປີດ' }}
                            </a-button>
                        </a-space>
                    </template>
                </template>
            </a-table>
        </div>

        <!-- Customer Detail Modal -->
        <a-modal v-model:open="showDetailModal" :title="selectedCustomer?.fullName || 'ລາຍລະອຽດລູກຄ້າ'" width="700px"
            :footer="null">
            <template v-if="selectedCustomer">
                <a-descriptions :column="2" bordered size="small">
                    <a-descriptions-item label="ຊື່" :span="2">
                        <a-space>
                            <a-avatar :src="selectedCustomer.avatar" size="large">
                                {{ selectedCustomer.fullName?.charAt(0) || 'C' }}
                            </a-avatar>
                            <span>{{ selectedCustomer.fullName || 'ບໍ່ມີຊື່' }}</span>
                        </a-space>
                    </a-descriptions-item>
                    <a-descriptions-item label="ອີເມລ">
                        {{ selectedCustomer.email || '-' }}
                    </a-descriptions-item>
                    <a-descriptions-item label="ເບີໂທ">
                        {{ selectedCustomer.phone || '-' }}
                    </a-descriptions-item>
                    <a-descriptions-item label="ເຂົ້າລະບົບຜ່ານ">
                        <a-tag :color="getProviderColor(selectedCustomer.authProvider)">
                            {{ getProviderText(selectedCustomer.authProvider) }}
                        </a-tag>
                    </a-descriptions-item>
                    <a-descriptions-item label="ສະຖານະ">
                        <a-tag :color="selectedCustomer.isActive ? 'green' : 'red'">
                            {{ selectedCustomer.isActive ? 'ໃຊ້ງານ' : 'ປິດໃຊ້ງານ' }}
                        </a-tag>
                    </a-descriptions-item>
                    <a-descriptions-item label="ສະມາຊິກຕັ້ງແຕ່">
                        {{ formatDate(selectedCustomer.createdAt) }}
                    </a-descriptions-item>
                    <a-descriptions-item label="ເຂົ້າໃຊ້ລ່າສຸດ">
                        {{ selectedCustomer.lastLoginAt ? formatDate(selectedCustomer.lastLoginAt) : '-' }}
                    </a-descriptions-item>
                </a-descriptions>

                <a-divider>ສະຖິຕິ</a-divider>
                <a-row :gutter="16">
                    <a-col :span="8">
                        <a-statistic title="ຄຳສັ່ງຊື້ທັງໝົດ" :value="selectedCustomer._count?.orders || 0" />
                    </a-col>
                    <a-col :span="8">
                        <a-statistic title="ລີວິວ" :value="selectedCustomer._count?.reviews || 0" />
                    </a-col>
                    <a-col :span="8">
                        <a-statistic title="ຮ້ານທີ່ມັກ" :value="selectedCustomer._count?.favorites || 0" />
                    </a-col>
                </a-row>

                <a-divider v-if="selectedCustomer.addresses?.length > 0">ທີ່ຢູ່</a-divider>
                <a-list v-if="selectedCustomer.addresses?.length > 0" :data-source="selectedCustomer.addresses"
                    size="small">
                    <template #renderItem="{ item }">
                        <a-list-item>
                            <a-list-item-meta :title="item.label" :description="item.address">
                                <template #avatar>
                                    <EnvironmentOutlined />
                                </template>
                            </a-list-item-meta>
                            <template #actions>
                                <a-tag v-if="item.isDefault" color="blue">ຄ່າເລີ່ມຕົ້ນ</a-tag>
                            </template>
                        </a-list-item>
                    </template>
                </a-list>

                <a-divider v-if="selectedCustomer.orders?.length > 0">ຄຳສັ່ງຊື້ລ່າສຸດ</a-divider>
                <a-table v-if="selectedCustomer.orders?.length > 0" :columns="orderColumns"
                    :data-source="selectedCustomer.orders" :pagination="false" size="small" row-key="id">
                    <template #bodyCell="{ column, record }">
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
            </template>
        </a-modal>
    </div>
</template>

<script setup lang="ts">
import {
    UserOutlined,
    UserAddOutlined,
    CalendarOutlined,
    EyeOutlined,
    EnvironmentOutlined,
} from '@ant-design/icons-vue'
import { message } from 'ant-design-vue'
import dayjs from 'dayjs'

definePageMeta({
    middleware: 'auth',
})

const api = useApi()

const loading = ref(false)
const searchText = ref('')
const customers = ref<any[]>([])
const selectedCustomer = ref<any>(null)
const showDetailModal = ref(false)
const customerStats = ref({
    total: 0,
    newToday: 0,
    newThisMonth: 0,
})
const pagination = ref({
    current: 1,
    pageSize: 10,
    total: 0,
})

const columns = [
    { title: 'ລູກຄ້າ', key: 'customer' },
    { title: 'ເຂົ້າລະບົບຜ່ານ', key: 'authProvider', width: 120 },
    { title: 'ຄຳສັ່ງຊື້', key: 'orders', width: 100 },
    { title: 'ສະຖານະ', key: 'status', width: 100 },
    { title: 'ວັນທີສະໝັກ', key: 'createdAt', width: 140 },
    { title: 'ການກະທຳ', key: 'actions', width: 120 },
]

const orderColumns = [
    { title: 'ເລກທີ່', dataIndex: 'orderNo', width: 120 },
    { title: 'ຮ້ານ', dataIndex: ['store', 'name'] },
    { title: 'ລວມ', key: 'total', width: 120 },
    { title: 'ສະຖານະ', key: 'status', width: 100 },
    { title: 'ວັນທີ', key: 'createdAt', width: 140 },
]

const formatDate = (date: string) => dayjs(date).format('DD/MM/YYYY HH:mm')

const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('lo-LA', {
        style: 'currency',
        currency: 'LAK',
        minimumFractionDigits: 0,
    }).format(amount)
}

const getProviderColor = (provider: string) => {
    const colors: Record<string, string> = {
        GOOGLE: 'red',
        FACEBOOK: 'blue',
        APPLE: 'default',
        EMAIL: 'green',
        PHONE: 'orange',
    }
    return colors[provider] || 'default'
}

const getProviderText = (provider: string) => {
    const texts: Record<string, string> = {
        GOOGLE: 'Google',
        FACEBOOK: 'Facebook',
        APPLE: 'Apple',
        EMAIL: 'Email',
        PHONE: 'ເບີໂທ',
    }
    return texts[provider] || provider
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

const fetchStats = async () => {
    try {
        const result = await api.get<any>('/api/admin/stats')
        customerStats.value = result.data.customers
    } catch (error) {
        console.error('Failed to fetch stats:', error)
    }
}

const fetchCustomers = async () => {
    loading.value = true
    try {
        const result = await api.get<any>('/api/admin/customers', {
            page: pagination.value.current,
            limit: pagination.value.pageSize,
            search: searchText.value,
        })
        customers.value = result.data.customers
        pagination.value.total = result.data.pagination.total
    } catch (error) {
        message.error('ບໍ່ສາມາດໂຫຼດຂໍ້ມູນໄດ້')
    } finally {
        loading.value = false
    }
}

const handleTableChange = (pag: any) => {
    pagination.value.current = pag.current
    pagination.value.pageSize = pag.pageSize
    fetchCustomers()
}

const viewCustomer = async (customer: any) => {
    try {
        const result = await api.get<any>(`/api/admin/customers/${customer.id}`)
        selectedCustomer.value = result.data
        showDetailModal.value = true
    } catch (error) {
        message.error('ບໍ່ສາມາດໂຫຼດຂໍ້ມູນລູກຄ້າໄດ້')
    }
}

const toggleActive = async (customer: any) => {
    try {
        await api.patch(`/api/admin/customers/${customer.id}`, {
            isActive: !customer.isActive,
        })
        message.success('ອັບເດດສຳເລັດ')
        fetchCustomers()
    } catch (error: any) {
        message.error(error.data?.message || 'ເກີດຂໍ້ຜິດພາດ')
    }
}

onMounted(() => {
    fetchStats()
    fetchCustomers()
})
</script>
