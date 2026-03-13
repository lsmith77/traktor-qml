# Traktor QML — Combined Mod Setup

**Controllers**: D2 + X1 MK3 + Z1 MK2 · **Traktor**: 4.4.2

This `qml/` directory combines the following mods on top of the traktor-kontrol-screens Nexus baseline. See [METADATA.md](METADATA.md) for full version details, conflict resolutions, and a testing checklist.

## Integrated mods

| Mod                                                                                                | Version         | Controllers | Files                                  |
| -------------------------------------------------------------------------------------------------- | --------------- | ----------- | -------------------------------------- |
| [traktor-kontrol-screens Nexus](https://github.com/ErikMinekus/traktor-kontrol-screens/tree/nexus) | nexus @ f0a5027 | All         | Baseline                               |
| [traktor-kontrol-d2 Stem Mods](https://github.com/lsmith77/traktor-kontrol-d2/releases/tag/v0.5.0) | v0.5.0          | D2          | `qml/CSI/Common/Deck_S8Style.qml`      |
| [X1MK3 Performance Mod](https://github.com/lsmith77/X1MK3_PerformanceMod/releases/tag/v12)         | v12             | X1 MK3      | `qml/CSI/X1MK3/`, `qml/Screens/X1MK3/` |

**D2 stem features**: stem mute (pads 1–4), Serato-style FX pads (5–8 → FX Unit 4), shift+pads toggle FX send / filter per stem.

**X1MK3 features**: MODE overlays, 3 setup pages, BPM/beatgrid control, vinyl break, CDJ-style LEDs, browser mode, mixer overlay, stem superknob, screen feedback.

→ Full details, conflict resolutions, and testing checklist: **[METADATA.md](METADATA.md)**

→ Installation guide, mod merging, troubleshooting, and QML API reference: **[Traktor QML Handbook](https://github.com/lsmith77/traktor-kontrol-qml)**

---

## Installation (Traktor 4.4.2, macOS & Windows)

Uses the `traktor-mod` script from the handbook repo. **One-time setup** — see [Chapter 08](https://github.com/lsmith77/traktor-kontrol-qml/blob/main/08_SHARING_CHANGES.md#setup-install-script-to-system-path-one-time-setup) for PATH setup instructions.

```bash
# From this repo directory:
traktor-mod --full
```

This backs up your existing `qml` folder automatically, then installs this combined mod.

**Restore to stock:**

```bash
traktor-mod restore
```

---

## Original baseline README

The content below is from the original traktor-kontrol-screens Nexus README.

---

# Display modifications for the Traktor Kontrol S8/S5/D2

**Changes in appearance:**

- **[Browser]** Keys are only colored if they match the master deck
  - **Yellow**: Perfect match
  - **Orange**: Adjacent keys
  - **Green**: Energy boost
  - **Blue**: Energy drop
- **[Browser]** Loaded tracks are marked green
- **[Browser]** Played tracks are marked dark green
- Added bar markers on large waveform
- Added minute markers on stripe waveform
- Camelot keys
- FX overlay is always large
- Improved FX select
- Improved spacing
- Improved waveform zooming so that more beats are visible
- Spectrum waveform colors
- Track deck header displays beats, remaining time, BPM and tempo

**Changes in functionality:**

- Added sorting by Genre and Release
- Hold Sync to quickly adjust the BPM
- Improved timings
- Press Shift+Flux to engage Flux Reverse
- Press Shift+FX Select to select Mixer FX
- Switched BPM coarse and fine adjustment
- [Track Deck] Use the Browse knob to zoom in and out of the waveform
- [Remix Deck] Use the Browse knob to scroll through pages

See `qml/Defines/Prefs.qml` for preferences.

## Editions

[Kontrol Edition](https://github.com/ErikMinekus/traktor-kontrol-screens/tree/master)\
[Nexus Edition](https://github.com/ErikMinekus/traktor-kontrol-screens/tree/nexus)\
[Prime Edition](https://github.com/ErikMinekus/traktor-kontrol-screens/tree/prime)

## How to install

Use `traktor-mod` — see the [Installation](#installation-traktor-442-macos--windows) section above.

For setup instructions and a full guide to backup, restore, and combining mods, see the **[Traktor QML Handbook](https://github.com/lsmith77/traktor-kontrol-qml)**.

## Screenshots

![Track Deck (Master)](https://ErikMinekus.github.io/traktor-kontrol-screens/nexus/track-deck-master.jpg)
![Track Deck (Sync)](https://ErikMinekus.github.io/traktor-kontrol-screens/nexus/track-deck-sync.jpg)
![Track Deck (Split View)](https://ErikMinekus.github.io/traktor-kontrol-screens/nexus/track-deck-split.jpg)
![Browser](https://ErikMinekus.github.io/traktor-kontrol-screens/nexus/browser.jpg)
