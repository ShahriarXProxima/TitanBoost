#!/system/bin/sh
# TitanBoost - Profile Management System

# Default configuration
TITANBOOST_CONFIG="${TITANBOOST_CONFIG:-/sdcard/TitanBoost/config.conf}"
MODE="balanced"
CPU_PROFILE="balanced"
GPU_PROFILE="balanced"
RAM_CLEAN="false"
BACKGROUND_CLEAN="false"
THERMAL_PROFILE="balanced"

# Load configuration from file
load_config() {
    if [ -f "$TITANBOOST_CONFIG" ]; then
        . "$TITANBOOST_CONFIG"
        log_info "Configuration loaded from: $TITANBOOST_CONFIG"
        log_info "Mode: $MODE | CPU: $CPU_PROFILE | GPU: $GPU_PROFILE | RAM Clean: $RAM_CLEAN"
    else
        log_warn "Config file not found: $TITANBOOST_CONFIG"
        log_info "Using default balanced configuration"
        MODE="balanced"
        CPU_PROFILE="balanced"
        GPU_PROFILE="balanced"
        RAM_CLEAN="false"
        BACKGROUND_CLEAN="false"
        THERMAL_PROFILE="balanced"
    fi
}

# Save configuration to file
save_config() {
    local temp_conf="/tmp/titanboost.conf.tmp"

    cat > "$temp_conf" <<EOF
# TitanBoost Configuration File
# Generated on $(date)

# Operating mode: balanced, gaming, extreme
MODE=$MODE

# CPU Profile: balanced, gaming, extreme
CPU_PROFILE=$CPU_PROFILE

# GPU Profile: balanced, gaming, extreme
GPU_PROFILE=$GPU_PROFILE

# Enable RAM cleaning: true/false
RAM_CLEAN=$RAM_CLEAN

# Enable background process cleanup: true/false
BACKGROUND_CLEAN=$BACKGROUND_CLEAN

# Thermal profile: balanced, gaming, extreme, none
THERMAL_PROFILE=$THERMAL_PROFILE
EOF

    cp "$temp_conf" "$TITANBOOST_CONFIG"
    chmod 644 "$TITANBOOST_CONFIG"
    rm -f "$temp_conf"
    log_success "Configuration saved"
}

# Apply thermal profile
apply_thermal_profile() {
    local profile="$1"

    log_info "Applying THERMAL profile: $profile"

    case "$profile" in
        balanced)
            # Stock thermal behavior
            if [ -d "/sys/class/thermal" ]; then
                # Keep thermal mitigation normal
                log_info "Thermal: Using stock settings"
            fi
            ;;
        gaming)
            # Moderate thermal relaxation
            if [ -f "/sys/module/msm_thermal/parameters/polling_delay" ]; then
                echo 10000 > /sys/module/msm_thermal/parameters/polling_delay 2>/dev/null
            fi
            log_info "Thermal: Gaming mode (moderate throttle relaxation)"
            ;;
        extreme)
            # Attempt performance-first tuning
            if [ -f "/sys/module/msm_thermal/parameters/enabled" ]; then
                # Don't disable entirely, just set aggressive limits
                echo 10000 > /sys/module/msm_thermal/parameters/polling_delay 2>/dev/null
            fi
            log_warn "Thermal: Extreme mode (monitor device temperature!)"
            ;;
    esac
}

# Apply background cleanup settings
apply_background_cleanup() {
    log_info "Applying background process cleanup"

    local whitelist="/sdcard/TitanBoost/whitelist.txt"

    # Critical services that must NEVER be killed
    local critical="com.android.systemui:system_server:surfaceflinger:zygote:zygote64:vendor.hwcomposer:vendor.display:vendor.qti.hardware:com.android.phone"

    # Get all third-party packages
    local threshold_time=$((EPOCHREALTIME - 300))  # 5 minutes

    # Use dumpsys to get cached processes
    local cached=$(dumpsys meminfo | grep "TOTAL" | head -1 | awk '{print $2}')

    if [ "$cached" -gt 1000000 ]; then  # If more than 1GB cached
        log_info "High memory pressure detected, cleaning background apps"

        # pkill cached apps (safely)
        for app in $(pm list packages -3 | cut -d: -f2); do
            local should_kill=true

            # Check against critical services
            for critical_pkg in $critical; do
                [ "$app" = "$critical_pkg" ] && should_kill=false
            done

            # Check whitelist
            if [ -f "$whitelist" ] && grep -q "^$app$" "$whitelist"; then
                should_kill=false
            fi

            if [ "$should_kill" = "true" ]; then
                killall "$app" 2>/dev/null
            fi
        done
    fi
}

# Set operating mode
set_mode() {
    local new_mode="$1"

    case "$new_mode" in
        balanced|gaming|extreme)
            MODE="$new_mode"
            save_config
            log_success "Mode changed to: $new_mode"
            ;;
        *)
            log_error "Invalid mode: $new_mode (use balanced, gaming, or extreme)"
            return 1
            ;;
    esac
}

# Set CPU profile
set_cpu_profile() {
    local profile="$1"
    CPU_PROFILE="$profile"
    save_config
    log_success "CPU profile set to: $profile"
}

# Set GPU profile
set_gpu_profile() {
    local profile="$1"
    GPU_PROFILE="$profile"
    save_config
    log_success "GPU profile set to: $profile"
}

# Enable auto-start
enable_autostart() {
    mkdir -p /data/adb/service.d

    if [ ! -f "/data/adb/service.d/titanboost.sh" ]; then
        cat > /data/adb/service.d/titanboost.sh <<'EOF'
#!/system/bin/sh
# TitanBoost Auto-start Service
sh /data/adb/modules/TitanBoost/service.sh &
EOF
        chmod 755 /data/adb/service.d/titanboost.sh
        log_success "Auto-start enabled"
    else
        log_info "Auto-start already enabled"
    fi
}

# Disable auto-start
disable_autostart() {
    rm -f /data/adb/service.d/titanboost.sh
    log_success "Auto-start disabled"
}

export -f load_config save_config apply_thermal_profile apply_background_cleanup
export -f set_mode set_cpu_profile set_gpu_profile enable_autostart disable_autostart

