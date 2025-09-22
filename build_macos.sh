#!/bin/bash

# Family Accountability System - macOS Build Script
# This script builds the Flutter app and copies it to ~/Desktop/FAS/

set -e  # Exit on any error

echo "🚀 Starting macOS build for Family Accountability System..."

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Ensure Flutter is in PATH
export PATH="$HOME/development/flutter/bin:$PATH"

# Check if we're in the right directory
if [ ! -d "family_accountability_system" ]; then
    echo -e "${RED}❌ Error: family_accountability_system directory not found!${NC}"
    echo "Please run this script from the FAS project root directory."
    exit 1
fi

# Create FAS folder on desktop if it doesn't exist
echo -e "${BLUE}📁 Creating FAS folder on desktop...${NC}"
mkdir -p ~/Desktop/FAS

# Clean previous build
echo -e "${BLUE}🧹 Cleaning previous build...${NC}"
cd family_accountability_system
flutter clean

# Get dependencies
echo -e "${BLUE}📦 Getting dependencies...${NC}"
flutter pub get

# Build for macOS
echo -e "${BLUE}🔨 Building macOS app (this may take a few minutes)...${NC}"
flutter build macos --release

# Check if build was successful
if [ ! -d "build/macos/Build/Products/Release/family_accountability_system.app" ]; then
    echo -e "${RED}❌ Build failed! App not found.${NC}"
    exit 1
fi

# Copy to desktop FAS folder
echo -e "${BLUE}📋 Copying app to ~/Desktop/FAS/...${NC}"
cd ..
cp -r family_accountability_system/build/macos/Build/Products/Release/family_accountability_system.app ~/Desktop/FAS/

# Get app size
APP_SIZE=$(du -sh ~/Desktop/FAS/family_accountability_system.app | cut -f1)

echo -e "${GREEN}✅ Build completed successfully!${NC}"
echo -e "${GREEN}📱 App location: ~/Desktop/FAS/family_accountability_system.app${NC}"
echo -e "${GREEN}📏 App size: $APP_SIZE${NC}"
echo -e "${GREEN}🎉 Ready to run! Double-click the app or run: open ~/Desktop/FAS/family_accountability_system.app${NC}"