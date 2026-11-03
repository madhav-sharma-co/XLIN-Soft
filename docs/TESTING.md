# Testing Xlin-soft on a real machine

Use a fresh Arch Linux install (a virtual machine is fine) with Hyprland and a normal user.

## Install
1. `git clone https://github.com/madhav-sharma-co/XLIN-Soft.git ~/.Xlin-soft && cd ~/.Xlin-soft && bash install.sh`
2. Log out and back in. Check: top bar, Run Bar, wallpaper, cursor, no red error line from Hyprland.
3. `xlin doctor` shows no MISSING line.

## Every day
- Press Super+Space: Launcher opens at once; the Super key alone does nothing. Type a name, press Enter. Right-click an app: pin and unpin.
- Super+S Settings, Super+E Files, Super+M SysMon, Super+C control panel, Super+Return Terminal.
- Settings -> Personalization: dark mode, accent, font and size (nothing is cut off), Animations Off / Subtle / Smooth.
- Drag the brightness, volume and transparency sliders: smooth, no freezing.
- Right-click the empty desktop: menu opens; add and remove a widget (no ghost left behind).
- Settings -> About: Check again, Update, SysMon, SysDeb, Reset.

## The apps
- Media: open a song and a video (double-click in Files, and from Media's Open). Video plays, F or double-click is full screen, Esc leaves it. Resize the window small and wide; the controls wrap. `~/.cache/xlin/media.log` stays empty.
- Xedit: open a text file and a `.py` file (colours), edit, find and replace (Ctrl+F / Ctrl+H), save, close with unsaved changes (it asks).
- Xview: open a picture, next/previous in the folder, zoom, rotate, slideshow (Space), full screen, trash.
- Xread: open a PDF, scroll, search (Ctrl+F), contents (B), night mode (N), a password-protected PDF.
- Xman (X on the top bar): all tabs. Welcome (`xlin welcome`): every page, and Open Settings.
- Screenshot tool: the chosen delay is highlighted; Include pointer, Copy only and Open afterwards work.
- SysDeb: Run checks, then Fix everything on a machine with a package removed (e.g. remove `jq`); it comes back.

## Power
- Leave the laptop alone for 5 minutes: the screen locks, then the laptop sleeps. Wake it: lock screen, then desktop.
- Settings -> Sleep after: change to 10 min and to Never; `xlin idle status` agrees.
- Play a video in the browser: the laptop must not sleep during it.

## Update and uninstall
- `git pull && ./update.sh`: installs missing packages, shows "What's new", nothing breaks.
- Run `./update.sh` twice: the second run changes nothing.
- `xlin uninstall`: your own Hyprland, Waybar and Kitty configs are back, the desktop still works.
- Put your own `hypridle` or `hyprsunset` running, then `xlin idle off` and `xlin nightlight off`: yours keeps running.

`bash tests/test-*.sh` (and `python3 tests/test-desktop-folders.py`) run on any machine, no display needed. They are the same checks CI runs.

Report anything odd with the output of `xlin doctor` and the files in `~/.cache/xlin/`.
