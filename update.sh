#!/usr/bin/env bash
# Update Xlin-soft from this folder. Missing dependencies are installed automatically.
#   ./update.sh
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
XLIN_HOME="$HOME/.config/xlin"
export XLIN_HOME

[[ $EUID -ne 0 ]] || { echo "Run as your normal user, not root."; exit 1; }
say() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }

say "Copying Xlin-soft files"
mkdir -p "$XLIN_HOME/state" "$XLIN_HOME/wallpapers" "$HOME/.config/hypr" "$HOME/.config/waybar" "$HOME/.config/swaync"
echo "$SRC" >"$XLIN_HOME/state/source"
cp -r "$SRC/themes" "$SRC/templates" "$XLIN_HOME/"
mkdir -p "$XLIN_HOME/wallpapers"
cp "$SRC"/assets/wallpapers/*.jpg "$XLIN_HOME/wallpapers/"
# the old built-in wallpapers (before the six gradients) go away; wallpapers the user added are never touched
for w in dawn mist lagoon blossom midnight nebula ember forest; do rm -f "$XLIN_HOME/wallpapers/xlin-$w.jpg"; done
rm -f "$XLIN_HOME/wallpapers/xlin-light.png" "$XLIN_HOME/wallpapers/xlin-dark.png"
cp "$SRC/config/shell/xlin.bash" "$XLIN_HOME/shell.bash"
cp "$SRC/config/kitty/kitty.conf" "$XLIN_HOME/kitty.conf"
cp "$SRC/config/hypr/xlin.conf" "$SRC/config/hypr/xlin.lua" "$HOME/.config/hypr/"
# Keep the first user-config backup across repeated updates. The installer uses
# the same .bak- timestamp convention, so its original backup is respected.
STAMP="$(date +%Y%m%d-%H%M%S)"
source "$SRC/lib/config-backups.sh"

xlin_backup_once "$HOME/.config/waybar/config.jsonc"
cp "$SRC/config/waybar/config.jsonc" "$HOME/.config/waybar/config.jsonc"
cp "$SRC/config/waybar/config.jsonc" "$XLIN_HOME/waybar-base.jsonc"
xlin_backup_once "$HOME/.config/swaync/config.json"
cp "$SRC/config/swaync/config.json" "$HOME/.config/swaync/config.json"

say "Checking dependencies (installs anything that is missing)"
source "$SRC/scripts/deps.sh"
rm -f "$HOME/.config/xlin/state/.gi_ok" "$HOME/.config/xlin/state/.vte_ok"
xlin_deps || echo "(some packages are missing; the message above says which)"

say "Installing the xlin commands (asks for your password once)"
source "$SRC/scripts/files.sh"
xlin_install_files

/usr/local/bin/xlin hook || true
/usr/local/bin/xlin pins init || true      # a fresh install gets Xlin-soft's own apps pinned (your pins are never touched)

say "Applying theme and terminal"
theme="$(cat "$XLIN_HOME/state/theme" 2>/dev/null || echo light)"
/usr/local/bin/xlin theme "$theme" || true
/usr/local/bin/xlin terminal || true
/usr/local/bin/xlin adapt || true

if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
  hyprctl reload >/dev/null 2>&1 || true
  /usr/local/bin/xlin restart || true
fi
ver="$(grep -m1 '^XLIN_VERSION=' "$SRC/bin/xlin" | cut -d'"' -f2)"
say "Done. Xlin-soft $ver is installed. Open a new terminal."
# what is new in this version (the newest section of the changelog)
if [[ -f "$SRC/CHANGELOG.md" ]]; then
  echo; echo "What's new:"
  awk '/^## /{n++; next} n==1 && NF' "$SRC/CHANGELOG.md" | sed -n '1,8p' | cut -c1-200 | sed 's/^/  /'
fi
command -v notify-send >/dev/null && notify-send -a "Xlin-soft" "Xlin-soft updated" "Version $ver is installed" 2>/dev/null || true
