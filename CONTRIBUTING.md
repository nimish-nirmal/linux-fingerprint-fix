# 🤝 Contributing — Linux Fingerprint Fix

Thank you for your interest in contributing! This project is community-maintained and welcomes contributions.

---

## Ways to Contribute

- **Documentation:** Fix typos, improve clarity, add brand-specific notes
- **Scripts:** Improve automation, add distribution support (Fedora, Arch)
- **Hardware reports:** Add new working sensor IDs to SUPPORTED_DEVICES.md
- **Bug reports:** Include `lsusb` output, distribution, kernel version, and error logs

## Pull Request Process

1. Fork the repository
2. Create a branch: `git checkout -b fix/description`
3. Make changes with clear commits
4. Test your changes
5. Submit a PR with a clear description

## Code Style

- Shell scripts: `set -euo pipefail`, use functions, descriptive variables
- Markdown: ATX headers, fenced code blocks with language identifiers, relative links

## Adding a New Sensor

1. Verify it works: `fprintd-list`
2. Get ID: `lsusb | grep -i "04f3\|138a\|27c6\|06cb"`
3. Open a PR adding it to SUPPORTED_DEVICES.md

---

*Thank you for helping make this project better!*