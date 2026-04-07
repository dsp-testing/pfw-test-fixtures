#!/usr/bin/env bash
#
# Prepares v2.0.0 of test fixture packages for manual (no-provenance) publish.
#
# After running this script:
#   cd packages/pfw-test-install-script && npm publish
#   cd ../pfw-test-attestation && npm publish
#   cd ../pfw-test-combined && npm publish
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

echo "=== Preparing v2.0.0 packages ==="

# pfw-test-install-script: bump to 2.0.0 and ADD postinstall
cd packages/pfw-test-install-script
npm version 2.0.0 --no-git-tag-version
# Add postinstall script
node -e "
const pkg = require('./package.json');
pkg.scripts.postinstall = 'echo pfw-test-postinstall';
require('fs').writeFileSync('package.json', JSON.stringify(pkg, null, 2) + '\n');
"
echo "✅ pfw-test-install-script@2.0.0 — added postinstall script"

# pfw-test-attestation: bump to 2.0.0 (no other changes — just no provenance)
cd ../pfw-test-attestation
npm version 2.0.0 --no-git-tag-version
echo "✅ pfw-test-attestation@2.0.0 — no provenance (publish locally)"

# pfw-test-combined: bump to 2.0.0 AND add postinstall
cd ../pfw-test-combined
npm version 2.0.0 --no-git-tag-version
node -e "
const pkg = require('./package.json');
pkg.scripts.postinstall = 'echo pfw-test-postinstall';
require('fs').writeFileSync('package.json', JSON.stringify(pkg, null, 2) + '\n');
"
echo "✅ pfw-test-combined@2.0.0 — added postinstall, no provenance"

echo ""
echo "Now publish each package locally (without --provenance):"
echo "  cd packages/pfw-test-install-script && npm publish"
echo "  cd ../pfw-test-attestation && npm publish"
echo "  cd ../pfw-test-combined && npm publish"
