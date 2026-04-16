<template>
  <div class="file-upload-panel">
    <div v-if="editable" class="upload-area">
      <input ref="fileInput" type="file" :multiple="multiple" :accept="accept" @change="onFileSelect" class="hidden" />
      <Button :label="uploadLabel" icon="pi pi-upload" size="small" severity="secondary"
              @click="fileInput?.click()" :loading="storage.uploading.value" />
    </div>
    <div v-if="files.length" class="file-list">
      <div v-for="(f, idx) in files" :key="f.objectKey || idx" class="file-item">
        <i class="pi pi-paperclip" />
        <span class="file-name" @click="handleDownload(f)">{{ f.filename }}</span>
        <small class="file-size">({{ formatSize(f.sizeBytes) }})</small>
        <Button v-if="editable" icon="pi pi-times" text size="small" severity="danger"
                @click="$emit('remove', f, idx)" />
      </div>
    </div>
    <div v-else-if="!editable" class="no-files">첨부 파일 없음</div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import Button from 'primevue/button';
import { useStorage } from '@/composables/useStorage';
import { useMessage } from '@/composables/useMessage';

export interface FileItem {
  objectKey: string;
  filename: string;
  sizeBytes: number;
  mimeType?: string;
  attachId?: number;
}

const props = withDefaults(defineProps<{
  files: FileItem[];
  prefix: string;
  editable?: boolean;
  multiple?: boolean;
  accept?: string;
  uploadLabel?: string;
}>(), {
  editable: true,
  multiple: true,
  accept: '*',
  uploadLabel: '파일 첨부'
});

const emit = defineEmits<{
  uploaded: [meta: FileItem];
  remove: [file: FileItem, index: number];
}>();

const storage = useStorage();
const { error } = useMessage();
const fileInput = ref<HTMLInputElement | null>(null);

async function onFileSelect(event: Event) {
  const input = event.target as HTMLInputElement;
  if (!input.files?.length) return;
  for (const file of Array.from(input.files)) {
    try {
      const meta = await storage.uploadFile(file, props.prefix);
      emit('uploaded', meta as FileItem);
    } catch (e) {
      error(`${file.name} 업로드 실패`);
    }
  }
  input.value = '';
}

async function handleDownload(f: FileItem) {
  try {
    await storage.downloadFile(f.objectKey);
  } catch (e) {
    error('다운로드 실패');
  }
}

function formatSize(bytes: number) {
  if (!bytes) return '0 B';
  if (bytes < 1024) return bytes + ' B';
  if (bytes < 1048576) return (bytes / 1024).toFixed(1) + ' KB';
  return (bytes / 1048576).toFixed(1) + ' MB';
}
</script>

<style scoped>
.file-upload-panel { display: flex; flex-direction: column; gap: 0.5rem; }
.hidden { display: none; }
.file-list { display: flex; flex-direction: column; gap: 0.25rem; }
.file-item { display: flex; align-items: center; gap: 0.5rem; font-size: 0.9rem; }
.file-name { cursor: pointer; color: var(--p-primary-color); }
.file-name:hover { text-decoration: underline; }
.file-size { color: var(--p-text-muted-color); }
.no-files { color: var(--p-text-muted-color); font-size: 0.85rem; }
</style>
