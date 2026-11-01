#!/usr/bin/env bash
# ---- Hyprland 0.55+ uses a Lua config (hyprland.lua); 0.57 dropped hyprland.conf. Xlin-soft speaks both.
hypr_version() {   # e.g. 0.57.0
  local v=""
  have pacman && v="$(pacman -Q hyprland 2>/dev/null | awk '{print $2}' | sed -E 's/^[0-9]+://; s/-.*//')"
  [[ "$v" =~ ^[0-9]+\.[0-9]+ ]] || v="$(Hyprland --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)"
  echo "${v:-0}"
}
hypr_ge() { [[ "$(printf '%s\n%s\n' "$1" "$(hypr_version)" | sort -V | head -1)" == "$1" ]]; }
hypr_mode() {      # lua | conf: which kind of config Hyprland reads
  if [[ -z "${_HYPR_MODE:-}" ]]; then
    if [[ -f "$HOME/.config/hypr/hyprland.lua" ]] || hypr_ge 0.57; then _HYPR_MODE=lua; else _HYPR_MODE=conf; fi
  fi
  echo "$_HYPR_MODE"
}
is_lua() { [[ -n "${_HYPR_MODE:-}" ]] || hypr_mode >/dev/null; [[ "$_HYPR_MODE" == lua ]]; }
# hy_lua <lua code>: run Lua inside the running Hyprland
hy_lua() { hyprctl eval "$1" >/dev/null 2>&1; }
# The few window / session actions Xlin-soft uses, written once for both config kinds
hy_move_silent() {   # <workspace> <window address>
  if is_lua; then
    hy_lua "hl.dispatch(hl.dsp.window.move({ workspace = \"$1\", follow = false, window = \"address:$2\" }))"
  else hyprctl dispatch movetoworkspacesilent "$1,address:$2" >/dev/null 2>&1; fi
}
# hy_special_shown <name>: is that special workspace on screen right now?
hy_special_shown() {
  hyprctl monitors -j 2>/dev/null | jq -e --arg n "special:$1" 'any(.[]; .specialWorkspace.name == $n)' >/dev/null 2>&1
}
# hy_special_close <name>: put a special workspace away (the windows in it stay hidden)
hy_special_close() {
  hy_special_shown "$1" || return 0
  if is_lua; then hy_lua "hl.dispatch(hl.dsp.workspace.toggle_special(\"$1\"))"; sleep 0.05; fi
  # older Hyprland, or the Lua call did not exist: the classic dispatcher
  hy_special_shown "$1" && hyprctl dispatch togglespecialworkspace "$1" >/dev/null 2>&1
  return 0
}
hy_focus() {         # <window selector, e.g. address:0x1 or class:dev.xlin.Monitor>
  if is_lua; then hy_lua "hl.dispatch(hl.dsp.focus({ window = \"$1\" }))"
  else hyprctl dispatch focuswindow "$1" >/dev/null 2>&1; fi
}
hy_dpms() {          # on | off
  if is_lua; then
    hy_lua "hl.dispatch(hl.dsp.dpms({ action = \"$([[ $1 == on ]] && echo enable || echo disable)\" }))"
  else hyprctl dispatch dpms "$1" >/dev/null 2>&1; fi
}
hy_exit() {
  if is_lua; then hy_lua 'hl.dispatch(hl.dsp.exit())'; else hyprctl dispatch exit; fi
}
