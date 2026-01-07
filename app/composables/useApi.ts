export const useApi = () => {
  const authStore = useAuthStore()

  const api = async <T>(
    url: string,
    options: {
      method?: 'GET' | 'POST' | 'PUT' | 'PATCH' | 'DELETE'
      body?: any
      query?: Record<string, any>
    } = {}
  ): Promise<{ data: T; success: boolean; message?: string }> => {
    const headers: Record<string, string> = {}

    if (authStore.token) {
      headers.Authorization = `Bearer ${authStore.token}`
    }

    try {
      const response = await $fetch<any>(url, {
        method: options.method || 'GET',
        body: options.body,
        query: options.query,
        headers,
      })

      return {
        data: response.data,
        success: response.success,
        message: response.message,
      }
    } catch (error: any) {
      // Handle 401 Unauthorized
      if (error.statusCode === 401) {
        authStore.logout()
      }

      throw error
    }
  }

  return {
    get: <T>(url: string, query?: Record<string, any>) =>
      api<T>(url, { method: 'GET', query }),

    post: <T>(url: string, body?: any) =>
      api<T>(url, { method: 'POST', body }),

    put: <T>(url: string, body?: any) =>
      api<T>(url, { method: 'PUT', body }),

    patch: <T>(url: string, body?: any) =>
      api<T>(url, { method: 'PATCH', body }),

    delete: <T>(url: string) =>
      api<T>(url, { method: 'DELETE' }),
  }
}

