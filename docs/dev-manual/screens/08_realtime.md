# screens/08_realtime.md — 형태 8: 실시간 협업 (SSE / Video)

> Phase 3.8 산출물. 모범: `[code: ui/src/pages/PageVideo.vue]`, `[code: ui/src/components/layout/NotificationBell.vue]`

## 1. 화면 정의

WebSocket / EventSource SSE / LiveKit Room 연결로 라이브 데이터 sync. reactive 상태로 비동기 업데이트.

```
┌─ Room (dark bg) ─────────────────────────┐
│ 🎥 v3-general (정원 8명)                 │
│ ┌─ Video Grid ──────────────────────┐   │
│ │ [Local]  [김철수]  [이영희]       │   │
│ └────────────────────────────────────┘   │
│ [마이크 OFF][카메라 OFF][나가기]         │
└─────────────────────────────────────────┘
```

사용 시나리오: 비디오 룸, 실시간 알림 (NotificationBell), 출근 broadcast, 업무일지 팀 그리드.

## 2. UI 컴포넌트 매핑

| 역할 | 컴포넌트 | 핵심 prop / event |
|---|---|---|
| 알림 | `OverlayPanel` (button trigger) | `@show`, `@hide` |
| 액션 | `Button` (마이크/카메라/나가기) | — |
| 비디오 타일 | (custom `<video>` element) | `srcObject` (MediaStream) |
| 룸 | `livekit-client` `Room` | `RoomEvent.ParticipantConnected/TrackSubscribed` |
| SSE | `EventSource` (브라우저 native) | `onmessage` |

## 3. 백엔드 API 요구사항

| 메서드 | 경로 | 요청 | 응답 |
|---|---|---|---|
| GET | `/api/notification/subscribe?token={jwt}` | (헤더 X — query token) | SSE event stream |
| POST | `/api/bff/video/token` | `{ roomName }` | `{ token, wsUrl }` |
| WebSocket | `wsUrl` (LiveKit) | `Room.connect(wsUrl, token)` | LiveKit RTC events |

## 4. 화면 파일 작성 가이드

```vue
<!-- Video 룸 예 -->
<template>
  <div class="video-room">
    <h2>🎥 {{ roomName }}</h2>
    <section class="tiles">
      <video v-for="p in participants" :key="p.id" :ref="el => attachTrack(el, p.track)" autoplay playsinline />
    </section>
    <footer>
      <Button :label="micOn ? '마이크 OFF' : '마이크 ON'" @click="toggleMic" />
      <Button :label="camOn ? '카메라 OFF' : '카메라 ON'" @click="toggleCam" />
      <Button label="나가기" severity="danger" @click="leave" />
    </footer>
  </div>
</template>
<script setup lang="ts">
import { Room, RoomEvent, createLocalTracks, Track } from 'livekit-client'
const participants = ref<any[]>([])
let room: Room | null = null

const join = async () => {
  const { token, wsUrl } = (await axios.post('/api/bff/video/token', { roomName })).data.data
  room = new Room()
  room.on(RoomEvent.ParticipantConnected, (p) => participants.value.push({ id: p.identity }))
  room.on(RoomEvent.TrackSubscribed, (track, _, p) => {
    const part = participants.value.find(x => x.id === p.identity)
    if (part) part.track = track
  })
  await room.connect(wsUrl, token)
  const tracks = await createLocalTracks({ audio: true, video: true })
  for (const t of tracks) await room.localParticipant.publishTrack(t)
}
const leave = () => { room?.disconnect(); room = null }
onMounted(join); onUnmounted(leave)
</script>
```

## 5. 4표

### 표 1. 복사할 파일
| 원본 | 복사 후 | 치환 식별자 | 비고 |
|---|---|---|---|
| `[code: ui/src/pages/PageVideo.vue]` | `ui/src/pages/Page__DomainPascal__.vue` (Video 변종) | `__DomainPascal__`, `__roomName__` | LiveKit Room 패턴 |
| `[code: ui/src/components/layout/NotificationBell.vue]` (참고) | (SSE 변종) | — | EventSource 패턴 |

### 표 2. 신규 생성할 파일
| 경로 | 역할 | 골격 출처 |
|---|---|---|
| `ui/src/pages/Page__DomainPascal__.vue` | 실시간 페이지 | `templates/screen_types/08_realtime/Page.vue.tmpl` |

### 표 3. 수정할 기존 파일
| 경로 | 수정 위치 | 추가·변경 요약 |
|---|---|---|
| `ui/src/router/index.ts` | children 배열 | route entry |
| `ui/src/store/notification.ts` (있는 경우) | SSE 연결 | reconnect 처리 |

### 표 4. 식별자 치환
| From | To | 적용 범위 |
|---|---|---|
| `__DomainPascal__` | 컴포넌트 명 | Vue |
| `__roomName__` | LiveKit room | URL/payload |

## 6. 부모-자식·라우터 연동

- 라우트 진입: `onMounted` 에서 connect, `onUnmounted` 에서 disconnect (필수)
- 부모 → 자식 SSE: store 통해 reactive sync
- LiveKit 룸은 페이지 단독 — 자식 다이얼로그 없음

## 7. 모범 워크스루 — `PageVideo.vue` 따라가기

1. `<InputText v-model="roomName">` + `<Button @click="join">`.
2. `axios.post('/api/bff/video/token', { roomName })` → `{ token, wsUrl }`.
3. `new Room()` + `RoomEvent.ParticipantConnected` 리스너 등록 → reactive `participants.value.push(...)`.
4. `RoomEvent.TrackSubscribed` → MediaStreamTrack 을 `<video>` 요소에 attach.
5. `createLocalTracks({ audio: true, video: true })` → `room.localParticipant.publishTrack(track)`.
6. 나가기/페이지 떠남: `room.disconnect()` (필수, 메모리 누수 방지).

NotificationBell 변종 (`[code: ui/src/components/layout/NotificationBell.vue]`):
1. `new EventSource('/api/notification/subscribe?token=' + jwt)`.
2. `es.onmessage = (e) => store.push(JSON.parse(e.data))`.
3. `<OverlayPanel>` 에 unread 알림 list 표시.
4. `onUnmounted`: `es.close()`.
