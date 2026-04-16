<template>
  <Dialog v-model:visible="visible" :header="emp?.employeeName || '직원 정보'" modal
          :style="{ width: '440px' }" :closable="true" :draggable="false">
    <template v-if="emp">
      <div class="profile-section">
        <div class="avatar-lg">{{ emp.employeeName?.[0] || '?' }}</div>
        <div class="profile-info">
          <div class="emp-name">{{ emp.employeeName }}</div>
          <div class="emp-position">{{ emp.positionName }}</div>
          <div class="emp-dept">{{ emp.deptName }}</div>
        </div>
      </div>
      <Divider />
      <div class="detail-grid">
        <div class="detail-row">
          <span class="detail-label">사번</span>
          <span>{{ emp.employeeNo }}</span>
        </div>
        <div class="detail-row">
          <span class="detail-label">이메일</span>
          <span>{{ emp.email || '-' }}</span>
        </div>
        <div class="detail-row">
          <span class="detail-label">전화</span>
          <span>{{ emp.phone || '-' }}</span>
        </div>
        <div class="detail-row">
          <span class="detail-label">입사일</span>
          <span>{{ emp.hireDate ? formatDate(emp.hireDate) : '-' }}</span>
        </div>
        <div class="detail-row">
          <span class="detail-label">상태</span>
          <Tag :value="emp.status === 'ACTIVE' ? '재직' : emp.status" :severity="emp.status === 'ACTIVE' ? 'success' : 'secondary'" />
        </div>
      </div>
      <Divider />
      <div class="quick-actions">
        <Button icon="pi pi-send" label="메신저 DM" severity="info" size="small" @click="openMessenger" />
        <Button icon="pi pi-envelope" label="메일 보내기" severity="secondary" size="small" @click="openMail" />
        <Button icon="pi pi-video" label="화상회의" severity="success" size="small" @click="openVideo" />
      </div>
    </template>
  </Dialog>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import { useRouter } from 'vue-router';
import Dialog from 'primevue/dialog';
import Divider from 'primevue/divider';
import Button from 'primevue/button';
import Tag from 'primevue/tag';

const props = defineProps<{ employee: any }>();
const visible = defineModel<boolean>('visible', { default: false });
const router = useRouter();

const emp = computed(() => props.employee);

function formatDate(dt: string) {
  if (!dt) return '';
  return new Date(dt).toLocaleDateString('ko-KR', { year: 'numeric', month: '2-digit', day: '2-digit' });
}

function openMessenger() {
  const username = emp.value?.keycloakUserId || emp.value?.employeeNo || '';
  window.open(`http://localhost:19065/direct/${username}`, '_blank');
}

function openMail() {
  const email = emp.value?.email;
  if (email) window.location.href = `mailto:${email}`;
}

function openVideo() {
  const empNo = emp.value?.employeeNo || '';
  const roomId = `adhoc-${Date.now()}`;
  router.push({ path: '/video', query: { invite: empNo, room: roomId } });
  visible.value = false;
}
</script>

<style scoped>
.profile-section { display: flex; align-items: center; gap: 1rem; }
.avatar-lg {
  width: 64px; height: 64px; border-radius: 50%; background: #3b82f6;
  color: #fff; display: flex; align-items: center; justify-content: center;
  font-weight: 700; font-size: 1.75rem; flex-shrink: 0;
}
.emp-name { font-size: 1.25rem; font-weight: 700; }
.emp-position { color: var(--p-text-muted-color); font-size: 0.9rem; }
.emp-dept { color: var(--p-text-muted-color); font-size: 0.85rem; }
.detail-grid { display: flex; flex-direction: column; gap: 0.5rem; }
.detail-row { display: flex; gap: 1rem; font-size: 0.9rem; }
.detail-label { width: 60px; color: var(--p-text-muted-color); font-weight: 500; flex-shrink: 0; }
.quick-actions { display: flex; gap: 0.5rem; justify-content: center; }
</style>
