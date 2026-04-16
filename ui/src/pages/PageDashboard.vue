<template>
  <div class="dashboard">
    <h2>대시보드</h2>
    <p class="greeting">안녕하세요, {{ auth.user?.userName || '사용자' }}님</p>
    <div class="dashboard-grid">
      <div class="card clickable" @click="router.push('/calendar')">
        <h3><i class="pi pi-calendar" /> 오늘 일정</h3>
        <ul v-if="todayEvents.length">
          <li v-for="ev in todayEvents" :key="ev.eventId">
            {{ ev.title }} <small>{{ ev.startDt }}</small>
          </li>
        </ul>
        <p v-else class="empty">등록된 일정이 없습니다.</p>
      </div>
      <div class="card clickable" @click="router.push('/approval')">
        <h3><i class="pi pi-file-edit" /> 미결 결재</h3>
        <p class="metric">{{ pendingCount }} 건</p>
        <span class="card-link">결재함으로 →</span>
      </div>
      <div class="card clickable" @click="router.push('/board')">
        <h3><i class="pi pi-comment" /> 최근 공지</h3>
        <ul v-if="posts.length">
          <li v-for="p in posts" :key="p.postId">{{ p.title }}</li>
        </ul>
        <p v-else class="empty">공지 없음</p>
      </div>
      <div class="card">
        <h3><i class="pi pi-bell" /> 읽지 않은 알림</h3>
        <p class="metric">{{ notifStore.unreadCount }} 건</p>
      </div>
      <div class="card clickable" @click="router.push('/messenger')">
        <h3><i class="pi pi-send" /> 메신저 DM</h3>
        <p class="metric">{{ messengerUnread }} 건</p>
        <span class="card-link">메신저 →</span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import axios from 'axios';
import { useAuthStore } from '@/store/auth';
import { useNotificationStore } from '@/store/notification';

const router = useRouter();
const auth = useAuthStore();
const notifStore = useNotificationStore();
const todayEvents = ref<any[]>([]);
const posts = ref<any[]>([]);
const pendingCount = ref(0);
const messengerUnread = ref(0);

async function loadDashboard() {
  if (!auth.user) { await auth.loadUserInfo(); }
  const employeeId = auth.user?.employeeId;
  const employeeNo = auth.user?.employeeNo || auth.user?.userId || '';

  try {
    const today = await axios.post('/api/dataset/search', {
      serviceName: 'calendar/searchToday',
      datasets: { ds_search: { ownerId: employeeId } }
    });
    todayEvents.value = today.data?.data?.ds_todayEvents?.rows || [];
  } catch (e) { console.warn('today events failed', e); }

  try {
    const board = await axios.post('/api/dataset/search', {
      serviceName: 'board/searchPosts',
      datasets: { ds_search: { boardType: 'NOTICE' } }
    });
    posts.value = (board.data?.data?.ds_posts?.rows || []).slice(0, 5);
  } catch (e) { console.warn('posts failed', e); }

  // 알림 카운트는 notification store 에서 SSE 로 자동 갱신됨
  if (employeeId) {
    notifStore.loadRecent(employeeId);
  }

  try {
    const res = await axios.post('/api/dataset/search', {
      serviceName: 'approval/countPending',
      datasets: { ds_search: {} }
    });
    const rows = res.data?.data?.ds_count?.rows || [];
    pendingCount.value = rows[0]?.count || 0;
  } catch (e) { console.warn('pending count failed', e); }
}

onMounted(loadDashboard);
</script>

<style scoped>
.dashboard { padding: 1.5rem; }
.dashboard h2 { margin: 0 0 0.25rem 0; }
.greeting { color: #64748b; margin-bottom: 1.5rem; }
.dashboard-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 1rem;
}
.card {
  background: var(--p-content-background);
  border: 1px solid var(--p-content-border-color);
  border-radius: 8px;
  padding: 1.25rem;
}
.card.clickable { cursor: pointer; transition: box-shadow 0.2s; }
.card.clickable:hover { box-shadow: 0 2px 8px rgba(0,0,0,0.08); }
.metric { font-size: 2rem; font-weight: 700; color: #3b82f6; margin: 0.5rem 0; }
.card h3 { margin: 0 0 0.75rem 0; display: flex; align-items: center; gap: 0.5rem; color: #334155; }
.card ul { list-style: none; padding: 0; margin: 0; }
.card ul li { padding: 0.25rem 0; border-bottom: 1px solid #f1f5f9; }
.card .empty { color: #94a3b8; font-size: 0.9rem; }
.card-link { font-size: 0.85rem; color: var(--p-primary-color); }
</style>
