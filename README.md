# Linux Fingerprint Fix — Universal Troubleshooting Guide

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20Ubuntu%20%7C%20Debian-orange)]()
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)]()

A comprehensive, community-maintained guide for fixing fingerprint sensor issues on **HP, Dell, Lenovo, ASUS, Acer, and other laptops** running Linux.

---

## 📌 Quick Links

| Resource | Description |
|----------|-------------|
| [📖 Full Guide](docs/full-guide.md) | Complete step-by-step troubleshooting and installation |
| [⚡ Quick Start](docs/quick-start.md) | Minimal steps for experienced users |
| [🚨 Troubleshooting](docs/troubleshooting.md) | Solutions for common fingerprint issues |
| [❓ FAQ](docs/faq.md) | Frequently asked questions |
| [🔒 Security](docs/security.md) | Security considerations & best practices |
| [🗑️ Uninstall](docs/uninstall.md) | How to revert/remove fingerprint drivers |
| [📋 Supported Devices](SUPPORTED_DEVICES.md) | Compatible sensor IDs by brand |
| [🛠️ Scripts](scripts/) | Automation scripts |

## ✨ What This Covers

- ✅ **Fingerprint sensor not detected** — Driver installation and USB recovery
- ✅ **Sensor stops after suspend** — Fixes for sleep/wake issues
- ✅ **"No devices available"** — Diagnostic and resolution steps
- ✅ **Fingerprint enrollment failures** — Common errors and solutions
- ✅ **sudo/login authentication** — PAM configuration for all use cases
- ✅ **Multi-finger support** — Enroll and manage multiple fingerprints
- ✅ **Cross-brand support** — HP, Dell, Lenovo, ASUS, Acer, and more
- ✅ **Uninstall instructions** — Full revert, backup restore, system rollback

## 🖥️ Supported Laptop Brands

| Brand | Common Sensors | Status |
|-------|---------------|--------|
| **HP** | Elan, Synaptics, Validity | ✅ Tested |
| **Dell** | Goodix, Synaptics | ✅ Tested |
| **Lenovo** | Synaptics, Elan | ✅ Tested |
| **ASUS** | Elan, Goodix | ✅ Tested |
| **Acer** | Elan, Synaptics | ✅ Tested |
| **Microsoft Surface** | Synaptics | ⚠️ Partial |
| **Others** | Various USB/ I2C sensors | ⚠️ Check SUPPORTED_DEVICES.md |

## 📁 Repository Structure

```
linux-fingerprint-fix/
├── README.md                 # This file
├── LICENSE                   # MIT License
├── CHANGELOG.md              # Version history
├── SUPPORTED_DEVICES.md      # Compatible hardware list
├── CONTRIBUTING.md           # Contribution guidelines
├── docs/
│   ├── full-guide.md         # Complete troubleshooting guide
│   ├── quick-start.md        # Minimal setup steps
│   ├── troubleshooting.md    # Common issues & fixes
│   ├── faq.md                # Frequently asked questions
│   ├── security.md           # Security considerations
│   └── uninstall.md          # Removal instructions
├── scripts/
│   ├── setup.sh              # Automated driver installation
│   ├── reset-sensor.sh       # USB reset after suspend
│   └── verify-setup.sh       # Post-installation check
├── configs/
│   ├── fprintd-resume.service  # Resume fix service
│   └── pam-fprintd.conf        # PAM configuration samples
└── assets/
    └── images/               # Screenshots and diagrams
```

## 🛠️ Automation Scripts

| Script | Purpose |
|--------|---------|
| [`scripts/setup.sh`](scripts/setup.sh) | Automated driver setup and installation |
| [`scripts/reset-sensor.sh`](scripts/reset-sensor.sh) | Recover sensor after suspend |
| [`scripts/verify-setup.sh`](scripts/verify-setup.sh) | Verify installation and diagnose issues |

## 🤝 Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

## ⚠️ Disclaimer

This is a community-maintained project. Fingerprint sensor support on Linux varies by hardware. Use at your own risk. Always keep your password as a backup authentication method.

---

*Maintained by the community. Compatible with Elan, Synaptics, Goodix, Validity, and other fingerprint sensors.*