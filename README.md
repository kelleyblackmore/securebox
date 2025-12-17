# SecureBox 🔒

A comprehensive security scanning toolkit packaged as a Docker container and reusable GitHub Action.

## Features

- **Secrets Detection**: GitLeaks for credential scanning
- **SAST**: Semgrep for static code analysis
- **Dependency Scanning**: OSV Scanner and Trivy for vulnerability detection
- **SBOM Generation**: Syft for software bill of materials
- **IaC Security**: Checkov for infrastructure-as-code analysis
- **Go Security**: Gosec and govulncheck for Go-specific analysis
- **Reusable GitHub Action**: Easy integration into any repository
- **JSON Reports**: Standardized output for CI/CD pipelines

## Usage

### As a GitHub Action

Add this to your workflow file (e.g., `.github/workflows/security.yml`):

```yaml
name: Security Scan

on: [push, pull_request]

permissions:
  contents: read

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      
      - name: Run SecureBox
        uses: kelleyblackmore/securebox@main
        with:
          output-dir: security-reports
      
      - name: Upload reports
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: security-reports
          path: security-reports/
```

The action uses a pre-built Docker image from GitHub Container Registry for fast execution.

### As a Docker Container

```bash
# Build the image
docker build -t securebox:0.0.1 .

# Run scan on current directory
docker run --rm -v "$PWD:/work" securebox:0.0.1

# Custom output directory
docker run --rm -v "$PWD:/work" -e OUT_DIR=my-reports securebox:0.0.1
```

### Local Script Usage

```bash
# Make script executable
chmod +x scripts/security-scan

# Run directly (requires all tools installed)
./scripts/security-scan
```

## Output Reports

All scans generate JSON reports in the output directory (default: `reports/`):

- `meta.json` - Scan metadata and timestamp
- `gitleaks.json` - Detected secrets and credentials
- `semgrep.json` - SAST findings
- `gosec.json` - Go security issues (if Go detected)
- `govulncheck.json` - Go vulnerability analysis (if Go detected)
- `osv.json` - Dependency vulnerabilities (if lockfile found)
- `checkov.json` - IaC security issues (if IaC files detected)

## Requirements

- Docker (for containerized usage)
- Git repository (recommended for full scanning)

## Tools Included

| Tool | Purpose | Version |
|------|---------|---------|
| [GitLeaks](https://github.com/gitleaks/gitleaks) | Secret detection | Latest |
| [Trivy](https://github.com/aquasecurity/trivy) | Vulnerability scanner | Latest |
| [Syft](https://github.com/anchore/syft) | SBOM generation | Latest |
| [Semgrep](https://semgrep.dev/) | SAST analysis | Latest |
| [OSV Scanner](https://github.com/google/osv-scanner) | Dependency scanning | Latest |
| [Checkov](https://www.checkov.io/) | IaC security | Latest |
| [Gosec](https://github.com/securego/gosec) | Go security | Latest |
| [Govulncheck](https://pkg.go.dev/golang.org/x/vuln/cmd/govulncheck) | Go vulnerabilities | Latest |

## Example Workflow

See [.github/workflows/example-usage.yml](.github/workflows/example-usage.yml) for a complete example that includes:
- Running the scan on push and pull requests
- Uploading reports as artifacts
- Failing the build if secrets are detected

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT