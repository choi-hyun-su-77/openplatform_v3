<template>
  <div class="page">
    <h2>{{ t('LBL_PAGE_BOARD') }}</h2>
    <div class="toolbar">
      <Select v-model="boardType" :options="boardTypes" optionLabel="label" optionValue="code"
              :placeholder="t('PH_BOARD_SELECT')" @change="load" />
      <InputText v-model="keyword" :placeholder="t('PH_BOARD_SEARCH')" @keyup.enter="load" />
      <Button :label="t('BTN_SEARCH')" icon="pi pi-search" @click="load" />
      <Button :label="t('BTN_NEW_POST')" icon="pi pi-plus" severity="success" @click="openForm()" />
    </div>
    <DataTable :value="posts" :rowHover="true" paginator :rows="20" :loading="loading"
               selectionMode="single" @rowSelect="onRowSelect" dataKey="postId">
      <Column field="postId" :header="t('COL_BOARD_NO')" style="width:70px" />
      <Column :header="t('COL_BOARD_TITLE')">
        <template #body="{ data }">
          <i v-if="data.isPinned === 'Y'" class="pi pi-bookmark-fill" style="color:var(--p-primary-color);margin-right:4px" />
          <span class="post-title-link">{{ data.title }}</span>
        </template>
      </Column>
      <Column field="boardType" :header="t('COL_BOARD_TYPE')" style="width:100px">
        <template #body="{ data }">
          <Tag :value="boardTypeLabel(data.boardType)" :severity="boardTypeSeverity(data.boardType)" />
        </template>
      </Column>
      <Column field="createdBy" :header="t('COL_BOARD_AUTHOR')" style="width:100px" />
      <Column field="viewCount" :header="t('COL_BOARD_VIEWS')" style="width:70px" />
      <Column :header="t('COL_BOARD_CREATED_AT')" style="width:140px">
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
import { ref, computed, onMounted } from 'vue';
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
import { useLabel } from '@/composables/useLabel';

const route = useRoute();
const { t } = useLabel();

const boardTypes = computed(() => [
  { code: '',        label: t('LBL_BOARD_TYPE_ALL') },
  { code: 'NOTICE',  label: t('LBL_BOARD_TYPE_NOTICE') },
  { code: 'GENERAL', label: t('LBL_BOARD_TYPE_GENERAL') },
  { code: 'FREE',    label: t('LBL_BOARD_TYPE_FREE') },
  { code: 'DEPT',    label: t('LBL_BOARD_TYPE_DEPT') },
  { code: 'ARCHIVE', label: t('LBL_BOARD_TYPE_ARCHIVE') }
]);
const boardType = ref('');
const keyword = ref('');
const posts = ref<any[]>([]);
const loading = ref(false);

const selectedPostId = ref<number | null>(null);
const detailVisible = ref(false);
const formVisible = ref(false);
const editData = ref<any>(null);

function boardTypeLabel(code: string) { return t('LBL_BOARD_TYPE_' + code, code); }
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
