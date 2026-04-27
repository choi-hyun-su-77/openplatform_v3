<template>
  <div class="widget-body widget-rooms">
    <header class="widget-header">
      <i class="pi pi-video" />
      <span class="title">다가오는 회의</span>
      <span class="count" v-if="bookings.length">{{ bookings.length }}</span>
    </header>
    <div v-if="loading" class="state loading">로딩...</div>
    <ul v-else-if="bookings.length" class="room-list">
      <li v-for="b in bookings" :key="b.bookingId" @click="go">
        <div class="row1">
          <span class="room-name">{{ b.roomName }}</span>
          <span class="time">{{ formatTime(b.startAt) }}</span>
        </div>
        <div class="row2">
          <span class="b-title">{{ b.title }}</span>
        </div>
      </li>
    </ul>
    <div v-else class="state empty">예정된 회의가 없습니다.</div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { useRoom, type Booking } from '@/composables/useRoom';

defineProps<{ widgetCode: string; config?: any }>();

const router = useRouter();
const room = useRoom();
const bookings = ref<Booking[]>([]);
const loading = ref(false);

async function load() {
  loading.value = true;
  try {
    const all = await room.searchMyBookings('UPCOMING');
    bookings.value = (all || []).slice(0, 3);
  } catch (e) {
    console.warn('[WidgetMyRooms] failed', e);
    bookings.value = [];
  } finally {
    loading.value = false;
  }
}

function formatTime(iso?: string) {
  if (!iso) return '';
  try {
    const d = new Date(iso);
    const today = new Date();
    const sameDay = d.toDateString() === today.toDateString();
    const tm = `${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}`;
    return sameDay ? `오늘 ${tm}` : `${d.getMonth() + 1}/${d.getDate()} ${tm}`;
  } catch { return ''; }
}

function go() { router.push('/room').catch(() => {}); }

onMounted(load);
</script>

<style scoped>
.widget-rooms { display: flex; flex-direction: column; height: 100%; }
.widget-header { display: flex; align-items: center; gap: 0.5rem; margin-bottom: 0.6rem; color: #475569; font-weight: 600; }
.count { margin-left: auto; background: #6366f1; color: white; border-radius: 999px; padding: 0 0.45rem; font-size: 0.7rem; font-weight: 700; }
.state { flex: 1; display: flex; align-items: center; justify-content: center; color: #94a3b8; font-size: 0.9rem; }
.room-list { flex: 1; list-style: none; padding: 0; margin: 0; overflow-y: auto; }
.room-list li {
  padding: 0.4rem 0.2rem;
  border-bottom: 1px solid #f1f5f9;
  cursor: pointer;
}
.room-list li:hover { background: #f8fafc; }
.room-list .row1 { display: flex; justify-content: space-between; align-items: center; }
.room-list .room-name { color: #1e293b; font-weight: 600; font-size: 0.88rem; }
.room-list .time { color: #6366f1; font-weight: 600; font-size: 0.82rem; }
.room-list .row2 { margin-top: 0.1rem; }
.room-list .b-title { color: #64748b; font-size: 0.82rem; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; display: block; }
</style>
