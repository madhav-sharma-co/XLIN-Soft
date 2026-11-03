#!/usr/bin/env bash
# Xlin-soft: the files that install.sh and update.sh both put in place (one list, so they cannot drift apart).
# Source it, set SRC to the repository folder, and call `xlin_install_files`.

XLIN_BINS=(xlin xlin-dock-watch xlin-settings xlin-tools xlin-welcome xlin-files xlin-monitor xlin-terminal
  xlin-desktop xlin-start xlin-store xlin-media xlin-debug xlin-edit xlin-view)
XLIN_LIBS=(hyprland.sh config-backups.sh xlin_ui.py)

xlin_install_files() {
  local b l
  # /usr/local/bin is on every session's PATH, including Hyprland's exec-once and Waybar clicks
  sudo rm -f /usr/local/bin/xlin-launcher        # the App drawer was merged into the Launcher
  for b in "${XLIN_BINS[@]}"; do sudo install -m 755 "$SRC/bin/$b" "/usr/local/bin/$b"; done
  for l in "${XLIN_LIBS[@]}"; do sudo install -D -m 644 "$SRC/lib/$l" "/usr/local/lib/xlin/$l"; done
  mkdir -p "$HOME/.local/share/applications"
  cp "$SRC"/config/applications/dev.xlin.*.desktop "$HOME/.local/share/applications/"
  mkdir -p "$HOME/.local/share/icons/hicolor/scalable/apps"
  cp "$SRC"/assets/icons/*.svg "$HOME/.local/share/icons/hicolor/scalable/apps/"
  command -v gtk-update-icon-cache >/dev/null && gtk-update-icon-cache -q -t "$HOME/.local/share/icons/hicolor" 2>/dev/null || true
  command -v update-desktop-database >/dev/null && update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
  mkdir -p "$HOME/.local/share/icons"
  cp -a "$SRC/assets/cursors/." "$HOME/.local/share/icons/"
  return 0
}
