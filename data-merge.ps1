# blockchain-dapp-fw data-merge orchestrator (Windows PowerShell)
# Multi-DB capable: discovers .env.merge.* files in db/snapshot/ and processes each
# Subcommands: export | import | verify | status
# Default (no arg) = import

[CmdletBinding()]
param(
    [Parameter(Position=0)]
    [ValidateSet('export','import','verify','status','help')]
    [string]$Command = 'import'
)

$ErrorActionPreference = 'Stop'
$ScriptRoot = $PSScriptRoot
$SnapshotDir = Join-Path $ScriptRoot 'db\snapshot'
$ModuleName = Split-Path $ScriptRoot -Leaf

# Discover DB labels from .env.merge.* files (multi-DB) or fall back to single .env.merge
function Get-DbLabels {
    $labels = @()
    Get-ChildItem -Path $SnapshotDir -File -ErrorAction SilentlyContinue | ForEach-Object {
        if ($_.Name -match '^\.env\.merge\.(.+)$') {
            $labels += $Matches[1]
        }
    }
    if ($labels.Count -eq 0 -and (Test-Path (Join-Path $SnapshotDir '.env.merge'))) {
        $labels += ''  # empty label = single-DB mode
    }
    return ,$labels  # comma operator: ensure array even with 0/1 element
}

function Get-LabelFiles {
    param([string]$Label)
    $suffix = if ($Label) { ".$Label" } else { '' }
    return @{
        Env    = Join-Path $SnapshotDir ".env.merge$suffix"
        Tables = Join-Path $SnapshotDir "tables$suffix.txt"
        Schema = Join-Path $SnapshotDir "schema$suffix.sql"
        Data   = Join-Path $SnapshotDir "data$suffix.sql"
        Label  = if ($Label) { $Label } else { 'main' }
    }
}

function Read-EnvFile {
    param([string]$Path)
    $envMap = @{}
    Get-Content $Path | ForEach-Object {
        if ($_ -match '^\s*([^#=]+?)\s*=\s*(.+?)\s*$') { $envMap[$Matches[1]] = $Matches[2] }
    }
    if (-not $envMap['DB_SCHEMA']) { $envMap['DB_SCHEMA'] = 'public' }
    return $envMap
}

function Read-Whitelist {
    param([string]$Path)
    if (-not (Test-Path $Path)) { return @() }
    return Get-Content $Path | ForEach-Object { $_.Trim() } |
        Where-Object { $_ -and -not $_.StartsWith('#') }
}

function Test-PgReady {
    param($Env, [int]$TimeoutSec = 60)
    $deadline = (Get-Date).AddSeconds($TimeoutSec)
    while ((Get-Date) -lt $deadline) {
        $null = docker exec $Env['DB_CONTAINER'] pg_isready -U $Env['DB_USER'] -d $Env['DB_NAME'] 2>$null
        if ($LASTEXITCODE -eq 0) { return $true }
        Start-Sleep -Seconds 2
    }
    return $false
}

function Invoke-StatusOne {
    param($Files)
    $env = Read-EnvFile $Files.Env
    $running = docker ps --filter "name=^$($env['DB_CONTAINER'])$" --format '{{.Names}}'
    if ($running -ne $env['DB_CONTAINER']) {
        Write-Host "[!] [$($Files.Label)] container '$($env['DB_CONTAINER'])' is NOT running" -ForegroundColor Yellow
        return $false
    }
    if (Test-PgReady $env 5) {
        $tables = Read-Whitelist $Files.Tables
        Write-Host "[+] [$($Files.Label)] $($env['DB_CONTAINER']) ready (DB=$($env['DB_NAME']), $($tables.Count) tables)" -ForegroundColor Green
        return $true
    }
    Write-Host "[!] [$($Files.Label)] DB '$($env['DB_NAME'])' not accepting connections" -ForegroundColor Yellow
    return $false
}

function Invoke-ExportOne {
    param($Files)
    $env = Read-EnvFile $Files.Env
    if (-not (Test-PgReady $env 60)) { throw "[$($Files.Label)] DB not ready" }
    $tables = Read-Whitelist $Files.Tables
    if ($tables.Count -eq 0) {
        Write-Host "[*] [$($Files.Label)] no tables in whitelist — skip" -ForegroundColor Yellow
        return
    }
    Write-Host "[*] [$($Files.Label)] exporting $($tables.Count) tables from '$($env['DB_NAME'])'..." -ForegroundColor Cyan

    $tableArgs = @()
    foreach ($t in $tables) { $tableArgs += @('--table', "$($env['DB_SCHEMA']).$t") }

    # Schema (idempotent post-process)
    $schemaTmp = New-TemporaryFile
    & docker exec -e PGPASSWORD=$env['DB_PASSWORD'] $env['DB_CONTAINER'] pg_dump `
        -U $env['DB_USER'] -d $env['DB_NAME'] --schema-only --no-owner --no-acl --no-comments `
        @tableArgs > $schemaTmp.FullName
    if ($LASTEXITCODE -ne 0) { throw "[$($Files.Label)] pg_dump (schema) failed" }

    $header = @"
-- ============================================================
-- $ModuleName [$($Files.Label)] — schema.sql (idempotent)
-- Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
-- DB: $($env['DB_NAME']) @ $($env['DB_CONTAINER'])
-- Tables: $($tables.Count) (whitelist 기반, 로그/감사 제외)
-- ============================================================

"@
    $schemaContent = Get-Content $schemaTmp.FullName -Raw
    $schemaContent = $schemaContent -replace 'CREATE TABLE (?!IF NOT EXISTS)', 'CREATE TABLE IF NOT EXISTS '
    $schemaContent = $schemaContent -replace 'CREATE INDEX (?!IF NOT EXISTS)', 'CREATE INDEX IF NOT EXISTS '
    $schemaContent = $schemaContent -replace 'CREATE UNIQUE INDEX (?!IF NOT EXISTS)', 'CREATE UNIQUE INDEX IF NOT EXISTS '
    $schemaContent = $schemaContent -replace 'CREATE SEQUENCE (?!IF NOT EXISTS)', 'CREATE SEQUENCE IF NOT EXISTS '
    Set-Content -Path $Files.Schema -Value ($header + $schemaContent) -NoNewline -Encoding utf8
    Remove-Item $schemaTmp.FullName

    # Data (idempotent merge)
    $dataTmp = New-TemporaryFile
    & docker exec -e PGPASSWORD=$env['DB_PASSWORD'] $env['DB_CONTAINER'] pg_dump `
        -U $env['DB_USER'] -d $env['DB_NAME'] --data-only --column-inserts --on-conflict-do-nothing `
        --no-owner --no-acl --disable-triggers `
        @tableArgs > $dataTmp.FullName
    if ($LASTEXITCODE -ne 0) { throw "[$($Files.Label)] pg_dump (data) failed" }

    $dataHeader = @"
-- ============================================================
-- $ModuleName [$($Files.Label)] — data.sql (idempotent merge)
-- Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
-- DB: $($env['DB_NAME']) @ $($env['DB_CONTAINER'])
-- Mode: INSERT ... ON CONFLICT DO NOTHING (기존 데이터 보존)
-- ============================================================

"@
    $dataContent = Get-Content $dataTmp.FullName -Raw
    Set-Content -Path $Files.Data -Value ($dataHeader + $dataContent) -NoNewline -Encoding utf8
    Remove-Item $dataTmp.FullName

    $schemaSize = [math]::Round((Get-Item $Files.Schema).Length / 1KB, 1)
    $dataSize = [math]::Round((Get-Item $Files.Data).Length / 1KB, 1)
    $insertCount = (Select-String -Path $Files.Data -Pattern '^INSERT INTO' -CaseSensitive).Count
    Write-Host "[+] [$($Files.Label)] schema: $schemaSize KB / data: $dataSize KB ($insertCount INSERT)" -ForegroundColor Green
}

function Invoke-ImportOne {
    param($Files)
    $env = Read-EnvFile $Files.Env
    if (-not (Test-PgReady $env 60)) { throw "[$($Files.Label)] DB not ready" }
    if (-not (Test-Path $Files.Schema)) { throw "[$($Files.Label)] missing $(Split-Path $Files.Schema -Leaf)" }
    if (-not (Test-Path $Files.Data)) { throw "[$($Files.Label)] missing $(Split-Path $Files.Data -Leaf)" }

    Write-Host "[*] [$($Files.Label)] applying $(Split-Path $Files.Schema -Leaf)..." -ForegroundColor Cyan
    Get-Content $Files.Schema -Raw | docker exec -i -e PGPASSWORD=$env['DB_PASSWORD'] $env['DB_CONTAINER'] `
        psql -U $env['DB_USER'] -d $env['DB_NAME'] -v ON_ERROR_STOP=0 1>$null
    Write-Host "[+] [$($Files.Label)] schema applied (existing tables skipped)" -ForegroundColor Green

    Write-Host "[*] [$($Files.Label)] applying $(Split-Path $Files.Data -Leaf) (merge)..." -ForegroundColor Cyan
    Get-Content $Files.Data -Raw | docker exec -i -e PGPASSWORD=$env['DB_PASSWORD'] $env['DB_CONTAINER'] `
        psql -U $env['DB_USER'] -d $env['DB_NAME'] -v ON_ERROR_STOP=0 1>$null
    Write-Host "[+] [$($Files.Label)] data applied (PK 충돌 행은 skip)" -ForegroundColor Green
}

function Invoke-VerifyOne {
    param($Files)
    $env = Read-EnvFile $Files.Env
    if (-not (Test-PgReady $env 5)) { Write-Host "[!] [$($Files.Label)] DB not ready" -ForegroundColor Yellow; return }
    $tables = Read-Whitelist $Files.Tables
    Write-Host "[*] [$($Files.Label)] row counts ($($env['DB_NAME'])):" -ForegroundColor Cyan
    foreach ($t in $tables) {
        $count = docker exec -e PGPASSWORD=$env['DB_PASSWORD'] $env['DB_CONTAINER'] `
            psql -U $env['DB_USER'] -d $env['DB_NAME'] -tAc "SELECT COUNT(*) FROM $($env['DB_SCHEMA']).$t" 2>$null
        if ($LASTEXITCODE -eq 0) {
            "  {0,-40} {1,10}" -f $t, $count.Trim() | Write-Host
        } else {
            "  {0,-40} {1,10}" -f $t, '(missing)' | Write-Host -ForegroundColor Yellow
        }
    }
}

$labels = Get-DbLabels
if ($labels.Count -eq 0) {
    throw "No .env.merge or .env.merge.* found in $SnapshotDir"
}

switch ($Command) {
    'help' {
        Write-Host "Usage: data-merge.ps1 [export|import|verify|status]"
        Write-Host "  Multi-DB: discovers .env.merge.* files in db/snapshot/"
        Write-Host "  Detected DB labels: $($labels -join ', ')"
    }
    'status' { foreach ($lbl in $labels) { Invoke-StatusOne (Get-LabelFiles $lbl) | Out-Null } }
    'export' { foreach ($lbl in $labels) { Invoke-ExportOne (Get-LabelFiles $lbl) }; Write-Host "[*] git add db/snapshot/ && git commit && git push 로 공유하세요." -ForegroundColor Cyan }
    'import' { foreach ($lbl in $labels) { Invoke-ImportOne (Get-LabelFiles $lbl) }; foreach ($lbl in $labels) { Invoke-VerifyOne (Get-LabelFiles $lbl) } }
    'verify' { foreach ($lbl in $labels) { Invoke-VerifyOne (Get-LabelFiles $lbl) } }
}
