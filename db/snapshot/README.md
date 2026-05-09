# db/snapshot — Data Merge Snapshot (openplatform_v3)

다른 PC에서 동일한 데이터로 평가할 수 있도록 현재 PC의 PostgreSQL DB 스냅샷.

## 파일

| 파일 | 설명 |
|------|------|
| `.env.merge` | DB 접속 정보 (`v3-postgres` @ 19432, schema `platform_v3`) |
| `tables.txt` | 30 테이블 화이트리스트 (`ap_history`, `sa_audit` 제외) |
| `schema.sql` | `CREATE TABLE IF NOT EXISTS …` (idempotent) |
| `data.sql`   | `INSERT … ON CONFLICT DO NOTHING` (기존 데이터 보존) |

## 사용법

```bash
# 다른 PC에서:
docker compose up -d v3-postgres
./data-merge.ps1            # = import (기본)

# 현재 PC 데이터 갱신:
./data-merge.ps1 export
git add db/snapshot/ && git commit && git push origin main
```

## 제외

- `ap_history`, `sa_audit` — 감사 로그
- `flyway_schema_history`, `meta_version` — 마이그레이션 메타
- `keycloak_v3`, `flowable_v3`, `wiki_v3` 스키마 — 인프라 메타스토어 (각자 자체 관리)
