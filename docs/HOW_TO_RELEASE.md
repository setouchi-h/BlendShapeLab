# BlendShapeLab Release Playbook (GitHub Releases + Notarized DMG)

This document describes the standard local release flow for shipping a **notarized** `.dmg` via **GitHub Releases**.

---

## What you will ship

- `BlendShapeLab.dmg` (signed + notarized + stapled)
- Optional: `BlendShapeLab.dmg.sha256` (checksum for integrity)

---

## One-time prerequisites (do this once)

### 1) Developer ID certificate installed in Keychain

Verify you have **Developer ID Application** available:

```bash
security find-identity -v -p codesigning
```

You should see something like:

- `Developer ID Application: Kazuki Hashimoto (KRQX69QMRF)`

### 2) notarytool credential profile exists (recommended)

You should have a notarytool Keychain profile such as:

- `notary-blendshapelab`

If you ever lose your Keychain profile or move machines, you'll need your App Store Connect API Key (`AuthKey_*.p8`) to recreate it.

### 3) Keep your .p8 safe

- The `.p8` file is a private key.

---

## Per-release checklist (run for every new version)

### Step 0 — Set the version

Update these in Xcode (Target → General):

- **Version** (`CFBundleShortVersionString`), e.g. `1.2.3`
- **Build** (`CFBundleVersion`), e.g. `123` or `20251217.1`

Also decide:

- Git tag: `v1.2.3`

---

### Step 1 — Define variables

Run from the repository root (where `BlendShapeLab.xcodeproj` exists):

```bash
SIGN_ID="Developer ID Application: Kazuki Hashimoto (KRQX69QMRF)"
PROFILE="notary-blendshapelab"

ROOT="$PWD"
BUILD="$ROOT/build"
DIST="$ROOT/dist"
ARCHIVE="$BUILD/BlendShapeLab.xcarchive"
APP="$ARCHIVE/Products/Applications/BlendShapeLab.app"

STAGE="$DIST/stage"
DMG="$DIST/BlendShapeLab.dmg"
```

---

### Step 2 — Clean + Archive (Release build, sign later)

```bash
rm -rf "$BUILD" "$DIST"
mkdir -p "$BUILD" "$DIST"

xcodebuild archive \
  -project BlendShapeLab.xcodeproj \
  -scheme BlendShapeLab \
  -configuration Release \
  -destination 'generic/platform=macOS' \
  -archivePath "$ARCHIVE" \
  CODE_SIGNING_ALLOWED=NO
```

Confirm the app exists:

```bash
ls -la "$APP"
```

---

### Step 3 — Sign the app (Hardened Runtime + timestamp)

```bash
codesign --force --options runtime --timestamp \
  --sign "$SIGN_ID" \
  "$APP"
```

---

### Step 4 — Verify app signature

```bash
codesign --verify --deep --strict --verbose=2 "$APP"
```

Notes:

- At this point, `spctl --assess --type execute` may still show **Unnotarized Developer ID** — that is expected before notarization.

---

### Step 5 — Create the DMG (drag & drop style)

```bash
rm -rf "$STAGE"
mkdir -p "$STAGE"

cp -R "$APP" "$STAGE/"
ln -sf /Applications "$STAGE/Applications"

hdiutil create \
  -volname "BlendShapeLab" \
  -srcfolder "$STAGE" \
  -ov \
  -format UDZO \
  "$DMG"
```

---

### Step 6 — Sign the DMG

```bash
codesign --force --timestamp --sign "$SIGN_ID" "$DMG"
codesign --verify --verbose=2 "$DMG"
```

---

### Step 7 — Notarize the DMG

```bash
xcrun notarytool submit "$DMG" --wait --keychain-profile "$PROFILE"
```

Expected result:

- `status: Accepted`

If you get `Invalid` or errors, fetch the log using the Submission ID:

```bash
xcrun notarytool log <SUBMISSION_ID> --keychain-profile "$PROFILE"
```

---

### Step 8 — Staple the notarization ticket

```bash
xcrun stapler staple "$DMG"
```

---

### Step 9 — Validate stapling

```bash
xcrun stapler validate "$DMG"
```

**Important note about spctl:**

- A locally-built DMG often lacks download "context" (no quarantine attribute), so:
  - `spctl --assess --type open` may show **Insufficient Context**
- If `stapler validate` passes, your notarization + stapling is generally good.

Optional: simulate download context and check spctl:

```bash
xattr -w com.apple.quarantine "0083;$(date +%s);Safari;$(uuidgen)" "$DMG"
spctl --assess --type open --verbose=4 "$DMG"
xattr -d com.apple.quarantine "$DMG" 2>/dev/null || true
```

---

### Step 10 — Generate checksum (optional, recommended)

```bash
shasum -a 256 "$DMG" > "$DMG.sha256"
```

---

### Step 11 — Publish on GitHub Releases

**Option A: GitHub Web UI**

1. Releases → "Draft a new release"
2. Tag: `v1.2.3`
3. Attach:
   - `dist/BlendShapeLab.dmg`
   - `dist/BlendShapeLab.dmg.sha256` (if created)

**Option B: GitHub CLI (gh)**

```bash
gh release create v1.2.3 \
  "$DMG" \
  "$DMG.sha256" \
  --title "v1.2.3" \
  --notes "Release notes here"
```

---

## Quick troubleshooting

### A) spctl says "Unnotarized Developer ID"

- Expected before notarization.
- Not a problem if `notarytool` status: `Accepted` and `stapler validate` passes.

### B) spctl says "Insufficient Context"

- Common for locally-built DMGs (no quarantine).
- Prefer `stapler validate`, or simulate quarantine as shown above.

### C) codesign --verify fails

- Often caused by nested code (Frameworks/PlugIns/XPC) not being correctly signed.
- Capture the exact error output and re-sign the failing nested item(s), then re-sign the app and redo the DMG steps.
