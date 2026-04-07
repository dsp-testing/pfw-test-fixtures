#!/usr/bin/env bash
#
# Prepares v3.0.0 of test fixture packages (simulated compromise).
#
# pfw-fixture-install-script: published via GHA WITH provenance, adds postinstall
#   → tests install script introduction independently of attestation downgrade
# pfw-fixture-attestation: published locally WITHOUT provenance
#   → tests attestation downgrade only
# pfw-fixture-combined: published locally WITHOUT provenance, adds postinstall
#   → tests both signals together
#
# Usage:
#   ./prepare-v3.sh
#   # Publish attestation + combined locally:
#   cd packages/pfw-fixture-attestation && npm publish
#   cd ../pfw-fixture-combined && npm publish
#   # Publish install-script via GHA:
#   git add -A && git commit -m "Bump to v3.0.0"
#   git tag v3.0.0-scripts && git push origin main v3.0.0-scripts
#
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

echo "=== Preparing v3.0.0 packages (simulated compromise) ==="

# pfw-fixture-install-script: bump and ADD postinstall (will be published via GHA)
cd packages/pfw-fixture-install-script
npm version 3.0.0 --no-git-tag-version
node -e "
const fs = require('fs');
const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
pkg.scripts.postinstall = 'echo pfw-fixture-postinstall';
fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2) + '\n');
"
echo "✅ pfw-fixture-install-script@3.0.0 — added postinstall (publish via GHA for provenance)"
cd ../..

# pfw-fixture-attestation: bump only (no provenance when published locally)
cd packages/pfw-fixture-attestation
npm version 3.0.0 --no-git-tag-version
echo "✅ pfw-fixture-attestation@3.0.0 — publish locally (no provenance)"
cd ../..

# pfw-fixture-combined: bump AND add postinstall (publish locally, no provenance)
cd packages/pfw-fixture-combined
npm version 3.0.0 --no-git-tag-version
node -e "
const fs = require('fs');
const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
pkg.scripts.postinstall = 'echo pfw-fixture-postinstall';
fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2) + '\n');
"
echo "✅ pfw-fixture-combined@3.0.0 — added postinstall, publish locally (no provenance)"
cd ../..

echo ""
echo "Now:"
echo "  1. Publish attestation + combined locally:"
echo "     cd packages/pfw-fixture-attestation && npm publish"
echo "     cd ../pfw-fixture-combined && npm publish"
echo "  2. Publish install-script via GHA (with provenance):"
echo "     git add -A && git commit -m 'Bump to v3.0.0'"
echo "     git tag v3.0.0-scripts && git push origin main v3.0.0-scripts"
