#!/bin/bash
# =============================================================================
# Linux Fingerprint Fix — Post-Installation Verification Script
# =============================================================================
# Checks if fingerprint sensor is properly installed and configured.
#
# Usage: chmod +x verify-setup.sh && ./verify-setup.sh
# =============================================================================

set -euo pipefail
umask 077

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
PASS=0; FAIL=0; WARN=0

print_result() {
    case "$1" in
        PASS) echo -e "  ${GREEN}✓ PASS${NC}  $2"; PASS=$((PASS + 1)) ;;
        FAIL) echo -e "  ${RED}✗ FAIL${NC}  $2 — $3"; FAIL=$((FAIL + 1)) ;;
        WARN) echo -e "  ${YELLOW}⚠ WARN${NC}  $2 — $3"; WARN=$((WARN + 1)) ;;
    esac
}

# Determine current user with fallback
CURRENT_USER="${USER:-$(whoami 2>/dev/null || echo "unknown")}"

echo "=== Fingerprint Sensor Verification ==="

# Test 1: USB Detection
sensor_found=$(lsusb | grep -ci "fingerprint\|04f3\|138a\|27c6\|06cb" || true)
if [[ "$sensor_found" -gt 0 ]]; then
    print_result PASS "Fingerprint sensor detected via lsusb"
else
    print_result WARN "No fingerprint sensor found via lsusb" "May be I2C-based"
fi

# Test 2: fprintd Service
if systemctl is-active --quiet fprintd.service 2>/dev/null; then
    print_result PASS "fprintd service is running"
else
    print_result FAIL "fprintd service" "Run: sudo systemctl start fprintd"
fi

# Test 3: libfprint Library
if ldconfig -p | grep -q libfprint; then
    print_result PASS "libfprint library found"
else
    print_result FAIL "libfprint library" "Run: sudo ldconfig"
fi

# Test 4: fprintd-list
if fprintd-list "$CURRENT_USER" 2>/dev/null | grep -qi "device\|elan\|fingerprint\|synaptics\|goodix\|match-on-chip"; then
    print_result PASS "Reader detected by fprintd"
else
    print_result WARN "No reader detected by fprintd" "Check driver installation"
fi

# Test 5: PAM Module
if [[ -f /usr/lib/x86_64-linux-gnu/security/pam_fprintd.so ]] || \
   [[ -f /lib/x86_64-linux-gnu/security/pam_fprintd.so ]]; then
    print_result PASS "pam_fprintd.so module found"
else
    print_result WARN "pam_fprintd.so not found" "Install: sudo apt install libpam-fprintd"
fi

# Test 6: ShellCheck compliance (informational)
if command -v shellcheck &>/dev/null; then
    print_result PASS "shellcheck available for static analysis"
else
    print_result WARN "shellcheck not installed" "Install: sudo apt install shellcheck"
fi

# Summary
echo ""
echo "Results: $PASS passed, $FAIL failed, $WARN warnings"
if [[ $FAIL -eq 0 ]]; then
    echo -e "${GREEN}All critical checks passed.${NC}"
    echo "Run 'fprintd-enroll' to register your fingerprint."
else
    echo -e "${RED}Some checks failed.${NC} See docs/troubleshooting.md for help."
    exit 1
fi