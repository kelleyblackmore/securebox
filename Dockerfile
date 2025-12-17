FROM ubuntu:24.04

# Pin tool versions for reproducibility
ARG GITLEAKS_VERSION=8.21.2
ARG TRIVY_VERSION=0.58.1
ARG SYFT_VERSION=1.18.1
ARG SEMGREP_VERSION=1.99.0
ARG OSV_SCANNER_VERSION=1.9.0
ARG CHECKOV_VERSION=3.2.322
ARG GO_VERSION=1.23.4
ARG GOSEC_VERSION=v2.21.4
ARG GOVULNCHECK_VERSION=v1.1.3

# Install base dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    python3 \
    python3-pip \
    jq \
    unzip \
    openjdk-17-jre-headless \
  && rm -rf /var/lib/apt/lists/*

# gitleaks - verify checksum
RUN set -eux; \
    curl -sSfL "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz" \
      -o gitleaks.tar.gz; \
    curl -sSfL "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_checksums.txt" \
      -o checksums.txt; \
    grep "linux_x64.tar.gz" checksums.txt | sed "s/gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz/gitleaks.tar.gz/" > expected_checksum.txt; \
    sha256sum -c expected_checksum.txt; \
    tar -xzf gitleaks.tar.gz -C /usr/local/bin gitleaks; \
    chmod +x /usr/local/bin/gitleaks; \
    rm -f gitleaks.tar.gz checksums.txt expected_checksum.txt

# trivy - verify checksum
RUN set -eux; \
    curl -sSfL "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz" \
      -o trivy.tar.gz; \
    curl -sSfL "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_checksums.txt" \
      -o checksums.txt; \
    grep "Linux-64bit.tar.gz" checksums.txt | sed "s/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz/trivy.tar.gz/" > expected_checksum.txt; \
    sha256sum -c expected_checksum.txt; \
    tar -xzf trivy.tar.gz -C /usr/local/bin trivy; \
    chmod +x /usr/local/bin/trivy; \
    rm -f trivy.tar.gz checksums.txt expected_checksum.txt

# syft - verify checksum
RUN set -eux; \
    curl -sSfL "https://github.com/anchore/syft/releases/download/v${SYFT_VERSION}/syft_${SYFT_VERSION}_linux_amd64.tar.gz" \
      -o syft.tar.gz; \
    curl -sSfL "https://github.com/anchore/syft/releases/download/v${SYFT_VERSION}/syft_${SYFT_VERSION}_checksums.txt" \
      -o checksums.txt; \
    grep "linux_amd64.tar.gz" checksums.txt | sed "s/syft_${SYFT_VERSION}_linux_amd64.tar.gz/syft.tar.gz/" > expected_checksum.txt; \
    sha256sum -c expected_checksum.txt; \
    tar -xzf syft.tar.gz -C /usr/local/bin syft; \
    chmod +x /usr/local/bin/syft; \
    rm -f syft.tar.gz checksums.txt expected_checksum.txt

# semgrep - pinned version
RUN pip3 install --no-cache-dir --break-system-packages semgrep==${SEMGREP_VERSION}

# osv-scanner - download binary (no official checksums provided)
RUN set -eux; \
    curl -sSfL "https://github.com/google/osv-scanner/releases/download/v${OSV_SCANNER_VERSION}/osv-scanner_linux_amd64" \
      -o /usr/local/bin/osv-scanner; \
    chmod +x /usr/local/bin/osv-scanner

# checkov - pinned version
RUN pip3 install --no-cache-dir --break-system-packages checkov==${CHECKOV_VERSION}

# go - verify checksum
RUN set -eux; \
    curl -sSfL "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" \
      -o go.tar.gz; \
    echo "6924efde5de86fe277676e929dc9917d466efa02fb934197bc2eba35d5680971  go.tar.gz" | sha256sum -c -; \
    tar -xzf go.tar.gz -C /usr/local; \
    rm -f go.tar.gz

ENV PATH="/usr/local/go/bin:/root/go/bin:${PATH}"

# Go security tools - pinned versions
RUN go install github.com/securego/gosec/v2/cmd/gosec@${GOSEC_VERSION} \
 && go install golang.org/x/vuln/cmd/govulncheck@${GOVULNCHECK_VERSION}

# Create non-root user for runtime
RUN useradd -m -u 10001 -s /bin/bash securebox \
 && mkdir -p /work \
 && chown securebox:securebox /work

# Copy scripts and set ownership
COPY --chown=securebox:securebox scripts/ /usr/local/bin/

# Switch to non-root user
USER securebox
WORKDIR /work

ENTRYPOINT ["security-scan"]
