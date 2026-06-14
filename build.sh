#!/bin/bash
# TitanBoost - Build Script for Packaging into Magisk ZIP
# Usage: ./build.sh [output_directory]

set -e

# Configuration
MODULE_NAME="TitanBoost"
MODULE_VERSION="1.0.0"
OUTPUT_DIR="${1:-.}"
BUILD_DATE=$(date '+%Y-%m-%d')
ZIP_NAME="TitanBoost-v${MODULE_VERSION}-${BUILD_DATE}.zip"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=================================${NC}"
echo -e "${GREEN}TitanBoost Module Builder v${MODULE_VERSION}${NC}"
echo -e "${GREEN}=================================${NC}"
echo ""

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo -e "${YELLOW}[*] Script directory: $SCRIPT_DIR${NC}"

# Check if we're in the correct directory
if [ ! -f "$SCRIPT_DIR/module.prop" ]; then
    echo -e "${RED}[ERROR] module.prop not found! Run this script from the TitanBoost root directory.${NC}"
    exit 1
fi

# Create temporary build directory
BUILD_TEMP=$(mktemp -d)
echo -e "${YELLOW}[*] Creating temporary build directory: $BUILD_TEMP${NC}"

# Copy module files to build directory
echo -e "${YELLOW}[*] Copying module files...${NC}"
cp -r "$SCRIPT_DIR"/* "$BUILD_TEMP/"

# Create proper directory structure if missing
mkdir -p "$BUILD_TEMP/bin"
mkdir -p "$BUILD_TEMP/scripts"
mkdir -p "$BUILD_TEMP/config"

# Ensure all scripts have proper permissions in archive
chmod 755 "$BUILD_TEMP/service.sh" 2>/dev/null || true
chmod 755 "$BUILD_TEMP/post-fs-data.sh" 2>/dev/null || true
chmod 755 "$BUILD_TEMP/uninstall.sh" 2>/dev/null || true
chmod 755 "$BUILD_TEMP/customize.sh" 2>/dev/null || true
chmod 755 "$BUILD_TEMP/bin/"* 2>/dev/null || true
chmod 755 "$BUILD_TEMP/scripts/"* 2>/dev/null || true

# Remove build script from package
rm -f "$BUILD_TEMP/build.sh"

# Create install.sh if needed
if [ ! -f "$BUILD_TEMP/install.sh" ]; then
    cat > "$BUILD_TEMP/install.sh" <<'EOF'
#!/system/bin/sh
# TitanBoost - Installation Script
# This script is called by Magisk at module installation time

# Installation is handled by customize.sh
# This is a placeholder for module compatibility
true
EOF
    chmod 755 "$BUILD_TEMP/install.sh"
fi

# Validate module.prop
echo -e "${YELLOW}[*] Validating module.prop...${NC}"
if ! grep -q "^id=" "$BUILD_TEMP/module.prop"; then
    echo -e "${RED}[ERROR] Invalid module.prop: missing 'id' field${NC}"
    rm -rf "$BUILD_TEMP"
    exit 1
fi

# Show module info
echo -e "${GREEN}[✓] Module Information:${NC}"
grep "^id\|^name\|^version" "$BUILD_TEMP/module.prop" | sed 's/^/  /'

# Create ZIP package
echo -e "${YELLOW}[*] Creating ZIP package: $OUTPUT_DIR/$ZIP_NAME${NC}"
cd "$BUILD_TEMP"
zip -r -q "$OUTPUT_DIR/$ZIP_NAME" .

# Verify ZIP was created
if [ -f "$OUTPUT_DIR/$ZIP_NAME" ]; then
    ZIP_SIZE=$(ls -lh "$OUTPUT_DIR/$ZIP_NAME" | awk '{print $5}')
    echo -e "${GREEN}[✓] ZIP package created successfully!${NC}"
    echo -e "${GREEN}[✓] Size: $ZIP_SIZE${NC}"
    echo -e "${GREEN}[✓] Location: $OUTPUT_DIR/$ZIP_NAME${NC}"
else
    echo -e "${RED}[ERROR] Failed to create ZIP package${NC}"
    rm -rf "$BUILD_TEMP"
    exit 1
fi

# Cleanup
echo -e "${YELLOW}[*] Cleaning up temporary files...${NC}"
rm -rf "$BUILD_TEMP"

echo ""
echo -e "${GREEN}=================================${NC}"
echo -e "${GREEN}Build completed successfully! 🎉${NC}"
echo -e "${GREEN}=================================${NC}"
echo ""
echo -e "${YELLOW}Installation Instructions:${NC}"
echo "1. Transfer the ZIP to your device: adb push $OUTPUT_DIR/$ZIP_NAME /sdcard/"
echo "2. Open Magisk Manager"
echo "3. Tap Modules > Install from storage"
echo "4. Select the ZIP file"
echo "5. Reboot"
echo ""
echo -e "${YELLOW}Verification:${NC}"
echo "su -c titanboost --info"
echo ""

