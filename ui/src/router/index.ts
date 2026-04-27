import { createRouter, createWebHistory, type RouteRecordRaw } from 'vue-router';
import { useAuthStore } from '@/store/auth';

const routes: RouteRecordRaw[] = [
  {
    path: '/login',
    name: 'login',
    component: () => import('@/pages/PageLogin.vue'),
    meta: { requiresAuth: false }
  },
  {
    path: '/403',
    name: 'forbidden',
    component: () => import('@/pages/Page403.vue'),
    meta: { requiresAuth: false }
  },
  {
    path: '/',
    component: () => import('@/components/layout/LayoutDefault.vue'),
    meta: { requiresAuth: true },
    children: [
      { path: '', redirect: '/dashboard' },
      { path: 'dashboard', name: 'dashboard', component: () => import('@/pages/PageDashboard.vue'), meta: { menuId: 'dashboard' } },
      { path: 'approval',  name: 'approval',  component: () => import('@/pages/PageApproval.vue'),  meta: { menuId: 'approval'  } },
      { path: 'board',     name: 'board',     component: () => import('@/pages/PageBoard.vue'),     meta: { menuId: 'board'     } },
      { path: 'calendar',  name: 'calendar',  component: () => import('@/pages/PageCalendar.vue'),  meta: { menuId: 'calendar'  } },
      { path: 'org',       name: 'org',       component: () => import('@/pages/PageOrg.vue'),       meta: { menuId: 'org'       } },
      { path: 'messenger', name: 'messenger', component: () => import('@/pages/PageMessenger.vue'), meta: { menuId: 'messenger' } },
      { path: 'mail',      name: 'mail',      component: () => import('@/pages/PageMail.vue'),      meta: { menuId: 'mail'      } },
      { path: 'wiki',      name: 'wiki',      component: () => import('@/pages/PageWiki.vue'),      meta: { menuId: 'wiki'      } },
      { path: 'video',     name: 'video',     component: () => import('@/pages/PageVideo.vue'),     meta: { menuId: 'video'     } },

      // Phase 14 신규 라우트
      { path: 'attendance', name: 'attendance', component: () => import('@/pages/PageAttendance.vue'), meta: { menuId: 'attendance' } },
      { path: 'leave',      name: 'leave',      component: () => import('@/pages/PageLeave.vue'),      meta: { menuId: 'leave'      } },
      { path: 'room',       name: 'room',       component: () => import('@/pages/PageRoom.vue'),       meta: { menuId: 'room'       } },
      { path: 'datalib',    name: 'datalib',    component: () => import('@/pages/PageDataLibrary.vue'),meta: { menuId: 'datalib'    } },
      { path: 'worklog',    name: 'worklog',    component: () => import('@/pages/PageWorkLog.vue'),    meta: { menuId: 'worklog'    } },
      { path: 'search',     name: 'search',     component: () => import('@/pages/PageSearch.vue'),     meta: { menuId: 'search'     } },
      { path: 'settings/notify',    name: 'settings-notify',    component: () => import('@/pages/PageNotifySettings.vue'), meta: { menuId: 'settings_notify' } },
      { path: 'settings/favorites', name: 'settings-favorites', component: () => import('@/pages/PageFavorites.vue'),      meta: { menuId: 'settings_fav'    } },
      { path: 'admin/users', name: 'admin-users', component: () => import('@/pages/admin/PageUsers.vue'), meta: { menuId: 'admin_users', requiresAdmin: true } },
      { path: 'admin/depts', name: 'admin-depts', component: () => import('@/pages/admin/PageDepts.vue'), meta: { menuId: 'admin_depts', requiresAdmin: true } },
      { path: 'admin/menus', name: 'admin-menus', component: () => import('@/pages/admin/PageMenus.vue'), meta: { menuId: 'admin_menus', requiresAdmin: true } },
      { path: 'admin/codes', name: 'admin-codes', component: () => import('@/pages/admin/PageCodes.vue'), meta: { menuId: 'admin_codes', requiresAdmin: true } },
      { path: 'admin/audit', name: 'admin-audit', component: () => import('@/pages/admin/PageAudit.vue'), meta: { menuId: 'admin_audit', requiresAdmin: true } }
    ]
  },
  { path: '/:pathMatch(.*)*', redirect: '/dashboard' }
];

const router = createRouter({
  history: createWebHistory(),
  routes
});

router.beforeEach(async (to) => {
  const auth = useAuthStore();
  if (to.meta.requiresAuth === false) {
    if (auth.isAuthenticated && to.path === '/login') return '/dashboard';
    return true;
  }
  if (!auth.isAuthenticated) {
    return { path: '/login', query: { redirect: to.fullPath } };
  }
  if (!auth.user) {
    await auth.loadUserInfo();
  }
  // ROLE_ADMIN 한정 메뉴 (Phase 14 admin/*)
  if (to.meta.requiresAdmin === true) {
    const roles = auth.user?.roles || [];
    if (!roles.includes('ROLE_ADMIN')) {
      return '/403';
    }
  }
  // 권한 가드: 메뉴 권한이 있는 경우 canRead 체크
  const menuId = to.meta.menuId as string | undefined;
  if (menuId && auth.menus.length > 0) {
    const menu = auth.menus.find(m => m.menuId === menuId || m.menuPath === to.path);
    if (menu && menu.canRead === false) {
      return '/403';
    }
  }
  return true;
});

export default router;
