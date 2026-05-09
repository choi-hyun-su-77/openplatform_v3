<template>
  <div class="page">
    <h2>{{ t('LBL_PAGE_ADMIN_MENUS') }}</h2>
    <div class="layout">
      <aside class="tree-panel">
        <div class="tree-toolbar">
          <Button :label="t('BTN_NEW_MENU')" icon="pi pi-plus" size="small" @click="addNew" />
          <Button :label="t('BTN_REFRESH')" icon="pi pi-refresh" size="small" severity="secondary" @click="load" />
        </div>
        <Tree :value="treeNodes" selectionMode="single" v-model:selectionKeys="selectedKey"
              @node-select="onNodeSelect" :loading="loading" />
      </aside>

      <section class="right-panel">
        <h3>{{ isNew ? t('LBL_MENU_NEW') : (editing.menuId ? t('LBL_MENU_EDIT') : t('LBL_MENU_SELECT_HINT')) }}</h3>
        <div class="form-grid" v-if="isNew || editing.menuId">
          <label>{{ t('LBL_MENU_ID_REQ') }}</label>
          <InputText v-model="editing.menuId" :disabled="!isNew" />
          <label>{{ t('LBL_MENU_NAME_REQ') }}</label>
          <InputText v-model="editing.menuName" />
          <label>{{ t('LBL_MENU_PATH') }}</label>
          <InputText v-model="editing.menuPath" :placeholder="t('PH_MENU_PATH')" />
          <label>{{ t('LBL_MENU_PARENT') }}</label>
          <Select v-model="editing.parentMenuId" :options="parentOptions"
                  optionLabel="menuName" optionValue="menuId" :placeholder="t('PH_TREE_ROOT_NONE')" showClear />
          <label>{{ t('LBL_MENU_LEVEL') }}</label>
          <InputNumber v-model="editing.menuLevel" :min="1" :max="9" />
          <label>{{ t('LBL_MENU_SORT') }}</label>
          <InputNumber v-model="editing.sortOrder" :min="0" />
          <label>{{ t('LBL_MENU_ICON') }}</label>
          <InputText v-model="editing.icon" :placeholder="t('PH_MENU_ICON')" />
          <label>{{ t('LBL_MENU_USE') }}</label>
          <Select v-model="editing.useYn" :options="yesNoOptions" optionLabel="label" optionValue="code" />
        </div>
        <div class="actions" v-if="isNew || editing.menuId">
          <Button :label="t('BTN_SAVE')" icon="pi pi-check" @click="onSave" :loading="saving" />
          <Button v-if="!isNew" :label="t('BTN_DELETE')" icon="pi pi-trash" severity="danger" @click="onDelete" />
          <Button :label="t('BTN_CANCEL')" severity="secondary" text @click="cancel" />
        </div>

        <h3 style="margin-top:1.5rem">{{ t('LBL_MENU_PERM_MATRIX') }}</h3>
        <div class="matrix-toolbar">
          <span class="muted">{{ t('LBL_MENU_PERM_SELECTED') }}: {{ editing.menuId ? `${editing.menuName} (${editing.menuId})` : t('LBL_MENU_PERM_ALL') }}</span>
          <Button :label="t('BTN_SAVE_PERM')" icon="pi pi-save" size="small" @click="savePermissions" :loading="permSaving" />
        </div>
        <DataTable :value="filteredPermissions" responsiveLayout="scroll" size="small">
          <Column field="roleId" :header="t('COL_MENU_ROLE')" style="width:120px" />
          <Column field="menuId" :header="t('COL_MENU_ID')" style="width:140px" />
          <Column field="menuName" :header="t('COL_MENU_NAME')" style="min-width:120px" />
          <Column header="R" style="width:50px">
            <template #body="{ data }"><Checkbox v-model="data.canRead" :binary="true" /></template>
          </Column>
          <Column header="W" style="width:50px">
            <template #body="{ data }"><Checkbox v-model="data.canCreate" :binary="true" /></template>
          </Column>
          <Column header="U" style="width:50px">
            <template #body="{ data }"><Checkbox v-model="data.canUpdate" :binary="true" /></template>
          </Column>
          <Column header="D" style="width:50px">
            <template #body="{ data }"><Checkbox v-model="data.canDelete" :binary="true" /></template>
          </Column>
          <Column header="Export" style="width:60px">
            <template #body="{ data }"><Checkbox v-model="data.canExport" :binary="true" /></template>
          </Column>
          <Column header="Print" style="width:60px">
            <template #body="{ data }"><Checkbox v-model="data.canPrint" :binary="true" /></template>
          </Column>
        </DataTable>
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
import DataTable from 'primevue/datatable'
import Column from 'primevue/column'
import Checkbox from 'primevue/checkbox'
import { useToast } from 'primevue/usetoast'
import { useAdmin, type AdminMenu, type AdminPermission } from '@/composables/useAdmin'

const admin = useAdmin()
const toast = useToast()

const flatMenus = ref<AdminMenu[]>([])
const treeNodes = ref<any[]>([])
const roles = ref<{ roleId: string; roleName: string }[]>([])
const permissions = ref<(AdminPermission & { menuName?: string })[]>([])
const selectedKey = ref<any>({})
const loading = ref(false)
const saving = ref(false)
const permSaving = ref(false)

const isNew = ref(false)
const editing = reactive<AdminMenu>({
  menuId: '',
  menuName: '',
  menuPath: '',
  parentMenuId: null,
  menuLevel: 1,
  sortOrder: 0,
  icon: '',
  useYn: 'Y'
})

const yesNoOptions = computed(() => [
  { code: 'Y', label: t('STATUS_USE_Y') },
  { code: 'N', label: t('STATUS_USE_N') }
])

const parentOptions = computed(() => flatMenus.value.filter(m => m.menuId !== editing.menuId))

const filteredPermissions = computed(() => {
  if (!editing.menuId) return permissions.value
  return permissions.value.filter(p => p.menuId === editing.menuId)
})

function toNode(row: any): any {
  return {
    key: row.menuId,
    label: `${row.menuName} (${row.menuId})`,
    icon: row.icon || 'pi pi-circle',
    data: row,
    children: (row.children || []).map(toNode)
  }
}

async function load() {
  loading.value = true
  try {
    const data = await admin.menuList()
    flatMenus.value = data.flat
    treeNodes.value = data.tree.map(toNode)
    roles.value = data.roles
    permissions.value = data.permissions.map(p => ({ ...p }))
  } catch (e: any) {
    toast.add({ severity: 'error', summary: t('MSG_LOAD_FAILED'), detail: e.message || String(e), life: 3000 })
  } finally {
    loading.value = false
  }
}

function onNodeSelect(node: any) {
  isNew.value = false
  Object.assign(editing, {
    menuId: node.data.menuId,
    menuName: node.data.menuName,
    menuPath: node.data.menuPath || '',
    parentMenuId: node.data.parentMenuId,
    menuLevel: node.data.menuLevel,
    sortOrder: node.data.sortOrder,
    icon: node.data.icon || '',
    useYn: node.data.useYn || 'Y'
  })
}

function addNew() {
  isNew.value = true
  selectedKey.value = {}
  Object.assign(editing, {
    menuId: '',
    menuName: '',
    menuPath: '',
    parentMenuId: null,
    menuLevel: 1,
    sortOrder: 0,
    icon: '',
    useYn: 'Y'
  })
}

function cancel() {
  isNew.value = false
  Object.assign(editing, { menuId: '', menuName: '', menuPath: '', parentMenuId: null, menuLevel: 1, sortOrder: 0, icon: '', useYn: 'Y' })
  selectedKey.value = {}
}

async function onSave() {
  if (!editing.menuId || !editing.menuName) {
    toast.add({ severity: 'warn', summary: t('MSG_INPUT_REQUIRED'), detail: t('MSG_MENU_REQ'), life: 3000 })
    return
  }
  saving.value = true
  try {
    await admin.menuSave({ ...editing })
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
  if (!editing.menuId) return
  if (!confirm(t('MSG_MENU_DELETE_CONFIRM').replace('{name}', editing.menuName || ''))) return
  try {
    await admin.menuDelete(editing.menuId)
    toast.add({ severity: 'success', summary: t('MSG_DELETE_DONE'), life: 2000 })
    cancel()
    await load()
  } catch (e: any) {
    toast.add({ severity: 'error', summary: t('MSG_DELETE_FAILED'), detail: e.message || String(e), life: 4000 })
  }
}

async function savePermissions() {
  permSaving.value = true
  try {
    // 화면에 보이는 모든 항목을 upsert (단순화)
    const rows = filteredPermissions.value
    await admin.permSave(rows as any)
    toast.add({ severity: 'success', summary: t('MSG_MENU_PERM_SAVED'), detail: `${rows.length}`, life: 2000 })
  } catch (e: any) {
    toast.add({ severity: 'error', summary: t('MSG_SAVE_FAILED'), detail: e.message || String(e), life: 4000 })
  } finally {
    permSaving.value = false
  }
}

onMounted(load)
</script>

<style scoped>
.page { padding: 1.5rem; }
.layout { display: grid; grid-template-columns: 320px 1fr; gap: 1rem; }
.tree-panel { background: var(--p-content-background); border: 1px solid var(--p-content-border-color); border-radius: 0.5rem; padding: 0.5rem; }
.tree-toolbar { display: flex; gap: 0.4rem; margin-bottom: 0.5rem; }
.right-panel { background: var(--p-content-background); border: 1px solid var(--p-content-border-color); border-radius: 0.5rem; padding: 1rem; }
.form-grid { display: grid; grid-template-columns: 110px 1fr; gap: 0.75rem 1rem; align-items: center; }
.actions { display: flex; gap: 0.5rem; margin-top: 1rem; }
.matrix-toolbar { display: flex; align-items: center; justify-content: space-between; margin-bottom: 0.5rem; }
.muted { color: var(--p-text-muted-color); font-size: 0.85rem; }
</style>
