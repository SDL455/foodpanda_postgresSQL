<template>
    <div>
        <div class="page-header">
            <h1>ສິນຄ້າ</h1>
        </div>

        <!-- Select Store First -->
        <div class="card" style="margin-bottom: 16px">
            <a-space>
                <span>ເລືອກຮ້ານ:</span>
                <a-select v-model:value="selectedStoreId" style="width: 250px" placeholder="ເລືອກຮ້ານ"
                    @change="handleStoreChange">
                    <a-select-option v-for="store in stores" :key="store.id" :value="store.id">
                        {{ store.name }}
                    </a-select-option>
                </a-select>
            </a-space>
        </div>

        <template v-if="selectedStoreId">
            <!-- Categories Section -->
            <div class="card" style="margin-bottom: 16px">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
                    <h3 style="margin: 0;">
                        <FolderOutlined /> ໝວດໝູ່ສິນຄ້າ
                    </h3>
                    <a-button type="primary" size="small" @click="showCategoryModal = true">
                        <PlusOutlined /> ເພີ່ມໝວດໝູ່
                    </a-button>
                </div>

                <a-spin :spinning="loadingCategories">
                    <div v-if="categories.length === 0" style="text-align: center; padding: 20px; color: #888;">
                        ຍັງບໍ່ມີໝວດໝູ່
                    </div>
                    <a-space v-else wrap>
                        <a-tag v-for="cat in categories" :key="cat.id"
                            :color="selectedCategoryFilter === cat.id ? 'blue' : 'default'"
                            style="cursor: pointer; padding: 6px 12px; font-size: 14px;"
                            @click="filterByCategory(cat.id)">
                            {{ cat.name }} ({{ cat._count?.products || 0 }})
                            <a-popconfirm title="ລຶບໝວດໝູ່ນີ້?" @confirm="deleteCategory(cat.id)">
                                <CloseCircleOutlined style="margin-left: 6px;" @click.stop />
                            </a-popconfirm>
                        </a-tag>
                        <a-tag v-if="selectedCategoryFilter" color="red" style="cursor: pointer; padding: 6px 12px;"
                            @click="selectedCategoryFilter = null; fetchProducts()">
                            ລ້າງການກັ່ນຕອງ
                        </a-tag>
                    </a-space>
                </a-spin>
            </div>

            <!-- Products Section -->
            <div class="card">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
                    <h3 style="margin: 0;">
                        <AppstoreOutlined /> ລາຍການສິນຄ້າ
                    </h3>
                    <a-button type="primary" @click="openCreateProductModal">
                        <PlusOutlined /> ເພີ່ມສິນຄ້າ
                    </a-button>
                </div>

                <a-table :columns="columns" :data-source="products" :loading="loading" :pagination="pagination"
                    row-key="id" @change="handleTableChange">
                    <template #bodyCell="{ column, record }">
                        <template v-if="column.key === 'name'">
                            <a-space>
                                <a-avatar :src="record.image || record.images?.[0]?.url" shape="square">
                                    {{ record.name?.charAt(0) }}
                                </a-avatar>
                                <div>
                                    <div>{{ record.name }}</div>
                                    <div style="font-size: 12px; color: #666">
                                        {{ record.category?.name || "ບໍ່ມີໝວດໝູ່" }}
                                    </div>
                                </div>
                            </a-space>
                        </template>

                        <template v-if="column.key === 'images'">
                            <a-avatar-group :max-count="3" size="small">
                                <a-avatar v-for="(img, idx) in record.images" :key="idx" :src="img.url"
                                    shape="square" />
                            </a-avatar-group>
                            <span v-if="!record.images?.length" style="color: #999;">-</span>
                        </template>

                        <template v-if="column.key === 'price'">
                            {{ formatCurrency(record.basePrice) }}
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
        </template>

        <div v-else class="card">
            <div class="empty-state">
                <ShopOutlined class="empty-icon" />
                <h3>ກະລຸນາເລືອກຮ້ານກ່ອນ</h3>
                <p>ເລືອກຮ້ານເພື່ອເບິ່ງ ແລະ ຈັດການສິນຄ້າ</p>
            </div>
        </div>

        <!-- Create Category Modal -->
        <a-modal v-model:open="showCategoryModal" title="ເພີ່ມໝວດໝູ່ໃໝ່" :confirm-loading="savingCategory"
            @ok="handleCreateCategory">
            <a-form :model="categoryForm" layout="vertical">
                <a-form-item label="ຊື່ໝວດໝູ່" required>
                    <a-input v-model:value="categoryForm.name" placeholder="ຊື່ໝວດໝູ່" />
                </a-form-item>
                <a-form-item label="URL ຮູບພາບ">
                    <a-input v-model:value="categoryForm.image" placeholder="https://..." />
                </a-form-item>
                <a-form-item label="ລຳດັບສະແດງ">
                    <a-input-number v-model:value="categoryForm.sortOrder" :min="0" style="width: 100%;" />
                </a-form-item>
            </a-form>
        </a-modal>

        <!-- Create/Edit Product Modal -->
        <a-modal v-model:open="showCreateModal" :title="editingProduct ? 'ແກ້ໄຂສິນຄ້າ' : 'ເພີ່ມສິນຄ້າໃໝ່'"
            :confirm-loading="saving" width="700px" @ok="handleSave" @cancel="resetForm">
            <a-form :model="productForm" layout="vertical">
                <a-row :gutter="16">
                    <a-col :span="16">
                        <a-form-item label="ຊື່ສິນຄ້າ" required>
                            <a-input v-model:value="productForm.name" placeholder="ຊື່ສິນຄ້າ" />
                        </a-form-item>
                    </a-col>
                    <a-col :span="8">
                        <a-form-item label="ໝວດໝູ່">
                            <a-select v-model:value="productForm.categoryId" placeholder="ເລືອກໝວດໝູ່" allowClear>
                                <a-select-option v-for="cat in categories" :key="cat.id" :value="cat.id">
                                    {{ cat.name }}
                                </a-select-option>
                            </a-select>
                        </a-form-item>
                    </a-col>
                </a-row>

                <a-form-item label="ລາຍລະອຽດ">
                    <a-textarea v-model:value="productForm.description" placeholder="ລາຍລະອຽດສິນຄ້າ" :rows="3" />
                </a-form-item>

                <a-form-item label="ລາຄາ (ກີບ)" required>
                    <a-input-number v-model:value="productForm.basePrice" :min="0" style="width: 100%"
                        :formatter="(value: any) => `${value}`.replace(/\B(?=(\d{3})+(?!\d))/g, ',')"
                        :parser="(value: any) => value.replace(/\$\s?|(,*)/g, '')" />
                </a-form-item>

                <!-- Multiple Images Upload -->
                <a-form-item label="ຮູບພາບສິນຄ້າ">
                    <a-upload v-model:file-list="fileList" list-type="picture-card" :multiple="true"
                        :custom-request="handleUpload" :before-upload="beforeUpload" @remove="handleRemoveFile"
                        accept="image/*">
                        <div v-if="fileList.length < 10">
                            <PlusOutlined />
                            <div style="margin-top: 8px">ອັບໂຫຼດ</div>
                        </div>
                    </a-upload>
                    <div style="font-size: 12px; color: #888; margin-top: 4px;">
                        ສາມາດອັບໂຫຼດໄດ້ສູງສຸດ 10 ຮູບ (ຮູບທຳອິດຈະເປັນຮູບຫຼັກ)
                    </div>
                </a-form-item>

                <!-- Variants -->
                <!-- <a-divider>ຕົວເລືອກສິນຄ້າ (Variants)</a-divider>
                <div class="variant-list">
                    <div v-for="(variant, index) in productForm.variants" :key="index" class="variant-item">
                        <a-row :gutter="8" align="middle">
                            <a-col :span="12">
                                <a-input v-model:value="variant.name" placeholder="ຊື່ຕົວເລືອກ (ເຊັ່ນ: ໃຫຍ່, ນ້ອຍ)" />
                            </a-col>
                            <a-col :span="8">
                                <a-input-number v-model:value="variant.priceDelta" placeholder="ລາຄາເພີ່ມ/ຫຼຸດ"
                                    style="width: 100%;" />
                            </a-col>
                            <a-col :span="4">
                                <a-button danger type="text" @click="removeVariant(index)">
                                    <DeleteOutlined />
                                </a-button>
                            </a-col>
                        </a-row>
                    </div>
                    <a-button type="dashed" block @click="addVariant" style="margin-top: 8px;">
                        <PlusOutlined /> ເພີ່ມຕົວເລືອກ
                    </a-button>
                </div> -->
            </a-form>
        </a-modal>
    </div>
</template>

<script setup lang="ts">
import {
    PlusOutlined,
    EditOutlined,
    DeleteOutlined,
    ShopOutlined,
    FolderOutlined,
    AppstoreOutlined,
    CloseCircleOutlined,
    LoadingOutlined,
} from "@ant-design/icons-vue";
import { message } from "ant-design-vue";
import type { UploadProps, UploadFile } from "ant-design-vue";

definePageMeta({
    middleware: "auth",
});

const api = useApi();

const loading = ref(false);
const loadingCategories = ref(false);
const saving = ref(false);
const savingCategory = ref(false);
const stores = ref<any[]>([]);
const selectedStoreId = ref<string | null>(null);
const products = ref<any[]>([]);
const categories = ref<any[]>([]);
const selectedCategoryFilter = ref<string | null>(null);
const pagination = ref({
    current: 1,
    pageSize: 10,
    total: 0,
});

const showCreateModal = ref(false);
const showCategoryModal = ref(false);
const editingProduct = ref<any>(null);

const categoryForm = reactive({
    name: "",
    image: "",
    sortOrder: 0,
});

const productForm = reactive({
    name: "",
    description: "",
    basePrice: 0,
    categoryId: undefined as string | undefined,
    images: [] as string[],
    variants: [] as { name: string; priceDelta: number }[],
});

const fileList = ref<UploadFile[]>([]);
const uploading = ref(false);

const columns = [
    { title: "ສິນຄ້າ", key: "name" },
    { title: "ຮູບພາບ", key: "images", width: 120 },
    { title: "ລາຄາ", key: "price", width: 120 },
    { title: "ສະຖານະ", key: "status", width: 100 },
    { title: "ການກະທຳ", key: "actions", width: 120 },
];

// Get uploaded image URLs from fileList
const getUploadedImages = () => {
    return fileList.value
        .filter(file => file.status === 'done' && file.response?.url)
        .map(file => file.response.url as string);
};

// Upload handlers
const beforeUpload: UploadProps['beforeUpload'] = (file) => {
    const isImage = file.type?.startsWith('image/');
    if (!isImage) {
        message.error('ສາມາດອັບໂຫຼດໄດ້ສະເພາະໄຟລ໌ຮູບພາບເທົ່ານັ້ນ!');
        return false;
    }
    const isLt5M = file.size / 1024 / 1024 < 5;
    if (!isLt5M) {
        message.error('ຮູບພາບຕ້ອງມີຂະໜາດນ້ອຍກວ່າ 5MB!');
        return false;
    }
    return true;
};

const handleUpload: UploadProps['customRequest'] = async (options) => {
    const { file, onSuccess, onError, onProgress } = options;

    const formData = new FormData();
    formData.append('file', file as File);

    try {
        onProgress?.({ percent: 30 });

        const response = await fetch('/api/upload', {
            method: 'POST',
            body: formData,
        });

        onProgress?.({ percent: 70 });

        if (!response.ok) {
            throw new Error('Upload failed');
        }

        const data = await response.json();

        if (data.success && data.files?.length > 0) {
            onProgress?.({ percent: 100 });
            onSuccess?.(data.files[0]);
        } else {
            throw new Error('Upload failed');
        }
    } catch (error) {
        console.error('Upload error:', error);
        onError?.(error as Error);
        message.error('ອັບໂຫຼດຮູບພາບບໍ່ສຳເລັດ');
    }
};

const handleRemoveFile = (file: UploadFile) => {
    const index = fileList.value.indexOf(file);
    if (index > -1) {
        fileList.value.splice(index, 1);
    }
    return true;
};

const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat("lo-LA", {
        style: "currency",
        currency: "LAK",
        minimumFractionDigits: 0,
    }).format(amount);
};

const fetchStores = async () => {
    try {
        const result = await api.get<any>("/api/stores");
        stores.value = result.data.stores;
        if (stores.value.length > 0) {
            selectedStoreId.value = stores.value[0].id;
            handleStoreChange();
        }
    } catch (error) {
        message.error("ບໍ່ສາມາດໂຫຼດຂໍ້ມູນໄດ້");
    }
};

const handleStoreChange = () => {
    selectedCategoryFilter.value = null;
    fetchCategories();
    fetchProducts();
};

const fetchProducts = async () => {
    if (!selectedStoreId.value) return;

    loading.value = true;
    try {
        const params: any = {
            page: pagination.value.current,
            limit: pagination.value.pageSize,
        };
        if (selectedCategoryFilter.value) {
            params.categoryId = selectedCategoryFilter.value;
        }

        const result = await api.get<any>(
            `/api/stores/${selectedStoreId.value}/products`,
            params
        );
        products.value = result.data.products;
        pagination.value.total = result.data.pagination.total;
    } catch (error) {
        message.error("ບໍ່ສາມາດໂຫຼດຂໍ້ມູນໄດ້");
    } finally {
        loading.value = false;
    }
};

const fetchCategories = async () => {
    if (!selectedStoreId.value) return;

    loadingCategories.value = true;
    try {
        const result = await api.get<any>(
            `/api/stores/${selectedStoreId.value}/categories`
        );
        categories.value = result.data;
    } catch (error) {
        console.error("Failed to fetch categories");
    } finally {
        loadingCategories.value = false;
    }
};

const filterByCategory = (categoryId: string) => {
    if (selectedCategoryFilter.value === categoryId) {
        selectedCategoryFilter.value = null;
    } else {
        selectedCategoryFilter.value = categoryId;
    }
    pagination.value.current = 1;
    fetchProducts();
};

const handleTableChange = (pag: any) => {
    pagination.value.current = pag.current;
    pagination.value.pageSize = pag.pageSize;
    fetchProducts();
};

// Category functions
const handleCreateCategory = async () => {
    if (!categoryForm.name) {
        message.error("ກະລຸນາປ້ອນຊື່ໝວດໝູ່");
        return;
    }

    savingCategory.value = true;
    try {
        await api.post(`/api/stores/${selectedStoreId.value}/categories`, categoryForm);
        message.success("ສ້າງໝວດໝູ່ສຳເລັດ");
        showCategoryModal.value = false;
        Object.assign(categoryForm, { name: "", image: "", sortOrder: 0 });
        fetchCategories();
    } catch (error: any) {
        message.error(error.data?.message || "ເກີດຂໍ້ຜິດພາດ");
    } finally {
        savingCategory.value = false;
    }
};

const deleteCategory = async (categoryId: string) => {
    try {
        await api.delete(`/api/stores/${selectedStoreId.value}/categories/${categoryId}`);
        message.success("ລຶບໝວດໝູ່ສຳເລັດ");
        if (selectedCategoryFilter.value === categoryId) {
            selectedCategoryFilter.value = null;
        }
        fetchCategories();
        fetchProducts();
    } catch (error: any) {
        message.error(error.data?.message || "ເກີດຂໍ້ຜິດພາດ");
    }
};

// Product functions
const openCreateProductModal = () => {
    resetForm();
    showCreateModal.value = true;
};

const resetForm = () => {
    editingProduct.value = null;
    Object.assign(productForm, {
        name: "",
        description: "",
        basePrice: 0,
        categoryId: undefined,
        images: [],
        variants: [],
    });
    fileList.value = [];
};

const editProduct = (product: any) => {
    editingProduct.value = product;
    Object.assign(productForm, {
        name: product.name,
        description: product.description || "",
        basePrice: product.basePrice,
        categoryId: product.categoryId,
        images: product.images?.map((img: any) => img.url) || [],
        variants: product.variants?.map((v: any) => ({ name: v.name, priceDelta: v.priceDelta })) || [],
    });

    // Load existing images into fileList
    const existingImages: UploadFile[] = [];
    if (product.image) {
        existingImages.push({
            uid: 'main-image',
            name: 'ຮູບຫຼັກ',
            status: 'done',
            url: product.image,
            response: { url: product.image },
        });
    }
    product.images?.forEach((img: any, index: number) => {
        existingImages.push({
            uid: `image-${index}`,
            name: `ຮູບ ${index + 1}`,
            status: 'done',
            url: img.url,
            response: { url: img.url },
        });
    });
    fileList.value = existingImages;

    showCreateModal.value = true;
};

const addVariant = () => {
    productForm.variants.push({ name: "", priceDelta: 0 });
};

const removeVariant = (index: number) => {
    productForm.variants.splice(index, 1);
};

const handleSave = async () => {
    if (!productForm.name || !productForm.basePrice) {
        message.error("ກະລຸນາປ້ອນຂໍ້ມູນໃຫ້ຄົບ");
        return;
    }

    // Check if there are still uploading files
    const hasUploading = fileList.value.some(f => f.status === 'uploading');
    if (hasUploading) {
        message.warning("ກະລຸນາລໍຖ້າໃຫ້ຮູບພາບອັບໂຫຼດສຳເລັດກ່ອນ");
        return;
    }

    saving.value = true;
    try {
        const validVariants = productForm.variants.filter(v => v.name.trim() !== "");

        // Get all uploaded image URLs
        const uploadedImages = getUploadedImages();
        const mainImage = uploadedImages.length > 0 ? uploadedImages[0] : undefined;
        const additionalImages = uploadedImages.slice(1);

        const payload = {
            name: productForm.name,
            description: productForm.description,
            basePrice: productForm.basePrice,
            categoryId: productForm.categoryId || undefined,
            image: mainImage,
            images: additionalImages,
            variants: validVariants.length > 0 ? validVariants : undefined,
        };

        if (editingProduct.value) {
            await api.patch(`/api/stores/${selectedStoreId.value}/products/${editingProduct.value.id}`, payload);
            message.success("ອັບເດດສິນຄ້າສຳເລັດ");
        } else {
            await api.post(`/api/stores/${selectedStoreId.value}/products`, payload);
            message.success("ສ້າງສິນຄ້າສຳເລັດ");
        }
        showCreateModal.value = false;
        resetForm();
        fetchProducts();
    } catch (error: any) {
        message.error(error.data?.message || "ເກີດຂໍ້ຜິດພາດ");
    } finally {
        saving.value = false;
    }
};

const toggleAvailable = async (product: any, checked: boolean) => {
    try {
        await api.patch(`/api/stores/${selectedStoreId.value}/products/${product.id}`, {
            isAvailable: checked,
        });
        product.isAvailable = checked;
        message.success("ອັບເດດສະຖານະສຳເລັດ");
    } catch (error: any) {
        message.error(error.data?.message || "ເກີດຂໍ້ຜິດພາດ");
    }
};

const deleteProduct = async (product: any) => {
    try {
        await api.delete(`/api/stores/${selectedStoreId.value}/products/${product.id}`);
        message.success("ລຶບສິນຄ້າສຳເລັດ");
        fetchProducts();
    } catch (error: any) {
        message.error(error.data?.message || "ເກີດຂໍ້ຜິດພາດ");
    }
};

onMounted(() => {
    fetchStores();
});
</script>

<style scoped>
.variant-list {
    border: 1px dashed #d9d9d9;
    border-radius: 8px;
    padding: 12px;
    background: #fafafa;
}

.variant-item {
    margin-bottom: 8px;
}

.variant-item:last-child {
    margin-bottom: 0;
}

:deep(.ant-upload-list-picture-card) {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
}

:deep(.ant-upload-list-picture-card .ant-upload-list-item) {
    margin: 0;
}
</style>
