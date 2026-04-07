#!/usr/bin/env bash
#
# Cleans up and republishes all test fixture packages from scratch.
#
# Run this after npm login to fix the package state.
# It unpublishes all existing versions, then publishes v1.0.0 cleanly.
#
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

echo "=== Step 1: Unpublish all existing versions ==="
for pkg in pfw-fixture-install-script pfw-fixture-attestation pfw-fixture-combined; do
  echo "Unpublishing $pkg..."
  npm unpublish "$pkg" --force 2>/dev/null || echo "  (nothing to unpublish)"
done

echo ""
echo "=== Step 2: Reset packages to v1.0.0 (clean, no install scripts) ==="
for pkg in pfw-fixture-install-script pfw-fixture-attestation pfw-fixture-combined; do
  node -e "
const fs = require('fs');
const pkg = JSON.parse(fs.readFileSync('packages/$pkg/package.json', 'utf8'));
pkg.version = '1.0.0';
delete pkg.scripts.postinstall;
delete pkg.scripts.preinstall;
delete pkg.scripts.install;
fs.writeFileSync('packages/$pkg/package.json', JSON.stringify(pkg, null, 2) + '\n');
console.log('  $pkg: v' + pkg.version + ', scripts:', JSON.stringify(pkg.scripts));
"
done

echo ""
echo "=== Step 3: Publish v1.0.0 locally (no provenance) ==="
for pkg in pfw-fixture-install-script pfw-fixture-attestation pfw-fixture-combined; do
  echo "Publishing $pkg@1.0.0..."
  (cd "packages/$pkg" && npm publish --access public)
done

echo ""
echo "=== Done! ==="
echo "Now:"
echo "  1. Configure trusted publishers on npmjs.com for each package"
echo "     (dsp-testing/pfw-fixture-fixtures, workflow: publish.yml)"
echo "  2. Run: ./prepare-v2.sh"
echo "  3. Commit, tag v2.0.0, and push to trigger GHA publish with provenance"
echo "  4. After GHA succeeds, run: ./prepare-v3.sh"
echo "  5. Publish v3.0.0 locally for each package"
