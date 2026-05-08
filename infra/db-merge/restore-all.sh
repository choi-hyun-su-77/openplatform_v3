#!/usr/bin/env bash
# infra/db-merge/dumps/ 의 dump 결과를 v3-postgres / v3-mongo 로 복원한다.
# --force 가 없으면 데이터가 있는 DB 는 건너뛴다.

set -euo pipefail

PG_CONTAINER="${PG_CONTAINER:-v3-postgres}"
MONGO_CONTAINER="${MONGO_CONTAINER:-v3-mongo}"
PG_USER="${PG_USER:-platform_v3}"
FORCE=0

for arg in "$@"; do
    case "$arg" in
        --force|-f) FORCE=1 ;;
        *) echo "unknown arg: $arg" >&2; exit 2 ;;
    esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DUMPS_DIR="${SCRIPT_DIR}/dumps"

step() { printf '\033[36m==> %s\033[0m\n' "$1"; }
warn() { printf '\033[33m%s\033[0m\n' "$1"; }
fail() { printf '\033[31m!! %s\033[0m\n' "$1" >&2; exit 1; }

ensure_running() {
    local name="$1"
    if ! docker ps --filter "name=^${name}$" --format '{{.Names}}' | grep -q "^${name}$"; then
        fail "Container '${name}' is not running."
    fi
}

pg_db_has_data() {
    local db="$1"
    local n
    n="$(docker exec "$PG_CONTAINER" psql -U "$PG_USER" -d "$db" -tAc \
        "SELECT count(*) FROM information_schema.tables WHERE table_schema NOT IN ('pg_catalog','information_schema') AND table_type='BASE TABLE'" 2>/dev/null || echo 0)"
    [[ "${n//[^0-9]/}" -gt 0 ]]
}

ensure_running "$PG_CONTAINER"
ensure_running "$MONGO_CONTAINER"

[[ -f "${DUMPS_DIR}/MANIFEST.json" ]] || fail "MANIFEST.json not found in ${DUMPS_DIR}. Run dump-all first or pull dumps from git."

# ---------- Postgres globals ----------
GLOBALS="${DUMPS_DIR}/postgres-globals.sql"
if [[ -f "$GLOBALS" ]]; then
    step "Apply Postgres globals (roles)"
    # CREATE ROLE may already exist; tolerate.
    docker exec -i "$PG_CONTAINER" psql -U "$PG_USER" -d postgres < "$GLOBALS" >/dev/null 2>&1 || true
fi

# ---------- Postgres databases ----------
shopt -s nullglob
for f in "${DUMPS_DIR}"/postgres-*.dump; do
    bn="$(basename "$f")"
    db="${bn#postgres-}"
    db="${db%.dump}"

    if pg_db_has_data "$db"; then
        if [[ $FORCE -eq 0 ]]; then
            warn "Skip: database '$db' already has tables. Use --force to overwrite."
            continue
        fi
        warn "Force: dropping existing objects in '$db'"
    fi

    step "Restore Postgres database '${db}'"
    remote="/tmp/${bn}"
    docker cp "$f" "${PG_CONTAINER}:${remote}"
    docker exec "$PG_CONTAINER" pg_restore -U "$PG_USER" -d "$db" --clean --if-exists --no-owner --no-privileges "$remote" || true
    docker exec "$PG_CONTAINER" rm -f "$remote"
done

# ---------- MongoDB ----------
MONGO_ARCHIVE="${DUMPS_DIR}/mongo-all.archive.gz"
if [[ -f "$MONGO_ARCHIVE" ]]; then
    step "Restore MongoDB (drop existing collections; system DBs 는 nsExclude)"
    docker cp "$MONGO_ARCHIVE" "${MONGO_CONTAINER}:/tmp/mongo-all.archive.gz"
    docker exec "$MONGO_CONTAINER" mongorestore --archive=/tmp/mongo-all.archive.gz --gzip --drop \
        --nsExclude='admin.*' --nsExclude='config.*' --nsExclude='local.*'
    docker exec "$MONGO_CONTAINER" rm -f /tmp/mongo-all.archive.gz
fi

printf '\n\033[32mRestore complete.\033[0m\n'
