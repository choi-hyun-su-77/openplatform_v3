/**
 * Axios 인터셉터 — Keycloak 토큰 첨부 + 401 시 갱신 + 5xx 재시도
 * ts-spring-fw 의 JWT 자체발급 버전을 참고하여 Keycloak-js 로 교체.
 */
import axios, { type AxiosError, type InternalAxiosRequestConfig } from 'axios';
import type { Router } from 'vue-router';
import { useAuthStore } from '@/store/auth';
import { getKeycloak } from '@/keycloak';

const MAX_RETRIES = 2;
const RETRY_BASE_DELAY = 1000;
const CONSECUTIVE_FAIL_THRESHOLD = 3;
let consecutiveFailCount = 0;
let isRedirecting = false;

function delay(attempt: number): Promise<void> {
  return new Promise(r => setTimeout(r, RETRY_BASE_DELAY * Math.pow(2, attempt)));
}

function isRetryable(e: AxiosError): boolean {
  const url = (e.config?.url || '') as string;
  if (url.includes('/auth/') || url.includes('/bff/identity/me')) return false;
  if (!e.response) return true;
  return e.response.status >= 500;
}

async function redirectToLogin(router: Router) {
  if (isRedirecting) return;
  isRedirecting = true;
  const auth = useAuthStore();
  await auth.logout();
  router.push('/login');
  setTimeout(() => { isRedirecting = false; consecutiveFailCount = 0; }, 3000);
}

export function setupInterceptor(router: Router) {
  axios.interceptors.request.use((config) => {
    const auth = useAuthStore();
    const kc = getKeycloak();
    const token = kc?.token || auth.accessToken;
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    const locale = localStorage.getItem('locale') || 'ko';
    config.headers['X-Locale'] = locale;
    config.headers['Accept-Language'] = locale;
    return config;
  });

  axios.interceptors.response.use(
    (r) => { consecutiveFailCount = 0; return r; },
    async (error: AxiosError) => {
      const req = error.config as InternalAxiosRequestConfig & { _retry?: boolean; _retryCount?: number };

      if (error.response?.status === 401 && !req._retry) {
        req._retry = true;
        const auth = useAuthStore();
        const refreshed = await auth.refresh();
        if (refreshed) {
          req.headers.Authorization = `Bearer ${auth.accessToken}`;
          return axios(req);
        }
        await redirectToLogin(router);
        return Promise.reject(error);
      }

      if (error.response?.status === 403) {
        console.warn('403 forbidden:', req?.url);
        return Promise.reject(error);
      }

      if (isRetryable(error) && req) {
        const n = req._retryCount || 0;
        if (n < MAX_RETRIES) {
          req._retryCount = n + 1;
          await delay(n);
          return axios(req);
        }
        consecutiveFailCount++;
        if (consecutiveFailCount >= CONSECUTIVE_FAIL_THRESHOLD) {
          if (router.currentRoute.value.path !== '/login') {
            await redirectToLogin(router);
          }
        }
      }

      return Promise.reject(error);
    }
  );
}
