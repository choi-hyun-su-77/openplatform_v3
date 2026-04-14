<template>
  <div class="page">
    <h2>게시판</h2>
    <div class="toolbar">
      <Select v-model="boardType" :options="boardTypes" optionLabel="label" optionValue="code" placeholder="게시판 선택" @change="load" />
      <InputText v-model="keyword" placeholder="검색어" @keyup.enter="load" />
      <Button label="검색" icon="pi pi-search" @click="load" />
      <Button label="글쓰기" icon="pi pi-plus" severity="success" @click="onNew" />
    </div>
    <DataTable :value="posts" :rowHover="true" paginator :rows="20">
      <Column field="postId" header="번호" style="width:80px" />
      <Column field="title" header="제목" />
      <Column field="createdBy" header="작성자" style="width:120px" />
      <Column field="viewCount" header="조회" style="width:80px" />
      <Column field="createdAt" header="작성일" style="width:150px" />
    </DataTable>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import axios from 'axios';
import DataTable from 'primevue/datatable';
import Column from 'primevue/column';
import Button from 'primevue/button';
import InputText from 'primevue/inputtext';
import Select from 'primevue/select';

const boardTypes = [
  { code: 'NOTICE',   label: '공지사항' },
  { code: 'DEPT',     label: '부서게시판' },
  { code: 'FREE',     label: '자유게시판' },
  { code: 'ARCHIVE',  label: '자료실' }
];
const boardType = ref('NOTICE');
const keyword = ref('');
const posts = ref<any[]>([]);

async function load() {
  const res = await axios.post('/api/dataset/search', {
    serviceName: 'board/searchPosts',
    datasets: { ds_search: { boardType: boardType.value, keyword: keyword.value } }
  });
  posts.value = res.data?.data?.ds_posts?.rows || [];
}

function onNew() {
  alert('글쓰기 화면은 Phase 7 구현 예정');
}

onMounted(load);
</script>

<style scoped>
.page { padding: 1.5rem; }
.toolbar { display: flex; gap: 0.5rem; margin-bottom: 1rem; align-items: center; }
</style>
