<template>
  <div class="page">
    <h2>{{ t('LBL_PAGE_ADMIN_DEPTS') }}</h2>
    <div class="layout">
      <aside class="tree-panel">
        <div class="tree-toolbar">
          <Button :label="t('BTN_ADD_ROOT')" icon="pi pi-plus" size="small" @click="addRoot" />
          <Button :label="t('BTN_REFRESH')" icon="pi pi-refresh" size="small" severity="secondary" @click="load" />
        </div>
        <Tree :value="treeNodes" selectionMode="single" v-model:selectionKeys="selectedKey"
              @node-select="onNodeSelect" :loading="loading" />
      </aside>
      <section class="edit-panel">
        <h3 v-if="!editing.deptId && !isNew">{{ t('LBL_DEPT_SELECT_HINT') }}</h3>
        <template v-else>
          <h3>{{ isNew ? t('LBL_DEPT_NEW') : t('LBL_DEPT_EDIT') }}</h3>
          <div class="form-grid">
            <label>{{ t('LBL_DEPT_CODE_REQ') }}</label>
            <InputText v-model="editing.deptCode" :disabled="!isNew" />
            <label>{{ t('LBL_DEPT_NAME_REQ') }}</label>
            <InputText v-model="editing.deptName" />
            <label>{{ t('LBL_DEPT_PARENT') }}</label>
            <Select v-model="editing.parentDeptId" :options="parentOptions"
                    optionLabel="deptName" optionValue="deptId"
                    :placeholder="t('PH_TREE_ROOT_NONE')" showClear />
            <label>{{ t('LBL_DEPT_LEVEL') }}</label>
            <InputNumber v-model="editing.deptLevel" :min="1" :max="9" />
            <label>{{ t('LBL_DEPT_SORT') }}</label>
            <InputNumber v-model="editing.sortOrder" :min="0" />
            <label>{{ t('LBL_DEPT_USE') }}</label>
            <Select v-model="editing.useYn" :options="yesNoOptions" optionLabel="label" optionValue="code" />
          </div>
          <div class="actions">
            <Button :label="t('BTN_SAVE')" icon="pi pi-check" @click="onSave" :loading="saving" />
            <Button v-if="!isNew" :label="t('BTN_DELETE')" icon="pi pi-trash" severity="danger" @click="onDelete" />
            <Button :label="t('BTN_CANCEL')" severity="secondary" text @click="reset" />
          </div>
        </template>
      </section>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { useLabel } from '@/composables/useLabel'

const { t } = useLabel()
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

const yesNoOptions = computed(() => [
  { code: 'Y', label: t('STATUS_USE_Y') },
  { code: 'N', label: t('STATUS_USE_N') }
])

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
    toast.add({ severity: 'error', summary: t('MSG_LOAD_FAILED'), detail: e.message || String(e), life: 3000 })
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
    toast.add({ severity: 'warn', summary: t('MSG_INPUT_REQUIRED'), detail: t('MSG_DEPT_REQ'), life: 3000 })
    return
  }
  saving.value = true
  try {
    await admin.deptSave({ ...editing })
    toast.add({ severity: 'success', summary: t('MSG_SAVE_DONE'), life: 2000 })
    isNew.value = false
    await load()
  } catch (e: any) {
    toast.add({ severity: 'error', summary: t('MSG_SAVE_FAILED'), detail: e.message || String(e), life: 4000 })
  } finally {
    saving.value = false
  }
}

async function onDelete() {
  if (!editing.deptId) return
  if (!confirm(t('MSG_DEPT_DELETE_CONFIRM').replace('{name}', editing.deptName || ''))) return
  try {
    await admin.deptDelete(editing.deptId)
    toast.add({ severity: 'success', summary: t('MSG_DELETE_DONE'), life: 2000 })
    reset()
    await load()
  } catch (e: any) {
    toast.add({ severity: 'error', summary: t('MSG_DELETE_FAILED'), detail: e.message || String(e), life: 4000 })
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
