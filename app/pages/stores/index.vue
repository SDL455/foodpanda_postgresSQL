<template>
    <div>
        <div class="page-header">
            <h1>ຮ້ານຄ້າ</h1>
            <a-space>
                <a-select v-if="authStore.isAdmin" v-model:value="selectedMerchantId" style="width: 200px;"
                    placeholder="ເລືອກ Merchant" allowClear @change="fetchStores">
                    <a-select-option value="">ທັງໝົດ</a-select-option>
                    <a-select-option v-for="m in merchants" :key="m.id" :value="m.id">
                        {{ m.name }} ({{ m._count?.stores || 0 }})
                    </a-select-option>
                </a-select>
                <a-button type="primary" @click="openCreateModal">
                    <PlusOutlined /> ເພີ່ມຮ້ານ
                </a-button>
            </a-space>
        </div>

        <!-- Store Cards Grouped by Merchant (Admin View) -->
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

                    <a-row v-else :gutter="[16, 16]">
                        <a-col v-for="store in merchant.stores" :key="store.id" :xs="24" :sm="12" :lg="8" :xl="6">
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
                    <p>ກົດປຸ່ມ "ເພີ່ມຮ້ານ" ເພື່ອສ້າງຮ້ານໃໝ່</p>
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

        <!-- Create Modal -->
        <a-modal v-model:open="showCreateModal" title="ສ້າງຮ້ານໃໝ່" :confirm-loading="saving" width="600px"
            @ok="handleCreate">
            <a-form :model="createForm" layout="vertical">
                <!-- Merchant Selection (Admin only) -->
                <a-form-item v-if="authStore.isAdmin" label="Merchant" required>
                    <a-select v-model:value="createForm.merchantId" placeholder="ເລືອກ Merchant" style="width: 100%;">
                        <a-select-option v-for="m in merchants" :key="m.id" :value="m.id">
                            {{ m.name }}
                        </a-select-option>
                    </a-select>
                </a-form-item>

                <a-form-item label="ຊື່ຮ້ານ" required>
                    <a-input v-model:value="createForm.name" placeholder="ຊື່ຮ້ານ" />
                </a-form-item>
                <a-form-item label="ລາຍລະອຽດ">
                    <a-textarea v-model:value="createForm.description" placeholder="ລາຍລະອຽດຮ້ານ" :rows="3" />
                </a-form-item>
                <a-row :gutter="16">
                    <a-col :span="12">
                        <a-form-item label="ເບີໂທ">
                            <a-input v-model:value="createForm.phone" placeholder="020XXXXXXXX" />
                        </a-form-item>
                    </a-col>
                    <a-col :span="12">
                        <a-form-item label="ທີ່ຢູ່">
                            <a-input v-model:value="createForm.address" placeholder="ທີ່ຢູ່ຮ້ານ" />
                        </a-form-item>
                    </a-col>
                </a-row>
                <a-row :gutter="16">
                    <a-col :span="12">
                        <a-form-item label="ເວລາເປີດ">
                            <a-input v-model:value="createForm.openTime" placeholder="08:00" />
                        </a-form-item>
                    </a-col>
                    <a-col :span="12">
                        <a-form-item label="ເວລາປິດ">
                            <a-input v-model:value="createForm.closeTime" placeholder="22:00" />
                        </a-form-item>
                    </a-col>
                </a-row>
                <a-row :gutter="16">
                    <a-col :span="12">
                        <a-form-item label="ຄ່າຈັດສົ່ງ (ກີບ)">
                            <a-input-number v-model:value="createForm.deliveryFee" :min="0" style="width: 100%;" />
                        </a-form-item>
                    </a-col>
                    <a-col :span="12">
                        <a-form-item label="ຍອດຂັ້ນຕ່ຳ (ກີບ)">
                            <a-input-number v-model:value="createForm.minOrderAmount" :min="0" style="width: 100%;" />
                        </a-form-item>
                    </a-col>
                </a-row>
            </a-form>
        </a-modal>
    </div>
</template>

<script setup lang="ts">
import { PlusOutlined, ShopOutlined, AppstoreOutlined, ShoppingCartOutlined, TeamOutlined } from '@ant-design/icons-vue'
import { message } from 'ant-design-vue'

definePageMeta({
    middleware: 'auth',
})

const api = useApi()
const authStore = useAuthStore()

const loading = ref(false)
const saving = ref(false)
const stores = ref<any[]>([])
const merchants = ref<any[]>([])
const groupedData = ref<any[]>([])
const selectedMerchantId = ref<string>('')
const showCreateModal = ref(false)

const createForm = reactive({
    merchantId: '' as string,
    name: '',
    description: '',
    phone: '',
    address: '',
    openTime: '',
    closeTime: '',
    deliveryFee: 0,
    minOrderAmount: 0,
})

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

const openCreateModal = () => {
    // Pre-select merchant if filtered
    if (selectedMerchantId.value) {
        createForm.merchantId = selectedMerchantId.value
    }
    showCreateModal.value = true
}

const handleCreate = async () => {
    if (!createForm.name) {
        message.error('ກະລຸນາປ້ອນຊື່ຮ້ານ')
        return
    }

    if (authStore.isAdmin && !createForm.merchantId) {
        message.error('ກະລຸນາເລືອກ Merchant')
        return
    }

    saving.value = true
    try {
        await api.post('/api/stores', createForm)
        message.success('ສ້າງຮ້ານສຳເລັດ')
        showCreateModal.value = false
        Object.assign(createForm, {
            merchantId: '',
            name: '',
            description: '',
            phone: '',
            address: '',
            openTime: '',
            closeTime: '',
            deliveryFee: 0,
            minOrderAmount: 0,
        })
        fetchStores()
    } catch (error: any) {
        message.error(error.data?.message || 'ເກີດຂໍ້ຜິດພາດ')
    } finally {
        saving.value = false
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
</style>
