#!/bin/bash
# ============================================================
#  Cocos PSD Namer - macOS one-click install (Photoshop CEP)
#  What it does:
#    1) Copies this folder to the CEP extensions dir com.cocos.psdnamer
#    2) Enables PlayerDebugMode for CSXS.6 ~ CSXS.12 (allow unsigned extensions)
#  Writes only to ~/Library + user defaults, no sudo needed.
# ============================================================
set -e

SRC="$(cd "$(dirname "$0")" && pwd)"
DEST="$HOME/Library/Application Support/Adobe/CEP/extensions/com.cocos.psdnamer"

echo
echo "  Source : $SRC"
echo "  Install: $DEST"
echo

echo "[1/3] Copying extension files..."
mkdir -p "$DEST"
rsync -a --delete \
  --exclude '.git' \
  --exclude '.github' \
  --exclude '*.bat' \
  --exclude '*.command' \
  --exclude '*.zxp' \
  --exclude 'cert.p12' \
  "$SRC"/ "$DEST"/
echo "  done."

echo "[2/3] Enabling PlayerDebugMode (CSXS.6 ~ CSXS.12)..."
for V in 6 7 8 9 10 11 12; do
  defaults write "com.adobe.CSXS.$V" PlayerDebugMode 1 2>/dev/null || true
done
echo "  done."

echo "[3/3] Verifying..."
if [ -f "$DEST/CSXS/manifest.xml" ]; then
  echo "  installed."
else
  echo "  WARNING: manifest.xml not found, install may be incomplete."
fi

echo
echo "============================================================"
echo "  Done! Fully quit and restart Photoshop, then open"
echo "  Window > Extensions (legacy) > Cocos PSD Namer."
echo "============================================================"
echo
read -n 1 -s -r -p "Press any key to close..."
echo
