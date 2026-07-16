# ❓ FAQ — Linux Fingerprint Fix

---

### Q1: My sensor isn't detected at all. What should I do?

First, identify it:
```bash
lsusb
```
Look for any device with `Fingerprint` in the name or IDs like `04f3:`, `138a:`, `27c6:`, `06cb:`. If nothing appears, it may be an I2C sensor. Check:
```bash
sudo dmesg | grep -i finger
```

---

### Q2: Does this work on Wayland?

**Yes.** fprintd works on both X11 and Wayland.

---

### Q3: Will kernel updates break my fingerprint driver?

**Usually not.** The compiled libraries are user-space, not kernel modules. Kernel updates typically don't affect them.

---

### Q4: Can I enroll multiple users?

**Yes.** Each user enrolls independently:
```bash
sudo -u otheruser fprintd-enroll
```

---

### Q5: Can I use fingerprint for SSH?

**Not directly.** Use SSH keys protected by your fingerprint via PAM instead.

---

### Q6: Does fingerprint work in BIOS/UEFI?

**No.** The sensor only works after the OS loads. BIOS fingerprint auth requires firmware support.

---

### Q7: My sensor is not listed. Will it work?

The community `elanmoc2` branch supports many Elan sensors. Goodix, Synaptics, and Validity sensors may need different drivers. Check the [Supported Devices](../SUPPORTED_DEVICES.md) page.

---

### Q8: Is fingerprint authentication secure?

Fingerprint is convenient but less secure than a strong password. Use it for convenience, not for sensitive operations. Always keep a strong password as fallback.

---

### Q9: Do I need to recompile after OS upgrades?

Only if you built from source and upgrade to a new Ubuntu release (e.g., 22.04 → 24.04). The official `libfprint` package updates automatically.

---

### Q10: How many fingers can I enroll?

No hard limit, but 2–4 is recommended (both index fingers + optionally thumbs).

---

*Still have questions? Open an issue in the repository.*