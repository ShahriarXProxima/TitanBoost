#!/system/bin/sh
# TitanBoost - Service Initialization
# Runs at boot (in KernelSU) or on demand

MODDIR="${0%/*}"
TITANBOOST_LOG="/data/local/tmp/titanboost.log"
TITANBOOST_CONFIG="/sdcard/TitanBoost/config.conf"

# Create logging directory
mkdir -p /data/local/tmp
chmod 755 /data/local/tmp

# Load helper functions
. "$MODDIR/scripts/logger.sh"
. "$MODDIR/scripts/cpu.sh"
. "$MODDIR/scripts/gpu.sh"
. "$MODDIR/scripts/memory.sh"
. "$MODDIR/scripts/profile.sh"

log_info "================================"
log_info "TitanBoost Service Started"
log_info "================================"

# Detect Android version
ANDROID_VERSION=$(getprop ro.build.version.release)
log_info "Android Version: $ANDROID_VERSION"

# Detect SoC
detect_soc

# Detect GPU
detect_gpu

# Load configuration
load_config

# Apply optimizations based on mode
case "$MODE" in
    balanced)
        log_info "Applying BALANCED profile"
        apply_cpu_balanced
        apply_gpu_balanced
        ;;
    gaming)
        log_info "Applying GAMING profile"
        apply_cpu_gaming
        apply_gpu_gaming
        apply_memory_gaming
        ;;
    extreme)
        log_info "Applying EXTREME profile"
        apply_cpu_extreme
        apply_gpu_extreme
        apply_memory_extreme
        apply_thermal_extreme
        ;;
    *)
        log_warn "Unknown mode: $MODE, applying BALANCED"
        apply_cpu_balanced
        ;;
esac

# Apply thermal management if needed
if [ "$THERMAL_PROFILE" != "none" ]; then
    apply_thermal_profile "$THERMAL_PROFILE"
fi

# Apply background process management if enabled
if [ "$BACKGROUND_CLEAN" = "true" ]; then
    apply_background_cleanup
fi

# Final logging
log_info "TitanBoost service initialization complete"
log_info "Configuration loaded from: $TITANBOOST_CONFIG"
log_info "================================"

