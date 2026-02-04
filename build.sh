#!/bin/bash

# TyAu-Distortion Build Script
# Builds the plugin in Debug configuration and registers it with the system

set -e  # Exit on error

echo "🍕 Building TyAu-Distortion (Pizza Fuzz) plugin..."

# Build in Debug configuration
xcodebuild -project Distortion.xcodeproj \
    -scheme Distortion \
    -configuration Debug \
    build \
    -allowProvisioningUpdates

echo "✅ Build succeeded!"

# Register the Audio Unit extension
echo "📝 Registering Audio Unit extension..."
open /Users/taylorpage/Library/Developer/Xcode/DerivedData/Distortion-*/Build/Products/Debug/Distortion.app

echo "🎸 Pizza Fuzz is ready! Load it in Logic Pro."
