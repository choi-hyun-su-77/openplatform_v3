<template>
  <div class="page">
    <h2>{{ t('LBL_PAGE_ADMIN_USERS') }}</h2>
    <div class="toolbar">
      <InputText v-model="keyword" :placeholder="t('PH_USER_SEARCH')" @keyup.enter="load" />
      <Select v-model="status" :options="statusOptions" optionLabel="label" optionValue="code"
              :placeholder="t('PH_STATUS_SELECT')" showClear @change="load" />
      <Button :label="t('BTN_SEARCH')" icon="pi pi-search" @click="load" />
      <Button :label="t('BTN_ADD')" icon="pi pi-plus" severity="success" @click="openCreate" />
    </div>

    <DataTable :value="users" :rowHover="true" paginator :rows="pageSize"
               :totalRecords="total" :lazy="true"
               :first="first"
               @page="onPage"
               :loading="loading"
               selectionMode="single" v-model:selection="selectedRow"
               @row-click="(e) => openEdit(e.data)" dataKey="employeeId">
      <Column field="employeeNo" :header="t('COL_USER_NO')" style="width:100px" />
      <Column field="employeeName" :header="t('COL_USER_NAME')" style="width:120px" />
      <Column field="deptName" :header="t('COL_USER_DEPT')" style="width:140px" />
      <Column field="positionName" :header="t('COL_USER_POSITION')" style="width:100px" />
      <Column field="email" :header="t('COL_USER_EMAIL')" />
      <Column field="keycloakUserId" :header="t('COL_USER_KC_USERNAME')" style="width:120px" />
      <Column field="status" :header="t('COL_USER_STATUS')" style="width:90px">
        <template #body="{ data }">
          <Tag :value="t('STATUS_USER_' + data.status, data.status)" :severity="data.status === 'ACTIVE' ? 'success' : 'danger'" />
        </template>
      </Column>
      <Column :header="t('COL_USER_ACTIONS')" style="width:200px">
        <template #body="{ data }">
          <Button icon="pi pi-pencil" text size="small" @click.stop="openEdit(data)" />
          <Button icon="pi pi-power-off" text size="small" severity="warn"
                  @click.stop="onToggle(data)" />
          <Button icon="pi pi-key" text size="small" severity="info"
                  @click.stop="onResetPwd(data)" />
        </template>
      </Column>
    </DataTable>

    <!-- 추가/편집 다이얼로그 -->
    <Dialog v-model:visible="dialogVisible" :header="editing.employeeId ? t('LBL_USER_FORM_EDIT') : t('LBL_USER_FORM_NEW')"
            modal style="width:560px">
      <div class="form-grid">
        <label>{{ t('LBL_USER_NAME_REQ') }}</label>
        <InputText v-model="editing.employeeName" />
        <label>{{ t('LBL_USER_NO_REQ') }}</label>
        <InputText v-model="editing.employeeNo" :disabled="!!editing.employeeId" />
        <label>{{ t('LBL_USER_EMAIL') }}</label>
        <InputText v-model="editing.email" />
        <label>{{ t('LBL_USER_PHONE') }}</label>
        <InputText v-model="editing.phone" />
        <label>{{ t('LBL_USER_DEPT_REQ') }}</label>
        <Select v-model="editing.deptId" :options="deptList" optionLabel="deptName" optionValue="deptId"
                :placeholder="t('PH_DEPT_SELECT')" />
        <label>{{ t('LBL_USER_POSITION_REQ') }}</label>
        <Select v-model="editing.positionId" :options="positionList" optionLabel="positionName" optionValue="positionId"
                :placeholder="t('PH_POSITION_SELECT')" />
        <label>{{ t('LBL_USER_KC_USERNAME') }}</label>
        <InputText v-model="editing.keycloakUserId" />
        <label>{{ t('LBL_USER_ROLES') }}</label>
        <MultiSelect v-model="editing.roles" :options="roleOptions" optionLabel="label" optionValue="code"
                     :placeholder="t('PH_ROLES_SELECT')" />
      </div>
      <template #footer>
        <Button :label="t('BTN_CANCEL')" severity="secondary" text @click="dialogVisible = false" />
        <Button :label="t('BTN_SAVE')" icon="pi pi-check" @click="onSave" :loading="saving" />
      </template>
    </Dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, reactive } from 'vue'
import DataTable from 'primevue/datatable'
import Column from 'primevue/column'
import InputText from 'primevue/inputtext'
import Button from 'primevue/button'
import Select from 'primevue/select'
import MultiSelect from 'primevue/multiselect'
import Dialog from 'primevue/dialog'
import Tag from 'primevue/tag'
import { useToast } from 'primevue/usetoast'
import { useAdmin, type AdminUser } from '@/composables/useAdmin'
import { useLabel } from '@/composables/useLabel'

const admin = useAdmin()
const toast = useToast()
const { t } = useLabel()

const keyword = ref('')
const status = ref<string | null>(null)
const statusOptions = computed(() => [
  { code: 'ACTIVE', label: t('STATUS_USER_ACTIVE') },
  { code: 'INACTIVE', label: t('STATUS_USER_INACTIVE') }
])

const users = ref<AdminUser[]>([])
const total = ref(0)
const loading = ref(false)
const saving = ref(false)
const pageSize = 20
const page = ref(0)
const first = ref(0)

const selectedRow = ref<AdminUser | null>(null)

const dialogVisible = ref(false)
const editing = reactive<AdminUser>({
  employeeNo: '',
  employeeName: '',
  email: '',
  phone: '',
  deptId: undefined,
  positionId: undefined,
  keycloakUserId: '',
  roles: []
})

const deptList = ref<any[]>([])
const positionList = ref<any[]>([])
const roleOptions = computed(() => [
  { code: 'ROLE_USER', label: t('ROLE_USER_NAME') },
  { code: 'ROLE_APPROVER', label: t('ROLE_APPROVER_NAME') },
  { code: 'ROLE_MANAGER', label: t('ROLE_MANAGER_NAME') },
  { code: 'ROLE_ADMIN', label: t('ROLE_ADMIN_NAME') }
])

async function load() {
  loading.value = true
  try {
    const { rows, total: t } = await admin.userList({
      keyword: keyword.value || undefined,
      status: status.value || undefined,
      page: page.value,
      size: pageSize
    })
    users.value = rows
    total.value = t
  } catch (e: any) {
    toast.add({ severity: 'error', summary: t('MSG_LOAD_FAILED'), detail: e.message || String(e), life: 3000 })
  } finally {
    loading.value = false
  }
}

function onPage(e: any) {
  page.value = e.page
  first.value = e.first
  load()
}

async function loadMeta() {
  // 부서 트리에서 평면 목록
  try {
    const { flat } = await admin.deptTree()
    deptList.value = flat
  } catch (e) { /* ignore */ }
  // 직책: cm_code 활용 또는 org_position 직접 조회 — 간단히 static 으로 1~5 hardcode
  positionList.value = [
    { positionId: 1, positionName: '대표이사' },
    { positionId: 2, positionName: '본부장' },
    { positionId: 3, positionName: '팀장' },
    { positionId: 4, positionName: '과장' },
    { positionId: 5, positionName: '사원' }
  ]
}

function openCreate() {
  Object.assign(editing, {
    employeeId: undefined,
    employeeNo: '',
    employeeName: '',
    email: '',
    phone: '',
    deptId: deptList.value[0]?.deptId,
    positionId: 5,
    keycloakUserId: '',
    roles: ['ROLE_USER']
  })
  dialogVisible.value = true
}

function openEdit(u: AdminUser) {
  Object.assign(editing, {
    employeeId: u.employeeId,
    employeeNo: u.employeeNo,
    employeeName: u.employeeName,
    email: u.email || '',
    phone: u.phone || '',
    deptId: u.deptId,
    positionId: u.positionId,
    keycloakUserId: u.keycloakUserId || '',
    roles: ['ROLE_USER']
  })
  dialogVisible.value = true
}

async function onSave() {
  if (!editing.employeeName || !editing.employeeNo) {
    toast.add({ severity: 'warn', summary: t('MSG_INPUT_REQUIRED'), detail: t('MSG_USER_NAME_NO_REQ'), life: 3000 })
    return
  }
  if (!editing.deptId || !editing.positionId) {
    toast.add({ severity: 'warn', summary: t('MSG_INPUT_REQUIRED'), detail: t('MSG_USER_DEPT_POS_REQ'), life: 3000 })
    return
  }
  saving.value = true
  try {
    await admin.userSave({ ...editing })
    toast.add({ severity: 'success', summary: t('MSG_SAVE_DONE'), life: 2000 })
    dialogVisible.value = false
    await load()
  } catch (e: any) {
    toast.add({ severity: 'error', summary: t('MSG_SAVE_FAILED'), detail: e.message || String(e), life: 4000 })
  } finally {
    saving.value = false
  }
}

async function onToggle(u: AdminUser) {
  if (!u.employeeId) return
  if (!confirm(t('MSG_USER_TOGGLE_CONFIRM').replace('{name}', u.employeeName || ''))) return
  try {
    await admin.userToggleActive(u.employeeId)
    toast.add({ severity: 'success', summary: t('MSG_USER_STATUS_CHANGED'), life: 2000 })
    await load()
  } catch (e: any) {
    toast.add({ severity: 'error', summary: t('MSG_USER_STATUS_FAILED'), detail: e.message || String(e), life: 4000 })
  }
}

async function onResetPwd(u: AdminUser) {
  if (!u.employeeId) return
  if (!u.keycloakUserId) {
    toast.add({ severity: 'warn', summary: t('MSG_USER_KC_NOT_SET'), life: 3000 })
    return
  }
  if (!confirm(t('MSG_USER_RESET_PWD_CONFIRM').replace('{name}', u.employeeName || ''))) return
  try {
    const r: any = await admin.userResetPwd(u.employeeId)
    toast.add({
      severity: 'success',
      summary: t('MSG_USER_PWD_RESET'),
      detail: t('MSG_USER_TEMP_PASSWORD').replace('{pwd}', r?.temporaryPassword || 'temp123!'),
      life: 6000
    })
  } catch (e: any) {
    toast.add({ severity: 'error', summary: t('MSG_USER_PWD_RESET_FAILED'), detail: e.message || String(e), life: 4000 })
  }
}

onMounted(async () => {
  await loadMeta()
  await load()
})
</script>

<style scoped>
.page { padding: 1.5rem; }
.toolbar { display: flex; gap: 0.5rem; margin-bottom: 1rem; align-items: center; }
.form-grid { display: grid; grid-template-columns: 120px 1fr; gap: 0.75rem 1rem; align-items: center; }
.form-grid label { font-weight: 500; }
</style>
