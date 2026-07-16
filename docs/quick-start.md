# ⚡ Quick Start — Linux Fingerprint Fix

Minimal steps for experienced users. Skip to the section that matches your issue.

---

## 1. Identify Your Sensor
```bash
lsusb | grep -i "fingerprint\|04f3\|138a\|27c6\|06cb\|17ef\|0488\|10a5"
```

## 2. Install fprintd
```bash
sudo apt update && sudo apt install fprintd libpam-fprintd -y
sudo systemctl restart fprintd
```

## 3. Enroll Fingerprint
```bash
fprintd-enroll
```

## 4. Enable System-Wide Auth
```bash
sudo pam-auth-update
```
Check `[*] Fingerprint authentication`.

## 5. Test
```bash
sudo -v
```

## Quick Fixes

| Problem | Solution |
|---------|----------|
| Sensor stops after sleep | `sudo systemctl restart fprintd` |
| Sensor not detected | `sudo ldconfig && sudo systemctl restart fprintd` |
| Already enrolled error | `fprintd-delete "$USER"` then re-enroll |
| sudo still asks for password | Edit `/etc/pam.d/sudo` — add `auth sufficient pam_fprintd.so` |

---

*See the [Full Guide](full-guide.md) for detailed instructions.*