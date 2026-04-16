<template>
  <Dialog v-model:visible="visible" :header="isEdit ? '게시글 수정' : '새 글 작성'" modal
          :style="{ width: '640px' }" :closable="true" :draggable="false">
    <div class="form-grid">
      <div class="field">
        <label>게시판</label>
        <Select v-model="form.boardType" :options="boardTypes" optionLabel="label" optionValue="code"
                placeholder="게시판 선택" :disabled="isEdit" />
      </div>
      <div class="field">
        <label>제목 <span class="required">*</span></label>
        <InputText v-model="form.title" placeholder="제목을 입력하세요" class="w-full" />
      </div>
      <div class="field">
        <label>내용</label>
        <Textarea v-model="form.content" :rows="10" class="w-full" placeholder="내용을 입력하세요" />
      </div>
      <div class="field">
        <label><input type="checkbox" v-model="form.isPinned" true-value="Y" false-value="N" /> 상단 고정</label>
      </div>
    </div>
    <template #footer>
      <Button label="취소" severity="secondary" @click="visible = false" />
      <Button :label="isEdit ? '수정' : '등록'" icon="pi pi-check" @click="handleSave" :loading="saving" />
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

const props = defineProps<{ editData?: any }>();
const emit = defineEmits<{ saved: [] }>();
const visible = defineModel<boolean>('visible', { default: false });
const { success, error } = useMessage();

const boardTypes = [
  { code: 'NOTICE', label: '공지사항' },
  { code: 'GENERAL', label: '일반' },
  { code: 'FREE', label: '자유게시판' },
  { code: 'DEPT', label: '부서게시판' },
  { code: 'ARCHIVE', label: '자료실' }
];

const isEdit = computed(() => !!props.editData?.postId);
const saving = ref(false);
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
  if (!form.value.title.trim()) { error('제목을 입력하세요'); return; }
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
    success(isEdit.value ? '게시글이 수정되었습니다' : '게시글이 등록되었습니다');
    visible.value = false;
    emit('saved');
  } catch (e) {
    error('저장에 실패했습니다');
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
