param(
  [int]$WebPort = 7357,
  [int]$ApiPort = 3001
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$mobileRoot = Join-Path $root 'apps\mobile'
$webClientId =
  '567840262106-filnk22a2fdh33vildrem5npg1kb4qmg.apps.googleusercontent.com'

$portOwner = Get-NetTCPConnection `
  -State Listen `
  -LocalPort $WebPort `
  -ErrorAction SilentlyContinue |
  Select-Object -First 1

if ($portOwner) {
  throw "Port $WebPort is already in use by PID $($portOwner.OwningProcess). Stop that process before starting VNChinese Web."
}

Write-Host "VNChinese Web: http://localhost:$WebPort"
Write-Host "VNChinese API: http://localhost:$ApiPort"
Write-Host ''

Set-Location $mobileRoot
flutter run `
  -d chrome `
  --web-hostname localhost `
  --web-port $WebPort `
  --dart-define="API_BASE_URL=http://localhost:$ApiPort" `
  --dart-define="GOOGLE_WEB_CLIENT_ID=$webClientId"
