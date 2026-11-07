#!/usr/bin/env bash
# Apply the Tokyo Night GNOME look: GTK theme, extensions, wallpaper, settings.
# Prereqs (sudo): apt install papirus-icon-theme bibata-cursor-theme sassc
# Undo: ./scripts/restore-gnome.sh (loads the pre-rice snapshot in gnome/dconf/)
set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
SHELL_VER="$(gnome-shell --version | awk '{print $3}' | cut -d. -f1)"

EXTENSIONS=(
  blur-my-shell@aunetx
  just-perfection-desktop@just-perfection
  monitor@astraext.github.io
  space-bar@luchrioh
  openbar@neuromorph
  forge@jmmaranan.com
  rounded-window-corners@fxgn
  mediacontrols@cliffniff.github.com
  clipboard-indicator@tudmotu.com
  caffeine@patapon.info
)

# --- GTK theme (Tokyonight, links gtk-4.0 for libadwaita apps) ---
if [ ! -d ~/.themes/Tokyonight-Dark ]; then
  git clone -q --depth 1 https://github.com/Fausto-Korpsvart/Tokyonight-GTK-Theme.git "$TMP/tokyonight"
  [ -z "$(ls -A ~/.config/gtk-4.0 2>/dev/null)" ] || cp -a ~/.config/gtk-4.0 "$REPO/.gtk-4.0.pre-rice.bak"
  (cd "$TMP/tokyonight/themes" && ./install.sh -c dark -l >/dev/null)
  echo "installed GTK theme: $(ls ~/.themes | grep -i tokyonight | tr '\n' ' ')"
fi

# --- Extensions from extensions.gnome.org (for this shell version) ---
for uuid in "${EXTENSIONS[@]}"; do
  if [ "$(gnome-extensions info "$uuid" 2>/dev/null | awk -F': ' '/State/{print $2}')" = "ACTIVE" ]; then continue; fi
  # NB: ?shell_version= silently falls back to the newest release even if it
  # doesn't support this shell, so check shell_version_map explicitly.
  pk="$(curl -fsS "https://extensions.gnome.org/extension-info/?uuid=$uuid" \
        | /usr/bin/python3 -c 'import sys,json; print(json.load(sys.stdin)["shell_version_map"].get(sys.argv[1],{}).get("pk",""))' "$SHELL_VER")"
  if [ -z "$pk" ]; then echo "SKIP $uuid: no release for GNOME $SHELL_VER yet"; continue; fi
  curl -fsSL -o "$TMP/$uuid.zip" "https://extensions.gnome.org/download-extension/$uuid.shell-extension.zip?version_tag=$pk"
  gnome-extensions install --force "$TMP/$uuid.zip"
  echo "installed $uuid"
done

# --- Wallpaper ---
mkdir -p ~/.local/share/backgrounds
cp "$REPO/wallpapers/tokyo-night-mountains.png" ~/.local/share/backgrounds/
WP="file://$HOME/.local/share/backgrounds/tokyo-night-mountains.png"
dconf write /org/gnome/desktop/background/picture-uri "'$WP'"
dconf write /org/gnome/desktop/background/picture-uri-dark "'$WP'"
dconf write /org/gnome/desktop/screensaver/picture-uri "'$WP'"

# --- Settings (dconf, bypasses any stale GSETTINGS_SCHEMA_DIR) ---
dconf load / < "$REPO/gnome/rice.ini"
echo "settings applied — log out and back in to load the new extensions (Wayland)"
