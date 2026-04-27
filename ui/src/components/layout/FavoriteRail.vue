<!--
  FavoriteRail.vue — Phase 14 트랙 6: 헤더 우측 즐겨찾기 레일.

  [용도]
  - 헤더 우측에 사용자가 등록한 즐겨찾기를 가로 아이콘 레일로 표시
  - 각 아이콘 클릭 시 url 로 라우팅
  - 최대 8개까지만 표시 (그 이상은 /settings/favorites 에서 관리)

  [트랙 8 통합 노트]
  - 본 컴포넌트의 LayoutHeader 마운트는 트랙 8(메인)에서 일괄 처리
  - 본 트랙은 컴포넌트 신규 작성만, LayoutHeader.vue 직접 수정 금지

  [Props]
  - maxVisible (default 8): 표시 최대 갯수
-->
<template>
  <div class="favorite-rail" v-if="favorites.length > 0 || showSettingsButton">
    <Button
      v-for="fav in visibleFavorites"
      :key="fav.favId"
      :icon="fav.icon || 'pi pi-star-fill'"
      severity="secondary"
      text
      size="small"
      :label="compact ? undefined : fav.label"
      class="favorite-btn"
      v-tooltip.bottom="fav.label"
      @click="onFavoriteClick(fav)"
    />
    <Button
      v-if="showSettingsButton"
      icon="pi pi-cog"
      severity="secondary"
      text
      size="small"
      v-tooltip.bottom="'즐겨찾기 관리'"
      @click="goManage"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import Button from 'primevue/button';
import { useUx, type FavoriteRow } from '@/composables/useUx';

const props = withDefaults(defineProps<{
  maxVisible?: number;
  compact?: boolean;
  showSettingsButton?: boolean;
}>(), {
  maxVisible: 8,
  compact: true,
  showSettingsButton: true
});

const router = useRouter();
const ux = useUx();

const favorites = ref<FavoriteRow[]>([]);
const visibleFavorites = computed(() => favorites.value.slice(0, props.maxVisible));

async function load() {
  try {
    favorites.value = await ux.listFavorites();
  } catch (e) {
    favorites.value = [];
  }
}

function onFavoriteClick(fav: FavoriteRow) {
  if (fav.url) {
    router.push(fav.url);
  } else if (fav.targetType === 'POST') {
    router.push({ path: '/board', query: { postId: fav.targetId } });
  } else if (fav.targetType === 'DOC') {
    router.push({ path: '/approval', query: { docId: fav.targetId } });
  } else if (fav.targetType === 'EMPLOYEE') {
    router.push({ path: '/org', query: { employeeId: fav.targetId } });
  }
}

function goManage() {
  router.push('/settings/favorites');
}

defineExpose({ reload: load });

onMounted(load);
</script>

<style scoped>
.favorite-rail {
  display: flex;
  align-items: center;
  gap: 2px;
  padding-right: 6px;
  margin-right: 4px;
  border-right: 1px solid var(--p-content-border-color);
}

.favorite-btn {
  padding: 4px 8px !important;
  min-width: 0;
}

.favorite-btn :deep(.p-button-icon) {
  color: var(--p-primary-color);
  font-size: 14px;
}
</style>
