<template>
  <Dialog v-model:visible="visible" :header="isEdit ? '일정 수정' : '새 일정'" modal
          :style="{ width: '480px' }" :closable="true" :draggable="false">
    <div class="form-grid">
      <div class="field">
        <label>제목 <span class="req">*</span></label>
        <InputText v-model="form.title" placeholder="일정 제목" class="w-full" />
      </div>
      <div class="field-row">
        <div class="field flex-1">
          <label>시작</label>
          <DatePicker v-model="form.startDt" showTime :showSeconds="false" dateFormat="yy-mm-dd" class="w-full" />
        </div>
        <div class="field flex-1">
          <label>종료</label>
          <DatePicker v-model="form.endDt" showTime :showSeconds="false" dateFormat="yy-mm-dd" class="w-full" />
        </div>
      </div>
      <div class="field">
        <label><input type="checkbox" v-model="form.allDay" /> 종일</label>
      </div>
      <div class="field">
        <label>범위</label>
        <Select v-model="form.eventType" :options="eventTypes" optionLabel="label" optionValue="value" class="w-full" />
      </div>
      <div class="field">
        <label>색상</label>
        <div class="color-picks">
          <span v-for="c in colors" :key="c" :class="['color-dot', { selected: form.color === c }]"
                :style="{ background: c }" @click="form.color = c" />
        </div>
      </div>
      <div class="field">
        <label>설명</label>
        <Textarea v-model="form.description" :rows="3" class="w-full" />
      </div>
    </div>
    <template #footer>
      <Button v-if="isEdit" label="삭제" icon="pi pi-trash" severity="danger" text @click="handleDelete" />
      <Button label="취소" severity="secondary" @click="visible = false" />
      <Button :label="isEdit ? '수정' : '저장'" icon="pi pi-check" @click="handleSave" :loading="saving" />
    </template>
  </Dialog>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue';
import axios from 'axios';
import Dialog from 'primevue/dialog';
import Button from 'primevue/button';
import InputText from 'primevue/inputtext';
import Textarea from 'primevue/textarea';
import Select from 'primevue/select';
import DatePicker from 'primevue/datepicker';
import { useAuthStore } from '@/store/auth';
import { useMessage } from '@/composables/useMessage';

const props = defineProps<{ eventData?: any }>();
const emit = defineEmits<{ saved: []; deleted: [] }>();
const visible = defineModel<boolean>('visible', { default: false });
const auth = useAuthStore();
const { success, error } = useMessage();

const eventTypes = [
  { value: 'PERSONAL', label: '개인' },
  { value: 'DEPT', label: '부서' },
  { value: 'COMPANY', label: '회사' }
];
const colors = ['#3b82f6', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6', '#06b6d4', '#f97316'];

const isEdit = computed(() => !!props.eventData?.eventId);
const saving = ref(false);

const form = ref({
  eventId: null as number | null,
  title: '',
  description: '',
  eventType: 'PERSONAL',
  startDt: new Date(),
  endDt: new Date(Date.now() + 3600000),
  allDay: false,
  color: '#3b82f6'
});

watch(() => [visible.value, props.eventData], ([v]) => {
  if (v && props.eventData?.eventId) {
    form.value = {
      eventId: props.eventData.eventId,
      title: props.eventData.title || '',
      description: props.eventData.description || '',
      eventType: props.eventData.eventType || 'PERSONAL',
      startDt: new Date(props.eventData.startDt || props.eventData.start),
      endDt: new Date(props.eventData.endDt || props.eventData.end || Date.now() + 3600000),
      allDay: !!props.eventData.allDay,
      color: props.eventData.color || '#3b82f6'
    };
  } else if (v && props.eventData?.start) {
    // dateSelect 에서 넘어온 경우 (새 이벤트 + 날짜 지정)
    form.value = {
      eventId: null,
      title: '',
      description: '',
      eventType: 'PERSONAL',
      startDt: new Date(props.eventData.start),
      endDt: new Date(props.eventData.end || props.eventData.start),
      allDay: !!props.eventData.allDay,
      color: '#3b82f6'
    };
  } else if (v) {
    form.value = { eventId: null, title: '', description: '', eventType: 'PERSONAL', startDt: new Date(), endDt: new Date(Date.now() + 3600000), allDay: false, color: '#3b82f6' };
  }
});

async function handleSave() {
  if (!form.value.title.trim()) { error('제목을 입력하세요'); return; }
  saving.value = true;
  try {
    const rowType = isEdit.value ? 'U' : 'C';
    const row: any = {
      _rowType: rowType,
      title: form.value.title,
      description: form.value.description,
      eventType: form.value.eventType,
      startDt: form.value.startDt instanceof Date ? form.value.startDt.toISOString() : form.value.startDt,
      endDt: form.value.endDt instanceof Date ? form.value.endDt.toISOString() : form.value.endDt,
      allDay: form.value.allDay,
      color: form.value.color,
      ownerId: auth.user?.employeeId,
      deptId: auth.user?.deptId
    };
    if (isEdit.value) row.eventId = form.value.eventId;
    await axios.post('/api/dataset/save', {
      serviceName: 'calendar/saveEvents',
      datasets: { ds_events: { rows: [row] } }
    });
    success(isEdit.value ? '일정이 수정되었습니다' : '일정이 등록되었습니다');
    visible.value = false;
    emit('saved');
  } catch (e) {
    error('저장에 실패했습니다');
  } finally {
    saving.value = false;
  }
}

async function handleDelete() {
  if (!form.value.eventId) return;
  try {
    await axios.post('/api/dataset/save', {
      serviceName: 'calendar/deleteEvent',
      datasets: { ds_search: { eventId: form.value.eventId } }
    });
    success('일정이 삭제되었습니다');
    visible.value = false;
    emit('deleted');
  } catch (e) {
    error('삭제에 실패했습니다');
  }
}
</script>

<style scoped>
.form-grid { display: flex; flex-direction: column; gap: 0.75rem; }
.field { display: flex; flex-direction: column; gap: 0.25rem; }
.field label { font-weight: 500; font-size: 0.9rem; }
.field-row { display: flex; gap: 0.75rem; }
.flex-1 { flex: 1; }
.w-full { width: 100%; }
.req { color: red; }
.color-picks { display: flex; gap: 0.5rem; }
.color-dot { width: 24px; height: 24px; border-radius: 50%; cursor: pointer; border: 2px solid transparent; }
.color-dot.selected { border-color: var(--p-text-color); }
</style>
