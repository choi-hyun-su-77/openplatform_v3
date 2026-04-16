<template>
  <div class="mailbox-tree">
    <div v-for="mb in mailboxes" :key="mb.id"
         :class="['mailbox-item', { active: mb.id === selected }]"
         @click="$emit('select', mb.id)">
      <i :class="iconFor(mb.name || mb.role)" />
      <span class="mb-name">{{ mb.name }}</span>
      <span v-if="mb.totalEmails" class="mb-count">{{ mb.totalEmails }}</span>
    </div>
  </div>
</template>

<script setup lang="ts">
defineProps<{ mailboxes: any[]; selected?: string }>();
defineEmits<{ select: [id: string] }>();

function iconFor(name: string): string {
  const n = (name || '').toLowerCase();
  if (n.includes('inbox')) return 'pi pi-inbox';
  if (n.includes('sent')) return 'pi pi-send';
  if (n.includes('draft')) return 'pi pi-file-edit';
  if (n.includes('trash') || n.includes('junk')) return 'pi pi-trash';
  return 'pi pi-folder';
}
</script>

<style scoped>
.mailbox-tree { display: flex; flex-direction: column; gap: 2px; }
.mailbox-item {
  display: flex; align-items: center; gap: 0.5rem; padding: 0.5rem 0.75rem;
  cursor: pointer; border-radius: 6px; font-size: 0.9rem;
}
.mailbox-item:hover { background: var(--p-content-hover-background); }
.mailbox-item.active { background: var(--p-highlight-background); font-weight: 600; }
.mb-count { margin-left: auto; font-size: 0.8rem; color: var(--p-text-muted-color); }
</style>
