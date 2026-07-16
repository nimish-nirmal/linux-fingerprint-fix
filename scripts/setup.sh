#!/bin/bash
# =============================================================================
# Linux Fingerprint Fix — Automated Setup Script
# =============================================================================
# Universal script for fixing fingerprint sensors on HP, Dell, Lenovo, ASUS,
# Acer, and other laptops running Ubuntu/Debian-based Linux.
#
# Usage: chmod +x setup.sh && ./setup.sh
# =============================================================================

set -euo pipefail
umask 077

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
log_info()  { echo -e "${BLUE}[INFO]${NC} $1"; }
log_ok()    { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

VERSION="1.0.0"
REPO_URL="https://gitlab.freedesktop.org/Depau/libfprint.git"
BRANCH="elanmoc2"
BUILD_DIR="$HOME/libfprint"

# Safety: ensure BUILD_DIR is under $HOME
if [[ ! "$BUILD_DIR" == "$HOME"* ]]; then
    log_error "Build directory must be under \$HOME"
    exit 1
fi

# Trap-based cleanup on failure
CLEANUP_DIRS=()
cleanup_exit() {
    for dir in "${CLEANUP_DIRS[@]}"; do
        rm -rf "$dir" 2>/dev/null || true
    done
}
trap cleanup_exit EXIT

preflight_checks() {
    log_info "Running pre-flight checks..."
    if [[ $EUID -eq 0 ]]; then log_error "Do not run as root."; exit 1; fi
    # Use non-interactive sudo check first to avoid triggering fingerprint PAM
    if ! sudo -n true 2>/dev/null; then
        if ! sudo -v &>/dev/null; then
            log_error "Sudo access required. Run: sudo -v (enter password) then retry."
            exit 1
        fi
    fi
    local os_name os_version
    # shellcheck disable=SC1091
    os_name=$(. /etc/os-release 2>/dev/null && echo "${NAME:-Unknown}") || os_name="Unknown"
    # shellcheck disable=SC1091
    os_version=$(. /etc/os-release 2>/dev/null && echo "${VERSION_ID:-}") || os_version=""
    log_info "Detected OS: ${os_name} ${os_version}"
    log_ok "Pre-flight checks passed."
}

cleanup() {
    log_info "Cleaning up conflicting drivers..."
    # Run non-dependent tasks in parallel
    sudo apt purge -y open-fprintd fprintd-clients 2>/dev/null || true &
    sudo rm -f /lib/systemd/system/open-fprintd.service /lib/systemd/system/fprintd.service &
    sudo rm -f /etc/systemd/system/open-fprintd.service /etc/systemd/system/fprintd.service &
    wait
    sudo systemctl daemon-reload
    log_ok "Cleanup complete."
}

install_deps() {
    log_info "Installing dependencies..."
    # Only run apt update if cache is stale (>1 hour old)
    if [[ $(find /var/cache/apt/pkgcache.bin -mmin +60 2>/dev/null) ]]; then
        sudo apt update
    fi
    sudo apt install -y build-essential pkg-config libglib2.0-dev \
        libgusb-dev libgirepository1.0-dev libpixman-1-dev libnss3-dev libgudev-1.0-dev \
        gtk-doc-tools meson ninja-build git libssl-dev libcairo2-dev fprintd libpam-fprintd
    log_ok "Dependencies installed."
}

build_driver() {
    log_info "Building fingerprint driver..."
    rm -rf "$BUILD_DIR"
    CLEANUP_DIRS+=("$BUILD_DIR")
    git clone -b "$BRANCH" --depth 1 "$REPO_URL" "$BUILD_DIR"
    cd "$BUILD_DIR"
    meson setup builddir -Ddoc=false -Dtests=false -Dintrospection=false || \
        meson setup builddir -Ddoc=false -Dtests=false -Dintrospection=false -Ddrivers=elanmoc2
    cd builddir && ninja -j"$(nproc)"
    sudo ninja install && sudo ldconfig
    # Remove from cleanup on success
    CLEANUP_DIRS=("${CLEANUP_DIRS[@]/$BUILD_DIR}")
    log_ok "Driver built and installed."
}

verify() {
    log_info "Verifying installation..."
    sudo systemctl restart fprintd.service
    if systemctl is-active --quiet fprintd.service; then
        log_ok "fprintd service is running."
    else
        log_error "fprintd failed to start."
        journalctl -u fprintd.service --no-pager -n 20 2>/dev/null || true
        exit 1
    fi
    log_ok "Verification complete."
}

main() {
    echo "=== Linux Fingerprint Fix Setup v$VERSION ==="
    if [[ "${1:-}" == "--help" ]]; then
        echo "Usage: ./setup.sh [OPTION]"
        echo "Automated fingerprint driver setup for Linux."
        echo ""
        echo "Options:"
        echo "  --help      Show this help message"
        echo "  --version   Show version information"
        echo ""
        echo "No arguments: Run full setup"
        exit 0
    fi
    if [[ "${1:-}" == "--version" ]]; then
        echo "linux-fingerprint-fix setup.sh v$VERSION"
        exit 0
    fi
    preflight_checks; cleanup; install_deps; build_driver; verify
    echo ""
    echo "Next: Run 'fprintd-enroll' to register your fingerprint."
    echo "Then: Run 'sudo pam-auth-update' to enable system-wide auth."
}

main "$@"