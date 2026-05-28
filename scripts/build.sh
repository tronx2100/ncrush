#!/usr/bin/env bash
set -e

VERSION=$(git describe --long 2>/dev/null || echo "dev")
LDFLAGS="-X github.com/tronx2100/ncrush/internal/version.Version=${VERSION}"

echo "Building ncrush ${VERSION}..."
CGO_ENABLED=0 GOEXPERIMENT=greenteagc go build -ldflags="${LDFLAGS}" -o ncrush .
echo "Done: ./ncrush"
