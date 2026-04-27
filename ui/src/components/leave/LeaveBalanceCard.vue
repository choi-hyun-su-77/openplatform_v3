<!--
  LeaveBalanceCard.vue — 잔여/사용/총 + Donut 시각화 (SVG 두 원으로 구현, 외부 라이브러리 없음).

  Props:
    balance  LeaveBalanceRow

  표시:
    - 큰 숫자: 잔여 (remaining)
    - 작은 숫자: total / used / carryOver
    - Donut: 사용 비율
-->
<template>
  <div class="balance-card">
    <div class="donut-area">
      <svg :width="size" :height="size" viewBox="0 0 100 100" class="donut">
        <!-- 배경 원 -->
        <circle cx="50" cy="50" :r="radius"
                fill="none" stroke="#e2e8f0" :stroke-width="thickness" />
        <!-- 사용량 호 -->
        <circle cx="50" cy="50" :r="radius"
                fill="none" stroke="#3b82f6" :stroke-width="thickness"
                :stroke-dasharray="dashArray"
                :stroke-dashoffset="0"
                stroke-linecap="round"
                transform="rotate(-90 50 50)" />
      </svg>
      <div class="donut-center">
        <div class="big">{{ formatNum(remaining) }}</div>
        <div class="unit">잔여일</div>
      </div>
    </div>

    <div class="meta">
      <div class="row">
        <span class="label">부여</span>
        <span class="value">{{ formatNum(totalDays) }}일</span>
      </div>
      <div class="row">
        <span class="label">이월</span>
        <span class="value">{{ formatNum(carryOver) }}일</span>
      </div>
      <div class="row used">
        <span class="label"><i class="dot" /> 사용</span>
        <span class="value">{{ formatNum(usedDays) }}일</span>
      </div>
      <div class="row remain">
        <span class="label">잔여</span>
        <span class="value strong">{{ formatNum(remaining) }}일</span>
      </div>
      <div v-if="year" class="year-tag">{{ year }}년</div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import type { LeaveBalanceRow } from '@/composables/useLeave';

const props = withDefaults(defineProps<{
  balance: LeaveBalanceRow | null;
  size?: number;
}>(), {
  size: 140
});

const radius = 42;
const thickness = 12;
const circumference = 2 * Math.PI * radius;

const totalDays = computed(() => Number(props.balance?.totalDays ?? 0));
const usedDays = computed(() => Number(props.balance?.usedDays ?? 0));
const carryOver = computed(() => Number(props.balance?.carryOver ?? 0));
const remaining = computed(() => {
  if (props.balance?.remaining != null) return Number(props.balance.remaining);
  return totalDays.value + carryOver.value - usedDays.value;
});
const year = computed(() => props.balance?.year ?? null);

const ratio = computed(() => {
  const denom = totalDays.value + carryOver.value;
  if (denom <= 0) return 0;
  const r = usedDays.value / denom;
  return Math.max(0, Math.min(1, r));
});

const dashArray = computed(() => {
  const used = circumference * ratio.value;
  return `${used.toFixed(2)} ${(circumference - used).toFixed(2)}`;
});

function formatNum(n: number) {
  if (Number.isNaN(n)) return '-';
  return Number.isInteger(n) ? String(n) : n.toFixed(1);
}
</script>

<style scoped>
.balance-card {
  display: flex;
  align-items: center;
  gap: 1.25rem;
  padding: 1.25rem;
  background: var(--p-content-background, #fff);
  border: 1px solid var(--p-content-border-color, #e2e8f0);
  border-radius: 10px;
}
.donut-area {
  position: relative;
  flex: 0 0 auto;
}
.donut { display: block; }
.donut-center {
  position: absolute;
  inset: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  pointer-events: none;
}
.donut-center .big {
  font-size: 1.6rem;
  font-weight: 700;
  color: #1e40af;
  line-height: 1;
}
.donut-center .unit {
  font-size: 0.72rem;
  color: #64748b;
  margin-top: 4px;
}

.meta {
  flex: 1 1 auto;
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
  position: relative;
}
.meta .row {
  display: flex;
  justify-content: space-between;
  font-size: 0.875rem;
  color: #475569;
}
.meta .row .label { color: #64748b; }
.meta .row .value { font-weight: 500; }
.meta .row.used .label { color: #3b82f6; }
.meta .row.used .label .dot {
  display: inline-block;
  width: 8px; height: 8px;
  background: #3b82f6;
  border-radius: 2px;
  margin-right: 4px;
  vertical-align: middle;
}
.meta .row.remain .value.strong {
  color: #1e40af;
  font-weight: 700;
  font-size: 1rem;
}
.year-tag {
  position: absolute;
  top: 0; right: 0;
  font-size: 0.72rem;
  color: #94a3b8;
}
</style>
