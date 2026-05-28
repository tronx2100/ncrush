#!/usr/bin/env bash
set -e

INSTALL_DIR="${1:-$HOME/.local/bin}"

VERSION=$(git describe --long 2>/dev/null || echo "dev")
LDFLAGS="-X github.com/tronx2100/ncrush/internal/version.Version=${VERSION}"

echo "Building ncrush ${VERSION}..."
CGO_ENABLED=0 GOEXPERIMENT=greenteagc go build -ldflags="${LDFLAGS}" -o ncrush .

mkdir -p "${INSTALL_DIR}"
mv ncrush "${INSTALL_DIR}/ncrush"
echo "Installed to ${INSTALL_DIR}/ncrush"
