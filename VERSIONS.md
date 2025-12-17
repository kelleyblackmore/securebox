# SecureBox Tool Versions

This file documents all pinned tool versions for reproducibility and security auditing.

Last updated: 2025-12-17

## Security Scanning Tools

| Tool | Version | Release Date | Verification Method |
|------|---------|--------------|---------------------|
| gitleaks | 8.21.2 | 2024-12-10 | SHA256 checksum |
| trivy | 0.58.1 | 2024-12-16 | SHA256 checksum |
| syft | 1.18.1 | 2024-12-12 | SHA256 checksum |
| semgrep | 1.99.0 | 2024-12-16 | PyPI package hash |
| osv-scanner | 1.9.1 | 2024-11-21 | SHA256 checksum |
| checkov | 3.2.322 | 2024-12-16 | PyPI package hash |
| gosec | v2.21.4 | 2024-11-13 | Go module checksum |
| govulncheck | v1.1.3 | 2024-06-11 | Go module checksum |

## Runtime Dependencies

| Dependency | Version | Source |
|------------|---------|--------|
| Go | 1.23.4 | SHA256 verified from go.dev |
| Python | 3.12 | Ubuntu 24.04 package |
| OpenJDK | 17 | Ubuntu 24.04 package |

## Update Process

To update versions:

1. Check for new releases on respective GitHub repositories
2. Update version ARGs in Dockerfile
3. Update checksums if provided by upstream
4. Test the build: `docker build -t securebox:test .`
5. Test the scan: `docker run --rm -v "$PWD:/work" securebox:test`
6. Update this manifest file
7. Commit changes

## Checksum Verification

All downloads are verified using:
- SHA256 checksums from official release assets
- Package hashes from PyPI for Python packages
- Go module checksums for Go tools

No `curl | sh` installation methods are used.
