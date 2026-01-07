<template>
    <div class="login-card">
        <div class="logo">
            <h1>🐼 Foodpanda</h1>
            <p>ເຂົ້າສູ່ລະບົບຈັດການ</p>
        </div>

        <a-form :model="formState" :rules="rules" layout="vertical" @finish="handleLogin">
            <a-form-item label="ອີເມລ" name="email">
                <a-input v-model:value="formState.email" size="large" placeholder="admin@foodpanda.com">
                    <template #prefix>
                        <MailOutlined />
                    </template>
                </a-input>
            </a-form-item>

            <a-form-item label="ລະຫັດຜ່ານ" name="password">
                <a-input-password v-model:value="formState.password" size="large" placeholder="ລະຫັດຜ່ານ">
                    <template #prefix>
                        <LockOutlined />
                    </template>
                </a-input-password>
            </a-form-item>

            <a-form-item>
                <a-button type="primary" html-type="submit" size="large" block :loading="authStore.isLoading">
                    ເຂົ້າສູ່ລະບົບ
                </a-button>
            </a-form-item>
        </a-form>
    </div>
</template>

<script setup lang="ts">
import { MailOutlined, LockOutlined } from '@ant-design/icons-vue'
import { message } from 'ant-design-vue'
import type { Rule } from 'ant-design-vue/es/form'

definePageMeta({
    layout: 'auth',
})

const authStore = useAuthStore()
const router = useRouter()

const formState = reactive({
    email: '',
    password: '',
})

const rules: Record<string, Rule[]> = {
    email: [
        { required: true, message: 'ກະລຸນາປ້ອນອີເມລ' },
        { type: 'email', message: 'ອີເມລບໍ່ຖືກຕ້ອງ' },
    ],
    password: [
        { required: true, message: 'ກະລຸນາປ້ອນລະຫັດຜ່ານ' },
        { min: 6, message: 'ລະຫັດຜ່ານຕ້ອງມີຢ່າງໜ້ອຍ 6 ຕົວອັກສອນ' },
    ],
}

const handleLogin = async () => {
    const result = await authStore.login(formState.email, formState.password)

    if (result.success) {
        message.success('ເຂົ້າສູ່ລະບົບສຳເລັດ')
        router.push('/dashboard')
    } else {
        message.error(result.error || 'ເກີດຂໍ້ຜິດພາດ')
    }
}
</script>
