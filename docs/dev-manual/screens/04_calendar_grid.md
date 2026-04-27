# screens/04_calendar_grid.md — 형태 4: 캘린더 그리드

> Phase 3.4 산출물. 모범: `[code: ui/src/pages/PageCalendar.vue]`

## 1. 화면 정의

FullCalendar 로 month/week/day 그리드 렌더, 이벤트 클릭/드래그/리사이즈 → 다이얼로그 편집.

```
┌─ Toolbar (Scope + Add Event) ─────────────────┐
├─ FullCalendar Grid ───────────────────────────┤
│ Mon | Tue | Wed | Thu | Fri | Sat | Sun       │
│       [회의]    [휴가]                          │
└──────────────────────────────────────────────┘
```

사용 시나리오: 개인/팀 일정, 회의실 예약, 업무일지 일자 선택.

## 2. UI 컴포넌트 매핑

| 역할 | 컴포넌트 | 핵심 prop / event |
|---|---|---|
| 캘린더 | `FullCalendar` (외부) | `:options` (plugins, initialView, events, dateClick, eventClick, eventDrop, eventResize) |
| 뷰 토글 | `SelectButton` | `:options=[{label:'월',v:'dayGridMonth'},...]` |
| 범위 필터 | `SelectButton` | PERSONAL/DEPT/COMPANY |
| 이벤트 다이얼로그 | `Dialog` | (형태 2 SOP 위임) |

## 3. 백엔드 API 요구사항

| 메서드 | 경로 | 요청 | 응답 |
|---|---|---|---|
| POST | `/api/dataset/search` | `{ serviceName: "calendar/searchEvents", datasets: { ds_search: { startDt, endDt, scope } } }` | `{ ds_events: { rows: [{ id, title, startDt, endDt, color, scope }] } }` |
| POST | `/api/dataset/save` | `{ serviceName: "calendar/saveEvents", datasets: { ds_data: [{ _rowType: "I"|"U"|"D", id, ... }] } }` | `{ saved: n }` |

## 4. 화면 파일 작성 가이드

```vue
<template>
  <div class="page">
    <SelectButton v-model="scope" :options="scopeOptions" optionLabel="label" optionValue="value" />
    <FullCalendar :options="calOptions" />
    <CalendarEventDialog v-model:visible="dlgVisible" :event="selectedEvent" @saved="reload" />
  </div>
</template>
<script setup lang="ts">
import FullCalendar from '@fullcalendar/vue3'
import dayGridPlugin from '@fullcalendar/daygrid'
import timeGridPlugin from '@fullcalendar/timegrid'
import interactionPlugin from '@fullcalendar/interaction'
const calOptions = computed(() => ({
  plugins: [dayGridPlugin, timeGridPlugin, interactionPlugin],
  initialView: 'dayGridMonth',
  events: events.value,
  editable: true,
  eventClick: (e) => { selectedEvent.value = e.event; dlgVisible.value = true },
  eventDrop: (e) => batchSave([{ _rowType: 'U', id: e.event.id, startDt: e.event.start, endDt: e.event.end }]),
  eventResize: (e) => batchSave([{ _rowType: 'U', id: e.event.id, endDt: e.event.end }]),
  dateClick: (e) => { selectedEvent.value = { startDt: e.dateStr }; dlgVisible.value = true }
}))
</script>
```

## 5. 4표

### 표 1. 복사할 파일
| 원본 | 복사 후 | 치환 식별자 | 비고 |
|---|---|---|---|
| `[code: ui/src/pages/PageCalendar.vue]` | `ui/src/pages/Page__DomainPascal__.vue` | `__DomainPascal__`, `__domain-kebab__` | scope 옵션 + plugin 조합 |
| `[code: ui/src/components/calendar/CalendarEventDialog.vue]` | `ui/src/components/__domain-kebab__/__DomainPascal__EventDialog.vue` | `__DomainPascal__` | 형태 2 SOP 패턴 |

### 표 2. 신규 생성할 파일
| 경로 | 역할 | 골격 출처 |
|---|---|---|
| `ui/src/pages/Page__DomainPascal__.vue` | 캘린더 페이지 | `templates/screen_types/04_calendar/Page.vue.tmpl` |
| `ui/src/components/__domain-kebab__/__DomainPascal__EventDialog.vue` | 이벤트 편집 다이얼로그 | (형태 2 SOP) |

### 표 3. 수정할 기존 파일
| 경로 | 수정 위치 | 추가·변경 요약 |
|---|---|---|
| `ui/src/router/index.ts` | children 배열 | route entry |
| `ui/package.json` | dependencies | (이미 포함됨 — `@fullcalendar/vue3`) |

### 표 4. 식별자 치환
| From | To | 적용 범위 |
|---|---|---|
| `__DomainPascal__` | 컴포넌트 명 | Vue |
| `__domain-kebab__` | serviceName | API |

## 6. 부모-자식·라우터 연동

- `<FullCalendar :options="calOptions">` → `eventClick/dateClick` → `dlgVisible=true`
- `<CalendarEventDialog v-model:visible :event @saved>` → 저장 시 부모 `reload()`
- 라우터 path 단순(`/calendar`)

## 7. 모범 워크스루 — `PageCalendar.vue` 따라가기

1. `<SelectButton v-model="scope">` (PERSONAL/DEPT/COMPANY) + `<SelectButton v-model="view">` (month/week/day).
2. `events` computed: `axios.post('/api/dataset/search', { serviceName: 'calendar/searchEvents', datasets: { ds_search: { startDt, endDt, scope } } })`.
3. `<FullCalendar :options>` 의 `eventClick` 핸들러가 `<CalendarEventDialog>` 오픈.
4. `eventDrop`/`eventResize` 가 단일 row `_rowType: 'U'` 로 `calendar/saveEvents` 호출 → 즉시 반영.
5. `dateClick` → 신규 이벤트 다이얼로그 (시작일 미리 채움).
