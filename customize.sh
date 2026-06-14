#!/system/bin/sh
# TitanBoost - Magisk Installation Script
# This script validates the module and performs necessary setup

# Source magisk module API
[ -z "$MODPATH" ] && MODPATH=/system/priv-app/TitanBoost
[ -z "$MODDIR" ] && MODDIR="$0"

# Ensure proper permissions
set_perm_recursive "$MODPATH" 0 0 0755 0755
set_perm "$MODPATH/service.sh" 0 0 0755
set_perm "$MODPATH/post-fs-data.sh" 0 0 0755
set_perm "$MODPATH/uninstall.sh" 0 0 0755
set_perm_recursive "$MODPATH/bin" 0 0 0755 0755
set_perm_recursive "$MODPATH/scripts" 0 0 0755 0755

# Log installation
mkdir -p /data/local/tmp
echo "[$(date '+%Y-%m-%d %H:%M:%S')] TitanBoost installation started" >> /data/local/tmp/titanboost.log

# Create config directory if not present
mkdir -p /sdcard/TitanBoost
chmod 777 /sdcard/TitanBoost

# Copy default config if not present
if [ ! -f "/sdcard/TitanBoost/config.conf" ]; then
    cp "$MODPATH/config/config.conf" /sdcard/TitanBoost/config.conf
    chmod 644 /sdcard/TitanBoost/config.conf
fi

# Copy default whitelist if not present
if [ ! -f "/sdcard/TitanBoost/whitelist.txt" ]; then
    cp "$MODPATH/config/whitelist.txt" /sdcard/TitanBoost/whitelist.txt
    chmod 644 /sdcard/TitanBoost/whitelist.txt
fi

ui_print "- TitanBoost installation completed successfully"

