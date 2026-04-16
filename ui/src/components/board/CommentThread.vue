<template>
  <div class="comment-thread">
    <h4>댓글 ({{ comments.length }})</h4>
    <!-- 새 댓글 작성 -->
    <div class="comment-form">
      <InputText v-model="newComment" placeholder="댓글을 입력하세요" class="flex-1" @keyup.enter="submitComment()" />
      <Button label="등록" size="small" @click="submitComment()" :disabled="!newComment.trim()" />
    </div>
    <!-- 댓글 목록 -->
    <div v-for="c in rootComments" :key="c.commentId" class="comment-item">
      <div class="comment-header">
        <span class="author">{{ c.authorName }}</span>
        <span class="time">{{ formatTime(c.createdAt) }}</span>
        <Button v-if="c.authorNo === currentUserNo" icon="pi pi-trash" text size="small" severity="danger"
                @click="deleteComment(c.commentId)" />
        <Button icon="pi pi-reply" text size="small" @click="toggleReply(c.commentId)" />
      </div>
      <div class="comment-body">{{ c.content }}</div>
      <!-- 대댓글 -->
      <div v-for="r in repliesOf(c.commentId)" :key="r.commentId" class="reply-item">
        <div class="comment-header">
          <span class="author">↳ {{ r.authorName }}</span>
          <span class="time">{{ formatTime(r.createdAt) }}</span>
          <Button v-if="r.authorNo === currentUserNo" icon="pi pi-trash" text size="small" severity="danger"
                  @click="deleteComment(r.commentId)" />
        </div>
        <div class="comment-body">{{ r.content }}</div>
      </div>
      <!-- 대댓글 입력 -->
      <div v-if="replyTarget === c.commentId" class="reply-form">
        <InputText v-model="replyText" placeholder="답글 입력" class="flex-1" @keyup.enter="submitComment(c.commentId)" />
        <Button label="답글" size="small" @click="submitComment(c.commentId)" :disabled="!replyText.trim()" />
        <Button icon="pi pi-times" text size="small" @click="replyTarget = null" />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import axios from 'axios';
import Button from 'primevue/button';
import InputText from 'primevue/inputtext';
import { useAuthStore } from '@/store/auth';
import { useMessage } from '@/composables/useMessage';

const props = defineProps<{ postId: number; comments: any[] }>();
const emit = defineEmits<{ refresh: [] }>();
const auth = useAuthStore();
const { success, error } = useMessage();

const currentUserNo = computed(() => auth.user?.employeeNo || auth.user?.userId || '');
const newComment = ref('');
const replyTarget = ref<number | null>(null);
const replyText = ref('');

const rootComments = computed(() => props.comments.filter(c => !c.parentId));

function repliesOf(parentId: number) {
  return props.comments.filter(c => c.parentId === parentId);
}

function toggleReply(commentId: number) {
  replyTarget.value = replyTarget.value === commentId ? null : commentId;
  replyText.value = '';
}

async function submitComment(parentId?: number) {
  const content = parentId ? replyText.value.trim() : newComment.value.trim();
  if (!content) return;
  try {
    await axios.post('/api/dataset/save', {
      serviceName: 'board/saveComment',
      datasets: { ds_search: { postId: props.postId, parentId: parentId || null, content } }
    });
    success('댓글이 등록되었습니다');
    newComment.value = '';
    replyText.value = '';
    replyTarget.value = null;
    emit('refresh');
  } catch (e) {
    error('댓글 등록에 실패했습니다');
  }
}

async function deleteComment(commentId: number) {
  try {
    await axios.post('/api/dataset/save', {
      serviceName: 'board/deleteComment',
      datasets: { ds_search: { commentId } }
    });
    success('댓글이 삭제되었습니다');
    emit('refresh');
  } catch (e) {
    error('댓글 삭제에 실패했습니다');
  }
}

function formatTime(dt: string): string {
  if (!dt) return '';
  const d = new Date(dt);
  const now = new Date();
  const diff = now.getTime() - d.getTime();
  if (diff < 3600000) return `${Math.max(1, Math.floor(diff / 60000))}분 전`;
  if (diff < 86400000) return `${Math.floor(diff / 3600000)}시간 전`;
  return d.toLocaleDateString('ko-KR', { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' });
}
</script>

<style scoped>
.comment-thread { margin-top: 1rem; }
.comment-thread h4 { margin: 0 0 0.75rem; }
.comment-form, .reply-form { display: flex; gap: 0.5rem; margin-bottom: 0.75rem; }
.flex-1 { flex: 1; }
.comment-item { padding: 0.5rem 0; border-bottom: 1px solid var(--p-content-border-color); }
.comment-header { display: flex; align-items: center; gap: 0.5rem; font-size: 0.85rem; }
.author { font-weight: 600; }
.time { color: var(--p-text-muted-color); font-size: 0.8rem; }
.comment-body { margin: 0.25rem 0 0.25rem; font-size: 0.9rem; white-space: pre-wrap; }
.reply-item { margin-left: 1.5rem; padding: 0.25rem 0; }
.reply-form { margin-left: 1.5rem; margin-top: 0.5rem; }
</style>
