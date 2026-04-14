#!/usr/bin/env bash
# =============================================================================
# openplatform v3 — 전체 복원 스크립트
# -----------------------------------------------------------------------------
# 사용법: bash scripts/restore.sh backups/v3-YYYYMMDD-HHMMSS.tar.gz
#
# 주의:
#   - backend-core, backend-bff 는 반드시 중단한 상태에서 실행
#   - Keycloak, Wiki.js, Mattermost 는 복원 전후 재기동 필요
#   - 기존 데이터는 덮어써지므로 위험도 높음 → 운영 환경에서는 별도 확인 절차 필수
# =============================================================================

set -euo pipefail

# ─── 인자 검증 ───────────────────────────────────────────────────────────────
if [[ $# -lt 1 ]]; then
    echo "사용법: $0 <backups/v3-YYYYMMDD-HHMMSS.tar.gz>"
    exit 1
fi

ARCHIVE="$1"
if [[ ! -f "${ARCHIVE}" ]]; then
    echo "FAIL: 아카이브 파일 없음 — ${ARCHIVE}"
    exit 1
fi

# ─── 설정 ────────────────────────────────────────────────────────────────────
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RESTORE_DIR="${ROOT_DIR}/backups/restore-tmp-$(date +%s)"
LOG="${ROOT_DIR}/backups/restore-$(date +%Y%m%d-%H%M%S).log"

# ─── 로그 헬퍼 ───────────────────────────────────────────────────────────────
log()  { echo "[$(date +%H:%M:%S)] $*" | tee -a "${LOG}"; }
warn() { echo "[$(date +%H:%M:%S)] WARN: $*" | tee -a "${LOG}" >&2; }
fail() { echo "[$(date +%H:%M:%S)] FAIL: $*" | tee -a "${LOG}" >&2; exit 1; }

container_exists() {
    docker ps -a --format '{{.Names}}' | grep -q "^$1$"
}

mkdir -p "${RESTORE_DIR}"
log "복원 시작: ${ARCHIVE}"
log "작업 디렉터리: ${RESTORE_DIR}"

# ─── 1. 아카이브 해제 ────────────────────────────────────────────────────────
log "[0/6] tar.gz 해제 중..."
tar -xzf "${ARCHIVE}" -C "${RESTORE_DIR}" 2>>"${LOG}" \
    || fail "tar 해제 실패"

# 해제된 최상위 디렉터리 탐색 (v3-YYYYMMDD-HHMMSS)
SRC_DIR="$(find "${RESTORE_DIR}" -maxdepth 1 -mindepth 1 -type d | head -n1)"
[[ -d "${SRC_DIR}" ]] || fail "해제된 백업 디렉터리를 찾지 못함"
log "    → 복원 원본: ${SRC_DIR}"

# ─── 2. 안전 체크 — 애플리케이션 중단 여부 ──────────────────────────────────
log "[확인] backend 컨테이너 중단 여부 확인..."
for c in v3-backend-core v3-backend-bff; do
    if container_exists "$c" && docker ps --format '{{.Names}}' | grep -q "^$c$"; then
        warn "${c} 가 실행 중입니다. 계속하려면 5초 내에 Ctrl+C 로 중단하지 마십시오."
        sleep 5
    fi
done

# ─── 3. PostgreSQL 복원 ──────────────────────────────────────────────────────
log "[1/6] PostgreSQL 복원..."
if [[ -f "${SRC_DIR}/postgres-dumpall.sql" ]] && container_exists v3-postgres; then
    docker exec -i v3-postgres psql -U postgres < "${SRC_DIR}/postgres-dumpall.sql" \
        2>>"${LOG}" \
        || warn "postgres 복원 중 오류 발생 — 로그 확인"
    log "    → postgres 복원 완료"
else
    warn "postgres 덤프 파일 또는 컨테이너 없음 — 스킵"
fi

# ─── 4. MinIO 복원 (mc mirror 역방향) ────────────────────────────────────────
log "[2/6] MinIO 버킷 복원..."
if [[ -d "${SRC_DIR}/minio" ]] && container_exists v3-minio; then
    docker run --rm \
        --network container:v3-minio \
        -v "${SRC_DIR}/minio:/backup:ro" \
        --entrypoint sh \
        minio/mc -c '
            mc alias set local http://localhost:9000 minioadmin minioadmin &&
            mc mirror --overwrite /backup local
        ' 2>>"${LOG}" \
        || warn "minio mirror 복원 실패"
    log "    → minio 버킷 복원 완료"
else
    warn "minio 백업 없음 — 스킵"
fi

# ─── 5. Keycloak realm import ────────────────────────────────────────────────
log "[3/6] Keycloak realm 복원..."
if [[ -d "${SRC_DIR}/keycloak" ]] && container_exists v3-keycloak; then
    docker cp "${SRC_DIR}/keycloak/." v3-keycloak:/tmp/kc-restore/ 2>>"${LOG}" \
        || warn "keycloak 파일 복사 실패"
    docker exec v3-keycloak /opt/keycloak/bin/kc.sh import \
        --dir /tmp/kc-restore --override true \
        2>>"${LOG}" \
        || warn "keycloak import 실패 — 서버 중단 상태에서만 가능할 수 있음"
    log "    → keycloak realm 복원 완료 (재기동 필요)"
else
    warn "keycloak 백업 없음 — 스킵"
fi

# ─── 6. OpenLDAP 복원 (ldapadd) ──────────────────────────────────────────────
log "[4/6] OpenLDAP LDIF 복원..."
if [[ -f "${SRC_DIR}/ldap-dump.ldif" ]] && container_exists v3-openldap; then
    docker cp "${SRC_DIR}/ldap-dump.ldif" v3-openldap:/tmp/restore.ldif 2>>"${LOG}"
    docker exec v3-openldap bash -c '
        ldapadd -x -H ldap://localhost \
            -D "cn=admin,dc=openplatform,dc=v3" \
            -w admin \
            -c -f /tmp/restore.ldif
    ' 2>>"${LOG}" \
        || warn "ldapadd 오류 (이미 존재하는 엔터티는 정상)"
    log "    → ldap 복원 완료"
else
    warn "ldap 백업 없음 — 스킵"
fi

# ─── 7. Rocket.Chat Mongo 복원 ───────────────────────────────────────────────
log "[5/6] Rocket.Chat Mongo 복원..."
if [[ -f "${SRC_DIR}/rocketchat-mongo.archive" ]] && container_exists v3-rocketchat-mongo; then
    docker exec -i v3-rocketchat-mongo bash -c 'mongorestore --archive --drop' \
        < "${SRC_DIR}/rocketchat-mongo.archive" \
        2>>"${LOG}" \
        || warn "mongorestore 실패"
    log "    → rocketchat mongo 복원 완료"
else
    log "    → mongo 백업 없음 (mattermost 는 postgres 경유, 1번에서 복원됨)"
fi

# ─── 8. Wiki.js DB 복원 ──────────────────────────────────────────────────────
log "[6/6] Wiki.js DB 복원..."
if [[ -f "${SRC_DIR}/wikijs-db.sqlite" ]] && container_exists v3-wikijs; then
    docker cp "${SRC_DIR}/wikijs-db.sqlite" v3-wikijs:/wiki/db.sqlite 2>>"${LOG}" \
        || warn "wikijs sqlite 복사 실패"
    log "    → wikijs sqlite 복원 완료 (컨테이너 재기동 필요)"
else
    log "    → wikijs 는 postgres 경유 (1번에서 복원됨)"
fi

# ─── 정리 ────────────────────────────────────────────────────────────────────
rm -rf "${RESTORE_DIR}"

log "============================================================"
log "복원 완료"
log "재기동 권장: docker compose restart v3-keycloak v3-wikijs v3-backend-core v3-backend-bff"
log "로그: ${LOG}"
log "============================================================"
