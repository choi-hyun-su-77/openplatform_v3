<!--
  FolderActions.vue — 자료실 폴더 우클릭 컨텍스트 메뉴 (Phase 14 트랙 3).

  사용:
    <FolderActions ref="folderActions"
                   :folder="selectedFolder"
                   :writable="writable"
                   @new-folder="handleNewFolder"
                   @rename="handleRename"
                   @delete="handleDelete"
                   @upload="handleUpload" />

    function onTreeRightClick(event: MouseEvent, node: FolderTreeNode) {
      selectedFolder.value = node;
      folderActions.value?.show(event);
    }

  메뉴 항목은 writable 권한에 따라 비활성 처리. (회사 공용 루트 + 부서 외부 폴더
  등 사용자가 변경할 수 없는 폴더에서는 새 폴더/이름변경/삭제/업로드 모두 disabled)
-->
<template>
  <ContextMenu ref="cmRef" :model="items" />
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import ContextMenu from 'primevue/contextmenu';
import type { FolderRow } from '@/composables/useDataLibrary';

const props = defineProps<{
  folder: FolderRow | null;
  /** 현재 선택된 폴더에 쓰기 가능한지 (Service `canAccessFolder` 의 클라이언트 미러). */
  writable: boolean;
}>();

const emit = defineEmits<{
  newFolder: [folder: FolderRow];
  rename:    [folder: FolderRow];
  delete:    [folder: FolderRow];
  upload:    [folder: FolderRow];
}>();

const cmRef = ref<InstanceType<typeof ContextMenu> | null>(null);

function fire(action: 'newFolder' | 'rename' | 'delete' | 'upload') {
  if (!props.folder) return;
  const f = props.folder;
  switch (action) {
    case 'newFolder': emit('newFolder', f); break;
    case 'rename':    emit('rename', f);    break;
    case 'delete':    emit('delete', f);    break;
    case 'upload':    emit('upload', f);    break;
  }
}

const items = computed(() => {
  const w = props.writable;
  return [
    {
      label: '파일 업로드',
      icon: 'pi pi-upload',
      disabled: !w,
      command: () => fire('upload')
    },
    { separator: true },
    {
      label: '새 폴더',
      icon: 'pi pi-folder-plus',
      disabled: !w,
      command: () => fire('newFolder')
    },
    {
      label: '이름 변경',
      icon: 'pi pi-pencil',
      // 회사 공용 루트(folderId=1)는 이름 변경 금지.
      disabled: !w || props.folder?.folderId === 1,
      command: () => fire('rename')
    },
    {
      label: '삭제',
      icon: 'pi pi-trash',
      disabled: !w || props.folder?.folderId === 1,
      command: () => fire('delete')
    }
  ];
});

defineExpose({
  /** 부모에서 우클릭 이벤트 받아 메뉴 표시. */
  show(event: MouseEvent) {
    cmRef.value?.show(event);
  }
});
</script>
