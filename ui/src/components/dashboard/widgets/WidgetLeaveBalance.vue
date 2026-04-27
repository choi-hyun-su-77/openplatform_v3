<template>
  <div class="widget-body widget-leave">
    <header class="widget-header">
      <i class="pi pi-calendar-clock" />
      <span class="title">연차 잔여</span>
    </header>
    <div v-if="loading" class="state loading">로딩...</div>
    <div v-else-if="!balance" class="state empty">잔여 정보 없음</div>
    <div v-else class="state ready" @click="goLeave">
      <svg viewBox="0 0 100 100" class="donut">
        <circle cx="50" cy="50" r="42" class="track" />
        <circle
          cx="50" cy="50" r="42"
          class="ring"
          :stroke-dasharray="ringDashArray"
          :stroke-dashoffset="ringDashOffset"
        />
        <text x="50" y="48" class="num">{{ remainingNum }}</text>
        <text x="50" y="63" class="unit">일</text>
      </svg>
      <div class="meta">
        <div><span class="lbl">잔여</span><span class="val">{{ remainingNum }} 일</span></div>
        <div><span class="lbl">사용</span><span class="val">{{ usedNum }} 일</span></div>
        <div><span class="lbl">총</span><span class="val">{{ totalNum }} 일</span></div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { useLeave, type LeaveBalanceRow } from '@/composables/useLeave';

defineProps<{ widgetCode: string; config?: any }>();

const router = useRouter();
const leave = useLeave();
const balance = ref<LeaveBalanceRow | null>(null);
const loading = ref(false);

const totalNum     = computed(() => Number(balance.value?.totalDays ?? 0));
const usedNum      = computed(() => Number(balance.value?.usedDays ?? 0));
const remainingNum = computed(() => {
  const r = balance.value?.remaining;
  if (r != null) return Number(r);
  return Math.max(0, totalNum.value - usedNum.value);
});

const ratio = computed(() => {
  if (totalNum.value <= 0) return 0;
  return Math.min(1, Math.max(0, remainingNum.value / totalNum.value));
});

// 원주 = 2 * π * r ≈ 263.89 (r=42)
const CIRC = 2 * Math.PI * 42;
const ringDashArray  = computed(() => `${CIRC} ${CIRC}`);
const ringDashOffset = computed(() => `${CIRC * (1 - ratio.value)}`);

async function load() {
  loading.value = true;
  try {
    balance.value = await leave.searchBalance();
  } catch (e) {
    console.warn('[WidgetLeaveBalance] failed', e);
    balance.value = null;
  } finally {
    loading.value = false;
  }
}

function goLeave() {
  router.push('/leave').catch(() => {});
}

onMounted(load);
</script>

<style scoped>
.widget-leave { display: flex; flex-direction: column; height: 100%; }
.widget-header { display: flex; align-items: center; gap: 0.5rem; margin-bottom: 0.6rem; color: #475569; font-weight: 600; }
.state { flex: 1; }
.state.loading, .state.empty { display: flex; align-items: center; justify-content: center; color: #94a3b8; font-size: 0.9rem; }
.state.ready { display: flex; align-items: center; gap: 1rem; cursor: pointer; }
.donut { width: 100px; height: 100px; }
.donut .track { fill: none; stroke: #e2e8f0; stroke-width: 10; }
.donut .ring  { fill: none; stroke: #3b82f6; stroke-width: 10; transform: rotate(-90deg); transform-origin: 50% 50%; transition: stroke-dashoffset 0.5s; }
.donut .num   { font-size: 22px; font-weight: 700; text-anchor: middle; fill: #1e293b; }
.donut .unit  { font-size: 9px; text-anchor: middle; fill: #64748b; }
.meta { display: flex; flex-direction: column; gap: 0.2rem; font-size: 0.85rem; }
.meta .lbl { color: #64748b; min-width: 2.5rem; display: inline-block; }
.meta .val { color: #1e293b; font-weight: 600; }
</style>
