#!/bin/bash
# ============================================================
#  Cocos PSD Namer - macOS uninstall
# ============================================================
set -e

DEST="$HOME/Library/Application Support/Adobe/CEP/extensions/com.cocos.psdnamer"

echo
echo "  Removing: $DEST"
echo

if [ -d "$DEST" ]; then
  rm -rf "$DEST"
  echo "  Extension folder removed."
else
  echo "  Installed extension not found, skipping."
fi

echo
echo "  Note: PlayerDebugMode is left enabled (harmless to other extensions)."
echo "  To turn it off manually, run:"
echo "    for V in 6 7 8 9 10 11 12; do defaults delete com.adobe.CSXS.\$V PlayerDebugMode; done"
echo
echo "  Uninstall complete. Please restart Photoshop."
echo
read -n 1 -s -r -p "Press any key to close..."
echo
