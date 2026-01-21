<template>
    <div>
        <div class="page-header">
            <h1>ຮ້ານຄ້າ</h1>
            <a-select v-if="authStore.isAdmin" v-model:value="selectedMerchantId" style="width: 200px;"
                placeholder="ເລືອກ Merchant" allowClear @change="fetchStores">
                <a-select-option value="">ທັງໝົດ</a-select-option>
                <a-select-option v-for="m in merchants" :key="m.id" :value="m.id">
                    {{ m.name }} ({{ m._count?.stores || 0 }})
                </a-select-option>
            </a-select>
        </div>

        <!-- Store Table Grouped by Merchant (Admin View) -->
        <a-spin :spinning="loading">
            <template v-if="authStore.isAdmin && groupedData.length > 0">
                <div v-for="merchant in filteredMerchants" :key="merchant.id" class="merchant-group">
                    <div class="merchant-header">
                        <a-space>
                            <TeamOutlined />
                            <h2>{{ merchant.name }}</h2>
                            <a-tag color="blue">{{ merchant.stores?.length || 0 }} ຮ້ານ</a-tag>
                        </a-space>
                    </div>

                    <div v-if="merchant.stores?.length === 0" class="empty-state" style="padding: 20px;">
                        <p>ຍັງບໍ່ມີຮ້ານຄ້າ</p>
                    </div>

                    <a-table v-else :columns="storeColumns" :data-source="merchant.stores" :pagination="false"
                        row-key="id" :row-class-name="() => 'clickable-row'"
                        :custom-row="(record: any) => ({ onClick: () => $router.push(`/stores/${record.id}`) })">
                        <template #bodyCell="{ column, record }">
                            <template v-if="column.key === 'name'">
                                <a-space>
                                    <a-avatar :src="record.logo" shape="square" :size="40">
                                        <template #icon>
                                            <ShopOutlined />
                                        </template>
                                    </a-avatar>
                                    <div>
                                        <div style="font-weight: 500;">{{ record.name }}</div>
                                        <div style="font-size: 12px; color: #888;">{{ record.phone || '-' }}</div>
                                    </div>
                                </a-space>
                            </template>
                            <template v-else-if="column.key === 'address'">
                                {{ record.address || '-' }}
                            </template>
                            <template v-else-if="column.key === 'products'">
                                <a-tag color="blue">{{ record._count?.products || 0 }}</a-tag>
                            </template>
                            <template v-else-if="column.key === 'orders'">
                                <a-tag color="green">{{ record._count?.orders || 0 }}</a-tag>
                            </template>
                            <template v-else-if="column.key === 'status'">
                                <a-tag :color="record.isActive ? 'success' : 'error'">
                                    {{ record.isActive ? 'ເປີດ' : 'ປິດ' }}
                                </a-tag>
                            </template>
                            <template v-else-if="column.key === 'action'">
                                <a-button type="link" size="small" @click.stop="$router.push(`/stores/${record.id}`)">
                                    <EyeOutlined /> ລາຍລະອຽດ
                                </a-button>
                            </template>
                        </template>
                    </a-table>
                </div>
            </template>

            <!-- Empty State (Admin with no data) -->
            <div v-else-if="authStore.isAdmin && groupedData.length === 0 && !loading" class="empty-state">
                <ShopOutlined class="empty-icon" />
                <h3>ຍັງບໍ່ມີຮ້ານຄ້າ</h3>
                <p>ກະລຸນາເພີ່ມ Merchant ກ່ອນ ແລ້ວຈຶ່ງສ້າງຮ້ານ</p>
                <a-button type="primary" @click="$router.push('/admin/merchants')">
                    ໄປຈັດການ Merchant
                </a-button>
            </div>

            <!-- Merchant User View (Regular) -->
            <template v-if="!authStore.isAdmin">
                <div v-if="stores.length === 0" class="empty-state">
                    <ShopOutlined class="empty-icon" />
                    <h3>ຍັງບໍ່ມີຮ້ານຄ້າ</h3>
                    <p>ກະລຸນາຕິດຕໍ່ Admin ເພື່ອເພີ່ມຮ້ານໃໝ່</p>
                </div>

                <a-row v-else :gutter="[16, 16]">
                    <a-col v-for="store in stores" :key="store.id" :xs="24" :sm="12" :lg="8" :xl="6">
                        <a-card hoverable @click="$router.push(`/stores/${store.id}`)">
                            <template #cover>
                                <div class="store-cover"
                                    :style="{ backgroundImage: store.coverImage ? `url(${store.coverImage})` : 'linear-gradient(135deg, #f5f5f5 0%, #e0e0e0 100%)' }">
                                    <a-tag v-if="!store.isActive" color="red"
                                        style="position: absolute; top: 10px; right: 10px;">
                                        ປິດ
                                    </a-tag>
                                </div>
                            </template>
                            <a-card-meta :title="store.name">
                                <template #description>
                                    <div>{{ store.address || 'ບໍ່ມີທີ່ຢູ່' }}</div>
                                    <a-space style="margin-top: 8px;">
                                        <span>
                                            <AppstoreOutlined /> {{ store._count?.products || 0 }} ສິນຄ້າ
                                        </span>
                                        <span>
                                            <ShoppingCartOutlined /> {{ store._count?.orders || 0 }} ຄຳສັ່ງ
                                        </span>
                                    </a-space>
                                </template>
                            </a-card-meta>
                        </a-card>
                    </a-col>
                </a-row>
            </template>
        </a-spin>

    </div>
</template>

<script setup lang="ts">
import { ShopOutlined, AppstoreOutlined, ShoppingCartOutlined, TeamOutlined, EyeOutlined } from '@ant-design/icons-vue'
import { message } from 'ant-design-vue'

definePageMeta({
    middleware: 'auth',
})

const api = useApi()
const authStore = useAuthStore()

const loading = ref(false)
const stores = ref<any[]>([])
const merchants = ref<any[]>([])
const groupedData = ref<any[]>([])
const selectedMerchantId = ref<string>('')

// Table columns for admin view
const storeColumns = [
    { title: 'ຮ້ານຄ້າ', key: 'name', dataIndex: 'name' },
    { title: 'ທີ່ຢູ່', key: 'address', dataIndex: 'address', ellipsis: true },
    { title: 'ສິນຄ້າ', key: 'products', width: 100, align: 'center' as const },
    { title: 'ຄຳສັ່ງຊື້', key: 'orders', width: 100, align: 'center' as const },
    { title: 'ສະຖານະ', key: 'status', width: 100, align: 'center' as const },
    { title: '', key: 'action', width: 120, align: 'center' as const },
]

// Filter merchants by selection
const filteredMerchants = computed(() => {
    if (!selectedMerchantId.value) {
        return groupedData.value
    }
    return groupedData.value.filter(m => m.id === selectedMerchantId.value)
})

const fetchStores = async () => {
    loading.value = true
    try {
        if (authStore.isAdmin) {
            // Admin: fetch grouped by merchant
            const result = await api.get<any>('/api/stores', { groupByMerchant: 'true' })
            groupedData.value = result.data.merchants || []
            merchants.value = result.data.merchants || []
        } else {
            // Merchant user: fetch normal list
            const result = await api.get<any>('/api/stores')
            stores.value = result.data.stores || []
        }
    } catch (error) {
        message.error('ບໍ່ສາມາດໂຫຼດຂໍ້ມູນໄດ້')
    } finally {
        loading.value = false
    }
}

onMounted(() => {
    fetchStores()
})
</script>

<style scoped>
.store-cover {
    height: 150px;
    background-size: cover;
    background-position: center;
    background-color: #f0f0f0;
    position: relative;
}

.merchant-group {
    margin-bottom: 32px;
}

.merchant-header {
    margin-bottom: 16px;
    padding-bottom: 12px;
    border-bottom: 2px solid #d70f64;
}

.merchant-header h2 {
    margin: 0;
    font-size: 18px;
    font-weight: 600;
}

:deep(.clickable-row) {
    cursor: pointer;
    transition: background-color 0.2s;
}

:deep(.clickable-row:hover) {
    background-color: #f5f5f5 !important;
}
</style>
