@echo off
echo Cleaning Flutter project...
flutter clean

echo Removing build and ephemeral directories...
rmdir /s /q build 2>nul
rmdir /s /q windows\flutter\ephemeral 2>nul

echo Getting Flutter dependencies...
flutter pub get

echo Enabling Windows desktop...
flutter config --enable-windows-desktop

echo Creating Windows desktop app...
flutter create --platforms=windows .

echo Rebuilding project...
flutter pub get

echo Build cleanup complete!
echo You can now run: flutter run -d windows
pause
