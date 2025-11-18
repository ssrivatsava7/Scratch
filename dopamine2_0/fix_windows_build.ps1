# Flutter Windows Build Fix Script
Write-Host "Fixing Flutter Windows build issues..." -ForegroundColor Green

# Clean the project
Write-Host "1. Cleaning Flutter project..." -ForegroundColor Yellow
flutter clean

# Remove problematic directories
Write-Host "2. Removing build directories..." -ForegroundColor Yellow
if (Test-Path "build") { Remove-Item -Recurse -Force "build" }
if (Test-Path "windows\flutter\ephemeral") { Remove-Item -Recurse -Force "windows\flutter\ephemeral" }

# Get dependencies
Write-Host "3. Getting Flutter dependencies..." -ForegroundColor Yellow
flutter pub get

# Enable Windows desktop
Write-Host "4. Enabling Windows desktop..." -ForegroundColor Yellow
flutter config --enable-windows-desktop

# Recreate Windows files
Write-Host "5. Recreating Windows platform files..." -ForegroundColor Yellow
flutter create --platforms=windows .

# Get dependencies again
Write-Host "6. Getting dependencies again..." -ForegroundColor Yellow
flutter pub get

Write-Host "Build fix complete! You can now run: flutter run -d windows" -ForegroundColor Green
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")