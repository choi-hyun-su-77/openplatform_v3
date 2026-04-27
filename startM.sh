#!/usr/bin/env bash
# openplatform v3 — 서비스 일괄 기동
# 사용: ./start.sh
set -e
cd "$(dirname "$0")"

echo "▶ traefik-net 네트워크 보장"
docker network create traefik-net 2>/dev/null || true

echo "▶ v3 스택 기동 (docker compose up -d)"
docker compose -f infra/docker-compose.yml up -d

echo "▶ backend-core 헬스 대기 (최대 3분)"
deadline=$((SECONDS + 180))
while true; do
  code=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:19090/actuator/health || echo "000")
  if [ "$code" = "200" ]; then break; fi
  if [ $SECONDS -ge $deadline ]; then
    echo "✗ backend-core 헬스 타임아웃 — docker logs v3-backend-core 확인"
    exit 1
  fi
  sleep 5
done

echo "▶ 핵심 엔드포인트 점검"
for url in \
  "core=http://localhost:19090/actuator/health" \
  "bff=http://localhost:19091/actuator/health" \
  "ui=http://localhost:19173/" \
  "kc=http://localhost:19281/realms/openplatform-v3/.well-known/openid-configuration" \
  "minio=http://localhost:19901/"; do
  name="${url%%=*}"
  target="${url#*=}"
  code=$(curl -s -o /dev/null -w "%{http_code}" "$target" || echo "000")
  printf "  %-8s %s  %s\n" "$name" "$code" "$target"
done

echo
echo "==========================================="
echo "  openplatform v3 — 기동 완료"
echo "==========================================="
echo "  포탈 UI : http://localhost:19173/"
echo "  계정    : admin / admin"
echo
echo "  전체 URL/계정: server-info.txt"
echo "  중지:        ./stop.sh"
echo "==========================================="
