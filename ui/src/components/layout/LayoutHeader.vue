<!--
  레이아웃 헤더 (LayoutHeader)

  [용도]
  - 화면 상단에 고정되는 헤더 컴포넌트
  - 좌측: 사이드바 토글 버튼 + 프레임워크 고정 제목
  - 우측: 테마 프리셋 선택 + 다크/라이트 모드 전환 + 사용자 정보 + 로그아웃 버튼

  [Emits]
  - toggleSidebar — 햄버거 버튼 클릭 시 (사이드바 접힘/펼침 토글)

  [테마 기능]
  - useTheme composable을 통해 PrimeVue 테마 프리셋(Aura, Lara, Nora) 선택 가능
  - 다크/라이트 모드 토글 지원
  - 선택된 테마는 localStorage에 저장되어 새로고침 후에도 유지됨

  [참고]
  - 페이지별 제목은 탭 바(LayoutTabBar)에서 표시하므로 헤더는 고정 텍스트
  - 사용자 정보(이름, 부서)는 authStore에서 가져온다
-->
<template>
  <div class="layout-header">
    <!-- 좌측: 사이드바 토글 버튼 + 프레임워크 고정 제목 -->
    <div class="header-left">
      <!-- 햄버거 메뉴 버튼: sidebar 모드에서만 표시 (topnav 모드에서는 사이드바 없음) -->
      <button v-if="layoutMode === 'sidebar'" class="toggle-btn" @click="$emit('toggleSidebar')">
        <i class="pi pi-bars"></i>
      </button>
      <!-- 프레임워크 고정 제목: 페이지별 제목은 탭 바에서 표시 -->
      <span class="page-title">openplatform v3</span>
    </div>
    <!-- 우측: 테마 전환 + 사용자 정보 + 로그아웃 -->
    <div class="header-right">
      <!-- 설정 컨트롤: 아이콘 버튼만 표시 (깔끔한 UI) -->
      <div class="theme-controls">
        <!-- 테마 설정 패널 열기: 기어 아이콘 → Drawer 슬라이드 -->
        <Button
          icon="pi pi-cog"
          severity="secondary"
          text
          size="small"
          @click="themeDrawerVisible = true"
          v-tooltip.bottom="t('LBL_THEME_SETTINGS', '테마 설정')"
        />
        <!-- 다크/라이트 모드 토글 (빠른 접근용 헤더에 유지) -->
        <Button
          :icon="isDark ? 'pi pi-sun' : 'pi pi-moon'"
          severity="secondary"
          text
          size="small"
          @click="toggleDark"
          v-tooltip.bottom="isDark ? '라이트 모드' : '다크 모드'"
        />
        <!-- 다국어 선택: 현재 로케일 약어(KO/EN) 표시, 클릭 시 팝업 메뉴로 언어 변경 -->
        <Button
          severity="secondary"
          text
          size="small"
          class="locale-button"
          @click="(e: Event) => localeMenuRef?.toggle(e)"
          v-tooltip.bottom="'언어: ' + localeLabels[locale as 'ko' | 'en']"
        >
          <i class="pi pi-globe" style="margin-right: 4px"></i>
          <span class="locale-short">{{ localeShort[locale as 'ko' | 'en'] }}</span>
        </Button>
        <Menu ref="localeMenuRef" :model="localeMenuItems" :popup="true" />
      </div>
      <!-- 알림 벨 (SSE 실시간) -->
      <NotificationBell />
      <!-- 로그인 사용자 정보 표시: 이름 (부서명) -->
      <span class="user-info" v-if="authStore.user">
        <i class="pi pi-user"></i>
        {{ displayUserName }} ({{ authStore.user.department }})
      </span>
      <!-- 로그아웃 버튼 (다국어 라벨) -->
      <Button
        icon="pi pi-sign-out"
        :label="t('BTN_LOGOUT', '로그아웃')"
        severity="secondary"
        text
        size="small"
        @click="handleLogout"
      />
    </div>
    <!-- 테마 설정 Drawer (우측 슬라이드) -->
    <ThemeSettingsDrawer v-model:visible="themeDrawerVisible" />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/store/auth'
import { useTheme } from '@/composables/useTheme'
import { useLocale, type SupportedLocale } from '@/composables/useLocale'
import { t } from '@/composables/useLabel'
import Button from 'primevue/button'
import Menu from 'primevue/menu'
import ThemeSettingsDrawer from './ThemeSettingsDrawer.vue'
import NotificationBell from '@/components/common/NotificationBell.vue'

/**
 * 부모(LayoutDefault)로 전달하는 이벤트
 * LayoutDefault의 sidebarCollapsed 상태를 토글하여 사이드바 접힘/펼침을 제어
 */
defineEmits<{
  /** 사이드바 토글 요청 — 햄버거 버튼(pi-bars) 클릭 시 발생, LayoutDefault의 sidebarCollapsed를 반전 */
  toggleSidebar: []
}>()

const router = useRouter()      // 라우터 인스턴스 (로그아웃 후 리다이렉트용)
const authStore = useAuthStore() // 인증 스토어
/** 테마 관련 상태 및 함수 */
const { isDark, layoutMode, toggleDark, init } = useTheme()

/** 테마 설정 Drawer 표시 여부 */
const themeDrawerVisible = ref(false)
/** PrimeVue Menu 컴포넌트 ref (언어 선택 팝업) */
const localeMenuRef = ref<InstanceType<typeof Menu> | null>(null)

/** 다국어 컴포저블 */
const { locale, setLocale, supportedLocales, localeLabels, localeShort } = useLocale()

/** 현재 locale에 맞는 사용자명 표시 — ko면 userName, 그 외면 userNameEn 폴백 */
const displayUserName = computed(() => {
  const user = authStore.user
  if (!user) return ''
  if (locale.value === 'ko') return user.userName || user.userNameEn || ''
  return user.userNameEn || user.userName || ''
})

/**
 * 언어 선택 팝업 메뉴 항목
 * - 각 언어에 체크 아이콘(현재 선택) 표시
 * - 클릭 시 setLocale 호출하여 캐시 재로드 + 화면 자동 갱신
 */
const localeMenuItems = computed(() =>
  supportedLocales.map(loc => ({
    label: localeLabels[loc],
    icon: locale.value === loc ? 'pi pi-check' : 'pi pi-circle',
    command: () => setLocale(loc as SupportedLocale)
  }))
)

/** 컴포넌트 마운트 시 저장된 테마 설정을 복원 */
onMounted(() => {
  init()
})

/**
 * 로그아웃 처리
 * - authStore.logout()으로 토큰 제거 후 로그인 페이지로 이동
 */
async function handleLogout() {
  await authStore.logout()
  router.push('/login')
}
</script>

<style scoped>
.layout-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: var(--header-height);
  padding: 0 16px;
  background-color: var(--p-content-background);
  border-bottom: 1px solid var(--p-content-border-color);
  flex-shrink: 0;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 12px;
}

.toggle-btn {
  background: none;
  border: none;
  cursor: pointer;
  font-size: 18px;
  color: var(--p-text-muted-color);
  padding: 4px 8px;
  border-radius: 4px;
}

.toggle-btn:hover {
  background-color: var(--p-content-hover-background);
}

.page-title {
  font-size: 16px;
  font-weight: 600;
  color: var(--p-text-color);
}

.header-right {
  display: flex;
  align-items: center;
  gap: 12px;
}

.theme-controls {
  display: flex;
  align-items: center;
  gap: 4px;
}

.user-info {
  font-size: 13px;
  color: var(--p-text-muted-color);
  display: flex;
  align-items: center;
  gap: 6px;
}

.locale-button {
  display: inline-flex;
  align-items: center;
}

.locale-short {
  font-size: 11px;
  font-weight: 600;
  letter-spacing: 0.3px;
}

</style>
