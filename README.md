# computer-configs

Configs and setup for my Ubuntu 26.04 / GNOME 50 machine. Nothing sensitive lives here (see `.gitignore`).

## Setup on a fresh machine
```bash
sudo apt install starship stow
./scripts/install.sh        # Nerd Font, symlinks (stow), bashrc hook (plain starship prompt)
./scripts/stock-gnome.sh    # GNOME look (see profiles)
```

## GNOME profiles
| Profile | Script | What |
|---|---|---|
| **stock+** (current) | `scripts/stock-gnome.sh` | Stock Ubuntu (Yaru-dark, GNOME Terminal, dock, Tiling Assistant) + Astra Monitor CPU/RAM/network in the top bar |
| rice | `scripts/rice-gnome.sh` | Black/mono: Tokyonight Grey GTK+shell theme, Papirus black folders, Tiling Shell, Space Bar workspaces, Ghostty. Needs `sudo apt install ghostty papirus-icon-theme bibata-cursor-theme sassc` |

Switching is non-destructive: `stock-gnome.sh` resets every key `rice-gnome.sh` sets.
Settings live in `gnome/stock-plus.ini` and `gnome/rice.ini`.

## Layout
- `dotfiles/<pkg>/` — stow packages mirroring `$HOME` (ghostty, starship, bash)
- `scripts/install.sh` — apply dotfiles; idempotent, never overwrites files
- `scripts/snapshot.sh` — capture current state into the repo (read-only on the system)
- `scripts/restore-gnome.sh` — load the curated dconf snapshot in `gnome/dconf/`
- `scripts/papirus-black.sh` — user-level Papirus theme with black (or any color) folders
- `gnome/dconf/` — curated dconf dumps (interface, wm, shell, keybindings, terminal…)
- `packages/` — apt (manual), snap, flatpak, VS Code extension lists
- `input-remapper/` — mouse button remaps (copy of `~/.config/input-remapper-2`)
- `wallpapers/generate.py` — generated mountain wallpapers (`mono` / `tokyo`)
