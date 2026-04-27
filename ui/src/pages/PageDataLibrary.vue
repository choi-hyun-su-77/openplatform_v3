<!--
  PageDataLibrary.vue — Phase 14 트랙 3: 자료실(Document Library)

  구성:
    좌(240px): PrimeVue Tree 폴더 — COMPANY/DEPT/PERSONAL scope 별로 정렬,
              우클릭 시 FolderActions ContextMenu (새 폴더/이름변경/삭제/업로드).
    우(1fr) : CrudToolbar(검색, 새 폴더, 업로드) + 파일 DataTable
              (이름·크기·업로더·날짜·다운로드 회수·다운로드 버튼·삭제 버튼).

  업로드: components/common/FileUploadPanel.vue 재사용.
          파일별 presigned PUT 완료 → datalib/uploadMeta 호출.
  다운로드: datalib/getDownloadUrl 로 presigned GET 받아 새 탭으로 open.
-->
<template>
  <div class="page datalib-page">
    <!-- 좌측: 폴더 트리 -->
    <aside class="folder-pane">
      <div class="pane-header">
        <h3>폴더</h3>
        <Button icon="pi pi-refresh" text size="small" @click="loadFolders" />
      </div>
      <Tree
        :value="treeNodes"
        selectionMode="single"
        v-model:selectionKeys="selectedKey"
        @node-select="onNodeSelect"
        @node-contextmenu="onNodeContextMenu"
        class="folder-tree"
      />
      <FolderActions
        ref="folderActionsRef"
        :folder="selectedFolder"
        :writable="selectedWritable"
        @new-folder="openNewFolderDialog"
        @rename="openRenameDialog"
        @delete="confirmDeleteFolder"
        @upload="openUploadDialog"
      />
    </aside>

    <!-- 우측: 툴바 + 파일 목록 -->
    <section class="file-pane">
      <div class="toolbar">
        <h2 class="title">
          {{ selectedFolder?.folderName || '자료실' }}
          <small v-if="selectedFolder">
            <Tag :value="scopeLabel(selectedFolder.scope)" :severity="scopeSeverity(selectedFolder.scope)" />
          </small>
        </h2>
        <div class="toolbar-actions">
          <InputText v-model="keyword" placeholder="파일명 검색" @keyup.enter="loadFiles" />
          <Button icon="pi pi-search" label="검색" severity="info" size="small" @click="loadFiles" />
          <Button icon="pi pi-folder-plus" label="새 폴더"
                  severity="secondary" size="small"
                  :disabled="!selectedFolder || !selectedWritable"
                  @click="openNewFolderDialog(selectedFolder!)" />
          <Button icon="pi pi-upload" label="업로드"
                  severity="success" size="small"
                  :disabled="!selectedFolder || !selectedWritable"
                  @click="openUploadDialog(selectedFolder!)" />
        </div>
      </div>

      <DataTable :value="files" :rowHover="true" :loading="loading"
                 paginator :rows="20" dataKey="fileId">
        <template #empty>
          <div class="empty-row">선택된 폴더에 파일이 없습니다.</div>
        </template>
        <Column field="fileName" header="이름">
          <template #body="{ data }">
            <i class="pi pi-file" />
            <span class="file-name-link" @click="downloadFile(data)">{{ data.fileName }}</span>
          </template>
        </Column>
        <Column header="크기" style="width:100px">
          <template #body="{ data }">{{ formatSize(data.sizeBytes) }}</template>
        </Column>
        <Column field="uploaderName" header="업로더" style="width:110px" />
        <Column header="업로드일" style="width:140px">
          <template #body="{ data }">{{ formatDate(data.uploadedAt) }}</template>
        </Column>
        <Column field="downloadCount" header="다운로드" style="width:90px" />
        <Column header="" style="width:120px">
          <template #body="{ data }">
            <Button icon="pi pi-download" text rounded severity="info"
                    @click="downloadFile(data)" />
            <Button v-if="canDeleteFile(data)" icon="pi pi-trash" text rounded
                    severity="danger" @click="confirmDeleteFile(data)" />
          </template>
        </Column>
      </DataTable>
    </section>

    <!-- 새 폴더 다이얼로그 -->
    <Dialog v-model:visible="newFolderVisible" header="새 폴더" modal :style="{ width: '400px' }">
      <div class="form-row">
        <label>폴더명</label>
        <InputText v-model="newFolderName" autofocus @keyup.enter="submitNewFolder" />
      </div>
      <div class="form-row" v-if="newFolderParent">
        <label>위치</label>
        <span class="parent-path">{{ newFolderParent.folderName }}</span>
      </div>
      <template #footer>
        <Button label="취소" severity="secondary" @click="newFolderVisible = false" />
        <Button label="생성" severity="success" :disabled="!newFolderName.trim()" @click="submitNewFolder" />
      </template>
    </Dialog>

    <!-- 이름 변경 다이얼로그 -->
    <Dialog v-model:visible="renameVisible" header="폴더 이름 변경" modal :style="{ width: '400px' }">
      <div class="form-row">
        <label>새 이름</label>
        <InputText v-model="renameName" autofocus @keyup.enter="submitRename" />
      </div>
      <template #footer>
        <Button label="취소" severity="secondary" @click="renameVisible = false" />
        <Button label="저장" severity="warn" :disabled="!renameName.trim()" @click="submitRename" />
      </template>
    </Dialog>

    <!-- 업로드 다이얼로그 -->
    <Dialog v-model:visible="uploadVisible" header="파일 업로드" modal :style="{ width: '520px' }">
      <p v-if="uploadFolder" class="upload-target">
        업로드 대상: <strong>{{ uploadFolder.folderName }}</strong>
        <Tag :value="scopeLabel(uploadFolder.scope)" :severity="scopeSeverity(uploadFolder.scope)" class="ml-2" />
      </p>
      <FileUploadPanel
        :files="uploadedFiles"
        :prefix="uploadPrefix"
        editable
        multiple
        @uploaded="onFileUploaded"
        @remove="onUploadedRemove"
      />
      <template #footer>
        <Button label="닫기" severity="secondary" @click="closeUploadDialog" />
      </template>
    </Dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import Tree from 'primevue/tree';
import DataTable from 'primevue/datatable';
import Column from 'primevue/column';
import Button from 'primevue/button';
import InputText from 'primevue/inputtext';
import Dialog from 'primevue/dialog';
import Tag from 'primevue/tag';
import FileUploadPanel, { type FileItem } from '@/components/common/FileUploadPanel.vue';
import FolderActions from '@/components/datalib/FolderActions.vue';
import { useDataLibrary, buildFolderTree,
         type FolderRow, type FolderTreeNode, type FileRow } from '@/composables/useDataLibrary';
import { useMessage } from '@/composables/useMessage';
import { useAuthStore } from '@/store/auth';

const lib = useDataLibrary();
const { success, error, confirmDialog } = useMessage();
const auth = useAuthStore();

const folders = ref<FolderRow[]>([]);
const treeNodes = ref<any[]>([]);
const selectedKey = ref<Record<string, boolean>>({});
const selectedFolder = ref<FolderRow | null>(null);

const files = ref<FileRow[]>([]);
const loading = ref(false);
const keyword = ref('');

// FolderActions 컨텍스트
const folderActionsRef = ref<InstanceType<typeof FolderActions> | null>(null);

// 다이얼로그 상태
const newFolderVisible = ref(false);
const newFolderName = ref('');
const newFolderParent = ref<FolderRow | null>(null);

const renameVisible = ref(false);
const renameName = ref('');
const renameTarget = ref<FolderRow | null>(null);

const uploadVisible = ref(false);
const uploadFolder = ref<FolderRow | null>(null);
const uploadedFiles = ref<FileItem[]>([]);

const currentUserNo = computed(() => auth.user?.employeeNo || auth.user?.userId || '');
const currentDeptId = computed(() => auth.user?.deptId);
const isAdmin = computed(() => (auth.user?.roles || []).includes('ROLE_ADMIN'));
const isMgr = computed(() => (auth.user?.roles || []).includes('ROLE_MGR'));

/** 클라이언트 미러: 서버 canAccessFolder 와 동일 로직. 차단된 작업은 서버에서도 거부됨. */
const selectedWritable = computed<boolean>(() => writableFor(selectedFolder.value));

function writableFor(f: FolderRow | null): boolean {
  if (!f) return false;
  if (isAdmin.value) return true;
  if (f.scope === 'COMPANY') return isMgr.value;
  if (f.scope === 'DEPT') {
    return f.ownerDeptId != null && f.ownerDeptId === currentDeptId.value;
  }
  if (f.scope === 'PERSONAL') {
    return f.ownerNo === currentUserNo.value;
  }
  return false;
}

function canDeleteFile(file: FileRow): boolean {
  return isAdmin.value || file.uploaderNo === currentUserNo.value;
}

const uploadPrefix = computed(() => {
  return uploadFolder.value ? `datalib/${uploadFolder.value.folderId}/` : 'datalib/0/';
});

const scopeLabels: Record<string, string> = {
  COMPANY: '회사', DEPT: '부서', PERSONAL: '개인'
};
function scopeLabel(s?: string) { return s ? scopeLabels[s] || s : ''; }
function scopeSeverity(s?: string) {
  if (s === 'COMPANY') return 'success';
  if (s === 'DEPT') return 'info';
  if (s === 'PERSONAL') return 'warn';
  return 'secondary';
}

function formatSize(bytes: number) {
  if (!bytes) return '0 B';
  if (bytes < 1024) return bytes + ' B';
  if (bytes < 1048576) return (bytes / 1024).toFixed(1) + ' KB';
  return (bytes / 1048576).toFixed(1) + ' MB';
}

function formatDate(dt: string) {
  if (!dt) return '';
  return new Date(dt).toLocaleDateString('ko-KR',
    { month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit' });
}

function toPrimevueNode(node: FolderTreeNode): any {
  let icon = 'pi pi-folder';
  if (node.scope === 'COMPANY') icon = 'pi pi-building';
  else if (node.scope === 'DEPT') icon = 'pi pi-users';
  else if (node.scope === 'PERSONAL') icon = 'pi pi-user';
  return {
    key: String(node.folderId),
    label: node.folderName,
    icon,
    data: node,
    children: node.children.map(toPrimevueNode)
  };
}

async function loadFolders() {
  try {
    const rows = await lib.listFolders();
    folders.value = rows;
    const tree = buildFolderTree(rows);
    treeNodes.value = tree.map(toPrimevueNode);

    // 선택 상태 유지 — 없으면 첫 번째 (회사 공용 루트) 자동 선택.
    if (!selectedFolder.value && rows.length > 0) {
      const root = rows.find(r => r.folderId === 1) || rows[0];
      selectedFolder.value = root;
      selectedKey.value = { [String(root.folderId)]: true };
      await loadFiles();
    } else if (selectedFolder.value) {
      // 변경된 폴더 객체로 갱신.
      const updated = rows.find(r => r.folderId === selectedFolder.value!.folderId);
      if (updated) selectedFolder.value = updated;
      else {
        // 삭제된 경우 — 루트로 폴백.
        const root = rows.find(r => r.folderId === 1) || rows[0] || null;
        selectedFolder.value = root;
        selectedKey.value = root ? { [String(root.folderId)]: true } : {};
        await loadFiles();
      }
    }
  } catch (e) {
    error('폴더 트리 로드에 실패했습니다.');
  }
}

async function loadFiles() {
  if (!selectedFolder.value) {
    files.value = [];
    return;
  }
  loading.value = true;
  try {
    files.value = await lib.listFiles(selectedFolder.value.folderId, keyword.value);
  } catch (e) {
    error('파일 목록 로드에 실패했습니다.');
    files.value = [];
  } finally {
    loading.value = false;
  }
}

function onNodeSelect(node: any) {
  const folder = node?.data as FolderRow | undefined;
  if (folder) {
    selectedFolder.value = folder;
    keyword.value = '';
    loadFiles();
  }
}

function onNodeContextMenu(event: { originalEvent: MouseEvent; node: any }) {
  const folder = event.node?.data as FolderRow | undefined;
  if (!folder) return;
  selectedFolder.value = folder;
  selectedKey.value = { [String(folder.folderId)]: true };
  event.originalEvent.preventDefault();
  folderActionsRef.value?.show(event.originalEvent);
}

// ── 새 폴더 ──
function openNewFolderDialog(parent: FolderRow) {
  newFolderParent.value = parent;
  newFolderName.value = '';
  newFolderVisible.value = true;
}

async function submitNewFolder() {
  if (!newFolderName.value.trim() || !newFolderParent.value) return;
  try {
    await lib.createFolder({
      parentId: newFolderParent.value.folderId,
      folderName: newFolderName.value.trim()
      // scope 미지정 → 부모로부터 상속.
    });
    success('폴더가 생성되었습니다.');
    newFolderVisible.value = false;
    await loadFolders();
  } catch (e: any) {
    error(e?.response?.data?.message || '폴더 생성에 실패했습니다.');
  }
}

// ── 이름 변경 ──
function openRenameDialog(folder: FolderRow) {
  renameTarget.value = folder;
  renameName.value = folder.folderName;
  renameVisible.value = true;
}

async function submitRename() {
  if (!renameName.value.trim() || !renameTarget.value) return;
  try {
    await lib.renameFolder(renameTarget.value.folderId, renameName.value.trim());
    success('폴더 이름이 변경되었습니다.');
    renameVisible.value = false;
    await loadFolders();
  } catch (e: any) {
    error(e?.response?.data?.message || '이름 변경에 실패했습니다.');
  }
}

// ── 폴더 삭제 ──
function confirmDeleteFolder(folder: FolderRow) {
  confirmDialog({
    message: `폴더 '${folder.folderName}'을(를) 삭제하시겠습니까?\n(하위 폴더/파일이 있으면 실패합니다)`,
    accept: async () => {
      try {
        await lib.deleteFolder(folder.folderId);
        success('폴더가 삭제되었습니다.');
        await loadFolders();
      } catch (e: any) {
        error(e?.response?.data?.message || '폴더 삭제에 실패했습니다.');
      }
    }
  });
}

// ── 업로드 ──
function openUploadDialog(folder: FolderRow) {
  uploadFolder.value = folder;
  uploadedFiles.value = [];
  uploadVisible.value = true;
}

async function onFileUploaded(meta: FileItem) {
  if (!uploadFolder.value) return;
  try {
    const res: any = await lib.uploadMeta({
      folderId: uploadFolder.value.folderId,
      fileName: meta.filename,
      objectKey: meta.objectKey,
      sizeBytes: meta.sizeBytes,
      mimeType: meta.mimeType
    });
    if (res?.success || res?.fileId) {
      uploadedFiles.value.push({ ...meta, attachId: res.fileId });
      success(`${meta.filename} 업로드 완료`);
    }
  } catch (e: any) {
    error(e?.response?.data?.message || `${meta.filename} 메타 등록 실패`);
  }
}

function onUploadedRemove(_file: FileItem, idx: number) {
  // 다이얼로그 내부 임시 표시만 제거 — 실제 삭제는 목록에서 별도 수행.
  uploadedFiles.value.splice(idx, 1);
}

async function closeUploadDialog() {
  uploadVisible.value = false;
  uploadedFiles.value = [];
  await loadFiles();
}

// ── 파일 다운로드 / 삭제 ──
async function downloadFile(file: FileRow) {
  try {
    const { url } = await lib.getDownloadUrl(file.fileId);
    if (url) window.open(url, '_blank');
    // 다운로드 카운트 새로고침
    await loadFiles();
  } catch (e: any) {
    error(e?.response?.data?.message || '다운로드 URL 발급 실패');
  }
}

function confirmDeleteFile(file: FileRow) {
  confirmDialog({
    message: `'${file.fileName}'을(를) 삭제하시겠습니까?`,
    accept: async () => {
      try {
        await lib.deleteFile(file.fileId);
        success('파일이 삭제되었습니다.');
        await loadFiles();
      } catch (e: any) {
        error(e?.response?.data?.message || '파일 삭제에 실패했습니다.');
      }
    }
  });
}

onMounted(async () => {
  await loadFolders();
});
</script>

<style scoped>
.datalib-page {
  display: grid;
  grid-template-columns: 240px 1fr;
  gap: 1rem;
  padding: 1.5rem;
  height: calc(100vh - 100px);
}
.folder-pane {
  border-right: 1px solid var(--p-content-border-color);
  padding-right: 0.75rem;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}
.pane-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.5rem;
}
.pane-header h3 {
  margin: 0;
  font-size: 1rem;
}
.folder-tree {
  flex: 1;
  overflow: auto;
  border: none;
}
.file-pane {
  display: flex;
  flex-direction: column;
  overflow: hidden;
}
.toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
  flex-wrap: wrap;
  gap: 0.5rem;
}
.title {
  margin: 0;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}
.title small {
  font-size: 0.7rem;
  font-weight: normal;
}
.toolbar-actions {
  display: flex;
  gap: 0.5rem;
  align-items: center;
}
.empty-row {
  text-align: center;
  padding: 2rem;
  color: var(--p-text-muted-color);
}
.file-name-link {
  cursor: pointer;
  color: var(--p-primary-color);
  margin-left: 0.5rem;
}
.file-name-link:hover {
  text-decoration: underline;
}
.form-row {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
  margin-bottom: 0.75rem;
}
.form-row label {
  font-size: 0.85rem;
  font-weight: 600;
}
.parent-path {
  font-size: 0.9rem;
  color: var(--p-text-muted-color);
}
.upload-target {
  margin-bottom: 1rem;
}
.ml-2 {
  margin-left: 0.5rem;
}
</style>
