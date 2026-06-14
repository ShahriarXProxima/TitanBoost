#!/system/bin/sh
# TitanBoost - Advanced RAM Cleaning Utilities

# Force RAM cleanup
force_ram_cleanup() {
    log_info "Executing force RAM cleanup"

    # Sync filesystem
    sync

    # Drop page cache
    if [ -w "/proc/sys/vm/drop_caches" ]; then
        echo 3 > /proc/sys/vm/drop_caches 2>/dev/null
        log_info "Page cache dropped"
    fi

    # Trim memory via PM
    pm trim-caches 8192 2>/dev/null || true

    # Force garbage collection
    am dumpheap system /data/local/tmp/heap.dump 2>/dev/null || true

    # Get memory stats
    local available=$(grep "MemAvailable" /proc/meminfo | awk '{print $2}')
    log_info "Available memory after cleanup: $((available / 1024))MB"
}

# Kill non-critical background processes
aggressive_kill() {
    log_warn "Starting aggressive background process termination"

    local whitelist="/sdcard/TitanBoost/whitelist.txt"

    # Critical system packages (never kill these)
    local critical_packages=(
        "com.android.systemui"
        "com.android.system"
        "com.android.settings"
        "com.android.phone"
        "com.android.bluetooth"
        "com.android.WiFiDialog"
        "system_server"
        "surfaceflinger"
        "zygote"
        "zygote64"
    )

    # Get all running packages
    local running_packages=$(pm list packages)

    # Kill each non-critical package
    while IFS= read -r package_line; do
        local package=$(echo "$package_line" | cut -d: -f2)

        # Skip critical packages
        local is_critical=false
        for critical in "${critical_packages[@]}"; do
            [ "$package" = "$critical" ] && is_critical=true
        done

        # Skip if in critical list
        [ "$is_critical" = "true" ] && continue

        # Skip if in whitelist
        if [ -f "$whitelist" ]; then
            grep -q "^$package$" "$whitelist" && continue
        fi

        # Kill the package
        killall "$package" 2>/dev/null && log_info "Killed: $package"

    done <<EOF
$running_packages
EOF

    log_success "Aggressive termination complete"
}

# Monitor memory usage
monitor_memory() {
    log_info "Memory Statistics"
    echo "================================"
    free -h
    echo "================================"

    local mem_total=$(grep "MemTotal" /proc/meminfo | awk '{print $2}')
    local mem_free=$(grep "MemFree" /proc/meminfo | awk '{print $2}')
    local mem_available=$(grep "MemAvailable" /proc/meminfo | awk '{print $2}')
    local mem_cached=$(grep "Cached" /proc/meminfo | awk '{print $2}')

    local usage=$((100 * (mem_total - mem_available) / mem_total))

    echo "Total: $((mem_total / 1024))MB"
    echo "Free: $((mem_free / 1024))MB"
    echo "Available: $((mem_available / 1024))MB"
    echo "Cached: $((mem_cached / 1024))MB"
    echo "Usage: $usage%"
    echo "================================"
}

# Tune virtual memory
tune_vm() {
    log_info "Tuning virtual memory parameters"

    # Virtual memory tunables
    local vm_params=(
        "/proc/sys/vm/swappiness:90"
        "/proc/sys/vm/vfs_cache_pressure:20"
        "/proc/sys/vm/dirty_ratio:50"
        "/proc/sys/vm/dirty_background_ratio:40"
        "/proc/sys/vm/watermark_scale_factor:125"
        "/proc/sys/vm/page-cluster:3"
    )

    for param in "${vm_params[@]}"; do
        local path="${param%:*}"
        local value="${param#*:}"

        if [ -f "$path" ] && [ -w "$path" ]; then
            echo "$value" > "$path" 2>/dev/null
            log_info "Set $path = $value"
        fi
    done
}

# Optimize I/O scheduler
optimize_io() {
    log_info "Optimizing I/O scheduler"

    # Set I/O scheduler to CFQ or deadline for performance
    for scheduler in /sys/block/*/queue/scheduler; do
        if [ -f "$scheduler" ]; then
            # Check available schedulers
            local available=$(cat "$scheduler")

            if echo "$available" | grep -q "noop"; then
                echo "noop" > "$scheduler" 2>/dev/null
            elif echo "$available" | grep -q "deadline"; then
                echo "deadline" > "$scheduler" 2>/dev/null
            fi
        fi
    done

    log_success "I/O optimization complete"
}

# Check system health
check_health() {
    log_info "System Health Check"
    echo "================================"

    # Check thermal
    if [ -d "/sys/class/thermal" ]; then
        for thermal in /sys/class/thermal/thermal_zone*/temp; do
            if [ -f "$thermal" ]; then
                local temp=$(cat "$thermal")
                echo "Thermal Zone: $((temp / 1000))°C"
            fi
        done
    fi

    # Check battery
    if [ -d "/sys/class/power_supply/battery" ]; then
        local battery_temp=$(cat /sys/class/power_supply/battery/temp 2>/dev/null)
        echo "Battery Temp: $battery_temp"
    fi

    # Check CPU frequencies
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq; do
        if [ -f "$cpu/scaling_cur_freq" ]; then
            local freq=$(cat "$cpu/scaling_cur_freq")
            echo "CPU Freq: $((freq / 1000))MHz"
        fi
    done

    echo "================================"
}

export -f force_ram_cleanup aggressive_kill monitor_memory
export -f tune_vm optimize_io check_health

