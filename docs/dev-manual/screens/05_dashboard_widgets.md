# screens/05_dashboard_widgets.md — 형태 5: 대시보드 위젯 그리드

> Phase 3.5 산출물. 모범: `[code: ui/src/pages/PageDashboard.vue]`

## 1. 화면 정의

12-column CSS Grid 위에 위젯들을 배치, 편집 모드에서 추가/삭제/리사이즈.

```
┌─ Header (편집 / 위젯추가 / 저장) ────────────┐
├─ 12-Col Grid ─────────────────────────────┤
│ ┌Widget(4×1)─┐ ┌Widget(4×2)─┐               │
│ │ Attendance │ │ LeaveBal   │               │
│ └────────────┘ └────────────┘               │
└─────────────────────────────────────────────┘
```

사용 시나리오: 개인 대시보드 (근태 / 잔여 휴가 / 대기 결재 / 오늘 일정 / 공지 / 업무일지 등 위젯).

## 2. UI 컴포넌트 매핑

| 역할 | 컴포넌트 | 핵심 prop / event |
|---|---|---|
| 그리드 | CSS `grid-template-columns: repeat(12, 1fr)` | `--w` (1-12), `--h` (1-3) CSS vars |
| 카드 | `Card` | header / content slot |
| 액션 | `Button` | 편집/저장/취소 |
| 위젯 picker | `Dialog` (catalog 표시) | — |
| 위젯들 | 각 `Widget*` 컴포넌트 (custom) | code 별 컴포넌트 매핑 |

## 3. 백엔드 API 요구사항

| 메서드 | 경로 | 요청 | 응답 |
|---|---|---|---|
| POST | `/api/dataset/search` | `{ serviceName: "widget/listMine" }` | `{ ds_mine: { rows: [{ widgetCode, w, h, sortOrder }], totalCount } }` |
| POST | `/api/dataset/search` | `{ serviceName: "widget/listAll" }` | `{ ds_catalog: { rows: [{ widgetCode, name, defaultW, defaultH }] } }` |
| POST | `/api/dataset/save` | `{ serviceName: "widget/saveLayout", datasets: { ds_data: [{ _rowType: "I"|"U"|"D", widgetCode, w, h, sortOrder }] } }` | `{ saved: n }` |

## 4. 화면 파일 작성 가이드

```vue
<template>
  <div class="page">
    <header>
      <Button :label="editing ? '취소' : '편집'" @click="toggleEdit" />
      <Button label="위젯 추가" @click="pickerVisible=true" v-if="editing" />
      <Button label="저장" @click="save" v-if="editing" />
    </header>
    <section class="grid-12">
      <div v-for="w in widgets" :key="w.widgetCode" class="cell" :style="{ '--w': w.w, '--h': w.h }">
        <Card>
          <template #header>{{ w.name }}</template>
          <template #content>
            <component :is="widgetMap[w.widgetCode]" />
          </template>
        </Card>
      </div>
    </section>
    <Dialog v-model:visible="pickerVisible">…catalog list…</Dialog>
  </div>
</template>
<style scoped>
.grid-12 { display: grid; grid-template-columns: repeat(12, 1fr); gap: 12px; }
.cell { grid-column: span var(--w); grid-row: span var(--h); }
</style>
```

## 5. 4표

### 표 1. 복사할 파일
| 원본 | 복사 후 | 치환 식별자 | 비고 |
|---|---|---|---|
| `[code: ui/src/pages/PageDashboard.vue]` | `ui/src/pages/Page__DomainPascal__.vue` | `__DomainPascal__`, `__domain-kebab__` | 12-col grid 골격 |
| `[code: ui/src/components/dashboard/Widget*.vue]` (각 위젯) | `ui/src/components/__domain-kebab__/Widget__WidgetName__.vue` | `__WidgetName__`, `__domain-kebab__` | 신규 위젯 추가 시 |

### 표 2. 신규 생성할 파일
| 경로 | 역할 | 골격 출처 |
|---|---|---|
| `ui/src/pages/Page__DomainPascal__.vue` | 대시보드 페이지 | `templates/screen_types/05_dashboard/Page.vue.tmpl` |
| `ui/src/components/__domain-kebab__/Widget__WidgetName__.vue` | 개별 위젯 | `templates/screen_types/05_dashboard/Widget.vue.tmpl` |

### 표 3. 수정할 기존 파일
| 경로 | 수정 위치 | 추가·변경 요약 |
|---|---|---|
| `ui/src/router/index.ts` | children 배열 | route entry |
| `ui/src/pages/Page__DomainPascal__.vue` | `widgetMap` 객체 | 신규 위젯 코드 등록 |

### 표 4. 식별자 치환
| From | To | 적용 범위 |
|---|---|---|
| `__DomainPascal__` | 페이지 명 | Vue |
| `__WidgetName__` | 위젯 컴포넌트 명 | Vue |
| `__widget_code__` | DB widgetCode | DDL + UI |

## 6. 부모-자식·라우터 연동

- 부모: `<component :is="widgetMap[code]">` 동적 컴포넌트
- 위젯들은 자체적으로 fetch (API 호출)
- 편집 모드 토글: snapshot 저장 → 취소 시 복원
- 저장: 변경된 위젯만 모아 `_rowType: 'I'/'U'/'D'` 배치

## 7. 모범 워크스루 — `PageDashboard.vue` 따라가기

1. `onMounted`: `widget/listMine` + `widget/listAll` 동시 호출.
2. count=0 (첫 로그인) 시 백엔드가 DEFAULT_LAYOUT(6 위젯) 자동 시드 → 응답에 6 row.
3. `widgetMap` 정적 매핑: ATTENDANCE → WidgetAttendance, LEAVE_BALANCE → WidgetLeaveBalance, …
4. 편집 모드: 위젯 카드에 ±W/±H/× 오버레이 컨트롤 노출.
5. 저장: 변경된 위젯들 `_rowType: 'U'` + 삭제된 코드 `_rowType: 'D'` 묶어서 `widget/saveLayout` 1회 호출.
