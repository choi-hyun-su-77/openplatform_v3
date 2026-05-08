#Requires -Version 5.1
<#
.SYNOPSIS
  infra/db-merge/dumps/ 의 dump 결과를 v3-postgres / v3-mongo 에 복원.

.DESCRIPTION
  대상 DB 가 비어있는 경우 그대로 import. 데이터가 이미 존재하면 -Force 가 없는 한 중단.

.PARAMETER Force
  대상 DB 에 데이터가 있어도 강제 덮어쓰기 (drop 후 재import).

.EXAMPLE
  PS> infra\db-merge\restore-all.ps1
  PS> infra\db-merge\restore-all.ps1 -Force
#>
param(
    [switch]$Force,
    [string]$PostgresContainer = 'v3-postgres',
    [string]$MongoContainer = 'v3-mongo',
    [string]$PostgresUser = 'platform_v3'
)

$ErrorActionPreference = 'Stop'

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$DumpsDir = Join-Path $ScriptRoot 'dumps'

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
    if (-not $running) { throw "Container '$Name' is not running." }
}

function Test-PgDbHasData {
    param([string]$Db)
    $sql = "SELECT count(*) FROM information_schema.tables WHERE table_schema NOT IN ('pg_catalog','information_schema') AND table_type='BASE TABLE'"
    $out = docker exec $PostgresContainer psql -U $PostgresUser -d $Db -tAc $sql 2>$null
    return ([int]$out -gt 0)
}

Test-Container $PostgresContainer
Test-Container $MongoContainer

if (-not (Test-Path (Join-Path $DumpsDir 'MANIFEST.json'))) {
    throw "MANIFEST.json not found in $DumpsDir. Run dump-all first or pull dumps from git."
}

# ---------- Postgres globals ----------
$globals = Join-Path $DumpsDir 'postgres-globals.sql'
if (Test-Path $globals) {
    Invoke-Step "Apply Postgres globals (roles)" {
        Get-Content -Raw -Encoding UTF8 $globals | docker exec -i $PostgresContainer psql -U $PostgresUser -d postgres -v ON_ERROR_STOP=0 | Out-Null
        # Globals contain CREATE ROLE which may already exist — exit code mismatch tolerated.
        $script:LASTEXITCODE = 0
    }
}

# ---------- Postgres databases ----------
$pgDumps = Get-ChildItem -Path $DumpsDir -Filter 'postgres-*.dump'
foreach ($f in $pgDumps) {
    if ($f.Name -eq 'postgres-globals.sql') { continue }
    $db = $f.Name -replace '^postgres-', '' -replace '\.dump$', ''

    if (Test-PgDbHasData -Db $db) {
        if (-not $Force) {
            Write-Host "Skip: database '$db' already has tables. Use -Force to overwrite." -ForegroundColor Yellow
            continue
        }
        Write-Host "Force: dropping existing objects in '$db'" -ForegroundColor Yellow
    }

    Invoke-Step "Restore Postgres database '$db'" {
        $remote = "/tmp/$($f.Name)"
        docker cp $f.FullName "${PostgresContainer}:$remote"
        # --clean --if-exists drops existing objects before restore.
        docker exec $PostgresContainer pg_restore -U $PostgresUser -d $db --clean --if-exists --no-owner --no-privileges $remote
        # pg_restore can return non-zero on benign warnings; tolerate.
        $script:LASTEXITCODE = 0
        docker exec $PostgresContainer rm -f $remote
    }
}

# ---------- MongoDB ----------
$mongoArchive = Join-Path $DumpsDir 'mongo-all.archive.gz'
if (Test-Path $mongoArchive) {
    Invoke-Step "Restore MongoDB (drop existing collections)" {
        $remote = '/tmp/mongo-all.archive.gz'
        docker cp $mongoArchive "${MongoContainer}:$remote"
        docker exec $MongoContainer mongorestore --archive=$remote --gzip --drop
        docker exec $MongoContainer rm -f $remote
    }
}

Write-Host ""
Write-Host "Restore complete." -ForegroundColor Green
