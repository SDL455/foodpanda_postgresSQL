<template>
    <div>
        <div class="page-header">
            <h1>ຮ້ານຄ້າ</h1>
            <a-button type="primary" @click="showCreateModal = true">
                <PlusOutlined /> ເພີ່ມຮ້ານ
            </a-button>
        </div>

        <!-- Store Cards -->
        <a-spin :spinning="loading">
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
                                :style="{ backgroundImage: `url(${store.coverImage || '/images/store-placeholder.jpg'})` }">
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
        </a-spin>

        <!-- Create Modal -->
        <a-modal v-model:open="showCreateModal" title="ສ້າງຮ້ານໃໝ່" :confirm-loading="saving" width="600px"
            @ok="handleCreate">
            <a-form :model="createForm" layout="vertical">
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
import { PlusOutlined, ShopOutlined, AppstoreOutlined, ShoppingCartOutlined } from '@ant-design/icons-vue'
import { message } from 'ant-design-vue'

definePageMeta({
    middleware: 'auth',
})

const api = useApi()

const loading = ref(false)
const saving = ref(false)
const stores = ref<any[]>([])
const showCreateModal = ref(false)

const createForm = reactive({
    name: '',
    description: '',
    phone: '',
    address: '',
    openTime: '',
    closeTime: '',
    deliveryFee: 0,
    minOrderAmount: 0,
})

const fetchStores = async () => {
    loading.value = true
    try {
        const result = await api.get<any>('/api/stores')
        stores.value = result.data.stores
    } catch (error) {
        message.error('ບໍ່ສາມາດໂຫຼດຂໍ້ມູນໄດ້')
    } finally {
        loading.value = false
    }
}

const handleCreate = async () => {
    if (!createForm.name) {
        message.error('ກະລຸນາປ້ອນຊື່ຮ້ານ')
        return
    }

    saving.value = true
    try {
        await api.post('/api/stores', createForm)
        message.success('ສ້າງຮ້ານສຳເລັດ')
        showCreateModal.value = false
        Object.assign(createForm, {
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
</style>
