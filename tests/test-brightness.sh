#!/usr/bin/env bash
# The screen never goes fully black (1% minimum), and the volume can be muted with a click.
set -u
cd "$(dirname "$0")/.."
ROOT="$PWD"; T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
export HOME="$T/home" XLIN_HOME="$T/home/.config/xlin"
mkdir -p "$XLIN_HOME/state" "$HOME/bin"
fail=0
chk() { if eval "$2"; then echo "ok: $1"; else echo "FAIL: $1"; fail=1; fi; }

# fake brightnessctl on a screen with 255 steps; state kept in a file, percent steps like the real one
cat >"$HOME/bin/brightnessctl" <<'EOS'
#!/usr/bin/env bash
f="$HOME/bright"; [[ -f $f ]] || echo 128 >"$f"
max=255; cur=$(<"$f"); args=("$@"); q=0; m=0
for a in "${args[@]}"; do [[ $a == -q ]] && q=1; [[ $a == -m ]] && m=1; done
if ((m)); then echo "dev,backlight,$cur,$((cur*100/max))%,$max"; exit 0; fi
for i in "${!args[@]}"; do
  if [[ ${args[$i]} == set ]]; then
    v="${args[$((i+1))]}"
    case "$v" in
      *%+) n=$(( cur + ${v%\%+}*max/100 )) ;;
      *%-) n=$(( cur - ${v%\%-}*max/100 )) ;;
      *%)  n=$(( ${v%\%}*max/100 )) ;;
      *)   n=$v ;;
    esac
    ((n<0)) && n=0; ((n>max)) && n=max; echo "$n" >"$f"
  fi
done
EOS
chmod +x "$HOME/bin/brightnessctl"; export PATH="$HOME/bin:$PATH"
X="bash $ROOT/bin/xlin"

echo 10 >"$HOME/bright"
$X brightness down 50 >/dev/null
chk "down never reaches 0 (raw $(cat $HOME/bright))"  "[[ \$(cat $HOME/bright) -ge 3 ]]"
$X brightness set 1 >/dev/null
chk "set 1 stays at 1% or more"        "[[ \$(cat $HOME/bright) -ge 3 ]]"
echo 0 >"$HOME/bright"; $X brightness up 0 >/dev/null
chk "a black screen is lifted to 1%"   "[[ \$(cat $HOME/bright) -ge 3 ]]"
$X brightness set 50 >/dev/null
chk "normal values are untouched"      "[[ \$(cat $HOME/bright) -eq 127 ]]"

chk "panel slider minimum is 1"        "python3 -c \"import json;assert json.load(open('config/swaync/config.json'))['widget-config']['backlight']['min']==1\""
chk "panel has a mute button"          "python3 -c \"import json;d=json.load(open('config/swaync/config.json'));assert 'buttons-grid#sound' in d['widgets'];assert d['widgets'].index('buttons-grid#sound')<d['widgets'].index('volume')\""
chk "bar volume middle-click mutes"    "grep -A9 '\"pulseaudio\"' config/waybar/config.jsonc | grep -q '\"on-click-middle\": \"xlin sound toggle\"'"
chk "Settings slider goes through xlin" "grep -q '\"xlin\", \"brightness\", \"set\"' bin/xlin-settings"

# muted state
cat >"$HOME/bin/wpctl" <<'EOS'
#!/usr/bin/env bash
[[ "$1" == get-volume ]] && cat "$HOME/vol"
[[ "$1" == set-mute ]] && { grep -q MUTED "$HOME/vol" && echo "Volume: 0.50" >"$HOME/vol" || echo "Volume: 0.50 [MUTED]" >"$HOME/vol"; }
exit 0
EOS
chmod +x "$HOME/bin/wpctl"; echo "Volume: 0.50" >"$HOME/vol"
chk "state muted: false first"         "[[ \$($X state muted) == false ]]"
$X sound toggle >/dev/null
chk "state muted: true after toggle"   "[[ \$($X state muted) == true ]]"
$X sound toggle >/dev/null
chk "state muted: false again"         "[[ \$($X state muted) == false ]]"
$X silent on >/dev/null
chk "silent on mutes"                  "[[ \$($X state silent) == true ]]"
$X silent toggle >/dev/null
chk "silent toggle unmutes"            "[[ \$($X state silent) == false ]]"
$X silent toggle >/dev/null
chk "silent toggle mutes again"        "[[ \$($X state silent) == true ]]"
chk "panel silent button is a small round one" "python3 -c \"import json;a=json.load(open('config/swaync/config.json'))['widget-config']['buttons-grid#sound'];assert a['buttons-per-row']>=4 and len(a['actions'])==1 and a['actions'][0]['command']=='xlin silent toggle'\""
chk "Super+T is Tools, Return is the terminal" "grep -q 'run(\"SUPER + T\", \"xlin tools\")' config/hypr/xlin.lua && ! grep -q 'SUPER + T\", terminal' config/hypr/xlin.lua && grep -q 'bind  = SUPER, T, exec, xlin tools' config/hypr/xlin.conf && grep -q 'bind  = SUPER, Return, exec, \$terminal' config/hypr/xlin.conf && ! grep -q 'SUPER, T, exec, \$terminal' config/hypr/xlin.conf"
exit $fail
