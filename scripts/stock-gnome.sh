#!/usr/bin/env bash
# Go back to the stock Ubuntu look, keeping only the system monitor in the top bar.
# Undoes scripts/rice-gnome.sh: resets every key in gnome/rice.ini, unlinks the
# GTK4 theme override, then loads gnome/stock-plus.ini. Never deletes user files.
# Re-rice any time with scripts/rice-gnome.sh.
set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"

# 1. Reset every setting the rice touched (back to Ubuntu defaults)
/usr/bin/python3 - "$REPO/gnome/rice.ini" <<'EOF' | while read -r key; do dconf reset "$key"; done
import sys
from gi.repository import GLib
kf = GLib.KeyFile(); kf.load_from_file(sys.argv[1], GLib.KeyFileFlags.NONE)
for g in kf.get_groups()[0]:
    for k in kf.get_keys(g)[0]:
        print(f"/{g}/{k}")
EOF
for k in picture-uri picture-uri-dark; do dconf reset /org/gnome/desktop/background/$k; done
dconf reset /org/gnome/desktop/screensaver/picture-uri

# 2. Remove the theme's libadwaita override (only if they're symlinks into ~/.themes)
for f in assets gtk.css gtk-dark.css; do
  p=~/.config/gtk-4.0/$f
  if [ -L "$p" ] && [[ "$(readlink "$p")" == "$HOME/.themes/"* ]]; then rm "$p"; fi
done

# 3. Stock settings + system monitor
dconf load / < "$REPO/gnome/stock-plus.ini"

# 4. GNOME Terminal as default terminal (if installed)
if [ -f /usr/share/applications/org.gnome.Terminal.desktop ]; then
  LIST=~/.config/GNOME-xdg-terminals.list
  { echo org.gnome.Terminal.desktop; grep -v -x org.gnome.Terminal.desktop "$LIST" 2>/dev/null || true; } > "$LIST.new" && mv "$LIST.new" "$LIST"
else
  echo "GNOME Terminal not installed: sudo apt install gnome-terminal, then re-run"
fi
echo "stock Ubuntu look restored (system monitor kept)"
