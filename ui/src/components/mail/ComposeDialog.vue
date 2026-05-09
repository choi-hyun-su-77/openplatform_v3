<template>
  <Dialog v-model:visible="visible" :header="dialogTitle" modal :style="{ width: '600px' }" :closable="true">
    <div class="compose-form">
      <div class="field">
        <label>{{ t('LBL_MAIL_TO') }}</label>
        <InputText v-model="form.to" placeholder="email@example.com" class="w-full" />
      </div>
      <div class="field">
        <label>{{ t('LBL_MAIL_CC') }}</label>
        <InputText v-model="form.cc" :placeholder="t('LBL_MAIL_OPTIONAL')" class="w-full" />
      </div>
      <div class="field">
        <label>{{ t('LBL_TITLE') }}</label>
        <InputText v-model="form.subject" :placeholder="t('LBL_TITLE')" class="w-full" />
      </div>
      <div class="field">
        <label>{{ t('LBL_APPROVAL_CONTENT') }}</label>
        <Textarea v-model="form.body" :rows="12" class="w-full" />
      </div>
    </div>
    <template #footer>
      <Button :label="t('BTN_MAIL_DRAFT')" icon="pi pi-save" severity="secondary" @click="handleDraft" :loading="saving" />
      <Button :label="t('BTN_MAIL_SEND')" icon="pi pi-send" @click="handleSend" :loading="sending" />
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
import { useAuthStore } from '@/store/auth';
import { useMessage } from '@/composables/useMessage';
import { useLabel } from '@/composables/useLabel';

const props = defineProps<{ replyTo?: any; forwardOf?: any }>();
const emit = defineEmits<{ sent: [] }>();
const visible = defineModel<boolean>('visible', { default: false });
const auth = useAuthStore();
const { success, error } = useMessage();
const { t } = useLabel();

const sending = ref(false);
const saving = ref(false);

const form = ref({ to: '', cc: '', subject: '', body: '' });

const dialogTitle = computed(() => {
  if (props.replyTo) return t('LBL_MAIL_REPLY');
  if (props.forwardOf) return t('LBL_MAIL_FORWARD');
  return t('LBL_MAIL_COMPOSE_HEADER');
});

watch(() => [visible.value, props.replyTo, props.forwardOf], ([v]) => {
  if (!v) return;
  if (props.replyTo) {
    const r = props.replyTo;
    form.value = {
      to: r.from?.[0]?.email || '',
      cc: '',
      subject: `Re: ${r.subject || ''}`,
      body: `\n\n---\n${r.preview || ''}`
    };
  } else if (props.forwardOf) {
    const f = props.forwardOf;
    form.value = {
      to: '',
      cc: '',
      subject: `Fwd: ${f.subject || ''}`,
      body: `\n\n--- Forwarded ---\n${f.preview || ''}`
    };
  } else {
    form.value = { to: '', cc: '', subject: '', body: '' };
  }
});

async function handleSend() {
  if (!form.value.to.trim()) { error('받는 사람을 입력하세요'); return; }
  sending.value = true;
  try {
    await axios.post('/api/bff/mail/send', {
      to: form.value.to,
      cc: form.value.cc || undefined,
      subject: form.value.subject,
      body: form.value.body,
      from: `${auth.user?.userId || 'user'}@v3.local`
    });
    success('메일이 발송되었습니다');
    visible.value = false;
    emit('sent');
  } catch (e) {
    error('메일 발송에 실패했습니다');
  } finally {
    sending.value = false;
  }
}

async function handleDraft() {
  saving.value = true;
  try {
    await axios.post('/api/bff/mail/draft', {
      to: form.value.to,
      subject: form.value.subject,
      body: form.value.body,
      from: `${auth.user?.userId || 'user'}@v3.local`
    });
    success('임시저장되었습니다');
  } catch (e) {
    error('임시저장에 실패했습니다');
  } finally {
    saving.value = false;
  }
}
</script>

<style scoped>
.compose-form { display: flex; flex-direction: column; gap: 0.75rem; }
.field { display: flex; flex-direction: column; gap: 0.25rem; }
.field label { font-weight: 500; font-size: 0.9rem; }
.w-full { width: 100%; }
</style>
