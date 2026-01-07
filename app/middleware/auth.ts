export default defineNuxtRouteMiddleware(async (to) => {
  // Skip on server
  if (import.meta.server) return

  const authStore = useAuthStore()

  // Public routes
  const publicRoutes = ['/login']
  if (publicRoutes.includes(to.path)) {
    // Redirect to dashboard if already logged in
    if (authStore.isLoggedIn) {
      return navigateTo('/dashboard')
    }
    return
  }

  // Try to fetch user if we have token but no user
  if (authStore.token && !authStore.user) {
    await authStore.fetchUser()
  }

  // Redirect to login if not authenticated
  if (!authStore.isLoggedIn) {
    return navigateTo('/login')
  }

  // Admin only routes
  const adminRoutes = ['/admin']
  if (adminRoutes.some(r => to.path.startsWith(r)) && !authStore.isAdmin) {
    return navigateTo('/dashboard')
  }
})

