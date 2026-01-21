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
            <div class="stat-card">
                <div class="stat-icon warning">
                    <ShopOutlined />
                </div>
                <div class="stat-value">{{ storeStats.total }}</div>
                <div class="stat-label">ຮ້ານຄ້າທັງໝົດ</div>
            </div>
        </div>

        <!-- Second Row Stats -->
        <div class="stats-grid" style="margin-bottom: 24px;">
            <div class="stat-card">
                <div class="stat-icon success">
                    <CheckCircleOutlined />
                </div>
                <div class="stat-value">{{ customerStats.active }}</div>
                <div class="stat-label">ລູກຄ້າ Active</div>
            </div>
            <div class="stat-card">
                <div class="stat-icon primary">
                    <DollarOutlined />
                </div>
                <div class="stat-value">{{ formatCurrency(revenue.today) }}</div>
                <div class="stat-label">ຍອດຂາຍມື້ນີ້</div>
            </div>
            <div class="stat-card">
                <div class="stat-icon info">
                    <DollarOutlined />
                </div>
                <div class="stat-value">{{ formatCurrency(revenue.month) }}</div>
                <div class="stat-label">ຍອດຂາຍເດືອນນີ້</div>
            </div>
            <div class="stat-card">
                <div class="stat-icon warning">
                    <ShoppingCartOutlined />
                </div>
                <div class="stat-value">{{ orderStats.today }}</div>
                <div class="stat-label">ຄຳສັ່ງຊື້ມື້ນີ້</div>
            </div>
        </div>

        <!-- Search & Filter -->
        <div class="card" style="margin-bottom: 16px;">
            <a-space wrap>
                <a-input-search v-model:value="searchText" placeholder="ຄົ້ນຫາລູກຄ້າ (ຊື່, ອີເມລ, ເບີໂທ)..."
                    style="width: 350px;" @search="fetchCustomers" allow-clear />
                <a-select v-model:value="statusFilter" style="width: 150px;" placeholder="ສະຖານະ" allowClear
                    @change="fetchCustomers">
                    <a-select-option value="all">ທັງໝົດ</a-select-option>
                    <a-select-option value="active">Active</a-select-option>
                    <a-select-option value="inactive">Inactive</a-select-option>
                </a-select>
                <a-select v-model:value="providerFilter" style="width: 150px;" placeholder="ເຂົ້າລະບົບຜ່ານ" allowClear
                    @change="fetchCustomers">
                    <a-select-option value="">ທັງໝົດ</a-select-option>
                    <a-select-option value="GOOGLE">Google</a-select-option>
                    <a-select-option value="FACEBOOK">Facebook</a-select-option>
                    <a-select-option value="APPLE">Apple</a-select-option>
                    <a-select-option value="EMAIL">Email</a-select-option>
                    <a-select-option value="PHONE">ເບີໂທ</a-select-option>
                </a-select>
                <a-button @click="resetFilters">
                    <ReloadOutlined /> ລ້າງ
                </a-button>
            </a-space>
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
                                <div style="font-weight: 500;">{{ record.fullName || 'ບໍ່ມີຊື່' }}</div>
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
                        <a-badge :count="record._count?.orders || 0" :number-style="{ backgroundColor: '#52c41a' }">
                            <a-tag color="green">{{ record._count?.orders || 0 }} ຄຳສັ່ງ</a-tag>
                        </a-badge>
                    </template>

                    <template v-if="column.key === 'favorites'">
                        <a-tag color="pink">
                            <HeartOutlined /> {{ record._count?.favorites || 0 }}
                        </a-tag>
                    </template>

                    <template v-if="column.key === 'totalSpent'">
                        <span style="font-weight: 500; color: #d70f64;">
                            {{ formatCurrency(record.totalSpent || 0) }}
                        </span>
                    </template>

                    <template v-if="column.key === 'status'">
                        <a-tag :color="record.isActive ? 'green' : 'red'">
                            {{ record.isActive ? 'Active' : 'Inactive' }}
                        </a-tag>
                    </template>

                    <template v-if="column.key === 'createdAt'">
                        {{ formatDate(record.createdAt) }}
                    </template>

                    <template v-if="column.key === 'actions'">
                        <a-space>
                            <a-tooltip title="ເບິ່ງລາຍລະອຽດ">
                                <a-button size="small" type="primary" @click="viewCustomer(record)">
                                    <EyeOutlined />
                                </a-button>
                            </a-tooltip>
                            <a-tooltip :title="record.isActive ? 'ປິດໃຊ້ງານ' : 'ເປີດໃຊ້ງານ'">
                                <a-button size="small" :type="record.isActive ? 'default' : 'primary'" danger
                                    @click="toggleActive(record)">
                                    {{ record.isActive ? 'ປິດ' : 'ເປີດ' }}
                                </a-button>
                            </a-tooltip>
                        </a-space>
                    </template>
                </template>
            </a-table>
        </div>

        <!-- Customer Detail Modal with Tabs -->
        <a-modal v-model:open="showDetailModal" :title="selectedCustomer?.fullName || 'ລາຍລະອຽດລູກຄ້າ'" width="800px"
            :footer="null">
            <template v-if="selectedCustomer">
                <!-- Customer Header -->
                <div class="customer-header">
                    <a-avatar :src="selectedCustomer.avatar" :size="64">
                        {{ selectedCustomer.fullName?.charAt(0) || 'C' }}
                    </a-avatar>
                    <div class="customer-header-info">
                        <h2>{{ selectedCustomer.fullName || 'ບໍ່ມີຊື່' }}</h2>
                        <a-space>
                            <a-tag :color="getProviderColor(selectedCustomer.authProvider)">
                                {{ getProviderText(selectedCustomer.authProvider) }}
                            </a-tag>
                            <a-tag :color="selectedCustomer.isActive ? 'green' : 'red'">
                                {{ selectedCustomer.isActive ? 'Active' : 'Inactive' }}
                            </a-tag>
                        </a-space>
                    </div>
                    <div class="customer-header-stats">
                        <a-statistic title="ຍອດໃຊ້ຈ່າຍລວມ" :value="selectedCustomer.totalSpent || 0"
                            :formatter="(val: number) => formatCurrency(val)" />
                    </div>
                </div>

                <!-- Stats Row -->
                <a-row :gutter="[16, 16]" style="margin: 16px 0;">
                    <a-col :xs="12" :sm="8" :md="4">
                        <a-card size="small">
                            <a-statistic title="ຄຳສັ່ງຊື້" :value="selectedCustomer._count?.orders || 0"
                                :value-style="{ color: '#52c41a' }">
                                <template #prefix>
                                    <ShoppingCartOutlined />
                                </template>
                            </a-statistic>
                        </a-card>
                    </a-col>
                    <a-col :xs="12" :sm="8" :md="4">
                        <a-card size="small">
                            <a-statistic title="ຮ້ານທີ່ມັກ" :value="selectedCustomer._count?.favorites || 0"
                                :value-style="{ color: '#eb2f96' }">
                                <template #prefix>
                                    <HeartOutlined />
                                </template>
                            </a-statistic>
                        </a-card>
                    </a-col>
                    <a-col :xs="12" :sm="8" :md="4">
                        <a-card size="small">
                            <a-statistic title="ລີວິວ" :value="selectedCustomer._count?.reviews || 0"
                                :value-style="{ color: '#faad14' }">
                                <template #prefix>
                                    <StarOutlined />
                                </template>
                            </a-statistic>
                        </a-card>
                    </a-col>
                    <a-col :xs="12" :sm="8" :md="4">
                        <a-card size="small">
                            <a-statistic title="ທີ່ຢູ່" :value="selectedCustomer.addresses?.length || 0"
                                :value-style="{ color: '#1890ff' }">
                                <template #prefix>
                                    <EnvironmentOutlined />
                                </template>
                            </a-statistic>
                        </a-card>
                    </a-col>
                    <a-col :xs="12" :sm="8" :md="4">
                        <a-card size="small">
                            <a-statistic title="ອາຫານຍອດນິຍົມ" :value="selectedCustomer.popularProducts?.length || 0"
                                :value-style="{ color: '#ff4d4f' }">
                                <template #prefix>
                                    <FireOutlined />
                                </template>
                            </a-statistic>
                        </a-card>
                    </a-col>
                    <a-col :xs="12" :sm="8" :md="4">
                        <a-card size="small">
                            <a-statistic title="ອາຫານຄຽງ" :value="selectedCustomer.sideDishes?.length || 0"
                                :value-style="{ color: '#722ed1' }">
                                <template #prefix>
                                    <CoffeeOutlined />
                                </template>
                            </a-statistic>
                        </a-card>
                    </a-col>
                </a-row>

                <!-- Tabs -->
                <a-tabs v-model:activeKey="activeTab">
                    <!-- Tab 1: ຂໍ້ມູນທົ່ວໄປ -->
                    <a-tab-pane key="info" tab="ຂໍ້ມູນທົ່ວໄປ">
                        <a-descriptions :column="2" bordered size="small">
                            <a-descriptions-item label="ອີເມລ">
                                {{ selectedCustomer.email || '-' }}
                            </a-descriptions-item>
                            <a-descriptions-item label="ເບີໂທ">
                                {{ selectedCustomer.phone || '-' }}
                            </a-descriptions-item>
                            <a-descriptions-item label="ສະມາຊິກຕັ້ງແຕ່">
                                {{ formatDate(selectedCustomer.createdAt) }}
                            </a-descriptions-item>
                            <a-descriptions-item label="ເຂົ້າໃຊ້ລ່າສຸດ">
                                {{ selectedCustomer.lastLoginAt ? formatDate(selectedCustomer.lastLoginAt) : '-' }}
                            </a-descriptions-item>
                        </a-descriptions>

                        <a-divider v-if="selectedCustomer.addresses?.length > 0">ທີ່ຢູ່ຈັດສົ່ງ</a-divider>
                        <a-list v-if="selectedCustomer.addresses?.length > 0" :data-source="selectedCustomer.addresses"
                            size="small">
                            <template #renderItem="{ item }">
                                <a-list-item>
                                    <a-list-item-meta :title="item.label" :description="item.address">
                                        <template #avatar>
                                            <a-avatar :style="{ backgroundColor: '#1890ff' }">
                                                <template #icon>
                                                    <EnvironmentOutlined />
                                                </template>
                                            </a-avatar>
                                        </template>
                                    </a-list-item-meta>
                                    <template #actions>
                                        <a-tag v-if="item.isDefault" color="blue">ຄ່າເລີ່ມຕົ້ນ</a-tag>
                                    </template>
                                </a-list-item>
                            </template>
                        </a-list>
                        <a-empty v-else description="ບໍ່ມີທີ່ຢູ່" />
                    </a-tab-pane>

                    <!-- Tab 2: ຄຳສັ່ງຊື້ -->
                    <a-tab-pane key="orders" tab="ຄຳສັ່ງຊື້">
                        <a-table v-if="selectedCustomer.orders?.length > 0" :columns="orderColumns"
                            :data-source="selectedCustomer.orders" :pagination="false" size="small" row-key="id">
                            <template #bodyCell="{ column, record }">
                                <template v-if="column.key === 'orderNo'">
                                    <a>{{ record.orderNo?.slice(-8).toUpperCase() }}</a>
                                </template>
                                <template v-if="column.key === 'store'">
                                    <a-space>
                                        <a-avatar :src="record.store?.logo" size="small" shape="square">
                                            {{ record.store?.name?.charAt(0) }}
                                        </a-avatar>
                                        {{ record.store?.name }}
                                    </a-space>
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
                            </template>
                        </a-table>
                        <a-empty v-else description="ບໍ່ມີຄຳສັ່ງຊື້" />
                    </a-tab-pane>

                    <!-- Tab 3: ຮ້ານທີ່ມັກ -->
                    <a-tab-pane key="favorites" tab="ຮ້ານທີ່ມັກ">
                        <a-row v-if="selectedCustomer.favorites?.length > 0" :gutter="[16, 16]">
                            <a-col v-for="fav in selectedCustomer.favorites" :key="fav.id" :xs="24" :sm="12">
                                <a-card size="small" hoverable>
                                    <a-card-meta>
                                        <template #avatar>
                                            <a-avatar :src="fav.store?.logo" size="large" shape="square">
                                                {{ fav.store?.name?.charAt(0) }}
                                            </a-avatar>
                                        </template>
                                        <template #title>
                                            <a-space>
                                                {{ fav.store?.name }}
                                                <a-tag v-if="!fav.store?.isActive" color="red" size="small">ປິດ</a-tag>
                                            </a-space>
                                        </template>
                                        <template #description>
                                            <div>
                                                <EnvironmentOutlined /> {{ fav.store?.address || 'ບໍ່ມີທີ່ຢູ່' }}
                                            </div>
                                            <a-space style="margin-top: 4px;">
                                                <a-rate :value="fav.store?.rating || 0" disabled allow-half
                                                    style="font-size: 12px;" />
                                                <span>{{ (fav.store?.rating || 0).toFixed(1) }}</span>
                                                <a-tag color="blue">{{ fav.store?._count?.products || 0 }}
                                                    ສິນຄ້າ</a-tag>
                                            </a-space>
                                        </template>
                                    </a-card-meta>
                                </a-card>
                            </a-col>
                        </a-row>
                        <a-empty v-else description="ບໍ່ມີຮ້ານທີ່ມັກ" />
                    </a-tab-pane>

                    <!-- Tab 4: ລີວິວ -->
                    <a-tab-pane key="reviews" tab="ລີວິວ">
                        <a-list v-if="selectedCustomer.reviews?.length > 0" :data-source="selectedCustomer.reviews"
                            size="small">
                            <template #renderItem="{ item }">
                                <a-list-item>
                                    <a-list-item-meta>
                                        <template #avatar>
                                            <a-avatar :src="item.store?.logo" shape="square">
                                                {{ item.store?.name?.charAt(0) }}
                                            </a-avatar>
                                        </template>
                                        <template #title>
                                            <a-space>
                                                <span>{{ item.store?.name }}</span>
                                                <a-rate :value="item.rating" disabled style="font-size: 12px;" />
                                            </a-space>
                                        </template>
                                        <template #description>
                                            <div>{{ item.comment || 'ບໍ່ມີຄຳເຫັນ' }}</div>
                                            <div style="font-size: 12px; color: #999;">{{ formatDate(item.createdAt) }}
                                            </div>
                                        </template>
                                    </a-list-item-meta>
                                </a-list-item>
                            </template>
                        </a-list>
                        <a-empty v-else description="ບໍ່ມີລີວິວ" />
                    </a-tab-pane>

                    <!-- Tab 5: ຮ້ານທີ່ເຄີຍສັ່ງ -->
                    <a-tab-pane key="orderedStores" tab="ຮ້ານທີ່ເຄີຍສັ່ງ">
                        <a-space v-if="selectedCustomer.orderedStores?.length > 0" wrap>
                            <a-tag v-for="store in selectedCustomer.orderedStores" :key="store.id" color="blue"
                                style="padding: 8px 12px;">
                                <a-space>
                                    <a-avatar :src="store.logo" size="small" shape="square">
                                        {{ store.name?.charAt(0) }}
                                    </a-avatar>
                                    {{ store.name }}
                                </a-space>
                            </a-tag>
                        </a-space>
                        <a-empty v-else description="ບໍ່ມີປະຫວັດການສັ່ງຊື້" />
                    </a-tab-pane>

                    <!-- Tab 6: ອາຫານຍອດນິຍົມ -->
                    <a-tab-pane key="popularProducts" tab="ອາຫານຍອດນິຍົມ">
                        <a-row v-if="selectedCustomer.popularProducts?.length > 0" :gutter="[16, 16]">
                            <a-col v-for="item in selectedCustomer.popularProducts" :key="item.product.id" :xs="24"
                                :sm="12" :md="8">
                                <a-card size="small" hoverable class="product-card">
                                    <template #cover>
                                        <div class="product-image-container">
                                            <img v-if="item.product.image" :src="item.product.image"
                                                :alt="item.product.name" class="product-image" />
                                            <div v-else class="product-image-placeholder">
                                                <ShopOutlined style="font-size: 32px; color: #ccc;" />
                                            </div>
                                            <a-badge :count="item.quantity" class="quantity-badge">
                                                <template #count>
                                                    <span class="quantity-text">{{ item.quantity }}x</span>
                                                </template>
                                            </a-badge>
                                        </div>
                                    </template>
                                    <a-card-meta :title="item.product.name">
                                        <template #description>
                                            <div class="product-info">
                                                <a-tag v-if="item.product.category" color="blue" size="small">
                                                    {{ item.product.category.name }}
                                                </a-tag>
                                                <div class="product-price">
                                                    {{ formatCurrency(item.product.basePrice) }}
                                                </div>
                                                <div class="product-stats">
                                                    <span>
                                                        <ShoppingCartOutlined /> ສັ່ງ {{ item.orderCount }} ຄັ້ງ
                                                    </span>
                                                    <span>
                                                        <FireOutlined style="color: #ff4d4f;" /> ຂາຍແລ້ວ {{
                                                            item.product.totalSold }}
                                                    </span>
                                                </div>
                                            </div>
                                        </template>
                                    </a-card-meta>
                                </a-card>
                            </a-col>
                        </a-row>
                        <a-empty v-else description="ບໍ່ມີອາຫານຍອດນິຍົມ" />
                    </a-tab-pane>

                    <!-- Tab 7: ອາຫານຄຽງ -->
                    <a-tab-pane key="sideDishes" tab="ອາຫານຄຽງ">
                        <a-row v-if="selectedCustomer.sideDishes?.length > 0" :gutter="[16, 16]">
                            <a-col v-for="item in selectedCustomer.sideDishes" :key="item.product.id" :xs="24" :sm="12"
                                :md="8">
                                <a-card size="small" hoverable class="product-card">
                                    <template #cover>
                                        <div class="product-image-container">
                                            <img v-if="item.product.image" :src="item.product.image"
                                                :alt="item.product.name" class="product-image" />
                                            <div v-else class="product-image-placeholder">
                                                <CoffeeOutlined style="font-size: 32px; color: #ccc;" />
                                            </div>
                                            <a-badge :count="item.quantity" class="quantity-badge">
                                                <template #count>
                                                    <span class="quantity-text">{{ item.quantity }}x</span>
                                                </template>
                                            </a-badge>
                                        </div>
                                    </template>
                                    <a-card-meta :title="item.product.name">
                                        <template #description>
                                            <div class="product-info">
                                                <a-tag v-if="item.product.category" color="green" size="small">
                                                    {{ item.product.category.name }}
                                                </a-tag>
                                                <div class="product-price">
                                                    {{ formatCurrency(item.product.basePrice) }}
                                                </div>
                                                <div class="product-stats">
                                                    <span>
                                                        <ShoppingCartOutlined /> ສັ່ງ {{ item.orderCount }} ຄັ້ງ
                                                    </span>
                                                </div>
                                            </div>
                                        </template>
                                    </a-card-meta>
                                </a-card>
                            </a-col>
                        </a-row>
                        <a-empty v-else description="ບໍ່ມີອາຫານຄຽງ" />
                    </a-tab-pane>
                </a-tabs>
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
    ShopOutlined,
    CheckCircleOutlined,
    DollarOutlined,
    ShoppingCartOutlined,
    HeartOutlined,
    StarOutlined,
    ReloadOutlined,
    FireOutlined,
    CoffeeOutlined,
} from '@ant-design/icons-vue'
import { message } from 'ant-design-vue'
import dayjs from 'dayjs'

definePageMeta({
    middleware: 'auth',
})

const api = useApi()

const loading = ref(false)
const searchText = ref('')
const statusFilter = ref<string | undefined>(undefined)
const providerFilter = ref<string>('')
const customers = ref<any[]>([])
const selectedCustomer = ref<any>(null)
const showDetailModal = ref(false)
const activeTab = ref('info')

const customerStats = ref({
    total: 0,
    newToday: 0,
    newThisMonth: 0,
    active: 0,
})

const storeStats = ref({
    total: 0,
    active: 0,
})

const orderStats = ref({
    total: 0,
    today: 0,
    pending: 0,
})

const revenue = ref({
    today: 0,
    month: 0,
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
    { title: 'ຮ້ານທີ່ມັກ', key: 'favorites', width: 100 },
    { title: 'ຍອດໃຊ້ຈ່າຍ', key: 'totalSpent', width: 130 },
    { title: 'ສະຖານະ', key: 'status', width: 100 },
    { title: 'ວັນທີສະໝັກ', key: 'createdAt', width: 130 },
    { title: 'ການກະທຳ', key: 'actions', width: 120 },
]

const orderColumns = [
    { title: 'ເລກທີ່', key: 'orderNo', width: 100 },
    { title: 'ຮ້ານ', key: 'store' },
    { title: 'ລວມ', key: 'total', width: 120 },
    { title: 'ສະຖານະ', key: 'status', width: 100 },
    { title: 'ວັນທີ', key: 'createdAt', width: 130 },
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
        customerStats.value = {
            ...result.data.customers,
            active: result.data.customers.total, // Will be updated from customers API
        }
        storeStats.value = result.data.stores
        orderStats.value = result.data.orders
        revenue.value = result.data.revenue
    } catch (error) {
        console.error('Failed to fetch stats:', error)
    }
}

const fetchCustomers = async () => {
    loading.value = true
    try {
        const params: any = {
            page: pagination.value.current,
            limit: pagination.value.pageSize,
            search: searchText.value,
        }

        if (providerFilter.value) {
            params.provider = providerFilter.value
        }

        if (statusFilter.value && statusFilter.value !== 'all') {
            params.status = statusFilter.value
        }

        const result = await api.get<any>('/api/admin/customers', params)
        customers.value = result.data.customers
        pagination.value.total = result.data.pagination.total

        // Update active count from API
        if (result.data.stats?.active !== undefined) {
            customerStats.value.active = result.data.stats.active
        }
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

const resetFilters = () => {
    searchText.value = ''
    statusFilter.value = undefined
    providerFilter.value = ''
    pagination.value.current = 1
    fetchCustomers()
}

const viewCustomer = async (customer: any) => {
    try {
        const result = await api.get<any>(`/api/admin/customers/${customer.id}`)
        selectedCustomer.value = result.data
        activeTab.value = 'info'
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

<style scoped>
.customer-header {
    display: flex;
    align-items: center;
    gap: 16px;
    padding: 16px;
    background: linear-gradient(135deg, #fff5f8 0%, #fff 100%);
    border-radius: 8px;
    margin-bottom: 16px;
}

.customer-header-info {
    flex: 1;
}

.customer-header-info h2 {
    margin: 0 0 8px 0;
    font-size: 20px;
    font-weight: 600;
}

.customer-header-stats {
    text-align: right;
}

.status-badge {
    padding: 4px 8px;
    border-radius: 4px;
    font-size: 12px;
    font-weight: 500;
}

.status-badge.pending {
    background: rgba(250, 173, 20, 0.1);
    color: #faad14;
}

.status-badge.confirmed {
    background: rgba(24, 144, 255, 0.1);
    color: #1890ff;
}

.status-badge.preparing {
    background: rgba(114, 46, 209, 0.1);
    color: #722ed1;
}

.status-badge.ready-for-pickup {
    background: rgba(82, 196, 26, 0.1);
    color: #52c41a;
}

.status-badge.picked-up {
    background: rgba(24, 144, 255, 0.1);
    color: #1890ff;
}

.status-badge.delivering {
    background: rgba(250, 140, 22, 0.1);
    color: #fa8c16;
}

.status-badge.delivered {
    background: rgba(82, 196, 26, 0.1);
    color: #52c41a;
}

.status-badge.cancelled {
    background: rgba(255, 77, 79, 0.1);
    color: #ff4d4f;
}

/* Product Card Styles */
.product-card {
    height: 100%;
}

.product-card :deep(.ant-card-cover) {
    height: 120px;
    overflow: hidden;
}

.product-image-container {
    position: relative;
    height: 120px;
    overflow: hidden;
    background: #f5f5f5;
}

.product-image {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.product-image-placeholder {
    width: 100%;
    height: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
    background: #f0f0f0;
}

.quantity-badge {
    position: absolute;
    top: 8px;
    right: 8px;
}

.quantity-text {
    background: #d70f64;
    color: white;
    padding: 2px 8px;
    border-radius: 10px;
    font-size: 12px;
    font-weight: 600;
}

.product-info {
    display: flex;
    flex-direction: column;
    gap: 8px;
}

.product-price {
    font-size: 14px;
    font-weight: 600;
    color: #d70f64;
}

.product-stats {
    display: flex;
    flex-direction: column;
    gap: 4px;
    font-size: 12px;
    color: #666;
}

.product-stats span {
    display: flex;
    align-items: center;
    gap: 4px;
}
</style>
