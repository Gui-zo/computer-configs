#!/usr/bin/env bash
# Apply the configs in this repo to the current user. Idempotent; never deletes files.
# Prereqs (sudo): apt install starship stow   (+ ghostty for the rice profile)
set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
PACKAGES=(ghostty bash starship)

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

