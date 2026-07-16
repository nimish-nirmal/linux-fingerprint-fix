# 📋 Supported Devices — Linux Fingerprint Fix

Fingerprint sensors known to work on Linux by brand.

---

## Confirmed Working Sensors

| Vendor ID | Brand | Common Laptop Models | Notes |
|-----------|-------|---------------------|-------|
| `04f3:0c00` | Elan | ASUS ZenBook, Acer Swift, Dell XPS | Elan ARM-M4 |
| `04f3:0c37` | Elan | HP Spectre, Lenovo Yoga | |
| `04f3:0c46` | Elan | ASUS Vivobook | |
| `04f3:0c4f` | Elan | Dell Inspiron | |
| `04f3:0c52` | Elan | HP Envy | |
| `04f3:0c56` | Elan | Lenovo ThinkPad | |
| `04f3:0c5a` | Elan | Acer Aspire | |
| `04f3:0c60` | Elan | ASUS ROG | |
| `04f3:0c62` | Elan | HP Pavilion | |
| `04f3:0c6b` | Elan | Various | |
| `06cb:009a` | Synaptics | Dell Latitude, HP EliteBook | |
| `06cb:00a6` | Synaptics | Lenovo ThinkPad | |
| `27c6:5380` | Goodix | Dell XPS, ASUS | |
| `138a:0001` | Validity | HP (older models) | |

---

## How to Check Your Device

```bash
lsusb | grep -i "04f3\|138a\|27c6\|06cb\|17ef\|0488\|10a5"
```

---

## How to Contribute

If your sensor works but isn't listed, open an issue or PR with:
- Your `lsusb` output
- Laptop brand and model
- Distribution and kernel version (`uname -a`)