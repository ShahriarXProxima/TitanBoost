#!/system/bin/sh
# TitanBoost - GPU Optimization Module

# Detect GPU type
detect_gpu() {
    if [ -d "/sys/class/kgsl/kgsl-3d0" ]; then
        DETECTED_GPU="Adreno"
        GPU_PATH="/sys/class/kgsl/kgsl-3d0"
        log_info "Detected GPU: Qualcomm Adreno (KGSL)"
    elif [ -d "/sys/class/misc/mali0" ]; then
        DETECTED_GPU="Mali"
        GPU_PATH="/sys/class/misc/mali0"
        log_info "Detected GPU: ARM Mali"
    elif [ -d "/sys/class/devfreq" ] && grep -q "powervr" /proc/devices 2>/dev/null; then
        DETECTED_GPU="PowerVR"
        GPU_PATH="/sys/class/devfreq"
        log_info "Detected GPU: PowerVR"
    else
        DETECTED_GPU="Unknown"
        log_warn "Could not detect GPU type"
    fi
}

# Adreno GPU optimization
apply_adreno_balanced() {
    log_info "Applying BALANCED Adreno GPU settings"

    if [ -f "$GPU_PATH/devfreq/min_freq" ] && [ -f "$GPU_PATH/devfreq/max_freq" ]; then
        local max_freq=$(cat "$GPU_PATH/devfreq/max_freq" 2>/dev/null)
        local min_freq=$(cat "$GPU_PATH/devfreq/min_freq" 2>/dev/null)

        # Set mid-range frequency
        if [ "$max_freq" ] && [ "$min_freq" ]; then
            local mid_freq=$((min_freq + (max_freq - min_freq) / 2))
            echo "$mid_freq" > "$GPU_PATH/devfreq/max_freq" 2>/dev/null
        fi
    fi

    # Disable force clock on
    [ -f "$GPU_PATH/force_clk_on" ] && echo 0 > "$GPU_PATH/force_clk_on" 2>/dev/null
    [ -f "$GPU_PATH/force_bus_on" ] && echo 0 > "$GPU_PATH/force_bus_on" 2>/dev/null
}

apply_adreno_gaming() {
    log_info "Applying GAMING Adreno GPU settings"

    # Force higher minimum frequency
    if [ -f "$GPU_PATH/devfreq/min_freq" ] && [ -f "$GPU_PATH/devfreq/max_freq" ]; then
        local max_freq=$(cat "$GPU_PATH/devfreq/max_freq" 2>/dev/null)
        local min_freq=$(cat "$GPU_PATH/devfreq/min_freq" 2>/dev/null)

        if [ "$max_freq" ] && [ "$min_freq" ]; then
            local high_freq=$((min_freq + (max_freq - min_freq) * 3 / 4))
            echo "$high_freq" > "$GPU_PATH/devfreq/min_freq" 2>/dev/null
            echo "$max_freq" > "$GPU_PATH/devfreq/max_freq" 2>/dev/null
        fi
    fi

    # Enable bus
    [ -f "$GPU_PATH/force_bus_on" ] && echo 1 > "$GPU_PATH/force_bus_on" 2>/dev/null
}

apply_adreno_extreme() {
    log_info "Applying EXTREME Adreno GPU settings"

    # Force maximum frequency
    if [ -f "$GPU_PATH/devfreq/max_freq" ]; then
        local max_freq=$(cat "$GPU_PATH/devfreq/max_freq" 2>/dev/null)
        echo "$max_freq" > "$GPU_PATH/devfreq/max_freq" 2>/dev/null
    fi

    # Force buses on
    [ -f "$GPU_PATH/force_bus_on" ] && echo 1 > "$GPU_PATH/force_bus_on" 2>/dev/null
    [ -f "$GPU_PATH/force_clk_on" ] && echo 1 > "$GPU_PATH/force_clk_on" 2>/dev/null

    # Disable throttling if available
    [ -f "$GPU_PATH/thermal_pwrlevel" ] && echo 0 > "$GPU_PATH/thermal_pwrlevel" 2>/dev/null
}

# Mali GPU optimization
apply_mali_balanced() {
    log_info "Applying BALANCED Mali GPU settings"

    if [ -f "$GPU_PATH/devfreq/min_freq" ] && [ -f "$GPU_PATH/devfreq/max_freq" ]; then
        local max_freq=$(cat "$GPU_PATH/devfreq/max_freq" 2>/dev/null)
        local min_freq=$(cat "$GPU_PATH/devfreq/min_freq" 2>/dev/null)

        if [ "$max_freq" ] && [ "$min_freq" ]; then
            local mid_freq=$((min_freq + (max_freq - min_freq) / 2))
            echo "$mid_freq" > "$GPU_PATH/devfreq/max_freq" 2>/dev/null
        fi
    fi
}

apply_mali_gaming() {
    log_info "Applying GAMING Mali GPU settings"

    if [ -f "$GPU_PATH/devfreq/max_freq" ]; then
        local max_freq=$(cat "$GPU_PATH/devfreq/max_freq" 2>/dev/null)

        if [ "$max_freq" ]; then
            local high_freq=$((max_freq * 3 / 4))
            echo "$high_freq" > "$GPU_PATH/devfreq/max_freq" 2>/dev/null
        fi
    fi
}

apply_mali_extreme() {
    log_info "Applying EXTREME Mali GPU settings"

    if [ -f "$GPU_PATH/devfreq/max_freq" ]; then
        local max_freq=$(cat "$GPU_PATH/devfreq/max_freq" 2>/dev/null)
        [ -n "$max_freq" ] && echo "$max_freq" > "$GPU_PATH/devfreq/max_freq" 2>/dev/null
    fi
}

# Generic GPU settings
apply_gpu_balanced() {
    log_info "Applying BALANCED GPU profile"

    case "$DETECTED_GPU" in
        Adreno)
            apply_adreno_balanced
            ;;
        Mali)
            apply_mali_balanced
            ;;
        *)
            log_warn "GPU optimization not available for $DETECTED_GPU"
            ;;
    esac
}

apply_gpu_gaming() {
    log_info "Applying GAMING GPU profile"

    case "$DETECTED_GPU" in
        Adreno)
            apply_adreno_gaming
            ;;
        Mali)
            apply_mali_gaming
            ;;
        *)
            log_warn "GPU optimization not available for $DETECTED_GPU"
            ;;
    esac
}

apply_gpu_extreme() {
    log_info "Applying EXTREME GPU profile"

    case "$DETECTED_GPU" in
        Adreno)
            apply_adreno_extreme
            ;;
        Mali)
            apply_mali_extreme
            ;;
        *)
            log_warn "GPU optimization not available for $DETECTED_GPU"
            ;;
    esac
}

export -f detect_gpu apply_gpu_balanced apply_gpu_gaming apply_gpu_extreme

