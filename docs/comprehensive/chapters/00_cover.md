---
title: "openplatform_v3 — 풀스택 프레임워크 종합 매뉴얼"
subtitle: "Spring Boot 3.2 + Vue 3 + Keycloak Federation"
author: "openplatform_v3 팀 (자동 문서화)"
date: "2026-04-27"
version: "v1.0"
---

# openplatform_v3 종합 매뉴얼

**버전**: v1.0  
**작성일**: 2026-04-27  
**기준**: Phase 14 완료 시점

## 문서 구성

본 매뉴얼은 다음 20개 챕터로 구성됩니다.

| # | 챕터 | 내용 |
|---|------|------|
| 1.1 | 개요 | 프로젝트 비전, 적용 대상, 핵심 차별점 |
| 1.2 | 기술 스택 | Spring Boot/Vue 3 의존성과 라이선스 |
| 1.3 | 아키텍처 | C4 컨테이너/컴포넌트 그림 |
| 1.4 | 데이터 모델 | ERD + Flyway V1~V17 |
| 1.5 | API 명세 | DataSet 라우터 + BFF Federation |
| 1.6 | 프엔 구조 | 디렉토리/라우터/Pinia/Vite |
| 1.7 | 컴포넌트 | PrimeVue 4 + Multi-panel pattern |
| 1.8 | 프엔 규약 | SFC 순서, useXxx, 네이밍 |
| 1.9 | 백엔드 구조 | Pattern A/B/C, 도메인 16개 |
| 1.10 | 백엔드 규약 | MyBatis, _rowType, 트랜잭션 |
| 1.11 | 로깅·추적 | Logback, AOP, Loki |
| 1.12 | 보안 | OAuth2/JWT, RBAC, OWASP |
| 1.13 | 배포 | Docker compose 8 yml + Traefik |
| 1.14 | 테스트 | Playwright E2E + 권장 |
| 1.15 | 관찰성 | Prometheus/Grafana/Loki |
| 1.16 | 사용자 매뉴얼 | 역할별 시나리오 |
| 1.17 | 운영 매뉴얼 | 백업/복구/장애대응 |
| 1.18 | 개발 가이드 | 워크스페이스 규칙 + 신규 도메인 절차 |
| 1.19 | 트러블슈팅 | 빈도순 FAQ + 알려진 미완 |
| 1.20 | 부록 | 용어집/링크/체인지로그 |

