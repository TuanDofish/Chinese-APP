param(
  [int]$ApiPort = 3001,
  [int]$AdminPort = 8080
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

function Wait-HttpOk($Url, $Name, $Seconds = 90) {
  $deadline = (Get-Date).AddSeconds($Seconds)
  do {
    try {
      $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 3
      if ($response.StatusCode -ge 200 -and $response.StatusCode -lt 300) {
        Write-Host "$Name ready: $Url"
        return
      }
    } catch {
      Start-Sleep -Seconds 2
    }
  } while ((Get-Date) -lt $deadline)
  throw "$Name did not become ready at $Url"
}

function Show-RecentLog($Path, $Label) {
  if (Test-Path $Path) {
    Write-Host ""
    Write-Host "Last $Label lines:"
    Get-Content -Path $Path -Tail 40 -ErrorAction SilentlyContinue
  }
}

function Test-DockerReady {
  try {
    docker info *> $null
    return $LASTEXITCODE -eq 0
  } catch {
    return $false
  }
}

function Ensure-DockerReady {
  if (Test-DockerReady) { return }

  $dockerDesktop = Join-Path $env:ProgramFiles 'Docker\Docker\Docker Desktop.exe'
  if (Test-Path $dockerDesktop) {
    Write-Host 'Starting Docker Desktop...'
    Start-Process -FilePath $dockerDesktop -WindowStyle Hidden
  }

  $deadline = (Get-Date).AddSeconds(120)
  do {
    Start-Sleep -Seconds 5
    if (Test-DockerReady) { return }
  } while ((Get-Date) -lt $deadline)

  throw 'Docker Desktop is not ready. Open Docker Desktop manually, then run this script again.'
}

function Stop-PortOwner($Port) {
  $owners = Get-NetTCPConnection -State Listen -LocalPort $Port -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty OwningProcess -Unique
  foreach ($owner in $owners) {
    if ($owner) {
      Stop-Process -Id $owner -Force -ErrorAction SilentlyContinue
    }
  }
}

Set-Location $root
Ensure-DockerReady
docker compose up -d postgres redis
Write-Host 'PostgreSQL: localhost:5433'
Write-Host 'Adminer, if needed: http://127.0.0.1:8081'

Stop-PortOwner $ApiPort
$apiLog = Join-Path $root 'api\server-prod.log'
$apiErr = Join-Path $root 'api\server-prod.error.log'
$apiEntry = Join-Path $root 'api\dist\src\main.js'
if (-not (Test-Path $apiEntry)) {
  throw "API build is missing at $apiEntry. Run: cd api; npm install; npm run build"
}
$env:PUBLIC_API_URL = "http://localhost:$ApiPort"
Start-Process -FilePath 'node' `
  -ArgumentList '--enable-source-maps','dist/src/main' `
  -WorkingDirectory (Join-Path $root 'api') `
  -RedirectStandardOutput $apiLog `
  -RedirectStandardError $apiErr `
  -WindowStyle Hidden
try {
  Wait-HttpOk "http://localhost:$ApiPort/health" 'VNChinese API'
} catch {
  Write-Host ""
  Write-Host "VNChinese API failed to become ready."
  Write-Host "API stdout log: $apiLog"
  Write-Host "API stderr log: $apiErr"
  Show-RecentLog $apiLog 'API stdout'
  Show-RecentLog $apiErr 'API stderr'
  throw
}

Stop-PortOwner $AdminPort
$env:ADMIN_PORT = "$AdminPort"
$env:API_PORT = "$ApiPort"

Write-Host ''
Write-Host "Admin: http://127.0.0.1:$AdminPort"
Write-Host "API:   http://localhost:$ApiPort"
Write-Host 'Login: admin@vnchinese.local / admin123456'
Write-Host ''
Write-Host 'Keep this terminal open while using the admin web.'
node scripts/serve-admin.js "$AdminPort"
