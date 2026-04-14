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
      { path: 'video',     name: 'video',     component: () => import('@/pages/PageVideo.vue'),     meta: { menuId: 'video'     } }
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
  return true;
});

export default router;
