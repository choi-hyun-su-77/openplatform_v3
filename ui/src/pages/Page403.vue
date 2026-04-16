<template>
  <div class="forbidden-page">
    <i class="pi pi-lock" style="font-size: 4rem; color: var(--p-text-muted-color)" />
    <h2>접근 권한이 없습니다</h2>
    <p>이 페이지에 대한 접근 권한이 없습니다. 관리자에게 문의하세요.</p>
    <Button label="대시보드로 이동" icon="pi pi-home" @click="$router.push('/dashboard')" />
  </div>
</template>

<script setup lang="ts">
import Button from 'primevue/button';
</script>

<style scoped>
.forbidden-page {
  display: flex; flex-direction: column; align-items: center; justify-content: center;
  min-height: 60vh; gap: 1rem; text-align: center;
}
.forbidden-page h2 { margin: 0; }
.forbidden-page p { color: var(--p-text-muted-color); }
</style>
