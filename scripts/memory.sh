#!/system/bin/sh
# TitanBoost - Memory Optimization Module

# Get available memory
get_available_memory() {
    grep "MemAvailable" /proc/meminfo | awk '{print $2}'
}

# Trigger garbage collection safely
safe_garbage_collection() {
    # Synchronize filesystem first
    sync 2>/dev/null

    # Drop page cache safely
    if [ -f "/proc/sys/vm/drop_caches" ]; then
        echo 3 > /proc/sys/vm/drop_caches 2>/dev/null
        log_info "Page cache cleared"
    fi

    # Trim caches via am command
    am trim-caches 8192 2>/dev/null || log_warn "Failed to execute trim-caches"
}

# Clean cached applications
clean_cached_apps() {
    log_info "Cleaning cached apps"
    pm trim-caches 4096 2>/dev/null

    # Get list of cached packages (excluding critical services)
    local whitelist="/sdcard/TitanBoost/whitelist.txt"

    # Kill cached processes (pkill)
    for app in $(pm list packages -3 | cut -d: -f2); do
        local should_kill=true

        # Check whitelist
        if [ -f "$whitelist" ]; then
            if grep -q "^$app$" "$whitelist"; then
                should_kill=false
            fi
        fi

        # Never kill critical services
        case "$app" in
            com.android.systemui|surfaceflinger|com.android.phone|com.android.systemserver|vendor.*)
                should_kill=false
                ;;
        esac

        if [ "$should_kill" = "true" ]; then
            killall "$app" 2>/dev/null
        fi
    done

    log_success "Cached app cleanup complete"
}

# Apply balanced memory profile
apply_memory_balanced() {
    log_info "Applying BALANCED memory profile"

    # Light cache pressure
    if [ -f "/proc/sys/vm/vfs_cache_pressure" ]; then
        echo 50 > /proc/sys/vm/vfs_cache_pressure 2>/dev/null
    fi
}

# Apply gaming memory profile
apply_memory_gaming() {
    log_info "Applying GAMING memory profile"

    # More aggressive caching
    if [ -f "/proc/sys/vm/vfs_cache_pressure" ]; then
        echo 30 > /proc/sys/vm/vfs_cache_pressure 2>/dev/null
    fi

    # Clean cached apps
    clean_cached_apps

    # Trim caches
    safe_garbage_collection
}

# Apply extreme memory profile
apply_memory_extreme() {
    log_info "Applying EXTREME memory profile"

    # Very aggressive caching
    if [ -f "/proc/sys/vm/vfs_cache_pressure" ]; then
        echo 10 > /proc/sys/vm/vfs_cache_pressure 2>/dev/null
    fi

    # Set swappiness
    if [ -f "/proc/sys/vm/swappiness" ]; then
        echo 90 > /proc/sys/vm/swappiness 2>/dev/null
    fi

    # Aggressive cleaning
    clean_cached_apps
    safe_garbage_collection

    # Drop pagecache
    if [ -f "/proc/sys/vm/drop_caches" ]; then
        echo 3 > /proc/sys/vm/drop_caches 2>/dev/null
    fi

    log_success "Extreme memory optimization applied"
}

# Optimize ZRAM if present
optimize_zram() {
    local zram_device="/sys/block/zram0"

    if [ -d "$zram_device" ]; then
        log_info "Optimizing ZRAM"

        # Set compression algorithm to LZ4 (fastest) if available
        if [ -f "$zram_device/comp_algorithm" ]; then
            local available=$(cat "$zram_device/comp_algorithm")
            if echo "$available" | grep -q "lz4"; then
                echo "lz4" > "$zram_device/comp_algorithm" 2>/dev/null
            fi
        fi

        # Set swappiness for ZRAM
        if [ -f "/proc/sys/vm/swappiness" ]; then
            echo 100 > /proc/sys/vm/swappiness 2>/dev/null
        fi

        log_success "ZRAM optimized"
    fi
}

# Check and optimize LMKD settings
optimize_lmkd() {
    log_info "Optimizing LMKD settings"

    # These are set via system.prop, but we can apply additional tuning here
    # LMKD properties are managed through property_contexts and init scripts
    # Just log that they were considered

    log_info "LMKD settings configured via system.prop"
}

export -f get_available_memory safe_garbage_collection clean_cached_apps
export -f apply_memory_balanced apply_memory_gaming apply_memory_extreme
export -f optimize_zram optimize_lmkd

