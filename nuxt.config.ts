// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2025-07-15',
  devtools: { enabled: true },

  modules: [
    '@pinia/nuxt',
    '@nuxt/icon',
    '@nuxt/image',
    '@nuxt/fonts',
    '@vueuse/nuxt',
  ],

  css: [
    '~/assets/css/main.scss',
  ],

  pinia: {
    storesDirs: ['./stores/**'],
  },

  runtimeConfig: {
    jwtSecret: process.env.JWT_SECRET || 'your-super-secret-jwt-key',
    jwtExpiresIn: process.env.JWT_EXPIRES_IN || '7d',
    firebaseProjectId: process.env.FIREBASE_PROJECT_ID,
    firebasePrivateKey: process.env.FIREBASE_PRIVATE_KEY,
    firebaseClientEmail: process.env.FIREBASE_CLIENT_EMAIL,
    public: {
      appName: 'Foodpanda',
      apiBase: '/api',
    },
  },

  nitro: {
    experimental: {
      asyncContext: true,
    },
  },

  app: {
    head: {
      title: 'Foodpanda - Admin Dashboard',
      meta: [
        { charset: 'utf-8' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' },
        { name: 'description', content: 'Foodpanda Admin Dashboard' },
      ],
      link: [
        { rel: 'icon', type: 'image/x-icon', href: '/favicon.ico' },
      ],
    },
  },
})
