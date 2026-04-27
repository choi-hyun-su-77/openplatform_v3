<template>
  <div class="page-room">
    <h2>회의실 예약</h2>
    <div class="layout">
      <!-- ── 좌측: 회의실 목록 + 필터 ── -->
      <aside class="sidebar">
        <div class="filter-bar">
          <InputText v-model="filter.keyword" placeholder="회의실 검색" class="w-full"
                     @input="onFilterChange" />
          <div class="filter-row">
            <label class="cap-label">최소 인원</label>
            <InputNumber v-model="filter.minCapacity" :min="0" :max="100" showButtons
                         buttonLayout="horizontal" :step="2" class="cap-input"
                         @input="onFilterChange" />
          </div>
          <label class="check-label">
            <Checkbox v-model="filter.hasVideo" binary @change="onFilterChange" />
            화상회의 가능
          </label>
        </div>
        <div class="room-list">
          <div v-if="loadingRooms" class="loading">불러오는 중...</div>
          <div v-else-if="!rooms.length" class="empty">조건에 맞는 회의실이 없습니다</div>
          <RoomCard v-for="r in rooms" :key="r.roomId" :room="r"
                    :selected="selectedRoom?.roomId === r.roomId"
                    @select="onRoomSelect" />
        </div>
        <Button label="예약하기" icon="pi pi-plus" class="reserve-btn"
                :disabled="!selectedRoom" @click="openDialogForCurrentRoom" />
      </aside>

      <!-- ── 우측: FullCalendar (timeGridWeek) ── -->
      <section class="calendar-area">
        <div class="cal-head">
          <strong v-if="selectedRoom">
            {{ selectedRoom.roomName }}
            <span class="muted">정원 {{ selectedRoom.capacity }}명</span>
          </strong>
          <span v-else class="muted">회의실을 선택하면 예약 현황이 표시됩니다</span>
        </div>
        <FullCalendar ref="calRef" :options="calendarOptions" />
      </section>
    </div>

    <BookingDialog v-model:visible="dialogVisible" :rooms="rooms"
                   :preselectedRoomId="selectedRoom?.roomId"
                   :initialStart="dialogStart" :initialEnd="dialogEnd"
                   @saved="onSaved" />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import FullCalendar from '@fullcalendar/vue3';
import dayGridPlugin from '@fullcalendar/daygrid';
import timeGridPlugin from '@fullcalendar/timegrid';
import interactionPlugin from '@fullcalendar/interaction';
import InputText from 'primevue/inputtext';
import InputNumber from 'primevue/inputnumber';
import Checkbox from 'primevue/checkbox';
import Button from 'primevue/button';
import RoomCard from '@/components/room/RoomCard.vue';
import BookingDialog from '@/components/room/BookingDialog.vue';
import { useRoom, type Room, type Booking } from '@/composables/useRoom';
import { useMessage } from '@/composables/useMessage';
import { useAuthStore } from '@/store/auth';

const room = useRoom();
const { error: showError, success } = useMessage();
const auth = useAuthStore();

const calRef = ref<InstanceType<typeof FullCalendar> | null>(null);

const rooms = ref<Room[]>([]);
const allRooms = ref<Room[]>([]);
const bookings = ref<Booking[]>([]);
const selectedRoom = ref<Room | null>(null);
const loadingRooms = ref(false);

const dialogVisible = ref(false);
const dialogStart = ref<Date | null>(null);
const dialogEnd = ref<Date | null>(null);

const filter = ref({
  keyword: '',
  minCapacity: null as number | null,
  hasVideo: false
});

let filterTimer: number | null = null;
function onFilterChange() {
  if (filterTimer) window.clearTimeout(filterTimer);
  filterTimer = window.setTimeout(() => applyFilter(), 200);
}

function applyFilter() {
  const kw = (filter.value.keyword || '').toLowerCase();
  rooms.value = allRooms.value.filter(r => {
    if (kw && !r.roomName.toLowerCase().includes(kw)
        && !(r.location || '').toLowerCase().includes(kw)) return false;
    if (filter.value.minCapacity != null && r.capacity < filter.value.minCapacity) return false;
    if (filter.value.hasVideo && !r.hasVideo) return false;
    return true;
  });
  // 선택된 회의실이 필터에서 제외되면 선택 해제
  if (selectedRoom.value && !rooms.value.find(r => r.roomId === selectedRoom.value!.roomId)) {
    selectedRoom.value = rooms.value[0] || null;
    if (selectedRoom.value) loadBookings();
    else bookings.value = [];
  }
}

async function loadRooms() {
  loadingRooms.value = true;
  try {
    const list = await room.searchRooms({});
    allRooms.value = list;
    rooms.value = [...list];
    if (!selectedRoom.value && rooms.value.length) {
      selectedRoom.value = rooms.value[0];
      await loadBookings();
    }
  } catch (e) {
    showError('회의실 목록을 불러올 수 없습니다');
  } finally {
    loadingRooms.value = false;
  }
}

async function loadBookings() {
  if (!selectedRoom.value) {
    bookings.value = [];
    return;
  }
  try {
    const now = new Date();
    const from = new Date(now.getFullYear(), now.getMonth() - 1, 1).toISOString();
    const to = new Date(now.getFullYear(), now.getMonth() + 2, 0).toISOString();
    bookings.value = await room.searchBookings(selectedRoom.value.roomId, from, to);
  } catch (e) {
    bookings.value = [];
  }
}

function onRoomSelect(r: Room) {
  selectedRoom.value = r;
  loadBookings();
}

const calendarEvents = computed(() =>
  bookings.value.map(b => ({
    id: String(b.bookingId),
    title: b.title + (b.bookerNo ? ' (' + b.bookerNo + ')' : ''),
    start: b.startAt,
    end: b.endAt,
    color: b.bookerNo === currentUserNo() ? '#06b6d4' : '#6366f1',
    extendedProps: { ...b }
  }))
);

function currentUserNo(): string {
  return auth.user?.employeeNo || auth.user?.userId || '';
}

const calendarOptions = computed(() => ({
  plugins: [dayGridPlugin, timeGridPlugin, interactionPlugin],
  initialView: 'timeGridWeek',
  headerToolbar: {
    left: 'prev,next today',
    center: 'title',
    right: 'timeGridDay,timeGridWeek,dayGridMonth'
  },
  locale: 'ko',
  height: 'calc(100vh - 220px)',
  slotMinTime: '06:00:00',
  slotMaxTime: '22:00:00',
  allDaySlot: false,
  selectable: !!selectedRoom.value,
  selectMirror: true,
  events: calendarEvents.value,
  select: handleDateSelect,
  eventClick: handleEventClick,
  nowIndicator: true
}));

function handleDateSelect(info: any) {
  if (!selectedRoom.value) {
    showError('먼저 좌측에서 회의실을 선택하세요');
    return;
  }
  dialogStart.value = new Date(info.startStr);
  dialogEnd.value = new Date(info.endStr);
  dialogVisible.value = true;
}

function handleEventClick(info: any) {
  const b: Booking = info.event.extendedProps;
  // 본인 예약이면 취소 다이얼로그
  if (b.bookerNo === currentUserNo()) {
    if (confirm(`'${b.title}' 예약을 취소하시겠습니까?`)) {
      cancelBooking(b.bookingId);
    }
  }
}

async function cancelBooking(bookingId: number) {
  try {
    await room.cancel(bookingId);
    success('예약이 취소되었습니다');
    await loadBookings();
  } catch (e: any) {
    const msg = e?.response?.data?.message || '취소에 실패했습니다';
    showError(msg);
  }
}

function openDialogForCurrentRoom() {
  if (!selectedRoom.value) return;
  const start = new Date();
  start.setMinutes(0, 0, 0);
  start.setHours(start.getHours() + 1);
  const end = new Date(start.getTime() + 60 * 60 * 1000);
  dialogStart.value = start;
  dialogEnd.value = end;
  dialogVisible.value = true;
}

function onSaved() {
  loadBookings();
}

onMounted(() => {
  loadRooms();
});
</script>

<style scoped>
.page-room { padding: 1.25rem; }
.page-room h2 { margin: 0 0 0.75rem 0; }

.layout {
  display: flex;
  gap: 1rem;
  align-items: stretch;
}
.sidebar {
  width: 240px;
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}
.filter-bar {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  padding: 0.5rem;
  background: var(--p-surface-50, #f9fafb);
  border-radius: 8px;
}
.filter-row {
  display: flex;
  align-items: center;
  gap: 0.4rem;
  font-size: 0.85rem;
}
.cap-label { width: 64px; }
.cap-input { flex: 1; }
.cap-input :deep(.p-inputnumber-input) { width: 60px; }
.check-label {
  font-size: 0.85rem;
  display: inline-flex;
  align-items: center;
  gap: 0.4rem;
}
.w-full { width: 100%; }

.room-list {
  flex: 1;
  overflow-y: auto;
  max-height: calc(100vh - 360px);
  padding-right: 2px;
}
.loading, .empty {
  text-align: center;
  padding: 1rem;
  color: var(--p-text-muted-color, #6b7280);
  font-size: 0.85rem;
}
.reserve-btn { width: 100%; }

.calendar-area {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}
.cal-head {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 1rem;
}
.muted { color: var(--p-text-muted-color, #6b7280); font-weight: 400; font-size: 0.85rem; }
</style>
