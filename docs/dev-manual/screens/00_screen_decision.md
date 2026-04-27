# screens/00_screen_decision.md — 화면 형태 결정 트리

> Phase 3.0 산출물. "사용자가 무엇을 하려 하는가?" 기준 분기 → 정확히 하나의 형태 SOP 도달.

## Mermaid Flowchart

```mermaid
flowchart TD
    Start([사용자 의도]) --> Q1{무엇을 하려 하는가?}

    Q1 --> A1[다건 조회·검색]
    Q1 --> A2[단건 보기/편집]
    Q1 --> A3[계층 탐색<br/>부서/폴더/메일함]
    Q1 --> A4[일정·예약 관리]
    Q1 --> A5[KPI/요약 한눈에]
    Q1 --> A6[다단계 신청서]
    Q1 --> A7[외부 시스템 진입<br/>Wiki/Chat/Mail]
    Q1 --> A8[실시간 협업/알림]
    Q1 --> A9[설정 매트릭스 일괄 변경]

    A1 --> S1[형태 1: 다건 목록<br/>screens/01_list_with_search.md]
    A2 --> S2[형태 2: 단건 상세 다이얼로그<br/>screens/02_detail_dialog.md]
    A3 --> S3[형태 3: 마스터-디테일<br/>screens/03_master_detail.md]
    A4 --> S4[형태 4: 캘린더 그리드<br/>screens/04_calendar_grid.md]
    A5 --> S5[형태 5: 대시보드 위젯 그리드<br/>screens/05_dashboard_widgets.md]
    A6 --> S6[형태 6: 다단계 입력 다이얼로그<br/>screens/06_multistep_dialog.md]
    A7 --> S7[형태 7: SSO 래퍼<br/>screens/07_sso_wrapper.md]
    A8 --> S8[형태 8: 실시간<br/>screens/08_realtime.md]
    A9 --> S9[형태 9: 폼 매트릭스<br/>screens/09_form_matrix.md]
```

## 분기 검증

- 9개 종착점, 막다른 분기 없음
- 모든 분기는 SOP 파일 1개에 도달
- 형태 9개 검증 (출처: `[doc: inventory/03_screen_types.md]`)

## 화면 조합 안내

여러 형태가 한 화면에 결합되는 경우가 흔하다 (예: PageBoard = 형태 1 + 형태 2; PageRoom = 형태 3 + 형태 4). 이 경우:
1. **주 형태**(라우트 진입의 첫 화면) SOP 부터 따른다.
2. 자식 다이얼로그/패널은 **부속 형태** SOP 의 4표 부분만 별도로 적용.
3. 부모-자식 통신은 각 SOP 의 "부모-자식·라우터 연동" 섹션에 명시.

| 흔한 조합 | 주 형태 | 부속 형태 |
|---|---|---|
| 게시판 (목록 + 상세) | 1 | 2 |
| 결재 (인박스 + 상세 + 신청) | 1 | 2 + 6 |
| 자료실 (Tree + 파일 + 미리보기) | 3 | 1 |
| 회의실 (Room sidebar + 캘린더) | 3 | 4 |
| 캘린더 (Calendar + 이벤트 다이얼로그) | 4 | 2 |
| 휴가 (이력 + 신청) | 1 | 6 |
