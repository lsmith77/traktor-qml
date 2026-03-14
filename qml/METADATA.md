# traktor-qml Integration Metadata

**Prompt version**: v1.0.0
**Last updated**: 2026-03-01
**Traktor version**: 4.4.2
**Controllers**: D2 + X1 MK3 + Z1 MK2

---

## Components

### [1] Baseline — traktor-kontrol-screens (Nexus Edition)

| Field   | Value                                |
| ------- | ------------------------------------ |
| Version | nexus branch @ f0a5027               |
| Status  | APPLIED                              |
| Files   | All files in `qml/` not listed below |

### [2] D2 Stem Mods — traktor-kontrol-d2

| Field          | Value                         |
| -------------- | ----------------------------- |
| Version        | 1                             |
| Tag            | `v0.6.2` (confirmed via git)  |
| Status         | APPLIED                       |
| Files modified | `CSI/Common/Deck_S8Style.qml` |
| Controllers    | D2                            |

**Features added:**

- Pads 1-4: Toggle stem mute (S5-style) when in Stem Mode
- Pads 5-8: Serato-style FX — hold to apply FX effect, release mutes stem
  - Pad 5: Drums Delay+Freeze (Delay on stem 1, single mode)
  - Pad 6: Instrumental Turntable FX (stems 1+2+3, group mode with Beatmasher/Gater)
  - Pad 7: Instrumental Delay+Freeze (Delay on stems 1+2+3, single mode)
  - Pad 8: Vocal Delay+Freeze (Delay on stem 4, single mode)
- **NEW:** Capture button: Toggle all-stems Delay+Freeze lock (toggle on/off, LED indicator)
  - Only active in Stem Mode (configurable via `sfxCaptureFreezeOnlyInStemMode` property)
  - When stem pad pressed, captures freeze automatically ends
- Shift + Pads 1-4: Toggle FX send on/off per stem
- Shift + Pads 5-8: Toggle Filter on/off per stem
- Press Remix button on Stem deck → resets FX units and re-enters Stem Mode
- **NEW (v0.6.0):** Edit button in Stem Mode: Duplicate focused deck to sister deck (A↔C or B↔D)
  - Press: mutes instrumentals on source, triggers duplicate, auto-plays target if source was running
  - Press again (opposing deck playing): stops opposing deck
  - Configured via `duplicateDeckOnlyInStemMode` (set to `false` — works on all deck types)

**FX Unit Configuration:**

Set in Traktor: Preferences > Effects > Effect Units

**Delay Unit (FX Unit 3, Single Mode):**

- Default effect: Delay
- Slot 1: Delay (TIME, FEEDBACK, DEPTH knobs)
- Button 2: Freeze toggle
- Used by Pads 5, 7, 8 and Capture button

**Turntable Unit (FX Unit 4, Group Mode):**

- Slot 1: Beatmasher
- Slot 2: Gater
- Slot 3: Turntable FX (BRK)
- Button 3: BRK trigger; Knob 3: B.SPD
- Used by Pad 6

**To reassign FX units:** Edit `sfxDelayUnit = 3` and `sfxTurntableUnit = 4` properties in `Deck_S8Style.qml`

### [3] X1MK3 Performance Mod

| Field       | Value                     |
| ----------- | ------------------------- |
| Version     | v12                       |
| Tag         | `v12` (confirmed via git) |
| Status      | APPLIED                   |
| Controllers | X1 MK3                    |

**Files replaced** (full replacement, not merged):

- `CSI/X1MK3/X1MK3.qml` (+ metadata header added)
- `CSI/X1MK3/X1MK3Deck.qml`
- `CSI/X1MK3/X1MK3DeviceSetup.qml`
- `CSI/X1MK3/X1MK3FXSection.qml`
- `CSI/X1MK3/X1MK3FXSectionSide.qml`
- `CSI/X1MK3/X1MK3HotcueButtons.qml`
- `CSI/X1MK3/X1MK3Side.qml`
- `CSI/X1MK3/X1MK3TransportButtons.qml`
- `Screens/X1MK3/DeckScreen.qml`
- `Screens/X1MK3/FXScreen.qml`
- `Screens/X1MK3/ModeScreen.qml`

**Files added** (new, not in baseline):

- `Screens/X1MK3/Images/EQMeter_bipolar.png`
- `Screens/X1MK3/Images/EQMeter_unipolar.png`
- `Screens/X1MK3/Images/MasterMeter.png`
- `Screens/X1MK3/Images/Speaker.png`
- `Screens/X1MK3/Images/StemMeter.png`

**Files kept from baseline** (not in mod):

- `CSI/X1MK3/Defines/BrowseEncoderAction.qml`
- `CSI/X1MK3/Defines/DeviceAssignment.qml`
- `CSI/X1MK3/Defines/DeviceSetupState.qml`
- `CSI/X1MK3/Defines/FXSectionLayer.qml`
- `CSI/X1MK3/Defines/HotcueAction.qml`
- `CSI/X1MK3/Defines/qmldir`

**Features included:** See `mods/X1MK3_PerformanceMod/README.md` for full list.
Summary: MODE overlays, 3 setup pages, BPM/beatgrid control, vinyl break, CDJ LEDs, browser mode, mixer overlay, stem superknob, FX section, screen feedback, overmapping support.

---

## Conflict Resolutions

| Conflict                                 | Resolution                                                                                                                                                                                                                             |
| ---------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `Deck_S8Style.qml` version mismatch      | D2 mod based on older baseline; surgically applied only the D2 stem additions to the newer nexus baseline. All nexus-specific features (BPM overlay, sync phase LED, MixerFX overlay, `flux_reverse`, waveform zoom encoder) retained. |
| `CSI/X1MK3/Defines/` not in mod          | Kept from baseline — mod imports these at runtime; they are unchanged.                                                                                                                                                                 |
| FX Unit 4 shared by D2 + X1MK3           | Intentional shared state. X1MK3 FX section can assign/control Unit 4; D2 stem FX also uses Unit 4. Normal workflow: configure Unit 4 presets once, use D2 pads for stem FX and X1MK3 FX buttons for unit selection.                    |
| Timer values (ShowLoopSize, BrowserBack) | Kept nexus baseline values (50ms / 500ms). D2 mod had older values (500ms / 1000ms).                                                                                                                                                   |
| `ScreenViewBlinker` cycle                | Kept nexus baseline (1000ms). D2 mod had 300ms.                                                                                                                                                                                        |
| Remix button wires                       | Kept baseline's `SetPropertyAdapter` approach (cleaner). Extended `enabled` condition to include `DeckType.Stem`. The `updatePads()` chain redirects `remixMode` → `stemMode` for Stem decks automatically.                            |

---

## Testing Checklist

Test in this order (dependencies first):

### Priority 1 — Basic Functionality (test first)

- [ ] Traktor starts without QML errors (check error log)
- [ ] D2 recognized in Preferences > Control Surfaces
- [ ] X1 MK3 recognized in Preferences > Control Surfaces
- [ ] Z1 MK2 recognized in Preferences > Control Surfaces

### Priority 2 — D2 Stem Controls

- [ ] Load a stem track to a D2-assigned deck
- [ ] Press Remix button → pads switch to Stem Mode (blue LED)
- [ ] Pads 1-4 toggle stem mute (Drums/Bass/Melody/Vocals)
- [ ] Press Remix again → pads exit Stem Mode
- [ ] Configure FX Unit 4: Group Mode with Delay T3 / Reverb / Turntable FX
- [ ] Hold Pad 5 → Drums Echo applies, releases mutes Drums
- [ ] Hold Pad 6 → Turntable FX on Instrumental stems
- [ ] Hold Pad 7 → Instrumental Echo
- [ ] Hold Pad 8 → Vocal Echo, releases mutes Vocals
- [ ] Press Pad 5 while Drums muted → unmutes immediately (no FX)
- [ ] Shift + Pad 1-4 → toggles FX send per stem (LED state changes)
- [ ] Shift + Pad 5-8 → toggles Filter per stem (LED state changes)

### Priority 3 — X1MK3 Core Controls

- [ ] MODE single tap → cycles overlays (FX1 → FX2 → Mixer → back)
- [ ] MODE double tap → switches deck pair (AB ↔ CD)
- [ ] MODE hold 1s → enters Setup mode; tap MODE to cycle 3 setup pages
- [ ] Sync hold → shows BPM display temporarily
- [ ] Sync + Loop turn → ±0.01 BPM fine adjust
- [ ] Play hold 0.2s+ → Vinyl Break effect
- [ ] Browse turn → playlist navigation
- [ ] Browse tap → load selected track

### Priority 4 — X1MK3 Advanced Controls

- [ ] Mixer Overlay → knob assignments work (EQ/Volume/Gain/MixerFX)
- [ ] FX Section → arrow buttons switch FX units; knobs control parameters
- [ ] Stem Superknob → turn left = Volume, turn right = High-pass filter
- [ ] Beatgrid: Sync+Play → manual beat tap; Sync+Cue → set grid marker
- [ ] Browser Mode (if enabled in Setup) → Shift+MODE activates
- [ ] Transport LEDs: Play=Green, Sync=Cyan/Red, Cue=Yellow

### Priority 5 — Cross-Controller Interaction

- [ ] D2 Stem Mode + X1MK3 FX Unit 4 controls don't conflict in practice
- [ ] Z1 MK2 mixer controls unaffected by stem pad operations
- [ ] Switching deck pairs on X1 while D2 is in Stem Mode → no crashes

### Edge Cases

- [ ] Load non-stem track to D2 deck → Remix button shows Hotcue/Loop modes normally
- [ ] FX Unit 4 teardown on Stem Mode exit (press non-stem pad mode button)
- [ ] Two D2 controllers (if applicable) → each controls its own deck's stems
- [ ] Traktor restart → sfxGroupModeInitialized resets, re-initializes on first Stem Mode entry

---

## Installation

```bash
# Copy to Traktor 4.4.2
cp -r /Users/lsmith/htdocs/traktor-qml/qml/ \
  ~/Library/Application\ Support/Native\ Instruments/Traktor\ 4.4.2/qml/

# Restart Traktor
```

**Before copying**: backup your existing Traktor qml folder.
