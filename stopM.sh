#!/usr/bin/env bash
# openplatform v3 — 서비스 일괄 중지
# 사용: ./stop.sh           — 컨테이너 중지 (데이터 보존)
#       ./stop.sh --remove  — 컨테이너 + 볼륨까지 완전 제거 (DB 초기화)
set -e
cd "$(dirname "$0")"

if [ "${1:-}" = "--remove" ]; then
  echo "▶ v3 스택 완전 제거 (down -v) — 데이터 볼륨까지 삭제"
  read -p "정말 모든 데이터를 삭제하시겠습니까? (yes/no): " ok
  if [ "$ok" != "yes" ]; then
    echo "취소됨"
    exit 0
  fi
  docker compose -f infra/docker-compose.yml down -v
  echo "✓ 컨테이너 + 볼륨 제거 완료"
else
  echo "▶ v3 스택 중지 (docker compose stop)"
  docker compose -f infra/docker-compose.yml stop
  echo "✓ 모든 컨테이너 중지됨 (데이터는 볼륨에 보존)"
  echo "  재기동:        ./start.sh"
  echo "  완전 제거:     ./stop.sh --remove"
fi
