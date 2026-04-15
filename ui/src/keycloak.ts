/**
 * Keycloak 어댑터 초기화 — PKCE + silent-SSO.
 *
 * 설정 소스: import.meta.env
 *   VITE_KEYCLOAK_URL    (기본 http://localhost:19281)
 *   VITE_KEYCLOAK_REALM  (기본 openplatform-v3)
 *   VITE_KEYCLOAK_CLIENT (기본 v3-ui)
 */
import Keycloak, { type KeycloakInstance } from 'keycloak-js';

let _kc: KeycloakInstance | null = null;

export async function initKeycloak(): Promise<KeycloakInstance> {
  if (_kc) return _kc;
  const kc = new Keycloak({
    url: import.meta.env.VITE_KEYCLOAK_URL || 'http://kc.localtest.me:19281',
    realm: import.meta.env.VITE_KEYCLOAK_REALM || 'openplatform-v3',
    clientId: import.meta.env.VITE_KEYCLOAK_CLIENT || 'v3-ui'
  });
  await kc.init({
    onLoad: 'check-sso',
    silentCheckSsoRedirectUri: window.location.origin + '/silent-check-sso.html',
    pkceMethod: 'S256',
    checkLoginIframe: false
  });
  _kc = kc;
  // 5분마다 토큰 자동 갱신
  setInterval(() => {
    kc.updateToken(60).catch(() => console.warn('token refresh failed'));
  }, 5 * 60 * 1000);
  return kc;
}

export function getKeycloak(): KeycloakInstance | null {
  return _kc;
}
