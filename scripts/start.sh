#!/usr/bin/env bash
# =============================================================================
# openplatform v3 — 통합 기동 스크립트
# =============================================================================
# 사용법: ./scripts/start.sh [mode]
# mode: dev / full / observability / traefik / production / stop / status / logs <name>
# =============================================================================

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

BASE="-f infra/docker-compose.yml"
HEALTH="-f infra/docker-compose.healthcheck.yml"
RESOURCES="-f infra/docker-compose.resources.yml"
OBSERVABILITY="-f infra/docker-compose.observability.yml"
TRAEFIK="-f infra/docker-compose.traefik.yml"
CRON="-f infra/docker-compose.cron.yml"

MODE="${1:-full}"

case "$MODE" in
    dev)
        echo "▶ 개발 모드"
        docker compose $BASE up -d
        ;;
    full)
        echo "▶ 기본 모드 (healthcheck + resources)"
        docker compose $BASE $HEALTH $RESOURCES up -d
        ;;
    observability)
        echo "▶ 관측 모드"
        docker compose $BASE $HEALTH $RESOURCES $OBSERVABILITY up -d
        ;;
    traefik)
        echo "▶ 프록시 모드"
        docker compose $BASE $HEALTH $RESOURCES $TRAEFIK up -d
        ;;
    production|prod)
        echo "▶ 운영 모드 (전체 override)"
        docker compose $BASE $HEALTH $RESOURCES $OBSERVABILITY $TRAEFIK $CRON up -d
        ;;
    stop|down)
        docker compose $BASE $HEALTH $RESOURCES $OBSERVABILITY $TRAEFIK $CRON down
        ;;
    status)
        docker ps --filter name=v3- --format 'table {{.Names}}\t{{.Status}}'
        echo
        for c in $(docker ps --filter name=v3- --format '{{.Names}}'); do
            h=$(docker inspect --format '{{.State.Health.Status}}' "$c" 2>/dev/null || echo "-")
            printf "  %-20s %s\n" "$c" "$h"
        done
        ;;
    logs)
        docker logs -f "${2:?사용법: $0 logs <service-name>}"
        ;;
    init-mongo)
        docker compose $BASE --profile init up mongo-init
        docker compose $BASE --profile init rm -f mongo-init
        ;;
    *)
        echo "사용법: $0 [dev|full|observability|traefik|production|stop|status|logs|init-mongo]"
        exit 1
        ;;
esac
echo
echo "✓ 완료. 상태: $0 status"
