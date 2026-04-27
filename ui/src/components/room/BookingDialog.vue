<template>
  <Dialog v-model:visible="visible" header="회의실 예약" modal
          :style="{ width: '560px' }" :closable="true" :draggable="false">
    <div class="form-grid">
      <div class="field">
        <label>제목 <span class="req">*</span></label>
        <InputText v-model="form.title" placeholder="회의 제목" class="w-full" />
      </div>
      <div class="field">
        <label>회의실 <span class="req">*</span></label>
        <Select v-model="form.roomId" :options="rooms" optionLabel="roomName" optionValue="roomId"
                placeholder="회의실 선택" class="w-full" @change="onRoomChange" />
      </div>
      <div class="field-row">
        <div class="field flex-1">
          <label>시작 <span class="req">*</span></label>
          <DatePicker v-model="form.startAt" showTime :showSeconds="false" dateFormat="yy-mm-dd"
                      class="w-full" hourFormat="24" />
        </div>
        <div class="field flex-1">
          <label>종료 <span class="req">*</span></label>
          <DatePicker v-model="form.endAt" showTime :showSeconds="false" dateFormat="yy-mm-dd"
                      class="w-full" hourFormat="24" />
        </div>
      </div>
      <div class="field">
        <label>참석자</label>
        <MultiSelect v-model="form.attendees" :options="employees" filter optionLabel="employee_name"
                     optionValue="employee_no" placeholder="참석자 선택"
                     class="w-full" :maxSelectedLabels="5" display="chip" />
      </div>
      <div class="field" v-if="selectedRoom?.hasVideo">
        <label>
          <input type="checkbox" v-model="form.useVideo" disabled />
          화상회의 자동 생성 (이 회의실은 LiveKit 연동)
        </label>
      </div>
      <div class="field-note" v-if="conflictMessage">
        <i class="pi pi-exclamation-triangle" /> {{ conflictMessage }}
      </div>
    </div>
    <template #footer>
      <Button label="취소" severity="secondary" @click="visible = false" />
      <Button label="예약" icon="pi pi-check" @click="handleReserve" :loading="saving" />
    </template>
  </Dialog>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue';
import axios from 'axios';
import Dialog from 'primevue/dialog';
import Button from 'primevue/button';
import InputText from 'primevue/inputtext';
import Select from 'primevue/select';
import MultiSelect from 'primevue/multiselect';
import DatePicker from 'primevue/datepicker';
import { useRoom, type Room } from '@/composables/useRoom';
import { useMessage } from '@/composables/useMessage';

const props = defineProps<{
  rooms: Room[];
  /** 미리 선택할 회의실 ID (사이드바에서 선택된 회의실) */
  preselectedRoomId?: number | null;
  /** dateSelect 등에서 넘어온 초기 시간 */
  initialStart?: Date | string | null;
  initialEnd?: Date | string | null;
}>();
const emit = defineEmits<{ saved: [bookingId: number] }>();
const visible = defineModel<boolean>('visible', { default: false });

const room = useRoom();
const { success, error } = useMessage();

const saving = ref(false);
const employees = ref<any[]>([]);
const conflictMessage = ref('');

const form = ref({
  roomId: null as number | null,
  title: '',
  startAt: new Date() as Date | null,
  endAt: new Date(Date.now() + 60 * 60 * 1000) as Date | null,
  attendees: [] as string[],
  useVideo: false
});

const selectedRoom = computed(() =>
  props.rooms.find(r => r.roomId === form.value.roomId) || null
);

watch(visible, async v => {
  if (!v) return;
  // 다이얼로그 열릴 때마다 초기화
  form.value = {
    roomId: props.preselectedRoomId ?? props.rooms[0]?.roomId ?? null,
    title: '',
    startAt: toDate(props.initialStart) || new Date(),
    endAt: toDate(props.initialEnd) || new Date(Date.now() + 60 * 60 * 1000),
    attendees: [],
    useVideo: true
  };
  conflictMessage.value = '';
  if (!employees.value.length) await loadEmployees();
});

watch(() => [form.value.roomId, form.value.startAt, form.value.endAt], async () => {
  conflictMessage.value = '';
  if (!form.value.roomId || !form.value.startAt || !form.value.endAt) return;
  if (!(form.value.endAt > form.value.startAt)) {
    conflictMessage.value = '종료 시간이 시작 시간보다 이후여야 합니다.';
    return;
  }
  try {
    const r = await room.checkConflict(
      form.value.roomId,
      iso(form.value.startAt),
      iso(form.value.endAt)
    );
    if (r.conflict) conflictMessage.value = '선택한 시간에 이미 다른 예약이 있습니다.';
  } catch {
    /* 충돌 검사 실패는 무시 */
  }
});

function onRoomChange() {
  /* placeholder for room change side-effects */
}

function toDate(v: any): Date | null {
  if (!v) return null;
  if (v instanceof Date) return v;
  const d = new Date(v);
  return isNaN(d.getTime()) ? null : d;
}

function iso(d: Date | null): string {
  return d instanceof Date ? d.toISOString() : (d ?? '');
}

async function loadEmployees() {
  try {
    const res = await axios.post('/api/dataset/search', {
      serviceName: 'org/searchEmployees',
      datasets: { ds_search: { status: 'ACTIVE' } }
    });
    employees.value = res.data?.data?.ds_employees?.rows || [];
  } catch {
    employees.value = [];
  }
}

async function handleReserve() {
  if (!form.value.title.trim()) { error('제목을 입력하세요'); return; }
  if (!form.value.roomId) { error('회의실을 선택하세요'); return; }
  if (!form.value.startAt || !form.value.endAt) { error('시간을 입력하세요'); return; }
  if (!(form.value.endAt > form.value.startAt)) {
    error('종료 시간이 시작 시간보다 이후여야 합니다');
    return;
  }
  saving.value = true;
  try {
    const res: any = await room.reserve({
      roomId: form.value.roomId!,
      title: form.value.title,
      startAt: iso(form.value.startAt),
      endAt: iso(form.value.endAt),
      attendees: form.value.attendees.join(',')
    });
    success('예약이 완료되었습니다');
    visible.value = false;
    emit('saved', res?.bookingId || 0);
  } catch (e: any) {
    const msg = e?.response?.data?.message || '예약에 실패했습니다';
    error(msg);
  } finally {
    saving.value = false;
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
.field-note {
  font-size: 0.85rem;
  color: var(--p-orange-600, #ea580c);
  display: inline-flex;
  align-items: center;
  gap: 0.4rem;
}
</style>
