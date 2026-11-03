#!/usr/bin/env bash
# Xlin-soft: the files that install.sh and update.sh both put in place (one list, so they cannot drift apart).
# Source it, set SRC to the repository folder, and call `xlin_install_files`.

XLIN_BINS=(xlin xlin-dock-watch xlin-settings xlin-tools xlin-welcome xlin-files xlin-monitor xlin-terminal
  xlin-desktop xlin-start xlin-store xlin-media xlin-debug xlin-edit xlin-view xlin-read)
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


# xlin_find_hyprland: make `hyprctl` and `xlin restart` work from any terminal (a text console, an ssh session or a terminal
# opened before Hyprland): find the running Hyprland and use it. Returns 0 when one is running.
xlin_find_hyprland() {
  [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]] && return 0
  local run="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}" d sock
  [[ -d "$run/hypr" ]] || return 1
  d="$(ls -1dt "$run"/hypr/*/ 2>/dev/null | head -n1)"
  [[ -n "$d" && -S "${d}.socket.sock" ]] || return 1
  export XDG_RUNTIME_DIR="$run" HYPRLAND_INSTANCE_SIGNATURE="$(basename "$d")"
  if [[ -z "${WAYLAND_DISPLAY:-}" ]]; then
    sock="$(ls -1 "$run"/wayland-[0-9]* 2>/dev/null | grep -v '\.lock$' | head -n1)"
    [[ -n "$sock" ]] && export WAYLAND_DISPLAY="$(basename "$sock")"
  fi
  return 0
}

# xlin_finish: the last step of install.sh and update.sh. Reloads Hyprland and restarts every Xlin-soft part, with a time
# limit so nothing can hang the terminal.
xlin_finish() {
  if xlin_find_hyprland; then
    printf '\033[1;34m==>\033[0m Starting Xlin-soft now (xlin restart)\n'
    timeout 15 hyprctl reload >/dev/null 2>&1 || true
    timeout 90 /usr/local/bin/xlin restart </dev/null || echo "(xlin restart did not finish: run 'xlin restart' in a new terminal)"
  else
    echo "Hyprland is not running here. Log in to your Hyprland session, then run: xlin restart"
  fi
}
