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
      if ($response.StatusCode -ge 200 -and $response.StatusCode -lt 500) {
        Write-Host "$Name ready: $Url"
        return
      }
    } catch {
      Start-Sleep -Seconds 2
    }
  } while ((Get-Date) -lt $deadline)
  throw "$Name did not become ready at $Url"
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

Stop-PortOwner $ApiPort
$apiLog = Join-Path $root 'api\server-prod.log'
$apiErr = Join-Path $root 'api\server-prod.error.log'
$env:PUBLIC_API_URL = "http://localhost:$ApiPort"
Start-Process -FilePath 'node' `
  -ArgumentList '--enable-source-maps','dist/src/main' `
  -WorkingDirectory (Join-Path $root 'api') `
  -RedirectStandardOutput $apiLog `
  -RedirectStandardError $apiErr `
  -WindowStyle Hidden
Wait-HttpOk "http://localhost:$ApiPort/health" 'VNChinese API'

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
