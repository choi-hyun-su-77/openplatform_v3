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
        Mattermost 로그인 페이지에서 "GitLab 로 로그인" 버튼을 클릭하면 즉시 통과합니다.</p>
        <Button label="메신저 열기" icon="pi pi-external-link" @click="open" severity="primary" size="large" />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import Button from 'primevue/button';
// Mattermost TE 7.10 의 GitLab OAuth 경로 (Keycloak 을 GitLab provider 로 재사용)
const base = import.meta.env.VITE_MATTERMOST_URL || 'http://localhost:19065';
const ssoUrl = `${base}/oauth/gitlab/login`;
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
