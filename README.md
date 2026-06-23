# Cocos PSD Namer — Photoshop Layer Naming Plugin (CEP)

**English** · [中文](./README.zh-CN.md)

A Photoshop panel that pairs with **cocos-psd-prefab-2x**: **select layers → click a button → batch-prefix the layer names**
(`btn_`/`lay_v_`/`sv_`…), letting artists quickly tag layers using the naming convention the converter recognizes.

> **Companion tool**: [cocos-psd-prefab-2x](https://github.com/shiliyu1991-lang/cocos-psd-prefab-2x)
> — a PSD→prefab converter for Cocos Creator 2.4.x that parses the naming convention this plugin applies and generates a node tree.

- Supports **multi-select** to rename several layers at once.
- Switching prefixes **automatically strips the old type prefix** before adding the new one (can be disabled in the panel).
- One-click **prefix removal** to restore names; also supports tagging `// comment` / `! ignore` / `ref_` / `tmp_`.
- Compatible with **Photoshop CC2015 ~ 2025** (CEP 6+).

## Button Mapping (matches the converter)

| Button | Prefix Added | Converts To |
|------|----------|--------|
| btn_ Button | `btn_` | cc.Button |
| lbl_ Label / rt_ RichText | `lbl_` / `rt_` | Label / RichText |
| sp_ Sliced | `sp_` | Sliced Sprite (remember to append `#top,right,bottom,left` after the name) |
| node_ / mask_ / edit_ / prog_ / tog_ | same name | Empty container / Mask / EditBox / ProgressBar / Toggle |
| lay_v_ / lay_h_ / lay_grid_ | same name | Container with Layout (vertical / horizontal / grid) |
| sv_ ScrollView | `sv_` | cc.ScrollView |
| ref_ / tmp_ / // / ! | same name | Layer is **ignored** during conversion |
| Remove Prefix | (cleared) | Restored to no prefix |

## Installation

### Option A: One-Click Install (recommended)

**Windows** — just double-click **`install.bat`** in the repo. It automatically:

1. Copies the extension to `%APPDATA%\Adobe\CEP\extensions\com.cocos.psdnamer\`;
2. Writes `PlayerDebugMode=1` for `CSXS.6 ~ CSXS.12` (allows unsigned extensions, so you don't have to edit the registry by hand).

The whole process only writes to `HKCU` + `%APPDATA%`, so **no administrator privileges are needed**.

**macOS** — double-click **`install.command`** (or run `bash install.command` in Terminal). It does the equivalent:

1. Copies the extension to `~/Library/Application Support/Adobe/CEP/extensions/com.cocos.psdnamer/`;
2. Runs `defaults write com.adobe.CSXS.<6..12> PlayerDebugMode 1` so unsigned extensions are allowed.

No `sudo` is needed — it only writes to your home `~/Library` and user defaults.

> macOS first-run notes:
> - If double-clicking does nothing, the execute bit may be missing after cloning. Run `chmod +x install.command uninstall.command` once, then double-click again.
> - If Gatekeeper blocks it ("cannot be opened"), right-click the file → **Open** → **Open**, or run `xattr -d com.apple.quarantine install.command`.

After installing, on either OS **fully quit and restart Photoshop**, then open the panel from the menu **Window > Extensions (legacy) → Cocos PSD Namer**.

> Uninstall: **`uninstall.bat`** (Windows) / **`uninstall.command`** (macOS).

---

### Option B: Manual Install (one-time)

### 1. Place It in the CEP Extensions Directory
Copy this entire folder (including `CSXS/`, `index.html`, `host.jsx`) into the location below, renaming it to `com.cocos.psdnamer`:

- **Windows**: `C:\Users\<your-username>\AppData\Roaming\Adobe\CEP\extensions\com.cocos.psdnamer\`
- **macOS**: `~/Library/Application Support/Adobe/CEP/extensions/com.cocos.psdnamer/`

(If the `CEP\extensions` directory doesn't exist, create it manually.)

### Option C: Package a .zxp for Team Distribution (no PlayerDebugMode)

If you want to hand it to colleagues without making them touch the registry, package the extension as a signed `.zxp`.
A `.zxp` is **cross-platform** — the same file installs on both Windows and macOS, so you only need to build it once.

- **Windows**: download `ZXPSignCmd.exe` from [Adobe CEP-Resources](https://github.com/Adobe-CEP/CEP-Resources)
  (place it next to this folder, in a `tools\` subdirectory, or on PATH), then double-click **`build-zxp.bat`**.
- **macOS**: download the `osx64/ZXPSignCmd` build from the same repo, `chmod +x ZXPSignCmd`, place it next to this folder
  (or in `tools/`, or on PATH), then run **`build-zxp.command`** (double-click, or `bash build-zxp.command`).

Either way it auto-generates a self-signed certificate and packages `cocos-psd-namer.zxp`.

Once colleagues have the `.zxp`, they can **install it by dragging it in** with [ZXP Installer](https://aescripts.com/learn/zxp-installer/) or
Anastasiy's Extension Manager — no need to enable PlayerDebugMode.

> Note: `cert.p12` (which contains the private key) and `*.zxp` are already ignored by `.gitignore`, so they won't accidentally be pushed to the repo.

**Automated Release (GitHub Actions)**: push a `v*` tag to have CI automatically package and attach the `.zxp` to a Release:

```bash
git tag v1.0.0 && git push origin v1.0.0
```

The workflow `.github/workflows/release-zxp.yml` runs on `windows-latest` and automatically downloads
`ZXPSignCmd`, generates a self-signed certificate on the fly, and signs and packages the extension — **no Secrets to configure**.
(You can also trigger it manually from the Actions page and download the result as an artifact.)
Since a `.zxp` is cross-platform, this single CI artifact installs on macOS too — no separate Mac CI job is needed.

---

### 2. Allow Unsigned Extensions (PlayerDebugMode)
This extension isn't ZXP-signed, so you need to enable debug mode:

- **Windows**: press `Win+R`, type `regedit`, and navigate to `HKEY_CURRENT_USER\Software\Adobe\CSXS.11`
  (create the key if it doesn't exist; different PS versions may use `CSXS.9 / .10 / .11 / .12`, so creating them all is the safest bet),
  then add a **String value** named `PlayerDebugMode` with the data set to `1`.
- **macOS**: run the following in Terminal (set it once per version)
  ```bash
  defaults write com.adobe.CSXS.11 PlayerDebugMode 1
  defaults write com.adobe.CSXS.12 PlayerDebugMode 1
  ```

### 3. Restart Photoshop
Open the panel from the menu **Window > Extensions (legacy) → Cocos PSD Namer**.

## Usage

1. Select one or more layers in the Layers panel (use Ctrl/Shift for multi-select).
2. Click the matching prefix button in the panel to batch-rename them.
3. To change the prefix, just click another button (by default it replaces the old prefix); to restore, click "Remove Prefix".

## Notes / Limitations

- `host.jsx` uses ActionManager to read/rename the **selected layers** (renaming by layer ID, with multi-select support,
  without changing the current selection). Each rename is a single undoable history step.
- This is a development-mode load (unsigned). To distribute it to your team, use Adobe `ZXPSignCmd` to package it as a `.zxp` and install it via
  Anastasiy's Extension Manager / UPIA, which removes the need for PlayerDebugMode.
- If the panel buttons don't respond: confirm PlayerDebugMode is set and Photoshop has been restarted; on some versions the menu is under
  "Window > Extensions" rather than "(legacy)".

## Directory Structure

```
com.cocos.psdnamer/
├── CSXS/manifest.xml   Extension manifest (host=PHXS, panel)
├── index.html          Panel UI (buttons + logic, minimal built-in CSInterface)
├── host.jsx            ExtendScript: add / replace / remove prefixes on selected layers by ID
├── install.bat         One-click install on Windows (copy + enable PlayerDebugMode)
├── uninstall.bat       One-click uninstall on Windows
├── install.command     One-click install on macOS (copy + enable PlayerDebugMode)
├── uninstall.command   One-click uninstall on macOS
├── build-zxp.bat       Package into a signed .zxp on Windows (self-signed cert)
└── build-zxp.command   Package into a signed .zxp on macOS (self-signed cert)
```
