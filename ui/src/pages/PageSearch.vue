<!--
  PageSearch.vue — Phase 14 트랙 6: 풀 통합 검색 결과 페이지.

  [URL]
    /search?q=keyword
    /search?q=keyword&type=POST    → 단일 도메인 강조 표시 (있으면 해당 탭만)

  [구성]
    상단: 큰 검색 입력 + 도메인 필터 체크박스(Posts/Docs/Employees/Files)
    하단: 4개 탭 — 각 탭에 DataTable 또는 Card 리스트
-->
<template>
  <div class="page search-page">
    <div class="search-toolbar">
      <span class="p-input-icon-left search-input-wrap">
        <i class="pi pi-search" />
        <InputText
          v-model="keyword"
          placeholder="통합 검색..."
          @keyup.enter="onSearch"
          autofocus
        />
      </span>
      <Button
        icon="pi pi-search"
        label="검색"
        severity="info"
        @click="onSearch"
      />
      <div class="filter-group">
        <span>대상:</span>
        <Checkbox v-model="filters.POST"  inputId="f-post" :binary="true" />
        <label for="f-post">게시글</label>
        <Checkbox v-model="filters.DOC"   inputId="f-doc"  :binary="true" />
        <label for="f-doc">결재</label>
        <Checkbox v-model="filters.EMP"   inputId="f-emp"  :binary="true" />
        <label for="f-emp">사람</label>
        <Checkbox v-model="filters.FILE"  inputId="f-file" :binary="true" />
        <label for="f-file">파일</label>
      </div>
    </div>

    <div class="result-summary" v-if="hasResult">
      게시글 <b>{{ result.posts.length }}</b> ·
      결재 <b>{{ result.docs.length }}</b> ·
      사람 <b>{{ result.employees.length }}</b> ·
      파일 <b>{{ result.files.length }}</b> 건
    </div>

    <TabView v-model:activeIndex="activeIdx">
      <TabPanel value="posts" :header="`게시글 (${result.posts.length})`">
        <DataTable :value="result.posts" :rowHover="true" dataKey="postId" :loading="loading">
          <template #empty>결과 없음</template>
          <Column field="title" header="제목">
            <template #body="{ data }">
              <a class="link" @click="goPost(data)">{{ data.title }}</a>
            </template>
          </Column>
          <Column field="boardType" header="게시판" style="width:120px" />
          <Column field="deptName"  header="부서"   style="width:140px" />
          <Column field="createdBy" header="작성자" style="width:120px" />
          <Column header="작성일" style="width:120px">
            <template #body="{ data }">{{ formatDate(data.createdAt) }}</template>
          </Column>
        </DataTable>
      </TabPanel>

      <TabPanel value="docs" :header="`결재 (${result.docs.length})`">
        <DataTable :value="result.docs" :rowHover="true" dataKey="docId" :loading="loading">
          <template #empty>결과 없음</template>
          <Column field="docTitle" header="제목">
            <template #body="{ data }">
              <a class="link" @click="goDoc(data)">{{ data.docTitle }}</a>
            </template>
          </Column>
          <Column field="formCode"    header="양식" style="width:120px" />
          <Column field="drafterName" header="기안자" style="width:120px" />
          <Column field="status"      header="상태"   style="width:120px" />
          <Column header="기안일" style="width:120px">
            <template #body="{ data }">{{ formatDate(data.createdAt) }}</template>
          </Column>
        </DataTable>
      </TabPanel>

      <TabPanel value="employees" :header="`사람 (${result.employees.length})`">
        <DataTable :value="result.employees" :rowHover="true" dataKey="employeeId" :loading="loading">
          <template #empty>결과 없음</template>
          <Column field="employeeName" header="이름">
            <template #body="{ data }">
              <a class="link" @click="goEmployee(data)">{{ data.employeeName }}</a>
            </template>
          </Column>
          <Column field="positionName" header="직책" style="width:120px" />
          <Column field="deptName"     header="부서"  style="width:160px" />
          <Column field="email"        header="이메일" />
          <Column field="phone"        header="전화"   style="width:140px" />
        </DataTable>
      </TabPanel>

      <TabPanel value="files" :header="`파일 (${result.files.length})`">
        <DataTable :value="result.files" :rowHover="true" dataKey="fileId" :loading="loading">
          <template #empty>결과 없음</template>
          <Column field="fileName" header="파일명">
            <template #body="{ data }">
              <a class="link" @click="goFile(data)">{{ data.fileName }}</a>
            </template>
          </Column>
          <Column field="folderName" header="폴더" style="width:160px" />
          <Column field="scope"      header="범위" style="width:100px" />
          <Column header="크기" style="width:100px">
            <template #body="{ data }">{{ formatSize(data.sizeBytes) }}</template>
          </Column>
          <Column header="업로드일" style="width:140px">
            <template #body="{ data }">{{ formatDate(data.uploadedAt) }}</template>
          </Column>
        </DataTable>
      </TabPanel>
    </TabView>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted, watch } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import InputText from 'primevue/inputtext';
import Button from 'primevue/button';
import Checkbox from 'primevue/checkbox';
import TabView from 'primevue/tabview';
import TabPanel from 'primevue/tabpanel';
import DataTable from 'primevue/datatable';
import Column from 'primevue/column';
import { useUx, type SearchResult, type SearchType, type SearchPostRow, type SearchDocRow, type SearchEmpRow, type SearchFileRow } from '@/composables/useUx';

const router = useRouter();
const route = useRoute();
const ux = useUx();

const keyword = ref<string>(String(route.query.q || ''));
const loading = ref(false);
const activeIdx = ref(0);
const filters = reactive<{ POST: boolean; DOC: boolean; EMP: boolean; FILE: boolean }>({
  POST: true, DOC: true, EMP: true, FILE: true
});

const result = ref<SearchResult>({ posts: [], docs: [], employees: [], files: [] });

const hasResult = computed(() =>
  result.value.posts.length + result.value.docs.length +
  result.value.employees.length + result.value.files.length > 0
);

async function onSearch() {
  if (!keyword.value.trim()) return;
  loading.value = true;
  try {
    const types: SearchType[] = [];
    if (filters.POST) types.push('POST');
    if (filters.DOC)  types.push('DOC');
    if (filters.EMP)  types.push('EMP');
    if (filters.FILE) types.push('FILE');
    result.value = await ux.search(keyword.value, types.length === 4 ? undefined : types);
    // URL 동기화
    router.replace({ path: '/search', query: { q: keyword.value } });
  } finally {
    loading.value = false;
  }
}

function goPost(p: SearchPostRow) { router.push({ path: '/board', query: { postId: String(p.postId) } }); }
function goDoc(d: SearchDocRow) { router.push({ path: '/approval', query: { docId: String(d.docId) } }); }
function goEmployee(e: SearchEmpRow) { router.push({ path: '/org', query: { employeeId: String(e.employeeId) } }); }
function goFile(f: SearchFileRow) { router.push({ path: '/datalib', query: { folderId: String(f.folderId), fileId: String(f.fileId) } }); }

function formatDate(dt?: string): string {
  if (!dt) return '';
  return new Date(dt).toLocaleDateString('ko-KR', { year: 'numeric', month: 'short', day: 'numeric' });
}

function formatSize(bytes: number): string {
  if (!bytes) return '0 B';
  if (bytes < 1024) return `${bytes} B`;
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
  return `${(bytes / 1024 / 1024).toFixed(1)} MB`;
}

watch(() => route.query.q, (newQ) => {
  if (newQ && String(newQ) !== keyword.value) {
    keyword.value = String(newQ);
    onSearch();
  }
});

onMounted(() => {
  if (keyword.value.trim()) onSearch();
});
</script>

<style scoped>
.search-page {
  padding: 16px 24px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.search-toolbar {
  display: flex;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
}

.search-input-wrap {
  position: relative;
  flex: 1;
  min-width: 280px;
  max-width: 480px;
  display: inline-flex;
  align-items: center;
}

.search-input-wrap > i {
  position: absolute;
  left: 10px;
  pointer-events: none;
  color: var(--p-text-muted-color);
}

.search-input-wrap input {
  width: 100%;
  padding-left: 32px;
}

.filter-group {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 13px;
}

.filter-group label {
  cursor: pointer;
  margin-right: 8px;
}

.result-summary {
  font-size: 13px;
  color: var(--p-text-muted-color);
}

.link {
  color: var(--p-primary-color);
  cursor: pointer;
  text-decoration: none;
}
.link:hover {
  text-decoration: underline;
}
</style>
