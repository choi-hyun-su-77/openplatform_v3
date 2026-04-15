# LiveKit 화상회의 수동 검증 가이드 (F-8)

헤드리스 Playwright 는 카메라/마이크 디바이스가 없어 자동 검증이 불가하므로, 실제 브라우저에서 5분 수동 확인한다.

## 사전 조건
- `docker compose -f infra/docker-compose.yml ps` 로 v3-livekit 이 `Up (healthy)` 인지 확인
- 브라우저(Chrome/Edge/Firefox)가 설치된 Windows/macOS 호스트
- 카메라/마이크가 물리적으로 연결되어 있고 OS 권한이 허용됨

## 1인 테스트 (단일 참가자)
1. 브라우저에서 http://localhost:19173 접속
2. `admin` / `admin` 으로 로그인
3. 좌측 사이드바 **화상회의** 클릭
4. 룸 이름 `v3-manual-test` 입력 → **룸 생성/입장** 클릭
5. 브라우저 카메라/마이크 권한 허용 팝업 → **허용**
6. 자기 비디오가 `나` 타일에 표시되는지 확인
7. 마이크 켜기/끄기, 카메라 켜기/끄기 버튼 토글 동작 확인
8. **나가기** 버튼 → 초기 화면 복귀

## 2인 테스트 (참가자 구독 + 트랙 publish)
1. 브라우저 A 창(시크릿 모드): admin 로 로그인 → 룸 `v3-multi` 입장
2. 브라우저 B 창(다른 프로필 또는 다른 브라우저): user1 / user1 로 로그인 → 동일 룸 `v3-multi` 입장
3. A 화면에서 B 의 비디오 타일이 추가로 나타나는지 확인
4. B 에서 마이크 끄기 → A 의 상대 오디오가 중단되는지 확인
5. B 에서 나가기 → A 의 B 타일이 사라지는지 확인

## 통과 기준 (inspection.md Type A 준수)
- [ ] `/api/bff/video/token` POST 응답 200 + token/room/wsUrl JSON (DevTools Network 확인)
- [ ] `wss://...:19880` WebSocket 연결이 `101 Switching Protocols` 로 성립
- [ ] ICE 상태 `connected` 도달 (DevTools `chrome://webrtc-internals` or Firefox `about:webrtc`)
- [ ] 자기 비디오 HTML `<video>` element 에 `readyState >= 2` 및 프레임 전송
- [ ] 상대 참가자의 `RemoteTrack` 수신 이벤트가 발생 (2인 테스트)

## 실패 시 점검 순서
1. `docker logs v3-livekit --tail 50` — `ICE candidate gathering` 로그 확인
2. 방화벽에서 UDP 19882 / TCP 19880,19881 허용 여부 확인 (Windows Defender)
3. LiveKit 컨테이너 재기동: `docker compose restart livekit`
4. `curl http://localhost:19880` → `404 Not Found` 응답이면 signaling 포트 정상 (LiveKit 은 WS 만 받음)

## 기록
통과 시 `warn.md` 하단에 `[YYYY-MM-DD HH:MM] F-8 수동 검증 통과 (테스터명)` 한 줄 추가.
