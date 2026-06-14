#!/system/bin/sh
# TitanBoost - Logging System

TITANBOOST_LOG="${TITANBOOST_LOG:-/data/local/tmp/titanboost.log}"

# Ensure log directory exists
mkdir -p "$(dirname "$TITANBOOST_LOG")"

# Log info message
log_info() {
    local msg="$1"
    echo "[INFO] $msg" >> "$TITANBOOST_LOG"
    echo "[INFO] $msg"
}

# Log warning message
log_warn() {
    local msg="$1"
    echo "[WARN] $msg" >> "$TITANBOOST_LOG"
    echo "[WARN] $msg"
}

# Log error message
log_error() {
    local msg="$1"
    echo "[ERROR] $msg" >> "$TITANBOOST_LOG"
    echo "[ERROR] $msg"
}

# Log success message
log_success() {
    local msg="$1"
    echo "[SUCCESS] $msg" >> "$TITANBOOST_LOG"
    echo "[SUCCESS] $msg"
}

# Get device information
get_device_info() {
    echo "=== Device Information ===" >> "$TITANBOOST_LOG"
    echo "Device: $(getprop ro.product.device)" >> "$TITANBOOST_LOG"
    echo "Manufacturer: $(getprop ro.product.manufacturer)" >> "$TITANBOOST_LOG"
    echo "Model: $(getprop ro.product.model)" >> "$TITANBOOST_LOG"
    echo "Android Version: $(getprop ro.build.version.release)" >> "$TITANBOOST_LOG"
    echo "Build ID: $(getprop ro.build.id)" >> "$TITANBOOST_LOG"
    echo "Kernel: $(uname -r)" >> "$TITANBOOST_LOG"
}

export -f log_info log_warn log_error log_success

