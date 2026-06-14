#!/system/bin/sh
# TitanBoost - CPU Optimization Module

# Detect SoC type
detect_soc() {
    local hardware=$(getprop ro.hardware)
    local soc=$(getprop ro.soc.model)

    if echo "$hardware" | grep -qi "snapdragon\|msm\|sm"; then
        DETECTED_SOC="Qualcomm Snapdragon"
        log_info "Detected SoC: Qualcomm Snapdragon ($hardware)"
    elif echo "$soc" | grep -qi "helio\|mt"; then
        DETECTED_SOC="MediaTek"
        log_info "Detected SoC: MediaTek ($soc)"
    elif echo "$hardware" | grep -qi "exynos"; then
        DETECTED_SOC="Samsung Exynos"
        log_info "Detected SoC: Samsung Exynos ($hardware)"
    elif echo "$hardware" | grep -qi "apple"; then
        DETECTED_SOC="Apple"
        log_info "Detected SoC: Apple ($hardware)"
    else
        DETECTED_SOC="Unknown SoC"
        log_warn "Unknown SoC: $hardware / $soc"
    fi
}

# Get best available governor
get_best_governor() {
    local available_governors
    for cpu_path in /sys/devices/system/cpu/cpu0/cpufreq; do
        if [ -f "$cpu_path/scaling_available_governors" ]; then
            available_governors=$(cat "$cpu_path/scaling_available_governors")
            break
        fi
    done

    # Check in preferred order
    for gov in performance schedutil interactive; do
        if echo "$available_governors" | grep -q "$gov"; then
            echo "$gov"
            return 0
        fi
    done

    # Fallback to first available
    echo "$available_governors" | awk '{print $1}'
}

# Apply CPU governor
apply_cpu_governor() {
    local governor="$1"
    local count=0

    for cpu_path in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        if [ -f "$cpu_path" ]; then
            echo "$governor" > "$cpu_path" 2>/dev/null
            count=$((count+1))
        fi
    done

    if [ $count -gt 0 ]; then
        log_success "Applied CPU governor '$governor' to $count CPUs"
    else
        log_warn "Failed to apply CPU governor, no paths found"
    fi
}

# Get CPU max frequency
get_cpu_max_freq() {
    for cpu in /sys/devices/system/cpu/cpu0/cpufreq; do
        if [ -f "$cpu/cpuinfo_max_freq" ]; then
            cat "$cpu/cpuinfo_max_freq"
            return 0
        fi
    done
    echo "0"
}

# Get CPU min frequency
get_cpu_min_freq() {
    for cpu in /sys/devices/system/cpu/cpu0/cpufreq; do
        if [ -f "$cpu/cpuinfo_min_freq" ]; then
            cat "$cpu/cpuinfo_min_freq"
            return 0
        fi
    done
    echo "0"
}

# Set CPU scaling frequency
set_cpu_freq_limits() {
    local min_freq="$1"
    local max_freq="$2"

    for cpu_path in /sys/devices/system/cpu/cpu*/cpufreq; do
        if [ -d "$cpu_path" ]; then
            [ -f "$cpu_path/scaling_min_freq" ] && echo "$min_freq" > "$cpu_path/scaling_min_freq" 2>/dev/null
            [ -f "$cpu_path/scaling_max_freq" ] && echo "$max_freq" > "$cpu_path/scaling_max_freq" 2>/dev/null
        fi
    done

    log_info "Set CPU frequencies: min=$min_freq max=$max_freq"
}

# Disable core control (Qualcomm)
disable_core_control() {
    for path in /sys/module/lpm_levels/parameters /etc/firmware /proc/sys/kernel; do
        if [ -f "$path/core_control" ]; then
            echo 0 > "$path/core_control" 2>/dev/null
        fi
    done
}

# Enable all cores
enable_all_cores() {
    for cpu_path in /sys/devices/system/cpu/cpu*/online; do
        if [ -f "$cpu_path" ]; then
            echo 1 > "$cpu_path" 2>/dev/null
        fi
    done
    log_success "All CPU cores enabled"
}

# Apply balanced CPU profile
apply_cpu_balanced() {
    log_info "Applying BALANCED CPU profile"

    local governor=$(get_best_governor)
    apply_cpu_governor "$governor"

    # Normal frequency scaling
    local max_freq=$(get_cpu_max_freq)
    local min_freq=$(get_cpu_min_freq)
    local mid_freq=$((min_freq + (max_freq - min_freq) / 2))

    set_cpu_freq_limits "$min_freq" "$mid_freq"

    # Don't lock all cores
    for i in /sys/devices/system/cpu/cpu*/online; do
        [ -f "$i" ] && echo 1 > "$i" 2>/dev/null
    done
}

# Apply gaming CPU profile
apply_cpu_gaming() {
    log_info "Applying GAMING CPU profile"

    apply_cpu_governor "performance"
    enable_all_cores

    # Higher frequency scaling
    local max_freq=$(get_cpu_max_freq)
    local min_freq=$(get_cpu_min_freq)
    local high_freq=$((min_freq + (max_freq - min_freq) * 3 / 4))

    set_cpu_freq_limits "$min_freq" "$high_freq"

    # Disable core hotplug if possible
    for path in /sys/module/msm_hotplug /sys/module/hotplug /sys/class/devfreq; do
        if [ -d "$path" ]; then
            [ -f "$path/enabled" ] && echo 0 > "$path/enabled" 2>/dev/null
        fi
    done
}

# Apply extreme CPU profile
apply_cpu_extreme() {
    log_info "Applying EXTREME CPU profile"

    apply_cpu_governor "performance"
    enable_all_cores

    # Maximum frequency scaling
    local max_freq=$(get_cpu_max_freq)
    local min_freq=$(get_cpu_min_freq)

    set_cpu_freq_limits "$min_freq" "$max_freq"

    # Boost settings if available
    if [ -f "/sys/module/cpu_boost/parameters/boost_ms" ]; then
        echo 10 > /sys/module/cpu_boost/parameters/boost_ms 2>/dev/null
    fi

    if [ -f "/sys/module/cpu_boost/parameters/input_boost_freq" ]; then
        echo "$max_freq" > /sys/module/cpu_boost/parameters/input_boost_freq 2>/dev/null
    fi

    log_success "Extreme CPU profile applied"
}

export -f detect_soc get_best_governor apply_cpu_governor get_cpu_max_freq
export -f get_cpu_min_freq set_cpu_freq_limits enable_all_cores
export -f apply_cpu_balanced apply_cpu_gaming apply_cpu_extreme

