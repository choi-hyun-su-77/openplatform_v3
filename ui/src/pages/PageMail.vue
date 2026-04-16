<template>
  <div class="page-mail">
    <!-- 좌측: 메일함 트리 -->
    <aside class="mail-sidebar">
      <Button label="새 메일" icon="pi pi-pencil" class="compose-btn" @click="openCompose()" />
      <MailboxTree :mailboxes="mailboxes" :selected="selectedMailboxId" @select="onSelectMailbox" />
    </aside>
    <!-- 중앙: 메일 리스트 -->
    <section class="mail-list">
      <EmailList :emails="emails" :loading="loadingEmails" :selectedId="selectedEmailId"
                 @select="onSelectEmail" />
    </section>
    <!-- 우측: 메일 상세 -->
    <section class="mail-detail">
      <EmailDetail :email="detailEmail" @reply="openReply" @forward="openForward" />
    </section>

    <!-- 작성 다이얼로그 -->
    <ComposeDialog v-model:visible="composeVisible" :replyTo="replyTo" :forwardOf="forwardOf"
                   @sent="onSent" />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import axios from 'axios';
import Button from 'primevue/button';
import MailboxTree from '@/components/mail/MailboxTree.vue';
import EmailList from '@/components/mail/EmailList.vue';
import EmailDetail from '@/components/mail/EmailDetail.vue';
import ComposeDialog from '@/components/mail/ComposeDialog.vue';

const mailboxes = ref<any[]>([]);
const emails = ref<any[]>([]);
const loadingEmails = ref(false);
const selectedMailboxId = ref<string>('');
const selectedEmailId = ref<string>('');
const detailEmail = ref<any>(null);
const composeVisible = ref(false);
const replyTo = ref<any>(null);
const forwardOf = ref<any>(null);

async function loadMailboxes() {
  try {
    const res = await axios.get('/api/bff/mail/mailboxes');
    mailboxes.value = res.data || [];
    // 자동으로 INBOX 선택
    const inbox = mailboxes.value.find((m: any) =>
      (m.name || '').toLowerCase().includes('inbox') || m.role === 'inbox'
    );
    if (inbox) {
      selectedMailboxId.value = inbox.id;
      loadEmails(inbox.id);
    }
  } catch (e) {
    console.warn('mailboxes load failed', e);
  }
}

async function loadEmails(mailboxId: string) {
  loadingEmails.value = true;
  try {
    const res = await axios.get('/api/bff/mail/emails', { params: { mailboxId, limit: 50 } });
    emails.value = res.data || [];
  } catch (e) {
    console.warn('emails load failed', e);
    emails.value = [];
  } finally {
    loadingEmails.value = false;
  }
}

function onSelectMailbox(id: string) {
  selectedMailboxId.value = id;
  selectedEmailId.value = '';
  detailEmail.value = null;
  loadEmails(id);
}

async function onSelectEmail(email: any) {
  selectedEmailId.value = email.id;
  try {
    const res = await axios.get(`/api/bff/mail/email/${email.id}`);
    detailEmail.value = res.data;
  } catch (e) {
    console.warn('email detail failed', e);
    detailEmail.value = email;
  }
}

function openCompose() {
  replyTo.value = null;
  forwardOf.value = null;
  composeVisible.value = true;
}

function openReply(email: any) {
  replyTo.value = email;
  forwardOf.value = null;
  composeVisible.value = true;
}

function openForward(email: any) {
  replyTo.value = null;
  forwardOf.value = email;
  composeVisible.value = true;
}

function onSent() {
  if (selectedMailboxId.value) loadEmails(selectedMailboxId.value);
}

onMounted(loadMailboxes);
</script>

<style scoped>
.page-mail {
  display: grid;
  grid-template-columns: 200px 360px 1fr;
  height: calc(100vh - var(--header-height, 56px) - 40px);
  overflow: hidden;
}
.mail-sidebar {
  border-right: 1px solid var(--p-content-border-color);
  padding: 0.75rem;
  overflow-y: auto;
}
.compose-btn { width: 100%; margin-bottom: 0.75rem; }
.mail-list {
  border-right: 1px solid var(--p-content-border-color);
  overflow-y: auto;
}
.mail-detail { overflow-y: auto; }
</style>
