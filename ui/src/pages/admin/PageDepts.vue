<template>
  <div class="page">
    <h2>조직 관리</h2>
    <div class="layout">
      <aside class="tree-panel">
        <div class="tree-toolbar">
          <Button label="루트 추가" icon="pi pi-plus" size="small" @click="addRoot" />
          <Button label="새로고침" icon="pi pi-refresh" size="small" severity="secondary" @click="load" />
        </div>
        <Tree :value="treeNodes" selectionMode="single" v-model:selectionKeys="selectedKey"
              @node-select="onNodeSelect" :loading="loading" />
      </aside>
      <section class="edit-panel">
        <h3 v-if="!editing.deptId && !isNew">부서를 선택하거나 추가하세요</h3>
        <template v-else>
          <h3>{{ isNew ? '새 부서' : '부서 편집' }}</h3>
          <div class="form-grid">
            <label>부서코드 *</label>
            <InputText v-model="editing.deptCode" :disabled="!isNew" />
            <label>부서명 *</label>
            <InputText v-model="editing.deptName" />
            <label>상위 부서</label>
            <Select v-model="editing.parentDeptId" :options="parentOptions"
                    optionLabel="deptName" optionValue="deptId"
                    placeholder="(루트)" showClear />
            <label>레벨</label>
            <InputNumber v-model="editing.deptLevel" :min="1" :max="9" />
            <label>정렬순서</label>
            <InputNumber v-model="editing.sortOrder" :min="0" />
            <label>사용</label>
            <Select v-model="editing.useYn" :options="yesNoOptions" optionLabel="label" optionValue="code" />
          </div>
          <div class="actions">
            <Button label="저장" icon="pi pi-check" @click="onSave" :loading="saving" />
            <Button v-if="!isNew" label="삭제" icon="pi pi-trash" severity="danger" @click="onDelete" />
            <Button label="취소" severity="secondary" text @click="reset" />
          </div>
        </template>
      </section>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import Tree from 'primevue/tree'
import Button from 'primevue/button'
import InputText from 'primevue/inputtext'
import InputNumber from 'primevue/inputnumber'
import Select from 'primevue/select'
import { useToast } from 'primevue/usetoast'
import { useAdmin, type AdminDept } from '@/composables/useAdmin'

const admin = useAdmin()
const toast = useToast()

const flatDepts = ref<AdminDept[]>([])
const treeNodes = ref<any[]>([])
const selectedKey = ref<any>({})
const loading = ref(false)
const saving = ref(false)

const isNew = ref(false)
const editing = reactive<AdminDept>({
  deptCode: '',
  deptName: '',
  parentDeptId: null,
  deptLevel: 1,
  sortOrder: 0,
  useYn: 'Y'
})

const yesNoOptions = [
  { code: 'Y', label: '사용' },
  { code: 'N', label: '미사용' }
]

const parentOptions = computed(() => {
  return flatDepts.value.filter(d => d.deptId !== editing.deptId)
})

function toNode(row: any): any {
  return {
    key: row.deptId,
    label: `${row.deptName} (${row.deptCode})`,
    icon: row.useYn === 'N' ? 'pi pi-folder-open' : 'pi pi-building',
    data: row,
    children: (row.children || []).map(toNode)
  }
}

async function load() {
  loading.value = true
  try {
    const { tree, flat } = await admin.deptTree()
    flatDepts.value = flat
    treeNodes.value = tree.map(toNode)
  } catch (e: any) {
    toast.add({ severity: 'error', summary: '조회 실패', detail: e.message || String(e), life: 3000 })
  } finally {
    loading.value = false
  }
}

function onNodeSelect(node: any) {
  isNew.value = false
  Object.assign(editing, {
    deptId: node.data.deptId,
    deptCode: node.data.deptCode,
    deptName: node.data.deptName,
    parentDeptId: node.data.parentDeptId,
    deptLevel: node.data.deptLevel,
    sortOrder: node.data.sortOrder,
    useYn: node.data.useYn || 'Y'
  })
}

function addRoot() {
  isNew.value = true
  selectedKey.value = {}
  Object.assign(editing, {
    deptId: undefined,
    deptCode: '',
    deptName: '',
    parentDeptId: null,
    deptLevel: 1,
    sortOrder: 0,
    useYn: 'Y'
  })
}

async function onSave() {
  if (!editing.deptCode || !editing.deptName) {
    toast.add({ severity: 'warn', summary: '입력 필요', detail: '부서코드/부서명은 필수.', life: 3000 })
    return
  }
  saving.value = true
  try {
    await admin.deptSave({ ...editing })
    toast.add({ severity: 'success', summary: '저장 완료', life: 2000 })
    isNew.value = false
    await load()
  } catch (e: any) {
    toast.add({ severity: 'error', summary: '저장 실패', detail: e.message || String(e), life: 4000 })
  } finally {
    saving.value = false
  }
}

async function onDelete() {
  if (!editing.deptId) return
  if (!confirm(`'${editing.deptName}' 부서를 삭제합니다. 하위 부서/소속 직원이 있으면 실패합니다.`)) return
  try {
    await admin.deptDelete(editing.deptId)
    toast.add({ severity: 'success', summary: '삭제 완료', life: 2000 })
    reset()
    await load()
  } catch (e: any) {
    toast.add({ severity: 'error', summary: '삭제 실패', detail: e.message || String(e), life: 4000 })
  }
}

function reset() {
  isNew.value = false
  Object.assign(editing, {
    deptId: undefined,
    deptCode: '',
    deptName: '',
    parentDeptId: null,
    deptLevel: 1,
    sortOrder: 0,
    useYn: 'Y'
  })
  selectedKey.value = {}
}

onMounted(load)
</script>

<style scoped>
.page { padding: 1.5rem; }
.layout { display: grid; grid-template-columns: 320px 1fr; gap: 1rem; }
.tree-panel { background: var(--p-content-background); border: 1px solid var(--p-content-border-color); border-radius: 0.5rem; padding: 0.5rem; }
.tree-toolbar { display: flex; gap: 0.4rem; margin-bottom: 0.5rem; }
.edit-panel { background: var(--p-content-background); border: 1px solid var(--p-content-border-color); border-radius: 0.5rem; padding: 1rem; }
.form-grid { display: grid; grid-template-columns: 110px 1fr; gap: 0.75rem 1rem; align-items: center; }
.actions { display: flex; gap: 0.5rem; margin-top: 1rem; }
</style>
