#!/usr/bin/env bash
#
# Prepares v3.0.0 of test fixture packages for manual (no-provenance) publish.
# This simulates a supply chain compromise: provenance is lost, and install
# scripts are added to some packages.
#
# Usage:
#   ./prepare-v3.sh
#   cd packages/pfw-fixture-install-script && npm publish
#   cd ../pfw-fixture-attestation && npm publish
#   cd ../pfw-fixture-combined && npm publish
#
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

echo "=== Preparing v3.0.0 packages (simulated compromise) ==="

# pfw-fixture-install-script: bump and ADD postinstall
cd packages/pfw-fixture-install-script
npm version 3.0.0 --no-git-tag-version
node -e "
const fs = require('fs');
const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
pkg.scripts.postinstall = 'echo pfw-fixture-postinstall';
fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2) + '\n');
"
echo "✅ pfw-fixture-install-script@3.0.0 — added postinstall script"
cd ../..

# pfw-fixture-attestation: bump only (no provenance when published locally)
cd packages/pfw-fixture-attestation
npm version 3.0.0 --no-git-tag-version
echo "✅ pfw-fixture-attestation@3.0.0 — no provenance (publish locally)"
cd ../..

# pfw-fixture-combined: bump AND add postinstall
cd packages/pfw-fixture-combined
npm version 3.0.0 --no-git-tag-version
node -e "
const fs = require('fs');
const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
pkg.scripts.postinstall = 'echo pfw-fixture-postinstall';
fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2) + '\n');
"
echo "✅ pfw-fixture-combined@3.0.0 — added postinstall, no provenance"
cd ../..

echo ""
echo "Now publish each package locally (without --provenance):"
echo "  cd packages/pfw-fixture-install-script && npm publish"
echo "  cd ../pfw-fixture-attestation && npm publish"
echo "  cd ../pfw-fixture-combined && npm publish"
