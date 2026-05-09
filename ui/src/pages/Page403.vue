<template>
  <div class="forbidden-page">
    <i class="pi pi-lock" style="font-size: 4rem; color: var(--p-text-muted-color)" />
    <h2>{{ t('LBL_FORBIDDEN') }}</h2>
    <p>{{ t('LBL_FORBIDDEN_DETAIL') }}</p>
    <Button :label="t('BTN_GO_DASHBOARD')" icon="pi pi-home" @click="$router.push('/dashboard')" />
  </div>
</template>

<script setup lang="ts">
import Button from 'primevue/button';
import { useLabel } from '@/composables/useLabel';

const { t } = useLabel();
</script>

<style scoped>
.forbidden-page {
  display: flex; flex-direction: column; align-items: center; justify-content: center;
  min-height: 60vh; gap: 1rem; text-align: center;
}
.forbidden-page h2 { margin: 0; }
.forbidden-page p { color: var(--p-text-muted-color); }
</style>
