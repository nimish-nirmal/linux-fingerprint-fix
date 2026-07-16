#!/bin/bash
# =============================================================================
# Linux Fingerprint Fix — Sensor Reset After Suspend
# =============================================================================
# Recovers fingerprint sensor after laptop wakes from sleep.
# Works with HP, Dell, Lenovo, ASUS, Acer, and other laptops.
#
# Usage: chmod +x reset-sensor.sh && ./reset-sensor.sh
# =============================================================================

set -euo pipefail
umask 077

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
log_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Configuration — override via environment variables
POLL_TIMEOUT="${POLL_TIMEOUT:-10}"
USB_CONTROLLER="${USB_CONTROLLER:-}"

# Auto-detect USB controller if not specified
if [[ -z "$USB_CONTROLLER" ]]; then
    USB_CONTROLLER=$(lspci 2>/dev/null | grep "USB controller" | head -1 | awk '{print $1}' || true)
    if [[ -n "$USB_CONTROLLER" ]]; then
        USB_CONTROLLER="0000:$USB_CONTROLLER"
    else
        USB_CONTROLLER="0000:00:14.0"  # Fallback default
    fi
fi

# Check sudo non-interactively first
if ! sudo -n true 2>/dev/null; then
    if ! sudo -v &>/dev/null; then
        log_error "Sudo access required. Run: sudo -v (enter password) then retry."
        exit 1
    fi
fi

# Polling function to wait for sensor with timeout
wait_for_sensor() {
    local timeout="${1:-$POLL_TIMEOUT}"
    local elapsed=0
    while [[ $elapsed -lt $timeout ]]; do
        if fprintd-list "$USER" 2>/dev/null | grep -qi "device\|elan\|match-on-chip\|fingerprint\|synaptics\|goodix"; then
            return 0
        fi
        sleep 1
        ((elapsed++))
    done
    return 1
}

log_info "Attempting to recover fingerprint sensor..."

# Method 1: Restart fprintd
log_info "Method 1: Restarting fprintd..."
sudo systemctl restart fprintd
if wait_for_sensor 5; then
    log_info "Sensor recovered via service restart!"
    exit 0
fi

# Method 2: USB controller reset
log_info "Method 2: Resetting USB controller ($USB_CONTROLLER)..."
sudo sh -c "echo -n '$USB_CONTROLLER' > /sys/bus/pci/drivers/xhci_hcd/unbind" 2>/dev/null || \
    log_warn "USB unbind failed. Check controller address."
sleep 2
sudo sh -c "echo -n '$USB_CONTROLLER' > /sys/bus/pci/drivers/xhci_hcd/bind" 2>/dev/null || \
    log_warn "USB bind failed."
sleep 2
sudo systemctl restart fprintd
if wait_for_sensor 5; then
    log_info "Sensor recovered after USB controller reset!"
    exit 0
fi

log_error "Sensor could not be recovered. Try rebooting."
exit 1