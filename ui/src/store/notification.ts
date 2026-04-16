import { defineStore } from 'pinia';
import { ref } from 'vue';
import axios from 'axios';

export interface NotificationItem {
  notificationId: number;
  recipientId: number;
  docId: number;
  notificationType: string;
  channel: string;
  title: string;
  content: string;
  isRead: string;
  createdAt: string;
}

export const useNotificationStore = defineStore('notification', () => {
  const unreadCount = ref(0);
  const recent = ref<NotificationItem[]>([]);

  function pushEvent(ev: { type: string; docId: number; title: string; unreadCount: number }) {
    unreadCount.value = ev.unreadCount;
    recent.value.unshift({
      notificationId: Date.now(),
      recipientId: 0,
      docId: ev.docId,
      notificationType: ev.type,
      channel: 'WEB',
      title: ev.title,
      content: '',
      isRead: 'N',
      createdAt: new Date().toISOString()
    });
    if (recent.value.length > 20) recent.value.pop();
  }

  function setInitCount(count: number) {
    unreadCount.value = count;
  }

  async function loadRecent(recipientId: number) {
    try {
      const res = await axios.post('/api/dataset/search', {
        serviceName: 'notification/searchList',
        datasets: { ds_search: { recipientId, unreadOnly: false, limit: 10 } }
      });
      recent.value = res.data?.data?.ds_notifications?.rows || [];
      unreadCount.value = res.data?.data?.ds_unreadCount?.count || 0;
    } catch (e) {
      console.warn('notification loadRecent failed', e);
    }
  }

  async function markRead(notificationId: number) {
    try {
      await axios.post('/api/dataset/save', {
        serviceName: 'notification/markRead',
        datasets: { ds_notification: { rows: [{ notificationId }] } }
      });
      const item = recent.value.find(n => n.notificationId === notificationId);
      if (item) item.isRead = 'Y';
      if (unreadCount.value > 0) unreadCount.value--;
    } catch (e) {
      console.warn('markRead failed', e);
    }
  }

  async function markAllRead(recipientId: number) {
    try {
      await axios.post('/api/dataset/save', {
        serviceName: 'notification/markAllRead',
        datasets: { ds_search: { recipientId } }
      });
      recent.value.forEach(n => (n.isRead = 'Y'));
      unreadCount.value = 0;
    } catch (e) {
      console.warn('markAllRead failed', e);
    }
  }

  return { unreadCount, recent, pushEvent, setInitCount, loadRecent, markRead, markAllRead };
});
