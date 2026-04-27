# Chapter 1.3 — 시스템 아키텍처 (Architecture)

## 1. C4 시스템 컨텍스트 (System Context)

openplatform v3는 **포탈-게이트웨이-코어-외부서비스**의 4계층 구조를 따릅니다. 최종 사용자(브라우저)에서부터 데이터베이스·메일·화상·스토리지까지 모든 상호작용을 담당합니다.

\\\mermaid
graph TB
    User["👤 브라우저<br/>(포탈 사용자)"]
    
    subgraph "v3 Infra (Docker Compose)"
        Traefik["🔀 Traefik<br/>(리버스 프록시)<br/>:80/:443"]
        UI["📱 UI (nginx)<br/>Vue 3 SPA<br/>:19173"]
        BFF["🌉 Backend-BFF<br/>(게이트웨이)<br/>:19091"]
        Core["⚙️ Backend-Core<br/>(도메인 로직)<br/>:19090"]
    end
    
    subgraph "데이터 계층"
        PG["🗄️ PostgreSQL<br/>(platform_v3)<br/>:19432"]
        Redis["💾 Redis<br/>:19379"]
    end
    
    subgraph "외부 서비스 (Federation)"
        KC["🔐 Keycloak<br/>(SSO/OAuth2)<br/>:19281"]
        RC["💬 Rocket.Chat<br/>(메신저)<br/>:19065"]
        SW["📧 Stalwart<br/>(메일)<br/>:19480"]
        LK["📹 LiveKit<br/>(화상)<br/>:19880"]
        MIO["💾 MinIO<br/>(S3 스토리지)<br/>:19900"]
        WIKI["📚 Wiki.js<br/>(위키)<br/>:19001"]
    end
    
    User -->|HTTP(S)| Traefik
    Traefik -->|portal.v3.localhost| UI
    Traefik -->|api.v3.localhost| Core
    Traefik -->|bff.v3.localhost| BFF
    
    UI -->|REST + JWT| Core
    UI -->|BFF 프록시| BFF
    UI -->|SSO 리다이렉트| KC
    
    Core -->|SQL| PG
    Core -->|Cache| Redis
    Core -->|Presigned URL| MIO
    Core -->|HTTP 클라이언트| BFF
    
    BFF -->|OAuth2 token| KC
    BFF -->|HTTP API| RC
    BFF -->|HTTP API| SW
    BFF -->|HTTP API| WIKI
    BFF -->|JWT 발급| LK
    BFF -->|S3 SDK| MIO
    
    KC -->|Auth provider| RC
    KC -->|Auth provider| WIKI

    classDef browser fill:#e1f5ff,stroke:#0277bd
    classDef proxy fill:#fff3e0,stroke:#f57c00
    classDef service fill:#f3e5f5,stroke:#6a1b9a
    classDef storage fill:#e8f5e9,stroke:#2e7d32
    classDef external fill:#fce4ec,stroke:#c2185b
    
    class User browser
    class Traefik,UI,BFF proxy
    class Core service
    class PG,Redis storage
    class KC,RC,SW,LK,MIO,WIKI external
\\\

[src: docker-compose.yml, docker-compose.traefik.yml]

---

## 2. 컨테이너 다이어그램 (Container Diagram)

Docker Compose 환경에서 실행되는 11개 주요 서비스와 내부 3개 애플리케이션의 관계.

**포트 매핑 테이블:**

| 서비스 | 컨테이너 | 호스트 | 용도 |
|--------|---------|--------|------|
| postgres | 5432 | 19432 | 관계형 DB (platform_v3 schema) |
| redis | 6379 | 19379 | 캐시 & 세션 |
| keycloak | 8080 | 19281 | 인증 서버 (openplatform-v3 realm) |
| rocketchat | 3000 | 19065 | 메신저 (mongo 백엔드) |
| mongo | 27017 | (내부) | Rocket.Chat DB (replicaSet rs0) |
| wikijs | 3000 | 19001 | 위키 (postgres 공유) |
| stalwart | 8080 | 19480 | 메일 서버 (LDAP 사용자) |
| openldap | 389 | 19389 | 디렉터리 (사용자 풀) |
| livekit | 7880 | 19880 | 화상회의 (WebSocket) |
| minio | 9000/9001 | 19900/19901 | S3 호환 스토리지 |
| backend-bff | 8080 | 19091 | 게이트웨이 (REST) |
| backend-core | 8080 | 19090 | 도메인 로직 (REST) |
| ui-frontend | 80 | 19173 | SPA 포탈 (Nginx) |

[src: docker-compose.yml]

---

## 3. Backend-BFF — Port-Adapter 아키텍처

Backend-BFF는 헥사고날(육각형) 아키텍처를 따르며, 포탈 UI와 외부 서비스 간의 어댑터 역할을 수행합니다.

**BffController 엔드포인트:**

| 엔드포인트 | 외부 서비스 | 설명 |
|-----------|-----------|------|
| \/api/bff/identity/me\ | Keycloak | 현재 사용자 정보 |
| \/api/bff/identity/users\ | Keycloak | 사용자 관리 (admin 전용) |
| \/api/bff/messages\ | Rocket.Chat | 메시지 조회/송신 |
| \/api/bff/mail/*\ | Stalwart | 메일 조회/송신 (JMAP) |
| \/api/bff/wiki/*\ | Wiki.js | 위키 페이지 CRUD (GraphQL) |
| \/api/bff/video/token\ | LiveKit | 화상회의 토큰 발급 (JWT) |
| \/api/bff/video/room\ | LiveKit | 방 생성/조회 (Twirp) |
| \/api/bff/storage/*\ | MinIO | 파일 업/다운로드 (presigned URL) |

**7개 포트 + 6개 어댑터:**
- IdentityPort → KeycloakIdentityAdapter
- MessagingPort → RocketChatAdapter
- MailPort → StalwartMailAdapter
- WikiPort → WikiJsAdapter
- VideoPort → LiveKitAdapter
- StoragePort → MinioStorageAdapter
- NotificationPort → (미구현)

[src: backend-bff/src/main/java/com/platform/v3/bff]

---

## 4. Backend-Core — 도메인 주도 설계

Backend-Core는 포탈의 핵심 비즈니스 로직을 담당하며, **DataSet 라우터 패턴**으로 모든 비즈니스 작업을 단일 진입점(POST /api/dataset)으로 통합합니다.

**핵심 특징:**
1. **DataSet 라우터 패턴** — {service: "domain/action", params: {...}}로 통합
2. **Flowable BPMN/DMN** — 결재, 연차 승인 등 워크플로우 자동화
3. **MyBatis 기반 영속성** — SQL 명시적 관리
4. **Flyway 버전 관리** — V1~V17 점진적 스키마 진화

**16개 도메인 서비스:**
- ApprovalService (결재)
- LeaveService (연차/휴가)
- AttendanceService (출퇴근)
- RoomService (회의실)
- BoardService (게시판)
- CalendarService (일정)
- DataLibraryService (자료실)
- WorkReportService (업무일지)
- NotificationService (알림)
- + 7개 더 (Org, Menu, Code, Admin 등)

[src: backend-core/src/main/java/com/platform/v3/core, docs/comprehensive/inventory/02_stack_a_backend.md]

---

## 5. HA 토폴로지

### 현재 상태 (단일 Docker Compose)
- 모놀리식 구조
- 단일 호스트
- 재시작 시 다운타임
- 용도: 개발, 데모, 50명 규모 회사

### 권장 미래 상태 (Kubernetes/Swarm)
- 수평 확장 가능
- 고가용성
- 자동 복구
- 용도: 프로덕션 (500명+ 규모)

**마이그레이션 경로:**
1. Phase 14: 현재 상태 완성
2. Phase 15: Docker Swarm 또는 Kubernetes 도입
3. Phase 16: 데이터베이스 이중화
4. Phase 17+: 외부 서비스 클러스터화

---

## 6. 데이터 흐름 — 결재 라이프사이클

### 휴가 결재 신청 → 승인 → 연차 차감

**1단계**: 사용자가 /leave 페이지에서 "휴가 신청" 클릭
**2단계**: POST /api/dataset (form_code='LEAVE')
**3단계**: ApprovalService.submitDocument() - DB 레코드 생성
**4단계**: Flowable BPMN 엔진 - 프로세스 시작
**5단계**: 승인자가 결재 상세에서 "승인" 클릭
**6단계**: ApprovalService.approve() - 상태 갱신
**7단계**: LeaveService.onDocApproved() - 연차 차감 + 캘린더 업데이트
**8단계**: 대시보드 & UI 실시간 갱신 (SSE)

**최종 데이터 상태:**
- ap_document: status='APPROVED'
- ap_approval_line: [APPROVED, APPROVED]
- at_leave_request: status='APPROVED'
- at_leave_balance: used_days 증가 (15.0→13.0)
- at_attendance: 해당 날짜 status='LEAVE'

[src: backend-core/approval, docs/group_ware.md, PHASE14_PRODUCTION_GROUPWARE.md]

---

## 참조

### 구성 파일
- \infra/docker-compose.yml\ — 12개 서비스 정의
- \infra/docker-compose.traefik.yml\ — Traefik 라우팅
- \infra/livekit.yaml\ — LiveKit 설정

### 아키텍처 문서
- \docs/comprehensive/inventory/01_tree.txt\ — 프로젝트 구조
- \docs/comprehensive/inventory/02_stack_a_backend.md\ — Backend-Core
- \docs/comprehensive/inventory/03_stack_b_backend.md\ — Backend-BFF
- \docs/group_ware.md\ — 외부 서비스 API 매뉴얼
- \docs/PHASE14_PRODUCTION_GROUPWARE.md\ — Phase 14 구현 가이드

### 소스코드
- \ackend-core/src/main/java/com/platform/v3/core/\ — 도메인 서비스
- \ackend-bff/src/main/java/com/platform/v3/bff/\ — Port-Adapter
- \ui/src/router/index.ts\ — Vue Router
- \ui/src/composables/\ — DataSet 헬퍼

---

## 다루지 않은 인접 주제

- **Security Deep Dive** — OAuth2, JWT, CSRF/XSS → Chapter 1.5
- **Database Optimization** — 인덱스, 캐시 → Chapter 2.2
- **Monitoring & Observability** — Prometheus, Loki, Grafana → Chapter 3.1
- **Disaster Recovery** — 백업, RTO/RPO → Chapter 3.3

---

**작성일**: 2026-04-27 | **대상 버전**: Phase 14+ | **다이어그램**: 5개 (C4, Container, BFF, Core, HA)
