#!/usr/bin/env bash
# Restores this autostart setup on a fresh Fedora GNOME install.
# Idempotent — safe to re-run.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

echo "==> Adding Flathub remote (if missing)"
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo "==> Installing required flatpak apps"
flatpak install -y --noninteractive flathub com.slack.Slack
flatpak install -y --noninteractive flathub com.github.IsmaelMartinez.teams_for_linux

echo "==> Installing GNOME 'Auto Move Windows' extension (not installed by default on Fedora Workstation)"
sudo dnf install -y gnome-shell-extension-auto-move-windows

echo "==> Enabling the extension"
gnome-extensions enable auto-move-windows@gnome-shell-extensions.gcampax.github.com || \
  echo "WARNING: could not enable via CLI (may need a GNOME Shell restart / re-login first). Enable it manually in the Extensions app."

echo "==> Restoring workspace-pinning (dconf) settings"
dconf load /org/gnome/shell/extensions/auto-move-windows/ < dconf/auto-move-windows.ini

echo "==> Installing 'Smart Auto Move' (remembers which monitor each app lives on)"
SAM_UUID=smart-auto-move@khimaros.com
SAM_ZIP="$(mktemp --suffix=.zip)"
SAM_URL="https://extensions.gnome.org$(curl -fsS "https://extensions.gnome.org/extension-info/?pk=4736&shell_version=$(gnome-shell --version | grep -oE '[0-9]+' | head -1)" | python3 -c 'import sys,json; print(json.load(sys.stdin)["download_url"])')"
curl -fsSL -o "$SAM_ZIP" "$SAM_URL"
gnome-extensions install --force "$SAM_ZIP"
rm -f "$SAM_ZIP"
gnome-extensions enable "$SAM_UUID" || \
  echo "NOTE: Shell has not discovered $SAM_UUID yet - it will load after you log out and back in."
dconf load /org/gnome/shell/extensions/smart-auto-move/ < dconf/smart-auto-move.ini

echo "==> Done. This script assumes it's being run from inside ~/.config/autostart"
echo "    (i.e. this repo was cloned directly to that path) so the .desktop files"
echo "    are already in place. Log out and back in (or reboot) for autostart +"
echo "    workspace placement to take effect."
