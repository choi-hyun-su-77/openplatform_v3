<template>
  <div class="page">
    <h2>조직도</h2>
    <div class="org-layout">
      <aside class="dept-tree">
        <Tree :value="deptTree" selectionMode="single" v-model:selectionKeys="selectedKey" @node-select="onDeptSelect" />
      </aside>
      <section class="employee-list">
        <InputText v-model="keyword" placeholder="직원 검색" @keyup.enter="load" />
        <div class="cards">
          <div v-for="emp in employees" :key="emp.employeeId" class="emp-card">
            <div class="avatar">{{ emp.employeeName?.[0] || '?' }}</div>
            <div class="info">
              <div class="name">{{ emp.employeeName }} <span class="pos">{{ emp.positionName }}</span></div>
              <div class="dept">{{ emp.deptName }}</div>
              <div class="contact">
                <i class="pi pi-envelope" /> {{ emp.email || '-' }}
                <span v-if="emp.phone"><i class="pi pi-phone" /> {{ emp.phone }}</span>
              </div>
            </div>
          </div>
        </div>
      </section>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import axios from 'axios';
import Tree from 'primevue/tree';
import InputText from 'primevue/inputtext';

const deptTree = ref<any[]>([]);
const selectedKey = ref<any>({});
const employees = ref<any[]>([]);
const keyword = ref('');
const currentDeptId = ref<number | null>(null);

function toTreeNode(row: any): any {
  return {
    key: row.deptId,
    label: row.deptName,
    icon: 'pi pi-building',
    data: row,
    children: (row.children || []).map(toTreeNode)
  };
}

async function loadTree() {
  const res = await axios.post('/api/dataset/search', {
    serviceName: 'org/searchDeptTree',
    datasets: { ds_search: {} }
  });
  const roots = res.data?.data?.ds_deptTree?.rows || [];
  deptTree.value = roots.map(toTreeNode);
}

async function load() {
  const res = await axios.post('/api/dataset/search', {
    serviceName: 'org/searchEmployees',
    datasets: { ds_search: { deptId: currentDeptId.value, keyword: keyword.value } }
  });
  employees.value = res.data?.data?.ds_employees?.rows || [];
}

function onDeptSelect(node: any) {
  currentDeptId.value = node.key;
  load();
}

onMounted(async () => {
  await loadTree();
  await load();
});
</script>

<style scoped>
.page { padding: 1.5rem; }
.org-layout { display: grid; grid-template-columns: 280px 1fr; gap: 1rem; }
.dept-tree { background: #fff; border-radius: 0.5rem; padding: 0.5rem; }
.employee-list { background: #fff; border-radius: 0.5rem; padding: 1rem; }
.cards { display: grid; grid-template-columns: repeat(auto-fill, minmax(260px, 1fr)); gap: 0.75rem; margin-top: 1rem; }
.emp-card { border: 1px solid #e2e8f0; border-radius: 0.5rem; padding: 0.75rem; display: flex; gap: 0.75rem; }
.avatar { width: 48px; height: 48px; border-radius: 50%; background: #3b82f6; color: #fff; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 1.25rem; }
.info .name { font-weight: 600; }
.info .pos { color: #64748b; font-size: 0.85rem; margin-left: 0.25rem; }
.info .dept { color: #64748b; font-size: 0.85rem; }
.info .contact { font-size: 0.8rem; margin-top: 0.25rem; }
</style>
