# Universal Fingerprint Sensor Fix Guide for Linux

A complete troubleshooting and installation guide for fingerprint sensors on **HP, Dell, Lenovo, ASUS, Acer, and other laptops** running Ubuntu/Debian-based Linux distributions.

> **Compatibility:** Tested on Ubuntu 20.04 LTS, 22.04 LTS, 24.04 LTS, Debian 11/12, Linux Mint 21/22, Pop!_OS 22.04+
> **Last Updated:** July 2026

---

## 📋 Table of Contents

1. [Identify Your Sensor](#-step-0-identify-your-fingerprint-sensor)
2. [Purge Conflicting Drivers](#-step-1-purge-conflicting-third-party-drivers)
3. [Install Core Build Utilities](#-step-2-install-core-build-utilities--libraries)
4. [Install the Driver](#-step-3-install-the-fingerprint-driver)
5. [Start Service & Enroll](#-step-4-start-the-service-and-register-fingerprints)
6. [Enable System-Wide Auth](#-step-5-enable-authentication-system-wide)
7. [Verify Setup](#-step-6-verify-fingerprint-authentication)
8. [Managing Multiple Fingers](#-step-7-managing-multiple-fingerprints)
9. [Troubleshooting](#-troubleshooting--known-quirks)
10. [Uninstalling / Reverting](#-uninstalling--reverting-the-driver)

---

## 🖥️ Step 0: Identify Your Fingerprint Sensor

Before installing anything, identify which fingerprint sensor your laptop has.

### 0.1 List USB Devices

```bash
lsusb | grep -i "fingerprint\|04f3\|138a\|27c6\|06cb\|17ef\|0488\|10a5"
```

Common sensor vendors by brand:

| Brand | Common Vendors | lsusb IDs |
|-------|---------------|-----------|
| **HP** | Validity/Synaptics, Elan | `138a:`, `06cb:`, `04f3:` |
| **Dell** | Goodix, Synaptics | `27c6:`, `06cb:` |
| **Lenovo** | Synaptics, Elan | `06cb:`, `04f3:` |
| **ASUS** | Elan, Goodix | `04f3:`, `27c6:` |
| **Acer** | Elan, Synaptics | `04f3:`, `06cb:` |

No output? The sensor may be connected via I2C (not USB). Try:

```bash
# Check I2C devices
sudo dmesg | grep -i "fingerprint\|fprint"
ls /sys/bus/i2c/devices/ | grep -i "elan\|synaptics\|goodix"
```

### 0.2 Check Current State

```bash
# Check fprintd status
systemctl status fprintd 2>/dev/null || echo "fprintd not installed"

# Check kernel modules
lsmod | grep -i "fprint\|elan\|synaptics\|goodix"

# Check if any fingerprint driver is already loaded
fprintd-list 2>/dev/null || echo "fprintd not available"
```

---

## 🛠️ Step 1: Purge Conflicting Third-Party Drivers

If you've tried PPAs or manual installs before, clean them up first.

```bash
# Purge conflicting packages
sudo apt purge open-fprintd fprintd-clients -y
sudo apt purge libfprint-2-2 libfprint-2-dev 2>/dev/null || true

# Remove leftover systemd files
sudo rm -f /lib/systemd/system/open-fprintd.service
sudo rm -f /lib/systemd/system/fprintd.service
sudo rm -f /etc/systemd/system/open-fprintd.service
sudo rm -f /etc/systemd/system/fprintd.service

# Reload
sudo systemctl daemon-reload
```

---

## 📦 Step 2: Install Core Build Utilities & Libraries

```bash
sudo apt update
sudo apt install -y build-essential pkg-config libglib2.0-dev libgusb-dev \
  libgirepository1.0-dev libpixman-1-dev libnss3-dev libgudev-1.0-dev \
  gtk-doc-tools meson ninja-build git libssl-dev libcairo2-dev \
  fprintd libpam-fprintd
```

---

## 🔧 Step 3: Install the Fingerprint Driver

### Option A: Use the mainline libfprint (recommended for most users)

```bash
# Install the official libfprint package
sudo apt install libfprint-2-2 -y
sudo systemctl restart fprintd
```

### Option B: Build from source (for unsupported sensors)

If the official package doesn't work, try the community `elanmoc2` branch:

```bash
cd ~
git clone -b elanmoc2 --depth 1 https://gitlab.freedesktop.org/Depau/libfprint.git
cd libfprint
meson setup builddir
cd builddir
ninja -j$(nproc)
sudo ninja install
sudo ldconfig
```

### Option C: For specific sensors (check docs)

See the [Supported Devices](../SUPPORTED_DEVICES.md) page for brand-specific instructions.

---

## 🔑 Step 4: Start the Service and Register Fingerprints

```bash
# Restart the fingerprint service
sudo systemctl restart fprintd.service

# Verify service is running
sudo systemctl status fprintd.service

# Enroll your fingerprint
fprintd-enroll
```

### Enrollment Tips

| Do ✅ | Don't ❌ |
|------|---------|
| Wash and dry your hands first | Don't enroll with wet/oily fingers |
| Tap the same finger consistently | Don't switch fingers mid-enrollment |
| Vary the angle slightly each scan | Don't tap the exact same spot repeatedly |
| Tap in a steady rhythm | Don't tap too fast or too slow |

---

## 🎛️ Step 5: Enable Authentication System-Wide

```bash
sudo pam-auth-update
```

1. Navigate to **`Fingerprint authentication`**
2. Press **Spacebar** to check `[*]`
3. Press **Tab** then **Enter** to save

### Manual PAM Config (alternative)

If `pam-auth-update` doesn't work:

```bash
sudo nano /etc/pam.d/common-auth
```

Add this line **above** `pam_unix.so`:
```
auth    [success=2 default=ignore]    pam_fprintd.so
```

---

## ✅ Step 6: Verify Fingerprint Authentication

```bash
# Test with sudo
sudo -v

# List enrolled fingers
fprintd-list

# Check authentication logs
sudo journalctl -u fprintd.service --no-pager -n 20
```

---

## 🖐️ Step 7: Managing Multiple Fingerprints

```bash
# List enrolled fingers
fprintd-list

# Delete a specific finger
fprintd-delete "$USER" -f right-index-finger

# Delete all fingers
fprintd-delete "$USER"

# Enroll a specific finger
fprintd-enroll -f left-index-finger
```

---

## 🚨 Troubleshooting & Known Quirks

### 1. Sensor Not Detected After Suspend

```bash
sudo systemctl restart fprintd
```

For a permanent fix, create a systemd service (see [Troubleshooting Guide](troubleshooting.md)).

### 2. "No Devices Available"

| Check | Command |
|-------|---------|
| USB detection | `lsusb \| grep -i "04f3\|138a\|27c6\|06cb"` |
| Service status | `systemctl status fprintd` |
| Library cache | `sudo ldconfig && sudo systemctl restart fprintd` |

### 3. Fingerprint Not Working for sudo

Edit `/etc/pam.d/sudo` and add:
```
auth       sufficient    pam_fprintd.so
```

---

## 🗑️ Uninstalling / Reverting the Driver

```bash
cd ~/libfprint/builddir/ && sudo ninja uninstall && sudo ldconfig
rm -rf ~/libfprint
sudo systemctl stop fprintd && sudo systemctl disable fprintd
sudo pam-auth-update   # Uncheck 'Fingerprint authentication'
sudo apt remove --purge fprintd libpam-fprintd -y && sudo apt autoremove -y
```

---

## 📚 Additional Resources

- [libfprint Project](https://gitlab.freedesktop.org/libfprint/libfprint)
- [fprintd Documentation](https://fprint.freedesktop.org/)
- [Arch Wiki: Fprint](https://wiki.archlinux.org/title/Fprint)
- [Ubuntu Fingerprint Help](https://help.ubuntu.com/community/FingerprintAuthentication)

---

*This guide is brand-agnostic and maintained by the community.*