import { ref, onMounted, onUnmounted, watch } from 'vue';
import { useAuthStore } from '@/store/auth';
import { useNotificationStore } from '@/store/notification';
import { useMessage } from '@/composables/useMessage';

/**
 * SSE 알림 구독 composable.
 * EventSource 는 커스텀 헤더를 지원하지 않으므로 ?token= 쿼리로 JWT 전달.
 * Keycloak 토큰 갱신 시 EventSource 를 재연결한다.
 */
export function useNotificationSse() {
  const authStore = useAuthStore();
  const notifStore = useNotificationStore();
  const { info } = useMessage();
  const connected = ref(false);
  let eventSource: EventSource | null = null;

  function connect() {
    disconnect();
    const token = authStore.accessToken;
    if (!token) return;

    const url = `/api/notification/subscribe?token=${encodeURIComponent(token)}`;
    eventSource = new EventSource(url);
    connected.value = true;

    eventSource.addEventListener('init', (e: MessageEvent) => {
      try {
        const data = JSON.parse(e.data);
        notifStore.setInitCount(data.unreadCount || 0);
      } catch { /* ignore parse errors */ }
    });

    eventSource.addEventListener('notification', (e: MessageEvent) => {
      try {
        const data = JSON.parse(e.data);
        notifStore.pushEvent(data);
        info(data.title || '새 알림이 도착했습니다');
      } catch { /* ignore */ }
    });

    eventSource.onerror = () => {
      connected.value = false;
      disconnect();
      // 3초 후 재연결 시도
      setTimeout(() => {
        if (authStore.isAuthenticated) connect();
      }, 3000);
    };
  }

  function disconnect() {
    if (eventSource) {
      eventSource.close();
      eventSource = null;
      connected.value = false;
    }
  }

  // 토큰 변경 시 재연결
  watch(() => authStore.accessToken, (newToken, oldToken) => {
    if (newToken && newToken !== oldToken) {
      connect();
    } else if (!newToken) {
      disconnect();
    }
  });

  onMounted(() => {
    if (authStore.isAuthenticated) connect();
  });

  onUnmounted(() => {
    disconnect();
  });

  return { connected, connect, disconnect };
}
