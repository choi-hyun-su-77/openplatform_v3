<template>
  <div class="page">
    <h2>웹메일 (Stalwart)</h2>
    <div class="sso-panel">
      <div class="icon">
        <i class="pi pi-inbox" />
      </div>
      <div class="info">
        <h3>LDAP Federation 로 메일함 열기</h3>
        <p>Stalwart 는 Keycloak User Federation(OpenLDAP)을 통해 인증합니다.<br/>
        포털 로그인과 동일한 ID/PW 로 접근 가능합니다.</p>
        <p class="cred">ID: <code>user1</code> &nbsp;|&nbsp; PW: <code>user1</code></p>
        <Button label="웹메일 관리자 열기" icon="pi pi-external-link" @click="open" severity="primary" size="large" />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import Button from 'primevue/button';
const stalwartUrl = import.meta.env.VITE_STALWART_URL || 'http://localhost:19480';
function open() { window.open(stalwartUrl, '_blank'); }
</script>

<style scoped>
.page { padding: 2rem; }
.sso-panel {
  max-width: 680px; margin: 2rem auto; padding: 2.5rem;
  background: linear-gradient(135deg, #fef3c7, #fde68a);
  border-radius: 1rem;
  display: flex; gap: 2rem; align-items: center;
  box-shadow: 0 4px 12px rgba(245, 158, 11, 0.1);
}
.icon { font-size: 4rem; color: #d97706; }
.info h3 { margin: 0 0 0.75rem 0; color: #92400e; }
.info p { color: #475569; margin-bottom: 0.75rem; line-height: 1.6; }
.cred code { background: #fff; padding: 0.2rem 0.5rem; border-radius: 0.25rem; font-family: monospace; }
</style>
