#!/usr/bin/env bash
# ==============================================================================
# openplatform_v3 성능 스캔 스크립트
# ------------------------------------------------------------------------------
# 주요 공개 엔드포인트의 응답 시간을 측정하여 평균을 계산한다.
# curl 의 -w "%{time_total}" 포맷을 사용하며, TLS handshake 를 포함한 총 시간.
#
# 사용법:
#   ./scripts/perf-scan.sh [BASE_URL]
#   예) ./scripts/perf-scan.sh https://api.v3.localhost
#
# 결과 파일:
#   reports/perf-YYYYMMDD-HHMMSS.txt
# ==============================================================================

set -euo pipefail

# 프로젝트 루트 (스크립트 위치 기준)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# 기본 베이스 URL (인자로 오버라이드 가능)
BASE_URL="${1:-http://localhost:19090}"

# 반복 횟수
ITERATIONS=10

# 결과 디렉터리 보장
REPORT_DIR="${PROJECT_ROOT}/reports"
mkdir -p "${REPORT_DIR}"

# 타임스탬프 기반 리포트 파일명
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
REPORT_FILE="${REPORT_DIR}/perf-${TIMESTAMP}.txt"

# 측정 대상 엔드포인트 목록 (경로만; BASE_URL 과 조합)
ENDPOINTS=(
  "/actuator/health"
  "/api/dataset/search?q=public&size=10"
  "/api/codes"
  "/api/i18n/ko"
)

# ------------------------------------------------------------------------------
# 단일 엔드포인트 측정 함수
# $1: full URL
# 표준출력으로 10회 평균 시간(초) 반환
# ------------------------------------------------------------------------------
measure_endpoint() {
  local url="$1"
  local total=0
  local success=0
  local fail=0
  local times=()

  for i in $(seq 1 "${ITERATIONS}"); do
    # -o /dev/null : 본문 버림
    # -s           : 진행바 숨김
    # -w           : 응답 시간만 출력
    # --max-time   : 타임아웃 10초
    local t
    if t=$(curl -o /dev/null -s -w "%{time_total}" --max-time 10 "${url}" 2>/dev/null); then
      times+=("${t}")
      # bc 가 없는 환경 대비 awk 로 누적
      total=$(awk -v a="${total}" -v b="${t}" 'BEGIN{printf "%.6f", a+b}')
      success=$((success + 1))
    else
      fail=$((fail + 1))
    fi
  done

  if [[ "${success}" -eq 0 ]]; then
    echo "N/A (all failed)"
    return
  fi

  local avg
  avg=$(awk -v t="${total}" -v n="${success}" 'BEGIN{printf "%.4f", t/n}')
  # min/max 도 계산
  local min="${times[0]}"
  local max="${times[0]}"
  for t in "${times[@]}"; do
    awk -v a="${t}" -v b="${min}" 'BEGIN{exit !(a<b)}' && min="${t}"
    awk -v a="${t}" -v b="${max}" 'BEGIN{exit !(a>b)}' && max="${t}"
  done

  printf "avg=%ss min=%ss max=%ss success=%d fail=%d" \
    "${avg}" "${min}" "${max}" "${success}" "${fail}"
}

# ------------------------------------------------------------------------------
# 메인 로직
# ------------------------------------------------------------------------------
{
  echo "==============================================================="
  echo " openplatform_v3 Performance Scan"
  echo "==============================================================="
  echo " 실행 시각   : $(date '+%Y-%m-%d %H:%M:%S')"
  echo " 베이스 URL  : ${BASE_URL}"
  echo " 반복 횟수   : ${ITERATIONS}"
  echo " 호스트      : $(hostname)"
  echo "---------------------------------------------------------------"

  for path in "${ENDPOINTS[@]}"; do
    url="${BASE_URL}${path}"
    echo ""
    echo "[엔드포인트] ${path}"
    echo "  URL : ${url}"
    printf "  결과: "
    measure_endpoint "${url}"
    echo ""
  done

  echo ""
  echo "==============================================================="
  echo " 스캔 완료"
  echo "==============================================================="
} | tee "${REPORT_FILE}"

echo ""
echo "결과 저장: ${REPORT_FILE}"
