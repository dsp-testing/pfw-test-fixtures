#!/usr/bin/env bash
#
# Prepares v3.0.0 of test fixture packages for manual (no-provenance) publish.
# This simulates a supply chain compromise: provenance is lost, and install
# scripts are added to some packages.
#
# Usage:
#   ./prepare-v3.sh
#   cd packages/pfw-test-install-script && npm publish
#   cd ../pfw-test-attestation && npm publish
#   cd ../pfw-test-combined && npm publish
#
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

echo "=== Preparing v3.0.0 packages (simulated compromise) ==="

# pfw-test-install-script: bump and ADD postinstall
cd packages/pfw-test-install-script
npm version 3.0.0 --no-git-tag-version
node -e "
const fs = require('fs');
const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
pkg.scripts.postinstall = 'echo pfw-test-postinstall';
fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2) + '\n');
"
echo "✅ pfw-test-install-script@3.0.0 — added postinstall script"
cd ../..

# pfw-test-attestation: bump only (no provenance when published locally)
cd packages/pfw-test-attestation
npm version 3.0.0 --no-git-tag-version
echo "✅ pfw-test-attestation@3.0.0 — no provenance (publish locally)"
cd ../..

# pfw-test-combined: bump AND add postinstall
cd packages/pfw-test-combined
npm version 3.0.0 --no-git-tag-version
node -e "
const fs = require('fs');
const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
pkg.scripts.postinstall = 'echo pfw-test-postinstall';
fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2) + '\n');
"
echo "✅ pfw-test-combined@3.0.0 — added postinstall, no provenance"
cd ../..

echo ""
echo "Now publish each package locally (without --provenance):"
echo "  cd packages/pfw-test-install-script && npm publish"
echo "  cd ../pfw-test-attestation && npm publish"
echo "  cd ../pfw-test-combined && npm publish"
