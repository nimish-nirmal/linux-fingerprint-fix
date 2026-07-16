# 🗑️ Uninstall Guide — Linux Fingerprint Fix

How to completely remove fingerprint drivers.

---

## Full Removal

```bash
# 1. Remove compiled driver (if built from source)
cd ~/libfprint/builddir/ 2>/dev/null && sudo ninja uninstall && sudo ldconfig
cd ~ && rm -rf ~/libfprint

# 2. Stop and disable service
sudo systemctl stop fprintd.service
sudo systemctl disable fprintd.service

# 3. Revert PAM
sudo pam-auth-update   # Uncheck 'Fingerprint authentication'

# 4. Delete fingerprint data
fprintd-delete "$USER"

# 5. Remove packages
sudo apt remove --purge fprintd libpam-fprintd -y
sudo apt autoremove -y

# 6. Remove resume service (if installed)
sudo systemctl disable fprintd-resume.service 2>/dev/null || true
sudo rm -f /etc/systemd/system/fprintd-resume.service
sudo systemctl daemon-reload

echo "Uninstall complete. Reboot recommended."
```

## Post-Uninstall Verification

```bash
systemctl list-units --type=service | grep fprint  # Should be empty
ldconfig -p | grep libfprint                        # Should be empty
ps aux | grep fprint                                # Should show only grep
```

---

*To reinstall, follow the [Full Guide](full-guide.md) again.*