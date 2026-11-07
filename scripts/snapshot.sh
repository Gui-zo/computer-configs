#!/usr/bin/env bash
# Capture the current machine state into the repo (read-only on the system).
# Re-run any time; review `git diff` before committing.
set -euo pipefail
cd "$(dirname "$0")/.."

# --- GNOME settings: curated paths only (full dump contains app state/recent paths) ---
declare -A DCONF=(
  [interface]=/org/gnome/desktop/interface/
  [wm]=/org/gnome/desktop/wm/
  [input-sources]=/org/gnome/desktop/input-sources/
  [peripherals]=/org/gnome/desktop/peripherals/
  [background]=/org/gnome/desktop/background/
  [shell]=/org/gnome/shell/
  [mutter]=/org/gnome/mutter/
  [media-keys]=/org/gnome/settings-daemon/plugins/media-keys/
  [terminal]=/org/gnome/terminal/
  [ptyxis]=/org/gnome/Ptyxis/
  [text-editor]=/org/gnome/TextEditor/
)
for name in "${!DCONF[@]}"; do
  out="gnome/dconf/$name.ini"
  dconf dump "${DCONF[$name]}" > "$out"
  [ -s "$out" ] || rm -f "$out"
done
gnome-extensions list --enabled > gnome/extensions-enabled.txt

# --- Input Remapper (mouse button remaps) ---
rm -rf input-remapper && mkdir -p input-remapper
rsync -a --exclude='*.bak' ~/.config/input-remapper-2/ input-remapper/

# --- Package lists ---
apt-mark showmanual | sort > packages/apt-manual.txt
snap list | awk 'NR>1 && $NF !~ /base|core|snapd/ {print $1, $4}' > packages/snap.txt
flatpak list --app --columns=application 2>/dev/null | sort > packages/flatpak.txt || true
command -v code >/dev/null && code --list-extensions | sort > packages/vscode-extensions.txt || true

echo "Snapshot written. Review with: git status && git diff"
