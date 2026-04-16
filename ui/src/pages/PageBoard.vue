<template>
  <div class="page">
    <h2>게시판</h2>
    <div class="toolbar">
      <Select v-model="boardType" :options="boardTypes" optionLabel="label" optionValue="code"
              placeholder="게시판 선택" @change="load" />
      <InputText v-model="keyword" placeholder="검색어" @keyup.enter="load" />
      <Button label="검색" icon="pi pi-search" @click="load" />
      <Button label="글쓰기" icon="pi pi-plus" severity="success" @click="openForm()" />
    </div>
    <DataTable :value="posts" :rowHover="true" paginator :rows="20" :loading="loading"
               selectionMode="single" @rowSelect="onRowSelect" dataKey="postId">
      <Column field="postId" header="번호" style="width:70px" />
      <Column header="제목">
        <template #body="{ data }">
          <i v-if="data.isPinned === 'Y'" class="pi pi-bookmark-fill" style="color:var(--p-primary-color);margin-right:4px" />
          <span class="post-title-link">{{ data.title }}</span>
        </template>
      </Column>
      <Column field="boardType" header="분류" style="width:100px">
        <template #body="{ data }">
          <Tag :value="boardTypeLabel(data.boardType)" :severity="boardTypeSeverity(data.boardType)" />
        </template>
      </Column>
      <Column field="createdBy" header="작성자" style="width:100px" />
      <Column field="viewCount" header="조회" style="width:70px" />
      <Column header="작성일" style="width:140px">
        <template #body="{ data }">{{ formatDate(data.createdAt) }}</template>
      </Column>
    </DataTable>

    <!-- 상세 다이얼로그 -->
    <BoardDetailDialog v-if="selectedPostId"
                       v-model:visible="detailVisible"
                       :postId="selectedPostId"
                       @edit="openForm"
                       @deleted="onDeleted" />

    <!-- 작성/수정 다이얼로그 -->
    <BoardFormDialog v-model:visible="formVisible"
                     :editData="editData"
                     @saved="onSaved" />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useRoute } from 'vue-router';
import axios from 'axios';
import DataTable from 'primevue/datatable';
import Column from 'primevue/column';
import Button from 'primevue/button';
import InputText from 'primevue/inputtext';
import Select from 'primevue/select';
import Tag from 'primevue/tag';
import BoardDetailDialog from '@/components/board/BoardDetailDialog.vue';
import BoardFormDialog from '@/components/board/BoardFormDialog.vue';

const route = useRoute();

const boardTypes = [
  { code: '',        label: '전체' },
  { code: 'NOTICE',  label: '공지사항' },
  { code: 'GENERAL', label: '일반' },
  { code: 'FREE',    label: '자유게시판' },
  { code: 'DEPT',    label: '부서게시판' },
  { code: 'ARCHIVE', label: '자료실' }
];
const boardType = ref('');
const keyword = ref('');
const posts = ref<any[]>([]);
const loading = ref(false);

const selectedPostId = ref<number | null>(null);
const detailVisible = ref(false);
const formVisible = ref(false);
const editData = ref<any>(null);

const boardTypeLabels: Record<string, string> = {
  NOTICE: '공지', GENERAL: '일반', FREE: '자유', DEPT: '부서', ARCHIVE: '자료'
};
function boardTypeLabel(code: string) { return boardTypeLabels[code] || code; }
function boardTypeSeverity(code: string) {
  if (code === 'NOTICE') return 'danger';
  if (code === 'DEPT') return 'info';
  return 'secondary';
}

function formatDate(dt: string) {
  if (!dt) return '';
  return new Date(dt).toLocaleDateString('ko-KR', { month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit' });
}

async function load() {
  loading.value = true;
  try {
    const res = await axios.post('/api/dataset/search', {
      serviceName: 'board/searchPosts',
      datasets: { ds_search: { boardType: boardType.value || null, keyword: keyword.value || null } }
    });
    posts.value = res.data?.data?.ds_posts?.rows || [];
  } finally {
    loading.value = false;
  }
}

function onRowSelect(event: { data: any }) {
  selectedPostId.value = event.data.postId;
  detailVisible.value = true;
}

function openForm(post?: any) {
  detailVisible.value = false;
  editData.value = post || null;
  formVisible.value = true;
}

function onSaved() {
  load();
}

function onDeleted() {
  selectedPostId.value = null;
  load();
}

onMounted(() => {
  // URL 쿼리에서 postId 가 있으면 바로 상세 열기
  const qPostId = route.query.postId;
  if (qPostId) {
    selectedPostId.value = Number(qPostId);
    detailVisible.value = true;
  }
  load();
});
</script>

<style scoped>
.page { padding: 1.5rem; }
.toolbar { display: flex; gap: 0.5rem; margin-bottom: 1rem; align-items: center; flex-wrap: wrap; }
.post-title-link { cursor: pointer; }
.post-title-link:hover { text-decoration: underline; color: var(--p-primary-color); }
</style>
