<template>
    <div />
</template>

<script setup lang="ts">
definePageMeta({
    middleware: 'auth',
})

// Redirect to dashboard
navigateTo('/dashboard')
</script>
