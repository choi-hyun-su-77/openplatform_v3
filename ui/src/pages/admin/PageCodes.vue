<template>
  <div class="page">
    <h2>{{ t('LBL_PAGE_ADMIN_CODES') }}</h2>
    <div class="layout">
      <aside class="group-panel">
        <div class="group-toolbar">
          <Button :label="t('BTN_ADD_GROUP')" icon="pi pi-plus" size="small" @click="onAddGroup" />
          <Button :label="t('BTN_REFRESH')" icon="pi pi-refresh" size="small" severity="secondary" @click="loadGroups" />
        </div>
        <Listbox v-model="selectedGroup" :options="groups" optionLabel="groupCd"
                 :filter="true" :filterPlaceholder="t('PH_GROUP_SEARCH')" listStyle="max-height:60vh"
                 @change="onGroupChange">
          <template #option="{ option }">
            <span class="group-row">
              <span class="group-cd">{{ option.groupCd }}</span>
              <Tag :value="option.codeCount" severity="info" />
            </span>
          </template>
        </Listbox>
      </aside>

      <section class="codes-panel">
        <div class="toolbar">
          <h3 style="margin:0">{{ selectedGroup ? `${selectedGroup.groupCd}` : t('LBL_CODE_GROUP_HINT') }}</h3>
          <span style="flex:1"></span>
          <Button :label="t('BTN_ADD_ROW')" icon="pi pi-plus" size="small" :disabled="!selectedGroup" @click="addRow" />
          <Button :label="t('BTN_SAVE')" icon="pi pi-check" size="small" severity="success"
                  :disabled="!selectedGroup" @click="onSave" :loading="saving" />
        </div>

        <DataTable :value="codes" editMode="cell" @cell-edit-complete="onCellEdit"
                   responsiveLayout="scroll" size="small" :loading="loading">
          <Column field="groupCd" :header="t('COL_CODE_GROUP')" style="width:130px" />
          <Column field="code" :header="t('COL_CODE_CODE')" style="width:150px">
            <template #editor="{ data, field }">
              <InputText v-model="data[field]" :disabled="!data._isNew" />
            </template>
          </Column>
          <Column field="codeName" :header="t('COL_CODE_NAME')">
            <template #editor="{ data, field }"><InputText v-model="data[field]" /></template>
          </Column>
          <Column field="sortOrder" :header="t('COL_CODE_SORT')" style="width:80px">
            <template #editor="{ data, field }"><InputNumber v-model="data[field]" /></template>
          </Column>
          <Column field="useYn" :header="t('COL_CODE_USE')" style="width:80px">
            <template #editor="{ data, field }">
              <Select v-model="data[field]" :options="yesNoOptions" optionLabel="label" optionValue="code" />
            </template>
            <template #body="{ data, field }">
              <Tag :value="(data as any)[field as string] === 'Y' ? t('STATUS_USE_Y') : t('STATUS_USE_N')" :severity="(data as any)[field as string] === 'Y' ? 'success' : 'danger'" />
            </template>
          </Column>
          <Column :header="t('COL_CODE_ACTIONS')" style="width:80px">
            <template #body="{ data }">
              <Button icon="pi pi-trash" text severity="danger" size="small" @click="onDelete(data)" />
            </template>
          </Column>
        </DataTable>
      </section>
    </div>

    <Dialog v-model:visible="newGroupDialog" :header="t('LBL_CODE_NEW_GROUP')" modal style="width:380px">
      <div class="form-grid">
        <label>{{ t('LBL_CODE_GROUP_ID_REQ') }}</label>
        <InputText v-model="newGroup.groupCd" />
        <label>{{ t('LBL_CODE_FIRST_REQ') }}</label>
        <InputText v-model="newGroup.code" />
        <label>{{ t('LBL_CODE_NAME_REQ') }}</label>
        <InputText v-model="newGroup.codeName" />
      </div>
      <template #footer>
        <Button :label="t('BTN_CANCEL')" severity="secondary" text @click="newGroupDialog = false" />
        <Button :label="t('BTN_ADD')" icon="pi pi-check" @click="confirmNewGroup" />
      </template>
    </Dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, reactive, onMounted } from 'vue'
import Button from 'primevue/button'
import Listbox from 'primevue/listbox'
import DataTable from 'primevue/datatable'
import Column from 'primevue/column'
import InputText from 'primevue/inputtext'
import InputNumber from 'primevue/inputnumber'
import Select from 'primevue/select'
import Tag from 'primevue/tag'
import Dialog from 'primevue/dialog'
import { useToast } from 'primevue/usetoast'
import { useAdmin, type AdminCode } from '@/composables/useAdmin'
import { useLabel } from '@/composables/useLabel'

const admin = useAdmin()
const toast = useToast()
const { t } = useLabel()

const groups = ref<{ groupCd: string; codeCount: number }[]>([])
const selectedGroup = ref<{ groupCd: string; codeCount: number } | null>(null)
const codes = ref<(AdminCode & { _rowType?: string; _isNew?: boolean })[]>([])
const loading = ref(false)
const saving = ref(false)
const yesNoOptions = computed(() => [
  { code: 'Y', label: t('STATUS_USE_Y') },
  { code: 'N', label: t('STATUS_USE_N') }
])

const newGroupDialog = ref(false)
const newGroup = reactive({ groupCd: '', code: '', codeName: '' })

async function loadGroups() {
  groups.value = await admin.codeGroupList()
}

async function loadCodes() {
  if (!selectedGroup.value) return
  loading.value = true
  try {
    const rows = await admin.codeList(selectedGroup.value.groupCd)
    codes.value = rows.map(r => ({ ...r }))
  } catch (e: any) {
    toast.add({ severity: 'error', summary: t('MSG_LOAD_FAILED'), detail: e.message || String(e), life: 3000 })
  } finally {
    loading.value = false
  }
}

function onGroupChange() {
  loadCodes()
}

function addRow() {
  if (!selectedGroup.value) return
  codes.value.push({
    groupCd: selectedGroup.value.groupCd,
    code: '',
    codeName: '',
    sortOrder: codes.value.length,
    useYn: 'Y',
    _rowType: 'C',
    _isNew: true
  })
}

function onCellEdit(e: any) {
  const r: any = e.newData
  const orig: any = e.data
  Object.assign(orig, r)
  if (!orig._rowType) orig._rowType = 'U'
}

async function onDelete(row: any) {
  if (!selectedGroup.value) return
  if (row._isNew) {
    codes.value = codes.value.filter(c => c !== row)
    return
  }
  if (!confirm(t('MSG_CODE_DELETE_CONFIRM').replace('{code}', row.code || ''))) return
  try {
    await admin.codeDelete(row.groupCd, row.code)
    toast.add({ severity: 'success', summary: t('MSG_DELETE_DONE'), life: 2000 })
    await loadCodes()
    await loadGroups()
  } catch (e: any) {
    toast.add({ severity: 'error', summary: t('MSG_DELETE_FAILED'), detail: e.message || String(e), life: 4000 })
  }
}

async function onSave() {
  if (!selectedGroup.value) return
  const rows = codes.value.filter(c => c._rowType === 'C' || c._rowType === 'U')
  if (!rows.length) {
    toast.add({ severity: 'info', summary: t('MSG_NO_CHANGES'), life: 2000 })
    return
  }
  saving.value = true
  try {
    await admin.codeSave(rows as any)
    toast.add({ severity: 'success', summary: t('MSG_SAVE_DONE'), detail: `${rows.length}`, life: 2000 })
    await loadCodes()
    await loadGroups()
  } catch (e: any) {
    toast.add({ severity: 'error', summary: t('MSG_SAVE_FAILED'), detail: e.message || String(e), life: 4000 })
  } finally {
    saving.value = false
  }
}

function onAddGroup() {
  newGroup.groupCd = ''
  newGroup.code = ''
  newGroup.codeName = ''
  newGroupDialog.value = true
}

async function confirmNewGroup() {
  if (!newGroup.groupCd || !newGroup.code || !newGroup.codeName) {
    toast.add({ severity: 'warn', summary: t('MSG_INPUT_REQUIRED'), detail: t('MSG_CODE_ALL_REQ'), life: 3000 })
    return
  }
  try {
    await admin.codeSave([{ ...newGroup, sortOrder: 0, useYn: 'Y', _rowType: 'C' }] as any)
    toast.add({ severity: 'success', summary: t('MSG_CODE_GROUP_ADDED'), life: 2000 })
    newGroupDialog.value = false
    await loadGroups()
    selectedGroup.value = groups.value.find(g => g.groupCd === newGroup.groupCd) || null
    await loadCodes()
  } catch (e: any) {
    toast.add({ severity: 'error', summary: t('MSG_CODE_ADD_FAILED'), detail: e.message || String(e), life: 4000 })
  }
}

onMounted(async () => {
  await loadGroups()
  if (groups.value.length) {
    selectedGroup.value = groups.value[0]
    await loadCodes()
  }
})
</script>

<style scoped>
.page { padding: 1.5rem; }
.layout { display: grid; grid-template-columns: 280px 1fr; gap: 1rem; }
.group-panel { background: var(--p-content-background); border: 1px solid var(--p-content-border-color); border-radius: 0.5rem; padding: 0.5rem; }
.group-toolbar { display: flex; gap: 0.4rem; margin-bottom: 0.5rem; }
.group-row { display: flex; align-items: center; justify-content: space-between; gap: 0.5rem; width: 100%; }
.group-cd { font-family: monospace; }
.codes-panel { background: var(--p-content-background); border: 1px solid var(--p-content-border-color); border-radius: 0.5rem; padding: 1rem; }
.toolbar { display: flex; gap: 0.5rem; align-items: center; margin-bottom: 0.75rem; }
.form-grid { display: grid; grid-template-columns: 100px 1fr; gap: 0.75rem 1rem; align-items: center; }
</style>
