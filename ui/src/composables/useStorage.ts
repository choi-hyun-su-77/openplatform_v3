/**
 * useStorage — MinIO presigned URL 기반 파일 업/다운로드 공통 composable.
 *
 * BFF `/api/bff/storage/presigned` 엔드포인트를 통해
 * PUT(업로드)/GET(다운로드) presigned URL을 발급받고,
 * 브라우저에서 직접 MinIO에 파일을 업로드/다운로드한다.
 */
import axios from 'axios';
import { ref } from 'vue';

export function useStorage() {
  const uploading = ref(false);

  async function getPresignedPutUrl(objectKey: string, expireSec = 600): Promise<string> {
    const r = await axios.get('/api/bff/storage/presigned', {
      params: { object: objectKey, op: 'PUT', expire: expireSec }
    });
    return r.data?.url;
  }

  async function getPresignedGetUrl(objectKey: string, expireSec = 600): Promise<string> {
    const r = await axios.get('/api/bff/storage/presigned', {
      params: { object: objectKey, op: 'GET', expire: expireSec }
    });
    return r.data?.url;
  }

  /**
   * 파일을 MinIO에 업로드하고 메타 정보를 반환.
   * @param file - File 객체
   * @param prefix - 오브젝트 키 prefix (예: 'approval/123/', 'board/45/')
   * @returns { objectKey, filename, sizeBytes, mimeType }
   */
  async function uploadFile(file: File, prefix: string) {
    uploading.value = true;
    try {
      const objectKey = `${prefix}${Date.now()}_${file.name}`;
      const putUrl = await getPresignedPutUrl(objectKey);
      await axios.put(putUrl, file, {
        headers: { 'Content-Type': file.type || 'application/octet-stream' }
      });
      return {
        objectKey,
        filename: file.name,
        sizeBytes: file.size,
        mimeType: file.type || 'application/octet-stream'
      };
    } finally {
      uploading.value = false;
    }
  }

  /**
   * presigned GET URL을 새 탭으로 열어 다운로드.
   */
  async function downloadFile(objectKey: string) {
    const url = await getPresignedGetUrl(objectKey);
    window.open(url, '_blank');
  }

  return { uploading, getPresignedPutUrl, getPresignedGetUrl, uploadFile, downloadFile };
}
