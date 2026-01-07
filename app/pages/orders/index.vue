<template>
    <div>
        <div class="page-header">
            <h1>ຄຳສັ່ງຊື້</h1>
        </div>

        <!-- Filters -->
        <div class="card" style="margin-bottom: 16px;">
            <a-space wrap>
                <a-select v-model:value="statusFilter" style="width: 180px;" placeholder="ສະຖານະ" allowClear
                    @change="fetchOrders">
                    <a-select-option value="PENDING">ລໍຖ້າຢືນຢັນ</a-select-option>
                    <a-select-option value="CONFIRMED">ຢືນຢັນແລ້ວ</a-select-option>
                    <a-select-option value="PREPARING">ກຳລັງກະກຽມ</a-select-option>
                    <a-select-option value="READY_FOR_PICKUP">ພ້ອມສົ່ງ</a-select-option>
                    <a-select-option value="DELIVERING">ກຳລັງສົ່ງ</a-select-option>
                    <a-select-option value="DELIVERED">ສຳເລັດ</a-select-option>
                    <a-select-option value="CANCELLED">ຍົກເລີກ</a-select-option>
                </a-select>
                <a-button @click="fetchOrders">
                    <ReloadOutlined /> ໂຫຼດໃໝ່
                </a-button>
            </a-space>
        </div>

        <!-- Orders Table -->
        <div class="card">
            <a-table :columns="columns" :data-source="orders" :loading="loading" :pagination="pagination" row-key="id"
                @change="handleTableChange">
                <template #bodyCell="{ column, record }">
                    <template v-if="column.key === 'orderNo'">
                        <a @click="viewOrder(record)">{{ record.orderNo.slice(-8).toUpperCase() }}</a>
                    </template>

                    <template v-if="column.key === 'customer'">
                        <a-space>
                            <a-avatar :src="record.customer?.avatar" size="small">
                                {{ record.customer?.fullName?.charAt(0) || 'C' }}
                            </a-avatar>
                            <div>
                                <div>{{ record.customer?.fullName || 'ບໍ່ມີຊື່' }}</div>
                                <div style="font-size: 12px; color: #666;">{{ record.customer?.phone }}</div>
                            </div>
                        </a-space>
                    </template>

                    <template v-if="column.key === 'items'">
                        {{ record.items?.length || 0 }} ລາຍການ
                    </template>

                    <template v-if="column.key === 'total'">
                        {{ formatCurrency(record.total) }}
                    </template>

                    <template v-if="column.key === 'status'">
                        <span :class="['status-badge', record.status.toLowerCase().replace('_', '-')]">
                            {{ getStatusText(record.status) }}
                        </span>
                    </template>

                    <template v-if="column.key === 'createdAt'">
                        {{ formatDate(record.createdAt) }}
                    </template>

                    <template v-if="column.key === 'actions'">
                        <a-space>
                            <a-button size="small" @click="viewOrder(record)">
                                <EyeOutlined />
                            </a-button>
                            <template v-if="record.status === 'PENDING'">
                                <a-button size="small" type="primary" @click="updateStatus(record, 'CONFIRMED')">
                                    ຢືນຢັນ
                                </a-button>
                                <a-button size="small" danger @click="showCancelModal(record)">
                                    ຍົກເລີກ
                                </a-button>
                            </template>
                            <template v-else-if="record.status === 'CONFIRMED'">
                                <a-button size="small" type="primary" @click="updateStatus(record, 'PREPARING')">
                                    ກະກຽມ
                                </a-button>
                            </template>
                            <template v-else-if="record.status === 'PREPARING'">
                                <a-button size="small" type="primary" @click="updateStatus(record, 'READY_FOR_PICKUP')">
                                    ພ້ອມສົ່ງ
                                </a-button>
                            </template>
                        </a-space>
                    </template>
                </template>
            </a-table>
        </div>

        <!-- Order Detail Drawer -->
        <a-drawer v-model:open="showDetailDrawer" :title="`Order #${selectedOrder?.orderNo?.slice(-8).toUpperCase()}`"
            width="500">
            <template v-if="selectedOrder">
                <a-descriptions :column="1" bordered size="small">
                    <a-descriptions-item label="ລູກຄ້າ">
                        {{ selectedOrder.customer?.fullName }}
                    </a-descriptions-item>
                    <a-descriptions-item label="ເບີໂທ">
                        {{ selectedOrder.customer?.phone }}
                    </a-descriptions-item>
                    <a-descriptions-item label="ທີ່ຢູ່ຈັດສົ່ງ">
                        {{ selectedOrder.deliveryAddress }}
                    </a-descriptions-item>
                    <a-descriptions-item label="ໝາຍເຫດ">
                        {{ selectedOrder.deliveryNote || '-' }}
                    </a-descriptions-item>
                </a-descriptions>

                <a-divider>ລາຍການສິນຄ້າ</a-divider>

                <a-list :data-source="selectedOrder.items" size="small">
                    <template #renderItem="{ item }">
                        <a-list-item>
                            <a-list-item-meta>
                                <template #avatar>
                                    <a-avatar shape="square" :src="item.productImage">
                                        {{ item.productName?.charAt(0) }}
                                    </a-avatar>
                                </template>
                                <template #title>
                                    {{ item.productName }} x {{ item.quantity }}
                                </template>
                                <template #description>
                                    <div v-if="item.variants?.length">
                                        {{item.variants.map((v: any) => v.variantName).join(', ')}}
                                    </div>
                                    <div v-if="item.note" style="color: #666;">{{ item.note }}</div>
                                </template>
                            </a-list-item-meta>
                            <div>{{ formatCurrency(item.totalPrice) }}</div>
                        </a-list-item>
                    </template>
                </a-list>

                <a-divider />

                <a-descriptions :column="1" size="small">
                    <a-descriptions-item label="ລວມສິນຄ້າ">
                        {{ formatCurrency(selectedOrder.subtotal) }}
                    </a-descriptions-item>
                    <a-descriptions-item label="ຄ່າຈັດສົ່ງ">
                        {{ formatCurrency(selectedOrder.deliveryFee) }}
                    </a-descriptions-item>
                    <a-descriptions-item label="ສ່ວນຫຼຸດ">
                        -{{ formatCurrency(selectedOrder.discount) }}
                    </a-descriptions-item>
                    <a-descriptions-item label="ລວມທັງໝົດ">
                        <strong>{{ formatCurrency(selectedOrder.total) }}</strong>
                    </a-descriptions-item>
                </a-descriptions>
            </template>
        </a-drawer>

        <!-- Cancel Modal -->
        <a-modal v-model:open="showCancelModalVisible" title="ຍົກເລີກຄຳສັ່ງຊື້" :confirm-loading="saving"
            @ok="handleCancel">
            <a-form-item label="ເຫດຜົນ">
                <a-textarea v-model:value="cancelReason" placeholder="ເຫດຜົນໃນການຍົກເລີກ" :rows="3" />
            </a-form-item>
        </a-modal>
    </div>
</template>

<script setup lang="ts">
import { ReloadOutlined, EyeOutlined } from '@ant-design/icons-vue'
import { message } from 'ant-design-vue'
import dayjs from 'dayjs'

definePageMeta({
    middleware: 'auth',
})

const api = useApi()

const loading = ref(false)
const saving = ref(false)
const statusFilter = ref<string | undefined>(undefined)
const orders = ref<any[]>([])
const pagination = ref({
    current: 1,
    pageSize: 10,
    total: 0,
})

const showDetailDrawer = ref(false)
const selectedOrder = ref<any>(null)
const showCancelModalVisible = ref(false)
const cancelReason = ref('')
const cancellingOrder = ref<any>(null)

const columns = [
    { title: 'ເລກທີ່', key: 'orderNo', width: 100 },
    { title: 'ລູກຄ້າ', key: 'customer' },
    { title: 'ຮ້ານ', dataIndex: ['store', 'name'] },
    { title: 'ລາຍການ', key: 'items', width: 100 },
    { title: 'ລວມ', key: 'total', width: 120 },
    { title: 'ສະຖານະ', key: 'status', width: 120 },
    { title: 'ເວລາ', key: 'createdAt', width: 150 },
    { title: 'ການກະທຳ', key: 'actions', width: 200 },
]

const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('lo-LA', {
        style: 'currency',
        currency: 'LAK',
        minimumFractionDigits: 0,
    }).format(amount)
}

const formatDate = (date: string) => dayjs(date).format('DD/MM/YYYY HH:mm')

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

const fetchOrders = async () => {
    loading.value = true
    try {
        const result = await api.get<any>('/api/orders', {
            page: pagination.value.current,
            limit: pagination.value.pageSize,
            status: statusFilter.value,
        })
        orders.value = result.data.orders
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
    fetchOrders()
}

const viewOrder = async (order: any) => {
    try {
        const result = await api.get<any>(`/api/orders/${order.id}`)
        selectedOrder.value = result.data
        showDetailDrawer.value = true
    } catch (error) {
        message.error('ບໍ່ສາມາດໂຫຼດຂໍ້ມູນໄດ້')
    }
}

const updateStatus = async (order: any, status: string) => {
    try {
        await api.patch(`/api/orders/${order.id}/status`, { status })
        message.success('ອັບເດດສະຖານະສຳເລັດ')
        fetchOrders()
    } catch (error: any) {
        message.error(error.data?.message || 'ເກີດຂໍ້ຜິດພາດ')
    }
}

const showCancelModal = (order: any) => {
    cancellingOrder.value = order
    cancelReason.value = ''
    showCancelModalVisible.value = true
}

const handleCancel = async () => {
    saving.value = true
    try {
        await api.patch(`/api/orders/${cancellingOrder.value.id}/status`, {
            status: 'CANCELLED',
            cancelReason: cancelReason.value,
        })
        message.success('ຍົກເລີກສຳເລັດ')
        showCancelModalVisible.value = false
        fetchOrders()
    } catch (error: any) {
        message.error(error.data?.message || 'ເກີດຂໍ້ຜິດພາດ')
    } finally {
        saving.value = false
    }
}

onMounted(() => {
    fetchOrders()
})
</script>

<style scoped>
.status-badge.ready-for-pickup {
    background: rgba(#52c41a, 0.1);
    color: #52c41a;
}

.status-badge.picked-up {
    background: rgba(#1890ff, 0.1);
    color: #1890ff;
}
</style>
