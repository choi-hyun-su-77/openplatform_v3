<!--
  DailyEditor.vue — 업무일지 단일 일자 편집/조회 폼.

  Phase 14 트랙 4 §6.4. 좌측 미니 캘린더에서 선택된 날짜의 일지를 편집하거나,
  팀 뷰에서 셀 클릭 시 readonly 모드로 펼쳐 보여준다.

  Props:
    date           — 'YYYY-MM-DD'. 표시용 + 저장 시 reportDate.
    employeeNo     — 표시용 (다른 사람 일지 readonly 조회 시 헤더에 노출)
    employeeName   — 표시용
    readonly       — true 면 모든 입력 비활성 + "저장" 버튼 숨김
    initial        — 기존 일지 데이터 (없으면 빈 폼)

  v-model:visible 은 다이얼로그 모드(우측 폼이 아닌 팝업으로 띄울 때) 옵션.
  기본은 inline (visible 미사용).
-->
<template>
  <div class="daily-editor">
    <header class="editor-header">
      <div class="date-line">
        <i class="pi pi-calendar" />
        <strong>{{ headerDateLabel }}</strong>
        <span v-if="employeeName" class="emp-name">— {{ employeeName }}</span>
        <span v-if="employeeNo && employeeNo !== '_'" class="emp-no">({{ employeeNo }})</span>
      </div>
      <div v-if="!readonly" class="header-actions">
        <Tag v-if="hasContent" severity="info" value="작성됨" />
        <Tag v-else severity="secondary" value="미작성" />
      </div>
    </header>

    <div class="form-grid">
      <div class="field">
        <label>오늘 한 일</label>
        <Textarea
          v-model="form.doneToday"
          :rows="4"
          placeholder="오늘 완료한 업무를 항목별로 작성하세요"
          :disabled="readonly"
          class="w-full"
          autoResize
        />
      </div>
      <div class="field">
        <label>내일 할 일</label>
        <Textarea
          v-model="form.planTomorrow"
          :rows="3"
          placeholder="내일 처리할 업무를 작성하세요"
          :disabled="readonly"
          class="w-full"
          autoResize
        />
      </div>
      <div class="field">
        <label>이슈/문제</label>
        <Textarea
          v-model="form.issue"
          :rows="2"
          placeholder="진행 중 막힌 점, 도움 요청 등"
          :disabled="readonly"
          class="w-full"
          autoResize
        />
      </div>

      <div class="field-row">
        <div class="field flex-1">
          <label>오늘 기분</label>
          <SelectButton
            v-model="form.mood"
            :options="moods"
            optionLabel="label"
            optionValue="value"
            :disabled="readonly"
            :allowEmpty="true"
          />
        </div>
        <div class="field flex-half">
          <label>업무 시간 (h)</label>
          <InputNumber
            v-model="form.hoursWorked"
            :min="0"
            :max="24"
            :step="0.5"
            :minFractionDigits="0"
            :maxFractionDigits="1"
            placeholder="예: 8.5"
            :disabled="readonly"
            class="w-full"
          />
        </div>
      </div>
    </div>

    <footer v-if="!readonly" class="editor-footer">
      <Button
        :label="hasReportId ? '수정 저장' : '저장'"
        icon="pi pi-check"
        @click="handleSave"
        :loading="saving"
        :disabled="!form.doneToday && !form.planTomorrow && !form.issue"
      />
    </footer>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue';
import Button from 'primevue/button';
import Textarea from 'primevue/textarea';
import InputNumber from 'primevue/inputnumber';
import SelectButton from 'primevue/selectbutton';
import Tag from 'primevue/tag';
import { useMessage } from '@/composables/useMessage';
import { useWorkLog, type DailyReport, type WorkLogMood } from '@/composables/useWorkLog';

interface Props {
  date: string;                        // 'YYYY-MM-DD'
  employeeNo?: string;
  employeeName?: string;
  readonly?: boolean;
  initial?: DailyReport | null;
}

const props = withDefaults(defineProps<Props>(), {
  employeeNo: '',
  employeeName: '',
  readonly: false,
  initial: null
});

const emit = defineEmits<{
  saved: [report: DailyReport];
  changed: [report: DailyReport];
}>();

const { success, error } = useMessage();
const worklog = useWorkLog();

const moods = [
  { value: 'GOOD',   label: '좋음' },
  { value: 'NORMAL', label: '보통' },
  { value: 'BAD',    label: '나쁨' }
];

interface EditorForm {
  reportId: number | null;
  doneToday: string;
  planTomorrow: string;
  issue: string;
  mood: WorkLogMood | null;
  hoursWorked: number | null;
}

function emptyForm(): EditorForm {
  return {
    reportId: null,
    doneToday: '',
    planTomorrow: '',
    issue: '',
    mood: null,
    hoursWorked: null
  };
}

const form = ref<EditorForm>(emptyForm());
const saving = ref(false);

const hasReportId = computed(() => form.value.reportId != null);
const hasContent = computed(() =>
  !!(form.value.doneToday || form.value.planTomorrow || form.value.issue)
);

const headerDateLabel = computed(() => {
  if (!props.date) return '';
  try {
    const d = new Date(props.date + 'T00:00:00');
    if (Number.isNaN(d.getTime())) return props.date;
    const w = ['일', '월', '화', '수', '목', '금', '토'][d.getDay()];
    return `${props.date} (${w})`;
  } catch {
    return props.date;
  }
});

watch(
  () => [props.date, props.initial],
  () => {
    const i = props.initial;
    if (i) {
      form.value = {
        reportId: i.reportId ?? null,
        doneToday: i.doneToday || '',
        planTomorrow: i.planTomorrow || '',
        issue: i.issue || '',
        mood: (i.mood as WorkLogMood) || null,
        hoursWorked: i.hoursWorked != null ? Number(i.hoursWorked) : null
      };
    } else {
      form.value = emptyForm();
    }
  },
  { immediate: true }
);

async function handleSave() {
  if (props.readonly) return;
  if (!props.date) {
    error('저장할 날짜가 지정되지 않았습니다');
    return;
  }
  saving.value = true;
  try {
    const payload: DailyReport = {
      reportDate: props.date,
      doneToday: form.value.doneToday || null,
      planTomorrow: form.value.planTomorrow || null,
      issue: form.value.issue || null,
      mood: form.value.mood || null,
      hoursWorked: form.value.hoursWorked != null ? Number(form.value.hoursWorked) : null
    };
    const res: any = await worklog.saveDaily(payload);
    if (res?.reportId != null) form.value.reportId = Number(res.reportId);
    success('업무일지가 저장되었습니다');
    emit('saved', { ...payload, reportId: form.value.reportId });
  } catch (e: any) {
    error('저장 실패: ' + (e?.response?.data?.message || e.message || ''));
  } finally {
    saving.value = false;
  }
}
</script>

<style scoped>
.daily-editor {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  padding: 1rem 1.25rem;
  background: var(--p-content-background, #fff);
  border: 1px solid var(--p-content-border-color, #e2e8f0);
  border-radius: 10px;
  min-height: 100%;
}
.editor-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding-bottom: 0.5rem;
  border-bottom: 1px solid #f1f5f9;
}
.date-line {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 1.05rem;
  color: #1e293b;
}
.date-line i { color: var(--p-primary-color, #3b82f6); }
.emp-name { color: #475569; font-size: 0.95rem; }
.emp-no   { color: #94a3b8; font-size: 0.85rem; }

.form-grid {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}
.field {
  display: flex;
  flex-direction: column;
  gap: 0.3rem;
}
.field label {
  font-weight: 500;
  font-size: 0.875rem;
  color: #334155;
}
.field-row {
  display: flex;
  gap: 1rem;
  flex-wrap: wrap;
}
.flex-1 { flex: 1; min-width: 240px; }
.flex-half { flex: 0 0 180px; }
.w-full { width: 100%; }

.editor-footer {
  display: flex;
  justify-content: flex-end;
  gap: 0.5rem;
  padding-top: 0.75rem;
  border-top: 1px solid #f1f5f9;
}
</style>
