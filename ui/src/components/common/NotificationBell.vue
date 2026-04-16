<template>
  <div class="notification-bell" ref="bellRef">
    <Button
      icon="pi pi-bell"
      severity="secondary"
      text
      size="small"
      :badge="badgeText"
      :badgeSeverity="unreadCount > 0 ? 'danger' : 'secondary'"
      @click="togglePanel"
      v-tooltip.bottom="'알림'"
    />
    <OverlayPanel ref="overlayRef" :dismissable="true" class="notif-overlay">
      <div class="notif-header">
        <span class="notif-title">알림</span>
        <Button
          v-if="unreadCount > 0"
          label="모두 읽음"
          text
          size="small"
          @click="handleMarkAllRead"
        />
      </div>
      <div class="notif-list" v-if="notifStore.recent.length > 0">
        <div
          v-for="n in notifStore.recent.slice(0, 10)"
          :key="n.notificationId"
          :class="['notif-item', { unread: n.isRead === 'N' }]"
          @click="handleClick(n)"
        >
          <i :class="iconFor(n.notificationType)" />
          <div class="notif-content">
            <div class="notif-item-title">{{ n.title || '알림' }}</div>
            <div class="notif-time">{{ formatTime(n.createdAt) }}</div>
          </div>
        </div>
      </div>
      <div v-else class="notif-empty">새 알림이 없습니다</div>
    </OverlayPanel>
  </div>
</template>

<script setup lang="ts">
import { computed, ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from '@/store/auth';
import { useNotificationStore, type NotificationItem } from '@/store/notification';
import { useNotificationSse } from '@/composables/useNotificationSse';
import Button from 'primevue/button';
import OverlayPanel from 'primevue/overlaypanel';

const router = useRouter();
const authStore = useAuthStore();
const notifStore = useNotificationStore();
const bellRef = ref<HTMLElement | null>(null);
const overlayRef = ref<InstanceType<typeof OverlayPanel> | null>(null);

// SSE 연결 시작
useNotificationSse();

const unreadCount = computed(() => notifStore.unreadCount);
const badgeText = computed(() => unreadCount.value > 0 ? String(Math.min(unreadCount.value, 99)) : undefined);

function togglePanel(event: Event) {
  overlayRef.value?.toggle(event);
  if (authStore.user?.employeeId && notifStore.recent.length === 0) {
    notifStore.loadRecent(authStore.user.employeeId);
  }
}

function handleClick(n: NotificationItem) {
  if (n.isRead === 'N') {
    notifStore.markRead(n.notificationId);
  }
  overlayRef.value?.hide();
  if (n.notificationType === 'APPROVAL' && n.docId) {
    router.push({ path: '/approval', query: { docId: String(n.docId) } });
  } else if (n.notificationType === 'BOARD') {
    router.push({ path: '/board', query: { postId: String(n.docId) } });
  }
}

async function handleMarkAllRead() {
  if (authStore.user?.employeeId) {
    await notifStore.markAllRead(authStore.user.employeeId);
  }
}

function iconFor(type: string): string {
  switch (type) {
    case 'APPROVAL': return 'pi pi-file-edit';
    case 'BOARD': return 'pi pi-comment';
    case 'CALENDAR': return 'pi pi-calendar';
    default: return 'pi pi-bell';
  }
}

function formatTime(dt: string): string {
  if (!dt) return '';
  const d = new Date(dt);
  const now = new Date();
  const diff = now.getTime() - d.getTime();
  if (diff < 60000) return '방금 전';
  if (diff < 3600000) return `${Math.floor(diff / 60000)}분 전`;
  if (diff < 86400000) return `${Math.floor(diff / 3600000)}시간 전`;
  return d.toLocaleDateString('ko-KR', { month: 'short', day: 'numeric' });
}

onMounted(() => {
  if (authStore.user?.employeeId) {
    notifStore.loadRecent(authStore.user.employeeId);
  }
});
</script>

<style scoped>
.notification-bell { position: relative; display: inline-flex; }

.notif-overlay { width: 360px; max-height: 480px; }
.notif-header {
  display: flex; justify-content: space-between; align-items: center;
  padding: 0.5rem 0.75rem; border-bottom: 1px solid var(--p-content-border-color);
}
.notif-title { font-weight: 600; font-size: 0.95rem; }

.notif-list { max-height: 360px; overflow-y: auto; }
.notif-item {
  display: flex; align-items: flex-start; gap: 0.75rem;
  padding: 0.6rem 0.75rem; cursor: pointer;
  border-bottom: 1px solid var(--p-content-border-color);
  transition: background 0.15s;
}
.notif-item:hover { background: var(--p-content-hover-background); }
.notif-item.unread { background: var(--p-highlight-background); }
.notif-item i { font-size: 1rem; margin-top: 2px; color: var(--p-primary-color); }

.notif-content { flex: 1; min-width: 0; }
.notif-item-title { font-size: 0.85rem; line-height: 1.3; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.notif-time { font-size: 0.75rem; color: var(--p-text-muted-color); margin-top: 2px; }

.notif-empty { padding: 2rem; text-align: center; color: var(--p-text-muted-color); font-size: 0.9rem; }
</style>
