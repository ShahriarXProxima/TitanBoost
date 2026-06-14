#!/system/bin/sh
# TitanBoost - Uninstall Script

MODDIR="${0%/*}"
TITANBOOST_LOG="/data/local/tmp/titanboost.log"

# Log uninstallation
echo "[$(date '+%Y-%m-%d %H:%M:%S')] TitanBoost uninstallation started" >> "$TITANBOOST_LOG"

# Restore default CPU governors
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    [ -f "$cpu" ] && echo "schedutil" > "$cpu" 2>/dev/null
done

# Reset GPU settings
for gpu in /sys/class/kgsl/kgsl-3d0/*; do
    [ -f "$gpu/devfreq/min_freq" ] && echo "0" > "$gpu/devfreq/min_freq" 2>/dev/null
done

# Reset memory settings
echo 0 > /proc/sys/vm/drop_caches 2>/dev/null

# Log completion
echo "[$(date '+%Y-%m-%d %H:%M:%S')] TitanBoost uninstallation completed" >> "$TITANBOOST_LOG"

