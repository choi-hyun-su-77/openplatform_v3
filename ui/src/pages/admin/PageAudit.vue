<template>
  <div class="page">
    <h2>감사 로그</h2>
    <div class="toolbar">
      <InputText v-model="filter.actorNo" placeholder="작업자 사번" @keyup.enter="load" />
      <InputText v-model="filter.action" placeholder="액션 (예: admin/userSave)" @keyup.enter="load" />
      <DatePicker v-model="dateRange" selectionMode="range" :manualInput="false"
                  dateFormat="yy-mm-dd" placeholder="기간" showIcon />
      <Button label="검색" icon="pi pi-search" @click="load" />
      <Button label="초기화" icon="pi pi-refresh" severity="secondary" @click="reset" />
    </div>

    <DataTable :value="rows" :rowHover="true" paginator :rows="pageSize"
               :totalRecords="total" :lazy="true" :first="first"
               @page="onPage" :loading="loading"
               selectionMode="single" v-model:selection="selectedRow"
               @row-click="(e) => openDetail(e.data)" dataKey="auditId">
      <Column field="auditId" header="ID" style="width:80px" />
      <Column header="작업시각" style="width:170px">
        <template #body="{ data }">{{ formatDate(data.actedAt) }}</template>
      </Column>
      <Column field="actorNo" header="작업자" style="width:100px" />
      <Column field="actorName" header="이름" style="width:110px" />
      <Column field="action" header="액션" style="width:200px">
        <template #body="{ data }">
          <Tag :value="data.action" severity="info" />
        </template>
      </Column>
      <Column field="targetType" header="대상유형" style="width:100px" />
      <Column field="targetId" header="대상ID" style="width:100px" />
      <Column field="ipAddr" header="IP" style="width:120px" />
    </DataTable>

    <Dialog v-model:visible="detailVisible" header="감사 로그 상세" modal style="width:760px">
      <div v-if="detailRow" class="detail">
        <div class="detail-row"><label>ID</label><span>{{ detailRow.auditId }}</span></div>
        <div class="detail-row"><label>시각</label><span>{{ formatDate(detailRow.actedAt) }}</span></div>
        <div class="detail-row"><label>작업자</label><span>{{ detailRow.actorName }} ({{ detailRow.actorNo }})</span></div>
        <div class="detail-row"><label>액션</label><span><Tag :value="detailRow.action" severity="info" /></span></div>
        <div class="detail-row"><label>대상</label><span>{{ detailRow.targetType }} / {{ detailRow.targetId || '-' }}</span></div>
        <div class="detail-row"><label>IP</label><span>{{ detailRow.ipAddr || '-' }}</span></div>
        <div class="detail-row"><label>입력 (before)</label></div>
        <pre class="json">{{ formatJson(detailRow.beforeJson) }}</pre>
        <div class="detail-row"><label>결과 (after)</label></div>
        <pre class="json">{{ formatJson(detailRow.afterJson) }}</pre>
      </div>
    </Dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import DataTable from 'primevue/datatable'
import Column from 'primevue/column'
import InputText from 'primevue/inputtext'
import Button from 'primevue/button'
import Tag from 'primevue/tag'
import Dialog from 'primevue/dialog'
import DatePicker from 'primevue/datepicker'
import { useToast } from 'primevue/usetoast'
import { useAdmin, type AdminAuditRow } from '@/composables/useAdmin'

const admin = useAdmin()
const toast = useToast()

const filter = reactive({
  actorNo: '',
  action: ''
})
const dateRange = ref<Date[] | null>(null)
const rows = ref<AdminAuditRow[]>([])
const total = ref(0)
const loading = ref(false)
const pageSize = 30
const page = ref(0)
const first = ref(0)
const selectedRow = ref<AdminAuditRow | null>(null)

const detailVisible = ref(false)
const detailRow = ref<AdminAuditRow | null>(null)

function fmtDate(d?: Date | null): string | undefined {
  if (!d) return undefined
  const y = d.getFullYear()
  const m = String(d.getMonth() + 1).padStart(2, '0')
  const dd = String(d.getDate()).padStart(2, '0')
  return `${y}-${m}-${dd}`
}

async function load() {
  loading.value = true
  try {
    const fromDate = dateRange.value && dateRange.value[0] ? fmtDate(dateRange.value[0]) : undefined
    const toDate = dateRange.value && dateRange.value[1] ? fmtDate(dateRange.value[1]) : undefined
    const res = await admin.auditSearch({
      actorNo: filter.actorNo || undefined,
      action: filter.action || undefined,
      fromDate,
      toDate,
      page: page.value,
      size: pageSize
    })
    rows.value = res.rows
    total.value = res.total
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

function reset() {
  filter.actorNo = ''
  filter.action = ''
  dateRange.value = null
  page.value = 0
  first.value = 0
  load()
}

function openDetail(row: AdminAuditRow) {
  detailRow.value = row
  detailVisible.value = true
}

function formatDate(s: string): string {
  if (!s) return '-'
  try {
    const d = new Date(s)
    return d.toLocaleString('ko-KR', { hour12: false })
  } catch { return s }
}

function formatJson(v: any): string {
  if (v == null) return '(없음)'
  try {
    if (typeof v === 'string') {
      // JSONB 가 문자열로 직렬화되어 도착할 수도 있고 객체일 수도 있음
      try { return JSON.stringify(JSON.parse(v), null, 2) }
      catch { return v }
    }
    return JSON.stringify(v, null, 2)
  } catch {
    return String(v)
  }
}

onMounted(load)
</script>

<style scoped>
.page { padding: 1.5rem; }
.toolbar { display: flex; gap: 0.5rem; margin-bottom: 1rem; align-items: center; flex-wrap: wrap; }
.detail-row { display: grid; grid-template-columns: 110px 1fr; gap: 0.5rem; margin-bottom: 0.5rem; }
.detail-row label { font-weight: 600; color: var(--p-text-muted-color); }
.json { background: var(--p-content-background); border: 1px solid var(--p-content-border-color); border-radius: 4px; padding: 0.5rem; font-size: 0.78rem; max-height: 200px; overflow: auto; white-space: pre-wrap; }
</style>
