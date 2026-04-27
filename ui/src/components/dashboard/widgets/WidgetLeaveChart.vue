<template>
  <div class="widget-body widget-leave-chart">
    <header class="widget-header">
      <i class="pi pi-chart-bar" />
      <span class="title">연차 사용 추이</span>
      <small class="year">{{ year }}</small>
    </header>
    <div v-if="loading" class="state loading">로딩...</div>
    <svg v-else class="chart" :viewBox="`0 0 ${chartW} ${chartH}`" preserveAspectRatio="none">
      <!-- y axis grid -->
      <line v-for="g in gridLines" :key="'g'+g.y"
            :x1="0" :x2="chartW" :y1="g.y" :y2="g.y"
            stroke="#e2e8f0" stroke-dasharray="2 3" />
      <!-- bars -->
      <g v-for="(b, i) in bars" :key="'b'+i">
        <rect
          :x="b.x" :y="b.y" :width="b.w" :height="b.h"
          :fill="b.value > 0 ? '#3b82f6' : '#e2e8f0'"
          rx="2"
        />
        <text v-if="b.value > 0"
              :x="b.x + b.w / 2" :y="b.y - 2"
              text-anchor="middle" font-size="9" fill="#64748b">
          {{ b.value }}
        </text>
        <text :x="b.x + b.w / 2" :y="chartH - 2"
              text-anchor="middle" font-size="9" fill="#94a3b8">
          {{ b.label }}
        </text>
      </g>
    </svg>
    <div class="legend">
      <span class="lbl">총 사용</span>
      <span class="val">{{ totalUsed }}일</span>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { useLeave, type LeaveRequestRow } from '@/composables/useLeave';

defineProps<{ widgetCode: string; config?: any }>();

const leave = useLeave();
const year = ref(new Date().getFullYear());
const history = ref<LeaveRequestRow[]>([]);
const loading = ref(false);

const chartW = 280;
const chartH = 110;
const padTop = 14;
const padBot = 16;

interface MonthBar { x: number; y: number; w: number; h: number; label: string; value: number; }

const monthlyTotals = computed<number[]>(() => {
  const arr = new Array(12).fill(0);
  for (const r of history.value) {
    if (r.status && r.status !== 'APPROVED' && r.status !== 'COMPLETED') continue;
    if (!r.fromDate) continue;
    try {
      const d = new Date(r.fromDate);
      if (d.getFullYear() === year.value) {
        arr[d.getMonth()] += Number(r.days || 0);
      }
    } catch { /* ignore */ }
  }
  return arr;
});

const totalUsed = computed(() =>
  monthlyTotals.value.reduce((a, b) => a + b, 0).toFixed(1).replace(/\.0$/, '')
);

const bars = computed<MonthBar[]>(() => {
  const data = monthlyTotals.value;
  const max = Math.max(1, ...data);
  const usableH = chartH - padTop - padBot;
  const slot = chartW / 12;
  const barW = Math.max(8, slot * 0.62);
  return data.map((v, i) => {
    const h = (v / max) * usableH;
    return {
      x: i * slot + (slot - barW) / 2,
      y: padTop + (usableH - h),
      w: barW,
      h,
      label: String(i + 1),
      value: v
    };
  });
});

const gridLines = computed(() => {
  const usableH = chartH - padTop - padBot;
  return [0, 0.5, 1].map(p => ({ y: padTop + usableH * p }));
});

async function load() {
  loading.value = true;
  try {
    history.value = await leave.searchMyHistory(year.value);
  } catch (e) {
    console.warn('[WidgetLeaveChart] failed', e);
    history.value = [];
  } finally {
    loading.value = false;
  }
}

onMounted(load);
</script>

<style scoped>
.widget-leave-chart { display: flex; flex-direction: column; height: 100%; }
.widget-header { display: flex; align-items: center; gap: 0.5rem; margin-bottom: 0.4rem; color: #475569; font-weight: 600; }
.year { margin-left: auto; color: #94a3b8; font-size: 0.8rem; font-weight: normal; }
.state { flex: 1; display: flex; align-items: center; justify-content: center; color: #94a3b8; font-size: 0.9rem; }
.chart { flex: 1; width: 100%; max-height: 200px; }
.legend { display: flex; justify-content: flex-end; gap: 0.5rem; font-size: 0.8rem; padding-top: 0.2rem; border-top: 1px solid #f1f5f9; margin-top: 0.2rem; }
.legend .lbl { color: #64748b; }
.legend .val { color: #1e293b; font-weight: 700; }
</style>
