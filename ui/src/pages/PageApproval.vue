<template>
  <div class="page">
    <h2>전자결재</h2>
    <div class="approval-layout">
      <aside class="inbox-nav">
        <ul>
          <li v-for="b in boxes" :key="b.code" :class="{ active: b.code === activeBox }" @click="selectBox(b.code)">
            <i :class="b.icon" /> {{ b.label }}
          </li>
        </ul>
      </aside>
      <section class="inbox-list">
        <DataTable :value="documents" :rowHover="true" @row-click="onRowClick">
          <Column field="docId" header="번호" style="width:80px" />
          <Column field="docTitle" header="제목" />
          <Column field="drafterName" header="기안자" style="width:120px" />
          <Column field="status" header="상태" style="width:120px" />
          <Column field="createdAt" header="기안일" style="width:140px" />
        </DataTable>
      </section>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import axios from 'axios';
import DataTable from 'primevue/datatable';
import Column from 'primevue/column';

const boxes = [
  { code: 'DRAFT',       label: '임시저장', icon: 'pi pi-pencil'   },
  { code: 'MY_DOCS',     label: '기안함',   icon: 'pi pi-folder'   },
  { code: 'PENDING',     label: '대기함',   icon: 'pi pi-clock'    },
  { code: 'IN_PROGRESS', label: '진행함',   icon: 'pi pi-sync'     },
  { code: 'COMPLETED',   label: '완료함',   icon: 'pi pi-check'    },
  { code: 'REJECTED',    label: '반려함',   icon: 'pi pi-times'    },
  { code: 'RECEIVED',    label: '수신함',   icon: 'pi pi-inbox'    },
  { code: 'CC_BOX',      label: '참조함',   icon: 'pi pi-eye'      },
  { code: 'DEPT_BOX',    label: '부서함',   icon: 'pi pi-building' }
];

const activeBox = ref('PENDING');
const documents = ref<any[]>([]);

async function selectBox(code: string) {
  activeBox.value = code;
  try {
    const res = await axios.post('/api/dataset/search', {
      serviceName: 'approval/searchInbox',
      datasets: { ds_search: { boxType: code, userId: 1 } }
    });
    documents.value = res.data?.data?.ds_inbox?.rows || [];
  } catch {
    documents.value = [];
  }
}

function onRowClick(e: any) {
  console.log('document clicked', e.data);
}

onMounted(() => selectBox('PENDING'));
</script>

<style scoped>
.page { padding: 1.5rem; }
.approval-layout { display: grid; grid-template-columns: 220px 1fr; gap: 1rem; margin-top: 1rem; }
.inbox-nav { background: #fff; border-radius: 0.5rem; padding: 0.5rem; }
.inbox-nav ul { list-style: none; padding: 0; margin: 0; }
.inbox-nav li { padding: 0.75rem 1rem; cursor: pointer; border-radius: 0.375rem; display: flex; gap: 0.5rem; }
.inbox-nav li:hover { background: #f1f5f9; }
.inbox-nav li.active { background: #3b82f6; color: #fff; }
.inbox-list { background: #fff; border-radius: 0.5rem; padding: 1rem; }
</style>
