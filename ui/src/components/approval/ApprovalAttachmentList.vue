<!--
  결재 첨부 파일 목록 + 업/다운로드.

  Props:
    docId: number              필수
    editable: boolean (default false)  업로드/삭제 활성화 여부

  내부 동작:
    - mount 시 useApproval().listAttachments(docId)
    - editable=true 일 때 file input 노출 → presigned PUT 업로드 → uploadAttachmentMeta 등록
    - 다운로드: presigned GET URL 새 탭 open
-->
<template>
  <div class="attachment-list">
    <div v-if="loading" class="loading">불러오는 중...</div>
    <div v-else-if="!items.length" class="empty">첨부 파일이 없습니다</div>
    <ul v-else>
      <li v-for="a in items" :key="a.attachId">
        <i class="pi pi-file"></i>
        <span class="filename">{{ a.filename }}</span>
        <span class="size">{{ formatSize(a.sizeBytes) }}</span>
        <span class="uploader">{{ a.uploaderNo }}</span>
        <Button icon="pi pi-download" text rounded @click="download(a)" v-tooltip="'다운로드'" />
        <Button v-if="editable" icon="pi pi-trash" text rounded severity="danger" @click="remove(a)" v-tooltip="'삭제'" />
      </li>
    </ul>

    <div v-if="editable" class="upload-area">
      <input ref="fileInput" type="file" @change="onFileChange" style="display:none" />
      <Button label="파일 첨부" icon="pi pi-upload" @click="fileInput?.click()" :loading="uploading" />
      <span v-if="uploading" class="upload-status">{{ uploadingName }} 업로드 중...</span>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, watch } from 'vue';
import Button from 'primevue/button';
import { useApproval } from '@/composables/useApproval';

const props = defineProps<{ docId: number; editable?: boolean }>();
const emit = defineEmits<{ (e: 'changed'): void }>();

const approval = useApproval();
const items = ref<any[]>([]);
const loading = ref(false);
const uploading = ref(false);
const uploadingName = ref('');
const fileInput = ref<HTMLInputElement | null>(null);

async function reload() {
  if (!props.docId) return;
  loading.value = true;
  try {
    items.value = await approval.listAttachments(props.docId);
  } finally {
    loading.value = false;
  }
}

onMounted(reload);
watch(() => props.docId, reload);

async function onFileChange(e: Event) {
  const target = e.target as HTMLInputElement;
  const file = target.files?.[0];
  if (!file) return;
  uploading.value = true;
  uploadingName.value = file.name;
  try {
    const objectKey = `approval/${props.docId}/${Date.now()}-${file.name}`;
    const putUrl = await approval.getPresignedPutUrl(objectKey, 600);
    // PUT to MinIO
    const putRes = await fetch(putUrl, {
      method: 'PUT',
      headers: { 'Content-Type': file.type || 'application/octet-stream' },
      body: file
    });
    if (!putRes.ok) throw new Error('S3 PUT 실패: ' + putRes.status);
    await approval.uploadAttachmentMeta({
      docId: props.docId,
      objectKey,
      filename: file.name,
      sizeBytes: file.size,
      mimeType: file.type
    });
    await reload();
    emit('changed');
  } catch (err: any) {
    alert('업로드 실패: ' + (err?.message || err));
  } finally {
    uploading.value = false;
    uploadingName.value = '';
    if (fileInput.value) fileInput.value.value = '';
  }
}

async function download(att: any) {
  try {
    const url = await approval.getPresignedGetUrl(att.objectKey, 600);
    window.open(url, '_blank');
  } catch (e: any) {
    alert('다운로드 URL 발급 실패: ' + (e?.message || e));
  }
}

async function remove(att: any) {
  if (!confirm(`'${att.filename}' 을 삭제하시겠습니까?`)) return;
  try {
    // 백엔드 approval/deleteAttachment DataSet 서비스 (다음 세션에서 신규 추가 예정)
    // 현재는 임시로 직접 호출 (404 가능)
    const axios = (await import('axios')).default;
    await axios.post('/api/dataset/search', {
      serviceName: 'approval/deleteAttachment',
      datasets: { ds_search: { attachId: att.attachId } }
    });
    await reload();
    emit('changed');
  } catch (e: any) {
    alert('삭제 실패: ' + (e?.response?.data?.message || e.message));
  }
}

function formatSize(bytes: number): string {
  if (!bytes) return '0';
  if (bytes < 1024) return `${bytes} B`;
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
  return `${(bytes / 1024 / 1024).toFixed(1)} MB`;
}
</script>

<style scoped>
.attachment-list {
  padding: 0.5rem 0;
}
.loading, .empty {
  color: #94a3b8;
  font-size: 0.9rem;
  padding: 0.5rem 0;
}
ul {
  list-style: none;
  padding: 0;
  margin: 0;
}
li {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.5rem;
  border-bottom: 1px solid #f1f5f9;
}
li i.pi-file { color: #3b82f6; }
.filename { flex: 1; font-weight: 500; }
.size, .uploader {
  font-size: 0.8rem;
  color: #94a3b8;
}
.upload-area {
  margin-top: 1rem;
  display: flex;
  align-items: center;
  gap: 0.75rem;
}
.upload-status {
  color: #3b82f6;
  font-size: 0.85rem;
}
</style>
