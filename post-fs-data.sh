#!/system/bin/sh
# TitanBoost - Post-FS-Data Initialization
# Runs early in boot for both Magisk and KernelSU

MODDIR="${0%/*}"
TITANBOOST_LOG="/data/local/tmp/titanboost.log"

# Create logging infrastructure
mkdir -p /data/local/tmp
chmod 755 /data/local/tmp

# Initialize log
echo "[$(date '+%Y-%m-%d %H:%M:%S')] TitanBoost post-fs-data initialization" >> "$TITANBOOST_LOG"

# Load logger first
. "$MODDIR/scripts/logger.sh"

log_info "Post-FS-Data: Starting early initialization"

# Verify critical files exist
if [ ! -f "$MODDIR/scripts/logger.sh" ]; then
    log_error "Critical file missing: scripts/logger.sh"
    exit 1
fi

if [ ! -f "$MODDIR/scripts/cpu.sh" ]; then
    log_error "Critical file missing: scripts/cpu.sh"
    exit 1
fi

# Check if running on Magisk or KernelSU
if [ -f "/data/adb/magisk/util_functions.sh" ]; then
    log_info "Detected: Magisk environment"
    RUNTIME_ENV="magisk"
elif [ -f "/data/adb/ksu/util_functions.sh" ]; then
    log_info "Detected: KernelSU environment"
    RUNTIME_ENV="kernelsu"
else
    log_warn "Unknown root environment detected"
    RUNTIME_ENV="unknown"
fi

# Create necessary directories
mkdir -p /sdcard/TitanBoost
mkdir -p /data/local/tmp

# Set permissions
chmod 755 "$MODDIR/service.sh"
chmod 755 "$MODDIR/scripts"/*.sh
chmod 755 "$MODDIR/bin"/*

log_info "Post-FS-Data: Early initialization complete (Environment: $RUNTIME_ENV)"

