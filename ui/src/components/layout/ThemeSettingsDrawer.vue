<!--
  테마 설정 Drawer (ThemeSettingsDrawer)

  [용도]
  - 헤더의 기어 아이콘 클릭 시 우측에서 슬라이드로 열리는 설정 패널
  - Primary 컬러, 프리셋, 다크모드, 밀도, 보더 라운드, 사이드바 스타일, 레이아웃 모드를 한 곳에서 설정
  - 모든 변경은 즉시 적용 + localStorage에 자동 저장

  [Props]
  - visible: boolean — Drawer 표시 여부 (v-model)

  [설정 항목]
  - Primary 컬러: 10색 원형 팔레트 (blue, green, purple, orange, teal, rose, indigo, amber, cyan, emerald)
  - 프리셋: Aura / Lara / Nora / Material 카드 선택
  - 다크 모드: 해/달 아이콘 토글
  - 밀도: Compact / Default / Comfortable 3단계
  - 보더 라운드: Sharp / Soft / Round / Pill 4단계
  - 사이드바 스타일: Default / Colored / Glass / Minimal
  - 레이아웃: Sidebar / TopNav
-->
<template>
  <Drawer
    :visible="visible"
    @update:visible="$emit('update:visible', $event)"
    position="right"
    :header="t('LBL_THEME_SETTINGS', '테마 설정')"
    style="width: 320px"
    class="theme-drawer"
  >
    <div class="theme-sections">

      <!-- ─── Primary 컬러 ─── -->
      <div class="theme-section">
        <div class="section-label">{{ t('LBL_PRIMARY_COLOR', 'Primary 컬러') }}</div>
        <div class="color-palette">
          <button
            v-for="c in primaryColors"
            :key="c.name"
            class="color-swatch"
            :class="{ active: primaryColor === c.name }"
            :style="{ backgroundColor: c.hex }"
            @click="setPrimaryColor(c.name)"
            v-tooltip.bottom="c.name"
          >
            <i v-if="primaryColor === c.name" class="pi pi-check" style="color:#fff;font-size:11px"></i>
          </button>
        </div>
      </div>

      <!-- ─── 테마 프리셋 ─── -->
      <div class="theme-section">
        <div class="section-label">{{ t('LBL_PRESET', '테마 프리셋') }}</div>
        <div class="preset-grid">
          <button
            v-for="name in presetNames"
            :key="name"
            class="preset-card"
            :class="{ active: currentPreset === name }"
            @click="applyPreset(name)"
          >
            {{ name }}
          </button>
        </div>
      </div>

      <!-- ─── 다크 모드 ─── -->
      <div class="theme-section">
        <div class="section-label">{{ t('LBL_DARK_MODE', '다크 모드') }}</div>
        <div class="toggle-row">
          <button
            class="mode-btn"
            :class="{ active: !isDark }"
            @click="isDark && toggleDark()"
          >
            <i class="pi pi-sun"></i> Light
          </button>
          <button
            class="mode-btn"
            :class="{ active: isDark }"
            @click="!isDark && toggleDark()"
          >
            <i class="pi pi-moon"></i> Dark
          </button>
        </div>
      </div>

      <!-- ─── UI 밀도 ─── -->
      <div class="theme-section">
        <div class="section-label">{{ t('LBL_DENSITY', 'UI 밀도') }}</div>
        <div class="toggle-row three">
          <button
            v-for="d in densityOptions"
            :key="d.value"
            class="mode-btn"
            :class="{ active: density === d.value }"
            @click="setDensity(d.value)"
          >
            {{ d.label }}
          </button>
        </div>
      </div>

      <!-- ─── 보더 라운드 ─── -->
      <div class="theme-section">
        <div class="section-label">{{ t('LBL_BORDER_RADIUS', '보더 라운드') }}</div>
        <div class="toggle-row four">
          <button
            v-for="r in radiusOptions"
            :key="r.value"
            class="mode-btn"
            :class="{ active: borderRadius === r.value }"
            @click="setBorderRadius(r.value)"
          >
            <span class="radius-preview" :style="{ borderRadius: r.preview }"></span>
            {{ r.label }}
          </button>
        </div>
      </div>

      <!-- ─── 사이드바 스타일 ─── -->
      <div class="theme-section" v-if="layoutMode === 'sidebar'">
        <div class="section-label">{{ t('LBL_SIDEBAR_STYLE', '사이드바 스타일') }}</div>
        <div class="toggle-row two-col">
          <button
            v-for="s in sidebarOptions"
            :key="s.value"
            class="mode-btn"
            :class="{ active: sidebarStyle === s.value }"
            @click="setSidebarStyle(s.value)"
          >
            {{ s.label }}
          </button>
        </div>
      </div>

      <!-- ─── 레이아웃 모드 ─── -->
      <div class="theme-section">
        <div class="section-label">{{ t('LBL_LAYOUT_MODE', '레이아웃 모드') }}</div>
        <div class="toggle-row">
          <button
            class="mode-btn"
            :class="{ active: layoutMode === 'sidebar' }"
            @click="setLayoutMode('sidebar')"
          >
            <i class="pi pi-objects-column"></i> Sidebar
          </button>
          <button
            class="mode-btn"
            :class="{ active: layoutMode === 'topnav' }"
            @click="setLayoutMode('topnav')"
          >
            <i class="pi pi-th-large"></i> TopNav
          </button>
        </div>
      </div>

    </div>
  </Drawer>
</template>

<script setup lang="ts">
/**
 * 테마 설정 Drawer — 모든 디자인 옵션을 한 곳에서 설정
 *
 * useTheme 컴포저블의 모든 설정 함수를 직접 호출하여
 * 즉시 반영 + localStorage 자동 저장
 */
import Drawer from 'primevue/drawer'
import { useTheme, primaryColors, type PrimaryColor, type Density, type BorderRadius, type SidebarStyle } from '@/composables/useTheme'
import { t } from '@/composables/useLabel'

/** Drawer 표시 여부 (v-model) */
defineProps<{ visible: boolean }>()
defineEmits<{ 'update:visible': [value: boolean] }>()

const {
  currentPreset, isDark, layoutMode, primaryColor, density, borderRadius, sidebarStyle,
  presetNames, applyPreset, toggleDark, setLayoutMode,
  setPrimaryColor, setDensity, setBorderRadius, setSidebarStyle
} = useTheme()

/** 밀도 옵션 */
const densityOptions: { value: Density; label: string }[] = [
  { value: 'compact', label: 'Compact' },
  { value: 'default', label: 'Default' },
  { value: 'comfortable', label: 'Comfortable' }
]

/** 보더 라운드 옵션 */
const radiusOptions: { value: BorderRadius; label: string; preview: string }[] = [
  { value: 'sharp', label: 'Sharp', preview: '0px' },
  { value: 'soft',  label: 'Soft',  preview: '4px' },
  { value: 'round', label: 'Round', preview: '8px' },
  { value: 'pill',  label: 'Pill',  preview: '16px' }
]

/** 사이드바 스타일 옵션 */
const sidebarOptions: { value: SidebarStyle; label: string }[] = [
  { value: 'default', label: 'Default' },
  { value: 'colored', label: 'Colored' },
  { value: 'glass',   label: 'Glass' },
  { value: 'minimal', label: 'Minimal' }
]
</script>

<style scoped>
/* ─── Drawer 내부 섹션 ─── */
.theme-sections {
  display: flex;
  flex-direction: column;
  gap: 20px;
  padding: 4px 0;
}

.theme-section {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.section-label {
  font-size: 12px;
  font-weight: 600;
  color: var(--p-text-muted-color);
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

/* ─── 컬러 팔레트 (원형 스와치) ─── */
.color-palette {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.color-swatch {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  border: 2px solid transparent;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.15s;
}

.color-swatch:hover {
  transform: scale(1.15);
}

.color-swatch.active {
  border-color: var(--p-text-color);
  box-shadow: 0 0 0 2px var(--p-content-background), 0 0 0 4px var(--p-text-muted-color);
}

/* ─── 프리셋 그리드 ─── */
.preset-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 6px;
}

.preset-card {
  padding: 8px 12px;
  border: 1px solid color-mix(in srgb, var(--p-text-color) 15%, transparent);
  border-radius: var(--app-border-radius, 4px);
  background: color-mix(in srgb, var(--p-text-color) 5%, var(--p-content-background));
  color: var(--p-text-color);
  cursor: pointer;
  font-size: 13px;
  font-weight: 500;
  text-align: center;
  transition: all 0.15s;
}

.preset-card:hover {
  background: color-mix(in srgb, var(--p-text-color) 10%, var(--p-content-background));
}

.preset-card.active {
  border-color: var(--p-primary-color);
  background: color-mix(in srgb, var(--p-primary-color) 18%, var(--p-content-background));
  color: var(--p-primary-color);
  font-weight: 600;
}

/* ─── 토글 행 (2버튼) ─── */
.toggle-row {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 6px;
}

.toggle-row.three {
  grid-template-columns: repeat(3, 1fr);
}

.toggle-row.four {
  grid-template-columns: repeat(4, 1fr);
}

.toggle-row.two-col {
  grid-template-columns: repeat(2, 1fr);
}

.mode-btn {
  padding: 8px 6px;
  border: 1px solid color-mix(in srgb, var(--p-text-color) 15%, transparent);
  border-radius: var(--app-border-radius, 4px);
  background: color-mix(in srgb, var(--p-text-color) 5%, var(--p-content-background));
  color: var(--p-text-color);
  cursor: pointer;
  font-size: 12px;
  font-weight: 500;
  text-align: center;
  transition: all 0.15s;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 4px;
}

.mode-btn:hover {
  background: color-mix(in srgb, var(--p-text-color) 10%, var(--p-content-background));
}

.mode-btn.active {
  border-color: var(--p-primary-color);
  background: color-mix(in srgb, var(--p-primary-color) 18%, var(--p-content-background));
  color: var(--p-primary-color);
  font-weight: 600;
  box-shadow: 0 0 0 1px color-mix(in srgb, var(--p-primary-color) 30%, transparent);
}

/* ─── 보더 라운드 미리보기 ─── */
.radius-preview {
  display: inline-block;
  width: 14px;
  height: 14px;
  border: 2px solid currentColor;
  flex-shrink: 0;
}
</style>
