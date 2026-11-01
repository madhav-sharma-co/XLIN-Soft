#!/usr/bin/env bash
# Which kind of update? Used by update.sh (and so by `xlin update` and Settings -> About -> Update).
#   full  = the whole system and every Xlin-soft package (pacman -Syu): big download
#   xlin  = only Xlin-soft itself (for people with limited data); only packages Xlin-soft newly needs are fetched
# Decided by, in this order: --full / --xlin-only (or -y / -n), XLIN_NO_UPGRADE=1, XLIN_FULL_UPGRADE=1,
# then by asking (Enter = Xlin-soft only). With no terminal to ask in, it is Xlin-soft only.

xlin_update_mode() {
  local a mode="" ans=""
  for a in "$@"; do
    case "$a" in
      --full|-y|--yes) mode=full ;;
      --xlin-only|--only|-n|--no) mode=xlin ;;
    esac
  done
  [[ -z "$mode" && -n "${XLIN_NO_UPGRADE:-}" ]] && mode=xlin
  [[ -z "$mode" && -n "${XLIN_FULL_UPGRADE:-}" ]] && mode=full
  if [[ -z "$mode" ]]; then
    if [[ -t 0 && -t 1 ]]; then
      printf '\033[1;34m==>\033[0m Do you want a full system update?\n' >&2
      printf '    y = update the whole system and Xlin-soft (bigger download)\n' >&2
      printf '    n = update only Xlin-soft (small, good for limited data)\n' >&2
      read -r -p "    Full system update? [y/N] " ans || ans=""
      case "${ans,,}" in y|yes) mode=full ;; *) mode=xlin ;; esac
    else
      mode=xlin
    fi
  fi
  echo "$mode"
}
