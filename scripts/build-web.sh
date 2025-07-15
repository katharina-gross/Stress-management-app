#!/bin/bash

# Build Flutter web app for GitHub Pages
# This script builds the web version with the correct base href

echo "Building Flutter web app for GitHub Pages..."

# Navigate to frontend directory
cd frontend

# Clean previous build
echo "Cleaning previous build..."
flutter clean

# Get dependencies
echo "Getting dependencies..."
flutter pub get

# Build web with correct base href
echo "Building web app..."
flutter build web --release --base-href /Stress-management-app/

echo "Build completed! Files are in frontend/build/web/"
echo "You can test locally by serving the build/web directory" 