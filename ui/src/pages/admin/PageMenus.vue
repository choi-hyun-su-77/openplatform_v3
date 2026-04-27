<template>
  <div class="page">
    <h2>메뉴 / 권한 관리</h2>
    <div class="layout">
      <aside class="tree-panel">
        <div class="tree-toolbar">
          <Button label="새 메뉴" icon="pi pi-plus" size="small" @click="addNew" />
          <Button label="새로고침" icon="pi pi-refresh" size="small" severity="secondary" @click="load" />
        </div>
        <Tree :value="treeNodes" selectionMode="single" v-model:selectionKeys="selectedKey"
              @node-select="onNodeSelect" :loading="loading" />
      </aside>

      <section class="right-panel">
        <h3>{{ isNew ? '새 메뉴' : (editing.menuId ? '메뉴 편집' : '메뉴를 선택하세요') }}</h3>
        <div class="form-grid" v-if="isNew || editing.menuId">
          <label>메뉴 ID *</label>
          <InputText v-model="editing.menuId" :disabled="!isNew" />
          <label>메뉴명 *</label>
          <InputText v-model="editing.menuName" />
          <label>경로</label>
          <InputText v-model="editing.menuPath" placeholder="/example" />
          <label>상위 메뉴</label>
          <Select v-model="editing.parentMenuId" :options="parentOptions"
                  optionLabel="menuName" optionValue="menuId" placeholder="(루트)" showClear />
          <label>레벨</label>
          <InputNumber v-model="editing.menuLevel" :min="1" :max="9" />
          <label>정렬순서</label>
          <InputNumber v-model="editing.sortOrder" :min="0" />
          <label>아이콘</label>
          <InputText v-model="editing.icon" placeholder="pi pi-folder" />
          <label>사용</label>
          <Select v-model="editing.useYn" :options="yesNoOptions" optionLabel="label" optionValue="code" />
        </div>
        <div class="actions" v-if="isNew || editing.menuId">
          <Button label="저장" icon="pi pi-check" @click="onSave" :loading="saving" />
          <Button v-if="!isNew" label="삭제" icon="pi pi-trash" severity="danger" @click="onDelete" />
          <Button label="취소" severity="secondary" text @click="cancel" />
        </div>

        <h3 style="margin-top:1.5rem">권한 매트릭스</h3>
        <div class="matrix-toolbar">
          <span class="muted">선택 메뉴: {{ editing.menuId ? `${editing.menuName} (${editing.menuId})` : '(전체 메뉴)' }}</span>
          <Button label="권한 저장" icon="pi pi-save" size="small" @click="savePermissions" :loading="permSaving" />
        </div>
        <DataTable :value="filteredPermissions" responsiveLayout="scroll" size="small">
          <Column field="roleId" header="역할" style="width:120px" />
          <Column field="menuId" header="메뉴" style="width:140px" />
          <Column field="menuName" header="메뉴명" style="min-width:120px" />
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

const yesNoOptions = [
  { code: 'Y', label: '사용' },
  { code: 'N', label: '미사용' }
]

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
    toast.add({ severity: 'error', summary: '조회 실패', detail: e.message || String(e), life: 3000 })
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
    toast.add({ severity: 'warn', summary: '입력 필요', detail: '메뉴ID/메뉴명은 필수.', life: 3000 })
    return
  }
  saving.value = true
  try {
    await admin.menuSave({ ...editing })
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
  if (!editing.menuId) return
  if (!confirm(`'${editing.menuName}' 메뉴를 삭제합니다.`)) return
  try {
    await admin.menuDelete(editing.menuId)
    toast.add({ severity: 'success', summary: '삭제 완료', life: 2000 })
    cancel()
    await load()
  } catch (e: any) {
    toast.add({ severity: 'error', summary: '삭제 실패', detail: e.message || String(e), life: 4000 })
  }
}

async function savePermissions() {
  permSaving.value = true
  try {
    // 화면에 보이는 모든 항목을 upsert (단순화)
    const rows = filteredPermissions.value
    await admin.permSave(rows as any)
    toast.add({ severity: 'success', summary: '권한 저장됨', detail: `${rows.length}건`, life: 2000 })
  } catch (e: any) {
    toast.add({ severity: 'error', summary: '저장 실패', detail: e.message || String(e), life: 4000 })
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
