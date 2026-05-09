#!/usr/bin/env bash
# blockchain-dapp-fw data-merge orchestrator (POSIX bash)
# Multi-DB capable: discovers .env.merge.* files in db/snapshot/ and processes each
# Subcommands: export | import | verify | status
# Default (no arg) = import
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SNAPSHOT_DIR="$SCRIPT_DIR/db/snapshot"
MODULE_NAME="$(basename "$SCRIPT_DIR")"

discover_labels() {
    local found=0
    for f in "$SNAPSHOT_DIR"/.env.merge.*; do
        [[ -f "$f" ]] || continue
        local lbl="${f##*.env.merge.}"
        echo "$lbl"
        found=1
    done
    if [[ $found -eq 0 && -f "$SNAPSHOT_DIR/.env.merge" ]]; then
        echo ""
    fi
}

label_files() {
    local lbl="$1" suffix=""
    [[ -n "$lbl" ]] && suffix=".$lbl"
    echo "ENV=$SNAPSHOT_DIR/.env.merge$suffix"
    echo "TABLES=$SNAPSHOT_DIR/tables$suffix.txt"
    echo "SCHEMA=$SNAPSHOT_DIR/schema$suffix.sql"
    echo "DATA=$SNAPSHOT_DIR/data$suffix.sql"
    echo "LABEL=${lbl:-main}"
}

load_env() {
    set -a; source "$1"; set +a
    DB_SCHEMA="${DB_SCHEMA:-public}"
}

read_whitelist() {
    [[ -f "$1" ]] || return 0
    grep -v '^\s*#' "$1" | grep -v '^\s*$' | tr -d '\r'
}

wait_pg() {
    local timeout="${1:-60}" deadline=$(($(date +%s) + timeout))
    while [[ $(date +%s) -lt $deadline ]]; do
        docker exec "$DB_CONTAINER" pg_isready -U "$DB_USER" -d "$DB_NAME" >/dev/null 2>&1 && return 0
        sleep 2
    done
    return 1
}

build_args() {
    while IFS= read -r t; do
        printf -- "--table %s.%s " "$DB_SCHEMA" "$t"
    done < <(read_whitelist "$1")
}

status_one() {
    eval "$(label_files "$1")"
    load_env "$ENV"
    if [[ "$(docker ps --filter "name=^${DB_CONTAINER}$" --format '{{.Names}}')" != "$DB_CONTAINER" ]]; then
        echo "[!] [$LABEL] container '$DB_CONTAINER' is NOT running"
        return 1
    fi
    if wait_pg 5; then
        local count; count=$(read_whitelist "$TABLES" | wc -l)
        echo "[+] [$LABEL] $DB_CONTAINER ready (DB=$DB_NAME, $count tables)"
    else
        echo "[!] [$LABEL] DB '$DB_NAME' not accepting connections"
    fi
}

export_one() {
    eval "$(label_files "$1")"
    load_env "$ENV"
    wait_pg 60 || { echo "[$LABEL] DB not ready"; return 1; }
    local tables count; tables=$(read_whitelist "$TABLES")
    count=$(echo "$tables" | grep -c . || echo 0)
    if [[ "$count" -eq 0 ]]; then
        echo "[*] [$LABEL] no tables — skip"; return
    fi
    echo "[*] [$LABEL] exporting $count tables from '$DB_NAME'..."
    local args; args=$(build_args "$TABLES")

    local tmp; tmp=$(mktemp)
    # shellcheck disable=SC2086
    docker exec -e PGPASSWORD="$DB_PASSWORD" "$DB_CONTAINER" pg_dump \
        -U "$DB_USER" -d "$DB_NAME" --schema-only --no-owner --no-acl --no-comments \
        $args > "$tmp"
    {
        echo "-- ============================================================"
        echo "-- $MODULE_NAME [$LABEL] — schema.sql (idempotent)"
        echo "-- Generated: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "-- DB: $DB_NAME @ $DB_CONTAINER"
        echo "-- Tables: $count (whitelist 기반)"
        echo "-- ============================================================"
        echo ""
        sed -e 's/CREATE TABLE \([^I]\)/CREATE TABLE IF NOT EXISTS \1/g' \
            -e 's/CREATE INDEX \([^I]\)/CREATE INDEX IF NOT EXISTS \1/g' \
            -e 's/CREATE UNIQUE INDEX \([^I]\)/CREATE UNIQUE INDEX IF NOT EXISTS \1/g' \
            -e 's/CREATE SEQUENCE \([^I]\)/CREATE SEQUENCE IF NOT EXISTS \1/g' \
            "$tmp"
    } > "$SCHEMA"
    rm -f "$tmp"

    tmp=$(mktemp)
    # shellcheck disable=SC2086
    docker exec -e PGPASSWORD="$DB_PASSWORD" "$DB_CONTAINER" pg_dump \
        -U "$DB_USER" -d "$DB_NAME" --data-only --column-inserts --on-conflict-do-nothing \
        --no-owner --no-acl --disable-triggers \
        $args > "$tmp"
    {
        echo "-- ============================================================"
        echo "-- $MODULE_NAME [$LABEL] — data.sql (idempotent merge)"
        echo "-- Generated: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "-- DB: $DB_NAME @ $DB_CONTAINER"
        echo "-- Mode: INSERT ... ON CONFLICT DO NOTHING"
        echo "-- ============================================================"
        echo ""
        cat "$tmp"
    } > "$DATA"
    rm -f "$tmp"

    local ic; ic=$(grep -c '^INSERT INTO' "$DATA" || true)
    echo "[+] [$LABEL] schema $(du -k "$SCHEMA" | cut -f1) KB / data $(du -k "$DATA" | cut -f1) KB ($ic INSERT)"
}

import_one() {
    eval "$(label_files "$1")"
    load_env "$ENV"
    wait_pg 60 || { echo "[$LABEL] DB not ready"; return 1; }
    [[ -f "$SCHEMA" ]] || { echo "[$LABEL] missing $(basename "$SCHEMA")" >&2; return 1; }
    [[ -f "$DATA"   ]] || { echo "[$LABEL] missing $(basename "$DATA")"   >&2; return 1; }
    echo "[*] [$LABEL] applying $(basename "$SCHEMA")..."
    docker exec -i -e PGPASSWORD="$DB_PASSWORD" "$DB_CONTAINER" \
        psql -U "$DB_USER" -d "$DB_NAME" -v ON_ERROR_STOP=0 < "$SCHEMA" >/dev/null
    echo "[*] [$LABEL] applying $(basename "$DATA")..."
    docker exec -i -e PGPASSWORD="$DB_PASSWORD" "$DB_CONTAINER" \
        psql -U "$DB_USER" -d "$DB_NAME" -v ON_ERROR_STOP=0 < "$DATA" >/dev/null
    echo "[+] [$LABEL] applied (PK 충돌 행은 skip)"
}

verify_one() {
    eval "$(label_files "$1")"
    load_env "$ENV"
    wait_pg 5 || { echo "[!] [$LABEL] DB not ready"; return; }
    echo "[*] [$LABEL] row counts ($DB_NAME):"
    while IFS= read -r t; do
        local cnt
        cnt=$(docker exec -e PGPASSWORD="$DB_PASSWORD" "$DB_CONTAINER" \
            psql -U "$DB_USER" -d "$DB_NAME" -tAc "SELECT COUNT(*) FROM $DB_SCHEMA.$t" 2>/dev/null || echo "(missing)")
        printf "  %-40s %10s\n" "$t" "$cnt"
    done < <(read_whitelist "$TABLES")
}

mapfile -t LABELS < <(discover_labels)
[[ ${#LABELS[@]} -gt 0 ]] || { echo "No .env.merge or .env.merge.* in $SNAPSHOT_DIR" >&2; exit 1; }

cmd="${1:-import}"
case "$cmd" in
    status) for l in "${LABELS[@]}"; do status_one "$l"; done ;;
    export) for l in "${LABELS[@]}"; do export_one "$l"; done; echo "[*] git add db/snapshot/ && git commit && git push 로 공유하세요." ;;
    import) for l in "${LABELS[@]}"; do import_one "$l"; done; for l in "${LABELS[@]}"; do verify_one "$l"; done ;;
    verify) for l in "${LABELS[@]}"; do verify_one "$l"; done ;;
    help)
        echo "Usage: $0 [export|import|verify|status]"
        echo "  Detected DB labels: ${LABELS[*]:-(none)}"
        ;;
    *) echo "Unknown: $cmd" >&2; exit 2 ;;
esac
