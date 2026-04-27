<!--
  PageNotifySettings.vue — Phase 14 트랙 6: 알림 채널 환경설정.

  [URL] /settings/notify

  [구성]
  - DataTable 매트릭스: 행=카테고리(APPROVAL/BOARD/CALENDAR/MENTION/ROOM/LEAVE),
    열=채널(PORTAL/EMAIL/MESSENGER) 의 ToggleButton
  - 우상단 "저장" 버튼 — 매트릭스 일괄 upsert
  - 좌하단 "기본값으로" 버튼 — 모든 PORTAL=ON, EMAIL/MESSENGER=OFF 로 리셋(저장 전)
-->
<template>
  <div class="page notify-settings">
    <div class="page-header">
      <h2>알림 설정</h2>
      <div class="header-actions">
        <Button
          icon="pi pi-replay"
          label="기본값으로"
          severity="secondary"
          size="small"
          @click="resetToDefault"
        />
        <Button
          icon="pi pi-save"
          label="저장"
          severity="primary"
          size="small"
          :loading="saving"
          @click="onSave"
        />
      </div>
    </div>

    <p class="note">
      각 카테고리별로 알림을 받을 채널을 선택하세요.
      포탈은 헤더 종 아이콘에 SSE 로 즉시 알림, 이메일은 등록된 메일 주소로 발송,
      메신저는 Rocket.Chat DM 으로 전달됩니다.
    </p>

    <DataTable :value="matrix" :rowHover="true" dataKey="category" :loading="loading" class="matrix-table">
      <Column field="categoryLabel" header="카테고리" style="width:160px" />
      <Column header="포탈 (PORTAL)" style="width:160px">
        <template #body="{ data }">
          <ToggleButton
            v-model="data.PORTAL"
            onLabel="ON" offLabel="OFF"
            onIcon="pi pi-check" offIcon="pi pi-times"
            class="channel-toggle"
          />
        </template>
      </Column>
      <Column header="이메일 (EMAIL)" style="width:160px">
        <template #body="{ data }">
          <ToggleButton
            v-model="data.EMAIL"
            onLabel="ON" offLabel="OFF"
            onIcon="pi pi-check" offIcon="pi pi-times"
            class="channel-toggle"
          />
        </template>
      </Column>
      <Column header="메신저 (MESSENGER)" style="width:200px">
        <template #body="{ data }">
          <ToggleButton
            v-model="data.MESSENGER"
            onLabel="ON" offLabel="OFF"
            onIcon="pi pi-check" offIcon="pi pi-times"
            class="channel-toggle"
          />
        </template>
      </Column>
      <Column header="설명">
        <template #body="{ data }">
          <small class="muted">{{ data.description }}</small>
        </template>
      </Column>
    </DataTable>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useToast } from 'primevue/usetoast';
import DataTable from 'primevue/datatable';
import Column from 'primevue/column';
import Button from 'primevue/button';
import ToggleButton from 'primevue/togglebutton';
import { useUx, type NotifyPrefRow } from '@/composables/useUx';

const ux = useUx();
const toast = useToast();

interface MatrixRow {
  category: string;
  categoryLabel: string;
  description: string;
  PORTAL: boolean;
  EMAIL: boolean;
  MESSENGER: boolean;
}

const CATEGORY_META: Record<string, { label: string; description: string }> = {
  APPROVAL: { label: '결재',   description: '결재 요청·승인·반려 알림' },
  BOARD:    { label: '게시판', description: '공지·게시글 새 등록 알림' },
  CALENDAR: { label: '캘린더', description: '일정 초대·다가오는 일정 알림' },
  MENTION:  { label: '멘션',   description: '메신저·게시글 등에서 본인 언급' },
  ROOM:     { label: '회의실', description: '회의실 예약 초대·변경 알림' },
  LEAVE:    { label: '연차',   description: '휴가 신청·승인·반려 알림' }
};

const loading = ref(false);
const saving = ref(false);
const matrix = ref<MatrixRow[]>([]);

async function load() {
  loading.value = true;
  try {
    const pref = await ux.getNotifyPref();
    matrix.value = pref.categories.map(cat => {
      const portal    = pref.rows.find(r => r.category === cat && r.channel === 'PORTAL');
      const email     = pref.rows.find(r => r.category === cat && r.channel === 'EMAIL');
      const messenger = pref.rows.find(r => r.category === cat && r.channel === 'MESSENGER');
      return {
        category: cat,
        categoryLabel: CATEGORY_META[cat]?.label || cat,
        description: CATEGORY_META[cat]?.description || '',
        PORTAL:    portal    ? !!portal.enabled    : true,
        EMAIL:     email     ? !!email.enabled     : false,
        MESSENGER: messenger ? !!messenger.enabled : false
      };
    });
  } catch (e: any) {
    toast.add({ severity: 'error', summary: '로드 실패', detail: e?.message || String(e), life: 3000 });
  } finally {
    loading.value = false;
  }
}

async function onSave() {
  saving.value = true;
  try {
    const rows: NotifyPrefRow[] = [];
    for (const m of matrix.value) {
      rows.push({ category: m.category as any, channel: 'PORTAL',    enabled: m.PORTAL });
      rows.push({ category: m.category as any, channel: 'EMAIL',     enabled: m.EMAIL });
      rows.push({ category: m.category as any, channel: 'MESSENGER', enabled: m.MESSENGER });
    }
    await ux.saveNotifyPref(rows);
    toast.add({ severity: 'success', summary: '저장됨', detail: `${rows.length}개 항목 저장`, life: 2000 });
  } catch (e: any) {
    toast.add({ severity: 'error', summary: '저장 실패', detail: e?.message || String(e), life: 3000 });
  } finally {
    saving.value = false;
  }
}

function resetToDefault() {
  matrix.value.forEach(m => {
    m.PORTAL = true;
    m.EMAIL = false;
    m.MESSENGER = false;
  });
  toast.add({ severity: 'info', summary: '기본값 적용', detail: '저장 버튼을 눌러야 적용됩니다.', life: 2000 });
}

onMounted(load);
</script>

<style scoped>
.notify-settings {
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

.header-actions {
  display: flex;
  gap: 8px;
}

.note {
  font-size: 13px;
  color: var(--p-text-muted-color);
  margin: 0;
}

.matrix-table :deep(.p-datatable-tbody > tr > td) {
  padding: 8px 12px;
}

.channel-toggle {
  min-width: 80px;
}

.muted {
  color: var(--p-text-muted-color);
  font-size: 12px;
}
</style>
