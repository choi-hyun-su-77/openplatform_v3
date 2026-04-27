# Chapter 1.5: API Specification & Integration Guide

**문서 버전**: v3.0 (Phase 14 기반)  
**대상 시스템**: openplatform_v3 백엔드 (backend-core 19090, backend-bff 19091)  
**마지막 업데이트**: 2026-04-27

---

## 목차

1. [API 게이트웨이 아키텍처](#1-api-게이트웨이-아키텍처)
2. [DataSet 단일 엔드포인트](#2-dataset-단일-엔드포인트)
3. [DataSetServiceMapping 어노테이션](#3-datasetsermicemapping-어노테이션)
4. [BFF /api/bff/* 엔드포인트](#4-bff-apibff-엔드포인트)
5. [권한 및 인증](#5-권한-및-인증)
6. [페이지네이션·정렬·필터 규약](#6-페이지네이션정렬필터-규약)
7. [응답 포맷 & 에러 처리](#7-응답-포맷--에러-처리)
8. [외부 서비스 직통 호출](#8-외부-서비스-직통-호출)
9. [참조](#9-참조)

---

## 1. API 게이트웨이 아키텍처

v3 는 **마이크로서비스 기반**의 다층 API 구조를 제공합니다.

### 1.1 계층 구분

| 계층 | 포트 | 베이스 경로 | 특징 | 담당 파일 |
|---|---|---|---|---|
| **Core API** | 19090 | `/api/dataset` (단일) + `/api/notification`, `/api/codes`, `/api/i18n` | 비즈니스 로직 중심, 서비스 레지스트리 패턴 | `backend-core` |
| **BFF** | 19091 | `/api/bff/*` | 외부 서비스 프록시 + JWT 발급 | `backend-bff` |
| **인증 서버** | 19281 | `/auth` | Keycloak OAuth2/OIDC | Keycloak |

### 1.2 라우팅 규칙

```
브라우저 요청
  ├─ /api/dataset/* → DataSetController (POST 단일 진입점)
  ├─ /api/bff/* → BffController (마이크로 엔드포인트)
  ├─ /api/notification/* → NotificationController (SSE)
  ├─ /api/codes → CodeController (공통코드)
  ├─ /api/i18n/{locale} → I18nController (다국어)
  └─ /actuator/health → Spring Health (공개)
```

---

## 2. DataSet 단일 엔드포인트

### 2.1 개요

**DataSet** 은 모든 비즈니스 로직을 단일 POST 진입점(`/api/dataset/{search|save|search-save}`)을 통해 라우팅하는 **역동적 서비스 디스패치 패턴**입니다.

- **목표**: 복잡한 CRUD 요청을 `serviceName` 기반으로 분류하여 올바른 핸들러에 전달
- **장점**: 새로운 서비스 추가 시 컨트롤러 수정 불필요 (어노테이션 기반 자동 등록)
- **보안**: JWT 인증 필수, 모든 요청에서 `currentUser` 정규화

### 2.2 엔드포인트 목록

| 메서드 | 경로 | 설명 | 인증 | 용례 |
|---|---|---|---|---|
| POST | `/api/dataset/search` | 조회 (read-only) | JWT | `approval/searchInbox`, `org/searchEmployees` |
| POST | `/api/dataset/save` | 저장/수정 (transactional) | JWT | `approval/saveDraft`, `calendar/saveEvents` |
| POST | `/api/dataset/search-save` | 저장 후 재조회 | JWT | 승인 후 목록 새로고침 |

### 2.3 요청 페이로드 형식

```json
POST /api/dataset/search
Content-Type: application/json
Authorization: Bearer <JWT>

{
  "serviceName": "org/searchEmployees",
  "ds_search": {
    "deptId": 10,
    "keyword": "길동",
    "pageNo": 1,
    "pageSize": 20,
    "sortField": "employeeNo",
    "sortOrder": "ASC"
  }
}
```

**필드 설명**:

| 필드 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `serviceName` | String | Yes | `domain/method` 형식 (e.g., `approval/submitDocument`) |
| `ds_search` | Object | No | 검색/필터 파라미터. `pageNo`, `pageSize`, `sortField`, `sortOrder` 포함 가능 |
| `ds_*` (기타) | Object | No | 추가 데이터셋. 예: `ds_rows` (행 데이터), `ds_detail` (상세 정보) |

### 2.4 동작 흐름 (코드 인용)

**DataSetController.search()** (backend-core/src/main/java/com/platform/v3/core/dataset/DataSetController.java:32-41):

```java
@PostMapping("/search")
public ApiResponse<Map<String, Object>> search(
        @RequestBody Map<String, Object> body,
        Authentication authentication
) {
    String serviceName = (String) body.get("serviceName");
    Map<String, Object> datasets = extractDatasets(body);
    String user = currentUser(authentication);
    return ApiResponse.ok(dataSetService.search(serviceName, datasets, user));
}
```

**ServiceRegistry.execute()** (backend-core/src/main/java/com/platform/v3/core/dataset/ServiceRegistry.java:62-79):

```java
public Map<String, Object> execute(String serviceName, Map<String, Object> datasets, String currentUser) {
    ServiceMethodHolder holder = registry.get(serviceName);
    if (holder == null) {
        throw BusinessException.notFound("Service not found: " + serviceName);
    }
    try {
        Object result = holder.method().invoke(holder.bean(), datasets, currentUser);
        if (result == null) return Map.of();
        if (result instanceof Map<?, ?> map) return (Map<String, Object>) map;
        throw new IllegalStateException("DataSet service must return Map<String,Object>");
    } catch (InvocationTargetException e) {
        Throwable cause = e.getCause();
        if (cause instanceof RuntimeException re) throw re;
        throw new RuntimeException(cause);
    }
}
```

**currentUser 정규화** (backend-core/src/main/java/com/platform/v3/core/dataset/DataSetController.java:87-113):

```java
private String currentUser(Authentication auth) {
    if (auth == null) return "anonymous";
    Object principal = auth.getPrincipal();
    String username = null;
    if (principal instanceof Jwt jwt) {
        username = jwt.getClaimAsString("preferred_username");
        if (username == null) username = jwt.getSubject();
    } else {
        username = auth.getName();
    }
    if (username == null || username.isBlank()) return "anonymous";
    try {
        Map<String, Object> emp = orgMapper.findEmployeeByKeycloakUserId(username);
        if (emp != null) {
            Object empNo = emp.get("employeeNo");
            if (empNo == null) empNo = emp.get("employee_no");
            if (empNo != null) {
                return empNo.toString();  // 정규화: username → employeeNo
            }
        }
    } catch (Exception e) {
        log.warn("currentUser keycloak→employee_no 매핑 실패: {}", username);
    }
    return username;  // fallback
}
```

**주의**: 모든 도메인 서비스는 `currentUser` 가 항상 `employee_no` (e.g., `E0001`) 형식이라고 가정할 수 있습니다.

### 2.5 응답 포맷

```json
{
  "success": true,
  "data": {
    "rows": [
      { "deptId": 10, "deptName": "개발팀", ... },
      { "deptId": 11, "deptName": "운영팀", ... }
    ],
    "totalCount": 2
  },
  "message": null,
  "error": null
}
```

---

## 3. DataSetServiceMapping 어노테이션

### 3.1 개요

`@DataSetServiceMapping` 는 메서드 레벨 어노테이션으로, 해당 메서드를 **ServiceRegistry** 에 자동 등록합니다.

**정의** (backend-core/src/main/java/com/platform/v3/core/dataset/DataSetServiceMapping.java):

```java
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface DataSetServiceMapping {
    String value();  // e.g., "org/searchDeptTree"
}
```

### 3.2 사용 예시

**CalendarService.java** (backend-core/src/main/java/com/platform/v3/core/calendar/CalendarService.java:38-51):

```java
@DataSetServiceMapping("calendar/searchEvents")
public Map<String, Object> searchEvents(Map<String, Object> datasets, String currentUser) {
    Map<String, Object> s = DataSetSupport.getSearchParams(datasets);
    Long deptId = DataSetSupport.toLong(s.get("deptId"));
    String startDt = DataSetSupport.toStr(s.get("startDt"));
    String endDt = DataSetSupport.toStr(s.get("endDt"));

    List<Map<String, Object>> events = new ArrayList<>(calendarMapper.selectEvents(
            DataSetSupport.toLong(s.get("ownerId")),
            deptId,
            startDt,
            endDt,
            DataSetSupport.toStr(s.get("eventType"))
    ));
    // ... 추가 로직
    return DataSetSupport.rows(events);
}
```

### 3.3 ServiceRegistry 자동 등록

**ServiceRegistry** 는 Spring 애플리케이션 시작 시 어노테이션을 자동으로 스캔합니다. 로그:

```
INFO DataSet service registered: calendar/searchEvents -> CalendarService#searchEvents
INFO ServiceRegistry initialized with 35 services
```

---

## 4. BFF /api/bff/* 엔드포인트

### 4.1 개요

**BFF (Backend for Frontend)** 는 외부 서비스를 프록시하는 어댑터 계층입니다.

| 메서드 | 경로 | 서비스 | 인증 |
|---|---|---|---|
| GET | `/identity/me` | IdentityPort | JWT |
| GET | `/messenger/channels` | MessagingPort | JWT |
| POST | `/messenger/messages` | MessagingPort | JWT |
| GET | `/mail/emails` | MailPort | JWT |
| POST | `/mail/send` | MailPort | JWT |
| GET | `/wiki/search` | WikiPort | JWT |
| POST | `/video/token` | VideoPort | JWT |
| GET | `/storage/presigned` | StoragePort | JWT |

---

## 5. 권한 및 인증

### 5.1 인증 방식

| 방식 | 대상 | 검증 |
|---|---|---|
| **JWT (Bearer)** | DataSet, BFF | Keycloak JWK 서명 검증 |
| **공개** | /api/codes, /api/i18n | 인증 불필요 |

### 5.2 권한 매트릭스

| 엔드포인트 | ROLE_USER | ROLE_ADMIN |
|---|---|---|
| `/api/dataset/search` | ✅ | ✅ |
| `/api/bff/identity/users` (POST) | ❌ | ✅ |
| `/api/bff/storage/presigned` | ✅ | ✅ |

---

## 6. 페이지네이션·정렬·필터 규약

| 파라미터 | 타입 | 기본값 | 설명 |
|---|---|---|---|
| `pageNo` | Integer | 1 | 1 기반 페이지 번호 |
| `pageSize` | Integer | 20 | 페이지당 행 수 |
| `sortField` | String | null | 정렬 컬럼명 |
| `sortOrder` | String | ASC | ASC 또는 DESC |

---

## 7. 응답 포맷 & 에러 처리

### 7.1 성공 응답

```json
{
  "success": true,
  "data": { "rows": [...], "totalCount": 100 },
  "message": null,
  "error": null
}
```

### 7.2 에러 응답

| 코드 | HTTP | 설명 |
|---|---|---|
| BAD_REQUEST | 400 | 필수 파라미터 누락 |
| NOT_FOUND | 404 | serviceName 미등록 |
| UNAUTHORIZED | 401 | JWT 누락 |
| FORBIDDEN | 403 | 권한 부족 |

---

## 8. 외부 서비스 직통 호출

### 8.1 Rocket.Chat

```bash
curl -H "Authorization: Bearer \" http://kc.localtest.me:19091/api/bff/messenger/channels
```

자세한 내용은 **docs/group_ware.md § 1. Rocket.Chat** 참고.

### 8.2 Wiki.js

```bash
curl -H "Authorization: Bearer \" "http://kc.localtest.me:19091/api/bff/wiki/search?keyword=result"
```

자세한 내용은 **docs/group_ware.md § 2. Wiki.js** 참고.

### 8.3 MinIO

```bash
curl -H "Authorization: Bearer \" "http://kc.localtest.me:19091/api/bff/storage/presigned?object=approval/123/contract.pdf&op=PUT&expire=600"
```

자세한 내용은 **docs/group_ware.md § 3. MinIO** 참고.

### 8.4 Stalwart

```bash
curl -H "Authorization: Bearer \" "http://kc.localtest.me:19091/api/bff/mail/mailboxes"
```

자세한 내용은 **docs/group_ware.md § 4. Stalwart** 참고.

### 8.5 LiveKit

```bash
curl -X POST -H "Authorization: Bearer \" -H "Content-Type: application/json" \
  -d '{"roomName":"v3-meeting-42","canPublish":true}' \
  http://kc.localtest.me:19091/api/bff/video/token
```

자세한 내용은 **docs/group_ware.md § 5. LiveKit** 참고.

---

## 참조

### 9.1 소스 파일

| 파일 경로 | 라인 범위 | 내용 |
|---|---|---|
| `backend-core/.../DataSetController.java` | 1-114 | DataSet 진입점 |
| `backend-core/.../ServiceRegistry.java` | 1-82 | 어노테이션 스캔 |
| `backend-bff/.../BffController.java` | 1-215 | BFF 엔드포인트 |
| `backend-core/.../ApiResponse.java` | 1-34 | 응답 포맷 |
| `backend-core/.../GlobalExceptionHandler.java` | 1-37 | 에러 처리 |

### 9.2 관련 문서

- **docs/api-catalog.md** — DataSet serviceName 전체 목록 (35+개)
- **docs/group_ware.md** — 외부 서비스 실전 가이드
- **docs/approval.md** — 결재 워크플로우

### 9.3 Phase 14 체크리스트

| 트랙 | DataSet 서비스 | BFF 엔드포인트 | 상태 |
|---|---|---|---|
| 1 (근태/연차) | `attendance/*`, `leave/*` | `/api/bff/ux/*` | ✅ |
| 2 (회의실) | `room/*` | `/api/bff/video/room` | ✅ |
| 5 (관리자) | `admin/*` | `/api/bff/identity/users*` | ✅ |

---

## 이 챕터가 다루지 않은 인접 주제

- 백엔드 도메인 구조와 패턴은 챕터 1.9 참조
- 백엔드 규약 (MyBatis 동적 SQL, 트랜잭션 경계) 은 챕터 1.10 참조
- 보안 (JWT 클레임 처리, 권한 매트릭스) 은 챕터 1.12 참조
- DataSet 페이로드의 전체 케이스(_rowType C/U/D 통합) 는 챕터 1.10 참조
