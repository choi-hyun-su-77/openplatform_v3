#Requires -Version 5.1
<#
.SYNOPSIS
  openplatform_v3 의 PostgreSQL + MongoDB 모든 DB(스키마+데이터) 를 한 번에 dump.

.DESCRIPTION
  결과는 infra/db-merge/dumps/ 에 저장된다. 결과 파일을 git 에 커밋하면 다른 컴퓨터의
  restore-all.ps1 로 그대로 복원 가능.

.PARAMETER PostgresContainer
  Postgres 컨테이너 이름 (기본: v3-postgres)

.PARAMETER MongoContainer
  Mongo 컨테이너 이름 (기본: v3-mongo)

.EXAMPLE
  PS> cd C:\claude\openplatform_v3
  PS> infra\db-merge\dump-all.ps1
#>
param(
    [string]$PostgresContainer = 'v3-postgres',
    [string]$MongoContainer = 'v3-mongo',
    [string]$PostgresUser = 'platform_v3',
    # 로그성 테이블/컬렉션 제외 패턴 (POSIX 정규식, table_name 만 매칭).
    # Postgres: 매칭 테이블의 데이터만 제외 (--exclude-table-data, 스키마는 유지).
    # Mongo:    매칭 컬렉션 자체를 제외 (--excludeCollection).
    [string]$ExcludeRegex = '(^|_)(log|logs|audit)($|_|s)|^event_entity$|^admin_event_entity$'
)

$ErrorActionPreference = 'Stop'

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$DumpsDir = Join-Path $ScriptRoot 'dumps'
if (-not (Test-Path $DumpsDir)) { New-Item -ItemType Directory -Path $DumpsDir | Out-Null }

function Invoke-Step {
    param([string]$Title, [scriptblock]$Body)
    Write-Host "==> $Title" -ForegroundColor Cyan
    & $Body
    if ($LASTEXITCODE -ne 0) {
        throw "Step failed: $Title (exit $LASTEXITCODE)"
    }
}

function Test-Container {
    param([string]$Name)
    $running = docker ps --filter "name=^$Name$" --format '{{.Names}}'
    if (-not $running) { throw "Container '$Name' is not running. Start the v3 stack first." }
}

Test-Container $PostgresContainer
Test-Container $MongoContainer

# ---------- Postgres ----------
$PgDatabases = @('platform_v3', 'wiki_v3')

Invoke-Step "Dump Postgres globals (roles, tablespaces)" {
    docker exec $PostgresContainer sh -c "pg_dumpall -U $PostgresUser --globals-only --no-role-passwords > /tmp/postgres-globals.sql"
    docker cp "${PostgresContainer}:/tmp/postgres-globals.sql" (Join-Path $DumpsDir 'postgres-globals.sql')
    docker exec $PostgresContainer rm -f /tmp/postgres-globals.sql
}

foreach ($db in $PgDatabases) {
    $remote = "/tmp/postgres-$db.dump"
    $local = Join-Path $DumpsDir "postgres-$db.dump"

    # 동적으로 로그성 테이블 목록 조회 (스키마.테이블 형태).
    $sql = "SELECT table_schema || '.' || table_name FROM information_schema.tables " +
           "WHERE table_schema NOT IN ('pg_catalog','information_schema') " +
           "AND table_type='BASE TABLE' AND table_name ~* '$ExcludeRegex' ORDER BY 1"
    $excluded = (docker exec $PostgresContainer psql -U $PostgresUser -d $db -tAc $sql) -split "`n" |
                ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }

    if ($excluded.Count -gt 0) {
        Write-Host ("    excluded log tables in '{0}': {1}" -f $db, ($excluded -join ', ')) -ForegroundColor DarkGray
    }

    Invoke-Step "Dump Postgres database '$db' (custom format, compression 9)" {
        $cmd = @('pg_dump','-U',$PostgresUser,'-d',$db,'-F','c','-Z','9','-f',$remote)
        foreach ($t in $excluded) { $cmd += '--exclude-table-data'; $cmd += $t }
        docker exec $PostgresContainer @cmd
        docker cp "${PostgresContainer}:$remote" $local
        docker exec $PostgresContainer rm -f $remote
    }
}

# ---------- MongoDB ----------
$mongoArchive = Join-Path $DumpsDir 'mongo-all.archive.gz'

# 모든 사용자 DB 의 컬렉션을 훑어 로그성 이름을 식별 (--excludeCollection 은 이름 단위 매칭).
$mongoExcludeJs = @"
let names = new Set();
db.getMongo().getDBNames().filter(n => !['admin','config','local'].includes(n)).forEach(dbn => {
  db.getSiblingDB(dbn).getCollectionNames().forEach(c => {
    if (/$ExcludeRegex/i.test(c)) names.add(c);
  });
});
print(Array.from(names).join('\n'));
"@
$mongoExcluded = (docker exec $MongoContainer mongosh --quiet --eval $mongoExcludeJs) -split "`n" |
                 ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }

if ($mongoExcluded.Count -gt 0) {
    Write-Host ("    excluded mongo collections: {0}" -f ($mongoExcluded -join ', ')) -ForegroundColor DarkGray
}

Invoke-Step "Dump MongoDB (all DBs, archive+gzip — admin/config/local 은 restore 단계에서 nsExclude)" {
    $excludeFlags = ($mongoExcluded | ForEach-Object { "--excludeCollection=$_" }) -join ' '
    # --quiet: PowerShell 5.1 에서 native stderr 출력이 NativeCommandError 로 wrap 되는 문제 회피.
    $shCmd = "mongodump --quiet --archive=/tmp/mongo-all.archive.gz --gzip $excludeFlags"
    docker exec $MongoContainer sh -c $shCmd
    docker cp "${MongoContainer}:/tmp/mongo-all.archive.gz" $mongoArchive
    docker exec $MongoContainer rm -f /tmp/mongo-all.archive.gz
}

# ---------- MANIFEST ----------
$files = Get-ChildItem -Path $DumpsDir -File |
    Where-Object { $_.Name -ne 'MANIFEST.json' -and -not $_.Name.StartsWith('.') }
$entries = foreach ($f in $files) {
    $hash = (Get-FileHash -Algorithm SHA256 -Path $f.FullName).Hash.ToLower()
    [pscustomobject]@{
        name = $f.Name
        bytes = $f.Length
        sha256 = $hash
    }
}
$manifest = [pscustomobject]@{
    createdAtUtc = (Get-Date).ToUniversalTime().ToString('o')
    host = $env:COMPUTERNAME
    postgresContainer = $PostgresContainer
    mongoContainer = $MongoContainer
    postgresDatabases = $PgDatabases
    excludeRegex = $ExcludeRegex
    files = @($entries)
}
$manifestPath = Join-Path $DumpsDir 'MANIFEST.json'
$manifest | ConvertTo-Json -Depth 5 | Out-File -FilePath $manifestPath -Encoding utf8

Write-Host ""
Write-Host "Dump complete. Files in $DumpsDir :" -ForegroundColor Green
Get-ChildItem -Path $DumpsDir | Format-Table Name, Length, LastWriteTime
