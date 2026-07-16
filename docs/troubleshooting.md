# 🚨 Troubleshooting Guide — Linux Fingerprint Fix

Common fingerprint sensor issues across all laptop brands.

---

## 1. Sensor Not Detected After Suspend/Wake

**Symptom:** Fingerprint works after reboot but stops after sleep.

**Fix:**
```bash
sudo systemctl restart fprintd
```

**Permanent fix (systemd service):**
```bash
sudo tee /etc/systemd/system/fprintd-resume.service > /dev/null << 'EOF'
[Unit]
Description=Restart fprintd after resume
After=suspend.target

[Service]
Type=oneshot
ExecStart=/usr/bin/systemctl restart fprintd

[Install]
WantedBy=suspend.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable fprintd-resume.service
```

---

## 2. "No Devices Available"

**Symptom:** `fprintd-list` shows no devices.

| Cause | Check | Fix |
|-------|-------|-----|
| Driver not installed | `dpkg -l \| grep libfprint` | Install libfprint |
| Service not running | `systemctl status fprintd` | `sudo systemctl start fprintd` |
| USB not detected | `lsusb \| grep -i "04f3\|138a\|27c6\|06cb"` | Check BIOS settings |
| Library cache stale | `ldconfig -p \| grep libfprint` | `sudo ldconfig` |

---

## 3. "Fingerprint Already Enrolled"

```bash
fprintd-delete "$USER"
fprintd-enroll
```

---

## 4. Fingerprint Works for Login but Not sudo

Edit `/etc/pam.d/sudo` and add at the top:
```
auth       sufficient    pam_fprintd.so
```

---

## 5. PAM Authentication Loop

**Fix:** Edit `/etc/pam.d/common-auth`:
```
auth    [success=2 default=ignore]    pam_fprintd.so
auth    [success=1 default=ignore]    pam_unix.so nullok_secure
```

---

## 6. Permission Denied

```bash
sudo usermod -a -G plugdev "$USER"
# Log out and back in
```

---

## 7. Slow Recognition

- Clean sensor with 70% isopropyl alcohol
- Re-enroll with varied finger angles
- Enroll the same finger twice under different names

---

## 8. Build/Compilation Errors

| Error | Fix |
|-------|-----|
| `glib.h not found` | `sudo apt install libglib2.0-dev` |
| `meson setup fails` | Try `-Ddrivers=elanmoc2` flag |
| Out of memory | `ninja -j2` (fewer threads) |

---

*Still stuck? Open an issue with your `lsusb` output and distribution details.*