/**
 * 인증 스토어 — Keycloak PKCE 기반 SSO 통합
 *
 * ts-spring-fw의 JWT 자체발급 구조를 Keycloak OIDC로 교체.
 * - accessToken: Keycloak 발급 JWT (interceptor에서 Authorization 헤더에 첨부)
 * - user: Keycloak userinfo + v3 백엔드의 menus 병합
 * - menus: /api/bff/identity/me 또는 v3 core 로부터 로드
 */
import { defineStore } from 'pinia';
import { ref, computed } from 'vue';
import axios from 'axios';
import { initKeycloak, getKeycloak } from '@/keycloak';

interface UserInfo {
  userId: string;
  userName: string;
  userNameEn?: string;
  email: string;
  deptName: string;
  department?: string;
  roles: string[];
  preferredLocale?: string;
}

interface MenuItem {
  menuId: string;
  menuName: string;
  menuPath: string;
  parentMenuId: string | null;
  menuLevel: number;
  sortOrder: number;
  icon: string | null;
  canRead: boolean;
  canCreate: boolean;
  canUpdate: boolean;
  canDelete: boolean;
  canExport: boolean;
  canPrint: boolean;
  children?: MenuItem[];
}

export const useAuthStore = defineStore('auth', () => {
  const accessToken = ref<string | null>(null);
  const user = ref<UserInfo | null>(null);
  const menus = ref<MenuItem[]>([]);

  const isAuthenticated = computed(() => !!accessToken.value);

  const menuTree = computed(() => {
    const items = [...menus.value];
    const map = new Map<string, MenuItem>();
    const roots: MenuItem[] = [];
    items.forEach(item => map.set(item.menuId, { ...item, children: [] }));
    items.forEach(item => {
      const node = map.get(item.menuId)!;
      const pid = item.parentMenuId;
      if (pid && map.has(pid)) {
        map.get(pid)!.children!.push(node);
      } else {
        roots.push(node);
      }
    });
    roots.sort((a, b) => a.sortOrder - b.sortOrder);
    roots.forEach(r => r.children?.sort((a, b) => a.sortOrder - b.sortOrder));
    return roots;
  });

  async function login(): Promise<boolean> {
    const kc = await initKeycloak();
    if (!kc.authenticated) {
      await kc.login({ redirectUri: window.location.origin + '/dashboard' });
      return false;
    }
    accessToken.value = kc.token || null;
    await loadUserInfo();
    return true;
  }

  async function logout() {
    const kc = getKeycloak();
    accessToken.value = null;
    user.value = null;
    menus.value = [];
    if (kc) {
      await kc.logout({ redirectUri: window.location.origin });
    }
  }

  async function refresh(): Promise<boolean> {
    try {
      const kc = getKeycloak();
      if (!kc) return false;
      const refreshed = await kc.updateToken(30);
      if (refreshed || kc.token) {
        accessToken.value = kc.token || null;
        return true;
      }
      return false;
    } catch {
      return false;
    }
  }

  async function loadUserInfo() {
    if (!accessToken.value) return;
    try {
      const me = await axios.get('/api/bff/identity/me');
      const data = (me.data as any) || {};
      user.value = {
        userId: data.preferred_username || data.sub,
        userName: data.name || data.preferred_username || 'User',
        email: data.email || '',
        deptName: data.dept_name || '',
        roles: (data.realm_access && data.realm_access.roles) || [],
        preferredLocale: data.locale || 'ko'
      };
      // 메뉴는 backend-core 의 menu/searchByUser 에서 역할 기반 조회
      try {
        const m = await axios.post('/api/dataset/search', {
          serviceName: 'menu/searchByUser',
          datasets: { ds_search: {} }
        });
        const rows = m.data?.data?.ds_menus?.rows || [];
        if (rows.length > 0) {
          menus.value = rows.map((r: any) => ({
            menuId: r.menuId, menuName: r.menuName, menuPath: r.menuPath,
            parentMenuId: r.parentMenuId, menuLevel: r.menuLevel, sortOrder: r.sortOrder,
            icon: r.icon,
            canRead: r.canRead, canCreate: r.canCreate, canUpdate: r.canUpdate,
            canDelete: r.canDelete, canExport: r.canExport, canPrint: r.canPrint
          }));
        } else {
          menus.value = defaultMenus();
        }
      } catch (menuErr) {
        console.warn('menu load failed', menuErr);
        menus.value = defaultMenus();
      }
    } catch (e) {
      console.warn('loadUserInfo fallback', e);
      user.value = { userId: 'anonymous', userName: 'Guest', email: '', deptName: '', roles: [] };
      menus.value = defaultMenus();
    }
  }

  function defaultMenus(): MenuItem[] {
    const mk = (id: string, name: string, path: string, sort: number, icon: string): MenuItem => ({
      menuId: id, menuName: name, menuPath: path, parentMenuId: null,
      menuLevel: 1, sortOrder: sort, icon,
      canRead: true, canCreate: true, canUpdate: true, canDelete: true, canExport: true, canPrint: true
    });
    return [
      mk('dashboard', '대시보드',  '/dashboard', 1,  'pi pi-th-large'),
      mk('approval',  '전자결재',  '/approval',  2,  'pi pi-file-edit'),
      mk('board',     '게시판',    '/board',     3,  'pi pi-comment'),
      mk('calendar',  '캘린더',    '/calendar',  4,  'pi pi-calendar'),
      mk('org',       '조직도',    '/org',       5,  'pi pi-sitemap'),
      mk('messenger', '메신저',    '/messenger', 6,  'pi pi-send'),
      mk('mail',      '메일',      '/mail',      7,  'pi pi-inbox'),
      mk('wiki',      '위키',      '/wiki',      8,  'pi pi-book'),
      mk('video',     '화상회의',  '/video',     9,  'pi pi-video')
    ];
  }

  return { accessToken, user, menus, isAuthenticated, menuTree, login, logout, refresh, loadUserInfo };
});
