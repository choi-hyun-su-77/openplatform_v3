# screens/07_sso_wrapper.md — 형태 7: SSO 래퍼 (외부 시스템 진입)

> Phase 3.7 산출물. 모범: `[code: ui/src/pages/PageWiki.vue]`

## 1. 화면 정의

Keycloak SSO 로 외부 시스템(Wiki.js / Rocket.Chat / Mail / MinIO Console / LiveKit) 진입. 임베디드 iframe 사용 X. `window.open(ssoUrl, '_blank')`.

```
┌─ Page ─────────────────────────────────────┐
│ ┌ SSO Panel (gradient bg) ────────────────┐ │
│ │ 📖 위키 (Wiki.js)                         │ │
│ │ Keycloak SSO 로 위키 열기                  │ │
│ │ [위키 열기] (외부 링크)                    │ │
│ └──────────────────────────────────────────┘ │
└────────────────────────────────────────────┘
```

사용 시나리오: 외부 시스템 launcher (5종).

## 2. UI 컴포넌트 매핑

| 역할 | 컴포넌트 | 핵심 prop / event |
|---|---|---|
| 진입 버튼 | `Button` | `:label`, `@click` |
| 카드 | `Card` (선택) | gradient bg |
| 룸 이름 입력 (Video) | `InputText` | — |
| 룸 입장 (Video) | LiveKit `Room` | `Room.connect(wsUrl, token)` |
| 메일 IMAP UI (Mail) | `Tree` (mailbox) + `DataTable` (list) + iframe? | — |

## 3. 백엔드 API 요구사항

| 메서드 | 경로 | 요청 | 응답 |
|---|---|---|---|
| 외부 OAuth | (브라우저) `${kcBase}/realms/${realm}/protocol/openid-connect/auth?...` | (외부) | (외부) redirect |
| Video token | POST `/api/bff/video/token` | `{ roomName }` | `{ token, wsUrl }` |
| Mail mailboxes | GET `/api/bff/mail/mailboxes` | — | `{ rows: [...] }` |
| Mail email | GET `/api/bff/mail/email/:id` | — | `{ subject, body, ... }` |

## 4. 화면 파일 작성 가이드

```vue
<template>
  <div class="page sso-wrapper">
    <Card>
      <template #header>📖 {{ t('LBL___DOMAIN_UPPER___TITLE') }}</template>
      <template #content>
        <p>Keycloak SSO 로 {{ t('LBL___DOMAIN_UPPER___NAME') }} 열기</p>
        <Button :label="`${t('LBL_OPEN')} ${t('LBL___DOMAIN_UPPER___NAME')}`" @click="open" />
      </template>
    </Card>
  </div>
</template>
<script setup lang="ts">
import { useAuthStore } from '@/store/auth'
const auth = useAuthStore()
const open = () => {
  const params = new URLSearchParams({
    client_id: '__client_id__',
    redirect_uri: '__external_url__',
    response_type: 'code',
    scope: 'openid email profile',
    state: crypto.randomUUID()
  })
  window.open(`${auth.kcBase}/realms/${auth.realm}/protocol/openid-connect/auth?${params}`, '_blank')
}
</script>
```

## 5. 4표

### 표 1. 복사할 파일
| 원본 | 복사 후 | 치환 식별자 | 비고 |
|---|---|---|---|
| `[code: ui/src/pages/PageWiki.vue]` | `ui/src/pages/Page__DomainPascal__.vue` | `__DomainPascal__`, `__client_id__`, `__external_url__` | 단순 SSO 진입 |
| `[code: ui/src/pages/PageVideo.vue]` (참고) | (LiveKit 추가 시) | — | 룸 입장 패턴 |
| `[code: ui/src/pages/PageMessenger.vue]` (참고) | (RC 추가 시) | — | 커스텀 OAuth callback |

### 표 2. 신규 생성할 파일
| 경로 | 역할 | 골격 출처 |
|---|---|---|
| `ui/src/pages/Page__DomainPascal__.vue` | SSO 래퍼 페이지 | `templates/screen_types/07_sso/Page.vue.tmpl` |

### 표 3. 수정할 기존 파일
| 경로 | 수정 위치 | 추가·변경 요약 |
|---|---|---|
| `ui/src/router/index.ts` | children 배열 | route entry |
| `infra/keycloak/realm-export.json` | clients 배열 | 새 OIDC client 추가 (관리자 작업) |
| `backend-bff/src/main/resources/application.yml` | downstream URL 섹션 | 외부 시스템 URL 환경변수 |

### 표 4. 식별자 치환
| From | To | 적용 범위 |
|---|---|---|
| `__DomainPascal__` | 페이지 명 | Vue |
| `__client_id__` | Keycloak client | OAuth URL |
| `__external_url__` | 외부 시스템 URL | redirect_uri |
| `__DOMAIN_UPPER__` | i18n 키 | 라벨 |

## 6. 부모-자식·라우터 연동

- 라우터: `meta.menuId='__domain-kebab__'`
- 자식 다이얼로그/패널 없음 (단순 launcher)
- LiveKit/Mail 같은 변종은 자체 상태 관리

## 7. 모범 워크스루 — `PageWiki.vue` 따라가기

1. `<Card>` + `<Button label="위키 열기">` 단순 구조.
2. 클릭: OAuth URL 구성 — `client_id=wiki-js`, `redirect_uri=http://kc.localtest.me:19001/login/keycloak/callback`, `response_type=code`, `scope=openid email profile`, `state=uuid`.
3. `window.open(url, '_blank')` → 브라우저 새 탭에서 Keycloak 로그인 페이지 표시.
4. 이미 로그인된 세션이 있으면 자동 redirect 후 Wiki.js 가 로컬 사용자 생성/매핑.
5. PageVideo 변종: `<InputText v-model="roomName">` + 입장 버튼 → `/api/bff/video/token` POST → LiveKit `Room.connect(wsUrl, token)` (형태 8 와 결합).
