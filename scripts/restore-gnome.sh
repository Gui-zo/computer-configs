#!/usr/bin/env bash
# Load the curated dconf snapshots back into GNOME.
set -euo pipefail
cd "$(dirname "$0")/.."
declare -A DCONF=(
  [interface]=/org/gnome/desktop/interface/   [wm]=/org/gnome/desktop/wm/
  [input-sources]=/org/gnome/desktop/input-sources/ [peripherals]=/org/gnome/desktop/peripherals/
  [background]=/org/gnome/desktop/background/ [shell]=/org/gnome/shell/
  [mutter]=/org/gnome/mutter/ [media-keys]=/org/gnome/settings-daemon/plugins/media-keys/
  [terminal]=/org/gnome/terminal/ [ptyxis]=/org/gnome/Ptyxis/ [text-editor]=/org/gnome/TextEditor/
)
for name in "${!DCONF[@]}"; do
  f="gnome/dconf/$name.ini"
  [ -f "$f" ] && dconf load "${DCONF[$name]}" < "$f" && echo "loaded $name"
done
