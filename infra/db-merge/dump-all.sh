#!/usr/bin/env bash
# openplatform_v3 의 PostgreSQL + MongoDB 모든 DB 를 한 번에 dump 한다.
# 결과: infra/db-merge/dumps/

set -euo pipefail

PG_CONTAINER="${PG_CONTAINER:-v3-postgres}"
MONGO_CONTAINER="${MONGO_CONTAINER:-v3-mongo}"
PG_USER="${PG_USER:-platform_v3}"
# 로그성 테이블/컬렉션 제외 패턴. Postgres: 데이터만 제외(스키마 유지). Mongo: 컬렉션 자체 제외.
EXCLUDE_REGEX="${EXCLUDE_REGEX:-(^|_)(log|logs|audit)($|_|s)|^event_entity\$|^admin_event_entity\$}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DUMPS_DIR="${SCRIPT_DIR}/dumps"
mkdir -p "$DUMPS_DIR"

step() { printf '\033[36m==> %s\033[0m\n' "$1"; }
fail() { printf '\033[31m!! %s\033[0m\n' "$1" >&2; exit 1; }

ensure_running() {
    local name="$1"
    if ! docker ps --filter "name=^${name}$" --format '{{.Names}}' | grep -q "^${name}$"; then
        fail "Container '${name}' is not running. Start the v3 stack first."
    fi
}

ensure_running "$PG_CONTAINER"
ensure_running "$MONGO_CONTAINER"

PG_DBS=(platform_v3 wiki_v3)

step "Dump Postgres globals (roles, tablespaces)"
docker exec "$PG_CONTAINER" sh -c "pg_dumpall -U ${PG_USER} --globals-only --no-role-passwords > /tmp/postgres-globals.sql"
docker cp "${PG_CONTAINER}:/tmp/postgres-globals.sql" "${DUMPS_DIR}/postgres-globals.sql"
docker exec "$PG_CONTAINER" rm -f /tmp/postgres-globals.sql

for db in "${PG_DBS[@]}"; do
    # 로그성 테이블 목록 동적 조회 → --exclude-table-data 로 데이터만 제외 (스키마 유지).
    sql="SELECT table_schema || '.' || table_name FROM information_schema.tables WHERE table_schema NOT IN ('pg_catalog','information_schema') AND table_type='BASE TABLE' AND table_name ~* '${EXCLUDE_REGEX}' ORDER BY 1"
    excluded_raw="$(docker exec "$PG_CONTAINER" psql -U "$PG_USER" -d "$db" -tAc "$sql")"
    exclude_args=()
    while IFS= read -r line; do
        line="${line//[$'\t\r ']}"
        [[ -z "$line" ]] && continue
        exclude_args+=(--exclude-table-data "$line")
    done <<< "$excluded_raw"

    if [[ ${#exclude_args[@]} -gt 0 ]]; then
        printf '    excluded log tables in %s: %s\n' "$db" "$(echo "$excluded_raw" | tr '\n' ',' | sed 's/,$//')"
    fi

    step "Dump Postgres database '${db}' (custom format, compression 9)"
    docker exec "$PG_CONTAINER" pg_dump -U "$PG_USER" -d "$db" -F c -Z 9 -f "/tmp/postgres-${db}.dump" "${exclude_args[@]}"
    docker cp "${PG_CONTAINER}:/tmp/postgres-${db}.dump" "${DUMPS_DIR}/postgres-${db}.dump"
    docker exec "$PG_CONTAINER" rm -f "/tmp/postgres-${db}.dump"
done

step "Identify mongo log collections"
mongo_excluded="$(docker exec "$MONGO_CONTAINER" mongosh --quiet --eval "
let names = new Set();
db.getMongo().getDBNames().filter(n => !['admin','config','local'].includes(n)).forEach(dbn => {
  db.getSiblingDB(dbn).getCollectionNames().forEach(c => {
    if (/${EXCLUDE_REGEX}/i.test(c)) names.add(c);
  });
});
print(Array.from(names).join('\n'));
")"
mongo_exclude_flags=""
while IFS= read -r line; do
    line="${line//[$'\t\r ']}"
    [[ -z "$line" ]] && continue
    mongo_exclude_flags+=" --excludeCollection=${line}"
done <<< "$mongo_excluded"
[[ -n "${mongo_excluded//[$'\n\r\t ']}" ]] && printf '    excluded mongo collections: %s\n' "$(echo "$mongo_excluded" | tr '\n' ',' | sed 's/,$//')"

step "Dump MongoDB (all DBs, archive+gzip — admin/config/local 은 restore 단계에서 nsExclude)"
docker exec "$MONGO_CONTAINER" sh -c "mongodump --quiet --archive=/tmp/mongo-all.archive.gz --gzip${mongo_exclude_flags}"
docker cp "${MONGO_CONTAINER}:/tmp/mongo-all.archive.gz" "${DUMPS_DIR}/mongo-all.archive.gz"
docker exec "$MONGO_CONTAINER" rm -f /tmp/mongo-all.archive.gz

step "Write MANIFEST.json"
MANIFEST="${DUMPS_DIR}/MANIFEST.json"
{
    printf '{\n'
    printf '  "createdAtUtc": "%s",\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf '  "host": "%s",\n' "$(hostname)"
    printf '  "postgresContainer": "%s",\n' "$PG_CONTAINER"
    printf '  "mongoContainer": "%s",\n' "$MONGO_CONTAINER"
    printf '  "postgresDatabases": ['
    for i in "${!PG_DBS[@]}"; do
        [[ $i -gt 0 ]] && printf ', '
        printf '"%s"' "${PG_DBS[$i]}"
    done
    printf '],\n'
    printf '  "files": [\n'
    first=1
    for f in "${DUMPS_DIR}"/*; do
        bn="$(basename "$f")"
        [[ "$bn" == "MANIFEST.json" ]] && continue
        [[ "$bn" == .* ]] && continue
        bytes=$(wc -c < "$f" | tr -d ' ')
        sha=$(sha256sum "$f" | awk '{print $1}')
        [[ $first -eq 0 ]] && printf ',\n'
        printf '    {"name": "%s", "bytes": %s, "sha256": "%s"}' "$bn" "$bytes" "$sha"
        first=0
    done
    printf '\n  ]\n'
    printf '}\n'
} > "$MANIFEST"

printf '\n\033[32mDump complete. Files in %s:\033[0m\n' "$DUMPS_DIR"
ls -lh "$DUMPS_DIR"
