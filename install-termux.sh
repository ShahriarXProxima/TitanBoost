#!/system/bin/sh
# TitanBoost - Easy Installation Script for Termux
# Run this in Termux: sh install-termux.sh

set -e

echo "╔═══════════════════════════════════════════════════════╗"
echo "║         TitanBoost Installation for Termux            ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo ""

# Detect environment
if [ -d "$PREFIX" ]; then
    # Termux environment
    INSTALL_DIR="$PREFIX/opt/titanboost"
    BIN_DIR="$PREFIX/bin"
    echo "[✓] Termux detected"
else
    # Fallback for other Android shells
    INSTALL_DIR="/data/local/tmp/titanboost"
    BIN_DIR="/data/local/tmp/bin"
    echo "[✓] Android shell detected"
fi

# Create directories
echo "[*] Creating directories..."
mkdir -p "$INSTALL_DIR"
mkdir -p "$BIN_DIR"
mkdir -p "$INSTALL_DIR/scripts"
mkdir -p "$INSTALL_DIR/config"

# Copy files
echo "[*] Copying files..."
cp -r scripts/* "$INSTALL_DIR/scripts/" 2>/dev/null || true
cp config/config.conf "$INSTALL_DIR/config/"
cp config/whitelist.txt "$INSTALL_DIR/config/"
cp bin/titanboost "$INSTALL_DIR/titanboost"

# Make executable
chmod 755 "$INSTALL_DIR/titanboost"
chmod 755 "$INSTALL_DIR/scripts"/*.sh

# Create symlink for easy access
ln -sf "$INSTALL_DIR/titanboost" "$BIN_DIR/titanboost" 2>/dev/null || true

echo ""
echo "[✓] Installation complete!"
echo ""
echo "Quick start:"
echo "  titanboost                    (Interactive menu)"
echo "  titanboost balanced           (Apply balanced profile)"
echo "  titanboost gaming             (Apply gaming profile)"
echo "  titanboost extreme            (Apply extreme profile)"
echo ""
echo "Full path: $INSTALL_DIR/titanboost"
echo ""

