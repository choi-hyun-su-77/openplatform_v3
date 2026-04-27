# recipes/04_add_external_integration.md — 외부 시스템 연동 추가

> Phase 5.4 산출물. Pattern C(BFF Port-Adapter) 적용 가능. 본 코드베이스는 외부 연동 패턴이 이미 6개 존재.
> 가상 시나리오: **Slack Webhook** 연동 추가 (알림 전송용 신규 외부 시스템).

## 사전 정보

- 외부 시스템: Slack Incoming Webhook
- 능력: 메시지 전송 (`postMessage`)
- 기존 Port: `MessagingPort` 가 Rocket.Chat 전용 → 별도 Port 신설 vs 확장 결정 필요

## 결정

→ `[doc: scaffolds/00_decision_tree.md]`: 외부 호출 → **Pattern C**.

기존 `MessagingPort` 는 Rocket.Chat 전용이므로 신규 Port `__CapabilityPascal__=Webhook` 신설. (Adapter 는 `SlackWebhookAdapter`)

| placeholder | 값 |
|---|---|
| `__CapabilityPascal__` | `Webhook` |
| `__capabilityCamel__` | `webhook` |
| `__ExternalPascal__` | `Slack` |

## 변경 파일 표

| 계층 | 파일 | 변경 |
|---|---|---|
| **BFF Port** | `backend-bff/.../core/port/WebhookPort.java` (신규) | `interface WebhookPort { Mono<Void> postMessage(String url, String text); }` |
| **BFF Adapter** | `backend-bff/.../adapter/SlackWebhookAdapter.java` (신규) | `WebClient` 로 Slack 웹훅 POST |
| **BFF Controller** | `backend-bff/.../api/WebhookController.java` (신규) | `/api/bff/webhook/slack` 진입점 |
| **BFF 설정** | `backend-bff/src/main/resources/application.yml` | `webhook.slack.default-url` 환경변수 추가 |
| **backend-core 연동** | `backend-core/.../some/SomeService.java` | `bffClient.post("/api/bff/webhook/slack", ...)` |
| **DB 메타데이터** | (선택) `V{N+1}__webhook_config.sql` | 사용자별 webhook URL 저장 시 |
| **UI 설정 페이지** | (선택) `ui/src/pages/admin/PageWebhook.vue` (형태 1 또는 9) | webhook URL 관리 |

## 단계 절차

### Step 1 — BFF Port 정의

`backend-bff/src/main/java/com/platform/v3/bff/port/WebhookPort.java`:
```java
package com.platform.v3.bff.port;

import reactor.core.publisher.Mono;

public interface WebhookPort {
    Mono<Void> postMessage(String url, String text);
}
```

### Step 2 — BFF Adapter 구현

`backend-bff/.../adapter/SlackWebhookAdapter.java`:
```java
@Component
@RequiredArgsConstructor
public class SlackWebhookAdapter implements WebhookPort {
    private final WebClient webClient = WebClient.create();

    @Override
    public Mono<Void> postMessage(String url, String text) {
        return webClient.post()
            .uri(url)
            .bodyValue(Map.of("text", text))
            .retrieve()
            .bodyToMono(Void.class)
            .doOnError(e -> LoggerFactory.getLogger(getClass()).warn("slack webhook failed url={}", url, e));
    }
}
```

### Step 3 — BFF Controller

`backend-bff/.../api/WebhookController.java`:
```java
@RestController
@RequestMapping("/api/bff/webhook")
@RequiredArgsConstructor
public class WebhookController {
    private final WebhookPort webhookPort;

    @PostMapping("/slack")
    public Mono<ApiResponse<Void>> slack(@RequestBody SlackPayload p) {
        return webhookPort.postMessage(p.url(), p.text())
            .then(Mono.fromCallable(() -> ApiResponse.<Void>ok(null)));
    }

    public record SlackPayload(String url, String text) {}
}
```

### Step 4 — BFF 설정

`backend-bff/src/main/resources/application.yml`:
```yaml
webhook:
  slack:
    default-url: ${SLACK_WEBHOOK_URL:}
```

### Step 5 — backend-core 호출

`SomeService` 가 알림 발생 시:
```java
bffClient.post("/api/bff/webhook/slack",
    Map.of("url", slackUrl, "text", "[v3] 새 결재 도착: " + docTitle));
```

### Step 6 — UI 설정 (선택, 형태 9 매트릭스)

`ui/src/pages/admin/PageWebhook.vue` — webhook URL 관리 페이지(폼 매트릭스).

### Step 7 — 검증

1. `application.yml` 의 `SLACK_WEBHOOK_URL` 환경변수 설정
2. backend-bff health: `curl http://localhost:19091/actuator/health`
3. Postman: `POST /api/bff/webhook/slack { "url": "<webhook>", "text": "test" }` → 200 OK + Slack 채널 메시지 확인
4. backend-core 호출 흐름 검증 (실제 결재 신청 → Slack 메시지 도착)
5. 실패 케이스: 잘못된 URL → 200 OK 응답하되 backend-bff 로그에 `slack webhook failed` warn

## Pattern C 워크스루 매핑

→ `[doc: scaffolds/03_pattern_c_bff_adapter.md]` 의 Step 1~12 따라감.

| Pattern C Step | 본 레시피의 위치 |
|---|---|
| Step 1 식별자 결정 | 사전 정보 / placeholder 표 |
| Step 2 영속 (선택) | (해당 없음 — Slack URL 만 환경변수) |
| Step 3 메뉴 등록 | (선택) admin webhook 페이지 메뉴 |
| Step 4 Port + Adapter | Step 1, 2 |
| Step 5 backend-core Service | Step 5 |
| Step 6 진입점 | Step 3 (BFF Controller) |
| Step 7 컨벤션 | warn 로그 + ApiResponse |
| Step 8 화면 | Step 6 (선택) |
| Step 9 라우터/메뉴 | (선택, admin 라우트) |
| Step 10 테스트 | Step 7 |
| Step 11 자기검증 | 아래 체크 |
| Step 12 PR | feat(webhook): Slack 연동 추가 |

## 자기검증 체크

- [ ] Port 인터페이스가 reactive (Mono/Flux)
- [ ] Adapter 가 `WebClient` 사용
- [ ] BFF Controller path `/api/bff/webhook/...`
- [ ] 외부 호출 실패는 warn 로그, primary tx rollback X
- [ ] 토큰/URL 평문 로깅 없음
- [ ] backend-bff `application.yml` 환경변수 매핑

> 본 코드베이스에 외부 연동 패턴이 이미 6개(Identity/Storage/Messaging/Video/Mail/Wiki)이므로 Pattern C 가 안정적으로 검증된 상태. 신규 시스템 추가 시 동일 패턴 그대로 따라가면 됨.
