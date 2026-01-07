<template>
    <div>
        <div class="page-header">
            <h1>ສິນຄ້າ</h1>
        </div>

        <!-- Select Store First -->
        <div class="card" style="margin-bottom: 16px;">
            <a-space>
                <span>ເລືອກຮ້ານ:</span>
                <a-select v-model:value="selectedStoreId" style="width: 250px;" placeholder="ເລືອກຮ້ານ"
                    @change="fetchProducts">
                    <a-select-option v-for="store in stores" :key="store.id" :value="store.id">
                        {{ store.name }}
                    </a-select-option>
                </a-select>
                <a-button v-if="selectedStoreId" type="primary" @click="showCreateModal = true">
                    <PlusOutlined /> ເພີ່ມສິນຄ້າ
                </a-button>
            </a-space>
        </div>

        <!-- Products Table -->
        <div v-if="selectedStoreId" class="card">
            <a-table :columns="columns" :data-source="products" :loading="loading" :pagination="pagination" row-key="id"
                @change="handleTableChange">
                <template #bodyCell="{ column, record }">
                    <template v-if="column.key === 'name'">
                        <a-space>
                            <a-avatar :src="record.image" shape="square">
                                {{ record.name?.charAt(0) }}
                            </a-avatar>
                            <div>
                                <div>{{ record.name }}</div>
                                <div style="font-size: 12px; color: #666;">
                                    {{ record.category?.name || 'ບໍ່ມີໝວດໝູ່' }}
                                </div>
                            </div>
                        </a-space>
                    </template>

                    <template v-if="column.key === 'price'">
                        {{ formatCurrency(record.basePrice) }}
                    </template>

                    <template v-if="column.key === 'stock'">
                        <a-tag :color="record.stock?.quantity > 10 ? 'green' : 'red'">
                            {{ record.stock?.quantity || 0 }}
                        </a-tag>
                    </template>

                    <template v-if="column.key === 'status'">
                        <a-switch :checked="record.isAvailable" checked-children="ເປີດ" un-checked-children="ປິດ"
                            @change="(checked: boolean) => toggleAvailable(record, checked)" />
                    </template>

                    <template v-if="column.key === 'actions'">
                        <a-space>
                            <a-button size="small" @click="editProduct(record)">
                                <EditOutlined />
                            </a-button>
                            <a-popconfirm title="ທ່ານແນ່ໃຈບໍ່ວ່າຕ້ອງການລຶບ?" @confirm="deleteProduct(record)">
                                <a-button size="small" danger>
                                    <DeleteOutlined />
                                </a-button>
                            </a-popconfirm>
                        </a-space>
                    </template>
                </template>
            </a-table>
        </div>

        <div v-else class="card">
            <div class="empty-state">
                <ShopOutlined class="empty-icon" />
                <h3>ກະລຸນາເລືອກຮ້ານກ່ອນ</h3>
                <p>ເລືອກຮ້ານເພື່ອເບິ່ງ ແລະ ຈັດການສິນຄ້າ</p>
            </div>
        </div>

        <!-- Create/Edit Modal -->
        <a-modal v-model:open="showCreateModal" :title="editingProduct ? 'ແກ້ໄຂສິນຄ້າ' : 'ເພີ່ມສິນຄ້າໃໝ່'"
            :confirm-loading="saving" width="600px" @ok="handleSave" @cancel="resetForm">
            <a-form :model="productForm" layout="vertical">
                <a-form-item label="ຊື່ສິນຄ້າ" required>
                    <a-input v-model:value="productForm.name" placeholder="ຊື່ສິນຄ້າ" />
                </a-form-item>
                <a-form-item label="ໝວດໝູ່">
                    <a-select v-model:value="productForm.categoryId" placeholder="ເລືອກໝວດໝູ່" allowClear>
                        <a-select-option v-for="cat in categories" :key="cat.id" :value="cat.id">
                            {{ cat.name }}
                        </a-select-option>
                    </a-select>
                </a-form-item>
                <a-form-item label="ລາຍລະອຽດ">
                    <a-textarea v-model:value="productForm.description" placeholder="ລາຍລະອຽດສິນຄ້າ" :rows="3" />
                </a-form-item>
                <a-row :gutter="16">
                    <a-col :span="12">
                        <a-form-item label="ລາຄາ (ກີບ)" required>
                            <a-input-number v-model:value="productForm.basePrice" :min="0" style="width: 100%;" />
                        </a-form-item>
                    </a-col>
                    <a-col :span="12">
                        <a-form-item label="SKU">
                            <a-input v-model:value="productForm.sku" placeholder="SKU" />
                        </a-form-item>
                    </a-col>
                </a-row>
                <a-form-item label="URL ຮູບພາບ">
                    <a-input v-model:value="productForm.image" placeholder="https://..." />
                </a-form-item>
            </a-form>
        </a-modal>
    </div>
</template>

<script setup lang="ts">
import { PlusOutlined, EditOutlined, DeleteOutlined, ShopOutlined } from '@ant-design/icons-vue'
import { message } from 'ant-design-vue'

definePageMeta({
    middleware: 'auth',
})

const api = useApi()

const loading = ref(false)
const saving = ref(false)
const stores = ref<any[]>([])
const selectedStoreId = ref<string | null>(null)
const products = ref<any[]>([])
const categories = ref<any[]>([])
const pagination = ref({
    current: 1,
    pageSize: 10,
    total: 0,
})

const showCreateModal = ref(false)
const editingProduct = ref<any>(null)

const productForm = reactive({
    name: '',
    description: '',
    basePrice: 0,
    categoryId: undefined as string | undefined,
    sku: '',
    image: '',
})

const columns = [
    { title: 'ສິນຄ້າ', key: 'name' },
    { title: 'ລາຄາ', key: 'price', width: 120 },
    { title: 'ສາງ', key: 'stock', width: 80 },
    { title: 'ສະຖານະ', key: 'status', width: 100 },
    { title: 'ການກະທຳ', key: 'actions', width: 120 },
]

const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('lo-LA', {
        style: 'currency',
        currency: 'LAK',
        minimumFractionDigits: 0,
    }).format(amount)
}

const fetchStores = async () => {
    try {
        const result = await api.get<any>('/api/stores')
        stores.value = result.data.stores
        if (stores.value.length > 0) {
            selectedStoreId.value = stores.value[0].id
            fetchProducts()
            fetchCategories()
        }
    } catch (error) {
        message.error('ບໍ່ສາມາດໂຫຼດຂໍ້ມູນໄດ້')
    }
}

const fetchProducts = async () => {
    if (!selectedStoreId.value) return

    loading.value = true
    try {
        const result = await api.get<any>(`/api/stores/${selectedStoreId.value}/products`, {
            page: pagination.value.current,
            limit: pagination.value.pageSize,
        })
        products.value = result.data.products
        pagination.value.total = result.data.pagination.total
        fetchCategories()
    } catch (error) {
        message.error('ບໍ່ສາມາດໂຫຼດຂໍ້ມູນໄດ້')
    } finally {
        loading.value = false
    }
}

const fetchCategories = async () => {
    if (!selectedStoreId.value) return

    try {
        const result = await api.get<any>(`/api/stores/${selectedStoreId.value}/categories`)
        categories.value = result.data
    } catch (error) {
        console.error('Failed to fetch categories')
    }
}

const handleTableChange = (pag: any) => {
    pagination.value.current = pag.current
    pagination.value.pageSize = pag.pageSize
    fetchProducts()
}

const resetForm = () => {
    editingProduct.value = null
    Object.assign(productForm, {
        name: '',
        description: '',
        basePrice: 0,
        categoryId: undefined,
        sku: '',
        image: '',
    })
}

const editProduct = (product: any) => {
    editingProduct.value = product
    Object.assign(productForm, {
        name: product.name,
        description: product.description || '',
        basePrice: product.basePrice,
        categoryId: product.categoryId,
        sku: product.sku || '',
        image: product.image || '',
    })
    showCreateModal.value = true
}

const handleSave = async () => {
    if (!productForm.name || !productForm.basePrice) {
        message.error('ກະລຸນາປ້ອນຂໍ້ມູນໃຫ້ຄົບ')
        return
    }

    saving.value = true
    try {
        if (editingProduct.value) {
            // Update - would need PATCH endpoint
            message.info('ຟັງຊັ່ນອັບເດດຍັງບໍ່ພ້ອມ')
        } else {
            await api.post(`/api/stores/${selectedStoreId.value}/products`, productForm)
            message.success('ສ້າງສິນຄ້າສຳເລັດ')
        }
        showCreateModal.value = false
        resetForm()
        fetchProducts()
    } catch (error: any) {
        message.error(error.data?.message || 'ເກີດຂໍ້ຜິດພາດ')
    } finally {
        saving.value = false
    }
}

const toggleAvailable = async (product: any, checked: boolean) => {
    // Would need PATCH endpoint
    message.info('ຟັງຊັ່ນນີ້ຍັງບໍ່ພ້ອມ')
}

const deleteProduct = async (product: any) => {
    // Would need DELETE endpoint
    message.info('ຟັງຊັ່ນລຶບຍັງບໍ່ພ້ອມ')
}

onMounted(() => {
    fetchStores()
})
</script>
