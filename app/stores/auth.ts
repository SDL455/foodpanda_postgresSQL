import { defineStore } from 'pinia'

interface User {
  id: string
  email: string
  fullName?: string
  avatar?: string
  role: 'SUPER_ADMIN' | 'MERCHANT_OWNER' | 'MERCHANT_STAFF'
  merchant?: {
    id: string
    name: string
    stores?: any[]
  }
}

interface AuthState {
  token: string | null
  user: User | null
  isLoading: boolean
}

export const useAuthStore = defineStore('auth', {
  state: (): AuthState => ({
    token: null,
    user: null,
    isLoading: false,
  }),

  getters: {
    isLoggedIn: (state) => !!state.token && !!state.user,
    isAdmin: (state) => state.user?.role === 'SUPER_ADMIN',
    isMerchant: (state) => ['MERCHANT_OWNER', 'MERCHANT_STAFF'].includes(state.user?.role || ''),
  },

  actions: {
    async login(email: string, password: string) {
      this.isLoading = true
      try {
        const { data } = await $fetch<any>('/api/auth/login', {
          method: 'POST',
          body: { email, password },
        })

        this.token = data.token
        this.user = data.user

        // Save to localStorage
        if (import.meta.client) {
          localStorage.setItem('auth_token', data.token)
        }

        return { success: true }
      } catch (error: any) {
        return { 
          success: false, 
          error: error.data?.message || 'ເກີດຂໍ້ຜິດພາດ' 
        }
      } finally {
        this.isLoading = false
      }
    },

    async fetchUser() {
      if (!this.token) {
        // Try to get token from localStorage
        if (import.meta.client) {
          const savedToken = localStorage.getItem('auth_token')
          if (savedToken) {
            this.token = savedToken
          } else {
            return
          }
        } else {
          return
        }
      }

      try {
        const { data } = await $fetch<any>('/api/auth/me', {
          headers: {
            Authorization: `Bearer ${this.token}`,
          },
        })
        this.user = data
      } catch {
        this.logout()
      }
    },

    logout() {
      this.token = null
      this.user = null
      if (import.meta.client) {
        localStorage.removeItem('auth_token')
      }
      navigateTo('/login')
    },

    setToken(token: string) {
      this.token = token
      if (import.meta.client) {
        localStorage.setItem('auth_token', token)
      }
    },
  },

})

