<template>
  <div class="page">
    <h2>공통코드 관리</h2>
    <div class="layout">
      <aside class="group-panel">
        <div class="group-toolbar">
          <Button label="그룹 추가" icon="pi pi-plus" size="small" @click="onAddGroup" />
          <Button label="새로고침" icon="pi pi-refresh" size="small" severity="secondary" @click="loadGroups" />
        </div>
        <Listbox v-model="selectedGroup" :options="groups" optionLabel="groupCd"
                 :filter="true" filterPlaceholder="그룹 검색" listStyle="max-height:60vh"
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
          <h3 style="margin:0">{{ selectedGroup ? `${selectedGroup.groupCd}` : '그룹을 선택하세요' }}</h3>
          <span style="flex:1"></span>
          <Button label="행 추가" icon="pi pi-plus" size="small" :disabled="!selectedGroup" @click="addRow" />
          <Button label="저장" icon="pi pi-check" size="small" severity="success"
                  :disabled="!selectedGroup" @click="onSave" :loading="saving" />
        </div>

        <DataTable :value="codes" editMode="cell" @cell-edit-complete="onCellEdit"
                   responsiveLayout="scroll" size="small" :loading="loading">
          <Column field="groupCd" header="그룹" style="width:130px" />
          <Column field="code" header="코드" style="width:150px">
            <template #editor="{ data, field }">
              <InputText v-model="data[field]" :disabled="!data._isNew" />
            </template>
          </Column>
          <Column field="codeName" header="코드명">
            <template #editor="{ data, field }"><InputText v-model="data[field]" /></template>
          </Column>
          <Column field="sortOrder" header="순서" style="width:80px">
            <template #editor="{ data, field }"><InputNumber v-model="data[field]" /></template>
          </Column>
          <Column field="useYn" header="사용" style="width:80px">
            <template #editor="{ data, field }">
              <Select v-model="data[field]" :options="yesNoOptions" optionLabel="label" optionValue="code" />
            </template>
            <template #body="{ data, field }">
              <Tag :value="(data as any)[field as string] === 'Y' ? '사용' : '미사용'" :severity="(data as any)[field as string] === 'Y' ? 'success' : 'danger'" />
            </template>
          </Column>
          <Column header="작업" style="width:80px">
            <template #body="{ data }">
              <Button icon="pi pi-trash" text severity="danger" size="small" @click="onDelete(data)" />
            </template>
          </Column>
        </DataTable>
      </section>
    </div>

    <Dialog v-model:visible="newGroupDialog" header="새 그룹 추가" modal style="width:380px">
      <div class="form-grid">
        <label>그룹 ID *</label>
        <InputText v-model="newGroup.groupCd" />
        <label>첫 코드 *</label>
        <InputText v-model="newGroup.code" />
        <label>코드명 *</label>
        <InputText v-model="newGroup.codeName" />
      </div>
      <template #footer>
        <Button label="취소" severity="secondary" text @click="newGroupDialog = false" />
        <Button label="추가" icon="pi pi-check" @click="confirmNewGroup" />
      </template>
    </Dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
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

const admin = useAdmin()
const toast = useToast()

const groups = ref<{ groupCd: string; codeCount: number }[]>([])
const selectedGroup = ref<{ groupCd: string; codeCount: number } | null>(null)
const codes = ref<(AdminCode & { _rowType?: string; _isNew?: boolean })[]>([])
const loading = ref(false)
const saving = ref(false)
const yesNoOptions = [
  { code: 'Y', label: '사용' },
  { code: 'N', label: '미사용' }
]

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
    toast.add({ severity: 'error', summary: '조회 실패', detail: e.message || String(e), life: 3000 })
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
  if (!confirm(`'${row.code}' 코드를 삭제합니다.`)) return
  try {
    await admin.codeDelete(row.groupCd, row.code)
    toast.add({ severity: 'success', summary: '삭제 완료', life: 2000 })
    await loadCodes()
    await loadGroups()
  } catch (e: any) {
    toast.add({ severity: 'error', summary: '삭제 실패', detail: e.message || String(e), life: 4000 })
  }
}

async function onSave() {
  if (!selectedGroup.value) return
  const rows = codes.value.filter(c => c._rowType === 'C' || c._rowType === 'U')
  if (!rows.length) {
    toast.add({ severity: 'info', summary: '변경된 항목 없음', life: 2000 })
    return
  }
  saving.value = true
  try {
    await admin.codeSave(rows as any)
    toast.add({ severity: 'success', summary: '저장 완료', detail: `${rows.length}건`, life: 2000 })
    await loadCodes()
    await loadGroups()
  } catch (e: any) {
    toast.add({ severity: 'error', summary: '저장 실패', detail: e.message || String(e), life: 4000 })
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
    toast.add({ severity: 'warn', summary: '입력 필요', detail: '모든 항목 필수.', life: 3000 })
    return
  }
  try {
    await admin.codeSave([{ ...newGroup, sortOrder: 0, useYn: 'Y', _rowType: 'C' }] as any)
    toast.add({ severity: 'success', summary: '그룹 추가됨', life: 2000 })
    newGroupDialog.value = false
    await loadGroups()
    selectedGroup.value = groups.value.find(g => g.groupCd === newGroup.groupCd) || null
    await loadCodes()
  } catch (e: any) {
    toast.add({ severity: 'error', summary: '추가 실패', detail: e.message || String(e), life: 4000 })
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
