# Autostart config

Makes Slack + Teams for Linux launch on login, both pinned to workspace 3.

This folder **is** `~/.config/autostart`. On a new machine, clone it there.

## New machine? Just run this

```bash
git clone <this-repo-url> ~/.config/autostart
cd ~/.config/autostart
./setup.sh
```

Then **log out and back in** (or reboot).

## What `setup.sh` installs, in case it breaks

```bash
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub com.slack.Slack
flatpak install flathub com.github.IsmaelMartinez.teams_for_linux
sudo dnf install gnome-shell-extension-auto-move-windows
gnome-extensions enable auto-move-windows@gnome-shell-extensions.gcampax.github.com
dconf load /org/gnome/shell/extensions/auto-move-windows/ < dconf/auto-move-windows.ini
```

None of this exists on a fresh Fedora install — that's the whole reason `setup.sh`
exists instead of just copying `.desktop` files.

## Files

- `*.desktop` — autostart entries (Slack, Teams, Ptyxis)
- `dconf/auto-move-windows.ini` — the "which app goes to which workspace" rule
- `setup.sh` — installs everything above, safe to re-run

## Known issue

`my-startup.desktop` is broken — points at a script that no longer exists
(`~/automation_scripts/startup.py`). Ignore it or delete it.
