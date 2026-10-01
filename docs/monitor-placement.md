# Slack + Teams monitor placement

**Goal:** on login, Slack and Teams open on workspace 3, on the two docked monitors, never
overlapping and never on the laptop screen.

**Setup:** Fedora, GNOME Shell 49, Wayland. Both apps are Flatpaks.

## Monitors (2026-10-01)

| Name | Connector | Notes |
|---|---|---|
| Monitor 1 | `eDP-1` | Laptop screen, primary |
| Monitor 2 | `DVI-I-1` | Dell 2560x1440 |
| Monitor 3 | `DVI-I-2` | Dell 2560x1440 |

Connectors can change with the dock. List them:
`gdbus call --session --dest org.gnome.Mutter.DisplayConfig --object-path /org/gnome/Mutter/DisplayConfig --method org.gnome.Mutter.DisplayConfig.GetCurrentState`

## How it works

| Piece | Job |
|---|---|
| `*.desktop` autostart entries | Launch the apps on login |
| Auto Move Windows | Pins each app to workspace 3 (`dconf/auto-move-windows.ini`) |
| Smart Auto Move | Remembers each app's monitor, size and position, and restores them (`dconf/smart-auto-move.ini`) |

Smart Auto Move **learns** where you put a window. You can't tell it "Slack goes to monitor 2",
so place the apps by hand once. After that it remembers them.

Settings: default `IGNORE` (other apps untouched), `RESTORE` for Slack and Teams only, loose title
matching (`threshold 0.2`) because both apps change their window titles all the time.

Window classes the rules match on:
- Slack: `com.slack.Slack`
- Teams: `com.github.IsmaelMartinez.teams_for_linux`

## Current state

| App | Monitor | Workspace | State |
|---|---|---|---|
| Slack | `DVI-I-1` | 3 | maximized |
| Teams | `DVI-I-2` | 3 | maximized |

Not yet tested across a logout/login. Add the date here once it's confirmed.

## Why not something simpler

- `wmctrl` / `xdotool` only work on X11, not native Wayland windows.
- Neither app has a monitor or position flag. Chromium's `--window-position` is ignored on Wayland.
- Auto Move Windows only picks a workspace, never a monitor.

## Debugging

```bash
# Is it loaded?
gnome-extensions info smart-auto-move@khimaros.com

# Which windows and classes does it see?
gdbus call --session --dest org.gnome.Shell --object-path /org/gnome/shell/extensions/SmartAutoMove \
  --method org.gnome.shell.extensions.SmartAutoMove.ListWindows

# What did it save?
GSETTINGS_SCHEMA_DIR=~/.local/share/gnome-shell/extensions/smart-auto-move@khimaros.com/schemas \
  gsettings get org.gnome.shell.extensions.smart-auto-move saved-windows
```

| Problem | Fix |
|---|---|
| "Extension does not exist" after install | Log out and back in (Wayland only discovers new extensions at login) |
| App opens in the wrong place | Check its class with `ListWindows`; make sure it has an override |
| Wrong monitor after a dock change | Connector names changed; move the apps once more |
| Nothing is restored | App needs a `RESTORE` override, because the default is `IGNORE` |

## If Smart Auto Move stops working

1. [Window State Manager](https://extensions.gnome.org/extension/5353/window-state-manager/)
2. [automove-display](https://github.com/De1tago/automove-display): fixed monitor per app
3. A small custom extension (an unfinished one is at `~/.local/share/gnome-shell/extensions/window-placer@local`, not in this repo)

## Loose ends

- The Teams `.desktop` file has an uncommitted edit (likely written by the Flatpak autostart portal). Check Teams still launches on login before committing it.
- `dconf/smart-auto-move.ini` lists extra guessed class names. Only the two above matter; the rest can go.
