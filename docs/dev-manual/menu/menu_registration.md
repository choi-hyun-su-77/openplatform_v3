# menu/menu_registration.md — 메뉴 등록 절차서 (8단계)

> Phase 4 산출물. 모든 SOP 의 메뉴 관련 Step 은 본 문서를 링크만 한다 (중복 서술 금지).
> 본문은 `[doc: inventory/05_menu_registration_points.md]` 의 K=8 단계를 그대로 옮기되, 4표 형식으로 구체화.

---

## Step 1 — 부모 메뉴 INSERT (계층이 새로 필요할 때만)

> 기존 부모(`mywork`, `work`, `settings`, `admin`) 중 하나에 매달면 본 단계 생략.

### 표 1. 복사할 파일

| 원본 | 복사 후 | 치환 식별자 | 비고 |
|---|---|---|---|
| `[code: backend-core/src/main/resources/db/migration/V17__phase14_menus.sql:8-10]` (부모 메뉴 1행) | `backend-core/src/main/resources/db/migration/V{N+1}__{domain}_menu.sql` | `__parent_id__`, `__parent_name_ko__`, `__sort_order__`, `__icon__` | V{N} 은 현재 V17 다음 자유 번호 |

### 표 2. 신규 생성할 파일

| 경로 | 역할 | 골격 출처 |
|---|---|---|
| `backend-core/src/main/resources/db/migration/V{N+1}__{domain}_menu.sql` | 새 도메인 메뉴 마이그레이션 | `templates/menu/V__menu_template.sql.tmpl` |

### 표 3. 수정할 기존 파일

| 경로 | 수정 위치 | 추가·변경 요약 |
|---|---|---|
| (해당 없음) | — | — |

### 표 4. 식별자 치환

| From | To | 적용 범위 |
|---|---|---|
| `__parent_id__` | (예: `mygroup`) | 마이그레이션 파일 |
| `__parent_name_ko__` | (예: `내 그룹`) | 마이그레이션 파일 |
| `__sort_order__` | (예: `50`) | 마이그레이션 파일 |
| `__icon__` | (예: `pi pi-folder`) | 마이그레이션 파일 |

### 모범 INSERT
```sql
INSERT INTO platform_v3.cm_menu (menu_id, menu_name, menu_path, parent_menu_id, menu_level, sort_order, icon)
VALUES ('mygroup', '내 그룹', NULL, NULL, 1, 50, 'pi pi-folder')
ON CONFLICT (menu_id) DO NOTHING;
```

### 검증
```sql
SELECT * FROM platform_v3.cm_menu WHERE menu_id='__parent_id__';
-- 1 row, parent_menu_id=NULL, menu_level=1
```

---

## Step 2 — 자식 메뉴 INSERT (도메인 메뉴 본체) — 필수

### 표 1. 복사할 파일

| 원본 | 복사 후 | 치환 식별자 | 비고 |
|---|---|---|---|
| `[code: V17__phase14_menus.sql:13-14]` (자식 메뉴 1행) | Step 1 의 마이그레이션 파일에 추가 | `__domain-kebab__`, `__domainKorean__`, `__parent_id__`, `__sort_order__`, `__icon__` | |

### 표 2. 신규 생성할 파일

| 경로 | 역할 | 골격 출처 |
|---|---|---|
| (Step 1 의 마이그레이션과 동일) | — | — |

### 표 3. 수정할 기존 파일

| 경로 | 수정 위치 | 추가·변경 요약 |
|---|---|---|
| Step 1 의 V{N+1} 마이그레이션 | `INSERT cm_menu` 블록 | 자식 행 추가 |

### 표 4. 식별자 치환

| From | To | 적용 범위 |
|---|---|---|
| `__domain-kebab__` | (예: `notice`) | 마이그레이션 |
| `__domainKorean__` | (예: `공지사항`) | 마이그레이션 |
| `__parent_id__` | (예: `mywork`) | 마이그레이션 |
| `__sort_order__` | (예: `15`) | 마이그레이션 |
| `__icon__` | (예: `pi pi-megaphone`) | 마이그레이션 |

### 모범 INSERT
```sql
INSERT INTO platform_v3.cm_menu (menu_id, menu_name, menu_path, parent_menu_id, menu_level, sort_order, icon)
VALUES ('notice', '공지사항', '/notice', 'mywork', 2, 15, 'pi pi-megaphone')
ON CONFLICT (menu_id) DO NOTHING;
```

### 검증
```sql
SELECT * FROM platform_v3.cm_menu WHERE menu_id='__domain-kebab__';
-- parent_menu_id=__parent_id__, menu_level=2, menu_path=/__domain-kebab__
```

---

## Step 3 — Role-Menu 권한 INSERT — 필수

### 표 1. 복사할 파일

| 원본 | 복사 후 | 치환 식별자 | 비고 |
|---|---|---|---|
| `[code: V17__phase14_menus.sql:60-90]` (cm_role_menu SELECT INSERT 블록) | Step 1 의 마이그레이션에 추가 | `__domain-kebab__`, `__role_id__` | ROLE_USER + ROLE_ADMIN 두 행 권장 |

### 표 2. 신규 생성할 파일

| 경로 | 역할 | 골격 출처 |
|---|---|---|
| (동일 마이그레이션) | — | — |

### 표 3. 수정할 기존 파일

| 경로 | 수정 위치 | 추가·변경 요약 |
|---|---|---|
| Step 1 의 V{N+1} | `INSERT cm_role_menu` 블록 | 역할별 권한 행 추가 |

### 표 4. 식별자 치환

| From | To | 적용 범위 |
|---|---|---|
| `__domain-kebab__` | 도메인 메뉴 코드 | 마이그레이션 |
| `__role_id__` | `ROLE_USER`, `ROLE_ADMIN`, `ROLE_APPROVER` 등 | 마이그레이션 |

### 모범 INSERT
```sql
INSERT INTO platform_v3.cm_role_menu
  (role_id, menu_id, can_read, can_create, can_update, can_delete, can_export, can_print)
VALUES
  ('ROLE_USER',  'notice', TRUE, FALSE, FALSE, FALSE, TRUE, TRUE),
  ('ROLE_ADMIN', 'notice', TRUE, TRUE,  TRUE,  TRUE,  TRUE, TRUE)
ON CONFLICT (role_id, menu_id) DO NOTHING;
```

### 검증
```sql
SELECT role_id, can_read FROM platform_v3.cm_role_menu WHERE menu_id='__domain-kebab__';
-- ROLE_USER + ROLE_ADMIN, can_read=TRUE
```

---

## Step 4 — Vue 페이지 컴포넌트 생성 — 필수

### 표 1. 복사할 파일

| 원본 | 복사 후 | 치환 식별자 | 비고 |
|---|---|---|---|
| `[code: ui/src/pages/PageBoard.vue]` (형태별 모범 페이지 — 형태 1 기준) | `ui/src/pages/Page__DomainPascal__.vue` | `__DomainPascal__`, `__domain-kebab__`, `__domainKorean__` | 화면 형태별 모범은 `[doc: inventory/08_references.md]` 참조 |

### 표 2. 신규 생성할 파일

| 경로 | 역할 | 골격 출처 |
|---|---|---|
| `ui/src/pages/Page__DomainPascal__.vue` | 도메인 페이지 | `templates/screen_types/{type}/Page.vue.tmpl` |

### 표 3. 수정할 기존 파일

| 경로 | 수정 위치 | 추가·변경 요약 |
|---|---|---|
| (해당 없음 이 단계에서는) | — | — |

### 표 4. 식별자 치환

| From | To | 적용 범위 |
|---|---|---|
| `__DomainPascal__` | (예: `Notice`) | 컴포넌트 명, import 경로 |
| `__domain-kebab__` | (예: `notice`) | 라우트 path, serviceName |
| `__domainKorean__` | (예: `공지사항`) | UI 라벨 |

### 검증
- TypeScript 컴파일 통과 (`npm run build` 또는 IDE)
- 페이지 vue 파일이 lint 통과

---

## Step 5 — Vue Router 등록 — 필수

### 표 1. 복사할 파일

| 원본 | 복사 후 | 치환 식별자 | 비고 |
|---|---|---|---|
| `[code: ui/src/router/index.ts:33-46]` 의 기존 routes 배열 1 entry | (수정) | `__domain-kebab__`, `__DomainPascal__` | 관리자 라우트면 `requiresAdmin: true` 추가 |

### 표 2. 신규 생성할 파일

| 경로 | 역할 | 골격 출처 |
|---|---|---|
| (해당 없음) | — | — |

### 표 3. 수정할 기존 파일

| 경로 | 수정 위치 | 추가·변경 요약 |
|---|---|---|
| `ui/src/router/index.ts` | `routes[0].children` 배열 (line 33~46 인근) | 신규 route entry 1 줄 추가 |

### 표 4. 식별자 치환

| From | To | 적용 범위 |
|---|---|---|
| `__domain-kebab__` | route path + name + meta.menuId | router/index.ts |
| `__DomainPascal__` | dynamic import 페이지 컴포넌트 | router/index.ts |

### 코드 추가 패턴
```typescript
{
  path: '__domain-kebab__',
  name: '__domain-kebab__',
  component: () => import('@/pages/Page__DomainPascal__.vue'),
  meta: { menuId: '__domain-kebab__' }
}
// 관리자 라우트의 경우:
{
  path: 'admin/__domain-kebab__',
  name: 'admin-__domain-kebab__',
  component: () => import('@/pages/admin/Page__DomainPascal__.vue'),
  meta: { menuId: 'admin___domain_snake__', requiresAdmin: true }
}
```

### 검증
- `npm run build` 통과
- path 가 Step 2 의 `menu_path` 와 글자 단위 일치

---

## Step 6 — Tab 아이템 (선택)

> 자동 생성: `ui/src/store/tab.ts` 가 router meta 와 `router.resolve` 로 탭을 만듦. **수동 등록 불필요.**

### 표 1. 복사할 파일

| 원본 | 복사 후 | 치환 식별자 | 비고 |
|---|---|---|---|
| (해당 없음) | — | — | 자동 처리 |

### 표 2. 신규 생성할 파일
| 경로 | 역할 | 골격 출처 |
|---|---|---|
| (해당 없음) | — | — |

### 표 3. 수정할 기존 파일
| 경로 | 수정 위치 | 추가·변경 요약 |
|---|---|---|
| (해당 없음 — Step 5 의 router 가 충분) | — | — |

### 표 4. 식별자 치환
| From | To | 적용 범위 |
|---|---|---|
| (해당 없음) | — | — |

### 검증
- 사이드바에서 새 메뉴 클릭 시 LayoutTabBar 에 탭이 자동 등장

---

## Step 7 — i18n 라벨 INSERT (선택)

> 갭: 현재 `cm_menu.menu_name` 직접 사용 → frontend lookup 미구현. 라벨 INSERT 만 진행하고 향후 lookup 도입 시 자동 활성화.

### 표 1. 복사할 파일

| 원본 | 복사 후 | 치환 식별자 | 비고 |
|---|---|---|---|
| `[code: V9__i18n_labels_and_seed_data.sql:24-35]` (4 locale 행) | `backend-core/src/main/resources/db/migration/V{N+2}__i18n_{domain}.sql` | `__DOMAIN_UPPER__`, `__domainKorean__`, `__domainEnglish__`, `__domainChinese__`, `__domainJapanese__` | |

### 표 2. 신규 생성할 파일

| 경로 | 역할 | 골격 출처 |
|---|---|---|
| `V{N+2}__i18n_{domain}.sql` | i18n 라벨 마이그레이션 | `templates/menu/V__i18n_template.sql.tmpl` |

### 표 3. 수정할 기존 파일
| 경로 | 수정 위치 | 추가·변경 요약 |
|---|---|---|
| (해당 없음) | — | — |

### 표 4. 식별자 치환

| From | To | 적용 범위 |
|---|---|---|
| `__DOMAIN_UPPER__` | (예: `NOTICE`) | i18n msg_key |
| `__domainKorean__` 외 4언어 | 라벨 텍스트 | message column |

### 모범 INSERT
```sql
INSERT INTO platform_v3.cm_i18n_message (msg_key, locale, msg_type, message)
VALUES
  ('MENU_NOTICE','ko','MENU','공지사항'),
  ('MENU_NOTICE','en','MENU','Notices'),
  ('MENU_NOTICE','zh','MENU','公告'),
  ('MENU_NOTICE','ja','MENU','お知らせ')
ON CONFLICT DO NOTHING;
```

### 검증
- `SELECT * FROM platform_v3.cm_i18n_message WHERE msg_key='MENU___DOMAIN_UPPER__';` → 4 rows

---

## Step 8 — 권한 검증 테스트 — 필수

### 표 1. 복사할 파일

| 원본 | 복사 후 | 치환 식별자 | 비고 |
|---|---|---|---|
| (해당 없음, 절차만) | — | — | — |

### 표 2. 신규 생성할 파일

| 경로 | 역할 | 골격 출처 |
|---|---|---|
| (해당 없음) | — | — |

### 표 3. 수정할 기존 파일

| 경로 | 수정 위치 | 추가·변경 요약 |
|---|---|---|
| (해당 없음, 검증만) | — | — |

### 표 4. 식별자 치환

| From | To | 적용 범위 |
|---|---|---|
| `__domain-kebab__` | 검증 대상 메뉴 코드 | 검증 절차 |

### 검증 체크리스트

1. **DB**:
   ```sql
   SELECT * FROM platform_v3.cm_menu WHERE menu_id='__domain-kebab__';
   SELECT * FROM platform_v3.cm_role_menu WHERE menu_id='__domain-kebab__';
   ```
2. **Backend API** (`POST /api/dataset/search`):
   ```json
   { "serviceName": "menu/searchByUser", "datasets": {} }
   ```
   응답의 `ds_menus.rows` 에 `__domain-kebab__` 포함 확인.
3. **사이드바**: `ROLE_USER` 로그인 → 부모 그룹 아래에 메뉴 노출 확인 → 클릭 시 `/__domain-kebab__` 이동
4. **가드 (can_read=FALSE)**:
   ```sql
   UPDATE platform_v3.cm_role_menu SET can_read=FALSE WHERE menu_id='__domain-kebab__' AND role_id='ROLE_USER';
   ```
   브라우저 새로고침 → URL 직접 접근 시 `/403` redirect 확인. (테스트 후 원복)
5. **admin 가드** (`requiresAdmin=true` 라우트의 경우):
   `ROLE_USER` 직접 접근 → `/403`. `ROLE_ADMIN` → 정상 접근.

### 권한 시나리오 표

| 사용자 | 노출 | 사이드바 | 직접 URL 접근 |
|---|---|---|---|
| ROLE_USER (`can_read=TRUE`) | O | 보임 | 접근 |
| ROLE_USER (`can_read=FALSE`) | X | 안 보임 | `/403` |
| 익명 사용자 | X | (로그인 페이지) | `/login` |
| ROLE_ADMIN (`requiresAdmin=true`) | O | 보임 | 접근 |
| ROLE_USER (`requiresAdmin=true`) | X | 안 보임 | `/403` |

### URL 직접 접근 가드 동작
- `router.beforeEach` (`[code: ui/src/router/index.ts:57-85]`) 가 `meta.requiresAdmin` 검사 + `auth.menus[].canRead` 검사 → 실패 시 `/403`

### 다국어/아이콘/정렬 표기 확인 (해당 메커니즘 있는 경우만)
- 아이콘: `cm_menu.icon` 컬럼 (PrimeIcon 또는 Tabler 클래스) → LayoutSidebar 가 그대로 적용
- 정렬: `cm_menu.sort_order` ASC
- 다국어: `cm_i18n_message` (현재는 lookup 미구현 — 갭)

---

## 모범 워크스루 — `attendance` 메뉴 등록 (V17 기반)

> 출처: `[code: backend-core/src/main/resources/db/migration/V17__phase14_menus.sql]`

1. **Step 1**: V17 가 부모 메뉴 `mywork` (level=1, sort=10, icon=`pi pi-briefcase`) 추가.
2. **Step 2**: V17 가 자식 메뉴 `attendance` (parent=`mywork`, path=`/attendance`, sort=11, icon=`pi pi-clock`) 추가.
3. **Step 3**: V17 가 `cm_role_menu` SELECT INSERT 로 `ROLE_USER` 에 `can_read|create|update|export|print=TRUE` 부여 (delete=FALSE).
4. **Step 4**: `[code: ui/src/pages/PageAttendance.vue]` 작성 완료.
5. **Step 5**: `[code: ui/src/router/index.ts]` 의 children 에 `{ path: 'attendance', name: 'attendance', component: () => import('@/pages/PageAttendance.vue'), meta: { menuId: 'attendance' } }` 등록.
6. **Step 6**: 자동 — LayoutTabBar 가 클릭 시 탭 생성.
7. **Step 7**: i18n 라벨은 미등록 (현재 갭으로 `cm_menu.menu_name` 직접 사용).
8. **Step 8**: ROLE_USER 로그인 → `내 업무 > 근태` 사이드바 노출 → 클릭 → PageAttendance 정상 렌더 확인.
