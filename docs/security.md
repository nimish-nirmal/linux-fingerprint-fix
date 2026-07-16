# 🔒 Security Considerations — Linux Fingerprint Fix

---

## Understanding the Risks

| Risk | Mitigation |
|------|------------|
| Fingerprints can be lifted from surfaces | Treat fingerprint as a **username**, not a password |
| Sensor spoofing possible | Basic liveness detection on most modern sensors |
| Templates stored on disk | Protect with Full Disk Encryption (LUKS) |
| PAM fallback to password | This is by design — defense in depth |

### ⚠️ Critical: Fingerprint Templates Are Unencrypted by Default

Fingerprint templates are stored in `/var/lib/fprint/`. **Without Full Disk Encryption (LUKS), these files are readable by anyone with physical disk access.**

```
/var/lib/fprint/
└── $USER
    └── right-index-finger.dat   # ← Unencrypted biometric data
```

**Always enable LUKS during OS installation** to protect stored fingerprint templates at rest.

---

## Best Practices

1. **Keep a strong password** — at least 12 characters, mix of types
2. **Enable Full Disk Encryption (LUKS)** — protects stored fingerprint templates from physical access
3. **Use fingerprint for convenience, not sensitive ops** — use password for destructive commands (`sudo rm -rf`, `sudo fdisk`, etc.)
4. **Clean your sensor regularly** — 70% isopropyl alcohol, weekly
5. **Don't rely solely on fingerprint** — always have password fallback
6. **Use `[success=2 default=ignore]` PAM flag** — avoids `sufficient` flag which can bypass password auth entirely

---

## PAM Configuration Security

| PAM Flag | Security Level | Risk |
|----------|---------------|------|
| `[success=2 default=ignore]` | ✅ **Recommended** | Fingerprint + password fallback |
| `sufficient` | ⚠️ **Less secure** | Fingerprint alone = access. Spoofed sensor = full bypass |
| `required` | ❌ **Lockout risk** | Sensor failure = no login possible |

---

## Legal Note

Fingerprint data may be considered **personally identifiable information (PII)** under multiple regulations:

| Jurisdiction | Regulation | Requirements |
|-------------|-----------|-------------|
| **EU/EEA** | GDPR | Explicit consent required for processing biometric data |
| **California, USA** | CCPA/CPRA | Right to know what biometric data is collected |
| **Illinois, USA** | BIPA | **Written consent required** before collecting biometric data |
| **Brazil** | LGPD | Similar to GDPR — biometric data is sensitive personal data |
| **India** | DPDP Act 2023 | Consent required for processing biometric data |

Be aware of your local regulations regarding the storage and processing of biometric data.

---

## Secure Erasure

If you sell or give away your laptop, securely erase fingerprint data:

```bash
sudo fprintd-delete --all-users
sudo rm -rf /var/lib/fprint/