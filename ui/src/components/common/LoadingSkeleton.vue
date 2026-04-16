<template>
  <div class="loading-skeleton">
    <div v-for="i in rows" :key="i" class="skeleton-row">
      <Skeleton v-for="j in columns" :key="j" :width="colWidth" height="1.2rem" />
    </div>
  </div>
</template>

<script setup lang="ts">
import Skeleton from 'primevue/skeleton';

withDefaults(defineProps<{
  rows?: number;
  columns?: number;
  colWidth?: string;
}>(), {
  rows: 5,
  columns: 4,
  colWidth: '100%'
});
</script>

<style scoped>
.loading-skeleton { display: flex; flex-direction: column; gap: 0.75rem; padding: 1rem; }
.skeleton-row { display: flex; gap: 1rem; }
</style>
