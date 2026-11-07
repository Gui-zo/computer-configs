#!/usr/bin/env bash
# Apply the configs in this repo to the current user. Idempotent; never deletes files.
# Prereqs (sudo): apt install ghostty starship stow
set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
PACKAGES=(ghostty bash starship forge)

# --- Nerd Font (user-level) ---
if ! fc-list | grep -qi "JetBrainsMono Nerd Font"; then
  tmp="$(mktemp -d)"
  curl -fsSL -o "$tmp/font.tar.xz" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz
  mkdir -p ~/.local/share/fonts/JetBrainsMonoNerd
  tar -xJf "$tmp/font.tar.xz" -C ~/.local/share/fonts/JetBrainsMonoNerd --wildcards '*.ttf'
  rm -rf "$tmp"
  fc-cache -f >/dev/null
  echo "installed JetBrainsMono Nerd Font"
fi

# --- Symlink dotfiles (stow refuses to overwrite existing files, so nothing is lost) ---
stow -d "$REPO/dotfiles" -t "$HOME" --restow "${PACKAGES[@]}"
echo "stowed: ${PACKAGES[*]}"

# --- bashrc hook (enables starship prompt) ---
HOOK='[ -f ~/.config/bash/rice.sh ] && . ~/.config/bash/rice.sh  # computer-configs'
grep -qF "$HOOK" ~/.bashrc || { printf '\n%s\n' "$HOOK" >> ~/.bashrc; echo "added bashrc hook"; }

# --- Ghostty as default terminal (Ctrl+Alt+T uses xdg-terminal-exec) ---
LIST=~/.config/GNOME-xdg-terminals.list
if [ "$(head -1 "$LIST" 2>/dev/null)" != "com.mitchellh.ghostty.desktop" ]; then
  { echo com.mitchellh.ghostty.desktop; grep -v ghostty "$LIST" 2>/dev/null || true; } > "$LIST.new" && mv "$LIST.new" "$LIST"
  echo "ghostty set as default terminal"
fi

# --- Dock: swap GNOME Terminal for Ghostty, keep position ---
fav="$(gsettings get org.gnome.shell favorite-apps)"
if [[ "$fav" != *ghostty* ]]; then
  if [[ "$fav" == *org.gnome.Terminal.desktop* ]]; then
    fav="${fav/org.gnome.Terminal.desktop/com.mitchellh.ghostty.desktop}"
  else
    fav="${fav%]}, 'com.mitchellh.ghostty.desktop']"
  fi
  gsettings set org.gnome.shell favorite-apps "$fav"
  echo "ghostty pinned to dock"
fi
