# Autostart config

This repo *is* `~/.config/autostart` — GNOME's per-user autostart directory. Clone it
directly to that path on a new machine (it'll merge with/replace whatever's already
there).

## What's tracked here

| File | Does what |
| --- | --- |
| `com.slack.Slack.desktop` | Launches Slack (flatpak) on login |
| `com.github.IsmaelMartinez.teams_for_linux.desktop` | Launches Teams for Linux (flatpak) on login |
| `org.gnome.Ptyxis.desktop` | Ptyxis terminal autostart entry (installed by the Ptyxis package itself, not hand-authored) |
| `my-startup.desktop` | **Currently broken** — points at `~/automation_scripts/startup.py`, which does not exist on this machine. Either recreate that script or delete this entry. |
| `dconf/auto-move-windows.ini` | Dump of the GNOME "Auto Move Windows" extension's workspace-pinning rules (see below) — **not a `.desktop` file**, GNOME ignores it, it's just backed up here for `setup.sh` to restore |
| `setup.sh` | Re-applies everything below on a fresh machine |

## Why this doesn't "just work" from a fresh Fedora install

Dropping these `.desktop` files into `~/.config/autostart` is not sufficient by
itself. Three things live outside this directory and won't exist on a clean Fedora
Workstation box:

1. **Flathub isn't enabled by default.** Fedora ships Flatpak, but the Flathub remote
   has to be added explicitly:
   ```
   flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
   ```

2. **The apps themselves aren't installed.** Each `.desktop` file's `Exec=` line
   shells out to `flatpak run --command=... <app-id>` — if the app isn't installed,
   autostart silently fails (no error dialog, it just never opens).
   ```
   flatpak install flathub com.slack.Slack
   flatpak install flathub com.github.IsmaelMartinez.teams_for_linux
   ```

3. **The workspace pinning (desktop 3) depends on a GNOME Shell extension that is
   its own RPM, separate from base GNOME**, and it's disabled by default even once
   installed:
   ```
   sudo dnf install gnome-shell-extension-auto-move-windows
   gnome-extensions enable auto-move-windows@gnome-shell-extensions.gcampax.github.com
   ```
   The actual rule mapping app → workspace lives in **dconf**, not in a file GNOME
   reads from this directory — that's why it's dumped separately into
   `dconf/auto-move-windows.ini` and has to be reloaded explicitly:
   ```
   dconf load /org/gnome/shell/extensions/auto-move-windows/ < dconf/auto-move-windows.ini
   ```
   This mapping is keyed by the app's exact `.desktop` file id (e.g.
   `com.slack.Slack.desktop:3`). If a flatpak app id ever changes, or you install
   the Slack/Teams client a different way (native package, Snap, etc. instead of
   flatpak), the id in this file won't match and the window will silently stay on
   whatever workspace it opened on instead of jumping to 3.

`setup.sh` runs all of the above. It's idempotent — safe to re-run.

## Fresh-machine setup

```
git clone <this-repo-url> ~/.config/autostart
cd ~/.config/autostart
./setup.sh
```

Then log out and back in (or reboot) — GNOME reads `~/.config/autostart` at session
start, and the Auto Move Windows extension needs a Shell restart to pick up newly
enabled state.

## Known gaps

- `my-startup.desktop` is dangling (see table above) — not fixed here, flagging it
  so it doesn't get silently copied to a new machine as if it worked.
- There's also a disabled, unused GNOME Shell extension called `window-placer@local`
  installed locally (`~/.local/share/gnome-shell/extensions/window-placer@local`) that
  looks like an earlier/alternate attempt at the same window-placement idea. It's
  disabled and not part of this setup — left alone, not tracked here, since it lives
  outside `~/.config/autostart`.
- No verification here that Slack/Teams' *windows* actually respect the pin the
  first time they're ever launched on a new machine — Auto Move Windows moves a
  window when the app creates it, so this should work the first time, but it's only
  been proven on this machine after the app was already installed.
