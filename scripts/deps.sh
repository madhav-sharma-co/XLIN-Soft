#!/usr/bin/env bash
# Xlin-soft dependencies: one list, used by install.sh, update.sh and `xlin deps`.
# Updates the installed packages and installs the missing ones (pacman -Syu); XLIN_NO_UPGRADE=1 installs only the missing.
# Source it and call `xlin_deps`, or run it directly.

XLIN_REQUIRED=(hyprland waybar swaync jq socat libnotify brightnessctl networkmanager network-manager-applet
  pipewire wireplumber pavucontrol blueman imagemagick ttf-font-awesome inter-font gtk3 gtk4 python-gobject
  gtk4-layer-shell bluez bluez-utils power-profiles-daemon hyprlock ttf-nerd-fonts-symbols vte4 polkit)
XLIN_EXTRA=(rofi udisks2 gvfs gvfs-smb grim slurp wl-clipboard cliphist hypridle hyprsunset
  xdg-desktop-portal-hyprland xdg-desktop-portal-gtk hyprpolkitagent playerctl gst-plugins-base gst-plugins-good gst-plugins-bad gst-libav gst-plugin-gtk4 gtksourceview5 poppler-glib)

_d_say() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }

_d_missing() { # which of these packages are not installed (pacman -T also understands "provides")
  pacman -T "$@" 2>/dev/null || true
}

_d_first_in_repo() { local p; for p in "$@"; do pacman -Si "$p" >/dev/null 2>&1 && { echo "$p"; return 0; }; done; return 0; }

# pacman allows one run at a time. Wait for a running one; remove the lock only when nothing is running (a stale lock
# is left behind by an interrupted install).
_d_unlock() {
  local lock=/var/lib/pacman/db.lck i
  [[ -e "$lock" ]] || return 0
  for i in $(seq 1 30); do
    pgrep -x 'pacman|yay|paru|pamac|pamac-daemon|packagekitd' >/dev/null 2>&1 || break
    ((i == 1)) && _d_say "Another package manager is running; waiting for it (up to a minute)"
    sleep 2
  done
  if [[ -e "$lock" ]] && ! pgrep -x 'pacman|yay|paru|pamac|pamac-daemon|packagekitd' >/dev/null 2>&1; then
    _d_say "Removing a stale pacman lock (no package manager is running)"
    sudo rm -f "$lock"
  fi
  [[ ! -e "$lock" ]]
}

# install packages from the repos; if the batch fails, retry one by one so a single bad name blocks nothing
_d_pacman() {
  (($#)) || return 0
  _d_unlock || { echo "!! pacman is busy: close the Store / other installers and run: xlin deps"; printf '%s\n' "$@" >"${XDG_RUNTIME_DIR:-/tmp}/xlin-deps-failed"; return 0; }
  sudo pacman -S --needed --noconfirm "$@" && return 0
  local p failed=()
  for p in "$@"; do sudo pacman -S --needed --noconfirm "$p" >/dev/null 2>&1 || failed+=("$p"); done
  ((${#failed[@]})) && printf '%s\n' "${failed[@]}" >"${XDG_RUNTIME_DIR:-/tmp}/xlin-deps-failed"
  return 0
}

_d_aur() { # package from the AUR with paru/yay, if one is installed
  local h; for h in paru yay; do command -v "$h" >/dev/null 2>&1 && { "$h" -S --needed --noconfirm "$1"; return; }; done
  return 1
}

# Bring the system and every Xlin-soft package up to date, and install what is missing, in ONE pacman run.
# Arch only supports full upgrades (a partial one can break the system), so this is `pacman -Syu`.
# Skip it with XLIN_NO_UPGRADE=1 (then only missing packages are installed).
_d_upgrade() {
  _d_unlock || { echo "!! pacman is busy: close the Store / other installers and run: xlin deps"; return 0; }
  _d_say "Updating the system and Xlin-soft's packages (sudo pacman -Syu)"
  sudo pacman -Syu --needed --noconfirm "$@" && return 0
  # one unknown package name must not block the update: upgrade alone, missing ones are installed one by one below
  _d_say "Retrying the update without the package list"
  sudo pacman -Syu --noconfirm || echo "(the system update did not finish; the message above says why)"
}

# xlin_deps [required-only]   returns 0 if everything required is in place
xlin_deps() {
  local mode="${1:-}" need=() failed=() p
  command -v pacman >/dev/null 2>&1 || { echo "(not Arch: install the dependencies yourself, see the README)"; return 0; }
  rm -f "${XDG_RUNTIME_DIR:-/tmp}/xlin-deps-failed"

  mapfile -t need < <(_d_missing "${XLIN_REQUIRED[@]}")
  [[ "$mode" == required-only ]] || { local more; mapfile -t more < <(_d_missing "${XLIN_EXTRA[@]}"); need+=("${more[@]}"); }

  # one wallpaper tool, a terminal font, and a terminal if VTE is unavailable
  command -v awww >/dev/null 2>&1 || command -v swww >/dev/null 2>&1 || command -v hyprpaper >/dev/null 2>&1 || \
    need+=("$(_d_first_in_repo awww swww hyprpaper)")
  if ! fc-list 2>/dev/null | grep -qi 'jetbrains'; then
    need+=("$(_d_first_in_repo ttf-jetbrains-mono-nerd ttf-jetbrains-mono)")
  fi
  mapfile -t need < <(printf '%s\n' "${need[@]}" | sed '/^$/d' | sort -u)

  # update what is installed and add what is missing, in one go (skip: XLIN_NO_UPGRADE=1)
  if [[ -z "${XLIN_NO_UPGRADE:-}" ]]; then
    local all=("${XLIN_REQUIRED[@]}")
    [[ "$mode" == required-only ]] || all+=("${XLIN_EXTRA[@]}")
    all+=("${need[@]}")
    mapfile -t all < <(printf '%s\n' "${all[@]}" | sed '/^$/d' | sort -u)
    _d_upgrade "${all[@]}"
    mapfile -t need < <(_d_missing "${need[@]}")      # only what is still missing
  fi

  if ((${#need[@]})); then
    _d_say "Installing missing packages: ${need[*]}"
    _d_pacman "${need[@]}"
    # anything pacman could not find may be in the AUR
    if [[ -f "${XDG_RUNTIME_DIR:-/tmp}/xlin-deps-failed" ]]; then
      while read -r p; do _d_aur "$p" >/dev/null 2>&1 || failed+=("$p"); done <"${XDG_RUNTIME_DIR:-/tmp}/xlin-deps-failed"
    fi
  fi

  # the dock comes from the AUR on some systems
  if ! command -v nwg-dock-hyprland >/dev/null 2>&1; then
    _d_say "Installing the Run Bar (nwg-dock-hyprland)"
    if pacman -Si nwg-dock-hyprland >/dev/null 2>&1; then _d_pacman nwg-dock-hyprland
    else _d_aur nwg-dock-hyprland || failed+=(nwg-dock-hyprland); fi
  fi
  command -v nwg-dock-hyprland >/dev/null 2>&1 || failed+=(nwg-dock-hyprland)

  # a terminal must always exist
  if ! python3 -c "import gi; gi.require_version('Vte','3.91')" >/dev/null 2>&1; then
    command -v kitty >/dev/null 2>&1 || _d_pacman kitty
  fi
  fc-cache -f >/dev/null 2>&1 || true

  # services that Wi-Fi, Bluetooth and power modes need
  local svc
  for svc in NetworkManager bluetooth power-profiles-daemon; do
    systemctl is-enabled --quiet "$svc" 2>/dev/null && systemctl is-active --quiet "$svc" 2>/dev/null && continue
    sudo systemctl enable --now "$svc" >/dev/null 2>&1 || echo "(could not start $svc)"
  done
  systemctl --user enable --now hyprpolkitagent.service >/dev/null 2>&1 || true

  rm -f "${XDG_RUNTIME_DIR:-/tmp}/xlin-deps-failed"
  if ((${#failed[@]})); then
    printf '\n!! Could not install: %s\n   Try: sudo pacman -Syu   (an old package database causes this), then run: xlin deps\n' "$(printf "%s\n" "${failed[@]}" | sort -u | tr "\n" " ")"
    return 1
  fi
  ((${#need[@]})) || _d_say "All dependencies are already installed"
  return 0
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then xlin_deps "$@"; fi
