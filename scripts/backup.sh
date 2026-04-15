#!/usr/bin/env bash
# =============================================================================
# openplatform v3 — 전체 백업 스크립트
# -----------------------------------------------------------------------------
# 대상:
#   1) PostgreSQL (v3-postgres)        — pg_dumpall 전체 DB
#   2) MinIO      (v3-minio)           — mc mirror 로 모든 버킷 미러링
#   3) Keycloak   (v3-keycloak)        — realm export (openplatform-v3)
#   4) OpenLDAP   (v3-openldap)        — ldapsearch 로 LDIF dump
#   5) Rocket.Chat  (v3-mongo)         — mongodump 로 rocketchat DB 덤프
#   6) Wiki.js    (v3-wikijs)          — sqlite 또는 pg dump
# 결과: backups/v3-YYYYMMDD-HHMMSS.tar.gz
# =============================================================================

set -euo pipefail

# MSYS/Git Bash 의 경로 변환 비활성화 (Docker 내부 /opt/... 경로가 Windows 로 변환되는 것 방지)
export MSYS_NO_PATHCONV=1
export MSYS2_ARG_CONV_EXCL="*"

# Postgres superuser 이름 (환경변수로 오버라이드 가능)
PG_USER="${PG_USER:-platform_v3}"

# ─── 설정 ────────────────────────────────────────────────────────────────────
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_ROOT="${ROOT_DIR}/backups"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
WORK_DIR="${BACKUP_ROOT}/v3-${TIMESTAMP}"
ARCHIVE="${BACKUP_ROOT}/v3-${TIMESTAMP}.tar.gz"
LOG="${BACKUP_ROOT}/backup-${TIMESTAMP}.log"

# ─── 로그 헬퍼 ───────────────────────────────────────────────────────────────
log()  { echo "[$(date +%H:%M:%S)] $*" | tee -a "${LOG}"; }
warn() { echo "[$(date +%H:%M:%S)] WARN: $*" | tee -a "${LOG}" >&2; }
fail() { echo "[$(date +%H:%M:%S)] FAIL: $*" | tee -a "${LOG}" >&2; exit 1; }

# ─── 컨테이너 존재 확인 ──────────────────────────────────────────────────────
container_exists() {
    docker ps -a --format '{{.Names}}' | grep -q "^$1$"
}

# ─── 디렉터리 준비 ───────────────────────────────────────────────────────────
mkdir -p "${WORK_DIR}" "${BACKUP_ROOT}"
log "백업 시작: ${WORK_DIR}"
log "로그 파일: ${LOG}"

# ─── 1. PostgreSQL 전체 DB 덤프 ──────────────────────────────────────────────
log "[1/6] PostgreSQL 전체 DB pg_dumpall 실행..."
if container_exists v3-postgres; then
    docker exec v3-postgres bash -c "pg_dumpall -U ${PG_USER}" \
        > "${WORK_DIR}/postgres-dumpall.sql" \
        2>>"${LOG}" \
        || warn "postgres 덤프 실패 — 계속 진행"
    log "    → $(du -h "${WORK_DIR}/postgres-dumpall.sql" 2>/dev/null | cut -f1 || echo '?') 완료"
else
    warn "v3-postgres 컨테이너 없음 — 스킵"
fi

# ─── 2. MinIO 버킷 미러링 ────────────────────────────────────────────────────
log "[2/6] MinIO 버킷 mc mirror 실행..."
if container_exists v3-minio; then
    mkdir -p "${WORK_DIR}/minio"
    # mc 클라이언트를 임시 컨테이너로 기동하여 같은 네트워크에서 mirror 수행
    docker exec v3-minio sh -c "
            mc alias set local http://localhost:9000 v3minio v3minio_pass >/dev/null 2>&1 &&
            mc mirror --overwrite local /tmp/backup-mirror
        " 2>>"${LOG}" \
        && docker cp v3-minio:/tmp/backup-mirror "${WORK_DIR}/minio" 2>>"${LOG}" \
        && docker exec v3-minio rm -rf /tmp/backup-mirror 2>>"${LOG}" \
        || warn "minio mirror 실패"
    log "    → minio 버킷 미러 완료"
else
    warn "v3-minio 컨테이너 없음 — 스킵"
fi

# ─── 3. Keycloak realm export ────────────────────────────────────────────────
log "[3/6] Keycloak realm export 실행..."
if container_exists v3-keycloak; then
    docker exec v3-keycloak /opt/keycloak/bin/kc.sh export \
        --dir /tmp/kc-export \
        --realm openplatform-v3 \
        --users realm_file \
        2>>"${LOG}" \
        || warn "keycloak export 실패 — 실행 중인 서버에서는 kc.sh export 불가할 수 있음"
    mkdir -p "${WORK_DIR}/keycloak"
    # MSYS 경로 변환 회피: 더블 슬래시 + exec cat 으로 파일별 스트림
    for f in $(docker exec v3-keycloak sh -c 'ls //tmp//kc-export//' 2>/dev/null); do
        docker exec v3-keycloak cat "//tmp//kc-export//$f" > "${WORK_DIR}/keycloak/$f" 2>>"${LOG}" \
            || warn "keycloak file $f 복사 실패"
    done
    log "    → keycloak realm export 완료"
else
    warn "v3-keycloak 컨테이너 없음 — 스킵"
fi

# ─── 4. OpenLDAP ldapsearch dump ─────────────────────────────────────────────
log "[4/6] OpenLDAP ldapsearch LDIF dump 실행..."
if container_exists v3-openldap; then
    docker exec v3-openldap bash -c '
        ldapsearch -x -H ldap://localhost \
            -D "cn=admin,dc=v3,dc=local" \
            -w adminpass \
            -b "dc=v3,dc=local"
    ' > "${WORK_DIR}/ldap-dump.ldif" 2>>"${LOG}" \
        || warn "ldapsearch 실패"
    log "    → ldap LDIF dump 완료"
else
    warn "v3-openldap 컨테이너 없음 — 스킵 (optional)"
fi

# ─── 5. Rocket.Chat Mongo dump ────────────────────────────────────────────────
log "[5/6] Rocket.Chat Mongo dump..."
if container_exists v3-mongo; then
    docker exec v3-mongo bash -c 'mongodump --archive --db=rocketchat' \
        > "${WORK_DIR}/rocketchat-mongo.archive" \
        2>>"${LOG}" \
        || warn "mongodump 실패"
    log "    → rocketchat mongodump 완료"
else
    warn "v3-mongo 컨테이너 없음 — 스킵"
fi

# ─── 6. Wiki.js DB 백업 ──────────────────────────────────────────────────────
log "[6/6] Wiki.js DB 백업..."
if container_exists v3-wikijs; then
    # sqlite 또는 pg 사용 가능 — 우선 sqlite 파일 존재 확인
    if docker exec v3-wikijs bash -c 'test -f /wiki/db.sqlite' 2>/dev/null; then
        docker cp v3-wikijs:/wiki/db.sqlite "${WORK_DIR}/wikijs-db.sqlite" 2>>"${LOG}" \
            || warn "wikijs sqlite 복사 실패"
        log "    → wikijs sqlite 백업 완료"
    else
        log "    → wikijs 는 postgres 에 저장됨 (1번 덤프 포함)"
    fi
else
    warn "v3-wikijs 컨테이너 없음 — 스킵"
fi

# ─── 압축 ────────────────────────────────────────────────────────────────────
log "tar.gz 아카이브 생성 중..."
tar -czf "${ARCHIVE}" -C "${BACKUP_ROOT}" "v3-${TIMESTAMP}" 2>>"${LOG}" \
    || fail "tar 압축 실패"

# ─── 정리 ────────────────────────────────────────────────────────────────────
rm -rf "${WORK_DIR}"
SIZE="$(du -h "${ARCHIVE}" | cut -f1)"

log "============================================================"
log "백업 완료: ${ARCHIVE}"
log "크기: ${SIZE}"
log "로그: ${LOG}"
log "============================================================"
