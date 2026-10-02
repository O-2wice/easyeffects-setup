# Adding a preset

The easiest way: [open a "Share a preset" issue](https://github.com/O-2wice/easyeffects-setup/issues/new?template=share-a-preset.yml) and drop the file in. I'll add it and credit you.

If you prefer a pull request:

1. In EasyEffects, open Presets > Local, click the export button next to the name box and pick a folder.
2. Copy your preset's `.json` into `presets/output/`. Name it `Group - Name.json` if one of the groups fits (`Mood`, `Laptop`, `Headphones`, `Bass`, `Speakers`...), or start a new group.
3. If it uses an impulse response, add the `.irs` file to `presets/irs/` with the same name the preset refers to.
4. Open the PR and tick the checklist.

Good presets work for most people: they don't clip, and they aren't tuned to one specific speaker unless the name says so. Presets you made go in under GPL-3.0. Someone else's need a licence that allows sharing, plus a row in [CREDITS.md](CREDITS.md).
