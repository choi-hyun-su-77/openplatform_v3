# ts-spring-fw 재사용 추적표

**원본 위치**: `C:\claude\ts-spring-fw` — **절대 수정 금지**
**복사 대상**: `C:\claude\openplatform_v3\ui\src\**`

> 원본은 읽기 전용 참조 자산이며, 필요한 파일을 Phase 4에서 정적 복사합니다.
> 복사 시 각 파일에 대해 (원본경로 → v3경로 → 수정사항) 1행씩 기록.

## 예정 복사 목록

### 레이아웃 (Phase 4-2)
| 원본 | v3 경로 | 수정 |
|---|---|---|
| `frontend/src/components/layout/LayoutDefault.vue` | `ui/src/components/layout/LayoutDefault.vue` | 미정 |
| `frontend/src/components/layout/LayoutHeader.vue` | `ui/src/components/layout/LayoutHeader.vue` | 미정 |
| `frontend/src/components/layout/LayoutSidebar.vue` | `ui/src/components/layout/LayoutSidebar.vue` | 메뉴 데이터 소스 v3로 교체 |
| `frontend/src/components/layout/LayoutTabBar.vue` | `ui/src/components/layout/LayoutTabBar.vue` | 미정 |

### 공통 컴포넌트
| 원본 | v3 경로 | 수정 |
|---|---|---|
| `frontend/src/components/common/CrudToolbar.vue` | `ui/src/components/common/CrudToolbar.vue` | 미정 |
| `frontend/src/components/common/SearchPanel.vue` | `ui/src/components/common/SearchPanel.vue` | 미정 |
| `frontend/src/components/common/PopupHost.vue` | `ui/src/components/common/PopupHost.vue` | 미정 |

### Composables
| 원본 | v3 경로 | 수정 |
|---|---|---|
| `composables/useDataSet.ts` | `ui/src/composables/useDataSet.ts` | API base URL → /api |
| `composables/useDataSetPaging.ts` | `ui/src/composables/useDataSetPaging.ts` | 미정 |
| `composables/usePermission.ts` | `ui/src/composables/usePermission.ts` | Keycloak roles 매핑 |
| `composables/useCodes.ts` | `ui/src/composables/useCodes.ts` | 미정 |
| `composables/useLabel.ts` | `ui/src/composables/useLabel.ts` | 미정 |
| `composables/useMessage.ts` | `ui/src/composables/useMessage.ts` | 미정 |
| `composables/useCombo.ts` | `ui/src/composables/useCombo.ts` | 미정 |
| `composables/useLocale.ts` | `ui/src/composables/useLocale.ts` | 미정 |
| `composables/useTheme.ts` | `ui/src/composables/useTheme.ts` | 미정 |

### Store / API
| 원본 | v3 경로 | 수정 |
|---|---|---|
| `store/auth.ts` | `ui/src/store/auth.ts` | **keycloak-js 어댑터로 교체** (JWT 자체 발급 → OIDC PKCE) |
| `store/tab.ts` | `ui/src/store/tab.ts` | 미정 |
| `api/interceptor.ts` | `ui/src/api/interceptor.ts` | **Bearer 토큰을 Keycloak access token으로 교체**, 401 → keycloak.updateToken() |

### 라우터 / 페이지 템플릿
| 원본 | v3 경로 | 수정 |
|---|---|---|
| `router/index.ts` | `ui/src/router/index.ts` | 라우트 전체 교체 (그룹웨어 라우트), 가드 로직만 유지 |
| `pages/PageLogin.vue` | `ui/src/pages/PageLogin.vue` | 레이아웃만 유지, 로그인 로직은 Keycloak 리다이렉트로 교체 |

### 참고 템플릿 (직접 복사는 필요 시에만)
- `pages/templates/*.vue` — Chart/Map/Flow/Kanban/Calendar/PDF/QR/Excel 20+ 템플릿
- 그룹웨어 페이지 제작 시 **레퍼런스로 참조**하고, 필요한 것만 선택 복사

## 복사 금지 (규칙)
- `backend/**` 전부
- `docker/**`
- `mybatis mapper XML`
- `pages/admin/**` (fw_* 관리 화면)
- 원본 경로의 어떤 파일도 **수정**하지 않음
