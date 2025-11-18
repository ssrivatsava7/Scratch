@echo off
echo Running Dopamine app on web browser...

echo Cleaning and preparing...
flutter clean
flutter pub get

echo Starting web server...
echo Open your browser to: http://localhost:8080
flutter run -d web-server --web-port 8080

pause
