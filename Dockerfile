FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl git python3 python3-pip jq unzip openjdk-17-jre-headless \
  && rm -rf /var/lib/apt/lists/*

# gitleaks
RUN curl -sSfL https://raw.githubusercontent.com/gitleaks/gitleaks/master/install.sh | bash

# trivy
RUN curl -sSfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

# syft
RUN curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin

# semgrep
RUN pip3 install --no-cache-dir --break-system-packages semgrep

# osv-scanner
RUN curl -sSfL https://github.com/google/osv-scanner/releases/latest/download/osv-scanner_linux_amd64 \
  -o /usr/local/bin/osv-scanner && chmod +x /usr/local/bin/osv-scanner

# checkov
RUN pip3 install --no-cache-dir --break-system-packages checkov

# go tools (optional: only needed if scanning Go repos)
RUN curl -sSfL https://go.dev/dl/go1.22.0.linux-amd64.tar.gz | tar -xz -C /usr/local
ENV PATH="/usr/local/go/bin:${PATH}"
RUN go install github.com/securego/gosec/v2/cmd/gosec@latest \
 && go install golang.org/x/vuln/cmd/govulncheck@latest

WORKDIR /work
COPY scripts/ /usr/local/bin/
ENTRYPOINT ["security-scan"]
