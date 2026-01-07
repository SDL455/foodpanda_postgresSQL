<template>
    <div>
        <div class="page-header">
            <h1>ຈັດການ Rider</h1>
            <a-button type="primary" @click="showCreateModal = true">
                <PlusOutlined /> ເພີ່ມ Rider
            </a-button>
        </div>

        <!-- Filters -->
        <div class="card" style="margin-bottom: 16px;">
            <a-space>
                <a-input-search v-model:value="searchText" placeholder="ຄົ້ນຫາ..." style="width: 250px;"
                    @search="fetchRiders" />
                <a-select v-model:value="statusFilter" style="width: 150px;" placeholder="ສະຖານະ" allowClear
                    @change="fetchRiders">
                    <a-select-option value="AVAILABLE">ພ້ອມຮັບງານ</a-select-option>
                    <a-select-option value="BUSY">ກຳລັງສົ່ງ</a-select-option>
                    <a-select-option value="OFFLINE">ອອບໄລນ໌</a-select-option>
                </a-select>
            </a-space>
        </div>

        <!-- Table -->
        <div class="card">
            <a-table :columns="columns" :data-source="riders" :loading="loading" :pagination="pagination" row-key="id"
                @change="handleTableChange">
                <template #bodyCell="{ column, record }">
                    <template v-if="column.key === 'fullName'">
                        <a-space>
                            <a-avatar :src="record.avatar" size="small">
                                {{ record.fullName?.charAt(0) || 'R' }}
                            </a-avatar>
                            <span>{{ record.fullName }}</span>
                            <a-tag v-if="!record.isActive" color="red">ປິດໃຊ້ງານ</a-tag>
                            <a-tag v-if="record.isVerified" color="green">ຢືນຢັນແລ້ວ</a-tag>
                        </a-space>
                    </template>

                    <template v-if="column.key === 'contact'">
                        <div>{{ record.email }}</div>
                        <div style="color: #666;">{{ record.phone }}</div>
                    </template>

                    <template v-if="column.key === 'vehicle'">
                        {{ record.vehicleType || '-' }}
                        <div v-if="record.vehiclePlate" style="color: #666;">
                            {{ record.vehiclePlate }}
                        </div>
                    </template>

                    <template v-if="column.key === 'status'">
                        <a-tag :color="getStatusColor(record.status)">
                            {{ getStatusText(record.status) }}
                        </a-tag>
                    </template>

                    <template v-if="column.key === 'deliveries'">
                        {{ record._count?.deliveries || 0 }} ຄັ້ງ
                    </template>

                    <template v-if="column.key === 'actions'">
                        <a-space>
                            <a-button size="small" @click="editRider(record)">
                                <EditOutlined />
                            </a-button>
                            <a-button v-if="!record.isVerified" size="small" type="primary"
                                @click="verifyRider(record)">
                                ຢືນຢັນ
                            </a-button>
                            <a-button size="small" :danger="record.isActive" @click="toggleActive(record)">
                                {{ record.isActive ? 'ປິດ' : 'ເປີດ' }}
                            </a-button>
                        </a-space>
                    </template>
                </template>
            </a-table>
        </div>

        <!-- Create Modal -->
        <a-modal v-model:open="showCreateModal" title="ເພີ່ມ Rider ໃໝ່" :confirm-loading="saving" @ok="handleCreate">
            <a-form :model="createForm" layout="vertical">
                <a-form-item label="ຊື່-ນາມສະກຸນ" required>
                    <a-input v-model:value="createForm.fullName" placeholder="ຊື່-ນາມສະກຸນ" />
                </a-form-item>
                <a-form-item label="ອີເມລ" required>
                    <a-input v-model:value="createForm.email" placeholder="email@example.com" />
                </a-form-item>
                <a-form-item label="ເບີໂທ" required>
                    <a-input v-model:value="createForm.phone" placeholder="020XXXXXXXX" />
                </a-form-item>
                <a-form-item label="ລະຫັດຜ່ານ" required>
                    <a-input-password v-model:value="createForm.password" placeholder="ລະຫັດຜ່ານ" />
                </a-form-item>
                <a-form-item label="ປະເພດຍານພາຫະນະ">
                    <a-select v-model:value="createForm.vehicleType" placeholder="ເລືອກ">
                        <a-select-option value="ລົດຈັກ">ລົດຈັກ</a-select-option>
                        <a-select-option value="ລົດໃຫຍ່">ລົດໃຫຍ່</a-select-option>
                    </a-select>
                </a-form-item>
                <a-form-item label="ປ້າຍທະບຽນ">
                    <a-input v-model:value="createForm.vehiclePlate" placeholder="XX-XXXX" />
                </a-form-item>
            </a-form>
        </a-modal>

        <!-- Edit Modal -->
        <a-modal v-model:open="showEditModal" title="ແກ້ໄຂ Rider" :confirm-loading="saving" @ok="handleEdit">
            <a-form :model="editForm" layout="vertical">
                <a-form-item label="ຊື່-ນາມສະກຸນ" required>
                    <a-input v-model:value="editForm.fullName" placeholder="ຊື່-ນາມສະກຸນ" />
                </a-form-item>
                <a-form-item label="ເບີໂທ" required>
                    <a-input v-model:value="editForm.phone" placeholder="020XXXXXXXX" />
                </a-form-item>
                <a-form-item label="ປະເພດຍານພາຫະນະ">
                    <a-select v-model:value="editForm.vehicleType" placeholder="ເລືອກ">
                        <a-select-option value="ລົດຈັກ">ລົດຈັກ</a-select-option>
                        <a-select-option value="ລົດໃຫຍ່">ລົດໃຫຍ່</a-select-option>
                    </a-select>
                </a-form-item>
                <a-form-item label="ປ້າຍທະບຽນ">
                    <a-input v-model:value="editForm.vehiclePlate" placeholder="XX-XXXX" />
                </a-form-item>
            </a-form>
        </a-modal>
    </div>
</template>

<script setup lang="ts">
import { PlusOutlined, EditOutlined } from '@ant-design/icons-vue'
import { message } from 'ant-design-vue'

definePageMeta({
    middleware: 'auth',
})

const api = useApi()

const loading = ref(false)
const saving = ref(false)
const searchText = ref('')
const statusFilter = ref<string | undefined>(undefined)
const riders = ref<any[]>([])
const pagination = ref({
    current: 1,
    pageSize: 10,
    total: 0,
})

const showCreateModal = ref(false)
const showEditModal = ref(false)
const editingRider = ref<any>(null)

const createForm = reactive({
    fullName: '',
    email: '',
    phone: '',
    password: '',
    vehicleType: undefined as string | undefined,
    vehiclePlate: '',
})

const editForm = reactive({
    fullName: '',
    phone: '',
    vehicleType: undefined as string | undefined,
    vehiclePlate: '',
})

const columns = [
    { title: 'ຊື່', key: 'fullName' },
    { title: 'ຕິດຕໍ່', key: 'contact' },
    { title: 'ຍານພາຫະນະ', key: 'vehicle' },
    { title: 'ສະຖານະ', key: 'status' },
    { title: 'ຈັດສົ່ງ', key: 'deliveries' },
    { title: 'ການກະທຳ', key: 'actions', width: 200 },
]

const getStatusColor = (status: string) => {
    const colors: Record<string, string> = {
        AVAILABLE: 'green',
        BUSY: 'orange',
        OFFLINE: 'default',
    }
    return colors[status] || 'default'
}

const getStatusText = (status: string) => {
    const texts: Record<string, string> = {
        AVAILABLE: 'ພ້ອມຮັບງານ',
        BUSY: 'ກຳລັງສົ່ງ',
        OFFLINE: 'ອອບໄລນ໌',
    }
    return texts[status] || status
}

const fetchRiders = async () => {
    loading.value = true
    try {
        const result = await api.get<any>('/api/admin/riders', {
            page: pagination.value.current,
            limit: pagination.value.pageSize,
            search: searchText.value,
            status: statusFilter.value,
        })
        riders.value = result.data.riders
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
    fetchRiders()
}

const handleCreate = async () => {
    if (!createForm.fullName || !createForm.email || !createForm.phone || !createForm.password) {
        message.error('ກະລຸນາປ້ອນຂໍ້ມູນໃຫ້ຄົບ')
        return
    }

    saving.value = true
    try {
        await api.post('/api/admin/riders', createForm)
        message.success('ສ້າງ Rider ສຳເລັດ')
        showCreateModal.value = false
        Object.assign(createForm, {
            fullName: '',
            email: '',
            phone: '',
            password: '',
            vehicleType: undefined,
            vehiclePlate: '',
        })
        fetchRiders()
    } catch (error: any) {
        message.error(error.data?.message || 'ເກີດຂໍ້ຜິດພາດ')
    } finally {
        saving.value = false
    }
}

const editRider = (rider: any) => {
    editingRider.value = rider
    editForm.fullName = rider.fullName
    editForm.phone = rider.phone
    editForm.vehicleType = rider.vehicleType
    editForm.vehiclePlate = rider.vehiclePlate
    showEditModal.value = true
}

const handleEdit = async () => {
    saving.value = true
    try {
        await api.patch(`/api/admin/riders/${editingRider.value.id}`, editForm)
        message.success('ອັບເດດສຳເລັດ')
        showEditModal.value = false
        fetchRiders()
    } catch (error: any) {
        message.error(error.data?.message || 'ເກີດຂໍ້ຜິດພາດ')
    } finally {
        saving.value = false
    }
}

const verifyRider = async (rider: any) => {
    try {
        await api.patch(`/api/admin/riders/${rider.id}`, { isVerified: true })
        message.success('ຢືນຢັນ Rider ສຳເລັດ')
        fetchRiders()
    } catch (error: any) {
        message.error(error.data?.message || 'ເກີດຂໍ້ຜິດພາດ')
    }
}

const toggleActive = async (rider: any) => {
    try {
        await api.patch(`/api/admin/riders/${rider.id}`, { isActive: !rider.isActive })
        message.success('ອັບເດດສຳເລັດ')
        fetchRiders()
    } catch (error: any) {
        message.error(error.data?.message || 'ເກີດຂໍ້ຜິດພາດ')
    }
}

onMounted(() => {
    fetchRiders()
})
</script>
