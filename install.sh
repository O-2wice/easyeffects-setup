#!/usr/bin/env bash
# Install the presets and the always-on EasyEffects service for the current user.
# Existing presets and settings are never overwritten.
set -euo pipefail

APP=com.github.wwmm.easyeffects
HERE=$(cd "$(dirname "$0")" && pwd)
EE=~/.var/app/$APP
UNITS=~/.config/systemd/user

if ! flatpak info "$APP" >/dev/null 2>&1; then
    echo "Installing EasyEffects from Flathub..."
    flatpak install -y flathub "$APP"
fi

mkdir -p "$EE/data/easyeffects/output" "$EE/data/easyeffects/irs" \
         "$EE/config/easyeffects/db" ~/.local/bin "$UNITS/easyeffects.service.d"

cp -n "$HERE"/presets/output/*.json "$EE/data/easyeffects/output/"
cp -n "$HERE"/presets/irs/*.irs "$EE/data/easyeffects/irs/"

# EasyEffects rewrites its settings from memory, so only seed them when absent.
if [ -e "$EE/config/easyeffects/db/easyeffectsrc" ]; then
    echo "Kept your existing EasyEffects settings. See config/easyeffectsrc.db for the ones this setup uses."
else
    cp "$HERE/config/easyeffectsrc.db" "$EE/config/easyeffects/db/easyeffectsrc"
fi

install -m 755 "$HERE"/bin/*.sh ~/.local/bin/
cp "$HERE"/systemd/*.service "$UNITS/"
cp "$HERE"/systemd/easyeffects.service.d/*.conf "$UNITS/easyeffects.service.d/"

systemctl --user daemon-reload
systemctl --user enable --now easyeffects.service

echo "Done. To give each speaker its own preset: EasyEffects > Presets > Autoload."
