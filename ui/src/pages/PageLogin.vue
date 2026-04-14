<template>
  <div class="login-page">
    <div class="login-card">
      <h1>openplatform v3</h1>
      <p>통합 그룹웨어 — Keycloak SSO</p>
      <Button label="Keycloak으로 로그인" icon="pi pi-sign-in" @click="onLogin" :loading="loading" />
      <p class="hint">admin / admin 또는 user1 / user1</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import Button from 'primevue/button';
import { useAuthStore } from '@/store/auth';

const router = useRouter();
const auth = useAuthStore();
const loading = ref(false);

onMounted(() => {
  if (auth.isAuthenticated) router.replace('/dashboard');
});

async function onLogin() {
  loading.value = true;
  try {
    const ok = await auth.login();
    if (ok) router.replace('/dashboard');
  } finally {
    loading.value = false;
  }
}
</script>

<style scoped>
.login-page {
  height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #3b82f6, #1e40af);
}
.login-card {
  background: white;
  padding: 3rem 4rem;
  border-radius: 1rem;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
  text-align: center;
  max-width: 420px;
}
.login-card h1 { color: #1e40af; margin-bottom: 0.25rem; }
.login-card p { color: #64748b; margin: 0.5rem 0 1.5rem 0; }
.hint { font-size: 0.85rem; color: #94a3b8; margin-top: 1rem; }
</style>
