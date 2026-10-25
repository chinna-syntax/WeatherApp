# Nimbus Flutter App — Setup Script
# Run this in PowerShell as Administrator in d:\weather
# Usage: .\setup.ps1

Set-Location d:\weather

Write-Host "=== STEP 1: Create Flutter project ===" -ForegroundColor Cyan
flutter create --org com.nimbus --project-name nimbus --platforms android,ios .

Write-Host ""
Write-Host "=== STEP 2: Create assets/fonts directory ===" -ForegroundColor Cyan
New-Item -ItemType Directory -Force -Path "d:\weather\assets\fonts" | Out-Null

Write-Host ""
Write-Host "=== STEP 3: Download fonts ===" -ForegroundColor Cyan
$fontsDir = "d:\weather\assets\fonts"

$fonts = @{
    "Manrope-ExtraLight.ttf" = "https://github.com/googlefonts/manrope/raw/main/fonts/ttf/Manrope-ExtraLight.ttf"
    "Manrope-Light.ttf"      = "https://github.com/googlefonts/manrope/raw/main/fonts/ttf/Manrope-Light.ttf"
    "Manrope-Regular.ttf"    = "https://github.com/googlefonts/manrope/raw/main/fonts/ttf/Manrope-Regular.ttf"
    "Manrope-Medium.ttf"     = "https://github.com/googlefonts/manrope/raw/main/fonts/ttf/Manrope-Medium.ttf"
    "Manrope-SemiBold.ttf"   = "https://github.com/googlefonts/manrope/raw/main/fonts/ttf/Manrope-SemiBold.ttf"
    "Manrope-Bold.ttf"       = "https://github.com/googlefonts/manrope/raw/main/fonts/ttf/Manrope-Bold.ttf"
    "Manrope-ExtraBold.ttf"  = "https://github.com/googlefonts/manrope/raw/main/fonts/ttf/Manrope-ExtraBold.ttf"
    "InstrumentSerif-Regular.ttf" = "https://github.com/googlefonts/instrument-serif/raw/main/fonts/ttf/InstrumentSerif-Regular.ttf"
    "InstrumentSerif-Italic.ttf"  = "https://github.com/googlefonts/instrument-serif/raw/main/fonts/ttf/InstrumentSerif-Italic.ttf"
}

foreach ($font in $fonts.GetEnumerator()) {
    $outPath = Join-Path $fontsDir $font.Key
    if (-not (Test-Path $outPath)) {
        Write-Host "Downloading $($font.Key)..."
        try {
            Invoke-WebRequest -Uri $font.Value -OutFile $outPath -UseBasicParsing
            Write-Host "  OK: $($font.Key)" -ForegroundColor Green
        } catch {
            Write-Host "  FAILED: $($font.Key) - $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "  Already exists: $($font.Key)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=== STEP 4: flutter pub get ===" -ForegroundColor Cyan
flutter pub get

Write-Host ""
Write-Host "=== STEP 5: flutter analyze ===" -ForegroundColor Cyan
flutter analyze

Write-Host ""
Write-Host "=== Done! ===" -ForegroundColor Green
Write-Host "Run 'flutter run' to start the app." -ForegroundColor Green
