#!/usr/bin/env bash
#
# Bumps all packages to v2.0.0 for publishing via GHA with trusted publishing.
# Run this after publishing v1.0.0 locally, then commit, tag, and push.
#
# Usage:
#   ./prepare-v2.sh
#   git add -A && git commit -m "Bump to v2.0.0"
#   git tag v2.0.0 && git push origin main v2.0.0
#
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

for pkg in pfw-test-install-script pfw-test-attestation pfw-test-combined; do
  cd "packages/$pkg"
  npm version 2.0.0 --no-git-tag-version
  echo "✅ $pkg bumped to 2.0.0"
  cd ../..
done

echo ""
echo "Now commit, tag, and push to trigger the GHA publish workflow:"
echo "  git add -A && git commit -m 'Bump to v2.0.0'"
echo "  git tag v2.0.0 && git push origin main v2.0.0"
