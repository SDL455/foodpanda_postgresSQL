<template>
    <div>
        <!-- Back Button & Header -->
        <div class="page-header">
            <a-space>
                <a-button @click="$router.push('/stores')">
                    <ArrowLeftOutlined /> ກັບຄືນ
                </a-button>
                <h1 v-if="store">{{ store.name }}</h1>
            </a-space>
            <a-space v-if="store">
                <a-button type="primary" @click="showEditModal = true">
                    <EditOutlined /> ແກ້ໄຂ
                </a-button>
            </a-space>
        </div>

        <a-spin :spinning="loading">
            <!-- Store Not Found -->
            <div v-if="!loading && !store" class="card">
                <div class="empty-state">
                    <ShopOutlined class="empty-icon" />
                    <h3>ບໍ່ພົບຮ້ານຄ້າ</h3>
                    <p>ຮ້ານຄ້ານີ້ບໍ່ມີຢູ່ໃນລະບົບ ຫຼື ທ່ານບໍ່ມີສິດເຂົ້າເຖິງ</p>
                    <a-button type="primary" @click="$router.push('/stores')">ກັບຄືນໄປລາຍການຮ້ານ</a-button>
                </div>
            </div>

            <template v-if="store">
                <!-- Store Cover & Info -->
                <div class="store-detail-header">
                    <div class="store-cover-large"
                        :style="{ backgroundImage: store.coverImage ? `url(${store.coverImage})` : 'linear-gradient(135deg, #f5f5f5 0%, #e0e0e0 100%)' }">
                        <div class="store-cover-overlay">
                            <div class="store-logo" v-if="store.logo">
                                <img :src="store.logo" :alt="store.name" />
                            </div>
                            <div class="store-logo store-logo-placeholder" v-else>
                                <ShopOutlined />
                            </div>
                            <div class="store-header-info">
                                <h2>{{ store.name }}</h2>
                                <a-tag :color="store.isActive ? 'green' : 'red'">
                                    {{ store.isActive ? 'ເປີດ' : 'ປິດ' }}
                                </a-tag>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Stats -->
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-icon primary">
                            <AppstoreOutlined />
                        </div>
                        <div class="stat-value">{{ store._count?.products || 0 }}</div>
                        <div class="stat-label">ສິນຄ້າ</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon success">
                            <ShoppingCartOutlined />
                        </div>
                        <div class="stat-value">{{ store._count?.orders || 0 }}</div>
                        <div class="stat-label">ຄຳສັ່ງຊື້</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon warning">
                            <StarOutlined />
                        </div>
                        <div class="stat-value">{{ store._count?.reviews || 0 }}</div>
                        <div class="stat-label">ລີວິວ</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon info">
                            <TagsOutlined />
                        </div>
                        <div class="stat-value">{{ store.categories?.length || 0 }}</div>
                        <div class="stat-label">ໝວດໝູ່</div>
                    </div>
                </div>

                <!-- Store Details -->
                <a-row :gutter="[16, 16]">
                    <a-col :xs="24" :lg="12">
                        <div class="card">
                            <div class="card-header">
                                <h2>ຂໍ້ມູນທົ່ວໄປ</h2>
                            </div>
                            <a-descriptions :column="1" bordered size="small">
                                <a-descriptions-item label="ລາຍລະອຽດ">
                                    {{ store.description || 'ບໍ່ມີລາຍລະອຽດ' }}
                                </a-descriptions-item>
                                <a-descriptions-item label="ທີ່ຢູ່">
                                    <EnvironmentOutlined /> {{ store.address || 'ບໍ່ມີທີ່ຢູ່' }}
                                </a-descriptions-item>
                                <a-descriptions-item label="ເບີໂທ">
                                    <PhoneOutlined /> {{ store.phone || 'ບໍ່ມີເບີໂທ' }}
                                </a-descriptions-item>
                                <a-descriptions-item label="ເວັບໄຊ">
                                    <GlobalOutlined />
                                    <a v-if="store.website" :href="store.website" target="_blank">{{ store.website
                                    }}</a>
                                    <span v-else>ບໍ່ມີເວັບໄຊ</span>
                                </a-descriptions-item>
                            </a-descriptions>
                        </div>
                    </a-col>

                    <a-col :xs="24" :lg="12">
                        <div class="card">
                            <div class="card-header">
                                <h2>ການຕັ້ງຄ່າຮ້ານ</h2>
                            </div>
                            <a-descriptions :column="1" bordered size="small">
                                <a-descriptions-item label="ເວລາເປີດ-ປິດ">
                                    <ClockCircleOutlined />
                                    {{ store.openTime || '00:00' }} - {{ store.closeTime || '23:59' }}
                                </a-descriptions-item>
                                <a-descriptions-item label="ຄ່າຈັດສົ່ງ">
                                    {{ formatCurrency(store.deliveryFee || 0) }}
                                </a-descriptions-item>
                                <a-descriptions-item label="ຍອດຂັ້ນຕ່ຳ">
                                    {{ formatCurrency(store.minOrderAmount || 0) }}
                                </a-descriptions-item>
                                <a-descriptions-item label="ເວລາກຽມອາຫານ (ນາທີ)">
                                    {{ store.estimatedPrepTime || 30 }} ນາທີ
                                </a-descriptions-item>
                            </a-descriptions>
                        </div>
                    </a-col>
                </a-row>

                <!-- Categories -->
                <div class="card" style="margin-top: 16px;">
                    <div class="card-header">
                        <h2>ໝວດໝູ່ສິນຄ້າ</h2>
                    </div>
                    <div v-if="store.categories?.length > 0">
                        <a-tag v-for="cat in store.categories" :key="cat.id" color="blue" style="margin: 4px;">
                            {{ cat.name }}
                        </a-tag>
                    </div>
                    <div v-else class="empty-state" style="padding: 20px;">
                        <p>ຍັງບໍ່ມີໝວດໝູ່</p>
                    </div>
                </div>

                <!-- Quick Actions -->
                <div class="card" style="margin-top: 16px;">
                    <div class="card-header">
                        <h2>ການຈັດການ</h2>
                    </div>
                    <a-space wrap>
                        <a-button type="primary" @click="$router.push(`/products?storeId=${store.id}`)">
                            <AppstoreOutlined /> ຈັດການສິນຄ້າ
                        </a-button>
                        <a-button @click="$router.push(`/orders?storeId=${store.id}`)">
                            <ShoppingCartOutlined /> ເບິ່ງຄຳສັ່ງຊື້
                        </a-button>
                        <a-button :type="store.isActive ? 'default' : 'primary'" danger @click="toggleStoreStatus">
                            <PoweroffOutlined />
                            {{ store.isActive ? 'ປິດຮ້ານ' : 'ເປີດຮ້ານ' }}
                        </a-button>
                    </a-space>
                </div>
            </template>
        </a-spin>

        <!-- Edit Modal -->
        <a-modal v-model:open="showEditModal" title="ແກ້ໄຂຂໍ້ມູນຮ້ານ" :confirm-loading="saving" width="700px"
            @ok="handleUpdate">
            <a-form v-if="store" :model="editForm" layout="vertical">
                <a-form-item label="ຊື່ຮ້ານ" required>
                    <a-input v-model:value="editForm.name" placeholder="ຊື່ຮ້ານ" />
                </a-form-item>
                <a-form-item label="ລາຍລະອຽດ">
                    <a-textarea v-model:value="editForm.description" placeholder="ລາຍລະອຽດຮ້ານ" :rows="3" />
                </a-form-item>
                <a-row :gutter="16">
                    <a-col :span="12">
                        <a-form-item label="ເບີໂທ">
                            <a-input v-model:value="editForm.phone" placeholder="020XXXXXXXX" />
                        </a-form-item>
                    </a-col>
                    <a-col :span="12">
                        <a-form-item label="ທີ່ຢູ່">
                            <a-input v-model:value="editForm.address" placeholder="ທີ່ຢູ່ຮ້ານ" />
                        </a-form-item>
                    </a-col>
                </a-row>
                <a-row :gutter="16">
                    <a-col :span="12">
                        <a-form-item label="ເວລາເປີດ">
                            <a-input v-model:value="editForm.openTime" placeholder="08:00" />
                        </a-form-item>
                    </a-col>
                    <a-col :span="12">
                        <a-form-item label="ເວລາປິດ">
                            <a-input v-model:value="editForm.closeTime" placeholder="22:00" />
                        </a-form-item>
                    </a-col>
                </a-row>
                <a-row :gutter="16">
                    <a-col :span="12">
                        <a-form-item label="ຄ່າຈັດສົ່ງ (ກີບ)">
                            <a-input-number v-model:value="editForm.deliveryFee" :min="0" style="width: 100%;" />
                        </a-form-item>
                    </a-col>
                    <a-col :span="12">
                        <a-form-item label="ຍອດຂັ້ນຕ່ຳ (ກີບ)">
                            <a-input-number v-model:value="editForm.minOrderAmount" :min="0" style="width: 100%;" />
                        </a-form-item>
                    </a-col>
                </a-row>
                <a-row :gutter="16">
                    <a-col :span="12">
                        <a-form-item label="ເວລາກຽມອາຫານ (ນາທີ)">
                            <a-input-number v-model:value="editForm.estimatedPrepTime" :min="1" style="width: 100%;" />
                        </a-form-item>
                    </a-col>
                    <a-col :span="12">
                        <a-form-item label="ສະຖານະຮ້ານ">
                            <a-switch v-model:checked="editForm.isActive" checked-children="ເປີດ"
                                un-checked-children="ປິດ" />
                        </a-form-item>
                    </a-col>
                </a-row>
                <a-form-item label="URL ຮູບປົກ">
                    <a-input v-model:value="editForm.coverImage" placeholder="https://..." />
                </a-form-item>
                <a-form-item label="URL ໂລໂກ້">
                    <a-input v-model:value="editForm.logo" placeholder="https://..." />
                </a-form-item>
            </a-form>
        </a-modal>
    </div>
</template>

<script setup lang="ts">
import {
    ArrowLeftOutlined,
    EditOutlined,
    ShopOutlined,
    AppstoreOutlined,
    ShoppingCartOutlined,
    StarOutlined,
    TagsOutlined,
    EnvironmentOutlined,
    PhoneOutlined,
    GlobalOutlined,
    ClockCircleOutlined,
    PoweroffOutlined,
} from '@ant-design/icons-vue'
import { message } from 'ant-design-vue'

definePageMeta({
    middleware: 'auth',
})

const route = useRoute()
const api = useApi()

const loading = ref(false)
const saving = ref(false)
const store = ref<any>(null)
const showEditModal = ref(false)

const editForm = reactive({
    name: '',
    description: '',
    phone: '',
    address: '',
    openTime: '',
    closeTime: '',
    deliveryFee: 0,
    minOrderAmount: 0,
    estimatedPrepTime: 30,
    isActive: true,
    coverImage: '',
    logo: '',
})

const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('lo-LA', {
        style: 'currency',
        currency: 'LAK',
        minimumFractionDigits: 0,
    }).format(amount)
}

const fetchStore = async () => {
    const storeId = route.params.id as string
    if (!storeId) return

    loading.value = true
    try {
        const result = await api.get<any>(`/api/stores/${storeId}`)
        store.value = result.data
        // Populate edit form
        if (store.value) {
            Object.assign(editForm, {
                name: store.value.name || '',
                description: store.value.description || '',
                phone: store.value.phone || '',
                address: store.value.address || '',
                openTime: store.value.openTime || '',
                closeTime: store.value.closeTime || '',
                deliveryFee: store.value.deliveryFee || 0,
                minOrderAmount: store.value.minOrderAmount || 0,
                estimatedPrepTime: store.value.estimatedPrepTime || 30,
                isActive: store.value.isActive ?? true,
                coverImage: store.value.coverImage || '',
                logo: store.value.logo || '',
            })
        }
    } catch (error: any) {
        console.error('Failed to fetch store:', error)
        message.error('ບໍ່ສາມາດໂຫຼດຂໍ້ມູນຮ້ານໄດ້')
    } finally {
        loading.value = false
    }
}

const handleUpdate = async () => {
    if (!editForm.name) {
        message.error('ກະລຸນາປ້ອນຊື່ຮ້ານ')
        return
    }

    saving.value = true
    try {
        const storeId = route.params.id as string
        await api.patch(`/api/stores/${storeId}`, editForm)
        message.success('ອັບເດດຂໍ້ມູນຮ້ານສຳເລັດ')
        showEditModal.value = false
        fetchStore()
    } catch (error: any) {
        message.error(error.data?.message || 'ເກີດຂໍ້ຜິດພາດ')
    } finally {
        saving.value = false
    }
}

const toggleStoreStatus = async () => {
    if (!store.value) return

    try {
        const storeId = route.params.id as string
        await api.patch(`/api/stores/${storeId}`, {
            isActive: !store.value.isActive,
        })
        message.success(store.value.isActive ? 'ປິດຮ້ານສຳເລັດ' : 'ເປີດຮ້ານສຳເລັດ')
        fetchStore()
    } catch (error: any) {
        message.error(error.data?.message || 'ເກີດຂໍ້ຜິດພາດ')
    }
}

onMounted(() => {
    fetchStore()
})
</script>

<style scoped>
.store-detail-header {
    margin-bottom: 24px;
}

.store-cover-large {
    height: 250px;
    background-size: cover;
    background-position: center;
    background-color: #f0f0f0;
    border-radius: 12px;
    position: relative;
    overflow: hidden;
}

.store-cover-overlay {
    position: absolute;
    bottom: 0;
    left: 0;
    right: 0;
    padding: 24px;
    background: linear-gradient(transparent, rgba(0, 0, 0, 0.7));
    display: flex;
    align-items: flex-end;
    gap: 16px;
}

.store-logo {
    width: 80px;
    height: 80px;
    border-radius: 12px;
    background: #fff;
    display: flex;
    align-items: center;
    justify-content: center;
    overflow: hidden;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.store-logo img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.store-logo-placeholder {
    font-size: 32px;
    color: #d70f64;
}

.store-header-info {
    flex: 1;
}

.store-header-info h2 {
    color: #fff;
    font-size: 28px;
    font-weight: 700;
    margin: 0 0 8px 0;
    text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
}
</style>
