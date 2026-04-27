<template>
  <div class="page">
    <h2>사용자 관리</h2>
    <div class="toolbar">
      <InputText v-model="keyword" placeholder="이름/사번/이메일 검색" @keyup.enter="load" />
      <Select v-model="status" :options="statusOptions" optionLabel="label" optionValue="code"
              placeholder="상태" showClear @change="load" />
      <Button label="검색" icon="pi pi-search" @click="load" />
      <Button label="추가" icon="pi pi-plus" severity="success" @click="openCreate" />
    </div>

    <DataTable :value="users" :rowHover="true" paginator :rows="pageSize"
               :totalRecords="total" :lazy="true"
               :first="first"
               @page="onPage"
               :loading="loading"
               selectionMode="single" v-model:selection="selectedRow"
               @row-click="(e) => openEdit(e.data)" dataKey="employeeId">
      <Column field="employeeNo" header="사번" style="width:100px" />
      <Column field="employeeName" header="이름" style="width:120px" />
      <Column field="deptName" header="부서" style="width:140px" />
      <Column field="positionName" header="직책" style="width:100px" />
      <Column field="email" header="이메일" />
      <Column field="keycloakUserId" header="KC username" style="width:120px" />
      <Column field="status" header="상태" style="width:90px">
        <template #body="{ data }">
          <Tag :value="data.status" :severity="data.status === 'ACTIVE' ? 'success' : 'danger'" />
        </template>
      </Column>
      <Column header="작업" style="width:200px">
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
    <Dialog v-model:visible="dialogVisible" :header="editing.employeeId ? '사용자 수정' : '사용자 추가'"
            modal style="width:560px">
      <div class="form-grid">
        <label>이름 *</label>
        <InputText v-model="editing.employeeName" />
        <label>사번 *</label>
        <InputText v-model="editing.employeeNo" :disabled="!!editing.employeeId" />
        <label>이메일</label>
        <InputText v-model="editing.email" />
        <label>전화</label>
        <InputText v-model="editing.phone" />
        <label>부서 *</label>
        <Select v-model="editing.deptId" :options="deptList" optionLabel="deptName" optionValue="deptId"
                placeholder="부서 선택" />
        <label>직책 *</label>
        <Select v-model="editing.positionId" :options="positionList" optionLabel="positionName" optionValue="positionId"
                placeholder="직책 선택" />
        <label>Keycloak username</label>
        <InputText v-model="editing.keycloakUserId" />
        <label>역할</label>
        <MultiSelect v-model="editing.roles" :options="roleOptions" optionLabel="label" optionValue="code"
                     placeholder="역할 선택" />
      </div>
      <template #footer>
        <Button label="취소" severity="secondary" text @click="dialogVisible = false" />
        <Button label="저장" icon="pi pi-check" @click="onSave" :loading="saving" />
      </template>
    </Dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, reactive } from 'vue'
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

const admin = useAdmin()
const toast = useToast()

const keyword = ref('')
const status = ref<string | null>(null)
const statusOptions = [
  { code: 'ACTIVE', label: '활성' },
  { code: 'INACTIVE', label: '비활성' }
]

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
const roleOptions = [
  { code: 'ROLE_USER', label: '일반 사용자' },
  { code: 'ROLE_APPROVER', label: '결재자' },
  { code: 'ROLE_MANAGER', label: '부서장' },
  { code: 'ROLE_ADMIN', label: '관리자' }
]

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
    toast.add({ severity: 'error', summary: '조회 실패', detail: e.message || String(e), life: 3000 })
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
    toast.add({ severity: 'warn', summary: '입력 필요', detail: '이름/사번은 필수입니다.', life: 3000 })
    return
  }
  if (!editing.deptId || !editing.positionId) {
    toast.add({ severity: 'warn', summary: '입력 필요', detail: '부서/직책을 선택하세요.', life: 3000 })
    return
  }
  saving.value = true
  try {
    await admin.userSave({ ...editing })
    toast.add({ severity: 'success', summary: '저장 완료', life: 2000 })
    dialogVisible.value = false
    await load()
  } catch (e: any) {
    toast.add({ severity: 'error', summary: '저장 실패', detail: e.message || String(e), life: 4000 })
  } finally {
    saving.value = false
  }
}

async function onToggle(u: AdminUser) {
  if (!u.employeeId) return
  if (!confirm(`'${u.employeeName}'의 활성 상태를 토글합니다.`)) return
  try {
    await admin.userToggleActive(u.employeeId)
    toast.add({ severity: 'success', summary: '상태 변경됨', life: 2000 })
    await load()
  } catch (e: any) {
    toast.add({ severity: 'error', summary: '변경 실패', detail: e.message || String(e), life: 4000 })
  }
}

async function onResetPwd(u: AdminUser) {
  if (!u.employeeId) return
  if (!u.keycloakUserId) {
    toast.add({ severity: 'warn', summary: 'Keycloak username 미설정', life: 3000 })
    return
  }
  if (!confirm(`'${u.employeeName}'의 비밀번호를 임시 비밀번호로 초기화합니다.`)) return
  try {
    const r: any = await admin.userResetPwd(u.employeeId)
    toast.add({
      severity: 'success',
      summary: '비밀번호 초기화',
      detail: `임시 비밀번호: ${r?.temporaryPassword || 'temp123!'}`,
      life: 6000
    })
  } catch (e: any) {
    toast.add({ severity: 'error', summary: '초기화 실패', detail: e.message || String(e), life: 4000 })
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
