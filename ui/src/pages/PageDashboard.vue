<template>
  <div class="dashboard">
    <h2>대시보드</h2>
    <p class="greeting">안녕하세요, {{ auth.user?.userName || '사용자' }}님</p>
    <div class="dashboard-grid">
      <div class="card">
        <h3><i class="pi pi-calendar" /> 오늘 일정</h3>
        <ul v-if="todayEvents.length">
          <li v-for="ev in todayEvents" :key="ev.eventId">
            {{ ev.title }} <small>{{ ev.startDt }}</small>
          </li>
        </ul>
        <p v-else class="empty">등록된 일정이 없습니다.</p>
      </div>
      <div class="card">
        <h3><i class="pi pi-file-edit" /> 미결 결재</h3>
        <p class="metric">{{ pendingCount }} 건</p>
        <router-link to="/approval">결재함으로 →</router-link>
      </div>
      <div class="card">
        <h3><i class="pi pi-comment" /> 최근 공지</h3>
        <ul v-if="posts.length">
          <li v-for="p in posts" :key="p.postId">{{ p.title }}</li>
        </ul>
        <p v-else class="empty">공지 없음</p>
      </div>
      <div class="card">
        <h3><i class="pi pi-bell" /> 읽지 않은 알림</h3>
        <p class="metric">{{ unreadCount }} 건</p>
      </div>
      <div class="card">
        <h3><i class="pi pi-send" /> 메신저 DM</h3>
        <p class="metric">{{ messengerUnread }} 건</p>
        <router-link to="/messenger">메신저 →</router-link>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import axios from 'axios';
import { useAuthStore } from '@/store/auth';

const auth = useAuthStore();
const todayEvents = ref<any[]>([]);
const posts = ref<any[]>([]);
const pendingCount = ref(0);
const unreadCount = ref(0);
const messengerUnread = ref(0);

async function loadDashboard() {
  try {
    const today = await axios.post('/api/dataset/search', {
      serviceName: 'calendar/searchToday',
      datasets: { ds_search: { ownerId: 10 } }
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

  try {
    const notif = await axios.post('/api/dataset/search', {
      serviceName: 'notification/searchList',
      datasets: { ds_search: { recipientId: 10, unreadOnly: true } }
    });
    unreadCount.value = notif.data?.data?.ds_unreadCount?.count || 0;
  } catch (e) { console.warn('notifications failed', e); }

  try {
    const inbox = await axios.post('/api/dataset/search', {
      serviceName: 'approval/searchInbox',
      datasets: { ds_search: { boxType: 'PENDING' } }
    });
    pendingCount.value = inbox.data?.data?.ds_inbox?.rows?.length || 0;
  } catch (e) { console.warn('pending failed', e); }
}

onMounted(loadDashboard);
</script>

<style scoped>
.dashboard { padding: 1.5rem; }
.dashboard h2 { margin: 0 0 0.25rem 0; }
.greeting { color: #64748b; margin-bottom: 1.5rem; }
.metric { font-size: 2rem; font-weight: 700; color: #3b82f6; margin: 0.5rem 0; }
.card h3 { margin: 0 0 0.75rem 0; display: flex; align-items: center; gap: 0.5rem; color: #334155; }
.card ul { list-style: none; padding: 0; margin: 0; }
.card ul li { padding: 0.25rem 0; border-bottom: 1px solid #f1f5f9; }
.card .empty { color: #94a3b8; font-size: 0.9rem; }
</style>
