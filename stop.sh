#!/usr/bin/env bash
# openplatform_v3 — 전체 서비스 정지 (모든 override 포함, 볼륨 보존)
set -uo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
INFRA="$ROOT/infra"
PROJECT="openplatform_v3"

FILES=(-f "$INFRA/docker-compose.yml")
[ -f "$INFRA/docker-compose.healthcheck.yml" ]    && FILES+=(-f "$INFRA/docker-compose.healthcheck.yml")
[ -f "$INFRA/docker-compose.resources.yml" ]      && FILES+=(-f "$INFRA/docker-compose.resources.yml")
[ -f "$INFRA/docker-compose.traefik.yml" ]        && FILES+=(-f "$INFRA/docker-compose.traefik.yml")
[ -f "$INFRA/docker-compose.observability.yml" ]  && FILES+=(-f "$INFRA/docker-compose.observability.yml")
[ -f "$INFRA/docker-compose.cron.yml" ]           && FILES+=(-f "$INFRA/docker-compose.cron.yml")

echo "▶ Docker 컨테이너 정지 (모든 override 포함)"
docker compose -p "$PROJECT" "${FILES[@]}" down

echo "✓ 정지 완료 (볼륨 보존)"
