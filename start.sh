#!/usr/bin/env bash
# openplatform_v3 — 전체 서비스 기동
# 기본 16개 서비스 + healthcheck/resources override 포함 (full 모드)
# Traefik / observability 가 필요하면 -t 또는 -o 인자 추가
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
INFRA="$ROOT/infra"
PROJECT="openplatform_v3"

WITH_TRAEFIK=0
WITH_OBSERVABILITY=0
WITH_CRON=0

for arg in "$@"; do
  case "$arg" in
    -t|--traefik)        WITH_TRAEFIK=1 ;;
    -o|--observability)  WITH_OBSERVABILITY=1 ;;
    -c|--cron)           WITH_CRON=1 ;;
    --production)        WITH_TRAEFIK=1; WITH_OBSERVABILITY=1; WITH_CRON=1 ;;
  esac
done

FILES=(-f "$INFRA/docker-compose.yml")
[ -f "$INFRA/docker-compose.healthcheck.yml" ] && FILES+=(-f "$INFRA/docker-compose.healthcheck.yml")
[ -f "$INFRA/docker-compose.resources.yml" ]   && FILES+=(-f "$INFRA/docker-compose.resources.yml")
if [ "$WITH_TRAEFIK" = 1 ] && [ -f "$INFRA/docker-compose.traefik.yml" ]; then
  FILES+=(-f "$INFRA/docker-compose.traefik.yml")
fi
if [ "$WITH_OBSERVABILITY" = 1 ] && [ -f "$INFRA/docker-compose.observability.yml" ]; then
  FILES+=(-f "$INFRA/docker-compose.observability.yml")
fi
if [ "$WITH_CRON" = 1 ] && [ -f "$INFRA/docker-compose.cron.yml" ]; then
  FILES+=(-f "$INFRA/docker-compose.cron.yml")
fi

echo "▶ Docker 컨테이너 기동 (openplatform_v3)"
docker compose -p "$PROJECT" "${FILES[@]}" up -d

echo
echo "==================================================="
echo "  UI Frontend        : http://localhost:19173"
echo "  UI (vite dev)      : http://localhost:25174  (cd ui && npm run dev)"
echo "  Backend Core       : http://localhost:19090"
echo "  Backend BFF        : http://localhost:19091"
echo "  Keycloak           : http://localhost:19281/admin     (or http://kc.localtest.me:19281)"
echo "  MinIO Console      : http://localhost:19901"
echo "  Rocket.Chat        : http://localhost:19065"
echo "  Wiki.js            : http://localhost:19001"
echo "  Stalwart Webmail   : http://localhost:19480"
echo "  LiveKit (RTC)      : ws://localhost:19880"
[ "$WITH_OBSERVABILITY" = 1 ] && echo "  Grafana            : http://localhost:19300"
[ "$WITH_OBSERVABILITY" = 1 ] && echo "  Prometheus         : http://localhost:19309"
[ "$WITH_TRAEFIK" = 1 ]       && echo "  Traefik dashboard  : http://localhost:18082"
echo "  옵션               : -t (traefik) / -o (observability) / -c (cron) / --production (전체)"
echo "  정지               : ./stop.sh"
echo "==================================================="
