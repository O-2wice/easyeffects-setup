# easyeffects-setup

Presets and a small always-on setup for EasyEffects 8 (Flatpak) on Linux with PipeWire.

## What's in it

- `presets/output/`: 75 output presets.
  - `Mood - *`: 23 everyday curves (Chill, Rock, Jazz, Late Night, Bass Boost and so on). Each ends in a limiter, so nothing clips.
  - `Laptop - *`: 9 presets for small laptop speakers (high-pass plus virtual bass).
  - The rest are community presets, credited in [CREDITS.md](CREDITS.md).
- `presets/irs/`: 15 impulse responses used by the headphone and surround presets.
- `systemd/easyeffects.service`: keeps EasyEffects running and restarts it if it stops.
- `bin/ee8-keep-effects.sh`: when EasyEffects restarts on the same speaker, keeps the effects you added instead of letting Autoload reset them.
- Optional: `ee8-bt-mirror` plays to two Bluetooth speakers at once, and `ee8-volume-follow` keeps their volumes in step.

## Install

```sh
git clone https://github.com/O-2wice/easyeffects-setup
cd easyeffects-setup
./install.sh
```

It installs EasyEffects from Flathub if needed and copies the presets and the service. Presets and settings you already have are not overwritten. To give each speaker its own preset, use Presets > Autoload in the app.

For the two Bluetooth speaker extras:

```sh
systemctl --user enable --now ee8-bt-mirror.service ee8-volume-follow.service
```

## Licence

GPL-3.0, see [LICENSE](LICENSE). Community presets keep their own licences, listed in [CREDITS.md](CREDITS.md) with the texts in [licenses/](licenses/).
