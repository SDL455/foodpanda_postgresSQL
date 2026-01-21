<template>
  <a-config-provider :theme="{ token: { colorPrimary: '#d70f64' } }">
    <div class="admin-layout">
      <!-- Sidebar -->
      <aside class="sidebar">
        <div class="logo">
          <h1>🐼 Foodpanda</h1>
        </div>

        <a-menu v-model:selectedKeys="selectedKeys" mode="inline" :items="menuItems" @click="handleMenuClick" />
      </aside>

      <!-- Main Content -->
      <div class="main-content">
        <!-- Header -->
        <header class="header">
          <div class="header-left">
            <a-breadcrumb>
              <a-breadcrumb-item>ໜ້າຫຼັກ</a-breadcrumb-item>
              <a-breadcrumb-item>{{ currentPageTitle }}</a-breadcrumb-item>
            </a-breadcrumb>
          </div>

          <div class="header-right">
            <a-tag v-if="authStore.isAdmin" color="red">Admin</a-tag>
            <a-tag v-else color="blue">{{ authStore.user?.merchant?.name || 'Merchant' }}</a-tag>

            <a-dropdown>
              <a-space style="cursor: pointer; margin-left: 12px;">
                <a-avatar :src="authStore.user?.avatar">
                  {{ authStore.user?.fullName?.charAt(0) || 'U' }}
                </a-avatar>
                <span>{{ authStore.user?.fullName || authStore.user?.email }}</span>
                <DownOutlined />
              </a-space>

              <template #overlay>
                <a-menu>
                  <a-menu-item key="profile">
                    <UserOutlined /> ໂປຣໄຟລ໌
                  </a-menu-item>
                  <a-menu-divider />
                  <a-menu-item key="logout" @click="handleLogout">
                    <LogoutOutlined /> ອອກຈາກລະບົບ
                  </a-menu-item>
                </a-menu>
              </template>
            </a-dropdown>
          </div>
        </header>

        <!-- Page Content -->
        <main class="content">
          <slot />
        </main>
      </div>
    </div>
  </a-config-provider>
</template>

<script setup lang="ts">
import {
  DashboardOutlined,
  ShopOutlined,
  AppstoreOutlined,
  ShoppingCartOutlined,
  TeamOutlined,
  CarOutlined,
  SettingOutlined,
  UserOutlined,
  LogoutOutlined,
  DownOutlined,
} from '@ant-design/icons-vue'
import type { MenuProps } from 'ant-design-vue'

const authStore = useAuthStore()
const route = useRoute()
const router = useRouter()

const selectedKeys = ref<string[]>([route.path])

// Watch route changes
watch(() => route.path, (path) => {
  selectedKeys.value = [path]
})

const currentPageTitle = computed(() => {
  const titles: Record<string, string> = {
    '/dashboard': 'Dashboard',
    '/admin/merchants': 'ຈັດການ Merchant',
    '/admin/riders': 'ຈັດການ Rider',
    '/admin/customers': 'ຈັດການລູກຄ້າ',
    '/stores': 'ຮ້ານຄ້າ',
    '/products': 'ສິນຄ້າ',
    '/orders': 'ຄຳສັ່ງຊື້',
    '/settings': 'ຕັ້ງຄ່າ',
  }
  return titles[route.path] || ''
})

// Menu items based on user role
const menuItems = computed<MenuProps['items']>(() => {
  const items: MenuProps['items'] = [
    {
      key: '/dashboard',
      icon: () => h(DashboardOutlined),
      label: 'Dashboard',
    },
  ]

  // Admin only menu
  if (authStore.isAdmin) {
    items.push(
      {
        key: 'admin',
        icon: () => h(SettingOutlined),
        label: 'ຈັດການລະບົບ',
        children: [
          {
            key: '/admin/merchants',
            icon: () => h(TeamOutlined),
            label: 'ເຈົ້າຂອງຮ້ານ',
          },
          {
            key: '/admin/riders',
            icon: () => h(CarOutlined),
            label: 'ຄົນສົ່ງ',
          },
          {
            key: '/admin/customers',
            icon: () => h(UserOutlined),
            label: 'ລູກຄ້າ',
          },
        ],
      },
      // Only admin can see stores menu
      {
        key: '/stores',
        icon: () => h(ShopOutlined),
        label: 'ຮ້ານຄ້າ',
      },
    )
  } else {
    // Merchant menu - Products and Orders
    items.push(
      {
        key: '/products',
        icon: () => h(AppstoreOutlined),
        label: 'ສິນຄ້າ',
      },
      {
        key: '/orders',
        icon: () => h(ShoppingCartOutlined),
        label: 'ຄຳສັ່ງຊື້',
      },
    )
  }

  // Settings for all users
  items.push(
    {
      type: 'divider',
    },
    {
      key: '/settings',
      icon: () => h(SettingOutlined),
      label: 'ຕັ້ງຄ່າ',
    }
  )

  return items
})

const handleMenuClick = ({ key }: { key: string }) => {
  if (key.startsWith('/')) {
    router.push(key)
  }
}

const handleLogout = () => {
  authStore.logout()
}
</script>
