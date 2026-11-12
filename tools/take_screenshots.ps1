<#
Retakes the screenshots of the download page (site/img) from the release build.

  flutter build windows --release        (inside app/)
  powershell -File tools/take_screenshots.ps1 [-Only home-en,qibla-ar]

Each shot starts the app with --page <screen> against a temporary settings
file (language, digits, theme, map style), photographs the window and closes
it. Your own settings.json and state.json in %APPDATA%\Salaat\Salaat are
backed up first and restored at the end, even if the script fails. The map
shots need the internet. Run it on a desktop where nothing covers the window.
#>
param(
  [string]$OutDir = (Join-Path (Split-Path $PSScriptRoot -Parent) 'site\img'),
  [string[]]$Only = @()
)
Add-Type -AssemblyName System.Windows.Forms, System.Drawing
$Only = @($Only | ForEach-Object { $_ -split "," })
Add-Type @"
using System; using System.Runtime.InteropServices;
public class W3 {
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
  [DllImport("user32.dll")] public static extern bool MoveWindow(IntPtr h, int x, int y, int w, int hh, bool repaint);
  public struct RECT { public int L, T, R, B; } }
"@

$exe = Join-Path (Split-Path $PSScriptRoot -Parent) 'app\build\windows\x64\runner\Release\salaat.exe'
$data = Join-Path $env:APPDATA 'Salaat\Salaat'
$backup = Join-Path $env:TEMP 'salaat-user-data-backup'

# name, locale, digits, theme, screen (1 home, 2 timetable, 3 calendar, 4 qibla, 5 wake-up, 6 settings),
# map style, seconds to wait before the photograph
$shots = @(
  @('home-en', 'en', 'latin', 'light', 1, 'street', 4),
  @('home-fa', 'fa', 'persian', 'light', 1, 'street', 4),
  @('home-ar', 'ar', 'arabic', 'light', 1, 'street', 4),
  @('home-en-dark', 'en', 'latin', 'dark', 1, 'street', 4),
  @('timetable-en', 'en', 'latin', 'light', 2, 'street', 4),
  @('timetable-fa', 'fa', 'persian', 'light', 2, 'street', 4),
  @('timetable-ar', 'ar', 'arabic', 'light', 2, 'street', 4),
  @('qibla-street-en', 'en', 'latin', 'light', 4, 'street', 12),
  @('qibla-satellite-en', 'en', 'latin', 'light', 4, 'satellite', 14),
  @('qibla-fa', 'fa', 'persian', 'light', 4, 'street', 12),
  @('qibla-ar', 'ar', 'arabic', 'light', 4, 'satellite', 14),
  @('settings-en', 'en', 'latin', 'light', 6, 'street', 4),
  @('settings-fa', 'fa', 'persian', 'light', 6, 'street', 4),
  @('settings-ar', 'ar', 'arabic', 'light', 6, 'street', 4)
)
$pages = @{ 1 = 'home'; 2 = 'timetable'; 3 = 'calendar'; 4 = 'qibla'; 5 = 'wakeup'; 6 = 'settings' }

function Stop-App { Get-Process salaat -ErrorAction SilentlyContinue | Stop-Process -Force; Start-Sleep -Milliseconds 800 }

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
Stop-App
if (Test-Path $backup) { Remove-Item $backup -Recurse -Force }
New-Item -ItemType Directory -Force -Path $backup | Out-Null
foreach ($f in 'settings.json', 'state.json') {
  $p = Join-Path $data $f
  if (Test-Path $p) { Copy-Item $p $backup -Force }
}
try {
  foreach ($s in $shots) {
    if ($Only.Count -gt 0 -and $Only -notcontains $s[0]) { continue }
    Stop-App
    $json = @{
      schemaVersion = 1; locale = $s[1]; digits = $s[2]; theme = $s[3]
      onboardingCompleted = $true
      azan = @{ enabled = $false }
      qibla = @{ mapEnabled = $true; mapStyle = $s[5] }
    } | ConvertTo-Json -Depth 5
    [System.IO.File]::WriteAllText((Join-Path $data 'settings.json'), $json, (New-Object System.Text.UTF8Encoding $false))
    [System.IO.File]::WriteAllText((Join-Path $data 'state.json'), '{}', (New-Object System.Text.UTF8Encoding $false))
    $p = Start-Process -FilePath $exe -ArgumentList '--page', $pages[[int]$s[4]] -WorkingDirectory (Split-Path $exe) -PassThru
    Start-Sleep -Seconds 10
    $p.Refresh()
    [W3]::MoveWindow($p.MainWindowHandle, 80, 40, 1200, 800, $true) | Out-Null
    [W3]::SetForegroundWindow($p.MainWindowHandle) | Out-Null
    Start-Sleep -Seconds ($s[6] + 1)
    $r = New-Object W3+RECT
    [W3]::GetWindowRect($p.MainWindowHandle, [ref]$r) | Out-Null
    # The window rectangle includes an invisible 8 px frame that shows what is
    # behind it; leave it out.
    $w = $r.R - $r.L - 16; $h = $r.B - $r.T - 8
    $bmp = New-Object System.Drawing.Bitmap $w, $h
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.CopyFromScreen($r.L + 8, $r.T, 0, 0, $bmp.Size)
    $out = Join-Path $OutDir ($s[0] + '.png')
    $bmp.Save($out)
    "$($s[0]): ${w}x${h} -> $out"
    Stop-App
  }
} finally {
  Stop-App
  foreach ($f in 'settings.json', 'state.json') {
    $b = Join-Path $backup $f
    if (Test-Path $b) { Copy-Item $b (Join-Path $data $f) -Force }
  }
  'restored the user settings'
}
