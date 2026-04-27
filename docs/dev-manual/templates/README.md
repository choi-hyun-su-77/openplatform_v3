# templates/ — 빈 골격 파일 카탈로그

> Phase 2.X / 3.X 산출물. SOP 의 "표 2. 신규 생성할 파일" 의 골격 출처.
> 모든 파일은 `__placeholder__` 치환 변수를 사용한다 — 정의는 `[doc: ../inventory/04_naming.md §4]`.

## 치환 변수 (전체 골격 공통)

| placeholder | 변환 | 예시 |
|---|---|---|
| `__DomainPascal__` | PascalCase | `Notice` |
| `__domainCamel__` | camelCase | `notice` |
| `__domain_snake__` | snake_case | `notice` |
| `__domain-kebab__` | kebab-case | `notice` |
| `__DOMAIN_UPPER__` | UPPER | `NOTICE` |
| `__dm_table_prefix__` | 2~3 letter | `nt2_` |
| `__domainKorean__` | 한글 | `공지사항` |

## 카탈로그

### Backend — `pattern_a/` (표준 CRUD)
- `V__schema.sql.tmpl` — DDL 마이그레이션
- `Mapper.java.tmpl` — MyBatis Mapper 인터페이스
- `Mapper.xml.tmpl` — MyBatis XML
- `Service.java.tmpl` — Service (DataSet 진입점)

### Backend — `pattern_b/` (Workflow)
- `V__schema.sql.tmpl` — 도메인 + 라인 + 첨부 + 이력 테이블
- `Service.java.tmpl` — submit/approve/reject/withdraw
- `flowable/StartListener.java.tmpl`
- `flowable/CompleteDelegate.java.tmpl`
- `flowable/AssigneeResolver.java.tmpl`
- `flowable/NotificationListener.java.tmpl`
- `process.bpmn20.xml.tmpl`
- `line.dmn.tmpl`

### Backend — `pattern_c/` (BFF Adapter)
- `V__mapping.sql.tmpl` — 외부 ID 매핑 컬럼
- `Port.java.tmpl` — BFF Port 인터페이스
- `Adapter.java.tmpl` — Adapter 구현
- `Controller.java.tmpl` — BFF Controller
- `Service.java.tmpl` — backend-core Service (BFF 호출)

### Backend — `pattern_d/` (Read-Only)
- `V__meta.sql.tmpl` — 사용자 메타데이터(선택)
- `Mapper.java.tmpl` — aggregation Mapper
- `Mapper.xml.tmpl` — UNION/JOIN/ILIKE 쿼리
- `Service.java.tmpl` — read-only Service

### Menu — `menu/`
- `V__menu_template.sql.tmpl` — `cm_menu` + `cm_role_menu` INSERT
- `V__i18n_template.sql.tmpl` — `cm_i18n_message` 4-locale INSERT

### Screen Types — `screen_types/{NN}_{type}/`
각 형태별 1개 또는 2개 .vue.tmpl 파일.

## 빌드 검증

치환 후 빌드/렌더 가능 여부 검증:
- 백엔드: `mvn clean package -DskipTests`
- UI: `npm run build` (vue-tsc 타입 체크)
- DDL: PostgreSQL 에 dry-run

## 사용 절차

1. SOP 의 "표 2. 신규 생성할 파일" 행을 본다.
2. 골격 출처 컬럼이 `templates/...` 인 경로의 파일을 복사.
3. 파일 내용의 `__placeholder__` 를 도메인 식별자로 치환.
4. 컴파일/빌드 통과 확인.
