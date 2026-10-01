# Autostart config

Makes Slack + Teams for Linux launch on login, both pinned to workspace 3, with Slack on
monitor 2 and Teams on monitor 3 (the two docked monitors) so they never overlap.

This folder **is** `~/.config/autostart`. On a new machine, clone it there.

## New machine? Just run this

```bash
git clone <this-repo-url> ~/.config/autostart
cd ~/.config/autostart
./setup.sh
```

Then **log out and back in** (or reboot), and run `gnome-extensions enable smart-auto-move@khimaros.com`
if `setup.sh` said the shell had not discovered it yet.

### One-time monitor placement

Smart Auto Move *learns* positions, it can't be told "Slack -> monitor 2". After first login on a
new machine, drag Slack to monitor 2 and Teams to monitor 3 (both on workspace 3) once. It remembers
per monitor connector, so docking/undocking restores them.

## What `setup.sh` installs, in case it breaks

```bash
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub com.slack.Slack
flatpak install flathub com.github.IsmaelMartinez.teams_for_linux
sudo dnf install gnome-shell-extension-auto-move-windows
gnome-extensions enable auto-move-windows@gnome-shell-extensions.gcampax.github.com
dconf load /org/gnome/shell/extensions/auto-move-windows/ < dconf/auto-move-windows.ini
# Smart Auto Move: download from extensions.gnome.org (id 4736), then
gnome-extensions install --force smart-auto-move.zip
dconf load /org/gnome/shell/extensions/smart-auto-move/ < dconf/smart-auto-move.ini
```

None of this exists on a fresh Fedora install — that's the whole reason `setup.sh`
exists instead of just copying `.desktop` files.

## Files

- `*.desktop` — autostart entries (Slack, Teams, Ptyxis)
- `dconf/auto-move-windows.ini` — the "which app goes to which workspace" rule
- `dconf/smart-auto-move.ini` — which apps get their monitor/position restored (Slack, Teams only)
- `setup.sh` — installs everything above, safe to re-run
- `docs/monitor-placement.md` — full write-up: how monitor placement works, why, monitor
  names, debugging commands, and fallbacks
