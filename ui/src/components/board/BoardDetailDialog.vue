<template>
  <Dialog v-model:visible="visible" :header="post?.title || '게시글 상세'" modal :style="{ width: '720px' }"
          :closable="true" :draggable="false">
    <template v-if="loading">
      <div class="loading-center"><i class="pi pi-spin pi-spinner" style="font-size:2rem" /></div>
    </template>
    <template v-else-if="post">
      <div class="post-meta">
        <span><strong>{{ post.createdBy }}</strong></span>
        <span>{{ boardTypeLabel(post.boardType) }}</span>
        <span>조회 {{ post.viewCount }}</span>
        <span>{{ formatDate(post.createdAt) }}</span>
      </div>
      <Divider />
      <div class="post-content" v-html="renderedContent"></div>
      <!-- 첨부 -->
      <div v-if="attachments.length" class="attach-section">
        <h5>첨부 파일 ({{ attachments.length }})</h5>
        <div v-for="a in attachments" :key="a.attachId" class="attach-item">
          <i class="pi pi-paperclip" />
          <span>{{ a.filename }}</span>
          <small>({{ formatSize(a.sizeBytes) }})</small>
        </div>
      </div>
      <Divider />
      <!-- 댓글 -->
      <CommentThread :postId="postId" :comments="comments" @refresh="loadDetail" />
    </template>
    <template #footer>
      <div class="dialog-footer">
        <Button v-if="isAuthor" label="수정" icon="pi pi-pencil" severity="info" @click="$emit('edit', post)" />
        <Button v-if="isAuthor" label="삭제" icon="pi pi-trash" severity="danger" @click="handleDelete" />
        <Button label="닫기" severity="secondary" @click="visible = false" />
      </div>
    </template>
  </Dialog>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue';
import axios from 'axios';
import Dialog from 'primevue/dialog';
import Divider from 'primevue/divider';
import Button from 'primevue/button';
import CommentThread from './CommentThread.vue';
import { useAuthStore } from '@/store/auth';
import { useMessage } from '@/composables/useMessage';

const props = defineProps<{ postId: number }>();
const emit = defineEmits<{ close: []; edit: [post: any]; deleted: [] }>();
const visible = defineModel<boolean>('visible', { default: false });
const auth = useAuthStore();
const { success, error, confirmDialog } = useMessage();

const loading = ref(false);
const post = ref<any>(null);
const comments = ref<any[]>([]);
const attachments = ref<any[]>([]);

const currentUserNo = computed(() => auth.user?.employeeNo || auth.user?.userId || '');
const isAuthor = computed(() => post.value && String(post.value.createdBy) === currentUserNo.value);

const renderedContent = computed(() => {
  if (!post.value?.content) return '<p class="empty">내용 없음</p>';
  // 간단 마크다운 → HTML (줄바꿈 처리)
  return post.value.content
    .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
    .replace(/\n/g, '<br>');
});

const boardTypeLabels: Record<string, string> = {
  NOTICE: '공지사항', GENERAL: '일반', FREE: '자유', DEPT: '부서', ARCHIVE: '자료실'
};
function boardTypeLabel(code: string) { return boardTypeLabels[code] || code; }

function formatDate(dt: string) {
  if (!dt) return '';
  return new Date(dt).toLocaleDateString('ko-KR', { year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit' });
}

function formatSize(bytes: number) {
  if (!bytes) return '0 B';
  if (bytes < 1024) return bytes + ' B';
  if (bytes < 1048576) return (bytes / 1024).toFixed(1) + ' KB';
  return (bytes / 1048576).toFixed(1) + ' MB';
}

async function loadDetail() {
  if (!props.postId) return;
  loading.value = true;
  try {
    const res = await axios.post('/api/dataset/search', {
      serviceName: 'board/searchDetail',
      datasets: { ds_search: { postId: props.postId } }
    });
    const data = res.data?.data || {};
    post.value = (data.ds_post?.rows || [])[0] || null;
    comments.value = data.ds_comments?.rows || [];
    attachments.value = data.ds_attachments?.rows || [];
  } catch (e) {
    error('게시글 로드에 실패했습니다');
  } finally {
    loading.value = false;
  }
}

async function handleDelete() {
  confirmDialog({ message: '이 게시글을 삭제하시겠습니까?', accept: async () => {
    try {
      await axios.post('/api/dataset/save', {
        serviceName: 'board/deletePost',
        datasets: { ds_search: { postId: props.postId } }
      });
      success('게시글이 삭제되었습니다');
      visible.value = false;
      emit('deleted');
    } catch (e) {
      error('삭제에 실패했습니다');
    }
  } });
}

watch(() => [visible.value, props.postId], ([v]) => {
  if (v && props.postId) loadDetail();
});
</script>

<style scoped>
.loading-center { text-align: center; padding: 2rem; }
.post-meta { display: flex; gap: 1rem; font-size: 0.85rem; color: var(--p-text-muted-color); align-items: center; }
.post-content { min-height: 120px; line-height: 1.7; font-size: 0.95rem; }
.attach-section { margin-top: 0.75rem; }
.attach-section h5 { margin: 0 0 0.5rem; }
.attach-item { display: flex; align-items: center; gap: 0.5rem; padding: 0.25rem 0; font-size: 0.9rem; }
.dialog-footer { display: flex; gap: 0.5rem; justify-content: flex-end; }
</style>
