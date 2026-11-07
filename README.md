# computer-configs

Configs and setup for my Ubuntu 26.04 / GNOME 50 machine. Nothing sensitive lives here (see `.gitignore`).

## Setup on a fresh machine
```bash
sudo apt install ghostty starship stow
./scripts/install.sh        # font, symlinks (stow), bashrc hook, default terminal, dock
./scripts/restore-gnome.sh  # optional: load GNOME settings
```

## Layout
- `dotfiles/<pkg>/` — stow packages mirroring `$HOME` (ghostty, starship, bash)
- `scripts/install.sh` — apply everything; idempotent, never overwrites files
- `scripts/snapshot.sh` — capture current state into the repo (read-only on the system)
- `scripts/restore-gnome.sh` — load curated GNOME settings back
- `gnome/dconf/` — curated dconf dumps (interface, wm, shell, keybindings, terminal…)
- `packages/` — apt (manual), snap, flatpak, VS Code extension lists
- `input-remapper/` — mouse button remaps (copy of `~/.config/input-remapper-2`)

## Theme
Tokyo Night (Night variant) · JetBrainsMono Nerd Font
