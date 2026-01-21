<template>
    <div>
        <div class="page-header">
            <h1>ຕັ້ງຄ່າ</h1>
        </div>

        <a-row :gutter="[24, 24]">
            <!-- Profile Section -->
            <a-col :xs="24" :lg="12">
                <div class="card">
                    <div class="card-header">
                        <h2>
                            <UserOutlined /> ຂໍ້ມູນໂປຣໄຟລ໌
                        </h2>
                    </div>

                    <div class="profile-header">
                        <a-avatar :src="authStore.user?.avatar" :size="80">
                            {{ authStore.user?.fullName?.charAt(0) || 'U' }}
                        </a-avatar>
                        <div class="profile-info">
                            <h3>{{ authStore.user?.fullName || 'ບໍ່ມີຊື່' }}</h3>
                            <p>{{ authStore.user?.email }}</p>
                            <a-tag :color="authStore.isAdmin ? 'red' : 'blue'">
                                {{ getRoleText(authStore.user?.role) }}
                            </a-tag>
                        </div>
                    </div>

                    <a-divider />

                    <a-form :model="profileForm" layout="vertical">
                        <a-form-item label="ຊື່-ນາມສະກຸນ">
                            <a-input v-model:value="profileForm.fullName" placeholder="ຊື່-ນາມສະກຸນ">
                                <template #prefix>
                                    <UserOutlined />
                                </template>
                            </a-input>
                        </a-form-item>

                        <a-form-item label="ເບີໂທ">
                            <a-input v-model:value="profileForm.phone" placeholder="020XXXXXXXX">
                                <template #prefix>
                                    <PhoneOutlined />
                                </template>
                            </a-input>
                        </a-form-item>

                        <a-form-item label="URL ຮູບໂປຣໄຟລ໌">
                            <a-input v-model:value="profileForm.avatar" placeholder="https://...">
                                <template #prefix>
                                    <PictureOutlined />
                                </template>
                            </a-input>
                        </a-form-item>

                        <a-button type="primary" :loading="savingProfile" @click="updateProfile">
                            <SaveOutlined /> ບັນທຶກຂໍ້ມູນ
                        </a-button>
                    </a-form>
                </div>
            </a-col>

            <!-- Password Section -->
            <a-col :xs="24" :lg="12">
                <div class="card">
                    <div class="card-header">
                        <h2>
                            <LockOutlined /> ປ່ຽນລະຫັດຜ່ານ
                        </h2>
                    </div>

                    <a-form :model="passwordForm" layout="vertical">
                        <a-form-item label="ລະຫັດຜ່ານປັດຈຸບັນ">
                            <a-input-password v-model:value="passwordForm.currentPassword"
                                placeholder="ລະຫັດຜ່ານປັດຈຸບັນ">
                                <template #prefix>
                                    <LockOutlined />
                                </template>
                            </a-input-password>
                        </a-form-item>

                        <a-form-item label="ລະຫັດຜ່ານໃໝ່">
                            <a-input-password v-model:value="passwordForm.newPassword" placeholder="ລະຫັດຜ່ານໃໝ່">
                                <template #prefix>
                                    <LockOutlined />
                                </template>
                            </a-input-password>
                        </a-form-item>

                        <a-form-item label="ຢືນຢັນລະຫັດຜ່ານໃໝ່">
                            <a-input-password v-model:value="passwordForm.confirmPassword"
                                placeholder="ຢືນຢັນລະຫັດຜ່ານໃໝ່">
                                <template #prefix>
                                    <LockOutlined />
                                </template>
                            </a-input-password>
                        </a-form-item>

                        <a-button type="primary" danger :loading="savingPassword" @click="changePassword">
                            <KeyOutlined /> ປ່ຽນລະຫັດຜ່ານ
                        </a-button>
                    </a-form>
                </div>
            </a-col>

            <!-- Merchant Info (For Merchant Users) -->
            <!-- <a-col v-if="!authStore.isAdmin && authStore.user?.merchant" :xs="24">
                <div class="card">
                    <div class="card-header">
                        <h2>
                            <ShopOutlined /> ຂໍ້ມູນທຸລະກິດ
                        </h2>
                    </div>

                    <a-descriptions :column="{ xs: 1, sm: 2, lg: 3 }" bordered>
                        <a-descriptions-item label="ຊື່ທຸລະກິດ">
                            {{ authStore.user.merchant.name }}
                        </a-descriptions-item>
                        <a-descriptions-item label="ຈຳນວນຮ້ານ">
                            {{ authStore.user.merchant.stores?.length || 0 }} ຮ້ານ
                        </a-descriptions-item>
                    </a-descriptions>

                    <a-divider v-if="(authStore.user.merchant.stores?.length ?? 0) > 0">ຮ້ານຂອງທ່ານ</a-divider>

                    <a-row v-if="(authStore.user.merchant.stores?.length ?? 0) > 0" :gutter="[16, 16]">
                        <a-col v-for="store in authStore.user.merchant.stores" :key="store.id" :xs="24" :sm="12"
                            :lg="8">
                            <a-card size="small">
                                <a-card-meta :title="store.name">
                                    <template #description>
                                        <a-space direction="vertical" size="small">
                                            <span>
                                                <EnvironmentOutlined /> {{ store.address || 'ບໍ່ມີທີ່ຢູ່' }}
                                            </span>
                                            <a-tag :color="store.isActive ? 'green' : 'red'">
                                                {{ store.isActive ? 'ເປີດ' : 'ປິດ' }}
                                            </a-tag>
                                        </a-space>
                                    </template>
                                </a-card-meta>
                            </a-card>
                        </a-col>
                    </a-row>
                </div>
            </a-col> -->

            <!-- Admin Store Overview -->
            <a-col v-if="authStore.isAdmin" :xs="24">
                <div class="card">
                    <div class="card-header">
                        <h2>
                            <ShopOutlined /> ພາບລວມຮ້ານຄ້າທັງໝົດ
                        </h2>
                        <a-button type="link" @click="$router.push('/stores')">
                            ເບິ່ງທັງໝົດ
                        </a-button>
                    </div>

                    <a-spin :spinning="loadingStores">
                        <a-table :columns="storeColumns" :data-source="allStores" :pagination="storePagination"
                            row-key="id" size="small" @change="handleStoreTableChange">
                            <template #bodyCell="{ column, record }">
                                <template v-if="column.key === 'store'">
                                    <a-space>
                                        <a-avatar :src="record.logo" shape="square" size="small">
                                            {{ record.name?.charAt(0) }}
                                        </a-avatar>
                                        <div>
                                            <div>{{ record.name }}</div>
                                            <div style="font-size: 12px; color: #666;">
                                                {{ record.merchant?.name }}
                                            </div>
                                        </div>
                                    </a-space>
                                </template>

                                <template v-if="column.key === 'status'">
                                    <a-tag :color="record.isActive ? 'green' : 'red'">
                                        {{ record.isActive ? 'ເປີດ' : 'ປິດ' }}
                                    </a-tag>
                                </template>

                                <template v-if="column.key === 'products'">
                                    {{ record._count?.products || 0 }}
                                </template>

                                <template v-if="column.key === 'orders'">
                                    {{ record._count?.orders || 0 }}
                                </template>

                                <template v-if="column.key === 'rating'">
                                    <a-rate :value="record.rating" disabled allow-half :count="5"
                                        style="font-size: 12px;" />
                                    <span style="margin-left: 8px;">{{ record.rating?.toFixed(1) || '0.0' }}</span>
                                </template>

                                <template v-if="column.key === 'actions'">
                                    <a-button size="small" @click="$router.push(`/stores/${record.id}`)">
                                        <EyeOutlined /> ເບິ່ງ
                                    </a-button>
                                </template>
                            </template>
                        </a-table>
                    </a-spin>
                </div>
            </a-col>

            <!-- System Info (Admin Only) -->
            <a-col v-if="authStore.isAdmin" :xs="24" :lg="12">
                <div class="card">
                    <div class="card-header">
                        <h2>
                            <SettingOutlined /> ຂໍ້ມູນລະບົບ
                        </h2>
                    </div>

                    <a-descriptions :column="1" bordered size="small">
                        <a-descriptions-item label="ລຸ້ນ">
                            v1.0.0
                        </a-descriptions-item>
                        <a-descriptions-item label="Framework">
                            Nuxt 3 + Vue 3
                        </a-descriptions-item>
                        <a-descriptions-item label="Database">
                            PostgreSQL + Prisma
                        </a-descriptions-item>
                        <a-descriptions-item label="UI Library">
                            Ant Design Vue
                        </a-descriptions-item>
                    </a-descriptions>
                </div>
            </a-col>

            <!-- App Config (Admin Only) -->
            <a-col v-if="authStore.isAdmin" :xs="24" :lg="12">
                <div class="card">
                    <div class="card-header">
                        <h2>
                            <ControlOutlined /> ການຕັ້ງຄ່າແອັບ
                        </h2>
                    </div>

                    <a-form layout="vertical">
                        <a-form-item label="ຊື່ແອັບພລິເຄຊັ່ນ">
                            <a-input value="Foodpanda Clone" disabled />
                        </a-form-item>
                        <a-form-item label="ສະກຸນເງິນ">
                            <a-select value="LAK" disabled style="width: 100%;">
                                <a-select-option value="LAK">LAK - ກີບລາວ</a-select-option>
                            </a-select>
                        </a-form-item>
                    </a-form>

                    <a-alert message="ການຕັ້ງຄ່າເຫຼົ່ານີ້ຈະສາມາດແກ້ໄຂໄດ້ໃນອະນາຄົດ" type="info" show-icon />
                </div>
            </a-col>
        </a-row>
    </div>
</template>

<script setup lang="ts">
import {
    UserOutlined,
    PhoneOutlined,
    PictureOutlined,
    SaveOutlined,
    LockOutlined,
    KeyOutlined,
    ShopOutlined,
    EnvironmentOutlined,
    EyeOutlined,
    SettingOutlined,
    ControlOutlined,
} from '@ant-design/icons-vue'
import { message } from 'ant-design-vue'

definePageMeta({
    middleware: 'auth',
})

const api = useApi()
const authStore = useAuthStore()

const savingProfile = ref(false)
const savingPassword = ref(false)
const loadingStores = ref(false)
const allStores = ref<any[]>([])

const profileForm = reactive({
    fullName: '',
    phone: '',
    avatar: '',
})

const passwordForm = reactive({
    currentPassword: '',
    newPassword: '',
    confirmPassword: '',
})

const storePagination = ref({
    current: 1,
    pageSize: 5,
    total: 0,
})

const storeColumns = [
    { title: 'ຮ້ານ', key: 'store' },
    { title: 'ສະຖານະ', key: 'status', width: 100 },
    { title: 'ສິນຄ້າ', key: 'products', width: 80 },
    { title: 'ຄຳສັ່ງ', key: 'orders', width: 80 },
    { title: 'ຄະແນນ', key: 'rating', width: 160 },
    { title: '', key: 'actions', width: 100 },
]

const getRoleText = (role: string | undefined) => {
    const texts: Record<string, string> = {
        SUPER_ADMIN: 'ຜູ້ດູແລລະບົບ',
        MERCHANT_OWNER: 'ເຈົ້າຂອງຮ້ານ',
        MERCHANT_STAFF: 'ພະນັກງານ',
    }
    return texts[role || ''] || role
}

const initProfileForm = () => {
    if (authStore.user) {
        profileForm.fullName = authStore.user.fullName || ''
        profileForm.phone = (authStore.user as any).phone || ''
        profileForm.avatar = authStore.user.avatar || ''
    }
}

const updateProfile = async () => {
    savingProfile.value = true
    try {
        await api.patch('/api/auth/profile', {
            fullName: profileForm.fullName,
            phone: profileForm.phone,
            avatar: profileForm.avatar,
        })
        message.success('ອັບເດດໂປຣໄຟລ໌ສຳເລັດ')
        // Refresh user data
        await authStore.fetchUser()
    } catch (error: any) {
        message.error(error.data?.message || 'ເກີດຂໍ້ຜິດພາດ')
    } finally {
        savingProfile.value = false
    }
}

const changePassword = async () => {
    if (!passwordForm.currentPassword) {
        message.error('ກະລຸນາປ້ອນລະຫັດຜ່ານປັດຈຸບັນ')
        return
    }
    if (!passwordForm.newPassword) {
        message.error('ກະລຸນາປ້ອນລະຫັດຜ່ານໃໝ່')
        return
    }
    if (passwordForm.newPassword.length < 6) {
        message.error('ລະຫັດຜ່ານໃໝ່ຕ້ອງມີຢ່າງໜ້ອຍ 6 ຕົວອັກສອນ')
        return
    }
    if (passwordForm.newPassword !== passwordForm.confirmPassword) {
        message.error('ລະຫັດຜ່ານໃໝ່ບໍ່ກົງກັນ')
        return
    }

    savingPassword.value = true
    try {
        await api.patch('/api/auth/profile', {
            currentPassword: passwordForm.currentPassword,
            newPassword: passwordForm.newPassword,
        })
        message.success('ປ່ຽນລະຫັດຜ່ານສຳເລັດ')
        // Reset form
        Object.assign(passwordForm, {
            currentPassword: '',
            newPassword: '',
            confirmPassword: '',
        })
    } catch (error: any) {
        message.error(error.data?.message || 'ເກີດຂໍ້ຜິດພາດ')
    } finally {
        savingPassword.value = false
    }
}

const fetchAllStores = async () => {
    if (!authStore.isAdmin) return

    loadingStores.value = true
    try {
        const result = await api.get<any>('/api/admin/stores', {
            page: storePagination.value.current,
            limit: storePagination.value.pageSize,
        })
        allStores.value = result.data.stores
        storePagination.value.total = result.data.pagination.total
    } catch (error) {
        console.error('Failed to fetch stores:', error)
    } finally {
        loadingStores.value = false
    }
}

const handleStoreTableChange = (pag: any) => {
    storePagination.value.current = pag.current
    storePagination.value.pageSize = pag.pageSize
    fetchAllStores()
}

onMounted(() => {
    initProfileForm()
    if (authStore.isAdmin) {
        fetchAllStores()
    }
})
</script>

<style scoped>
.profile-header {
    display: flex;
    align-items: center;
    gap: 16px;
}

.profile-info h3 {
    margin: 0 0 4px 0;
    font-size: 18px;
    font-weight: 600;
}

.profile-info p {
    margin: 0 0 8px 0;
    color: #666;
}
</style>
