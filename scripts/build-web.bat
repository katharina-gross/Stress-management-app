@echo off

REM Build Flutter web app for GitHub Pages
REM This script builds the web version with the correct base href

echo Building Flutter web app for GitHub Pages...

REM Navigate to frontend directory
cd frontend

REM Clean previous build
echo Cleaning previous build...
flutter clean

REM Get dependencies
echo Getting dependencies...
flutter pub get

REM Build web with correct base href
echo Building web app...
flutter build web --release --base-href /Stress-management-app/

echo Build completed! Files are in frontend/build/web/
echo You can test locally by serving the build/web directory 