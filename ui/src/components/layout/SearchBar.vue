<!--
  SearchBar.vue — Phase 14 트랙 6: 헤더 통합 검색 바.

  [용도]
  - 헤더에 마운트되어 모든 도메인(POST/DOC/EMP/FILE)을 한 번에 검색
  - 인풋 우측의 검색 아이콘 또는 Enter 키로 검색 실행
  - 검색 결과는 OverlayPanel 로 4개 탭(게시글·결재·사람·파일)에 표시
  - "더보기" 클릭 시 /search?q=... 풀 검색 페이지로 라우팅

  [트랙 8 통합 노트]
  - 본 컴포넌트의 LayoutHeader 마운트는 트랙 8(메인)에서 일괄 처리
  - 본 트랙은 컴포넌트 신규 작성만, LayoutHeader.vue 직접 수정 금지
-->
<template>
  <div class="search-bar">
    <span class="p-input-icon-left search-input-wrap">
      <i class="pi pi-search" />
      <InputText
        v-model="keyword"
        placeholder="통합 검색"
        size="small"
        class="search-input"
        @keyup.enter="onSearch"
        @focus="onFocusInput"
      />
    </span>
    <Button
      icon="pi pi-search"
      severity="secondary"
      text
      size="small"
      :disabled="!keyword.trim()"
      v-tooltip.bottom="'검색'"
      @click="onSearch"
    />

    <OverlayPanel ref="overlayRef" :dismissable="true" class="search-overlay">
      <div class="search-overlay-inner">
        <div class="overlay-header">
          <span class="overlay-title">"{{ keyword }}" 결과</span>
          <Button
            label="전체 보기"
            icon="pi pi-external-link"
            text
            size="small"
            @click="goFullSearch"
          />
        </div>

        <TabView>
          <TabPanel value="posts" :header="`게시글 (${result.posts.length})`">
            <div v-if="result.posts.length === 0" class="empty-tab">결과 없음</div>
            <ul v-else class="result-list">
              <li
                v-for="p in result.posts"
                :key="`post-${p.postId}`"
                class="result-item"
                @click="goPost(p)"
              >
                <i class="pi pi-comment" />
                <div class="item-body">
                  <div class="item-title">{{ p.title }}</div>
                  <div class="item-meta">{{ p.boardType }} · {{ p.deptName || '-' }} · {{ formatDate(p.createdAt) }}</div>
                </div>
              </li>
            </ul>
          </TabPanel>

          <TabPanel value="docs" :header="`결재 (${result.docs.length})`">
            <div v-if="result.docs.length === 0" class="empty-tab">결과 없음</div>
            <ul v-else class="result-list">
              <li
                v-for="d in result.docs"
                :key="`doc-${d.docId}`"
                class="result-item"
                @click="goDoc(d)"
              >
                <i class="pi pi-file-edit" />
                <div class="item-body">
                  <div class="item-title">{{ d.docTitle }}</div>
                  <div class="item-meta">{{ d.formCode }} · {{ d.drafterName }} · {{ d.status }}</div>
                </div>
              </li>
            </ul>
          </TabPanel>

          <TabPanel value="employees" :header="`사람 (${result.employees.length})`">
            <div v-if="result.employees.length === 0" class="empty-tab">결과 없음</div>
            <ul v-else class="result-list">
              <li
                v-for="e in result.employees"
                :key="`emp-${e.employeeId}`"
                class="result-item"
                @click="goEmployee(e)"
              >
                <i class="pi pi-user" />
                <div class="item-body">
                  <div class="item-title">{{ e.employeeName }} ({{ e.positionName }})</div>
                  <div class="item-meta">{{ e.deptName }} · {{ e.email || '-' }}</div>
                </div>
              </li>
            </ul>
          </TabPanel>

          <TabPanel value="files" :header="`파일 (${result.files.length})`">
            <div v-if="result.files.length === 0" class="empty-tab">결과 없음</div>
            <ul v-else class="result-list">
              <li
                v-for="f in result.files"
                :key="`file-${f.fileId}`"
                class="result-item"
                @click="goFile(f)"
              >
                <i class="pi pi-file" />
                <div class="item-body">
                  <div class="item-title">{{ f.fileName }}</div>
                  <div class="item-meta">{{ f.folderName }} · {{ formatSize(f.sizeBytes) }}</div>
                </div>
              </li>
            </ul>
          </TabPanel>
        </TabView>

        <div v-if="loading" class="overlay-loading">
          <i class="pi pi-spin pi-spinner" /> 검색 중…
        </div>
      </div>
    </OverlayPanel>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import InputText from 'primevue/inputtext';
import Button from 'primevue/button';
import OverlayPanel from 'primevue/overlaypanel';
import TabView from 'primevue/tabview';
import TabPanel from 'primevue/tabpanel';
import { useUx, type SearchResult, type SearchPostRow, type SearchDocRow, type SearchEmpRow, type SearchFileRow } from '@/composables/useUx';

const router = useRouter();
const ux = useUx();

const keyword = ref('');
const loading = ref(false);
const result = ref<SearchResult>({ posts: [], docs: [], employees: [], files: [] });
const overlayRef = ref<InstanceType<typeof OverlayPanel> | null>(null);

async function onSearch(event?: Event) {
  if (!keyword.value.trim()) return;
  loading.value = true;
  try {
    result.value = await ux.search(keyword.value);
    // OverlayPanel 토글
    const target = (event?.currentTarget as HTMLElement) || (event?.target as HTMLElement);
    if (target) {
      overlayRef.value?.show(event as Event, target);
    } else {
      // 키보드 Enter 의 경우 keyword input element 기준
      const el = document.querySelector('.search-bar .search-input') as HTMLElement | null;
      if (el) overlayRef.value?.show(event as Event, el);
    }
  } finally {
    loading.value = false;
  }
}

function onFocusInput(_event: Event) {
  // 빈 입력 시는 패널 표시하지 않음 (혼란 방지)
}

function goFullSearch() {
  overlayRef.value?.hide();
  router.push({ path: '/search', query: { q: keyword.value } });
}

function goPost(p: SearchPostRow) {
  overlayRef.value?.hide();
  router.push({ path: '/board', query: { postId: String(p.postId) } });
}

function goDoc(d: SearchDocRow) {
  overlayRef.value?.hide();
  router.push({ path: '/approval', query: { docId: String(d.docId) } });
}

function goEmployee(e: SearchEmpRow) {
  overlayRef.value?.hide();
  router.push({ path: '/org', query: { employeeId: String(e.employeeId) } });
}

function goFile(f: SearchFileRow) {
  overlayRef.value?.hide();
  router.push({ path: '/datalib', query: { folderId: String(f.folderId), fileId: String(f.fileId) } });
}

function formatDate(dt?: string): string {
  if (!dt) return '';
  const d = new Date(dt);
  return d.toLocaleDateString('ko-KR', { month: 'short', day: 'numeric' });
}

function formatSize(bytes: number): string {
  if (!bytes) return '0 B';
  if (bytes < 1024) return `${bytes} B`;
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
  return `${(bytes / 1024 / 1024).toFixed(1)} MB`;
}
</script>

<style scoped>
.search-bar {
  display: flex;
  align-items: center;
  gap: 4px;
}

.search-input-wrap {
  position: relative;
  display: inline-flex;
  align-items: center;
}

.search-input-wrap > i {
  position: absolute;
  left: 8px;
  pointer-events: none;
  color: var(--p-text-muted-color);
  font-size: 13px;
}

.search-input {
  width: 240px;
  padding-left: 28px;
  font-size: 13px;
}

.search-overlay {
  width: 480px;
  max-height: 560px;
}

.search-overlay-inner {
  padding: 4px;
}

.overlay-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 4px 8px 8px;
  border-bottom: 1px solid var(--p-content-border-color);
}

.overlay-title {
  font-weight: 600;
  font-size: 14px;
}

.result-list {
  list-style: none;
  margin: 0;
  padding: 0;
  max-height: 360px;
  overflow-y: auto;
}

.result-item {
  display: flex;
  gap: 10px;
  padding: 8px 10px;
  cursor: pointer;
  border-bottom: 1px solid var(--p-content-border-color);
  transition: background 0.15s;
}

.result-item:hover {
  background: var(--p-content-hover-background);
}

.result-item i {
  color: var(--p-primary-color);
  font-size: 14px;
  margin-top: 2px;
}

.item-body {
  flex: 1;
  min-width: 0;
}

.item-title {
  font-size: 13px;
  font-weight: 500;
  color: var(--p-text-color);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.item-meta {
  font-size: 11px;
  color: var(--p-text-muted-color);
  margin-top: 2px;
}

.empty-tab {
  text-align: center;
  padding: 24px;
  color: var(--p-text-muted-color);
  font-size: 13px;
}

.overlay-loading {
  text-align: center;
  padding: 8px;
  color: var(--p-text-muted-color);
  font-size: 12px;
}
</style>
