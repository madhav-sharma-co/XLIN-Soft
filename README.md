<div align="center">

# Xlin-soft

**A calm, clean desktop for Hyprland on Arch Linux.**
Light and dark themes, glass panels, smooth animations, and a complete set of its own apps.

[![License: MIT](https://img.shields.io/badge/licence-MIT-blue.svg)](LICENSE)
![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793d1?logo=archlinux&logoColor=white)
![Hyprland](https://img.shields.io/badge/Hyprland-0.53%2B_(Lua%20ready)-58e1ff)

<img width="1366" height="768" alt="Xlin-soft desktop, light theme" src="https://github.com/user-attachments/assets/bc88359e-5beb-4298-af17-064a573082b5" />
<img width="1366" height="768" alt="Xlin-soft desktop, dark theme" src="https://github.com/user-attachments/assets/ff2e9042-aa86-46ce-9401-deab74657cf6" />

</div>

## Highlights

- **One install, everything set up.** The installer and every update bring the system and all packages Xlin-soft needs up to date (`pacman -Syu`) and install the missing ones, hook Xlin-soft into your Hyprland config and apply the theme. New dependencies arrive by themselves. To install only what is missing, run with `XLIN_NO_UPGRADE=1`.
- **Its own apps.** Settings, Files, Terminal, Store, Media, SysMon, Notes, Clock, Calendar, Calculator, Screenshot, Welcome and a debug tool, all in one look.
- **Light and dark, everywhere.** One switch (Super+D) restyles every Xlin-soft app, every menu, the bars, the lock screen and other GTK apps, at once.
- **Smooth.** Gentle window, menu and workspace animations (Off, Subtle or Smooth in Settings). Settings, Files, Store and the Launcher wait out of sight, so they open instantly.
- **Flexible.** Change the system font or text size and every window, panel and widget grows to fit.
- **Works with current Hyprland.** Hyprland 0.55+ with the Lua config (the only format from 0.57) and older versions with `hyprland.conf` are both supported.

## Install

    git clone https://github.com/madhav-sharma-co/XLIN.git ~/.Xlin-soft
    cd ~/.Xlin-soft
    ./install.sh          # asks for your password to install packages
    hyprctl reload        # or log out and back in
    xlin doctor           # shows anything missing

Run it as your normal user, not root. The installer backs up the Waybar, swaync and Hyprland
files it changes and installs whatever is missing (from the Arch repositories, and the AUR when
you have `paru` or `yay`).

**Update:** open **Settings → About → Update Xlin-soft**, or run `xlin update`. By hand:

    cd ~/.Xlin-soft && git pull && bash update.sh

**Update packages and repair missing ones at any time:** `xlin deps`

**Remove Xlin-soft** (your old Waybar, swaync and Kitty configs are put back): `xlin uninstall`

## What you get

| Piece           | What it does |
|-----------------|--------------|
| Lock screen     | Your blurred wallpaper, time, date, battery, name and password (Super+L). Locks by itself when idle, and the laptop sleeps after 5 minutes without activity (changeable in Settings) |
| Top bar         | X (Xlin-soft Manual), current app, settings, tools, Wi-Fi and Bluetooth (click for a quick connect menu), sound, battery, date and time, power and control panel. Every button can be hidden |
| Launcher        | Super+Space: search, pinned apps, recent apps and the full All apps list. Right-click an app: Open, pin to the Run Bar, pin to the Launcher |
| Run Bar         | The bottom bar with pinned and running apps and the Launcher button. It is always there, even with nothing open. Starts with six Xlin-soft apps pinned (the Launcher has twelve, the desktop two); `xlin pins reset` brings the defaults back |
| Control panel   | Wi-Fi, Bluetooth, airplane mode, dark mode, night light and do not disturb (switched-on buttons are filled with the accent colour), volume, brightness, power mode and notifications (Super+C) |
| Desktop folders | Drag an app onto another to make a folder (one click opens it), add real files and folders from the right-click menu, drop a file onto a folder to move it in. Files and folders can also be pinned to the Run Bar and Launcher. Widget transparency is in Settings → Desktop |
| Wallpapers      | Six gradients (Light, Dark, Dark Blue, Light Blue, Dark Green, Light Pink). Add your own or remove them in **Settings → Desktop → Wallpapers**, or with `xlin wallpapers` |
| Desktop         | Right-click for the **Apps and widgets** gallery (clock, calendar, system, battery, media, notes, to-do, timer), new folder, wallpaper and icon size. Files in `~/Desktop` show up too |
| Settings        | General, Connectivity, Desktop, Status Bar and Run Bar, Launcher, Personalization (theme, accent, fonts, text size, animations, opacity, wallpaper, cursor), About (update, reset) |
| Tools           | Clock, Calendar, Calculator, Notes and Screenshot as small floating windows (Super+U) |
| Apps            | Terminal with tabs, Files, SysMon, Media player, Store (pacman and AUR) and SysDeb (checks, logs, repairs) |
| Windows         | Every app has hide, fullscreen and close buttons, can be resized by its edge or Super+right-drag, and fills the screen on a double-click of its title bar. Super+H brings hidden windows back, Super+Shift+D shows the desktop |
| Look and feel   | Light and dark, accent colours, system font and size, Xlin-soft cursor and icons, eight wallpapers (Super+W), animations on or off |
| Daily basics    | Screenshots, clipboard history, night light, quick notes, volume and brightness pop-ups |

## Keys

Press **Super+/** or run `xlin keys` to see them all. Every key is the first letter of what it does.

| Keys | Action | Keys | Action |
|------|--------|------|--------|
| Super+Space | Launcher | Super+Q | Quit (close) window |
| Super+Return, Super+T | Terminal | Super+F | Fullscreen |
| Super+E | Files (Explorer) | Super+Shift+F | Floating on / off |
| Super+S | Settings | Super+H | Bring back hidden windows |
| Super+C | Control panel | Super+Shift+D | Show the desktop |
| Super+U | Utilities (tools) | Alt+Tab | Next window |
| Super+M | SysMon | Super+arrows | Move focus |
| Super+N | Notes (Shift: quick note) | Super+Shift+arrows | Move the window |
| Super+B | Battery and power mode | Super+Ctrl+arrows | Resize the window |
| Super+L | Lock | Super+drag | Move (left) / resize (right) |
| Super+P | Power menu | Super+1..4 | Go to workspace |
| Super+Alt+←/→ | Previous / next workspace | Super+Scroll | Next / previous workspace |
| Super+D | Dark / light | Super+Shift+1..4 | Send window to workspace |
| Super+W | Next wallpaper | Super+scroll | Next / previous workspace |
| Super+V | Clipboard history | Print / Shift / Alt | Screenshot: area / screen / window |
| Super+Shift+Q | Log out | 3-finger swipe | Left, right: workspace. Up: Launcher. Down: show desktop |

## Command line

    xlin help                         everything, with help for each command
    xlin status                       one-screen overview
    xlin theme light|dark|toggle      xlin accent teal      xlin opacity 0.85
    xlin font <name>                  xlin font size small|normal|large|huge
    xlin animations off|subtle|smooth
    xlin wifi | bluetooth | sound | brightness | battery
    xlin bar show|hide settings|tools|wifi|...      xlin runbar autohide on|off
    xlin wallpaper next|<image>       xlin cursor 24|32|48|64
    xlin screenshot | clipboard | idle | nightlight | lock | session
    xlin store | media | debug | showdesktop | unhide | warm on|off
    xlin update [check]               xlin deps       xlin doctor
    xlin restart | reset              everything
    xlin runbar|bar|panel|desktop|launcher restart | reset     one part only
    xlin uninstall

Tab completion works in the Xlin-soft terminal.

## Requirements

Arch Linux (or an Arch-based distribution) with Hyprland. The installer takes care of everything
else: Waybar, swaync, hyprlock, hypridle, gtk4-layer-shell, vte4, NetworkManager, BlueZ, PipeWire,
grim, slurp, cliphist and the rest of the list in [`scripts/deps.sh`](scripts/deps.sh).
The Run Bar uses `nwg-dock-hyprland` (AUR; installed for you when `paru` or `yay` is present).

## Hyprland versions

- **0.55 and newer** read the Lua config. The installer adds `pcall(require, "xlin")` as the last
  line of `~/.config/hypr/hyprland.lua` (backup kept) and creates the file if it is missing.
  Hyprland 0.57 no longer reads `hyprland.conf`.
- **Older versions** keep using `hyprland.conf` with a `source` line for `xlin.conf`.

Shortcuts not working? Run `xlin hook`, then `hyprctl reload`.

## Troubleshooting

| Problem | Try |
|---------|-----|
| Something is missing | `xlin doctor`, then `xlin deps` |
| Shortcuts do nothing | `xlin hook` and `hyprctl reload`, then `xlin keys check` |
| An app looks old after an update | `xlin restart` (waiting apps are replaced) |
| One part misbehaves (Run Bar, bar, panel, desktop, Launcher) | `xlin runbar restart` (or `bar`, `panel`, `desktop`, `launcher`); `reset` puts that part back to its defaults |
| Slow first open of an app | Keep apps ready is on by default: `xlin warm on` |
| Anything else | SysDeb (`xlin debug`) shows checks and logs. Logs are in `~/.cache/xlin/` |

## Project layout

    bin/         the xlin command and the Xlin-soft apps (GTK4, Python)
    lib/         code shared by the apps
    config/      Hyprland (Lua and conf), Waybar, swaync, Kitty, shell and app launchers
    templates/   theme files with colour placeholders, filled in by `xlin theme`
    themes/      the light and dark palettes
    scripts/     dependency installer, icon, wallpaper and cursor generators
    assets/      cursors, icons, wallpapers
    install.sh   first install      update.sh   update without reinstalling

## Contributing and licence

See [CONTRIBUTING.md](CONTRIBUTING.md) and the [CHANGELOG](CHANGELOG.md). Xlin-soft is released under
the MIT licence ([LICENSE](LICENSE)).
