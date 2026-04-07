# pfw-test-fixtures

Test fixture packages for [package-firewall](https://github.com/github/package-firewall) end-to-end testing.

## Packages

| Package | Purpose | v1.0.0 | v2.0.0 |
|---------|---------|--------|--------|
| `pfw-test-install-script` | Install script introduction detection | No install scripts | Adds `postinstall` |
| `pfw-test-attestation` | Attestation downgrade detection | Published with provenance (GHA) | Published without provenance (local) |
| `pfw-test-combined` | Combined signal detection | With provenance, no install scripts | Without provenance, adds `postinstall` |

## Publishing

### Step 1: Publish v1.0.0 with provenance (via GitHub Actions)

Push a tag to trigger the publish workflow:

```bash
git tag v1.0.0
git push origin v1.0.0
```

The workflow publishes all three packages at v1.0.0 with `--provenance` from GitHub Actions.

### Step 2: Publish v2.0.0 without provenance (manually)

After v1.0.0 is published, bump each package to v2.0.0 (already prepared in the
`v2` branch or manually), then publish from your local machine:

```bash
# pfw-test-install-script: v2.0.0 adds postinstall
cd packages/pfw-test-install-script
npm version 2.0.0
npm publish

# pfw-test-attestation: v2.0.0 has no provenance
cd ../pfw-test-attestation
npm version 2.0.0
npm publish

# pfw-test-combined: v2.0.0 has no provenance AND adds postinstall
cd ../pfw-test-combined
npm version 2.0.0
npm publish
```

Publishing locally (without `--provenance`) ensures these versions have no
SLSA provenance attestation.

## Verifying

After publishing, verify the test fixtures are correct:

```bash
# Should have attestations
curl -s https://registry.npmjs.org/-/npm/v1/attestations/pfw-test-attestation@1.0.0 | jq .

# Should return 404 (no attestations)
curl -s https://registry.npmjs.org/-/npm/v1/attestations/pfw-test-attestation@2.0.0

# Should have no install scripts
curl -s https://registry.npmjs.org/pfw-test-install-script/1.0.0 | jq .scripts

# Should have postinstall
curl -s https://registry.npmjs.org/pfw-test-install-script/2.0.0 | jq .scripts
```

## Testing with package-firewall

With both Vexi flags enabled, the proxy should:

```bash
PROXY=http://localhost:18080/npm/enterprises/test-enterprise

# Attestation downgrade: v2.0.0 should be filtered from packument
curl -H "Authorization: Bearer $TOKEN" "$PROXY/pfw-test-attestation" | jq '.versions | keys'
# Expected: ["1.0.0"] — v2.0.0 filtered out

# Install script introduction: v2.0.0 should be filtered
curl -H "Authorization: Bearer $TOKEN" "$PROXY/pfw-test-install-script" | jq '.versions | keys'
# Expected: ["1.0.0"] — v2.0.0 filtered out

# Combined: v2.0.0 should be filtered (both signals)
curl -H "Authorization: Bearer $TOKEN" "$PROXY/pfw-test-combined" | jq '.versions | keys'
# Expected: ["1.0.0"] — v2.0.0 filtered out

# Tarball block: direct download should return 403
curl -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $TOKEN" \
  "$PROXY/pfw-test-attestation/-/pfw-test-attestation-2.0.0.tgz"
# Expected: 403
```
