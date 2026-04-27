# framework_documentation — 자율 결정/주의 이력

## [2026-04-27] PDF 엔진 선택 — xelatex 미설치
- **상황**: 프롬프트가 권장한 `xelatex` 미설치 (LaTeX 배포판 부재).
- **결정**: pandoc + weasyprint(HTML→PDF) 경로 채택. `pandoc -t html5 ... | weasyprint -` 또는 `pandoc --pdf-engine=weasyprint`.
- **근거**: weasyprint 는 CSS 기반 PDF 렌더링으로 한글 폰트(`Noto Sans CJK KR`)와 다이어그램 임베딩에 충분. xelatex 설치는 1GB+ MikTeX 다운로드 부담.
- **대안**: 문제가 발생하면 pandoc `wkhtmltopdf` 또는 `prince` 시도.

## [2026-04-27] Phase 1 디스패치 — Explore 에이전트의 Write 권한 부재
- **상황**: 첫 5개 챕터(1.1~1.5)와 중간 6개(1.6~1.11)를 Explore subagent_type 으로 디스패치했으나, Explore 는 Edit/Write/NotebookEdit 미보유 → 본문 파일 생성 실패. 1.2 결과가 정리 텍스트만 반환됨.
- **결정**: 향후 디스패치는 general-purpose 사용 (Tools `*`). 이미 진행 중인 1.1·1.3~1.11 Explore 결과는 텍스트 본문을 받는 즉시 메인 에이전트가 직접 Write 로 저장.
- **영향**: 약간의 토큰/시간 손실. 챕터 품질엔 영향 없음.

## [2026-04-27] Phase 0.C 갭 분석 결과
**기존 산출물 → 코드 누락**: 없음. 산출물은 모두 코드의 일부분에 매핑됨.
**코드 → 산출물 누락 (문서화 시 보강 필요)**:
- 단위/통합 테스트 (JUnit/Mockito) 부재 — 06_tests.md 에 "권장" 으로 기술. 챕터 14 에서 "현 상태=E2E only, 권장=JUnit + Testcontainers" 로 솔직 명시.
- CODING_STANDARDS.md 부재 — 프롬프트가 §0–§23 가정. 챕터 18 에서 "warn: CODING_STANDARDS 미존재 → CLAUDE.md + warn.md 결정 이력 + 컨벤션 grep 결과로 대체" 로 기술.
- 알람 규칙(Prometheus alerting rules) 미존재 — 챕터 15 에서 솔직 기술 + 권장.
- 부서장/관리자 역할 정의가 코드(role 문자열)에만 존재 — 매뉴얼 챕터 1.16 에서 권장 보강.
- recordHistory 의 actorName 미해결 TODO (warn.md 16~18행) — 트러블슈팅 챕터 1.19 에 "알려진 미완" 항목으로 기록.
- BFF /api/bff/mail/send 의 service-account 인증 부재 — 1.12 보안 + 1.19 트러블슈팅에 기록.

**누락 위험 영역(체크리스트)**:
- [x] 배치 잡 — `infra/docker-compose.cron.yml` 존재 (1.13 deployment, 1.17 ops)
- [x] 헬스체크 — `infra/docker-compose.healthcheck.yml` (1.13)
- [x] 백업 — `scripts/backup.sh`/`restore.sh` (1.17)
- [ ] 알람 규칙 — 미존재. 1.15 에 권장으로 기술.
- [x] 리트라이 정책 — `UI/api/interceptor.ts` (1.6/1.11)
- [ ] 회복절차 — 부분 존재(restore.sh). 1.17 에서 보강.

## [2026-04-27] 프롬프트의 Stack A/B 매핑 재해석
- **상황**: 프롬프트는 "Stack A = MyBatis(.java)", "Stack B = NestJS+Drizzle" 가정을 깔고 있음. 본 프로젝트는 NestJS 없음.
- **결정**: Stack A = `backend-core` (DataSet 도메인, MyBatis-XML + JPA + Flowable BPMN), Stack B = `backend-bff` (Port-Adapter, OAuth2 Resource Server). 두 개 모두 Spring Boot 3.x.
- **근거**: 프로젝트 CLAUDE.md "옵션 C 하이브리드: v1 DataSet 도메인(backend-core) + v2 Port-Adapter(backend-bff)".
- **영향**: 챕터 09(backend_structure)·10(backend_conventions)에서 NestJS/Drizzle 기술스택 부분은 모두 Spring Boot 기준으로 재작성.
