import Antd from 'ant-design-vue'
import 'ant-design-vue/dist/reset.css'

export default defineNuxtPlugin({
  name: 'antd',
  parallel: true,
  setup(nuxtApp) {
    nuxtApp.vueApp.use(Antd)
  },
})

