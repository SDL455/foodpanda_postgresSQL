<template>
    <div>
        <div class="page-header">
            <h1>ຈັດການ Merchant</h1>
            <a-button type="primary" @click="showCreateModal = true">
                <PlusOutlined /> ເພີ່ມ Merchant
            </a-button>
        </div>

        <!-- Search -->
        <div class="card" style="margin-bottom: 16px;">
            <a-input-search v-model:value="searchText" placeholder="ຄົ້ນຫາ Merchant..." style="max-width: 300px;"
                @search="fetchMerchants" />
        </div>

        <!-- Table -->
        <div class="card">
            <a-table :columns="columns" :data-source="merchants" :loading="loading" :pagination="pagination"
                row-key="id" @change="handleTableChange">
                <template #bodyCell="{ column, record }">
                    <template v-if="column.key === 'name'">
                        <a-space>
                            <span>{{ record.name }}</span>
                            <a-tag v-if="!record.isActive" color="red">ປິດໃຊ້ງານ</a-tag>
                        </a-space>
                    </template>

                    <template v-if="column.key === 'stores'">
                        {{ record._count?.stores || 0 }} ຮ້ານ
                    </template>

                    <template v-if="column.key === 'users'">
                        {{ record._count?.users || 0 }} ຜູ້ໃຊ້
                    </template>

                    <template v-if="column.key === 'createdAt'">
                        {{ formatDate(record.createdAt) }}
                    </template>

                    <template v-if="column.key === 'actions'">
                        <a-space>
                            <a-button size="small" @click="editMerchant(record)">
                                <EditOutlined />
                            </a-button>
                            <a-button size="small" :type="record.isActive ? 'default' : 'primary'"
                                @click="toggleActive(record)">
                                {{ record.isActive ? 'ປິດ' : 'ເປີດ' }}
                            </a-button>
                        </a-space>
                    </template>
                </template>
            </a-table>
        </div>

        <!-- Create Modal -->
        <a-modal v-model:open="showCreateModal" title="ເພີ່ມ Merchant ໃໝ່" :confirm-loading="saving" @ok="handleCreate">
            <a-form :model="createForm" layout="vertical">
                <a-form-item label="ຊື່ Merchant" required>
                    <a-input v-model:value="createForm.name" placeholder="ຊື່ທຸລະກິດ" />
                </a-form-item>
                <a-divider>ຂໍ້ມູນເຈົ້າຂອງ</a-divider>
                <a-form-item label="ອີເມລ" required>
                    <a-input v-model:value="createForm.ownerEmail" placeholder="email@example.com" />
                </a-form-item>
                <a-form-item label="ລະຫັດຜ່ານ" required>
                    <a-input-password v-model:value="createForm.ownerPassword" placeholder="ລະຫັດຜ່ານ" />
                </a-form-item>
                <a-form-item label="ຊື່-ນາມສະກຸນ">
                    <a-input v-model:value="createForm.ownerFullName" placeholder="ຊື່-ນາມສະກຸນ" />
                </a-form-item>
                <a-form-item label="ເບີໂທ">
                    <a-input v-model:value="createForm.ownerPhone" placeholder="020XXXXXXXX" />
                </a-form-item>
            </a-form>
        </a-modal>

        <!-- Edit Modal -->
        <a-modal v-model:open="showEditModal" title="ແກ້ໄຂ Merchant" :confirm-loading="saving" @ok="handleEdit">
            <a-form :model="editForm" layout="vertical">
                <a-form-item label="ຊື່ Merchant" required>
                    <a-input v-model:value="editForm.name" placeholder="ຊື່ທຸລະກິດ" />
                </a-form-item>
            </a-form>
        </a-modal>
    </div>
</template>

<script setup lang="ts">
import { PlusOutlined, EditOutlined } from '@ant-design/icons-vue'
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

const showCreateModal = ref(false)
const showEditModal = ref(false)
const editingMerchant = ref<any>(null)

const createForm = reactive({
    name: '',
    ownerEmail: '',
    ownerPassword: '',
    ownerFullName: '',
    ownerPhone: '',
})

const editForm = reactive({
    name: '',
})

const columns = [
    { title: 'ຊື່ Merchant', key: 'name', dataIndex: 'name' },
    { title: 'ຮ້ານຄ້າ', key: 'stores' },
    { title: 'ຜູ້ໃຊ້', key: 'users' },
    { title: 'ວັນທີສ້າງ', key: 'createdAt' },
    { title: 'ການກະທຳ', key: 'actions', width: 150 },
]

const formatDate = (date: string) => dayjs(date).format('DD/MM/YYYY')

const fetchMerchants = async () => {
    loading.value = true
    try {
        const result = await api.get<any>('/api/admin/merchants', {
            page: pagination.value.current,
            limit: pagination.value.pageSize,
            search: searchText.value,
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

const handleCreate = async () => {
    if (!createForm.name || !createForm.ownerEmail || !createForm.ownerPassword) {
        message.error('ກະລຸນາປ້ອນຂໍ້ມູນໃຫ້ຄົບ')
        return
    }

    saving.value = true
    try {
        await api.post('/api/admin/merchants', createForm)
        message.success('ສ້າງ Merchant ສຳເລັດ')
        showCreateModal.value = false
        Object.assign(createForm, {
            name: '',
            ownerEmail: '',
            ownerPassword: '',
            ownerFullName: '',
            ownerPhone: '',
        })
        fetchMerchants()
    } catch (error: any) {
        message.error(error.data?.message || 'ເກີດຂໍ້ຜິດພາດ')
    } finally {
        saving.value = false
    }
}

const editMerchant = (merchant: any) => {
    editingMerchant.value = merchant
    editForm.name = merchant.name
    showEditModal.value = true
}

const handleEdit = async () => {
    if (!editForm.name) {
        message.error('ກະລຸນາປ້ອນຊື່')
        return
    }

    saving.value = true
    try {
        await api.patch(`/api/admin/merchants/${editingMerchant.value.id}`, editForm)
        message.success('ອັບເດດສຳເລັດ')
        showEditModal.value = false
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

onMounted(() => {
    fetchMerchants()
})
</script>
