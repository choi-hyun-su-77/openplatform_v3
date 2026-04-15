<template>
  <div class="page">
    <h2>메신저 (Rocket.Chat)</h2>
    <div class="sso-panel">
      <div class="icon">
        <i class="pi pi-send" />
      </div>
      <div class="info">
        <h3>Keycloak SSO 로 메신저 열기</h3>
        <p>브라우저에 현재 로그인된 Keycloak 세션이 재사용됩니다.<br/>
        Rocket.Chat 의 "Keycloak SSO" Custom OAuth 플로우로 자동 진입합니다.</p>
        <Button label="메신저 열기" icon="pi pi-external-link" @click="open" severity="primary" size="large" />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import Button from 'primevue/button';
// Rocket.Chat Custom OAuth 'keycloak' 콜백 경로: /_oauth/keycloak
// Keycloak authorize 엔드포인트로 직접 진입하여 redirect_uri 로 Rocket.Chat 로그인 완성.
const rcBase = (import.meta as any).env.VITE_ROCKETCHAT_URL || 'http://localhost:19065';
const kcBase = (import.meta as any).env.VITE_KEYCLOAK_URL || 'http://kc.localtest.me:19281';
const realm = 'openplatform-v3';
const clientId = 'rocketchat';
const redirectUri = encodeURIComponent(`${rcBase}/_oauth/keycloak`);
const state = encodeURIComponent(btoa(JSON.stringify({ loginStyle: 'redirect', redirectUrl: `${rcBase}/home`, credentialToken: '' })));
const ssoUrl = `${kcBase}/realms/${realm}/protocol/openid-connect/auth?response_type=code&client_id=${clientId}&redirect_uri=${redirectUri}&scope=openid%20profile%20email&state=${state}`;
function open() { window.open(ssoUrl, '_blank'); }
</script>

<style scoped>
.page { padding: 2rem; }
.sso-panel {
  max-width: 680px; margin: 2rem auto; padding: 2.5rem;
  background: linear-gradient(135deg, #eff6ff, #dbeafe);
  border-radius: 1rem;
  display: flex; gap: 2rem; align-items: center;
  box-shadow: 0 4px 12px rgba(59, 130, 246, 0.1);
}
.icon { font-size: 4rem; color: #3b82f6; }
.info h3 { margin: 0 0 0.75rem 0; color: #1e40af; }
.info p { color: #475569; margin-bottom: 1.25rem; line-height: 1.6; }
</style>
