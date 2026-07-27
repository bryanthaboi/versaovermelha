# VersãoVermelha

Brazilian Portuguese, ripped from the **Hyd~Traduções Pokémon Versão
Vermelha v1.3.1** IPS patch rather than translated by hand.

Generated with `python3 tools/modkit.py translation versaovermelha`, then filled
by rom hack exports.

2796 strings register at boot. Everything unfilled falls through to
English, so this is playable at every point along the way.

Some missing wont make for a terrible experience, and itll do for now!

## What is not translated, and why

**138 dialogue lines.** Label recovery follows `TX_FAR` records out of map
scripts. A few labels are reached another way and have no recoverable
counterpart; a few more decode to bytes the port's text model cannot
represent.

## Layout

- `manifest.json` - identity and the engine version range
- `main.lua` - registers whatever is filled in and skips whatever is not
- `lang/` - the catalogs
- `assets/font/latin.png` - the accented glyph page, base `0x100`
- `overrides/` - any obvious sprite diffs
