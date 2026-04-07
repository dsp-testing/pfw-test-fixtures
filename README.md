# pfw-test-fixtures

Test fixture packages for [package-firewall](https://github.com/github/package-firewall) end-to-end testing.

## Packages

| Package | Purpose | v1.0.0 (local) | v2.0.0 (GHA + trusted publishing) | v3.0.0 (local) |
|---------|---------|----------------|-------------------------------------|----------------|
| `pfw-test-install-script` | Install script detection | No scripts, no provenance | No scripts, with provenance | Adds `postinstall`, no provenance |
| `pfw-test-attestation` | Attestation downgrade detection | No provenance | With provenance | No provenance |
| `pfw-test-combined` | Combined signal detection | No scripts, no provenance | No scripts, with provenance | Adds `postinstall`, no provenance |

v1.0.0 establishes that the package existed without provenance (baseline).
v2.0.0 upgrades to trusted publishing with provenance.
v3.0.0 simulates compromise — loses provenance and (for some packages) adds install scripts.

The proxy should block v3.0.0 but NOT v1.0.0, even though both lack provenance.

## Setup

### Prerequisites
Configure a trusted publisher on npmjs.com for each package:
- **Organization/user**: `dsp-testing`
- **Repository**: `pfw-test-fixtures`
- **Workflow**: `publish.yml`

### Step 1: Publish v1.0.0 locally (no provenance)

```bash
npm login
for pkg in pfw-test-install-script pfw-test-attestation pfw-test-combined; do
  (cd packages/$pkg && npm publish --access public)
done
```

### Step 2: Publish v2.0.0 with provenance (via GitHub Actions)

```bash
git tag v2.0.0
git push origin v2.0.0
```

The workflow publishes all three packages at v2.0.0 with `--provenance`.

### Step 3: Publish v3.0.0 locally (no provenance, simulates compromise)

```bash
./prepare-v3.sh
for pkg in pfw-test-install-script pfw-test-attestation pfw-test-combined; do
  (cd packages/$pkg && npm publish)
done
```

## Testing with package-firewall

With both Vexi flags enabled, the proxy should:

```bash
PROXY=http://localhost:18080/npm/enterprises/test-enterprise

# v3.0.0 should be filtered (attestation downgrade from v2.0.0)
curl -H "Authorization: Bearer $TOKEN" "$PROXY/pfw-test-attestation" | jq '.versions | keys'
# Expected: ["1.0.0", "2.0.0"] — v3.0.0 filtered out

# v1.0.0 should NOT be filtered (no prior version had provenance)
# v3.0.0 should be filtered (install script + attestation downgrade)
curl -H "Authorization: Bearer $TOKEN" "$PROXY/pfw-test-combined" | jq '.versions | keys'
# Expected: ["1.0.0", "2.0.0"] — v3.0.0 filtered out

# Tarball block
curl -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $TOKEN" \
  "$PROXY/pfw-test-attestation/-/pfw-test-attestation-3.0.0.tgz"
# Expected: 403
```
