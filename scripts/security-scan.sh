#!/usr/bin/env bash
# ==============================================================================
# openplatform_v3 보안 스캔 스크립트
# ------------------------------------------------------------------------------
# 수행 항목:
#   1. npm audit         : ui 프론트엔드 의존성 취약점
#   2. mvn dependency    : backend-core / backend-bff 미사용/누락 의존성 분석
#   3. 이미지 스캔       : docker scout 또는 trivy (가능한 경우)
#   4. 인증 우회 테스트  : 공개 엔드포인트가 401 을 반환하는지 확인
#
# 사용법:
#   ./scripts/security-scan.sh [BASE_URL]
#
# 결과 파일:
#   reports/security-YYYYMMDD-HHMMSS.txt
# ==============================================================================

set -uo pipefail  # set -e 는 섹션별 실패 허용 위해 끔

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

BASE_URL="${1:-http://localhost:19090}"

REPORT_DIR="${PROJECT_ROOT}/reports"
mkdir -p "${REPORT_DIR}"

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
REPORT_FILE="${REPORT_DIR}/security-${TIMESTAMP}.txt"

# ------------------------------------------------------------------------------
# 헬퍼: 섹션 헤더 출력
# ------------------------------------------------------------------------------
section() {
  echo ""
  echo "==============================================================="
  echo " $1"
  echo "==============================================================="
}

# ------------------------------------------------------------------------------
# 헬퍼: 명령 존재 여부 확인
# ------------------------------------------------------------------------------
has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

# ------------------------------------------------------------------------------
# 모든 출력을 리포트 파일과 stdout 양쪽으로
# ------------------------------------------------------------------------------
exec > >(tee -a "${REPORT_FILE}") 2>&1

section "openplatform_v3 Security Scan"
echo " 실행 시각  : $(date '+%Y-%m-%d %H:%M:%S')"
echo " 베이스 URL : ${BASE_URL}"
echo " 호스트     : $(hostname)"
echo " 리포트     : ${REPORT_FILE}"

# ------------------------------------------------------------------------------
# 1. npm audit (ui 폴더)
# ------------------------------------------------------------------------------
section "[1/4] npm audit - ui frontend"

UI_DIR="${PROJECT_ROOT}/ui"
if [[ -d "${UI_DIR}" ]] && [[ -f "${UI_DIR}/package.json" ]]; then
  if has_cmd npm; then
    echo "경로: ${UI_DIR}"
    ( cd "${UI_DIR}" && npm audit --audit-level=moderate ) || \
      echo "[WARN] npm audit 가 0 이 아닌 종료 코드 반환 (취약점 있음)"
  else
    echo "[SKIP] npm 명령 없음"
  fi
else
  echo "[SKIP] ${UI_DIR}/package.json 이 존재하지 않음"
fi

# ------------------------------------------------------------------------------
# 2. mvn dependency:analyze (backend-core, backend-bff)
# ------------------------------------------------------------------------------
section "[2/4] mvn dependency:analyze - backend modules"

for module in backend-core backend-bff; do
  mod_dir="${PROJECT_ROOT}/${module}"
  if [[ -d "${mod_dir}" ]] && [[ -f "${mod_dir}/pom.xml" ]]; then
    if has_cmd mvn; then
      echo ""
      echo "--- ${module} ---"
      ( cd "${mod_dir}" && mvn -q -B dependency:analyze -DfailOnWarning=false ) || \
        echo "[WARN] ${module} 분석 중 경고/오류"
    else
      echo "[SKIP] mvn 명령 없음 (${module})"
    fi
  else
    echo "[SKIP] ${mod_dir}/pom.xml 없음"
  fi
done

# ------------------------------------------------------------------------------
# 3. 컨테이너 이미지 스캔 (docker scout 또는 trivy)
# ------------------------------------------------------------------------------
section "[3/4] Container image scan"

# 스캔 대상 이미지 (실제 compose 에서 사용하는 이미지와 맞춰야 함)
IMAGES=(
  "minio/minio"
  "quay.io/keycloak/keycloak"
  "rocketchat/rocket.chat"
  "requarks/wiki"
)

if has_cmd trivy; then
  echo "도구: trivy"
  for img in "${IMAGES[@]}"; do
    echo ""
    echo "--- ${img} ---"
    trivy image --quiet --severity HIGH,CRITICAL --no-progress "${img}" 2>&1 | head -n 50 || \
      echo "[WARN] trivy 실패: ${img}"
  done
elif has_cmd docker && docker scout --help >/dev/null 2>&1; then
  echo "도구: docker scout"
  for img in "${IMAGES[@]}"; do
    echo ""
    echo "--- ${img} ---"
    docker scout cves "${img}" 2>&1 | head -n 50 || \
      echo "[WARN] docker scout 실패: ${img}"
  done
else
  echo "[SKIP] trivy 및 docker scout 모두 사용 불가. 설치 권장:"
  echo "  - trivy : https://aquasecurity.github.io/trivy/"
  echo "  - scout : docker desktop 포함"
fi

# ------------------------------------------------------------------------------
# 4. 공개 엔드포인트 인증 우회 테스트
#    인증이 필요한 엔드포인트는 401 을 반환해야 정상
# ------------------------------------------------------------------------------
section "[4/4] Authentication bypass test"

# (경로, 기대 상태코드) 쌍
PROTECTED_PATHS=(
  "/api/admin/users|401"
  "/api/admin/codes|401"
  "/api/dataset/private|401"
  "/actuator/env|401"
  "/actuator/loggers|401"
)

PUBLIC_PATHS=(
  "/actuator/health|200"
  "/api/i18n/ko|200"
)

test_path() {
  local path="$1"
  local expected="$2"
  local url="${BASE_URL}${path}"
  local code
  code=$(curl -o /dev/null -s -w "%{http_code}" --max-time 5 "${url}" || echo "000")
  if [[ "${code}" == "${expected}" ]]; then
    printf "  [OK]   %-35s → %s (expected %s)\n" "${path}" "${code}" "${expected}"
  else
    printf "  [FAIL] %-35s → %s (expected %s)\n" "${path}" "${code}" "${expected}"
  fi
}

echo ""
echo "보호된 엔드포인트 (인증 없이 호출 → 401 기대):"
for pair in "${PROTECTED_PATHS[@]}"; do
  test_path "${pair%|*}" "${pair##*|}"
done

echo ""
echo "공개 엔드포인트 (인증 없이 호출 → 200 기대):"
for pair in "${PUBLIC_PATHS[@]}"; do
  test_path "${pair%|*}" "${pair##*|}"
done

# ------------------------------------------------------------------------------
# 마무리
# ------------------------------------------------------------------------------
section "Scan complete"
echo "리포트: ${REPORT_FILE}"
