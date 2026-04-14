<!--
  팝업 호스트 (PopupHost)

  [용도]
  - 앱 전역에서 동적으로 열리는 팝업(Dialog)들을 렌더링하는 호스트 컴포넌트
  - usePopup의 openPopup()으로 등록된 팝업 스택을 순회하며 Dialog를 생성한다
  - App.vue 또는 LayoutDefault.vue에 한 번만 배치하면, 어느 화면에서든 팝업을 열 수 있다

  [동작 방식]
  1. 자식 화면에서 openPopup(Component, params) 호출
  2. popupStack에 새 팝업 정보가 push됨
  3. PopupHost가 v-for로 순회하며 PrimeVue Dialog를 렌더링
  4. 팝업 내부에서 onPopupClose(result) 호출 시 Promise가 resolve되고 Dialog가 닫힘
  5. Dialog의 X 버튼으로 닫으면 null이 resolve됨

  [사용 예시]
  - App.vue의 template에 <PopupHost /> 배치
  - 자식 화면: const result = await openPopup(PopupCustomerSearch, { keyword: '삼성' })

  [참고]
  - 팝업은 스택 구조로 관리되므로, 팝업 안에서 또 다른 팝업을 열 수 있다 (중첩 팝업)
  - 각 팝업의 width, modal, title 등은 openPopup 호출 시 옵션으로 지정 가능
-->
<template>
  <!-- 팝업 스택을 순회하며 각 팝업을 PrimeVue Dialog로 렌더링 -->
  <Dialog
    v-for="popup in popupStack"
    :key="popup.id"
    v-model:visible="popup.visible"
    :header="popup.title"
    :style="{ width: popup.width }"
    :modal="popup.modal"
    :closable="true"
    :draggable="true"
    @hide="onHide(popup)"
  >
    <!-- 동적 컴포넌트: 팝업으로 등록된 Vue 컴포넌트를 렌더링 -->
    <!-- popupParams: 부모가 전달한 파라미터, onPopupClose: 결과 반환 콜백 -->
    <component
      :is="popup.component"
      :popupParams="popup.params"
      :onPopupClose="(result: unknown) => popup.resolve(result)"
    />
  </Dialog>
</template>

<script setup lang="ts">
import Dialog from 'primevue/dialog'
import { getPopupStack } from '@/composables/usePopup' // 팝업 스택 관리 composable

/** 현재 열려 있는 팝업 목록 (반응형 배열) */
const popupStack = getPopupStack()

/**
 * Dialog 숨김(X 버튼 클릭) 시 호출되는 핸들러
 * - 사용자가 선택 없이 닫았으므로 null을 resolve하여 Promise를 완료시킨다
 * @param popup - 닫히는 팝업 객체
 */
function onHide(popup: { resolve: (value: unknown) => void }) {
  popup.resolve(null)
}
</script>
