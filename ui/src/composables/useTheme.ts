/**
 * ============================================================================
 * useTheme.ts — PrimeVue 테마/다크모드/디자인 설정 관리 컴포저블
 * ============================================================================
 *
 * 【역할】
 *   PrimeVue 4의 테마 프리셋(Aura, Lara, Nora, Material)을 동적으로 전환하고,
 *   다크 모드, Primary 컬러, UI 밀도, 보더 라운드, 사이드바 스타일을 설정할 수 있다.
 *   모든 설정은 localStorage에 저장되어 새로고침 후에도 유지된다.
 *
 * 【설정 항목】
 *   1. 프리셋      — Aura, Lara, Nora, Material
 *   2. 다크 모드   — 라이트 / 다크
 *   3. Primary 컬러 — blue, green, purple, orange, teal, rose, indigo, amber, cyan, emerald
 *   4. UI 밀도     — compact, default, comfortable
 *   5. 보더 라운드 — sharp(0), soft(4px), round(8px), pill(16px)
 *   6. 사이드바    — default, colored, glass, minimal
 *   7. 레이아웃    — sidebar, topnav
 *
 * 【사용 예시】
 *   const theme = useTheme()
 *   theme.init()
 *   theme.setPrimaryColor('purple')
 *   theme.setDensity('compact')
 */

import { ref, computed } from 'vue'
import { usePrimeVue } from 'primevue/config'
import { definePreset } from '@primeuix/themes'
import Aura from '@primevue/themes/aura'
import Lara from '@primevue/themes/lara'
import Nora from '@primevue/themes/nora'
import Material from '@primevue/themes/material'

/** 지원하는 PrimeVue 테마 프리셋 이름 */
export type PresetName = 'Aura' | 'Lara' | 'Nora' | 'Material'

/** Primary 컬러 팔레트 */
export type PrimaryColor = 'blue' | 'green' | 'purple' | 'orange' | 'teal' | 'rose' | 'indigo' | 'amber' | 'cyan' | 'emerald'

/** UI 밀도 */
export type Density = 'compact' | 'default' | 'comfortable'

/** 보더 라운드 */
export type BorderRadius = 'sharp' | 'soft' | 'round' | 'pill'

/** 사이드바 스타일 */
export type SidebarStyle = 'default' | 'colored' | 'glass' | 'minimal'

/** 레이아웃 모드 */
export type LayoutMode = 'sidebar' | 'topnav'

/** 프리셋 이름 → 실제 프리셋 객체 매핑 */
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const presetMap: Record<PresetName, any> = { Aura, Lara, Nora, Material }

/** Primary 컬러 팔레트 정의 — PrimeVue semantic 토큰 오버라이드용 */
const colorPalettes: Record<PrimaryColor, Record<string, string>> = {
  blue:    { '50': '#eff6ff', '100': '#dbeafe', '200': '#bfdbfe', '300': '#93c5fd', '400': '#60a5fa', '500': '#3b82f6', '600': '#2563eb', '700': '#1d4ed8', '800': '#1e40af', '900': '#1e3a8a', '950': '#172554' },
  green:   { '50': '#f0fdf4', '100': '#dcfce7', '200': '#bbf7d0', '300': '#86efac', '400': '#4ade80', '500': '#22c55e', '600': '#16a34a', '700': '#15803d', '800': '#166534', '900': '#14532d', '950': '#052e16' },
  purple:  { '50': '#faf5ff', '100': '#f3e8ff', '200': '#e9d5ff', '300': '#d8b4fe', '400': '#c084fc', '500': '#a855f7', '600': '#9333ea', '700': '#7e22ce', '800': '#6b21a8', '900': '#581c87', '950': '#3b0764' },
  orange:  { '50': '#fff7ed', '100': '#ffedd5', '200': '#fed7aa', '300': '#fdba74', '400': '#fb923c', '500': '#f97316', '600': '#ea580c', '700': '#c2410c', '800': '#9a3412', '900': '#7c2d12', '950': '#431407' },
  teal:    { '50': '#f0fdfa', '100': '#ccfbf1', '200': '#99f6e4', '300': '#5eead4', '400': '#2dd4bf', '500': '#14b8a6', '600': '#0d9488', '700': '#0f766e', '800': '#115e59', '900': '#134e4a', '950': '#042f2e' },
  rose:    { '50': '#fff1f2', '100': '#ffe4e6', '200': '#fecdd3', '300': '#fda4af', '400': '#fb7185', '500': '#f43f5e', '600': '#e11d48', '700': '#be123c', '800': '#9f1239', '900': '#881337', '950': '#4c0519' },
  indigo:  { '50': '#eef2ff', '100': '#e0e7ff', '200': '#c7d2fe', '300': '#a5b4fc', '400': '#818cf8', '500': '#6366f1', '600': '#4f46e5', '700': '#4338ca', '800': '#3730a3', '900': '#312e81', '950': '#1e1b4b' },
  amber:   { '50': '#fffbeb', '100': '#fef3c7', '200': '#fde68a', '300': '#fcd34d', '400': '#fbbf24', '500': '#f59e0b', '600': '#d97706', '700': '#b45309', '800': '#92400e', '900': '#78350f', '950': '#451a03' },
  cyan:    { '50': '#ecfeff', '100': '#cffafe', '200': '#a5f3fc', '300': '#67e8f9', '400': '#22d3ee', '500': '#06b6d4', '600': '#0891b2', '700': '#0e7490', '800': '#155e75', '900': '#164e63', '950': '#083344' },
  emerald: { '50': '#ecfdf5', '100': '#d1fae5', '200': '#a7f3d0', '300': '#6ee7b7', '400': '#34d399', '500': '#10b981', '600': '#059669', '700': '#047857', '800': '#065f46', '900': '#064e3b', '950': '#022c22' }
}

/** 밀도별 CSS 변수 */
const densityMap: Record<Density, { fontSize: string; inputPadding: string; cellPadding: string }> = {
  compact:     { fontSize: '12.5px', inputPadding: '0.35rem 0.5rem',   cellPadding: '0.3rem 0.6rem' },
  default:     { fontSize: '14px',   inputPadding: '0.5rem 0.75rem',   cellPadding: '0.5rem 0.75rem' },
  comfortable: { fontSize: '15px',   inputPadding: '0.625rem 0.875rem', cellPadding: '0.65rem 0.9rem' }
}

/** 보더 라운드별 값 */
const radiusMap: Record<BorderRadius, string> = {
  sharp: '0px', soft: '4px', round: '8px', pill: '16px'
}

/** localStorage 저장 키 */
const STORAGE_KEY = 'app-theme'

/** 테마 설정 인터페이스 */
interface ThemeSettings {
  preset: PresetName
  dark: boolean
  layoutMode: LayoutMode
  primaryColor: PrimaryColor
  density: Density
  borderRadius: BorderRadius
  sidebarStyle: SidebarStyle
}

/** 기본 설정 */
const defaultSettings: ThemeSettings = {
  preset: 'Aura', dark: false, layoutMode: 'sidebar',
  primaryColor: 'blue', density: 'default', borderRadius: 'soft', sidebarStyle: 'default'
}

/** localStorage에서 저장된 설정 로드 */
function loadSaved(): ThemeSettings {
  try {
    const raw = localStorage.getItem(STORAGE_KEY)
    if (raw) return { ...defaultSettings, ...JSON.parse(raw) }
  } catch { /* 기본값 사용 */ }
  return { ...defaultSettings }
}

const saved = loadSaved()

/** 반응형 상태 */
const currentPreset = ref<PresetName>(saved.preset)
const isDark = ref(saved.dark)
const layoutMode = ref<LayoutMode>(saved.layoutMode)
const primaryColor = ref<PrimaryColor>(saved.primaryColor)
const density = ref<Density>(saved.density)
const borderRadius = ref<BorderRadius>(saved.borderRadius)
const sidebarStyle = ref<SidebarStyle>(saved.sidebarStyle)

/** Primary 컬러 목록 (UI 팔레트용) */
export const primaryColors: { name: PrimaryColor; hex: string }[] = [
  { name: 'blue',    hex: '#3b82f6' },
  { name: 'green',   hex: '#22c55e' },
  { name: 'purple',  hex: '#a855f7' },
  { name: 'orange',  hex: '#f97316' },
  { name: 'teal',    hex: '#14b8a6' },
  { name: 'rose',    hex: '#f43f5e' },
  { name: 'indigo',  hex: '#6366f1' },
  { name: 'amber',   hex: '#f59e0b' },
  { name: 'cyan',    hex: '#06b6d4' },
  { name: 'emerald', hex: '#10b981' }
]

/**
 * 테마 관리 컴포저블
 */
export function useTheme() {
  const primevue = usePrimeVue()

  /** 테마 프리셋 + Primary 컬러를 함께 적용 */
  function applyPreset(name: PresetName) {
    currentPreset.value = name
    applyThemeConfig()
    save()
  }

  /** PrimeVue 테마 설정을 현재 상태 기반으로 적용 */
  function applyThemeConfig() {
    const basePreset = presetMap[currentPreset.value]
    const palette = colorPalettes[primaryColor.value]

    /* definePreset으로 primary 컬러를 오버라이드한 커스텀 프리셋 생성 */
    const customPreset = definePreset(basePreset, {
      semantic: {
        primary: palette
      }
    })

    primevue.config.theme = {
      preset: customPreset,
      options: {
        prefix: 'p',
        darkModeSelector: '.dark-mode',
        cssLayer: false
      }
    }
  }

  /** 다크 모드 토글 */
  function toggleDark() {
    isDark.value = !isDark.value
    applyDarkMode()
    save()
  }

  /** 다크 모드 CSS 클래스 적용/제거 */
  function applyDarkMode() {
    document.documentElement.classList.toggle('dark-mode', isDark.value)
  }

  /** 레이아웃 모드 전환 */
  function toggleLayout() {
    layoutMode.value = layoutMode.value === 'sidebar' ? 'topnav' : 'sidebar'
    save()
  }

  /** 레이아웃 모드 직접 설정 */
  function setLayoutMode(mode: LayoutMode) {
    layoutMode.value = mode
    save()
  }

  /** Primary 컬러 변경 */
  function setPrimaryColor(color: PrimaryColor) {
    primaryColor.value = color
    applyThemeConfig()
    save()
  }

  /** UI 밀도 변경 — CSS 변수를 DOM에 직접 적용 */
  function setDensity(d: Density) {
    density.value = d
    applyDensity()
    save()
  }

  /** 밀도 CSS 변수를 :root에 적용 */
  function applyDensity() {
    const v = densityMap[density.value]
    const root = document.documentElement.style
    root.setProperty('--app-font-size', v.fontSize)
    root.setProperty('--app-input-padding', v.inputPadding)
    root.setProperty('--app-cell-padding', v.cellPadding)
  }

  /** 보더 라운드 변경 — CSS 변수를 DOM에 직접 적용 */
  function setBorderRadius(r: BorderRadius) {
    borderRadius.value = r
    applyBorderRadius()
    save()
  }

  /** 보더 라운드 CSS 변수를 :root에 적용 */
  function applyBorderRadius() {
    document.documentElement.style.setProperty('--app-border-radius', radiusMap[borderRadius.value])
  }

  /** 사이드바 스타일 변경 */
  function setSidebarStyle(s: SidebarStyle) {
    sidebarStyle.value = s
    applySidebarStyle()
    save()
  }

  /** 사이드바 스타일 CSS 클래스를 body에 적용 */
  function applySidebarStyle() {
    const body = document.body
    body.classList.remove('sidebar-default', 'sidebar-colored', 'sidebar-glass', 'sidebar-minimal')
    body.classList.add(`sidebar-${sidebarStyle.value}`)
  }

  /** 설정을 localStorage에 저장 */
  function save() {
    localStorage.setItem(STORAGE_KEY, JSON.stringify({
      preset: currentPreset.value,
      dark: isDark.value,
      layoutMode: layoutMode.value,
      primaryColor: primaryColor.value,
      density: density.value,
      borderRadius: borderRadius.value,
      sidebarStyle: sidebarStyle.value
    }))
  }

  /** 앱 시작 시 호출 — 저장된 설정을 전부 적용 */
  function init() {
    applyPreset(currentPreset.value)
    applyDarkMode()
    applyDensity()
    applyBorderRadius()
    applySidebarStyle()
  }

  return {
    currentPreset, isDark, layoutMode, primaryColor, density, borderRadius, sidebarStyle,
    presetNames: Object.keys(presetMap) as PresetName[],
    applyPreset, toggleDark, toggleLayout, setLayoutMode,
    setPrimaryColor, setDensity, setBorderRadius, setSidebarStyle,
    init
  }
}
