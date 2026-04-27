<template>
  <div class="dashboard">
    <header class="dash-head">
      <div class="left">
        <h2>대시보드</h2>
        <p class="greeting">안녕하세요, {{ auth.user?.userName || '사용자' }}님</p>
      </div>
      <div class="right">
        <button v-if="!editMode" class="btn-edit" @click="enterEdit">
          <i class="pi pi-pencil" /> 편집
        </button>
        <template v-else>
          <button class="btn-add" @click="showAddPicker = !showAddPicker">
            <i class="pi pi-plus" /> 위젯 추가
          </button>
          <button class="btn-save" @click="save" :disabled="saving">
            <i class="pi pi-check" /> 저장
          </button>
          <button class="btn-cancel" @click="cancelEdit">
            <i class="pi pi-times" /> 취소
          </button>
        </template>
      </div>
    </header>

    <!-- 위젯 추가 picker (편집 모드에서만) -->
    <div v-if="editMode && showAddPicker" class="add-picker">
      <div class="picker-head">
        <strong>추가할 위젯 선택</strong>
        <button class="x" @click="showAddPicker = false"><i class="pi pi-times" /></button>
      </div>
      <div class="picker-grid">
        <button
          v-for="w in addableWidgets"
          :key="w.widgetCode"
          class="picker-item"
          @click="addWidget(w.widgetCode)"
        >
          <strong>{{ w.title }}</strong>
          <small>{{ w.description }}</small>
        </button>
        <span v-if="addableWidgets.length === 0" class="picker-empty">
          이미 모든 위젯이 추가되어 있습니다.
        </span>
      </div>
    </div>

    <!-- 위젯 그리드 -->
    <div v-if="loading && widgets.length === 0" class="loading-state">대시보드 로드 중...</div>
    <div v-else class="dashboard-grid" :class="{ 'edit-mode': editMode }">
      <div
        v-for="(w, idx) in widgets"
        :key="w.widgetCode"
        class="widget"
        :style="widgetStyle(w)"
      >
        <div v-if="editMode" class="edit-overlay">
          <button class="ctrl x" @click="removeWidget(idx)" title="삭제">
            <i class="pi pi-times" />
          </button>
          <div class="ctrl-group size">
            <button class="ctrl" @click="resize(idx, -1, 0)" title="가로 축소">
              <i class="pi pi-minus" />W
            </button>
            <button class="ctrl" @click="resize(idx, 1, 0)" title="가로 확대">
              <i class="pi pi-plus" />W
            </button>
            <button class="ctrl" @click="resize(idx, 0, -1)" title="세로 축소">
              <i class="pi pi-minus" />H
            </button>
            <button class="ctrl" @click="resize(idx, 0, 1)" title="세로 확대">
              <i class="pi pi-plus" />H
            </button>
          </div>
          <div class="ctrl-group move">
            <button class="ctrl" @click="move(idx, -1, 0)" title="왼쪽">
              <i class="pi pi-arrow-left" />
            </button>
            <button class="ctrl" @click="move(idx, 1, 0)" title="오른쪽">
              <i class="pi pi-arrow-right" />
            </button>
            <button class="ctrl" @click="move(idx, 0, -1)" title="위">
              <i class="pi pi-arrow-up" />
            </button>
            <button class="ctrl" @click="move(idx, 0, 1)" title="아래">
              <i class="pi pi-arrow-down" />
            </button>
          </div>
          <span class="dim-info">{{ w.width }}×{{ w.height }}</span>
        </div>
        <component :is="resolveComponent(w.widgetCode)" :widget-code="w.widgetCode" :config="w.configJson" />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, type Component } from 'vue';
import { useAuthStore } from '@/store/auth';
import { useWidget, type UserWidget, type WidgetCatalog } from '@/composables/useWidget';

import WidgetAttendance      from '@/components/dashboard/widgets/WidgetAttendance.vue';
import WidgetLeaveBalance    from '@/components/dashboard/widgets/WidgetLeaveBalance.vue';
import WidgetPendingApproval from '@/components/dashboard/widgets/WidgetPendingApproval.vue';
import WidgetTodayEvents     from '@/components/dashboard/widgets/WidgetTodayEvents.vue';
import WidgetNotices         from '@/components/dashboard/widgets/WidgetNotices.vue';
import WidgetMessenger       from '@/components/dashboard/widgets/WidgetMessenger.vue';
import WidgetMyRooms         from '@/components/dashboard/widgets/WidgetMyRooms.vue';
import WidgetTeamWorklog     from '@/components/dashboard/widgets/WidgetTeamWorklog.vue';
import WidgetLeaveChart      from '@/components/dashboard/widgets/WidgetLeaveChart.vue';

const auth = useAuthStore();
const widget = useWidget();

const widgets = ref<UserWidget[]>([]);
const catalog = ref<WidgetCatalog[]>([]);
const loading = ref(false);
const saving = ref(false);
const editMode = ref(false);
const showAddPicker = ref(false);

// snapshot for cancel
let snapshot: UserWidget[] = [];
// 삭제된 widgetCode 추적 (saveLayout 시 _rowType='D' 로 변환)
const deletedCodes = ref<string[]>([]);

const COMPONENT_MAP: Record<string, Component> = {
  ATTENDANCE:        WidgetAttendance,
  LEAVE_BALANCE:     WidgetLeaveBalance,
  PENDING_APPROVAL:  WidgetPendingApproval,
  TODAY_EVENTS:      WidgetTodayEvents,
  NOTICES:           WidgetNotices,
  MESSENGER_UNREAD:  WidgetMessenger,
  MY_ROOMS:          WidgetMyRooms,
  TEAM_WORKLOG:      WidgetTeamWorklog,
  CHART_LEAVE_USAGE: WidgetLeaveChart
};

function resolveComponent(code: string): Component {
  return COMPONENT_MAP[code] || WidgetPendingApproval;
}

function widgetStyle(w: UserWidget) {
  return {
    '--w': String(Math.min(12, Math.max(1, w.width || 4))),
    '--h': String(Math.min(3, Math.max(1, w.height || 1))),
    'order': String((w.posY ?? 0) * 100 + (w.posX ?? 0))
  } as Record<string, string>;
}

const addableWidgets = computed<WidgetCatalog[]>(() => {
  const inUse = new Set(widgets.value.map(w => w.widgetCode));
  return catalog.value.filter(c => !inUse.has(c.widgetCode));
});

async function loadWidgets() {
  loading.value = true;
  try {
    if (!auth.user) await auth.loadUserInfo();
    const [mine, all] = await Promise.all([widget.listMine(), widget.listAll()]);
    widgets.value = mine;
    catalog.value = all;
  } catch (e) {
    console.warn('[Dashboard] load failed', e);
  } finally {
    loading.value = false;
  }
}

function enterEdit() {
  // deep copy for cancel
  snapshot = widgets.value.map(w => ({ ...w }));
  deletedCodes.value = [];
  editMode.value = true;
  showAddPicker.value = false;
}

function cancelEdit() {
  widgets.value = snapshot.map(w => ({ ...w }));
  deletedCodes.value = [];
  editMode.value = false;
  showAddPicker.value = false;
}

async function save() {
  if (saving.value) return;
  saving.value = true;
  try {
    const payload: UserWidget[] = [
      ...widgets.value.map(w => ({ ...w })),
      ...deletedCodes.value.map(code => ({
        widgetCode: code,
        title: '', posX: 0, posY: 0, width: 0, height: 0,
        _rowType: 'D' as const
      }))
    ];
    await widget.saveLayout(payload);
    deletedCodes.value = [];
    editMode.value = false;
    showAddPicker.value = false;
    await loadWidgets();
  } catch (e) {
    console.warn('[Dashboard] save failed', e);
  } finally {
    saving.value = false;
  }
}

function move(idx: number, dx: number, dy: number) {
  const w = widgets.value[idx];
  if (!w) return;
  w.posX = Math.max(0, Math.min(11, (w.posX ?? 0) + dx));
  w.posY = Math.max(0, (w.posY ?? 0) + dy);
}

function resize(idx: number, dw: number, dh: number) {
  const w = widgets.value[idx];
  if (!w) return;
  w.width  = Math.max(1, Math.min(12, (w.width ?? 4) + dw));
  w.height = Math.max(1, Math.min(3,  (w.height ?? 1) + dh));
}

function removeWidget(idx: number) {
  const w = widgets.value[idx];
  if (!w) return;
  // 기존 행이면 삭제 큐에, 신규(C)면 그냥 제거
  if (w._rowType !== 'C') {
    deletedCodes.value.push(w.widgetCode);
  }
  widgets.value.splice(idx, 1);
}

async function addWidget(widgetCode: string) {
  // 카탈로그의 default 사이즈 가져오기
  const cat = catalog.value.find(c => c.widgetCode === widgetCode);
  // 화면 맨 아래에 추가 — 가장 큰 posY + 1
  const maxY = widgets.value.reduce((m, w) => Math.max(m, (w.posY ?? 0) + (w.height ?? 1)), 0);
  widgets.value.push({
    widgetCode,
    title: cat?.title || widgetCode,
    description: cat?.description,
    category: cat?.category,
    posX: 0,
    posY: maxY,
    width: cat?.defaultW || 4,
    height: cat?.defaultH || 1,
    _rowType: 'C'
  });
  // 삭제 큐에 같은 코드가 있었다면 제거
  deletedCodes.value = deletedCodes.value.filter(c => c !== widgetCode);
  showAddPicker.value = false;
}

onMounted(loadWidgets);
</script>

<style scoped>
.dashboard { padding: 1.5rem; }
.dash-head { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 1rem; gap: 1rem; flex-wrap: wrap; }
.dash-head h2 { margin: 0 0 0.25rem 0; }
.greeting { color: #64748b; margin: 0; }
.right { display: flex; gap: 0.4rem; }
.btn-edit, .btn-add, .btn-save, .btn-cancel {
  border: 1px solid #cbd5e1;
  background: white;
  padding: 0.4rem 0.8rem;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.85rem;
  display: inline-flex;
  align-items: center;
  gap: 0.3rem;
  color: #334155;
}
.btn-edit:hover, .btn-add:hover, .btn-cancel:hover { background: #f1f5f9; }
.btn-save { background: #3b82f6; color: white; border-color: #3b82f6; }
.btn-save:hover { background: #2563eb; }
.btn-save:disabled { opacity: 0.5; cursor: not-allowed; }

.add-picker {
  background: white;
  border: 1px solid #cbd5e1;
  border-radius: 8px;
  padding: 1rem;
  margin-bottom: 1rem;
  box-shadow: 0 4px 12px rgba(0,0,0,0.06);
}
.picker-head { display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.75rem; }
.picker-head .x { background: transparent; border: 0; color: #94a3b8; cursor: pointer; }
.picker-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(180px, 1fr)); gap: 0.5rem; }
.picker-item {
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 6px;
  padding: 0.6rem;
  cursor: pointer;
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 0.25rem;
  text-align: left;
}
.picker-item:hover { background: #e0f2fe; border-color: #3b82f6; }
.picker-item strong { font-size: 0.9rem; color: #1e293b; }
.picker-item small { font-size: 0.75rem; color: #64748b; }
.picker-empty { color: #94a3b8; font-size: 0.85rem; }

.loading-state { padding: 2rem; text-align: center; color: #94a3b8; }

.dashboard-grid {
  display: grid;
  grid-template-columns: repeat(12, 1fr);
  grid-auto-rows: 140px;
  gap: 12px;
}
.widget {
  grid-column: span var(--w, 4);
  grid-row: span var(--h, 1);
  background: var(--p-content-background, white);
  border: 1px solid var(--p-content-border-color, #e2e8f0);
  border-radius: 8px;
  padding: 1rem;
  position: relative;
  overflow: hidden;
  transition: box-shadow 0.2s;
  display: flex;
  flex-direction: column;
}
.widget:hover { box-shadow: 0 2px 8px rgba(0,0,0,0.05); }
.dashboard-grid.edit-mode .widget {
  border: 2px dashed #3b82f6;
  background: #f0f9ff;
}
.edit-overlay {
  position: absolute;
  top: 4px; right: 4px;
  display: flex;
  flex-direction: column;
  gap: 4px;
  align-items: flex-end;
  z-index: 10;
  background: rgba(255,255,255,0.95);
  padding: 0.25rem;
  border-radius: 6px;
  box-shadow: 0 2px 6px rgba(0,0,0,0.15);
}
.edit-overlay .ctrl {
  background: white;
  border: 1px solid #cbd5e1;
  border-radius: 4px;
  padding: 0.15rem 0.3rem;
  cursor: pointer;
  font-size: 0.7rem;
  color: #475569;
  display: inline-flex;
  align-items: center;
  gap: 1px;
  min-width: 22px;
  justify-content: center;
}
.edit-overlay .ctrl:hover { background: #e0f2fe; }
.edit-overlay .ctrl.x { background: #ef4444; color: white; border-color: #ef4444; }
.edit-overlay .ctrl.x:hover { background: #dc2626; }
.edit-overlay .ctrl-group { display: flex; gap: 2px; }
.edit-overlay .dim-info {
  font-size: 0.65rem;
  color: #64748b;
  background: white;
  padding: 1px 4px;
  border-radius: 3px;
  border: 1px solid #e2e8f0;
}
:deep(.widget-body) { width: 100%; height: 100%; display: flex; flex-direction: column; }
</style>
