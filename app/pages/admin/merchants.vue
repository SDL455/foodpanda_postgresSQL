<template>
    <div>
        <div class="page-header">
            <h1>ຈັດການເຈົ້າຂອງຮ້ານ</h1>
            <a-button type="primary" @click="showCreateMerchantModal = true">
                <PlusOutlined /> ເພີ່ມເຈົ້າຂອງຮ້ານ
            </a-button>
        </div>

        <!-- Search -->
        <div class="card" style="margin-bottom: 16px;">
            <a-input-search v-model:value="searchText" placeholder="ຄົ້ນຫາເຈົ້າຂອງຮ້ານ..." style="max-width: 300px;"
                @search="fetchMerchants" />
        </div>

        <!-- Expandable Table -->
        <div class="card">
            <a-table :columns="columns" :data-source="merchants" :loading="loading" :pagination="pagination"
                row-key="id" :expand-column-width="60" @change="handleTableChange">
                <!-- Expandable Row - Shows Stores -->
                <template #expandedRowRender="{ record }">
                    <div class="expanded-content">
                        <div class="stores-header">
                            <h4>
                                <ShopOutlined /> ຮ້ານຄ້າຂອງ {{ record.name }}
                            </h4>
                            <a-button type="primary" size="small" @click="openAddStoreModal(record)">
                                <PlusOutlined /> ເພີ່ມຮ້ານ
                            </a-button>
                        </div>

                        <a-table v-if="record.stores?.length > 0" :columns="storeColumns" :data-source="record.stores"
                            :pagination="false" size="small" row-key="id">
                            <template #bodyCell="{ column, record: store }">
                                <template v-if="column.key === 'name'">
                                    <a-space>
                                        <a-avatar :src="store.logo" shape="square" size="small">
                                            {{ store.name?.charAt(0) }}
                                        </a-avatar>
                                        <span>{{ store.name }}</span>
                                        <a-tag v-if="!store.isActive" color="red" size="small">ປິດ</a-tag>
                                    </a-space>
                                </template>
                                <template v-if="column.key === 'address'">
                                    {{ store.address || '-' }}
                                </template>
                                <template v-if="column.key === 'products'">
                                    {{ store._count?.products || 0 }}
                                </template>
                                <template v-if="column.key === 'orders'">
                                    {{ store._count?.orders || 0 }}
                                </template>
                                <template v-if="column.key === 'storeActions'">
                                    <a-space>
                                        <a-button size="small" @click="$router.push(`/stores/${store.id}`)">
                                            <EyeOutlined />
                                        </a-button>
                                        <a-button size="small" @click="editStore(store, record)">
                                            <EditOutlined />
                                        </a-button>
                                    </a-space>
                                </template>
                            </template>
                        </a-table>

                        <a-empty v-else description="ຍັງບໍ່ມີຮ້ານຄ້າ">
                            <a-button type="primary" @click="openAddStoreModal(record)">
                                <PlusOutlined /> ເພີ່ມຮ້ານທຳອິດ
                            </a-button>
                        </a-empty>
                    </div>
                </template>

                <!-- Main Table Columns -->
                <template #bodyCell="{ column, record }">
                    <template v-if="column.key === 'name'">
                        <a-space>
                            <TeamOutlined />
                            <strong>{{ record.name }}</strong>
                            <a-tag v-if="!record.isActive" color="red">ປິດໃຊ້ງານ</a-tag>
                        </a-space>
                    </template>

                    <template v-if="column.key === 'stores'">
                        <a-badge :count="record._count?.stores || 0" :number-style="{ backgroundColor: '#d70f64' }">
                            <a-tag color="blue">
                                <ShopOutlined /> {{ record._count?.stores || 0 }} ຮ້ານ
                            </a-tag>
                        </a-badge>
                    </template>

                    <template v-if="column.key === 'users'">
                        <a-tag>
                            <UserOutlined /> {{ record._count?.users || 0 }} ຜູ້ໃຊ້
                        </a-tag>
                    </template>

                    <template v-if="column.key === 'createdAt'">
                        {{ formatDate(record.createdAt) }}
                    </template>

                    <template v-if="column.key === 'actions'">
                        <a-space>
                            <a-tooltip title="ເພີ່ມຮ້ານ">
                                <a-button size="small" type="primary" @click="openAddStoreModal(record)">
                                    <ShopOutlined />
                                </a-button>
                            </a-tooltip>
                            <a-tooltip title="ແກ້ໄຂ">
                                <a-button size="small" @click="editMerchant(record)">
                                    <EditOutlined />
                                </a-button>
                            </a-tooltip>
                            <a-button size="small" :type="record.isActive ? 'default' : 'primary'" danger
                                @click="toggleActive(record)">
                                {{ record.isActive ? 'ປິດ' : 'ເປີດ' }}
                            </a-button>
                        </a-space>
                    </template>
                </template>
            </a-table>
        </div>

        <!-- Create Merchant Modal -->
        <a-modal v-model:open="showCreateMerchantModal" title="ເພີ່ມເຈົ້າຂອງຮ້ານໃໝ່" :confirm-loading="saving"
            width="600px" @ok="handleCreateMerchant">
            <a-form :model="createMerchantForm" layout="vertical">
                <a-form-item label="ຊື່ທຸລະກິດ" required>
                    <a-input v-model:value="createMerchantForm.name" placeholder="ຊື່ທຸລະກິດ" />
                </a-form-item>

                <a-divider>ຂໍ້ມູນເຈົ້າຂອງ</a-divider>

                <a-row :gutter="16">
                    <a-col :span="12">
                        <a-form-item label="ອີເມລ" required>
                            <a-input v-model:value="createMerchantForm.ownerEmail" placeholder="email@example.com" />
                        </a-form-item>
                    </a-col>
                    <a-col :span="12">
                        <a-form-item label="ລະຫັດຜ່ານ" required>
                            <a-input-password v-model:value="createMerchantForm.ownerPassword"
                                placeholder="ລະຫັດຜ່ານ" />
                        </a-form-item>
                    </a-col>
                </a-row>

                <a-row :gutter="16">
                    <a-col :span="12">
                        <a-form-item label="ຊື່-ນາມສະກຸນ">
                            <a-input v-model:value="createMerchantForm.ownerFullName" placeholder="ຊື່-ນາມສະກຸນ" />
                        </a-form-item>
                    </a-col>
                    <a-col :span="12">
                        <a-form-item label="ເບີໂທ">
                            <a-input v-model:value="createMerchantForm.ownerPhone" placeholder="020XXXXXXXX" />
                        </a-form-item>
                    </a-col>
                </a-row>

                <a-divider>
                    <a-checkbox v-model:checked="createWithStore">ເພີ່ມຮ້ານພ້ອມກັນ</a-checkbox>
                </a-divider>

                <!-- Store Creation Section -->
                <template v-if="createWithStore">
                    <a-alert message="ກອກຂໍ້ມູນຮ້ານທຳອິດຂອງເຈົ້າຂອງຮ້ານນີ້" type="info" show-icon
                        style="margin-bottom: 16px;" />

                    <a-form-item label="ຊື່ຮ້ານ" required>
                        <a-input v-model:value="createMerchantForm.storeName" placeholder="ຊື່ຮ້ານ" />
                    </a-form-item>

                    <a-row :gutter="16">
                        <a-col :span="12">
                            <a-form-item label="ເບີໂທຮ້ານ">
                                <a-input v-model:value="createMerchantForm.storePhone" placeholder="020XXXXXXXX" />
                            </a-form-item>
                        </a-col>
                        <a-col :span="12">
                            <a-form-item label="ທີ່ຢູ່ຮ້ານ">
                                <a-input v-model:value="createMerchantForm.storeAddress" placeholder="ທີ່ຢູ່" />
                            </a-form-item>
                        </a-col>
                    </a-row>

                    <a-row :gutter="16">
                        <a-col :span="12">
                            <a-form-item label="ເວລາເປີດ">
                                <a-input v-model:value="createMerchantForm.storeOpenTime" placeholder="08:00" />
                            </a-form-item>
                        </a-col>
                        <a-col :span="12">
                            <a-form-item label="ເວລາປິດ">
                                <a-input v-model:value="createMerchantForm.storeCloseTime" placeholder="22:00" />
                            </a-form-item>
                        </a-col>
                    </a-row>
                </template>
            </a-form>
        </a-modal>

        <!-- Edit Merchant Modal -->
        <a-modal v-model:open="showEditMerchantModal" title="ແກ້ໄຂເຈົ້າຂອງຮ້ານ" :confirm-loading="saving"
            @ok="handleEditMerchant">
            <a-form :model="editMerchantForm" layout="vertical">
                <a-form-item label="ຊື່ທຸລະກິດ" required>
                    <a-input v-model:value="editMerchantForm.name" placeholder="ຊື່ທຸລະກິດ" />
                </a-form-item>
            </a-form>
        </a-modal>

        <!-- Add Store Modal -->
        <a-modal v-model:open="showAddStoreModal" :title="`ເພີ່ມຮ້ານໃຫ້ ${selectedMerchant?.name || ''}`"
            :confirm-loading="saving" width="600px" @ok="handleAddStore">
            <a-form :model="storeForm" layout="vertical">
                <a-form-item label="ຊື່ຮ້ານ" required>
                    <a-input v-model:value="storeForm.name" placeholder="ຊື່ຮ້ານ" />
                </a-form-item>
                <a-form-item label="ລາຍລະອຽດ">
                    <a-textarea v-model:value="storeForm.description" placeholder="ລາຍລະອຽດຮ້ານ" :rows="3" />
                </a-form-item>
                <a-row :gutter="16">
                    <a-col :span="12">
                        <a-form-item label="ເບີໂທ">
                            <a-input v-model:value="storeForm.phone" placeholder="020XXXXXXXX" />
                        </a-form-item>
                    </a-col>
                    <a-col :span="12">
                        <a-form-item label="ທີ່ຢູ່">
                            <a-input v-model:value="storeForm.address" placeholder="ທີ່ຢູ່ຮ້ານ" />
                        </a-form-item>
                    </a-col>
                </a-row>
                <a-row :gutter="16">
                    <a-col :span="12">
                        <a-form-item label="ເວລາເປີດ">
                            <a-input v-model:value="storeForm.openTime" placeholder="08:00" />
                        </a-form-item>
                    </a-col>
                    <a-col :span="12">
                        <a-form-item label="ເວລາປິດ">
                            <a-input v-model:value="storeForm.closeTime" placeholder="22:00" />
                        </a-form-item>
                    </a-col>
                </a-row>
                <a-row :gutter="16">
                    <a-col :span="12">
                        <a-form-item label="ຄ່າຈັດສົ່ງ (ກີບ)">
                            <a-input-number v-model:value="storeForm.deliveryFee" :min="0" style="width: 100%;" />
                        </a-form-item>
                    </a-col>
                    <a-col :span="12">
                        <a-form-item label="ຍອດຂັ້ນຕ່ຳ (ກີບ)">
                            <a-input-number v-model:value="storeForm.minOrderAmount" :min="0" style="width: 100%;" />
                        </a-form-item>
                    </a-col>
                </a-row>
            </a-form>
        </a-modal>

        <!-- Edit Store Modal -->
        <a-modal v-model:open="showEditStoreModal" title="ແກ້ໄຂຮ້ານ" :confirm-loading="saving" width="600px"
            @ok="handleEditStore">
            <a-form :model="editStoreForm" layout="vertical">
                <a-form-item label="ຊື່ຮ້ານ" required>
                    <a-input v-model:value="editStoreForm.name" placeholder="ຊື່ຮ້ານ" />
                </a-form-item>
                <a-form-item label="ລາຍລະອຽດ">
                    <a-textarea v-model:value="editStoreForm.description" placeholder="ລາຍລະອຽດຮ້ານ" :rows="3" />
                </a-form-item>
                <a-row :gutter="16">
                    <a-col :span="12">
                        <a-form-item label="ເບີໂທ">
                            <a-input v-model:value="editStoreForm.phone" placeholder="020XXXXXXXX" />
                        </a-form-item>
                    </a-col>
                    <a-col :span="12">
                        <a-form-item label="ທີ່ຢູ່">
                            <a-input v-model:value="editStoreForm.address" placeholder="ທີ່ຢູ່ຮ້ານ" />
                        </a-form-item>
                    </a-col>
                </a-row>
                <a-row :gutter="16">
                    <a-col :span="12">
                        <a-form-item label="ສະຖານະ">
                            <a-switch v-model:checked="editStoreForm.isActive" checked-children="ເປີດ"
                                un-checked-children="ປິດ" />
                        </a-form-item>
                    </a-col>
                </a-row>
            </a-form>
        </a-modal>
    </div>
</template>

<script setup lang="ts">
import {
    PlusOutlined,
    EditOutlined,
    ShopOutlined,
    TeamOutlined,
    UserOutlined,
    EyeOutlined,
} from '@ant-design/icons-vue'
import { message } from 'ant-design-vue'
import dayjs from 'dayjs'

definePageMeta({
    middleware: 'auth',
})

const api = useApi()

const loading = ref(false)
const saving = ref(false)
const searchText = ref('')
const merchants = ref<any[]>([])
const pagination = ref({
    current: 1,
    pageSize: 10,
    total: 0,
})

// Modals
const showCreateMerchantModal = ref(false)
const showEditMerchantModal = ref(false)
const showAddStoreModal = ref(false)
const showEditStoreModal = ref(false)

const createWithStore = ref(false)
const selectedMerchant = ref<any>(null)
const editingMerchant = ref<any>(null)
const editingStore = ref<any>(null)

// Forms
const createMerchantForm = reactive({
    name: '',
    ownerEmail: '',
    ownerPassword: '',
    ownerFullName: '',
    ownerPhone: '',
    // Store fields (optional)
    storeName: '',
    storePhone: '',
    storeAddress: '',
    storeOpenTime: '',
    storeCloseTime: '',
})

const editMerchantForm = reactive({
    name: '',
})

const storeForm = reactive({
    name: '',
    description: '',
    phone: '',
    address: '',
    openTime: '',
    closeTime: '',
    deliveryFee: 0,
    minOrderAmount: 0,
})

const editStoreForm = reactive({
    name: '',
    description: '',
    phone: '',
    address: '',
    isActive: true,
})

// Table columns
const columns = [
    { title: 'ຊື່ເຈົ້າຂອງຮ້ານ', key: 'name', dataIndex: 'name' },
    { title: 'ຮ້ານຄ້າ', key: 'stores', width: 120 },
    { title: 'ຜູ້ໃຊ້', key: 'users', width: 100 },
    { title: 'ວັນທີສ້າງ', key: 'createdAt', width: 120 },
    { title: 'ການກະທຳ', key: 'actions', width: 180 },
]

const storeColumns = [
    { title: 'ຊື່ຮ້ານ', key: 'name' },
    { title: 'ທີ່ຢູ່', key: 'address' },
    { title: 'ສິນຄ້າ', key: 'products', width: 80 },
    { title: 'ຄຳສັ່ງ', key: 'orders', width: 80 },
    { title: '', key: 'storeActions', width: 100 },
]

const formatDate = (date: string) => dayjs(date).format('DD/MM/YYYY')

// Fetch merchants with stores
const fetchMerchants = async () => {
    loading.value = true
    try {
        const result = await api.get<any>('/api/admin/merchants', {
            page: pagination.value.current,
            limit: pagination.value.pageSize,
            search: searchText.value,
            includeStores: 'true',
        })
        merchants.value = result.data.merchants
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
    fetchMerchants()
}

// Create Merchant (with optional store)
const handleCreateMerchant = async () => {
    if (!createMerchantForm.name || !createMerchantForm.ownerEmail || !createMerchantForm.ownerPassword) {
        message.error('ກະລຸນາປ້ອນຂໍ້ມູນໃຫ້ຄົບ')
        return
    }

    if (createWithStore.value && !createMerchantForm.storeName) {
        message.error('ກະລຸນາປ້ອນຊື່ຮ້ານ')
        return
    }

    saving.value = true
    try {
        // Create merchant
        const merchantResult = await api.post<any>('/api/admin/merchants', {
            name: createMerchantForm.name,
            ownerEmail: createMerchantForm.ownerEmail,
            ownerPassword: createMerchantForm.ownerPassword,
            ownerFullName: createMerchantForm.ownerFullName,
            ownerPhone: createMerchantForm.ownerPhone,
        })

        // If creating with store
        if (createWithStore.value && merchantResult.data?.id) {
            await api.post('/api/stores', {
                merchantId: merchantResult.data.id,
                name: createMerchantForm.storeName,
                phone: createMerchantForm.storePhone,
                address: createMerchantForm.storeAddress,
                openTime: createMerchantForm.storeOpenTime,
                closeTime: createMerchantForm.storeCloseTime,
            })
            message.success('ສ້າງເຈົ້າຂອງຮ້ານ ແລະ ຮ້ານສຳເລັດ')
        } else {
            message.success('ສ້າງເຈົ້າຂອງຮ້ານສຳເລັດ')
        }

        showCreateMerchantModal.value = false
        resetCreateMerchantForm()
        fetchMerchants()
    } catch (error: any) {
        message.error(error.data?.message || 'ເກີດຂໍ້ຜິດພາດ')
    } finally {
        saving.value = false
    }
}

const resetCreateMerchantForm = () => {
    Object.assign(createMerchantForm, {
        name: '',
        ownerEmail: '',
        ownerPassword: '',
        ownerFullName: '',
        ownerPhone: '',
        storeName: '',
        storePhone: '',
        storeAddress: '',
        storeOpenTime: '',
        storeCloseTime: '',
    })
    createWithStore.value = false
}

// Edit Merchant
const editMerchant = (merchant: any) => {
    editingMerchant.value = merchant
    editMerchantForm.name = merchant.name
    showEditMerchantModal.value = true
}

const handleEditMerchant = async () => {
    if (!editMerchantForm.name) {
        message.error('ກະລຸນາປ້ອນຊື່')
        return
    }

    saving.value = true
    try {
        await api.patch(`/api/admin/merchants/${editingMerchant.value.id}`, editMerchantForm)
        message.success('ອັບເດດສຳເລັດ')
        showEditMerchantModal.value = false
        fetchMerchants()
    } catch (error: any) {
        message.error(error.data?.message || 'ເກີດຂໍ້ຜິດພາດ')
    } finally {
        saving.value = false
    }
}

const toggleActive = async (merchant: any) => {
    try {
        await api.patch(`/api/admin/merchants/${merchant.id}`, {
            isActive: !merchant.isActive,
        })
        message.success('ອັບເດດສຳເລັດ')
        fetchMerchants()
    } catch (error: any) {
        message.error(error.data?.message || 'ເກີດຂໍ້ຜິດພາດ')
    }
}

// Add Store
const openAddStoreModal = (merchant: any) => {
    selectedMerchant.value = merchant
    Object.assign(storeForm, {
        name: '',
        description: '',
        phone: '',
        address: '',
        openTime: '',
        closeTime: '',
        deliveryFee: 0,
        minOrderAmount: 0,
    })
    showAddStoreModal.value = true
}

const handleAddStore = async () => {
    if (!storeForm.name) {
        message.error('ກະລຸນາປ້ອນຊື່ຮ້ານ')
        return
    }

    saving.value = true
    try {
        await api.post('/api/stores', {
            merchantId: selectedMerchant.value.id,
            ...storeForm,
        })
        message.success('ເພີ່ມຮ້ານສຳເລັດ')
        showAddStoreModal.value = false
        fetchMerchants()
    } catch (error: any) {
        message.error(error.data?.message || 'ເກີດຂໍ້ຜິດພາດ')
    } finally {
        saving.value = false
    }
}

// Edit Store
const editStore = (store: any, merchant: any) => {
    editingStore.value = store
    selectedMerchant.value = merchant
    Object.assign(editStoreForm, {
        name: store.name || '',
        description: store.description || '',
        phone: store.phone || '',
        address: store.address || '',
        isActive: store.isActive ?? true,
    })
    showEditStoreModal.value = true
}

const handleEditStore = async () => {
    if (!editStoreForm.name) {
        message.error('ກະລຸນາປ້ອນຊື່ຮ້ານ')
        return
    }

    saving.value = true
    try {
        await api.patch(`/api/stores/${editingStore.value.id}`, editStoreForm)
        message.success('ອັບເດດຮ້ານສຳເລັດ')
        showEditStoreModal.value = false
        fetchMerchants()
    } catch (error: any) {
        message.error(error.data?.message || 'ເກີດຂໍ້ຜິດພາດ')
    } finally {
        saving.value = false
    }
}

onMounted(() => {
    fetchMerchants()
})
</script>

<style scoped>
.expanded-content {
    padding: 16px;
    background: #fafafa;
    border-radius: 8px;
}

.stores-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 16px;
}

.stores-header h4 {
    margin: 0;
    font-size: 14px;
    font-weight: 600;
}
</style>
