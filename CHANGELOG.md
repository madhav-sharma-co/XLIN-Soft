# Changelog

## 0.1.0 (current: work in progress)
The first version number of Xlin-soft. We stay on 0.1.0 while the system is being finished and tested, and release 0.2.0 when it is fully ready.

- The Launcher opens with Super+Space only. The Super key on its own no longer does anything
- Windows adapt to any size: drag a window's edge, use Super+right-drag, the fullscreen button, or double-click the title bar to fill the screen (and again to go back). The content follows. Settings pages keep a comfortable width and stay centred in a very wide window, and long hints wrap in a narrow one. The floating tools (Calculator, Calendar, Notes, Clock, Screenshot) can be resized too
- Control panel: the buttons now show whether they are on or off, like a phone's control centre. A switched-on button is filled with the accent colour (Wi-Fi, Bluetooth, Airplane, Dark mode, Night light, Do not disturb), a switched-off one stays soft. New Do not disturb button next to Night light. `xlin state <name>` prints true or false for each
- Default pinned apps are only Xlin-soft's own: the desktop has 2 (Files, Terminal), the Run Bar 6 (+ Settings, Store, Media, SysMon) and the Launcher 12 (+ SysDeb, Calculator, Calendar, Notes, Clock, Screenshot). A fresh install gets them, and `xlin reset`, `xlin runbar reset`, `xlin launcher reset` and `xlin pins reset` restore them. Pins you already have are never changed by an update
- The Run Bar no longer disappears when nothing is open and nothing is pinned: it always stays, with the Launcher button
- **Update asks first:** `xlin update`, `update.sh` and Settings → About → Update now ask *Full system update? [y/N]*. **y** updates the whole system and Xlin-soft; **n** (or Enter) updates only Xlin-soft, for limited data (only packages Xlin-soft newly needs are fetched). Skip the question with `xlin update --full` or `xlin update --xlin-only`. With no terminal to ask in, it is Xlin-soft only.
- **Scroll bar on the right:** every Xlin-soft window with long content now has a slim, always-visible scroll bar on its right side (drag it, or click the track) instead of one that only shows while scrolling, as in the control panel.
- **Scrolling is normal now** (moving down scrolls the page down). Xlin-soft sets the direction itself, so a leftover natural-scrolling setting in your own Hyprland config no longer inverts it. **Settings → Desktop → Natural scrolling** switches the phone-style direction on if you want it (`xlin scroll normal|natural`).
- **Smooth scrolling everywhere:** the mouse wheel now glides in every scroll area of every Xlin-soft app instead of jumping in steps (touchpads already scroll smoothly).
- The scroll bar is now in every place that can scroll: the Terminal (drag it to move through the output), the Settings and Files side lists (they scroll when the window is short) and the control panel, besides all the app pages.
- **Apps and Tools** is a new tab in Settings (General stays first, About last). Pick the default app for the terminal, web browser, files and folders, music, video, images, text, PDF and email, like in a phone's settings, and open any Xlin-soft app or tool. Xlin-soft's own Files, Media and Terminal are the defaults after install and `xlin reset` (`xlin defaults list | set | reset`). The old "Terminal" choice in General is gone: Super+Return always opens the Xlin-soft Terminal unless you pick another one here.
- **Battery** in Settings → General: charge level and the power mode (Power saver, Balanced, Performance; needs power-profiles-daemon).
- **Desktop folders and files:**
  - *New folder* now works on every system (the desktop folder is `~/Desktop`, created when needed; before, it was silently missed when no desktop folder was configured).
  - **App folders like on a phone:** drag one app icon onto another and they become a folder; drop more apps on it. One click opens it as a small popup with the apps, the name can be changed there, right-click an app to take it out. Remove the folder and its apps return to the desktop.
  - **Real files and folders:** right-click the desktop, *Add files...* / *Add folders...* (they appear as links, nothing is copied). Drag a file onto a real folder to move it inside, like in Windows. Right-click a file or folder icon to pin it to the Run Bar or Launcher.
  - **Run Bar and Launcher:** *Settings → Launcher* has *Add files and folders* for both (`xlin pinpath runbar|launcher|both <path>`).
  - **Widget transparency** slider in *Settings → Desktop* (changes at once, no restart).
- **Control panel buttons** are now in this order: Wi-Fi, Bluetooth, Airplane, Do not disturb, Dark mode, Night light, Settings and the new **Reload** (restarts Xlin-soft, like `xlin restart`).
- **Wallpapers:** Xlin-soft now ships six plain gradient wallpapers: Light, Dark, Dark Blue, Light Blue, Dark Green and Light Pink (the earlier eight are removed on update; wallpapers you added are never touched). **Settings → Desktop → Wallpapers** shows them as thumbnails: click to use, **Add wallpaper...** for your own pictures, a bin button to remove your own, **Open folder**. From a terminal: `xlin wallpapers list | add | remove | open | path`. The folder is hidden (`~/.config/xlin/wallpapers`); reach it with `cd "$(xlin wallpapers path)"`.
- The Xlin-soft source folder is now **`~/.Xlin-soft`** (hidden, so `ls` does not show it; `ls -a` and `cd ~/.Xlin-soft` still work). Existing clones keep working; `xlin update` finds the old locations too.
- The **X button** on the top bar opens the new **Xlin-soft Manual** (introduction, basics, troubleshooting, who made it) instead of the Launcher (`xlin manual`).
- **Wi-Fi and Bluetooth** on the top bar open small dropdown menus like the battery menu: switch on or off, connect or disconnect with one click, password for new secured networks (`xlin wifi`, `xlin bluetooth`). Right-click the icon for the full Settings page.
- The **Welcome tour** now shows after a fresh install and after `xlin reset` (an old "already welcomed" flag from an earlier install used to hide it).
- Everything listed below was built before the numbers were reset to 0.1.0

## Development history (numbers before the reset)
## 0.62.1
- Workspaces now really slide: Hyprland's own example config sets the workspace "in" and "out" animations to a fade, and those overrode Xlin-soft's slide. Xlin-soft now sets all of them (workspaces, in, out, and the special workspace) to slide

## 0.62.0
- The Launcher, Settings, Files, Store, SysMon and SysDeb now open at once: when a copy is already waiting out of sight, `xlin` asks it to show itself over D-Bus instead of starting Python and GTK again (that start-up was the delay after a click or the Super key)
- Panels (Launcher, control panel) appear a little quicker: shorter arrival and leaving animations

## 0.61.1
- Settings -> About: new Restart button next to Reset. It restarts the bars, control panel, Run Bar and desktop and keeps all your settings

## 0.61.0
- Desktop layer no longer lags or freezes the laptop: the full-screen desktop surface had a blur and an animation on it, which Hyprland redrew every frame; both are gone. It also starts with a lower priority, and a restart waits until the old one has really stopped
- Fixed the desktop disappearing after changing a widget in Settings (it was started again while the old copy was still closing, so it never came back)
- A forgotten right-click menu can no longer block the desktop menu: the next right click closes it, and rofi is now installed with the extras
- `xlin restart` restarts the whole system: top bar, control panel, Run Bar and its watcher, desktop and the waiting apps, each stopped completely before it starts again
- One part at a time: `xlin runbar|bar|panel|desktop|launcher restart` and `... reset` (also `xlin restart <part>`, `xlin reset <part>`). Reset puts only that part back to its defaults

## 0.60.0
- Switching workspaces now feels like paging on a phone: the old workspace slides out and the new one slides in with a long, soft ease-out (the three-finger swipe follows your fingers). New shortcut Super+Alt+Left / Right for the previous / next workspace

## 0.59.1
- Fixed `./update.sh: Permission denied`: install.sh and update.sh had lost their executable bit. `xlin update` now runs the updater with bash, so it works either way. A test now checks the bit

## 0.59.0
- Closing the last window of an app removes its icon from the Run Bar at once (pinned apps keep theirs). The Run Bar watcher now follows opened and closed windows
- Theme, accent and font changes show everywhere at the same time: the bars, panel, Run Bar, GTK apps and terminal refresh together instead of one after another. An accent or font change no longer re-runs the wallpaper transition. The Run Bar restarts without a fixed wait, and the menu icon is only redrawn when its colour changes

## 0.58.1
- install.sh and update.sh now share one list of the files they install (scripts/files.sh), so a new app can no longer be missing from one of them. The test checks that list

## 0.58.0
- SysMon and SysDeb now open at once, like Settings, Files and the Store: they wait out of sight (SysMon does no work while hidden)
- New docs: docs/TESTING.md (a checklist for trying Xlin-soft on a real machine) and docs/RELEASE.md (how to make a release)

## 0.57.0
- After an update, the terminal shows what is new (from this changelog) and a notification confirms the version
- Log files in ~/.cache/xlin are kept small: a log over 1 MB is cut to its last 500 lines at each start

## 0.56.0
- Each panel now arrives its own way: the Launcher rises from the Run Bar, the control panel and notifications slide in from the right, the top bar and Run Bar glide in from their edge, desktop widgets fade. Subtle uses a small pop or fade everywhere. Off (Settings -> Personalization -> Animations) turns all of it off

## 0.55.0
- System Monitor is now SysMon and System Debug is SysDeb (window titles, app entries, menus, README). Settings -> About has shortcut buttons for both, next to Update and Reset

## 0.54.0
- The Launcher opens at once: its app grid is rebuilt only when apps, pins or recent apps changed, not on every open
- Sliders (brightness, volume, window transparency) apply in the background and follow the handle at once, instead of freezing the window while the change is applied
- Settings -> Personalization opens at once: the font list is read in the background when Settings starts and remembered

## 0.53.1
- README install steps: the clone now goes into a folder called Xlin-soft, so `cd Xlin-soft` works. `xlin update` finds the folder under that name too and its hint matches
- New test: every program in bin/ must be installed by install.sh and update.sh and removed by uninstall

## 0.52.0
- Install and update now also update the packages that are already installed (one `pacman -Syu` run, together with the missing ones), not only add missing ones. `XLIN_NO_UPGRADE=1` installs only the missing packages. `xlin deps` does the same

## 0.51.0
- The project is now called Xlin-soft (names, titles, notifications, the README and the licence). The `xlin` command, the config folder, app ids and the cursor theme keep their names, so existing installs and updates keep working. Xlin-advance will be a separate edition later

## 0.50.1
- Auto-lock and night light now stop only the hypridle / hyprsunset that XLIN started itself (pid file + matching arguments). One you run yourself is no longer killed by `xlin idle off|set` or `xlin nightlight off`. Uninstall uses the same check. Regression test added

## 0.50.0
- Apps open faster: the check for the GTK libraries (a Python start-up before every launch) now runs once and is remembered, so a click opens the window at once
- Shorter animations: windows, menus and workspaces now take about half the time (Smooth and Subtle), so nothing feels like it waits

## 0.49.2
- Install and update handle a locked package database: they wait for a running package manager, and remove the lock only when nothing is running (a stale lock after an interrupted install)

## 0.49.1
- Fixed the Hyprland error in xlin-anim.lua: the spring curve is not accepted by Hyprland 0.57. The Smooth animations now use a bezier curve with a small overshoot (same feel)

## 0.49.0
- New animations: windows open with a soft spring (scale up from 88% while fading in), close quickly, workspaces slide and fade, menus and panels pop in gently
- Settings -> Personalization -> Animations: Off / Subtle / Smooth, and `xlin animations off|subtle|smooth`. Off also turns off animations in GTK apps. (Older Hyprland without springs uses matching curves)

## 0.48.0
- Removing a desktop widget (or icon) no longer leaves a stuck ghost on the screen: the right-click menu is fully closed before the widget is deleted. Same fix for the Launcher's app menu
- Font and size changes now fit everywhere: window sizes are no longer fixed by Hyprland rules; each app picks a size that grows with the chosen font size and with its content. The Launcher, desktop widgets, fixed side panels and the control panel scale too
- Dark / light (and the font) now apply at once to every XLIN app, including apps waiting in the background and every right-click menu: they watch the theme file and restyle themselves. Other GTK apps follow too (GTK theme, GTK3/4 settings and the colour scheme)

## 0.47.1
- Fixed the Hyprland error "gesture will be overshadowed by a previous gesture" on top of the screen (Hyprland's example config already has the same three-finger swipe)

## 0.47.0
- Hyprland 0.57 support: it dropped the old hyprland.conf format, so a fresh install showed XLIN's bars but Hyprland's default keys and settings. XLIN now ships a Lua config (config/hypr/xlin.lua, generated colours and opacity as .lua too) and the installer / `xlin hook` detect the Hyprland version, create or extend `hyprland.lua` and keep XLIN loaded last. Older versions keep using hyprland.conf
- Window hide / fullscreen / show-desktop, screen-off (`xlin dpms`), opacity and shortcut repair work on both config kinds
- `xlin start` re-checks the hook at every login, so XLIN's settings are re-applied after a reboot (never reset)
- Tap Super uses Hyprland's modifier-key bind in the Lua config

## 0.46.0
- The App drawer is removed. The Launcher (tap Super, Super+Space or the Run Bar button) now shows Pinned, Recent and a full All apps list below. `xlin drawer` still works and opens the Launcher

## 0.45.1
- Terminal apps (btop, htop...) opened from the Launcher or drawer now open in the XLIN terminal instead of failing with "Unable to find terminal"

## 0.45.0
- App drawer rebuilt from the Launcher's own code: same panel, search box, app cells and colours; narrower and taller , apps only. Right-click an app: Open, Pin / Unpin on the Run Bar, Pin / Unpin in the Launcher
- Launcher footer: Files and Lock buttons removed (name, Settings and Power remain)
- Fixed a broken line in the generated stylesheet

## 0.44.0
- Install and update now install any missing dependency automatically (one shared list in scripts/deps.sh; asks for the password only when something is missing). Falls back to the AUR, retries packages one by one, starts the Wi-Fi/Bluetooth/power services
- New command: `xlin deps` repairs missing packages any time

## 0.43.0
- Tap the Super key: opens the Launcher (Start menu). Super+Space opens the App drawer. (A tap is ignored when Super was just part of another shortcut)
- App drawer uses the Launcher's own app style (same icons, names and highlight, six per row), not a different one
- Pins are separate now: right-click an app (in the drawer or the Launcher) for Open, Pin / Unpin on the Run Bar, and Pin / Unpin in the Launcher. The Launcher's Pinned area shows what you pinned there; Settings -> Launcher lists both

## 0.42.0
- App drawer now looks like the Launcher (same panel, same height, "All apps" title with a Back button, same bottom row with your name, Files, Settings, Lock and Power) with a phone-style grid: every app icon sits on a soft rounded tile
- Fix: `xlin restart` (and so every update) also restarts the apps that wait out of sight, so a new Launcher, drawer, Settings, Files or Store shows up straight away instead of the old one

## 0.41.1
- Fix: clicking the Run Bar button while the App drawer (or Launcher) is open closed and re-opened it; now it just closes
- Fix: the Clock tool and the Apps and widgets window had no app icon on the Run Bar (an orange X)
- Right-clicking the desktop restarts the desktop layer if it had stopped (at most once a minute)
- `xlin doctor` also checks gtk4-layer-shell, polkit, playerctl and whether the desktop layer is running; the installer adds polkit, playerctl and the media codecs

## 0.41.0
- Show desktop (Super+Shift+D, `xlin showdesktop`): hides every window on the workspace, again brings them back
- Touchpad: three fingers left/right switch workspace, up opens the Launcher, down shows the desktop
- README rewritten to match everything XLIN does now

## 0.40.0
- Desktop: right-click now opens a short menu (Apps and widgets, New folder, wallpaper, View, Terminal, Files, Settings) that fits any screen; View holds the icon options
- New "Apps and widgets" gallery (right-click the desktop): widget cards with previews and Add / Remove, and an app list with Add / Remove
- `xlin desktop status` and a Status row with a Restart button on Settings -> Desktop say whether the desktop layer is running and why not

## 0.39.0
- App drawer redesigned: A-Z grid of every app with larger icons and a rounded search pill, in the same shape and place as the Launcher
- Right-click an app in the drawer for Open, Pin to the Run Bar or Unpin from the Run Bar (Alt+P and Alt+U still work)

## 0.38.0
- New tool: Clock (Tools menu, `xlin tools clock`): current time with six time zones, a stopwatch with laps, and a timer with presets or your own minutes that notifies when done

## 0.37.0
- Store: search also shows AUR packages when yay or paru is installed. Installing one opens a terminal so you can review it first; removing works like any other app

## 0.36.0
- Control Panel now matches the plan: a close button (top right), Wi-Fi / Bluetooth / Airplane / Theme / Night light / Settings buttons, volume and brightness sliders, and a Power mode row (Saver, Balanced, Performance)

## 0.35.0
- The Launcher and the App drawer are part of "Keep apps ready" too: they wait out of sight, so Super+Space and the Run Bar drawer button show them at once (and the same key hides them again)

## 0.34.0
- Settings -> About -> Reset XLIN settings (and `xlin reset`): theme, accent, bars, desktop widgets, fonts and options go back to the defaults; wallpaper, pinned apps and your files are kept

## 0.33.0
- Apps open instantly: Settings, Files and the Store start out of sight a few seconds after you log in, and closing them only hides them, so the next click shows them at once. Switch it off in Settings -> General ("Keep apps ready") or with `xlin warm off`; it is skipped automatically when memory is low

## 0.32.0
- Fonts and sizes: Settings -> Personalization has a system font, text size (small to huge), terminal font and terminal text size. Command line: `xlin font <name>`, `xlin font size large`, `xlin font reset`
- Fix: the window buttons in Settings were unstyled (Settings now loads the XLIN theme)

## 0.31.0
- New app: SysDebug (`xlin debug`): health checks, logs (this session, Hyprland and every XLIN app), one-click repairs (restart XLIN, fix shortcuts, restart the desktop layer) and a report you can copy into a bug report

## 0.30.0
- New app: XLIN Media (`xlin media`), a music and video player. Open files or a folder, drop files on it, Space plays and pauses, arrow keys skip; it also shows up in "Open with" for audio and video

## 0.29.0
- New app: XLIN Store (`xlin store`, or find it in the App drawer). Featured apps by category, search all packages, see what you installed, and check updates. Install and Remove ask for your password through the system prompt (needs polkit); "Update everything" runs in XLIN Terminal

## 0.28.0
- Settings reorganised into seven sections: General (volume, brightness, notifications, sleep, terminal), Connectivity (airplane mode, Wi-Fi, Bluetooth), Desktop (icons, widgets, wallpaper, cursor), Status Bar and Run Bar, Launcher and App Drawer (manage pinned apps), Personalization (theme, accent, transparency, wallpaper) and About
- New: Do not disturb switch, airplane mode switch, widget and icon-size switches for the desktop
- Old page names still work (`xlin settings wifi`, `sound`, `appearance`, ...)

## 0.27.0
- The Launcher is now a Start menu (Super+Space, or the X button): search, your pinned apps, recent apps, and buttons for Files, Settings, Lock and Power. "All apps" opens the App drawer
- The App drawer (`xlin drawer`, the grid of every app) is on the Run Bar's drawer button; Alt+P / Alt+U still pin and unpin there

## 0.26.2
- Fix: the fullscreen button is now real fullscreen, exactly like Super+F
- Fix: the hide button hides the window it belongs to (not whichever is focused); Super+H brings back the last hidden window, `xlin unhide all` brings back every one
- Top bar: the current-app name shows "Files" instead of "dev.xlin.Files"; clicking the date and time opens the Calendar

## 0.26.1
- Lock screen shows the battery level (top right) next to the time, date, name and password field
- The app drawer has a close button (panels only get a close button)

## 0.26.0
- Every XLIN app window (Settings, Files, Monitor, Terminal, Welcome, Calculator, Calendar, Notes, Screenshot) now has the same three buttons in its top corner: hide, fullscreen, close. The Tools menu stays a plain dropdown
- Hide moves the window out of sight; Super+H (or `xlin unhide`) brings hidden windows back
- Smoother panel animations (control panel, drawer and menus fade and pop in instead of sliding)

## 0.25.1
- App drawer matched to the old rofi look: DM Sans fonts, exact width and row height, always five columns, highlight follows the mouse, fixed 78px distance from the screen edge

## 0.25.0
- The app drawer is now XLIN's own (`xlin-launcher`, GTK + layer-shell) and no longer needs rofi: same look, same place above the Run Bar, same search, pinned/recent first, arrows + Enter, Alt+P pin, Alt+U unpin, Esc or a click outside closes
- rofi is optional now (installer and `xlin doctor`); it is only a fallback if the drawer cannot start, and is still used by the clipboard and shortcut pickers
- New: `xlin launch-app <id>`

## 0.24.0
- Desktop: icons and widgets now drag smoothly (one gesture on the whole desktop, so the pointer no longer jitters), lift with a shadow while moving, are kept on screen and glide into their grid cell when dropped
- New widgets: Battery, Media player (needs playerctl), Notes (shows recent notes, add a quick note), To-do list, Timer (with notification)
- Files and folders in ~/Desktop now appear as icons (double-click to open, right-click to Move to Trash)
- Desktop menu: New folder, Show desktop icons, Small / Medium / Large icons, Arrange icons; click an icon to select it

## 0.23.1
- Fix: Settings -> About -> Update XLIN did nothing when Kitty was not installed. It now opens XLIN Terminal (and falls back to foot, alacritty, gnome-terminal, konsole or xterm)
- Kitty is no longer required: the installer only installs it if XLIN Terminal cannot run, and `xlin doctor` checks XLIN Terminal instead

## 0.23.0
- Settings: new Bars page (show or hide the Settings, Tools, Wi-Fi, Bluetooth, Sound, Battery, Power and Control panel buttons on the top bar; Run Bar auto-hide and icon size) and a General page (desktop menu and widgets, cursor size, terminal choice, auto-lock and delay, night light)
- The bottom bar is now called the Run Bar everywhere (Settings, Welcome, README); `xlin runbar` is the command (`xlin dock` still works)
- Tab completion knows the new commands

## 0.22.0
- Calculator, Calendar and Notes now open in the middle of the screen (the Tools menu itself stays under the top bar); extra tools open a little offset so they do not hide each other
- New tool in the Tools menu: Screenshot (select an area, a window or the whole screen, with an optional 3 or 5 second delay, and a button for the Screenshots folder)

## 0.21.1
- Fix: copies and new zip files were numbered after the extension ("Archive.zip 2"); now "Archive 2.zip"
- Fix: Files restore from Trash gives a clear message when the trash record is missing
- Fix: if ImageMagick is missing, the theme wallpaper and the lock screen fall back to a built-in wallpaper instead of a missing file
- Fix: the installer no longer fails when the optional terminal / desktop packages (vte4, gtk4-layer-shell) or the USB / network packages are unavailable; they install one by one

## 0.21.0
- Terminal: search the scrollback (Ctrl+Shift+F), Ctrl+click links, a + button and x on tabs, Ctrl+scroll to zoom, drop files to paste their paths, Ctrl+Shift+N for a new window in the same folder

## 0.20.0
- Right-click the desktop for a menu: Add app shortcut, Widgets (clock, calendar, system), Next wallpaper / Choose picture, Terminal, Files, Settings
- Desktop shortcut icons (double-click to open, right-click to remove) and widgets, drag to arrange; positions are remembered in ~/.config/xlin/desktop.json
- New: `xlin desktop on|off|restart` (needs gtk4-layer-shell, installed by the installer)

## 0.19.0
- New app: XLIN Terminal (VTE): tabs (Ctrl+Shift+T), XLIN colours and font that follow `xlin theme`, copy/paste menu, text zoom. Super+Return / Super+T open it; `xlin term [-d folder] [-e cmd]` from the command line
- `xlin terminal use kitty` switches back to Kitty; Kitty is also the automatic fallback if VTE is missing

## 0.18.0
- New app: XLIN Monitor (Super+M, or `xlin monitor`): CPU, memory, disk and network cards, and a live list of your apps with End / Force quit
- Fix: the Welcome window rule was still the old size, so the new wallpaper page was cut off

## 0.17.0
- Welcome: new "Pick a wallpaper" page with thumbnails (and your own picture), a final "You're all set" page, and visible error messages instead of silent failures
- Fix: changing the wallpaper right after install could do nothing (the wallpaper daemon was not ready yet). XLIN now waits for it, supports old and new hyprpaper, and reports the real error

## 0.16.0
- Eight built-in wallpapers (light: dawn, mist, lagoon, blossom; dark: midnight, nebula, ember, forest). Super+W / Settings -> Appearance -> Next cycles through them; `scripts/make-wallpapers.py` redraws them

## 0.15.0
- Proper icons for XLIN's own apps (Settings, Files, Notes, Calculator, Calendar, Tools, Welcome, Power): the dock and launcher show them instead of the orange X. `scripts/make-icons.py` redraws them

## 0.14.0
- Own mouse cursor: XLIN (dark, for the light desktop) and XLIN-Dark (white, for the dark desktop), rounded with a soft shadow, accent-blue busy spinner. Follows the theme switch automatically; `xlin cursor 24|32|48|64` changes the size
- `scripts/make-cursors.py` redraws the cursors (Pillow only)

## 0.13.1
- Fix: update.sh wrote a damaged install-folder record, so Settings -> About -> Update XLIN said it needed a git install. It is repaired, and `xlin update` now also finds a clone in the usual places (~/XLIN, ~/Downloads/XLIN ...)

## 0.13.0
- XLIN Files: "Connect to server..." opens network folders (smb://, sftp://, ftp://, dav://); asks for a password in a window when needed (gvfs is installed by the installer)

## 0.12.0
- XLIN Files: right-click -> Open with... (pick an app, optionally make it the default for that file type)
- XLIN Files: right-click -> Extract here (zip, tar.*, 7z, rar, iso) and Compress to .zip

## 0.11.0
- XLIN Files: USB drives and other removable disks appear under "Drives" in the sidebar; click to mount and open, ⏏ to safely remove (needs udisks2, installed by the installer)

## 0.10.0
- `xlin update` and `xlin update check`; Settings -> About shows the version and has an Update XLIN button

## 0.9.3
- Fix: the Settings Appearance page did not open (missing accent colour row code)
- Screenshots: clear "Screenshot taken, saved in Pictures/Screenshots" notification, and a failure notification with the reason

## 0.9.2
- Shortcuts can no longer be taken over by another config: the installer and `./update.sh` put the XLIN line last in hyprland.conf (`xlin hook`)
- `xlin keys check` shows every XLIN shortcut and what it does now; `xlin keys fix` repairs clashes (also runs at login)
- `xlin doctor` checks the shortcuts
- GTK apps request Gdk 4.0 explicitly (no more warnings)

## 0.9.1
- XLIN Files: picture thumbnails, right-click menu

## 0.9.0
- XLIN Files: search, copy/cut/paste, drag and drop, Trash restore

## 0.8.0
- XLIN Files: browse, rename, new folder, trash

## 0.7.0
- Notes tool (plain .md files), quick note (Super+Shift+N)

## 0.6.0
- Accent colours, first-run Welcome tour, `xlin uninstall`, fuller `xlin doctor`

## 0.5.0
- Screenshots, volume/brightness popup, auto-lock, night light, clipboard history

## 0.4.0
- XLIN CLI: wifi, bluetooth, sound, brightness, battery, status, help, tab completion
- Lock screen, power menu, battery menu, mnemonic shortcuts

## 0.1 - 0.3
- Top bar, launcher, dock, control panel, Settings, Tools (calculator, calendar), XLIN Terminal
