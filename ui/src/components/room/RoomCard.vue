<template>
  <div class="room-card" :class="{ active: selected }" @click="$emit('select', room)">
    <div class="head">
      <span class="name">{{ room.roomName }}</span>
      <span class="cap">
        <i class="pi pi-users" /> {{ room.capacity }}
      </span>
    </div>
    <div class="meta" v-if="room.location">
      <i class="pi pi-map-marker" /> {{ room.location }}
    </div>
    <div class="amenities">
      <span v-if="room.hasVideo" class="amenity video">
        <i class="pi pi-video" /> 화상
      </span>
      <span v-if="room.hasPhone" class="amenity">
        <i class="pi pi-phone" /> 전화
      </span>
      <span v-for="a in amenityList" :key="a" class="amenity tag">{{ a }}</span>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import type { Room } from '@/composables/useRoom';

const props = defineProps<{ room: Room; selected?: boolean }>();
defineEmits<{ select: [room: Room] }>();

const amenityList = computed(() => {
  const csv = props.room.amenities || '';
  return csv
    .split(',')
    .map(s => s.trim())
    .filter(Boolean);
});
</script>

<style scoped>
.room-card {
  border: 1px solid var(--p-content-border-color, #e5e7eb);
  border-radius: 8px;
  padding: 0.75rem;
  margin-bottom: 0.5rem;
  cursor: pointer;
  background: var(--p-content-background, #fff);
  transition: border-color 0.15s, box-shadow 0.15s;
}
.room-card:hover { border-color: var(--p-primary-color, #6366f1); }
.room-card.active {
  border-color: var(--p-primary-color, #6366f1);
  box-shadow: 0 0 0 2px var(--p-primary-100, #e0e7ff);
}
.head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.35rem;
}
.name { font-weight: 600; font-size: 0.95rem; }
.cap {
  font-size: 0.8rem;
  color: var(--p-text-muted-color, #6b7280);
  display: inline-flex;
  align-items: center;
  gap: 0.25rem;
}
.meta {
  font-size: 0.78rem;
  color: var(--p-text-muted-color, #6b7280);
  margin-bottom: 0.4rem;
}
.amenities {
  display: flex;
  flex-wrap: wrap;
  gap: 0.3rem;
}
.amenity {
  font-size: 0.72rem;
  padding: 2px 6px;
  border-radius: 4px;
  background: var(--p-surface-100, #f3f4f6);
  color: var(--p-text-muted-color, #4b5563);
  display: inline-flex;
  align-items: center;
  gap: 0.2rem;
}
.amenity.video {
  background: var(--p-cyan-100, #cffafe);
  color: var(--p-cyan-700, #0e7490);
}
.amenity.tag { background: var(--p-surface-50, #f9fafb); }
</style>
