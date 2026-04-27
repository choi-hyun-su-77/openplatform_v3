# 풀스택 프레임워크 종합 문서화 프롬프트 (Claude Code 용)

## 역할 & 목표
당신은 시니어 테크니컬 라이터이자 시스템 아키텍트입니다.
현재 프로젝트의 **모든 측면을 누락 없이** 문서화하여 단일 PDF 산출물을 생성합니다.

## 핵심 원칙
1. **1차 정보원 우선 (Source of Truth First)**: 모든 챕터의 내용은 **(a) 코드베이스 내 기존 산출물(.md/.adoc/README/ADR/OpenAPI/ERD/마이그레이션/주석 등)**과 **(b) 실제 소스코드** 두 곳에서만 추출한다. 두 정보원 어디에도 근거가 없는 내용은 **추측·창작 금지** — 누락이 의심되면 `warn.md`에 기록하고 사용자에게 확인 요청.
2. **누락 금지**: 코드베이스 grep/스캔 결과와 산출 챕터를 대조하여 빠진 모듈/도메인/문서가 없도록 한다.
3. **병렬 실행**: Phase 1의 챕터 작성은 Task 에이전트로 Group 단위 병렬 디스패치한다 (파일 충돌 방지를 위해 각 에이전트는 자기 파일만 작성).
4. **상태 파일 갱신**: 매 단계마다 `info.md` / `warn.md` / `fatal.md`를 갱신하고, 사용자 확인이 필요한 차단점은 즉시 보고한다.
5. **CODING_STANDARDS 준수**: 본 문서 자체도 §0–§23 규약과 11항목 자기검증을 적용한다.
6. **재개 가능**: TODO 체크박스 기반으로 중단 후 재개 시 완료된 항목은 스킵한다.

## 작업 디렉토리
```
/docs/comprehensive/
├── TODO.md                   # 본 체크리스트 사본 (진행 추적)
├── info.md / warn.md / fatal.md
├── inventory/                # Phase 0 산출물 (1차 정보원 인벤토리)
│   ├── 00_existing_artifacts.md   # 기존 문서·자산 목록
│   ├── 01_tree.txt
│   ├── 02_stack_a_backend.md
│   ├── 03_stack_b_backend.md
│   ├── 04_frontend.md
│   ├── 05_database.md
│   ├── 06_tests.md
│   ├── 07_ops.md
│   ├── 08_logging.md
│   ├── 09_security.md
│   └── 10_chapter_source_map.md   # 챕터↔정보원 매핑표
├── chapters/                 # 챕터별 마크다운 (병렬 산출물)
├── assets/                   # 다이어그램, 이미지, 표
│   └── existing/             # 기존 산출물에서 가져온 이미지/스크린샷
└── build/                    # 최종 PDF 빌드 결과
```

## 사전 확인 (Phase 0 전)
- `SESSION_HANDOFF.md`, `CODING_STANDARDS.md`, `CLAUDE.md` 존재 여부
- Stack A / Stack B 루트 경로
- PDF 변환 도구: `pandoc` + `xelatex` (또는 `weasyprint`), 한글 폰트 `Noto Sans CJK KR`
- Mermaid 다이어그램 렌더러: `mermaid-cli` (mmdc)

---

## TODO 체크리스트

### Phase 0 — 사전 분석 (Sequential, **모든 후속 단계의 1차 정보원**)

> 이 Phase의 산출물(`inventory/` 디렉토리)이 Phase 1 모든 챕터 에이전트의 입력이 된다.
> **누락 시 챕터 품질이 직접 떨어지므로** 절대 스킵 금지.

#### 0.A 기존 산출물(문서·자산) 전수 스캔
- [ ] 0.A.1 루트/하위 디렉토리의 **모든 마크다운/문서**를 수집 — `find . -type f \( -name "*.md" -o -name "*.adoc" -o -name "*.rst" -o -name "*.txt" \) -not -path "*/node_modules/*" -not -path "*/target/*" -not -path "*/dist/*" -not -path "*/.git/*"`
- [ ] 0.A.2 핵심 메타 문서 우선 정독: `SESSION_HANDOFF.md`, `CODING_STANDARDS.md`, `CLAUDE.md`, `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`, `ARCHITECTURE.md`, `ADR/*` (Architecture Decision Records)
- [ ] 0.A.3 설계 산출물 수집: ERD 파일(`*.dbml`, `*.mwb`, `*.drawio`, `*.mermaid`, `*.puml`), API 명세(`openapi.yaml`, `swagger.json`, Postman collection), 시퀀스/플로우 다이어그램
- [ ] 0.A.4 정책/표준 문서: 네이밍·로깅·커밋·PR 규칙, 릴리즈 노트, 마이그레이션 가이드, 보안 정책
- [ ] 0.A.5 비-마크다운 산출물: HTML 목업, PPT(설계 발표), Excel(기능 명세/요구사항), PDF(이전 문서) — **있으면 텍스트 추출하여 인덱싱**
- [ ] 0.A.6 화면/UI 자산: 스크린샷, 와이어프레임, Figma 익스포트 → `assets/existing/`로 복사
- [ ] 0.A.7 → `inventory/00_existing_artifacts.md` 생성 (파일명 / 경로 / 종류 / 1줄 요약 / 어느 챕터에 매핑되는지)

#### 0.B 코드베이스 전수 분석
- [ ] 0.B.1 프로젝트 트리: `tree -L 4 -I 'node_modules|target|dist|build|.git|.gradle|.idea'` → `inventory/01_tree.txt`
- [ ] 0.B.2 빌드/의존성 파일 정독: `build.gradle(.kts)`, `pom.xml`, `package.json`(루트+하위 전부), `tsconfig.json`, `vite.config.ts`, `drizzle.config.ts`, `nest-cli.json`
- [ ] 0.B.3 환경설정: `application*.yml`, `application*.properties`, `.env*`(예시 포함), `docker-compose*.yml`, `Dockerfile*`, `nginx.conf`, `keepalived.conf`, `systemd/*.service`, Ansible 플레이북
- [ ] 0.B.4 **Stack A 백엔드 인벤토리**:
  - `**/*Controller.java` (REST 진입점)
  - `**/*Biz.java` (Pattern A/B/C 비즈 로직)
  - `**/*Mapper.java` + `**/*Mapper.xml` (MyBatis)
  - `**/*Service.java`, `**/*Repository.java` (있다면)
  - 패키지별 카운트 + 도메인 분류표 → `inventory/02_stack_a_backend.md`
- [ ] 0.B.5 **Stack B 백엔드 인벤토리**:
  - `**/*.module.ts`, `**/*.controller.ts`, `**/*.service.ts` (NestJS)
  - `**/schema/*.ts` (Drizzle 스키마)
  - `**/queries/*.ts` 또는 Kysely 쿼리 빌더 사용처
  - 가드/인터셉터/파이프 → `inventory/03_stack_b_backend.md`
- [ ] 0.B.6 **프론트엔드 인벤토리** (Stack A/B 공통):
  - `**/pages/**/*.vue` 또는 `**/views/**/*.vue` (라우팅 단위)
  - `**/components/**/*.vue` (재사용 컴포넌트, `Cm~` 프리픽스 식별)
  - `**/composables/*.ts`, `**/stores/*.ts` (Pinia)
  - `router/*.ts`, `main.ts`, `App.vue`
  - Multi-panel pattern (grid/detail/chart/form) 적용 화면 목록 → `inventory/04_frontend.md`
- [ ] 0.B.7 **DB/마이그레이션 인벤토리**:
  - 모든 테이블 DDL (Drizzle 스키마 + MyBatis용 SQL 스크립트 + Flyway/Liquibase 마이그레이션)
  - 시드 데이터 스크립트
  - 인덱스/제약조건 → `inventory/05_database.md`
- [ ] 0.B.8 **테스트 인벤토리**: `**/*.test.ts`, `**/*.spec.ts`, `**/*Test.java`, k6 스크립트, Playwright/Cypress 케이스 → `inventory/06_tests.md`
- [ ] 0.B.9 **운영/인프라 인벤토리**: 배포 스크립트, 헬스체크 엔드포인트, 백업 스크립트, 크론/스케줄러, 로그 수집 설정 → `inventory/07_ops.md`
- [ ] 0.B.10 **로깅/추적 인벤토리**: `cid`/`hint` 필드 사용처 grep, 로거 설정(logback/winston/pino), 추적 ID 전파 코드 → `inventory/08_logging.md`
- [ ] 0.B.11 **보안 인벤토리**: 인증 필터/가드, JWT 발급/검증, 권한 체크 어노테이션, 비밀관리 코드, CORS/CSRF 설정 → `inventory/09_security.md`

#### 0.C 갭 분석 (Gap Analysis)
- [ ] 0.C.1 기존 산출물(0.A) ↔ 코드베이스(0.B) 비교: **문서엔 있는데 코드에 없는 것** / **코드엔 있는데 문서엔 없는 것** 양방향 식별
- [ ] 0.C.2 누락 위험 영역(배치 잡, 스케줄러, 헬스체크, 백업, 알람, 리트라이 정책, 회복절차 등) 체크 → `warn.md`
- [ ] 0.C.3 챕터 ↔ 정보원 매핑표 작성 → `inventory/10_chapter_source_map.md` (각 챕터 1.1–1.20이 어떤 기존 산출물·어떤 코드 경로를 1차 인풋으로 쓸지 명시)

#### 0.D 디스패치 계획
- [ ] 0.D.1 Phase 1 Group A–F 병렬 디스패치 계획 수립 (각 에이전트에게 전달할 매핑표·인풋 경로 확정)
- [ ] 0.D.2 사용자에게 0.A/0.B/0.C 요약 1회 보고 (총 산출물 수, 총 코드 파일 수, 갭 항목 수). 차단 없으면 Phase 1 진행.

### Phase 1 — 챕터별 문서화 (Group 단위 Task 에이전트 병렬 실행)

> **병렬 디스패치 규칙**
> - 각 Group의 챕터들을 동시에 Task 에이전트로 시작.
> - 각 에이전트는 **자기 파일만** 작성하고 다른 파일은 read-only로 참조.
> - Group 자체도 의존성 없으면 동시 실행 가능 (Group A–F 모두 동시 디스패치 권장).
>
> **각 챕터 에이전트 공통 의무 (반드시 지킬 것)**
> 1. 시작 시 `inventory/10_chapter_source_map.md`에서 자신의 챕터 매핑을 읽어, 지정된 **기존 산출물 + 코드 경로**를 1차 인풋으로 사용.
> 2. 본문 작성 시 사실 주장마다 출처를 명시 — 형식: `[src: docs/X.md]` 또는 `[code: src/.../FooBiz.java:L42-L80]`. 출처 없는 주장 금지.
> 3. 기존 산출물에 이미 잘 쓰인 부분은 **요약·재구성**하되 원의도 유지. 충돌 시 **코드가 우선**, 문서는 `warn.md`에 불일치로 기록.
> 4. 코드는 **샘플만 인용**(15줄 이내), 전체 dump 금지. 인용 시 파일경로:라인범위 명시.
> 5. 참조한 모든 산출물·코드 경로를 챕터 말미 `## 참조` 섹션에 리스트업.

**Group A — 기술/아키텍처 (병렬 5)**
- [ ] 1.1 `01_overview.md` — 프로젝트 비전, 적용 대상(SME/제조), 핵심 차별점, 라이선스 전략
- [ ] 1.2 `02_tech_stack.md` — Stack A/B 의존성 트리, 버전 매트릭스, 라이선스 표(Apache 2.0/MIT 적합성)
- [ ] 1.3 `03_architecture.md` — 시스템 컨텍스트/컨테이너/컴포넌트 다이어그램(Mermaid C4), Active-Active HA 토폴로지
- [ ] 1.4 `04_data_model.md` — ERD(Mermaid), 정규화 정책, 마이그레이션 전략, Drizzle vs MyBatis 차이
- [ ] 1.5 `05_api_spec.md` — REST 엔드포인트 표(메서드/경로/요청/응답/권한), 페이지네이션·정렬·필터 규약

**Group B — 프론트엔드 (병렬 3)**
- [ ] 1.6 `06_frontend_structure.md` — 디렉토리 구조, 라우팅, 상태관리, Vite/번들 설정
- [ ] 1.7 `07_frontend_components.md` — PrimeVue4 채택 이유, Multi-panel pattern (grid/detail/chart/form), Cm~ 공용 컴포넌트 카탈로그
- [ ] 1.8 `08_frontend_conventions.md` — 단일파일 Vue 패턴 순서(types→API→state→actions→template), Cm~/cm~ 프리픽스 규칙

**Group C — 백엔드 (병렬 3)**
- [ ] 1.9 `09_backend_structure.md` — Pattern A(Vue+Biz.java+Mapper.xml), Pattern B(공유 CmCrudController), Pattern C(외부 API용 Vue+Biz.java) 도메인 인벤토리
- [ ] 1.10 `10_backend_conventions.md` — MyBatis 동적 SQL 규약, Drizzle(스키마)/Kysely(런타임) 분리 전략, 트랜잭션 경계
- [ ] 1.11 `11_backend_logging.md` — 구조화 JSON 로깅(cid+hint), 추적 ID 전파, 로그 수집 파이프라인

**Group D — 운영/품질 (병렬 4)**
- [ ] 1.12 `12_security.md` — JWT 인증, 7-Role 권한 모델, 비밀관리(Vault/.env), OWASP Top 10 대응 매트릭스
- [ ] 1.13 `13_deployment.md` — Docker Compose 8서비스, Keepalived VIP, Ansible 플레이북, bare-metal systemd
- [ ] 1.14 `14_testing.md` — 유닛/통합/E2E, k6 부하, Toxiproxy 장애주입, 동시성/세션 일관성 검증
- [ ] 1.15 `15_observability.md` — Prometheus+Grafana 대시보드, Loki 또는 OpenSearch 로그, 알람 규칙

**Group E — 매뉴얼 (병렬 2)**
- [ ] 1.16 `16_user_manual.md` — 역할별 시나리오(관리자/일반/외부), 화면 흐름, 스크린샷 placeholder 표시
- [ ] 1.17 `17_operations_manual.md` — 설치/업그레이드 절차, 백업·복구 런북, 장애 대응 시나리오, 롤링 배포 절차

**Group F — 가이드/부록 (병렬 3)**
- [ ] 1.18 `18_dev_guide.md` — CODING_STANDARDS §0–§23 요약, 11항목 자기검증, AI 생성 제약사항
- [ ] 1.19 `19_troubleshooting.md` — 빈도순 FAQ, 알려진 이슈와 해결법, 로그 패턴별 진단표
- [ ] 1.20 `20_appendix.md` — 용어집(KR/EN), 참고 링크, 라이선스 전문, 변경 이력

### Phase 2 — 검증 (Sequential)
- [ ] 2.1 챕터 20개 파일 존재 및 최소 길이(예: 2KB) 확인
- [ ] 2.2 `warn.md` 식별 영역이 어느 챕터엔가 반드시 등장하는지 grep 검증
- [ ] 2.3 코드베이스 인벤토리(0.B) vs 챕터 본문 교차검증 — 누락 도메인 0
- [ ] 2.4 기존 산출물 인벤토리(0.A) vs 챕터 참조 섹션 교차검증 — **0.A의 모든 문서가 최소 1개 챕터에서 참조되어야 함**
- [ ] 2.5 각 챕터 `## 참조` 섹션 비어있지 않음 확인 (출처 0건 = 환각 가능성)
- [ ] 2.6 용어/버전/경로 일관성 검사 (예: "Stack A" 표기 통일, 버전 충돌 없음)
- [ ] 2.7 대표 코드 예시 5개 실제 빌드/실행 가능 여부 확인
- [ ] 2.8 상호 참조 링크(`[01_overview](#)` 등) 깨짐 0건

### Phase 3 — 통합 & PDF 생성 (Sequential)
- [ ] 3.1 `00_cover.md` (표지: 제목/버전/날짜/작성자), `00_toc.md` (자동 목차) 생성
- [ ] 3.2 챕터 순서대로 `_combined.md`로 결합 (구분 페이지 브레이크 삽입)
- [ ] 3.3 Mermaid 코드블록 → SVG/PNG 변환 (`mmdc -i ... -o assets/`)
- [ ] 3.4 pandoc 변환:
  ```
  pandoc _combined.md -o build/framework_manual_v{ver}.pdf \
    --pdf-engine=xelatex \
    -V mainfont="Noto Sans CJK KR" \
    -V monofont="JetBrains Mono" \
    -V geometry:a4paper -V geometry:margin=2cm \
    --toc --toc-depth=3 --number-sections \
    --highlight-style=tango \
    -V linkcolor=blue
  ```
- [ ] 3.5 페이지 번호, 머리말/꼬리말, PDF 북마크 확인

### Phase 4 — 최종 점검 (Sequential)
- [ ] 4.1 PDF 메타데이터(제목/저자/키워드/생성일) 설정
- [ ] 4.2 무작위 10페이지 가독성/레이아웃 스폿 체크
- [ ] 4.3 다이어그램 렌더링 누락 0, 잘림 0 확인
- [ ] 4.4 최종 보고: 페이지 수 / 챕터 수 / 다이어그램 수 / 빌드 시간 / 산출물 경로

---

## 병렬 실행 지침 (Task 에이전트 디스패치 예시)

```
Group A 디스패치 (동시 5개):
  - Task: "01_overview.md 작성 — 프로젝트 비전/적용대상/차별점. info.md의 인벤토리만 read-only 참조. 4–6KB 분량."
  - Task: "02_tech_stack.md 작성 — Stack A/B 의존성과 라이선스 매트릭스. 표 형식 필수."
  - ... (1.3–1.5 동일 패턴)

Group B/C/D/E/F도 같은 방식으로 동시 디스패치.
모든 Group을 한꺼번에 시작해도 되고, 안전을 위해 Group 단위로 순차 실행해도 됨.
```

## 누락 방지 게이트
1. 각 챕터 말미에 **"이 챕터가 다루지 않은 인접 주제"** 1–3줄 필수.
2. `warn.md`에 식별된 영역은 챕터 본문에서 grep으로 발견되어야 함.
3. Phase 0의 모든 인벤토리(`inventory/00`–`10`) 항목이 챕터 어딘가에 등장해야 함 (`inventory/10_chapter_source_map.md` 기준 100% 커버).
4. 각 챕터의 `## 참조` 섹션이 비어있지 않을 것 (출처 없는 챕터 = 환각 의심).
5. 기존 산출물(0.A) 중 어느 챕터에도 매핑되지 않은 문서가 있다면 `warn.md`에 보고.
6. CODING_STANDARDS의 11항목 자기검증 블록을 본 문서에도 마지막에 부착.

## 진행 보고 규칙
- 매 Phase 완료 시 `info.md` 누적 append (시간/단계/요약).
- 차단 발생 시 `warn.md`(권장 우회) 또는 `fatal.md`(사용자 확인 필요)에 기록 후 즉시 보고.
- 최종 완료 시 한 줄 요약: `✅ framework_manual_v{ver}.pdf — {pages}p, {chapters}ch, {diagrams}dia, {minutes}min`.

## 산출물 위치
`/docs/comprehensive/build/framework_manual_v{버전}.pdf`

---

## 시작 명령
> "Phase 0부터 시작. 먼저 **0.A(기존 산출물 전수 스캔)**과 **0.B(코드베이스 전수 분석)**을 수행하여 `inventory/` 디렉토리에 11개 인벤토리 파일을 만들고, **0.C(갭 분석)**으로 `inventory/10_chapter_source_map.md`를 작성하라. 그 결과를 `info.md`에 1회 요약 보고한 후, 차단 없으면 Phase 1 Group A–F를 Task 에이전트로 동시 디스패치 (총 20개 챕터 병렬). 각 챕터 에이전트는 자신의 매핑된 산출물·코드 경로만 1차 인풋으로 사용하고, 모든 사실 주장에 출처를 명시할 것. 이후 Phase 2–4 순차 진행. 모든 산출물은 `/docs/comprehensive/`에 누적."
