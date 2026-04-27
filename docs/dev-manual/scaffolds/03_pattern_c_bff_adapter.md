# scaffolds/03_pattern_c_bff_adapter.md — Pattern C: External System Passthrough (BFF Port-Adapter)

> Phase 2.3 산출물. backend-core 가 BFF Port 를 호출 → Adapter 가 외부 REST 호출.
> 모범 도메인: **admin** (Keycloak) + **room** (LiveKit).

## 적용 시점
- 3rd-party 시스템 통합 (Identity / Storage / Messaging / Video / Mail / Wiki)
- Operational token 관리 (서비스 계정 / API 키)
- DB + 외부 상태의 cross-system 일관성
- Standardized error mapping

## 사전 결정 체크
- 외부 시스템: Keycloak / MinIO / Rocket.Chat / LiveKit / Wiki.js / Stalwart 중 어떤 것?
- 기존 Port 가 있는가 (`IdentityPort` / `StoragePort` / `MessagingPort` / `VideoPort` / `MailPort` / `WikiPort`)?
- backend-core DB 에 영속할 메타데이터(예: 사용자 매핑)는 있는가?

---

## Step 1 — 사전 결정

### 표 1. 복사할 파일
| 원본 | 복사 후 | 치환 식별자 | 비고 |
|---|---|---|---|
| (해당 없음, 결정만) | — | — | — |

### 표 2. 신규 생성할 파일
| 경로 | 역할 | 골격 출처 |
|---|---|---|
| (해당 없음) | — | — |

### 표 3. 수정할 기존 파일
| 경로 | 수정 위치 | 추가·변경 요약 |
|---|---|---|
| (해당 없음) | — | — |

### 표 4. 식별자 치환
| From | To | 적용 범위 |
|---|---|---|
| `__CapabilityPascal__` | (예: `Identity`/`Video`/`Storage`) | Port/Adapter 명 |
| `__capabilityCamel__` | (예: `identity`) | URL prefix |
| `__ExternalPascal__` | (예: `Keycloak`/`LiveKit`) | Adapter 명 |
| `__DomainPascal__` | (예: `Admin`) | backend-core Service |
| `__domain-kebab__` | (예: `admin`) | DataSet serviceName |

---

## Step 2 — 영속 계층 (메타데이터 매핑이 필요한 경우만)

### 표 1. 복사할 파일
| 원본 | 복사 후 | 치환 식별자 | 비고 |
|---|---|---|---|
| (선택) `[code: V2__org_schema.sql]` 의 `org_employee.keycloak_user_id` 컬럼 패턴 | 새 마이그레이션 | `__dm_table_prefix__`, `__external_id_col__` | 외부 ID 매핑용 컬럼 |

### 표 2. 신규 생성할 파일
| 경로 | 역할 | 골격 출처 |
|---|---|---|
| (선택) `V{N+1}__{domain}_external_mapping.sql` | 외부 ID 매핑 컬럼 | `templates/pattern_c/V__mapping.sql.tmpl` |

### 표 3. 수정할 기존 파일
| 경로 | 수정 위치 | 추가·변경 요약 |
|---|---|---|
| (해당 없음 또는 기존 도메인 테이블에 컬럼 추가) | `ALTER TABLE` | 외부 ID 컬럼 추가 |

### 표 4. 식별자 치환
| From | To | 적용 범위 |
|---|---|---|
| `__external_id_col__` | (예: `keycloak_user_id`) | 컬럼명 |

> 외부 시스템이 진실 source 인 경우 backend-core DB 영속이 거의 없을 수도 있음.

---

## Step 3 — 메뉴·권한 메타데이터 등록

→ `[doc: menu/menu_registration.md]` 위임.

---

## Step 4 — 데이터 액세스 계층 (Port + Adapter)

### 표 1. 복사할 파일
| 원본 | 복사 후 | 치환 식별자 | 비고 |
|---|---|---|---|
| `[code: backend-bff/.../port/IdentityPort.java]` | `backend-bff/.../port/__CapabilityPascal__Port.java` | `__CapabilityPascal__`, 메서드 시그니처 | 기존 Port 가 있으면 메서드 추가만 |
| `[code: backend-bff/.../adapter/KeycloakIdentityAdapter.java]` | `backend-bff/.../adapter/__ExternalPascal____CapabilityPascal__Adapter.java` | `__ExternalPascal__`, `__CapabilityPascal__` | WebClient 호출 + 에러 매핑 |

### 표 2. 신규 생성할 파일
| 경로 | 역할 | 골격 출처 |
|---|---|---|
| (신규 capability 시) `backend-bff/.../core/port/__CapabilityPascal__Port.java` | Port interface | `templates/pattern_c/Port.java.tmpl` |
| `backend-bff/.../adapter/__ExternalPascal____CapabilityPascal__Adapter.java` | Adapter 구현 | `templates/pattern_c/Adapter.java.tmpl` |
| `backend-bff/.../api/__CapabilityPascal__Controller.java` | BFF REST 진입점 | `templates/pattern_c/Controller.java.tmpl` |

### 표 3. 수정할 기존 파일
| 경로 | 수정 위치 | 추가·변경 요약 |
|---|---|---|
| `backend-bff/src/main/resources/application.yml` | 외부 시스템 URL/key 섹션 | 환경변수 매핑 추가 |
| (기존 Port 가 있으면) `backend-bff/.../port/{Existing}Port.java` | 메서드 시그니처 추가 | 새 메서드 |

### 표 4. 식별자 치환
| From | To | 적용 범위 |
|---|---|---|
| `__CapabilityPascal__` | Port/Controller | BFF |
| `__ExternalPascal__` | Adapter prefix | BFF |
| `__capabilityCamel__` | URL prefix | Controller path |

---

## Step 5 — 비즈니스 로직 (backend-core Service)

### 표 1. 복사할 파일
| 원본 | 복사 후 | 치환 식별자 | 비고 |
|---|---|---|---|
| `[code: backend-core/.../admin/AdminService.java]` | `backend-core/.../{domain}/{DomainPascal}Service.java` | `__DomainPascal__`, `__domain-kebab__`, `__capabilityCamel__` | `bffPost/bffPut` 호출 패턴 복제 |

### 표 2. 신규 생성할 파일
| 경로 | 역할 | 골격 출처 |
|---|---|---|
| `backend-core/.../core/{domain}/{DomainPascal}Service.java` | Service | `templates/pattern_c/Service.java.tmpl` |

### 표 3. 수정할 기존 파일
| 경로 | 수정 위치 | 추가·변경 요약 |
|---|---|---|
| `backend-core/.../common/BffClient.java` | 기존 `bffPost`/`bffPut`/`bffGet` 메서드 사용. 새 HTTP 메서드(예: PATCH)가 필요한 경우에만 메서드 추가 | (변경 없음 — 호출만) |

### 표 4. 식별자 치환
| From | To | 적용 범위 |
|---|---|---|
| `__DomainPascal__` | Service 클래스 | core |
| `__capabilityCamel__` | bff URL path | Service |

---

## Step 6 — 진입점 / 라우팅

> backend-core 는 `DataSetController` 진입점 공유. backend-bff 는 별도 `__CapabilityPascal__Controller` 가 진입점.

### 표 1. 복사할 파일
| 원본 | 복사 후 | 치환 식별자 | 비고 |
|---|---|---|---|
| (해당 없음) | — | — | — |

### 표 2. 신규 생성할 파일
| 경로 | 역할 | 골격 출처 |
|---|---|---|
| (Step 4 의 BFF Controller 와 동일) | — | — |

### 표 3. 수정할 기존 파일
| 경로 | 수정 위치 | 추가·변경 요약 |
|---|---|---|
| (해당 없음) | — | — |

### 표 4. 식별자 치환
| From | To | 적용 범위 |
|---|---|---|
| (해당 없음) | — | — |

---

## Step 7 — 표준 응답·로깅 컨벤션 적용

→ `[doc: inventory/07_conventions.md]`. 추가:
- 외부 호출 실패는 `BusinessException` 또는 warn 로그 (정책 결정)
- token 자격증명 평문 로깅 금지

### 표 1. 복사할 파일
| 원본 | 복사 후 | 치환 식별자 | 비고 |
|---|---|---|---|
| (해당 없음) | — | — | — |

### 표 2. 신규 생성할 파일
| 경로 | 역할 | 골격 출처 |
|---|---|---|
| (해당 없음) | — | — |

### 표 3. 수정할 기존 파일
| 경로 | 수정 위치 | 추가·변경 요약 |
|---|---|---|
| Adapter | exception handler | `BusinessException` 매핑 |

### 표 4. 식별자 치환
| From | To | 적용 범위 |
|---|---|---|
| (해당 없음) | — | — |

---

## Step 8 — 화면 작성

→ 외부 시스템 진입은 보통 형태 7(SSO 래퍼) + 형태 1(목록) 결합.

### 표 1. 복사할 파일
| 원본 | 복사 후 | 치환 식별자 | 비고 |
|---|---|---|---|
| (화면 SOP 의 표 1) | — | — | — |

### 표 2. 신규 생성할 파일
| 경로 | 역할 | 골격 출처 |
|---|---|---|
| (화면 SOP 의 표 2) | — | — |

### 표 3. 수정할 기존 파일
| 경로 | 수정 위치 | 추가·변경 요약 |
|---|---|---|
| (화면 SOP 의 표 3) | — | — |

### 표 4. 식별자 치환
| From | To | 적용 범위 |
|---|---|---|
| (화면 SOP 의 표 4) | — | — |

---

## Step 9 — 클라이언트 라우터 / 메뉴 매핑

→ `[doc: menu/menu_registration.md Step 5]` 위임.

### 표 1. 복사할 파일
| 원본 | 복사 후 | 치환 식별자 | 비고 |
|---|---|---|---|
| (해당 없음) | — | — | — |

### 표 2. 신규 생성할 파일
| 경로 | 역할 | 골격 출처 |
|---|---|---|
| (해당 없음) | — | — |

### 표 3. 수정할 기존 파일
| 경로 | 수정 위치 | 추가·변경 요약 |
|---|---|---|
| `ui/src/router/index.ts` | children 배열 | route entry 추가 |

### 표 4. 식별자 치환
| From | To | 적용 범위 |
|---|---|---|
| `__domain-kebab__` | path/name/menuId | router |

---

## Step 10 — 테스트

> 갭. WireMock / TestContainers 권장 (코드베이스 부재).

### 표 1. 복사할 파일
| 원본 | 복사 후 | 치환 식별자 | 비고 |
|---|---|---|---|
| (해당 없음) | — | — | — |

### 표 2. 신규 생성할 파일
| 경로 | 역할 | 골격 출처 |
|---|---|---|
| (선택) `backend-bff/src/test/java/.../adapter/{ExternalPascal}{Capability}AdapterTest.java` | adapter 단위 테스트 | (없음) |

### 표 3. 수정할 기존 파일
| 경로 | 수정 위치 | 추가·변경 요약 |
|---|---|---|
| (해당 없음) | — | — |

### 표 4. 식별자 치환
| From | To | 적용 범위 |
|---|---|---|
| (해당 없음) | — | — |

> 수동 검증: `POST /api/bff/{capability}/{action}` Postman 으로 → 외부 시스템 상태 확인.

---

## Step 11 — 자기검증

→ `[doc: inventory/07_conventions.md §8]`.

### 표 1. 복사할 파일
| 원본 | 복사 후 | 치환 식별자 | 비고 |
|---|---|---|---|
| (해당 없음) | — | — | — |

### 표 2. 신규 생성할 파일
| 경로 | 역할 | 골격 출처 |
|---|---|---|
| (해당 없음) | — | — |

### 표 3. 수정할 기존 파일
| 경로 | 수정 위치 | 추가·변경 요약 |
|---|---|---|
| (자기검증 누락 회귀) | — | — |

### 표 4. 식별자 치환
| From | To | 적용 범위 |
|---|---|---|
| (해당 없음) | — | — |

추가 체크:
- [ ] 외부 토큰 평문 로깅 없음
- [ ] 호출 실패 시 backend-core 트랜잭션 영향 정책 명확
- [ ] Adapter 가 `WebClient`/`RestClient` 사용 (RestTemplate 권장 X)
- [ ] BFF Controller path 가 `/api/bff/{capability}` 형식

---

## Step 12 — PR 준비

### 표 1. 복사할 파일
| 원본 | 복사 후 | 치환 식별자 | 비고 |
|---|---|---|---|
| (해당 없음) | — | — | — |

### 표 2. 신규 생성할 파일
| 경로 | 역할 | 골격 출처 |
|---|---|---|
| (해당 없음) | — | — |

### 표 3. 수정할 기존 파일
| 경로 | 수정 위치 | 추가·변경 요약 |
|---|---|---|
| (PR description) | — | 외부 시스템 명·테스트 시나리오 첨부 |

### 표 4. 식별자 치환
| From | To | 적용 범위 |
|---|---|---|
| (해당 없음) | — | — |

---

## 모범 워크스루 — `admin` 도메인 (Keycloak) 따라가기

> 모범: `[doc: inventory/08_references.md]`.

1. **Step 2 (DDL)**: V2 `org_employee.keycloak_user_id` 컬럼이 외부 ID 매핑.
2. **Step 3 (메뉴)**: V17 `admin_users` 메뉴 (parent=`admin`, requiresAdmin=true).
3. **Step 4 (Port + Adapter)**:
   - `[code: backend-bff/.../port/IdentityPort.java]` — `getMe`, `getRoles`, `getUserById`, `createUser`, `updateUser`, `setActive`, `resetPassword`
   - `[code: backend-bff/.../adapter/KeycloakIdentityAdapter.java]` — admin token 획득 → Keycloak Admin REST 호출
   - `IdentityController` 가 `/api/bff/identity/users` 엔드포인트 노출
5. **Step 5 (Service)**: `[code: backend-core/.../admin/AdminService.java]` 가 `bffPost("/api/bff/identity/users", req)` 로 BFF 호출. DB에 `org_employee` insert + Keycloak user 생성.
6. **Step 6 (진입점)**: backend-core `DataSetController` + backend-bff `IdentityController`.
7. **Step 7 (컨벤션)**: `requireAdmin()` 가드, `AdminAuditAspect` 자동 감사 (`admin/*`).
8. **Step 8 (화면)**: PageUsers (형태 1) — admin 라우트.
9. **Step 9 (라우터)**: `meta.menuId='admin_users', requiresAdmin: true`.
10. **Step 10~12**: 자동 테스트 부재 → 수동, 자기검증·PR.
