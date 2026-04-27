<!--
  PageFavorites.vue — Phase 14 트랙 6: 즐겨찾기 관리.

  [URL] /settings/favorites

  [구성]
  - 좌측: ListBox 카드 — 등록된 즐겨찾기 (sort_order 순)
  - 우측: 선택 항목 상세 + ▲▼ 정렬 이동 + 삭제 버튼
  - 상단: "추가" 버튼 (간단 다이얼로그 — type/label/url)

  [드래그 정책]
  npm 패키지 추가 금지 (트랙 6 § 8) — vuedraggable 미사용.
  대신 ▲▼ 화살표 버튼으로 한 칸씩 이동 → reorder 일괄 호출.
-->
<template>
  <div class="page favorites-page">
    <div class="page-header">
      <h2>즐겨찾기 관리</h2>
      <Button
        icon="pi pi-plus"
        label="추가"
        severity="primary"
        size="small"
        @click="openAddDialog"
      />
    </div>

    <div class="content">
      <div class="list-pane">
        <Listbox
          v-model="selectedFavId"
          :options="favorites"
          optionLabel="label"
          optionValue="favId"
          listStyle="max-height:480px"
          :loading="loading"
          class="favorites-listbox"
          emptyMessage="등록된 즐겨찾기가 없습니다."
        >
          <template #option="{ option }">
            <div class="fav-row">
              <i :class="option.icon || 'pi pi-star-fill'" class="fav-icon" />
              <div class="fav-text">
                <div class="fav-label">{{ option.label || option.targetId }}</div>
                <div class="fav-meta">{{ option.targetType }} · {{ option.url || '(no url)' }}</div>
              </div>
              <Tag :value="String(option.sortOrder)" severity="secondary" />
            </div>
          </template>
        </Listbox>
      </div>

      <div class="detail-pane">
        <div v-if="!selected" class="empty">왼쪽에서 항목을 선택하세요.</div>
        <div v-else class="detail">
          <h3>{{ selected.label || selected.targetId }}</h3>
          <p class="muted">유형: {{ selected.targetType }}</p>
          <p class="muted">URL: {{ selected.url || '-' }}</p>
          <p class="muted">아이콘: {{ selected.icon || '(default)' }}</p>
          <p class="muted">정렬 순서: {{ selected.sortOrder }}</p>

          <div class="action-group">
            <Button
              icon="pi pi-arrow-up"
              label="위로"
              severity="secondary"
              size="small"
              :disabled="!canMoveUp"
              @click="moveUp"
            />
            <Button
              icon="pi pi-arrow-down"
              label="아래로"
              severity="secondary"
              size="small"
              :disabled="!canMoveDown"
              @click="moveDown"
            />
            <Button
              icon="pi pi-external-link"
              label="이동"
              severity="info"
              size="small"
              :disabled="!selected.url"
              @click="goSelected"
            />
            <Button
              icon="pi pi-trash"
              label="삭제"
              severity="danger"
              size="small"
              @click="onRemove"
            />
          </div>
        </div>
      </div>
    </div>

    <Dialog v-model:visible="addDialog.visible" header="즐겨찾기 추가" :modal="true" :style="{ width: '420px' }">
      <div class="add-form">
        <div class="field">
          <label>유형</label>
          <Dropdown
            v-model="addDialog.targetType"
            :options="TARGET_TYPES"
            optionLabel="label"
            optionValue="value"
            placeholder="유형 선택"
          />
        </div>
        <div class="field">
          <label>라벨</label>
          <InputText v-model="addDialog.label" placeholder="표시될 이름" />
        </div>
        <div class="field">
          <label>대상 ID</label>
          <InputText v-model="addDialog.targetId" placeholder="메뉴ID, 글ID, 문서ID 등" />
        </div>
        <div class="field">
          <label>URL (선택)</label>
          <InputText v-model="addDialog.url" placeholder="/board?postId=123" />
        </div>
        <div class="field">
          <label>아이콘 (PrimeIcons)</label>
          <InputText v-model="addDialog.icon" placeholder="pi pi-star-fill" />
        </div>
      </div>
      <template #footer>
        <Button label="취소" severity="secondary" @click="addDialog.visible = false" />
        <Button label="추가" severity="primary" :loading="adding" @click="onAdd" />
      </template>
    </Dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, reactive, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { useToast } from 'primevue/usetoast';
import Button from 'primevue/button';
import Listbox from 'primevue/listbox';
import Tag from 'primevue/tag';
import Dialog from 'primevue/dialog';
import InputText from 'primevue/inputtext';
import Dropdown from 'primevue/dropdown';
import { useUx, type FavoriteRow } from '@/composables/useUx';

const ux = useUx();
const router = useRouter();
const toast = useToast();

const TARGET_TYPES = [
  { label: '메뉴',     value: 'MENU' },
  { label: '게시글',   value: 'POST' },
  { label: '결재',     value: 'DOC' },
  { label: '직원',     value: 'EMPLOYEE' },
  { label: '파일',     value: 'FILE' }
];

const favorites = ref<FavoriteRow[]>([]);
const loading = ref(false);
const adding = ref(false);
const selectedFavId = ref<number | null>(null);

const addDialog = reactive({
  visible: false,
  targetType: 'MENU' as FavoriteRow['targetType'],
  targetId: '',
  label: '',
  url: '',
  icon: ''
});

const selected = computed<FavoriteRow | undefined>(() =>
  favorites.value.find(f => f.favId === selectedFavId.value)
);
const selectedIndex = computed(() =>
  favorites.value.findIndex(f => f.favId === selectedFavId.value)
);
const canMoveUp = computed(() => selectedIndex.value > 0);
const canMoveDown = computed(() =>
  selectedIndex.value >= 0 && selectedIndex.value < favorites.value.length - 1
);

async function load() {
  loading.value = true;
  try {
    favorites.value = await ux.listFavorites();
  } catch (e: any) {
    toast.add({ severity: 'error', summary: '로드 실패', detail: e?.message || String(e), life: 3000 });
  } finally {
    loading.value = false;
  }
}

function openAddDialog() {
  addDialog.targetType = 'MENU';
  addDialog.targetId = '';
  addDialog.label = '';
  addDialog.url = '';
  addDialog.icon = 'pi pi-star-fill';
  addDialog.visible = true;
}

async function onAdd() {
  if (!addDialog.targetId.trim()) {
    toast.add({ severity: 'warn', summary: '대상 ID 필수', life: 2000 });
    return;
  }
  adding.value = true;
  try {
    await ux.addFavorite({
      targetType: addDialog.targetType,
      targetId: addDialog.targetId.trim(),
      label: addDialog.label.trim() || addDialog.targetId.trim(),
      url: addDialog.url.trim() || undefined,
      icon: addDialog.icon.trim() || undefined
    });
    toast.add({ severity: 'success', summary: '추가됨', life: 2000 });
    addDialog.visible = false;
    await load();
  } catch (e: any) {
    toast.add({ severity: 'error', summary: '추가 실패', detail: e?.message || String(e), life: 3000 });
  } finally {
    adding.value = false;
  }
}

async function onRemove() {
  if (!selected.value) return;
  if (!confirm(`'${selected.value.label}' 삭제할까요?`)) return;
  try {
    await ux.removeFavorite(selected.value.favId);
    toast.add({ severity: 'success', summary: '삭제됨', life: 2000 });
    selectedFavId.value = null;
    await load();
  } catch (e: any) {
    toast.add({ severity: 'error', summary: '삭제 실패', detail: e?.message || String(e), life: 3000 });
  }
}

async function moveUp() {
  if (!canMoveUp.value) return;
  const idx = selectedIndex.value;
  const arr = [...favorites.value];
  [arr[idx - 1], arr[idx]] = [arr[idx], arr[idx - 1]];
  await applyReorder(arr);
}

async function moveDown() {
  if (!canMoveDown.value) return;
  const idx = selectedIndex.value;
  const arr = [...favorites.value];
  [arr[idx + 1], arr[idx]] = [arr[idx], arr[idx + 1]];
  await applyReorder(arr);
}

async function applyReorder(newOrder: FavoriteRow[]) {
  const ids = newOrder.map(f => f.favId);
  try {
    await ux.reorderFavorites(ids);
    favorites.value = newOrder.map((f, i) => ({ ...f, sortOrder: i + 1 }));
  } catch (e: any) {
    toast.add({ severity: 'error', summary: '정렬 변경 실패', detail: e?.message || String(e), life: 3000 });
  }
}

function goSelected() {
  if (selected.value?.url) {
    router.push(selected.value.url);
  }
}

onMounted(load);
</script>

<style scoped>
.favorites-page {
  padding: 16px 24px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.content {
  display: grid;
  grid-template-columns: minmax(360px, 1fr) minmax(320px, 1fr);
  gap: 16px;
}

.favorites-listbox {
  width: 100%;
}

.fav-row {
  display: flex;
  align-items: center;
  gap: 10px;
  width: 100%;
}

.fav-icon {
  color: var(--p-primary-color);
  font-size: 16px;
}

.fav-text {
  flex: 1;
  min-width: 0;
}

.fav-label {
  font-weight: 500;
  font-size: 13px;
}

.fav-meta {
  font-size: 11px;
  color: var(--p-text-muted-color);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.detail-pane {
  border: 1px solid var(--p-content-border-color);
  border-radius: 8px;
  padding: 16px;
  background: var(--p-content-background);
  min-height: 240px;
}

.empty {
  text-align: center;
  color: var(--p-text-muted-color);
  font-size: 13px;
  padding: 32px 0;
}

.detail h3 {
  margin: 0 0 8px;
}

.muted {
  color: var(--p-text-muted-color);
  font-size: 13px;
  margin: 4px 0;
}

.action-group {
  display: flex;
  gap: 8px;
  margin-top: 16px;
  flex-wrap: wrap;
}

.add-form .field {
  display: flex;
  flex-direction: column;
  gap: 4px;
  margin-bottom: 12px;
}

.add-form label {
  font-size: 12px;
  color: var(--p-text-muted-color);
}
</style>
