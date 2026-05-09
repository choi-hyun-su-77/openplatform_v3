<template>
  <Dialog v-model:visible="visible" :header="isEdit ? t('LBL_BOARD_FORM_EDIT') : t('LBL_BOARD_FORM_NEW')" modal
          :style="{ width: '640px' }" :closable="true" :draggable="false">
    <div class="form-grid">
      <div class="field">
        <label>{{ t('LBL_BOARD_BOARD') }}</label>
        <Select v-model="form.boardType" :options="boardTypes" optionLabel="label" optionValue="code"
                :placeholder="t('PH_BOARD_SELECT')" :disabled="isEdit" />
      </div>
      <div class="field">
        <label>{{ t('LBL_BOARD_TITLE_REQ') }}</label>
        <InputText v-model="form.title" :placeholder="t('PH_POST_TITLE')" class="w-full" />
      </div>
      <div class="field">
        <label>{{ t('LBL_BOARD_CONTENT') }}</label>
        <Textarea v-model="form.content" :rows="10" class="w-full" :placeholder="t('PH_POST_CONTENT')" />
      </div>
      <div class="field">
        <label><input type="checkbox" v-model="form.isPinned" true-value="Y" false-value="N" /> {{ t('LBL_BOARD_PIN') }}</label>
      </div>
      <div class="field" v-if="isEdit && form.postId">
        <label>{{ t('LBL_BOARD_ATTACHMENT') }}</label>
        <FileUploadPanel :files="attachments" :prefix="`board/${form.postId}/`"
                         @uploaded="onFileUploaded" @remove="onFileRemove" />
      </div>
    </div>
    <template #footer>
      <Button :label="t('BTN_CANCEL')" severity="secondary" @click="visible = false" />
      <Button :label="isEdit ? t('BTN_UPDATE') : t('BTN_REGISTER')" icon="pi pi-check" @click="handleSave" :loading="saving" />
    </template>
  </Dialog>
</template>

<script setup lang="ts">
import { ref, watch, computed } from 'vue';
import axios from 'axios';
import Dialog from 'primevue/dialog';
import Button from 'primevue/button';
import InputText from 'primevue/inputtext';
import Textarea from 'primevue/textarea';
import Select from 'primevue/select';
import { useMessage } from '@/composables/useMessage';
import { useLabel } from '@/composables/useLabel';
import FileUploadPanel, { type FileItem } from '@/components/common/FileUploadPanel.vue';

const props = defineProps<{ editData?: any }>();
const emit = defineEmits<{ saved: [] }>();
const visible = defineModel<boolean>('visible', { default: false });
const { success, error } = useMessage();
const { t } = useLabel();

const boardTypes = computed(() => [
  { code: 'NOTICE', label: t('LBL_BOARD_TYPE_NOTICE') },
  { code: 'GENERAL', label: t('LBL_BOARD_TYPE_GENERAL') },
  { code: 'FREE', label: t('LBL_BOARD_TYPE_FREE') },
  { code: 'DEPT', label: t('LBL_BOARD_TYPE_DEPT') },
  { code: 'ARCHIVE', label: t('LBL_BOARD_TYPE_ARCHIVE') }
]);

const isEdit = computed(() => !!props.editData?.postId);
const saving = ref(false);
const attachments = ref<FileItem[]>([]);

async function onFileUploaded(meta: FileItem) {
  attachments.value.push(meta);
  if (form.value.postId) {
    try {
      await axios.post('/api/dataset/save', {
        serviceName: 'board/uploadAttachment',
        datasets: { ds_search: { postId: form.value.postId, ...meta } }
      });
    } catch { /* ignore - meta saved locally */ }
  }
}
function onFileRemove(_file: FileItem, idx: number) {
  attachments.value.splice(idx, 1);
}
const form = ref({
  postId: null as number | null,
  boardType: 'GENERAL',
  title: '',
  content: '',
  isPinned: 'N'
});

watch(() => [visible.value, props.editData], ([v]) => {
  if (v && props.editData?.postId) {
    form.value = {
      postId: props.editData.postId,
      boardType: props.editData.boardType || 'GENERAL',
      title: props.editData.title || '',
      content: props.editData.content || '',
      isPinned: props.editData.isPinned || 'N'
    };
  } else if (v) {
    form.value = { postId: null, boardType: 'GENERAL', title: '', content: '', isPinned: 'N' };
  }
});

async function handleSave() {
  if (!form.value.title.trim()) { error(t('MSG_BOARD_TITLE_REQ')); return; }
  saving.value = true;
  try {
    const rowType = isEdit.value ? 'U' : 'C';
    await axios.post('/api/dataset/save', {
      serviceName: 'board/savePosts',
      datasets: {
        ds_posts: {
          rows: [{ ...form.value, _rowType: rowType }]
        }
      }
    });
    success(isEdit.value ? t('MSG_BOARD_UPDATE_DONE') : t('MSG_BOARD_SAVE_DONE'));
    visible.value = false;
    emit('saved');
  } catch (e) {
    error(t('MSG_BOARD_SAVE_FAILED'));
  } finally {
    saving.value = false;
  }
}
</script>

<style scoped>
.form-grid { display: flex; flex-direction: column; gap: 0.75rem; }
.field { display: flex; flex-direction: column; gap: 0.25rem; }
.field label { font-weight: 500; font-size: 0.9rem; }
.required { color: red; }
.w-full { width: 100%; }
</style>
