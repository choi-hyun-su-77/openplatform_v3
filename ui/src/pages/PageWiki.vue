<template>
  <div class="page">
    <h2>위키 (Wiki.js)</h2>
    <div class="sso-panel">
      <div class="icon">
        <i class="pi pi-book" />
      </div>
      <div class="info">
        <h3>Keycloak SSO 로 위키 열기</h3>
        <p>브라우저에 현재 로그인된 Keycloak 세션이 재사용됩니다.<br/>
        Wiki.js 로그인 페이지에서 "Keycloak SSO" 버튼을 클릭하면 즉시 통과합니다.</p>
        <Button label="위키 열기" icon="pi pi-external-link" @click="open" severity="primary" size="large" />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import Button from 'primevue/button';
const base = import.meta.env.VITE_WIKI_URL || 'http://localhost:19001';
const ssoUrl = `${base}/login`;
function open() { window.open(ssoUrl, '_blank'); }
</script>

<style scoped>
.page { padding: 2rem; }
.sso-panel {
  max-width: 680px; margin: 2rem auto; padding: 2.5rem;
  background: linear-gradient(135deg, #f0fdf4, #dcfce7);
  border-radius: 1rem;
  display: flex; gap: 2rem; align-items: center;
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.1);
}
.icon { font-size: 4rem; color: #10b981; }
.info h3 { margin: 0 0 0.75rem 0; color: #047857; }
.info p { color: #475569; margin-bottom: 1.25rem; line-height: 1.6; }
</style>
