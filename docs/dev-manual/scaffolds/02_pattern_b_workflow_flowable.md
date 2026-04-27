# scaffolds/02_pattern_b_workflow_flowable.md — Pattern B: Workflow-Driven (Flowable + Delegates)

> Phase 2.2 산출물. Flowable BPMN + DMN + JavaDelegate 로 다단계 워크플로 작성.
> 모범 도메인: **approval** (전자결재) — `[code: backend-core/.../approval/]`

## 적용 시점
- 다단계 프로세스 (결재 체인, 조건 분기)
- 명확한 entry/exit 의 state machine
- 감사 추적 (process history 자동)
- 병렬/순차 task 할당
- 회수/재상신 로직

## 사전 결정 체크
- 프로세스 단계: PENDING → IN_PROGRESS → APPROVED|REJECTED|DRAFT 정의
- 결재선 결정 방식: DMN 룰 / 사용자 지정 / 부서별 자동
- Hook 대상 도메인 (예: `LeaveService.applyFromDoc` 호출 여부)

---

## Step 1 — 사전 결정 (식별자/화면/권한)

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
| `__DomainPascal__` | (예: `Expense`) | 전 단계 |
| `__domain-kebab__` | (예: `expense`) | 전 단계 |
| `__dm_table_prefix__` | (예: `ex_`) | 전 단계 |
| `__processKey__` | (예: `expense-approval`) | BPMN, DMN |

---

## Step 2 — 영속 계층 (DDL/스키마/마이그레이션)

> 결재 도메인 모범처럼 메인 + line + attachment + delegation + history 등 보조 테이블 다수.

### 표 1. 복사할 파일
| 원본 | 복사 후 | 치환 식별자 | 비고 |
|---|---|---|---|
| `[code: V8__approval_and_extras.sql]` (5 테이블) | `V{N+1}__{domain}_schema.sql` | `__dm_table_prefix__`, `__domain_snake__` | ap_document, ap_line, ap_attachment, ap_delegation, ap_history 패턴 복제 |

### 표 2. 신규 생성할 파일
| 경로 | 역할 | 골격 출처 |
|---|---|---|
| `backend-core/src/main/resources/db/migration/V{N+1}__{domain}_schema.sql` | 워크플로 도메인 테이블 | `templates/pattern_b/V__schema.sql.tmpl` |

### 표 3. 수정할 기존 파일
| 경로 | 수정 위치 | 추가·변경 요약 |
|---|---|---|
| (해당 없음) | — | — |

### 표 4. 식별자 치환
| From | To | 적용 범위 |
|---|---|---|
| `__dm_table_prefix__` | 2~3 letter | 마이그레이션 |
| `__domain_snake__` | snake_case | 마이그레이션 |

---

## Step 3 — 메뉴·권한 메타데이터 등록

→ `[doc: menu/menu_registration.md]` 위임.

---

## Step 4 — 데이터 액세스 계층 (Mapper)

### 표 1. 복사할 파일
| 원본 | 복사 후 | 치환 식별자 | 비고 |
|---|---|---|---|
| `[code: backend-core/.../approval/mapper/ApprovalMapper.java]` | `backend-core/.../{domain}/mapper/{DomainPascal}Mapper.java` | `__DomainPascal__` | inbox/outbox/cc/history 셀렉트 + 라인 insert/update 포함 |
| `[code: backend-core/src/main/resources/mapper/approval/ApprovalMapper.xml]` | `backend-core/src/main/resources/mapper/{domain}/{DomainPascal}Mapper.xml` | namespace, `__dm_table_prefix__` | DMN selector 쿼리 포함 |

### 표 2. 신규 생성할 파일
| 경로 | 역할 | 골격 출처 |
|---|---|---|
| `backend-core/.../core/{domain}/mapper/{DomainPascal}Mapper.java` | Mapper | `templates/pattern_b/Mapper.java.tmpl` |
| `backend-core/.../mapper/{domain}/{DomainPascal}Mapper.xml` | XML | `templates/pattern_b/Mapper.xml.tmpl` |

### 표 3. 수정할 기존 파일
| 경로 | 수정 위치 | 추가·변경 요약 |
|---|---|---|
| (해당 없음) | — | — |

### 표 4. 식별자 치환
| From | To | 적용 범위 |
|---|---|---|
| `__DomainPascal__` | Mapper 클래스 | Java + XML namespace |
| `__dm_table_prefix__` | DB 테이블 | XML SQL |

---

## Step 5 — 비즈니스 로직 (Service + Delegates)

### 표 1. 복사할 파일
| 원본 | 복사 후 | 치환 식별자 | 비고 |
|---|---|---|---|
| `[code: backend-core/.../approval/ApprovalService.java]` | `backend-core/.../{domain}/{DomainPascal}Service.java` | `__DomainPascal__`, `__domain-kebab__` | submit/approve/reject/withdraw 메서드 패턴 복제 |
| `[code: backend-core/.../approval/flowable/ApprovalProcessStartListener.java]` | `backend-core/.../{domain}/flowable/{DomainPascal}ProcessStartListener.java` | `__DomainPascal__`, `__domain-kebab__` | |
| `[code: backend-core/.../approval/flowable/ApprovalCompleteDelegate.java]` | `backend-core/.../{domain}/flowable/{DomainPascal}CompleteDelegate.java` | `__DomainPascal__`, `__domain-kebab__` | |
| `[code: backend-core/.../approval/flowable/ApprovalAssigneeResolver.java]` | `backend-core/.../{domain}/flowable/{DomainPascal}AssigneeResolver.java` | `__DomainPascal__` | |
| `[code: backend-core/.../approval/flowable/ApprovalNotificationListener.java]` | `backend-core/.../{domain}/flowable/{DomainPascal}NotificationListener.java` | `__DomainPascal__` | |

### 표 2. 신규 생성할 파일
| 경로 | 역할 | 골격 출처 |
|---|---|---|
| `backend-core/.../core/{domain}/{DomainPascal}Service.java` | Service | `templates/pattern_b/Service.java.tmpl` |
| `backend-core/.../core/{domain}/flowable/*.java` | 4 Delegate | `templates/pattern_b/flowable/*.java.tmpl` |
| `backend-core/src/main/resources/processes/{processKey}.bpmn20.xml` | BPMN 정의 | `templates/pattern_b/process.bpmn20.xml.tmpl` |
| `backend-core/src/main/resources/dmn/{processKey}-line.dmn` | 결재선 룰 (선택) | `templates/pattern_b/line.dmn.tmpl` |

### 표 3. 수정할 기존 파일
| 경로 | 수정 위치 | 추가·변경 요약 |
|---|---|---|
| (해당 없음 — 새 도메인 추가) | — | — |

### 표 4. 식별자 치환
| From | To | 적용 범위 |
|---|---|---|
| `__DomainPascal__` | 클래스 + Delegate 명 | 5 Java 파일 |
| `__domain-kebab__` | DataSet serviceName | Service |
| `__processKey__` | BPMN id | BPMN/DMN |

---

## Step 6 — 진입점 / 라우팅

> Pattern B 도 `DataSetController` 진입점 공유. 추가 컨트롤러 불필요.

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
| (해당 없음) | — | — |

### 표 4. 식별자 치환
| From | To | 적용 범위 |
|---|---|---|
| (해당 없음) | — | — |

---

## Step 7 — 표준 응답·로깅 컨벤션 적용

→ `[doc: inventory/07_conventions.md §1, §2]`. 추가로:
- 워크플로 단계 변화: `log.info("__domain-kebab__/state-change docId={} from={} to={} user={}", ...)`
- Delegate 진입/종료: `log.info("__domain-kebab__/delegate {} executed", className)`

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
| Service / Delegate | 메서드 본문 | 로깅 추가 |
| Service write 메서드 | 시그니처 | `@Transactional` |

### 표 4. 식별자 치환
| From | To | 적용 범위 |
|---|---|---|
| `__domain-kebab__` | 로그 prefix | Service / Delegate |

---

## Step 8 — 화면 작성

→ 결재형 도메인은 보통 **형태 1 + 형태 2 + 형태 6** 결합. 각 화면 SOP 위임.

### 표 1. 복사할 파일
| 원본 | 복사 후 | 치환 식별자 | 비고 |
|---|---|---|---|
| (화면 SOP 의 표 1 사용) | — | — | — |

### 표 2. 신규 생성할 파일
| 경로 | 역할 | 골격 출처 |
|---|---|---|
| (화면 SOP 의 표 2 사용) | — | — |

### 표 3. 수정할 기존 파일
| 경로 | 수정 위치 | 추가·변경 요약 |
|---|---|---|
| (화면 SOP 의 표 3 사용) | — | — |

### 표 4. 식별자 치환
| From | To | 적용 범위 |
|---|---|---|
| (화면 SOP 의 표 4 사용) | — | — |

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

> 갭(`[doc: inventory/09_gaps.md §1]`): 자동 테스트 부재. 워크플로 통합 테스트 권장.

### 표 1. 복사할 파일
| 원본 | 복사 후 | 치환 식별자 | 비고 |
|---|---|---|---|
| (해당 없음) | — | — | — |

### 표 2. 신규 생성할 파일
| 경로 | 역할 | 골격 출처 |
|---|---|---|
| (선택) `backend-core/src/test/java/.../{domain}/{DomainPascal}WorkflowIT.java` | 통합 테스트 | (없음) |

### 표 3. 수정할 기존 파일
| 경로 | 수정 위치 | 추가·변경 요약 |
|---|---|---|
| (해당 없음) | — | — |

### 표 4. 식별자 치환
| From | To | 적용 범위 |
|---|---|---|
| `__DomainPascal__` | 테스트 클래스 | 테스트 파일 |

> 수동 검증 시나리오: 신청 → 승인 → 완료 / 신청 → 반려 / 신청 → 회수.

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
| (자기검증 결과 누락이 있다면 해당 Step 회귀) | — | — |

### 표 4. 식별자 치환
| From | To | 적용 범위 |
|---|---|---|
| (해당 없음) | — | — |

추가 체크:
- [ ] BPMN 파일이 classpath `processes/` 에 위치
- [ ] Delegate 클래스가 `@Component` 또는 `@Service`
- [ ] `verifyDocAccess()` 류 권한 가드 존재
- [ ] hook 호출은 try-catch 로 감싸 primary tx rollback 차단

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
| (PR description) | (외부) | 워크플로 단계 다이어그램 첨부 |

### 표 4. 식별자 치환
| From | To | 적용 범위 |
|---|---|---|
| (해당 없음) | — | — |

---

## 모범 워크스루 — `approval` 도메인 따라가기

> 모범: `[doc: inventory/08_references.md]` 선정.

1. **Step 2 (DDL)**: V8 마이그레이션이 `ap_document`, `ap_approval_line`, `ap_attachment`, `ap_delegation`, `ap_history` 5 테이블 생성.
2. **Step 3 (메뉴)**: V17 의 `approval` 메뉴 행 (parent=`work`, path=`/approval`, icon=`pi pi-check-square`).
3. **Step 4 (Mapper)**: `ApprovalMapper.java` + XML — `selectInbox`, `selectOutbox`, `selectCcBox`, `selectDocDetail`, `insertDocument`, `updateDocStatus`, `selectApproversForDocFromDmn` (DMN 룰 호출), `insertApprovalLine`, `updateApprovalLineState`, `selectHistory`.
4. **Step 5 (Service + Delegates)**:
   - `ApprovalService.submitDocument(...)` — 검증 → `ap_document` insert → `selectApproversForDocFromDmn` → 라인 insert → `NotificationService.notifyByUserNo()` 호출 → LEAVE 폼 시 `LeaveService.applyFromDoc()` (실패 무시)
   - `ApprovalProcessStartListener` — Flowable 프로세스 시작 시 호출
   - `ApprovalAssigneeResolver` — userTask 의 동적 assignee 결정
   - `ApprovalCompleteDelegate` — endEvent 에서 기안자 알림 + LEAVE 시 `leaveService.onDocApproved()`
   - `ApprovalNotificationListener` — 상태 변경 시 SSE 알림
5. **Step 6 (진입점)**: `DataSetController` 가 `serviceName="approval/submitDocument"` 등을 라우팅.
6. **Step 7 (컨벤션)**: write 메서드에 `@Transactional`, `verifyDocAccess()` 권한 가드.
7. **Step 8 (화면)**: PageApproval (형태 1) + ApprovalDetailDialog (형태 2) + ApprovalSubmitDialog (형태 6) 결합.
8. **Step 9 (라우터)**: `meta.menuId='approval'` 등록.
9. **Step 10 (테스트)**: 자동 테스트 부재 → 수동 시나리오.
10. **Step 11~12**: 자기검증·PR.
