#!/bin/bash
# ============================================================
#  Package the extension into a signed .zxp (self-signed cert) on macOS.
#  Teammates install the .zxp with ZXP Installer / Anastasiy's Extension
#  Manager by dragging it in — no PlayerDebugMode needed.
#  Requires: Adobe ZXPSignCmd (this script will tell you where to get it).
#
#  The produced .zxp is cross-platform: the same file installs on Windows too.
# ============================================================
set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"
NAME="com.cocos.psdnamer"
OUT="$ROOT/cocos-psd-namer.zxp"
CERT="$ROOT/cert.p12"
PW="cocospsd"
STAGE="$ROOT/_zxp_build/$NAME"

# --- 1. Locate ZXPSignCmd (PATH, beside this script, or tools/) ---
ZXP=""
if command -v ZXPSignCmd >/dev/null 2>&1; then
  ZXP="$(command -v ZXPSignCmd)"
elif [ -x "$ROOT/ZXPSignCmd" ]; then
  ZXP="$ROOT/ZXPSignCmd"
elif [ -x "$ROOT/tools/ZXPSignCmd" ]; then
  ZXP="$ROOT/tools/ZXPSignCmd"
fi

if [ -z "$ZXP" ]; then
  echo
  echo "  ZXPSignCmd not found. Download the macOS build and place it"
  echo "  next to this script, in a tools/ subfolder, or on your PATH:"
  echo "    https://github.com/Adobe-CEP/CEP-Resources  (ZXPSignCMD/.../osx64/ZXPSignCmd)"
  echo "  Then: chmod +x ZXPSignCmd"
  echo
  read -n 1 -s -r -p "Press any key to close..."
  echo
  exit 1
fi
echo "  Using: $ZXP"

# --- 2. Generate a self-signed cert if missing ---
if [ ! -f "$CERT" ]; then
  echo "[1/3] Generating self-signed cert cert.p12 ..."
  "$ZXP" -selfSignedCert CN Shanghai Cocos "Cocos PSD Namer" "$PW" "$CERT"
else
  echo "[1/3] cert.p12 exists, skipping."
fi

# --- 3. Stage extension files (exclude scripts/cert/zxp/.git/.github) ---
echo "[2/3] Staging extension files ..."
rm -rf "$ROOT/_zxp_build"
mkdir -p "$STAGE"
rsync -a \
  --exclude '.git' \
  --exclude '.github' \
  --exclude '_zxp_build' \
  --exclude '*.bat' \
  --exclude '*.command' \
  --exclude '*.p12' \
  --exclude '*.zxp' \
  --exclude 'ZXPSignCmd' \
  "$ROOT"/ "$STAGE"/

# --- 4. Sign & package ---
echo "[3/3] Signing & packaging ..."
[ -f "$OUT" ] && rm -f "$OUT"
"$ZXP" -sign "$STAGE" "$OUT" "$CERT" "$PW" -tsa http://timestamp.digicert.com

echo
if [ -f "$OUT" ]; then
  echo "============================================================"
  echo "  Built: $OUT"
  echo "  Distribute the .zxp; teammates install it with ZXP Installer."
  echo "  Note: _zxp_build/ is a temp staging dir, safe to delete (git-ignored)."
  echo "============================================================"
else
  echo "  Build failed, check the ZXPSignCmd output above."
fi
echo
read -n 1 -s -r -p "Press any key to close..."
echo
