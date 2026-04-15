<template>
  <div class="page">
    <h2>화상회의 (LiveKit)</h2>
    <div v-if="!connected" class="pre">
      <div class="sso-panel">
        <div class="icon"><i class="pi pi-video" /></div>
        <div class="info">
          <h3>Keycloak SSO → LiveKit 룸 입장</h3>
          <p>룸 이름을 입력하고 카메라/마이크 권한을 허용하면 즉시 연결됩니다.</p>
          <InputText v-model="roomName" placeholder="룸 이름" />
          <Button label="룸 생성/입장" icon="pi pi-video" :loading="loading" @click="joinRoom" severity="primary" size="large" />
        </div>
      </div>
    </div>
    <div v-else class="room">
      <div class="room-header">
        <h3><i class="pi pi-video" /> {{ roomName }}</h3>
        <div class="room-actions">
          <Button :label="micOn ? '마이크 끄기' : '마이크 켜기'" :icon="micOn ? 'pi pi-microphone' : 'pi pi-microphone-slash'" @click="toggleMic" :severity="micOn ? 'secondary' : 'danger'" />
          <Button :label="camOn ? '카메라 끄기' : '카메라 켜기'" :icon="camOn ? 'pi pi-video' : 'pi pi-stop'" @click="toggleCam" :severity="camOn ? 'secondary' : 'danger'" />
          <Button label="나가기" icon="pi pi-sign-out" @click="leave" severity="danger" />
        </div>
      </div>
      <div class="videos">
        <div class="video-tile self">
          <video ref="localVideoRef" autoplay muted playsinline />
          <div class="tag">나</div>
        </div>
        <div v-for="p in remoteParticipants" :key="p.sid" class="video-tile">
          <video :ref="(el) => setRemoteVideo(p.sid, el)" autoplay playsinline />
          <div class="tag">{{ p.identity }}</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, nextTick } from 'vue';
import axios from 'axios';
import Button from 'primevue/button';
import InputText from 'primevue/inputtext';
import { Room, RoomEvent, Track, createLocalTracks, type LocalAudioTrack, type LocalVideoTrack, type RemoteParticipant, type RemoteTrack } from 'livekit-client';

const roomName = ref('v3-general');
const loading = ref(false);
const connected = ref(false);
const micOn = ref(true);
const camOn = ref(true);
const localVideoRef = ref<HTMLVideoElement | null>(null);

let room: Room | null = null;
let localAudio: LocalAudioTrack | null = null;
let localVideo: LocalVideoTrack | null = null;
const remoteParticipants = reactive<RemoteParticipant[]>([]);
const remoteVideoEls = new Map<string, HTMLVideoElement>();

function setRemoteVideo(sid: string, el: any) {
  if (el instanceof HTMLVideoElement) remoteVideoEls.set(sid, el);
}

async function joinRoom() {
  loading.value = true;
  try {
    // BFF 가 token 과 함께 wsUrl 을 반환한다. 환경변수 fallback 도 유지.
    const tokRes = await axios.post('/api/bff/video/token', { roomName: roomName.value, canPublish: true });
    const token = tokRes.data.token;
    const serverUrl: string = tokRes.data.wsUrl
      || (import.meta as any).env.VITE_LIVEKIT_URL
      || 'ws://localhost:19880';

    room = new Room({ adaptiveStream: true, dynacast: true });

    room.on(RoomEvent.ParticipantConnected, (p) => remoteParticipants.push(p));
    room.on(RoomEvent.ParticipantDisconnected, (p) => {
      const i = remoteParticipants.findIndex(x => x.sid === p.sid);
      if (i >= 0) remoteParticipants.splice(i, 1);
      remoteVideoEls.delete(p.sid);
    });
    room.on(RoomEvent.TrackSubscribed, (track: RemoteTrack, _pub, participant) => {
      if (track.kind === Track.Kind.Video || track.kind === Track.Kind.Audio) {
        const el = remoteVideoEls.get(participant.sid);
        if (el) track.attach(el);
      }
    });

    await room.connect(serverUrl, token);

    // 카메라/마이크가 없거나 권한이 거부된 환경에서도 룸 입장 자체는 성공해야 한다.
    // 디바이스 획득 실패는 view-only 로 폴백하고 사용자에게 알린다.
    try {
      const tracks = await createLocalTracks({ audio: true, video: true });
      for (const t of tracks) {
        if (t.kind === Track.Kind.Audio) {
          localAudio = t as LocalAudioTrack;
          await room.localParticipant.publishTrack(t);
        }
        if (t.kind === Track.Kind.Video) {
          localVideo = t as LocalVideoTrack;
          await room.localParticipant.publishTrack(t);
        }
      }
    } catch (mediaErr: any) {
      console.warn('미디어 디바이스 미사용 (view-only 모드):', mediaErr?.message || mediaErr);
      micOn.value = false;
      camOn.value = false;
    }
    connected.value = true;
    await nextTick();
    if (localVideo && localVideoRef.value) localVideo.attach(localVideoRef.value);
  } catch (e: any) {
    alert('룸 연결 실패: ' + (e.message || e));
    console.error(e);
  } finally {
    loading.value = false;
  }
}

async function toggleMic() {
  if (!localAudio) return;
  micOn.value = !micOn.value;
  if (micOn.value) await localAudio.unmute(); else await localAudio.mute();
}

async function toggleCam() {
  if (!localVideo) return;
  camOn.value = !camOn.value;
  if (camOn.value) await localVideo.unmute(); else await localVideo.mute();
}

async function leave() {
  if (room) { await room.disconnect(); room = null; }
  remoteParticipants.splice(0);
  remoteVideoEls.clear();
  connected.value = false;
}
</script>

<style scoped>
.page { padding: 1.5rem; height: calc(100vh - 120px); display: flex; flex-direction: column; }
.sso-panel { max-width: 680px; margin: 3rem auto; padding: 2.5rem; background: linear-gradient(135deg, #f3e8ff, #e9d5ff); border-radius: 1rem; display: flex; gap: 2rem; align-items: center; }
.icon { font-size: 4rem; color: #7c3aed; }
.info h3 { margin: 0 0 0.75rem 0; color: #6b21a8; }
.info p { color: #475569; margin-bottom: 1rem; }
.info .p-inputtext { width: 100%; margin-bottom: 0.75rem; }
.room { flex: 1; display: flex; flex-direction: column; background: #0f172a; border-radius: 0.5rem; overflow: hidden; }
.room-header { display: flex; justify-content: space-between; align-items: center; padding: 0.75rem 1.25rem; background: #1e293b; color: white; }
.room-header h3 { margin: 0; display: flex; align-items: center; gap: 0.5rem; }
.room-actions { display: flex; gap: 0.5rem; }
.videos { flex: 1; display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 0.75rem; padding: 1rem; }
.video-tile { position: relative; background: #000; border-radius: 0.5rem; overflow: hidden; aspect-ratio: 16/9; }
.video-tile video { width: 100%; height: 100%; object-fit: cover; }
.video-tile .tag { position: absolute; bottom: 0.5rem; left: 0.5rem; background: rgba(0,0,0,0.6); color: white; padding: 0.25rem 0.6rem; border-radius: 0.3rem; font-size: 0.85rem; }
.video-tile.self .tag { background: #3b82f6; }
</style>
