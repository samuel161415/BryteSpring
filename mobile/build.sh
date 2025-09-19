#!/bin/bash

# Install Flutter
echo "Installing Flutter..."
git clone https://github.com/flutter/flutter.git -b stable /tmp/flutter
export PATH="/tmp/flutter/bin:$PATH"

# Enable Flutter web
flutter config --enable-web

# Get dependencies
echo "Getting Flutter dependencies..."
flutter pub get

# Build the app
echo "Building Flutter web app..."
flutter build web --release

# Copy built files to output directory
echo "Copying built files..."
cp -r build/web/* /app/

echo "Build completed successfully!"
