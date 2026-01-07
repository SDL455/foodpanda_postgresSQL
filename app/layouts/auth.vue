<template>
  <a-config-provider :theme="{ token: { colorPrimary: '#d70f64' } }">
    <div class="login-page">
      <slot />
    </div>
  </a-config-provider>
</template>

