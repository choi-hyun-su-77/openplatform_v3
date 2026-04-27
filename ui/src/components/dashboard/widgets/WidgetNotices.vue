<template>
  <div class="widget-body widget-notices">
    <header class="widget-header">
      <i class="pi pi-megaphone" />
      <span class="title">최근 공지</span>
    </header>
    <div v-if="loading" class="state loading">로딩...</div>
    <ul v-else-if="posts.length" class="notice-list">
      <li v-for="p in posts" :key="p.postId" @click="goDetail(p.postId)">
        <span class="title-text">{{ p.title }}</span>
        <span class="date">{{ formatDate(p.createdAt) }}</span>
      </li>
    </ul>
    <div v-else class="state empty">등록된 공지가 없습니다.</div>
    <a class="more-link" @click="goBoard">전체 공지 →</a>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import axios from 'axios';

defineProps<{ widgetCode: string; config?: any }>();

const router = useRouter();
const posts = ref<any[]>([]);
const loading = ref(false);

async function load() {
  loading.value = true;
  try {
    const res = await axios.post('/api/dataset/search', {
      serviceName: 'board/searchPosts',
      datasets: { ds_search: { boardType: 'NOTICE' } }
    });
    const rows = res.data?.data?.ds_posts?.rows || [];
    posts.value = rows.slice(0, 5);
  } catch (e) {
    console.warn('[WidgetNotices] failed', e);
    posts.value = [];
  } finally {
    loading.value = false;
  }
}

function formatDate(iso?: string) {
  if (!iso) return '';
  try {
    const d = new Date(iso);
    return `${d.getMonth() + 1}/${d.getDate()}`;
  } catch { return ''; }
}

function goDetail(postId: number) {
  router.push({ path: '/board', query: { postId } }).catch(() => {});
}
function goBoard() { router.push('/board').catch(() => {}); }

onMounted(load);
</script>

<style scoped>
.widget-notices { display: flex; flex-direction: column; height: 100%; }
.widget-header { display: flex; align-items: center; gap: 0.5rem; margin-bottom: 0.6rem; color: #475569; font-weight: 600; }
.state { flex: 1; display: flex; align-items: center; justify-content: center; color: #94a3b8; font-size: 0.9rem; }
.notice-list { flex: 1; list-style: none; padding: 0; margin: 0; overflow-y: auto; }
.notice-list li {
  display: flex; justify-content: space-between; gap: 0.5rem;
  padding: 0.35rem 0.2rem;
  border-bottom: 1px solid #f1f5f9;
  cursor: pointer;
  font-size: 0.88rem;
}
.notice-list li:hover { background: #f8fafc; }
.title-text { color: #1e293b; flex: 1; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.date { color: #94a3b8; font-size: 0.8rem; }
.more-link { font-size: 0.8rem; color: #3b82f6; cursor: pointer; align-self: flex-end; padding-top: 0.3rem; }
</style>
