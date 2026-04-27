# scaffolds/04_pattern_d_aggregation_readonly.md — Pattern D: Read-Only / Aggregation

> Phase 2.4 산출물. 다수 mapper/도메인 데이터 집계, INSERT/UPDATE/DELETE 없음.
> 모범 도메인: **widget** (대시보드) + **ux/SearchService** (통합검색).

## 적용 시점
- 대시보드 (KPI count, 일정 요약, 잔여일수)
- 통합검색 (도메인 간 키워드)
- Read-only 분석/리포트
- 사용자 환경설정 조회
- 카탈로그 lookup

## 사전 결정 체크
- 어떤 도메인의 데이터를 집계할 것인가 (cross-domain mapper inject)
- 권한 필터(`employee_id`, `dept_id`) 정책
- 응답 구조: `List<Map>` 또는 도메인별 DTO

---

## Step 1 — 사전 결정

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
| `__DomainPascal__` | (예: `Search`/`Widget`) | 전 단계 |
| `__domain-kebab__` | (예: `search`/`widget`) | 전 단계 |
| `__dm_table_prefix__` | (예: `ux_`/`dw_`) | 사용자 메타데이터 테이블이 있을 때만 |

---

## Step 2 — 영속 계층 (선택)

> 사용자 layout / 즐겨찾기 / 알림 환경설정 같은 메타데이터가 있는 경우만.

### 표 1. 복사할 파일
| 원본 | 복사 후 | 치환 식별자 | 비고 |
|---|---|---|---|
| (선택) `[code: V16__dashboard_widget.sql]` (`dw_widget_layout`) | `V{N+1}__{domain}_meta.sql` | `__dm_table_prefix__` | |
| (선택) `[code: V15__ux_features.sql]` (`ux_favorite`, `ux_notify_pref`) | 위와 동일 | | |

### 표 2. 신규 생성할 파일
| 경로 | 역할 | 골격 출처 |
|---|---|---|
| (선택) `V{N+1}__{domain}_meta.sql` | 사용자별 메타데이터 | `templates/pattern_d/V__meta.sql.tmpl` |

### 표 3. 수정할 기존 파일
| 경로 | 수정 위치 | 추가·변경 요약 |
|---|---|---|
| (해당 없음) | — | — |

### 표 4. 식별자 치환
| From | To | 적용 범위 |
|---|---|---|
| `__dm_table_prefix__` | 사용자 메타 테이블 prefix | 마이그레이션 |

> Pure read-only (검색 등) 인 경우 본 Step 은 "해당 없음" 으로 표기.

---

## Step 3 — 메뉴·권한 메타데이터 등록

→ `[doc: menu/menu_registration.md]` 위임.

---

## Step 4 — 데이터 액세스 계층 (Mapper)

### 표 1. 복사할 파일
| 원본 | 복사 후 | 치환 식별자 | 비고 |
|---|---|---|---|
| `[code: backend-core/.../widget/mapper/WidgetMapper.java]` | `backend-core/.../{domain}/mapper/{DomainPascal}Mapper.java` | `__DomainPascal__` | aggregation 쿼리 패턴 |
| `[code: backend-core/src/main/resources/mapper/widget/WidgetMapper.xml]` | `backend-core/src/main/resources/mapper/{domain}/{DomainPascal}Mapper.xml` | namespace, `__dm_table_prefix__` | UNION/JOIN/ILIKE 패턴 |
| (검색형) `[code: backend-core/.../ux/mapper/UxMapper.xml]` | (참고) | — | UNION 통합 검색 패턴 |

### 표 2. 신규 생성할 파일
| 경로 | 역할 | 골격 출처 |
|---|---|---|
| `backend-core/.../core/{domain}/mapper/{DomainPascal}Mapper.java` | Mapper | `templates/pattern_d/Mapper.java.tmpl` |
| `backend-core/.../mapper/{domain}/{DomainPascal}Mapper.xml` | XML | `templates/pattern_d/Mapper.xml.tmpl` |

### 표 3. 수정할 기존 파일
| 경로 | 수정 위치 | 추가·변경 요약 |
|---|---|---|
| (해당 없음) | — | — |

### 표 4. 식별자 치환
| From | To | 적용 범위 |
|---|---|---|
| `__DomainPascal__` | Mapper | Java + XML namespace |
| `__dm_table_prefix__` | DB 테이블 | XML SQL |

---

## Step 5 — 비즈니스 로직 (Service)

### 표 1. 복사할 파일
| 원본 | 복사 후 | 치환 식별자 | 비고 |
|---|---|---|---|
| `[code: backend-core/.../widget/WidgetService.java]` | `backend-core/.../{domain}/{DomainPascal}Service.java` | `__DomainPascal__`, `__domain-kebab__` | DEFAULT_LAYOUT 자동 시드 패턴 (사용자 메타 있을 때) |
| (검색형) `[code: backend-core/.../ux/SearchService.java]` | (참고) | — | UNION 결과 가공 |

### 표 2. 신규 생성할 파일
| 경로 | 역할 | 골격 출처 |
|---|---|---|
| `backend-core/.../core/{domain}/{DomainPascal}Service.java` | Service | `templates/pattern_d/Service.java.tmpl` |

### 표 3. 수정할 기존 파일
| 경로 | 수정 위치 | 추가·변경 요약 |
|---|---|---|
| (해당 없음) | — | — |

### 표 4. 식별자 치환
| From | To | 적용 범위 |
|---|---|---|
| `__DomainPascal__` | 클래스명 | core |
| `__domain-kebab__` | DataSet serviceName | Service |

---

## Step 6 — 진입점 / 라우팅

> `DataSetController` 공유.

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

→ `[doc: inventory/07_conventions.md]`. 추가:
- read-only 메서드는 `@Transactional` 필요 없음 (또는 `readOnly=true` — 갭)
- 로그: `log.debug("__domain-kebab__/aggregate user={} keyword={}", ...)` (DEBUG 권장)

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
| Service 메서드 | 메서드 본문 | DEBUG 로깅 추가 |

### 표 4. 식별자 치환
| From | To | 적용 범위 |
|---|---|---|
| `__domain-kebab__` | 로그 prefix | Service |

---

## Step 8 — 화면 작성

→ 대시보드 → 형태 5; 통합검색 → 형태 1; 환경설정 → 형태 9.

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

> 갭. SQL 쿼리 회귀 테스트 권장.

### 표 1. 복사할 파일
| 원본 | 복사 후 | 치환 식별자 | 비고 |
|---|---|---|---|
| (해당 없음) | — | — | — |

### 표 2. 신규 생성할 파일
| 경로 | 역할 | 골격 출처 |
|---|---|---|
| (선택) `{DomainPascal}MapperTest.java` | mapper 쿼리 회귀 | (없음) |

### 표 3. 수정할 기존 파일
| 경로 | 수정 위치 | 추가·변경 요약 |
|---|---|---|
| (해당 없음) | — | — |

### 표 4. 식별자 치환
| From | To | 적용 범위 |
|---|---|---|
| (해당 없음) | — | — |

> 수동: `POST /api/dataset/search { serviceName: "__domain-kebab__/list..." }` 응답 row 수 / 정렬 / 권한 필터 확인.

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
| (자기검증 회귀) | — | — |

### 표 4. 식별자 치환
| From | To | 적용 범위 |
|---|---|---|
| (해당 없음) | — | — |

추가 체크:
- [ ] read-only 보장 (Service 에 INSERT/UPDATE/DELETE 없음)
- [ ] 권한 필터(`employee_id`/`dept_id`) 적용
- [ ] LIMIT 절 또는 페이징 적용 (대량 결과 차단)
- [ ] ILIKE 사용 시 GIN 인덱스 검토 (사용자 500+ 시)

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
| (PR description) | — | aggregation 쿼리 EXPLAIN 첨부 권장 |

### 표 4. 식별자 치환
| From | To | 적용 범위 |
|---|---|---|
| (해당 없음) | — | — |

---

## 모범 워크스루 — `widget` 도메인 따라가기

> 모범: `[doc: inventory/08_references.md]`.

1. **Step 2 (DDL)**: V16 `dw_widget_layout` (user_id, widget_code, position_x/y/w/h) 테이블.
2. **Step 3 (메뉴)**: V17 의 `dashboard` 메뉴 (parent=`mywork`, path=`/dashboard`).
3. **Step 4 (Mapper)**: `WidgetMapper.java` + XML — `selectMine`, `countMine`, `selectAll`, `insertLayout` (자동 시드용).
4. **Step 5 (Service)**: `WidgetService.listMine()` —
   - `widgetMapper.countMine(currentUser)` → 0이면 DEFAULT_LAYOUT(6 위젯) 자동 시드
   - `widgetMapper.selectMine()` → user layout + catalog merge
   - 반환: `{ ds_mine: { rows: [...], totalCount: 6 } }`
5. **Step 6 (진입점)**: `serviceName="widget/listMine"` `serviceName="widget/listAll"` `serviceName="widget/saveLayout"`.
6. **Step 7 (컨벤션)**: read 메서드 `@Transactional` 없음, 시드는 별도 write 메서드 `@Transactional`.
7. **Step 8 (화면)**: PageDashboard (형태 5) — 12-column grid + edit mode + widget catalog dialog.
8. **Step 9 (라우터)**: `meta.menuId='dashboard'`.
9. **Step 10~12**: 자동 테스트 부재 → 수동 시나리오 (첫 로그인 시 자동 시드 / layout 변경 시 저장 / 위젯 추가/삭제).
