#!/usr/bin/env bash
# Xlin-soft installer for Arch Linux + Hyprland
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
XLIN_HOME="$HOME/.config/xlin"
BIN="$HOME/.local/bin"
STAMP="$(date +%Y%m%d-%H%M%S)"

say() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }

[[ -f /etc/arch-release ]] || { echo "Xlin-soft installer targets Arch Linux."; exit 1; }
[[ $EUID -ne 0 ]] || { echo "Run as your normal user, not root."; exit 1; }

# ---------------------------------------------------------------- packages
# Everything Xlin-soft needs is installed here (only what is missing). The same step runs on every update.
say "Installing dependencies"
source "$SRC/scripts/deps.sh"
xlin_deps || echo "(some packages are missing; fix them, then run: xlin deps)"

# ------------------------------------------------------------------- files
say "Installing Xlin-soft to $XLIN_HOME"
mkdir -p "$XLIN_HOME" "$HOME/.config/hypr" "$HOME/.config/waybar" "$HOME/.config/swaync"
cp -r "$SRC/themes" "$SRC/templates" "$XLIN_HOME/"
mkdir -p "$XLIN_HOME/wallpapers"
cp "$SRC"/assets/wallpapers/*.jpg "$XLIN_HOME/wallpapers/"
cp "$SRC/config/shell/xlin.bash" "$XLIN_HOME/shell.bash"
cp "$SRC/config/kitty/kitty.conf" "$XLIN_HOME/kitty.conf"

source "$SRC/scripts/files.sh"
xlin_install_files
mkdir -p "$XLIN_HOME/wallpapers" "$XLIN_HOME/state"
echo "$SRC" >"$XLIN_HOME/state/source"
rm -f "$XLIN_HOME/state/welcomed"   # a fresh install shows the Welcome tour again

source "$SRC/lib/config-backups.sh"

# Waybar prefers a file called `config` over `config.jsonc`, so move an old one aside
if [[ -f "$HOME/.config/waybar/config" ]]; then
  mv "$HOME/.config/waybar/config" "$HOME/.config/waybar/config.bak-$STAMP"
  echo "   moved old waybar config aside"
fi

xlin_backup_once "$HOME/.config/waybar/config.jsonc"
cp "$SRC/config/waybar/config.jsonc" "$HOME/.config/waybar/config.jsonc"
cp "$SRC/config/waybar/config.jsonc" "$XLIN_HOME/waybar-base.jsonc"
xlin_backup_once "$HOME/.config/swaync/config.json"
cp "$SRC/config/swaync/config.json" "$HOME/.config/swaync/config.json"
cp "$SRC/config/hypr/xlin.conf" "$SRC/config/hypr/xlin.lua" "$HOME/.config/hypr/"

# ----------------------------------------------- hook Xlin-soft into the Hyprland config
# Hyprland 0.55+ reads hyprland.lua (0.57 dropped hyprland.conf); older versions read hyprland.conf.
# `xlin hook` picks the right one, keeps a backup, and puts Xlin-soft last so its shortcuts always work.
for hc in "$HOME/.config/hypr/hyprland.lua" "$HOME/.config/hypr/hyprland.conf"; do
  [[ -f "$hc" ]] && xlin_backup_once "$hc"
done
/usr/local/bin/xlin hook
/usr/local/bin/xlin pins init || true
/usr/local/bin/xlin defaults reset || true   # Xlin-soft Files, Media and Terminal are the default apps (changeable in Settings)      # a fresh install gets Xlin-soft's own apps pinned (your pins are never touched)

# ------------------------------------------------------------------- theme
say "Applying light theme"
export XLIN_HOME
# each step has a time limit and no keyboard input, so a slow or stuck helper can never hang the installer
timeout 120 /usr/local/bin/xlin theme light </dev/null || echo "(the theme step did not finish: it is applied again by 'xlin restart' below)"
timeout 60 /usr/local/bin/xlin terminal </dev/null || true
timeout 30 /usr/local/bin/xlin adapt </dev/null || true

xlin_finish

say "Done. Run 'xlin doctor' to check everything. If something is missing, run 'xlin start'."
