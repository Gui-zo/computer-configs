#!/usr/bin/env bash
# Build a user-level "Papirus-Black" icon theme: Papirus-Dark with black folders.
# No sudo, doesn't touch /usr/share/icons (unlike papirus-folders). Re-runnable.
set -euo pipefail
SRC=/usr/share/icons/Papirus
DEST="$HOME/.local/share/icons/Papirus-Black"
COLOR="${1:-black}"   # any Papirus folder color: black, grey, white, ...

[ -d "$SRC" ] || { echo "Papirus not installed (apt install papirus-icon-theme)"; exit 1; }
rm -rf "$DEST" && mkdir -p "$DEST"

dirs=()
for d in "$SRC"/*/places; do
  rel="${d#"$SRC"/}"
  mkdir -p "$DEST/$rel"
  # every "places" icon that points at the default blue variant -> the $COLOR variant
  for link in "$d"/*.svg; do
    [ -L "$link" ] || continue
    target="$(readlink "$link")"
    [[ "$target" == *-blue* ]] || continue
    alt="${target//-blue/-$COLOR}"
    [ -e "$d/$alt" ] && ln -s "$d/$alt" "$DEST/$rel/$(basename "$link")"
  done
  dirs+=("$rel")
done

{
  echo "[Icon Theme]"
  echo "Name=Papirus-Black"
  echo "Comment=Papirus-Dark with $COLOR folders"
  echo "Inherits=Papirus-Dark,breeze-dark,hicolor"
  echo "Directories=$(IFS=,; echo "${dirs[*]}")"
  echo
  # copy each places dir's size/scale/context definition from Papirus
  for rel in "${dirs[@]}"; do
    awk -v sec="[$rel]" '$0==sec{p=1;print;next} /^\[/{p=0} p' "$SRC/index.theme"
    echo
  done
} > "$DEST/index.theme"

gtk-update-icon-cache -q -f "$DEST" 2>/dev/null || true
echo "Papirus-Black built ($(find "$DEST" -type l | wc -l) folder icons -> $COLOR)"
