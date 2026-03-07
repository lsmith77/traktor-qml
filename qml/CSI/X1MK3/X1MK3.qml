// =============================================================================
// INTEGRATION METADATA — prompt v1.0.0 — last updated 2026-03-01
// =============================================================================
//
// Components integrated into this qml/ directory:
//
//   [1] traktor-kontrol-screens (Nexus Edition)
//       Version : nexus branch @ f0a5027
//       Source  : https://github.com/lsmith77/traktor-kontrol-qml
//       Role    : Baseline — stock CSI/Screens for all controllers
//       Status  : APPLIED
//
//   [2] traktor-kontrol-d2 Stem Mods
//       Version : v0.4.0
//       Source  : https://github.com/lsmith77/traktor-kontrol-d2/releases/tag/v0.4.0
//       Role    : Adds stem mute pads, Serato-style FX pads, shift-pad filter/send toggles
//       Files   : CSI/Common/Deck_S8Style.qml (surgical merge — baseline kept as base)
//       Status  : APPLIED
//       Controllers: D2
//
//   [3] X1MK3 Performance Mod
//       Version : v12
//       Source  : https://github.com/lsmith77/X1MK3_PerformanceMod/releases/tag/v12
//       Role    : Replaces all CSI/X1MK3/ files + Screens/X1MK3/ files
//       Files   : CSI/X1MK3/{X1MK3,X1MK3Deck,X1MK3DeviceSetup,X1MK3FXSection,
//                 X1MK3FXSectionSide,X1MK3HotcueButtons,X1MK3Side,X1MK3TransportButtons}.qml
//                 Screens/X1MK3/{DeckScreen,FXScreen,ModeScreen}.qml
//                 Screens/X1MK3/Images/{EQMeter_bipolar,EQMeter_unipolar,MasterMeter,Speaker,StemMeter}.png
//                 CSI/X1MK3/Defines/ kept from baseline (not included in mod)
//       Status  : APPLIED
//       Controllers: X1 MK3
//
// Application order:
//   Step 1: Baseline (APPLIED)
//   Step 2: D2 Stem Mods v0.4.0 (APPLIED — surgical edits to Deck_S8Style.qml)
//   Step 3: X1MK3 Performance Mod v12 (APPLIED — full replacement of X1MK3 files)
//
// Conflict resolutions:
//   - Deck_S8Style.qml: D2 mod was based on older baseline; applied only the D2
//     stem-specific additions; all nexus branch improvements (BPM overlay, sync phase,
//     MixerFX overlay, flux_reverse, waveform zoom) retained from baseline.
//   - CSI/X1MK3/Defines/: Not in X1MK3 mod; kept from baseline (unchanged).
//   - FX Unit 4: Shared by D2 stem FX and X1MK3 FX section — intentional.
//   - Timer values: Baseline nexus values kept (50ms ShowLoopSize, 500ms BrowserBack).
//
// See METADATA.md at qml/ root for full details and testing checklist.
// =============================================================================

import CSI 1.0
import QtQuick 2.0

import "Defines"

Mapping
{
  id: mapping
  readonly property string propertiesPath: "mapping.state"
  // readonly property string settingsPath: "mapping.settings"

  X1MK3 { name: "surface" }

  X1MK3DeviceSetup {
    id: deviceSetup;
    name: "device_setup";

    surface: "surface";
    propertiesPath: mapping.propertiesPath
    shift: shiftProp.value
    // settingsPath: mapping.settingsPath
  }

  onRunningChanged:
  {
    // When the mapping is reloaded go back into device setup
    deviceSetup.reset();
    // deviceSetup.resetOverlayOvermapping();
  }

  KontrolScreen { name: "screen"; side: ScreenSide.Left; propertiesPath: mapping.propertiesPath; flavor: ScreenFlavor.X1MK3_Mode }
  Wire { from: "screen.output"; to: "surface.display.mode" }

  // Custom Settings
  // MappingPropertyDescriptor { id: lastTouchedButtonLeftSideProp; path: "mapping.state.left.fx.last_active_button"; type: MappingPropertyDescriptor.Integer; value: 0 }
  // MappingPropertyDescriptor { id: lastTouchedButtonRightSideProp; path: "mapping.state.right.fx.last_active_button"; type: MappingPropertyDescriptor.Integer; value: 0 }
  MappingPropertyDescriptor {
    id: lastTouchedButtonLeftSideProp
    path: "mapping.state.left.fx.last_active_button"
    type: MappingPropertyDescriptor.Integer
    value: 0
    min: 0
    max: 20
  }
  
  MappingPropertyDescriptor {
    id: lastTouchedButtonRightSideProp
    path: "mapping.state.right.fx.last_active_button"
    type: MappingPropertyDescriptor.Integer
    value: 0
    min: 0
    max: 20
  }

  MappingPropertyDescriptor {
    id: deckAssignmentProp
    path: "mapping.settings.deck_assignment"
    type: MappingPropertyDescriptor.Integer
    value: DeviceAssignment.decks_a_b
    min: DeviceAssignment.decks_a_b
    max: DeviceAssignment.decks_a_c
    onValueChanged: {
      lastTouchedButtonLeftSideProp.value = 0
      lastTouchedButtonRightSideProp.value = 0
      if (value == DeviceAssignment.decks_a_b) customDeckSwitchAcVariantProp.value = false
      else if (value == DeviceAssignment.decks_c_d) customDeckSwitchAcVariantProp.value = false
      else if (value == DeviceAssignment.decks_c_a) customDeckSwitchAcVariantProp.value = false
      else if (value == DeviceAssignment.decks_a_c) customDeckSwitchAcVariantProp.value = true

      if (fxMode.value == FxMode.TwoFxUnits) fxAssignmentProp.value = DeviceAssignment.fx_1_2
      else if (customLinkFXOverlayToDeckProp.value) fxAssignmentProp.value = value

      deviceSetup.resetOverlayOvermapping()
    }
  }

  MappingPropertyDescriptor {
    id: fxAssignmentProp
    path: "mapping.settings.fx_assignment"
    type: MappingPropertyDescriptor.Integer
    value: DeviceAssignment.fx_1_2
    min: DeviceAssignment.fx_1_2
    max: DeviceAssignment.fx_1_3
    onValueChanged: {
      lastTouchedButtonLeftSideProp.value = 0
      lastTouchedButtonRightSideProp.value = 0
      deviceSetup.resetOverlayOvermapping()
    }
  }

  MappingPropertyDescriptor {
    id: customDeckSwitchAcVariantProp
    path: "mapping.settings.custom_deck_switch_ac_variant"
    type: MappingPropertyDescriptor.Boolean
    value: false
  }


  // MIXER SETTINGS
  
  MappingPropertyDescriptor {
    id: customKnobAssignmentEqHigh
    path: "mapping.settings.custom_mixer_eq_high_knob_assignment"
    type: MappingPropertyDescriptor.Integer
    value: 1 // Knobs 1 to 4, 0 = not assigned
    min: 0
    max: 4
  }

  MappingPropertyDescriptor {
    id: customLayerAssignmentEqHigh
    path: "mapping.settings.custom_mixer_eq_high_knob_layer_assignment"
    type: MappingPropertyDescriptor.Integer
    value: 0 // 0 = both layers, 1 = noShift layer, 2 = Shift layer
    min: 0
    max: 2
  }

  MappingPropertyDescriptor {
    id: customKnobAssignmentEqMid
    path: "mapping.settings.custom_mixer_eq_mid_knob_assignment"
    type: MappingPropertyDescriptor.Integer
    value: 2 // Knobs 1 to 4, 0 = not assigned
    min: 0
    max: 4
  }

  MappingPropertyDescriptor {
    id: customLayerAssignmentEqMid
    path: "mapping.settings.custom_mixer_eq_mid_knob_layer_assignment"
    type: MappingPropertyDescriptor.Integer
    value: 0 // 0 = both layers, 1 = noShift layer, 2 = Shift layer
    min: 0
    max: 2
  }

  MappingPropertyDescriptor {
    id: customKnobAssignmentEqMidLow
    path: "mapping.settings.custom_mixer_eq_midlow_knob_assignment"
    type: MappingPropertyDescriptor.Integer
    value: 0 // Knobs 1 to 4, 0 = not assigned
    min: 0
    max: 4
  }

  MappingPropertyDescriptor {
    id: customLayerAssignmentEqMidLow
    path: "mapping.settings.custom_mixer_eq_midlow_knob_layer_assignment"
    type: MappingPropertyDescriptor.Integer
    value: 0 // 0 = both layers, 1 = noShift layer, 2 = Shift layer
    min: 0
    max: 2
  }

  MappingPropertyDescriptor {
    id: customKnobAssignmentEqLow
    path: "mapping.settings.custom_mixer_eq_low_knob_assignment"
    type: MappingPropertyDescriptor.Integer
    value: 3 // Knobs 1 to 4, 0 = not assigned
    min: 0
    max: 4
  }

  MappingPropertyDescriptor {
    id: customLayerAssignmentEqLow
    path: "mapping.settings.custom_mixer_eq_low_knob_layer_assignment"
    type: MappingPropertyDescriptor.Integer
    value: 0 // 0 = both layers, 1 = noShift layer, 2 = Shift layer
    min: 0
    max: 2
  }

  MappingPropertyDescriptor {
    id: customKnobAssignmentVolume
    path: "mapping.settings.custom_mixer_volume_knob_assignment"
    type: MappingPropertyDescriptor.Integer
    value: 4 // Knobs 1 to 4, 0 = not assigned
    min: 0
    max: 4
  }

  MappingPropertyDescriptor {
    id: customLayerAssignmentVolume
    path: "mapping.settings.custom_mixer_volume_knob_layer_assignment"
    type: MappingPropertyDescriptor.Integer
    value: 0 // 0 = both layers, 1 = noShift layer, 2 = Shift layer
    min: 0
    max: 2
  }

  MappingPropertyDescriptor {
    id: customKnobAssignmentGain
    path: "mapping.settings.custom_mixer_gain_knob_assignment"
    type: MappingPropertyDescriptor.Integer
    value: 0 // Knobs 1 to 4, 0 = not assigned
    min: 0
    max: 4
  }

  MappingPropertyDescriptor {
    id: customLayerAssignmentGain
    path: "mapping.settings.custom_mixer_gain_knob_layer_assignment"
    type: MappingPropertyDescriptor.Integer
    value: 0 // 0 = both layers, 1 = noShift layer, 2 = Shift layer
    min: 0
    max: 2
  }

  MappingPropertyDescriptor {
    id: customKnobAssignmentMixerFx
    path: "mapping.settings.custom_mixer_fx_knob_assignment"
    type: MappingPropertyDescriptor.Integer
    value: 0 // Knobs 1 to 4, 0 = not assigned
    min: 0
    max: 4
  }

  MappingPropertyDescriptor {
    id: customLayerAssignmentMixerFx
    path: "mapping.settings.custom_mixer_fx_knob_layer_assignment"
    type: MappingPropertyDescriptor.Integer
    value: 0 // 0 = both layers, 1 = noShift layer, 2 = Shift layer
    min: 0
    max: 2
  }

  MappingPropertyDescriptor {
    id: customMixerOverlayBlockProp
    path: "mapping.settings.custom_mixer_overlay_block"
    type: MappingPropertyDescriptor.Boolean
    value: false
    onValueChanged: {
      if (fx_section.layer == FXSectionLayer.mixer) {
        fx_section.layer = FXSectionLayer.fx_primary
      }
    }
  }
  
  
  // BROWSER SETTINGS

  MappingPropertyDescriptor {
    id: customBrowserModeProp
    path: "mapping.settings.custom_browser_mode"
    type: MappingPropertyDescriptor.Boolean
    value: false
  }
  MappingPropertyDescriptor {
    id: maximizeBrowserWhenBrowsingProp
    path: "mapping.settings.maximize_browser_when_browsing"
    type: MappingPropertyDescriptor.Boolean
    value: false
  }
  MappingPropertyDescriptor {
    id: minimizeBrowserWhenLoadingProp
    path: "mapping.settings.minimize_browser_when_loading"
    type: MappingPropertyDescriptor.Boolean
    value: false
  }
  
  
  // BEAT COUNTER
  
  MappingPropertyDescriptor {
    id: deckDisplayMainInfoProp;
    path: "mapping.settings.deck_display.main_info";
    type: MappingPropertyDescriptor.Integer;
    value: 0 /* Remaining Time Display*/
  }
  MappingPropertyDescriptor {
    id: customBeatCounterEngagedProp
    path: "mapping.settings.custom_beatcounter_engaged"
    type: MappingPropertyDescriptor.Boolean
    value: false
  }
  MappingPropertyDescriptor {
    id: customBeatCounterPhraseLengthProp
    path: "mapping.settings.custom_phrase_length"
    type: MappingPropertyDescriptor.Integer
    value: 2 // 1, 2, 4, 8, 16, 32, 64 beats
    min: 0 // off, i.e. 'bars.beats' instead of 'phrases.bars.beats'
    max: 6 // 64 beats
  }


  // MISCELLANEOUS SETTINGS
  
  MappingPropertyDescriptor {
    id: customDeckSwitchOnSingleClickProp
    path: "mapping.settings.custom_deck_switch_on_single_click"
    type: MappingPropertyDescriptor.Boolean
    value: false
  }
  
  MappingPropertyDescriptor {
    id: customSingleCueMonitorProp
    path: "mapping.settings.custom_single_cue_monitor"
    type: MappingPropertyDescriptor.Boolean
    value: false
  }
  MappingPropertyDescriptor {
    id: customSubchannelMuteSendFXProp
    path: "mapping.settings.custom_subchannel_mute_send_fx"
    type: MappingPropertyDescriptor.Boolean
    value: false
  }
  MappingPropertyDescriptor {
    id: customCueAndPlayProp
    path: "mapping.settings.custom_cue_and_play"
    type: MappingPropertyDescriptor.Boolean
    value: false
  }
  MappingPropertyDescriptor {
    id: customInvertMixerFxLedProp
    path: "mapping.settings.custom_invert_mixerfx_led"
    type: MappingPropertyDescriptor.Boolean
    value: false
  }
  
  MappingPropertyDescriptor {
    id: customOvermappingEngagedProp
    path: "mapping.settings.custom_overmapping_engaged"
    type: MappingPropertyDescriptor.Boolean
    value: false
    onValueChanged: {
      if (value) {
        remixPageDeckA.value = 3
        remixPageDeckB.value = 3
      }
      else {
        remixPageDeckA.value = 0
        remixPageDeckB.value = 0
      }
    }
  }
  
  
  // EFFECTS
  
  MappingPropertyDescriptor {
    id: customFxAssignmentsUnitFocusProp
    path: "mapping.settings.custom_fx_assignments_unit_focus"
    type: MappingPropertyDescriptor.Boolean
    value: false
  }
  MappingPropertyDescriptor {
    id: customLinkFXOverlayToDeckProp
    path: "mapping.settings.custom_link_fx_overlay_to_deck"
    type: MappingPropertyDescriptor.Boolean
    value: false
    onValueChanged: {
      if (value == true) {
        if (fxMode.value == FxMode.TwoFxUnits) {
          fxAssignmentProp.value = DeviceAssignment.fx_1_2
        }
        else if (fxAssignmentProp.value != deckAssignmentProp.value) fxAssignmentProp.value = deckAssignmentProp.value
        if (fx_section.layer == FXSectionLayer.fx_secondary) {
          fx_section.layer = FXSectionLayer.fx_primary
        }
      }
    }
  }
  MappingPropertyDescriptor {
    id: customSecondaryFXOverlayBlockProp
    path: "mapping.settings.custom_secondary_fx_overlay_block"
    type: MappingPropertyDescriptor.Boolean
    value: false
    onValueChanged: {
      if (fx_section.layer == FXSectionLayer.fx_secondary) {
        fx_section.layer = FXSectionLayer.fx_primary
      }
    }
  }


  AppProperty { id: remixPageDeckA; path: "app.traktor.decks.1.remix.page"; }
  AppProperty { id: remixPageDeckB; path: "app.traktor.decks.2.remix.page"; }
  
  AppProperty { id: clockBPMProp; path: "app.traktor.masterclock.tempo" }
  MappingPropertyDescriptor {
    id: masterClockTempoMultiplierProp
    path: "mapping.settings.master_clock_blink_multiplier"
    type: MappingPropertyDescriptor.Float
    value: 1.0 // (120 / clockBPMProp.value)
  }

  // AppProperty {
    // id: cueMonitorChannelProp1;
    // path: "app.traktor.mixer.channels.1.cue";
    // onValueChanged: {
      // if (value && customSingleCueMonitorProp.value) {
        // cueMonitorChannelProp2.value = false;
        // cueMonitorChannelProp3.value = false;
        // cueMonitorChannelProp4.value = false;
      // }
    // }
  // }
  // AppProperty {
    // id: cueMonitorChannelProp2;
    // path: "app.traktor.mixer.channels.2.cue";
    // onValueChanged: {
      // if (value && customSingleCueMonitorProp.value) {
        // cueMonitorChannelProp1.value = false;
        // cueMonitorChannelProp3.value = false;
        // cueMonitorChannelProp4.value = false;
      // }
    // }
  // }
  // AppProperty {
    // id: cueMonitorChannelProp3;
    // path: "app.traktor.mixer.channels.3.cue";
    // onValueChanged: {
      // if (value && customSingleCueMonitorProp.value) {
        // cueMonitorChannelProp1.value = false;
        // cueMonitorChannelProp2.value = false;
        // cueMonitorChannelProp4.value = false;
      // }
    // }
  // }
  // AppProperty {
    // id: cueMonitorChannelProp4;
    // path: "app.traktor.mixer.channels.4.cue";
    // onValueChanged: {
      // if (value && customSingleCueMonitorProp.value) {
        // cueMonitorChannelProp1.value = false;
        // cueMonitorChannelProp2.value = false;
        // cueMonitorChannelProp3.value = false;
      // }
    // }
  // }

  AppProperty { id: fxMode; path: "app.traktor.fx.4fx_units"; onValueChanged: fxModeChanged() }

  function fxModeChanged() {
    if (fxMode.value == FxMode.TwoFxUnits) {
      fxAssignmentProp.value = DeviceAssignment.fx_1_2
      if (fx_section.layer == FXSectionLayer.fx_secondary) {
        fx_section.layer = FXSectionLayer.fx_primary
      }
    }
    else if (customLinkFXOverlayToDeckProp.value) {
      fxAssignmentProp.value = deckAssignmentProp.value
    }
  }
  
  // Settings
  MappingPropertyDescriptor { path: "mapping.settings.nudge_push_size"; type: MappingPropertyDescriptor.Integer; value: 11 /* 32 beats */ }
  MappingPropertyDescriptor { path: "mapping.settings.nudge_shiftpush_size"; type: MappingPropertyDescriptor.Integer; value: 11 /* 32 beats */ }
  MappingPropertyDescriptor { id: nudgePushActionProp; path: "mapping.settings.nudge_push_action"; type: MappingPropertyDescriptor.Integer; value: 0 /* Tempo Bend */ }
  MappingPropertyDescriptor { id: nudgeShiftPushActionProp; path: "mapping.settings.nudge_shiftpush_action"; type: MappingPropertyDescriptor.Integer; value: 1 /* Beatjump */ }
  
  MappingPropertyDescriptor { id: hotcue12PushActionProp; path: "mapping.settings.hotcue12_push_action"; type: MappingPropertyDescriptor.Integer; value: 0 /* Hotcues 1-2 */ }
  MappingPropertyDescriptor { id: hotcue34PushActionProp; path: "mapping.settings.hotcue34_push_action"; type: MappingPropertyDescriptor.Integer; value: 1 /* Hotcues 3-4 */ }
  MappingPropertyDescriptor { id: hotcue12ShiftPushActionProp; path: "mapping.settings.hotcue12_shiftpush_action"; type: MappingPropertyDescriptor.Integer; value: 4 /* Delete Hotcues 1-2 */ }
  MappingPropertyDescriptor { id: hotcue34ShiftPushActionProp; path: "mapping.settings.hotcue34_shiftpush_action"; type: MappingPropertyDescriptor.Integer; value: 5 /* Delete Hotcues 3-4 */ }

  MappingPropertyDescriptor { id: browseShiftActionProp; path: "mapping.settings.browse_shift_action"; type: MappingPropertyDescriptor.Integer; value: 0 /* Tree Up/Down */ }
  MappingPropertyDescriptor { id: browseShiftPushActionProp; path: "mapping.settings.browse_shiftpush_action"; type: MappingPropertyDescriptor.Integer; value: 0 /* Expand/Collapse tree folders */ }

  MappingPropertyDescriptor { id: loopShiftActionProp; path: "mapping.settings.loop_shift_action"; type: MappingPropertyDescriptor.Integer; value: 0 /* Beatjump Loop */ }

  // MappingPropertyDescriptor { id: maximizeBrowserWhenBrowsingProp; path: "mapping.settings.maximize_browser_when_browsing"; type: MappingPropertyDescriptor.Boolean; value: false }

  // MappingPropertyDescriptor { path: "mapping.settings.deck_display.main_info"; type: MappingPropertyDescriptor.Integer; value: 0 /* Remaining Time */ }

  // Color override
  MappingPropertyDescriptor { path: "mapping.settings.12_buttons.custom_color"; type: MappingPropertyDescriptor.Integer; value: Color.Black }
  Wire { from: "surface.left.hotcues.1.custom_color"; to: DirectPropertyAdapter { path: "mapping.settings.12_buttons.custom_color"; input: false } }
  Wire { from: "surface.left.hotcues.2.custom_color"; to: DirectPropertyAdapter { path: "mapping.settings.12_buttons.custom_color"; input: false } }
  Wire { from: "surface.right.hotcues.1.custom_color"; to: DirectPropertyAdapter { path: "mapping.settings.12_buttons.custom_color"; input: false } }
  Wire { from: "surface.right.hotcues.2.custom_color"; to: DirectPropertyAdapter { path: "mapping.settings.12_buttons.custom_color"; input: false } }

  MappingPropertyDescriptor { path: "mapping.settings.34_buttons.custom_color"; type: MappingPropertyDescriptor.Integer; value: Color.Black }
  Wire { from: "surface.left.hotcues.3.custom_color"; to: DirectPropertyAdapter { path: "mapping.settings.34_buttons.custom_color"; input: false } }
  Wire { from: "surface.left.hotcues.4.custom_color"; to: DirectPropertyAdapter { path: "mapping.settings.34_buttons.custom_color"; input: false } }
  Wire { from: "surface.right.hotcues.3.custom_color"; to: DirectPropertyAdapter { path: "mapping.settings.34_buttons.custom_color"; input: false } }
  Wire { from: "surface.right.hotcues.4.custom_color"; to: DirectPropertyAdapter { path: "mapping.settings.34_buttons.custom_color"; input: false } }

  MappingPropertyDescriptor { path: "mapping.settings.nudge_buttons.custom_color"; type: MappingPropertyDescriptor.Integer; value: Color.Black }
  Wire { from: "surface.left.nudge_slow.custom_color"; to: DirectPropertyAdapter { path: "mapping.settings.nudge_buttons.custom_color"; input: false } }
  Wire { from: "surface.left.nudge_fast.custom_color"; to: DirectPropertyAdapter { path: "mapping.settings.nudge_buttons.custom_color"; input: false } }
  Wire { from: "surface.right.nudge_slow.custom_color"; to: DirectPropertyAdapter { path: "mapping.settings.nudge_buttons.custom_color"; input: false } }
  Wire { from: "surface.right.nudge_fast.custom_color"; to: DirectPropertyAdapter { path: "mapping.settings.nudge_buttons.custom_color"; input: false } }

  MappingPropertyDescriptor { path: "mapping.settings.cue_rev_buttons.custom_color"; type: MappingPropertyDescriptor.Integer; value: Color.Black }
  Wire { from: "surface.left.cue.custom_color"; to: DirectPropertyAdapter { path: "mapping.settings.cue_rev_buttons.custom_color"; input: false } }
  Wire { from: "surface.left.rev.custom_color"; to: DirectPropertyAdapter { path: "mapping.settings.cue_rev_buttons.custom_color"; input: false } }
  Wire { from: "surface.right.cue.custom_color"; to: DirectPropertyAdapter { path: "mapping.settings.cue_rev_buttons.custom_color"; input: false } }
  Wire { from: "surface.right.rev.custom_color"; to: DirectPropertyAdapter { path: "mapping.settings.cue_rev_buttons.custom_color"; input: false } }

  MappingPropertyDescriptor { path: "mapping.settings.play_button.custom_color"; type: MappingPropertyDescriptor.Integer; value: Color.Black }
  Wire { from: "surface.left.play.custom_color"; to: DirectPropertyAdapter { path: "mapping.settings.play_button.custom_color"; input: false } }
  Wire { from: "surface.right.play.custom_color"; to: DirectPropertyAdapter { path: "mapping.settings.play_button.custom_color"; input: false } }

  MappingPropertyDescriptor { path: "mapping.settings.sync_button.custom_color"; type: MappingPropertyDescriptor.Integer; value: Color.Black }
  Wire { from: "surface.left.sync.custom_color"; to: DirectPropertyAdapter { path: "mapping.settings.sync_button.custom_color"; input: false } }
  Wire { from: "surface.right.sync.custom_color"; to: DirectPropertyAdapter { path: "mapping.settings.sync_button.custom_color"; input: false } }

  MappingPropertyDescriptor { path: "mapping.settings.fx_buttons.custom_color"; type: MappingPropertyDescriptor.Integer; value: Color.Black }
  Wire { from: "surface.left.fx.buttons.1.custom_color"; to: DirectPropertyAdapter { path: "mapping.settings.fx_buttons.custom_color"; input: false } }
  Wire { from: "surface.left.fx.buttons.2.custom_color"; to: DirectPropertyAdapter { path: "mapping.settings.fx_buttons.custom_color"; input: false } }
  Wire { from: "surface.left.fx.buttons.3.custom_color"; to: DirectPropertyAdapter { path: "mapping.settings.fx_buttons.custom_color"; input: false } }
  Wire { from: "surface.left.fx.buttons.4.custom_color"; to: DirectPropertyAdapter { path: "mapping.settings.fx_buttons.custom_color"; input: false } }
  Wire { from: "surface.right.fx.buttons.1.custom_color"; to: DirectPropertyAdapter { path: "mapping.settings.fx_buttons.custom_color"; input: false } }
  Wire { from: "surface.right.fx.buttons.2.custom_color"; to: DirectPropertyAdapter { path: "mapping.settings.fx_buttons.custom_color"; input: false } }
  Wire { from: "surface.right.fx.buttons.3.custom_color"; to: DirectPropertyAdapter { path: "mapping.settings.fx_buttons.custom_color"; input: false } }
  Wire { from: "surface.right.fx.buttons.4.custom_color"; to: DirectPropertyAdapter { path: "mapping.settings.fx_buttons.custom_color"; input: false } }

  MappingPropertyDescriptor { path: "mapping.settings.assign_buttons.custom_color"; type: MappingPropertyDescriptor.Integer; value: Color.Black }
  Wire { from: "surface.left.assign.left.custom_color"; to: DirectPropertyAdapter { path: "mapping.settings.assign_buttons.custom_color"; input: false } }
  Wire { from: "surface.left.assign.right.custom_color"; to: DirectPropertyAdapter { path: "mapping.settings.assign_buttons.custom_color"; input: false } }
  Wire { from: "surface.right.assign.left.custom_color"; to: DirectPropertyAdapter { path: "mapping.settings.assign_buttons.custom_color"; input: false } }
  Wire { from: "surface.right.assign.right.custom_color"; to: DirectPropertyAdapter { path: "mapping.settings.assign_buttons.custom_color"; input: false } }

  MappingPropertyDescriptor { id: showEndWarningProp; path: "mapping.settings.bottom_leds.show_end_warning"; type: MappingPropertyDescriptor.Boolean; value: true }
  MappingPropertyDescriptor { id: showSyncWarningProp; path: "mapping.settings.bottom_leds.show_sync_warning"; type: MappingPropertyDescriptor.Boolean; value: true }
  MappingPropertyDescriptor { id: showActiveLoopProp; path: "mapping.settings.bottom_leds.show_active_loop"; type: MappingPropertyDescriptor.Boolean; value: true }
  MappingPropertyDescriptor { id: bottomLedsDefaultColorProp; path: "mapping.settings.bottom_leds.default_color"; type: MappingPropertyDescriptor.Integer; value: Color.Black }

  MappingPropertyDescriptor { id: leftDeckIdxProp; path: "mapping.settings.left_deck_index"; type: MappingPropertyDescriptor.Integer; value: deviceSetup.leftDeckIdx }
  MappingPropertyDescriptor { id: rightDeckIdxProp; path: "mapping.settings.right_deck_index"; type: MappingPropertyDescriptor.Integer; value: deviceSetup.rightDeckIdx }

  // Shift
  property alias shift: shiftProp
  MappingPropertyDescriptor { id: shiftProp; path: mapping.propertiesPath + ".shift"; type: MappingPropertyDescriptor.Boolean; value: false }
  // Wire { from: "surface.shift";  to: DirectPropertyAdapter { path: mapping.propertiesPath + ".shift"  } }

  Browser { name: "browser" }

  AppProperty { id: previewplayerUnloadProp; path:"app.traktor.browser.preview_player.unload" }
  AppProperty { id: previewplayerPlayProp; path:"app.traktor.browser.preview_player.play" }
  
  Timer {
    id: shiftBlinkTimer
    property bool  blink: false
    interval: 250 * masterClockTempoMultiplierProp.value
    repeat: true
    running: browserModeProp.value
    onTriggered: {
      blink = !blink;
    }
    onRunningChanged: {
      blink = running;
    }
  }

  Wire {
    from: "surface.shift"
    to: ButtonScriptAdapter {
      brightness: shiftProp.value || shiftBlinkTimer.blink ? 1.0 : 0.0; 
      onPress: {
        shiftProp.value = true;
        holdShift_countdown.restart()
      }
      onRelease: {
        shiftProp.value = false;
        // if ( (holdShift_countdown.running) && (deviceSetup.state == DeviceSetupState.assigned) ) {
        if ( (holdShift_countdown.running) && customBrowserModeProp.value && (deviceSetup.state == DeviceSetupState.assigned) ) {
          browserModeProp.value = !browserModeProp.value
          previewplayerPlayProp.value = false
          // previewplayerUnloadProp.value = !previewplayerUnloadProp.value
          // holdShift_countdown.stop()
        }
      }
    }
  }
  
  Timer {
    id: holdShift_countdown;
    interval: 200
    // onTriggered: {
      // if (!browserModeProp.value) previewplayerUnloadProp.value = !previewplayerUnloadProp.value      
      // if (!customBrowserModeProp.value) previewplayerUnloadProp.value = !previewplayerUnloadProp.value      
    // }
  }
    
  WiresGroup {
    // enabled: (deviceSetup.state == DeviceSetupState.assigned) && browserModeProp.value 
    enabled: (deviceSetup.state == DeviceSetupState.assigned) && browserModeProp.value && customBrowserModeProp.value
    
    WiresGroup {
      
      Wire { enabled: !shiftProp.value; from: "surface.left.browse.turn"; to: RelativePropertyAdapter { path: "app.traktor.browser.list.select_up_down"; wrap: true; step: 1; mode: RelativeMode.Stepped } }
      Wire { enabled: shiftProp.value; from: "surface.left.browse.turn"; to: RelativePropertyAdapter { path: "app.traktor.browser.list.select_up_down"; wrap: true; step: 10; mode: RelativeMode.Stepped } }
      Wire { enabled: !shiftProp.value; from: "surface.right.browse.turn"; to: RelativePropertyAdapter { path: "app.traktor.browser.list.select_up_down"; wrap: true; step: 1; mode: RelativeMode.Stepped } }
      Wire { enabled: shiftProp.value; from: "surface.right.browse.turn"; to: RelativePropertyAdapter { path: "app.traktor.browser.list.select_up_down"; wrap: true; step: 10; mode: RelativeMode.Stepped } }
      Wire { enabled: !shiftProp.value; from: "surface.right.loop.turn"; to: RelativePropertyAdapter { path: "app.traktor.browser.preview_player.seek"; step: 0.05; mode: RelativeMode.Stepped } }
      Wire { enabled: shiftProp.value; from: "surface.right.loop.turn"; to: RelativePropertyAdapter { path: "app.traktor.browser.favorites.select"; wrap: true; step: 1; mode: RelativeMode.Stepped } }
        
    }
      
    WiresGroup {
      
      Wire { from: "surface.left.loop"; to: "browser.tree_navigation" }
      Wire { enabled: shiftProp.value; from: "surface.left.loop.turn"; to: RelativePropertyAdapter { path: "app.traktor.browser.tree.select_up_down"; wrap: true; step: 9; mode: RelativeMode.Stepped } }
      Wire { enabled: !shiftProp.value; from: "surface.right.loop.push"; to: TriggerPropertyAdapter { path:"app.traktor.browser.preview_player.load_or_play" } }
      Wire { enabled: shiftProp.value; from: "surface.right.loop.push"; to: TriggerPropertyAdapter { path:"app.traktor.browser.preparation.jump_to_list" } }
        
    }
      
  }

  X1MK3Side
  {
    name: "left_deck"
    surface: "surface.left"
    propertiesPath: mapping.propertiesPath + ".left.deck"
    active: deviceSetup.state == DeviceSetupState.assigned

    shift: shiftProp.value
    deckIdx: deviceSetup.leftDeckIdx

    fxSectionLayer: fxSection.layer
    leftPrimaryFxIdx: deviceSetup.leftPrimaryFxIdx
    rightPrimaryFxIdx: deviceSetup.rightPrimaryFxIdx
    leftSecondaryFxIdx: deviceSetup.leftSecondaryFxIdx
    rightSecondaryFxIdx: deviceSetup.rightSecondaryFxIdx

    fxAssignmentPropertiesPath: mapping.propertiesPath + ".left.fx"
    sidePrimaryFxIdx: deviceSetup.leftPrimaryFxIdx
    sideSecondaryFxIdx: deviceSetup.leftSecondaryFxIdx

    nudgePushAction: nudgePushActionProp.value
    nudgeShiftPushAction: nudgeShiftPushActionProp.value

    hotcue12PushAction: hotcue12PushActionProp.value
    hotcue34PushAction: hotcue34PushActionProp.value
    hotcue12ShiftPushAction: hotcue12ShiftPushActionProp.value
    hotcue34ShiftPushAction: hotcue34ShiftPushActionProp.value

    browseShiftAction: browseShiftActionProp.value
    browseShiftPushAction: browseShiftPushActionProp.value

    loopShiftAction: loopShiftActionProp.value

    showEndWarning: showEndWarningProp.value
    showSyncWarning: showSyncWarningProp.value
    showActiveLoop: showActiveLoopProp.value
    bottomLedsDefaultColor: bottomLedsDefaultColorProp.value
  }

  X1MK3Side
  {
    name: "right_deck"
    surface: "surface.right"
    propertiesPath: mapping.propertiesPath + ".right.deck"
    active: deviceSetup.state == DeviceSetupState.assigned

    shift: shiftProp.value
    deckIdx: deviceSetup.rightDeckIdx

    fxSectionLayer: fxSection.layer
    leftPrimaryFxIdx: deviceSetup.leftPrimaryFxIdx
    rightPrimaryFxIdx: deviceSetup.rightPrimaryFxIdx
    leftSecondaryFxIdx: deviceSetup.leftSecondaryFxIdx
    rightSecondaryFxIdx: deviceSetup.rightSecondaryFxIdx

    fxAssignmentPropertiesPath: mapping.propertiesPath + ".right.fx"
    sidePrimaryFxIdx: deviceSetup.rightPrimaryFxIdx
    sideSecondaryFxIdx: deviceSetup.rightSecondaryFxIdx

    nudgePushAction: nudgePushActionProp.value
    nudgeShiftPushAction: nudgeShiftPushActionProp.value

    hotcue12PushAction: hotcue12PushActionProp.value
    hotcue34PushAction: hotcue34PushActionProp.value
    hotcue12ShiftPushAction: hotcue12ShiftPushActionProp.value
    hotcue34ShiftPushAction: hotcue34ShiftPushActionProp.value

    browseShiftAction: browseShiftActionProp.value
    browseShiftPushAction: browseShiftPushActionProp.value

    loopShiftAction: loopShiftActionProp.value

    showEndWarning: showEndWarningProp.value
    showSyncWarning: showSyncWarningProp.value
    showActiveLoop: showActiveLoopProp.value
    bottomLedsDefaultColor: bottomLedsDefaultColorProp.value
  }

  MappingPropertyDescriptor {
    id: browserModeProp;
    path: "mapping.state.browser_mode";
    type: MappingPropertyDescriptor.Boolean;
    value: false;
    onValueChanged: {
      if (maximizeBrowserWhenBrowsingProp.value && (browserFullScreenProp.value != value)) browserFullScreenProp.value = value
      previewplayerUnloadProp.value = !previewplayerUnloadProp.value
    }
  }
  
  AppProperty { id: browserFullScreenProp; path: "app.traktor.browser.full_screen";
    onValueChanged: {
      // if (maximizeBrowserWhenBrowsingProp.value && (browserModeProp.value != value)) browserModeProp.value = value
      if (maximizeBrowserWhenBrowsingProp.value && customBrowserModeProp.value && (browserModeProp.value != value)) browserModeProp.value = value
      // previewplayerUnloadProp.value = !previewplayerUnloadProp.value
    }
  }

  property bool fullScreenTimerRunning: false

  SwitchTimer {
    name: "show_browser_full_screen_timer";
    setTimeout: 0;
    resetTimeout: 2000;

    onSet: {
      fullScreenTimerRunning = true;
      browserFullScreenProp.value = true;
      // browserModeProp.value = true;
    }

    onReset: {
      fullScreenTimerRunning = false;
      browserFullScreenProp.value = false
      // browserModeProp.value = false
    }
  }

  WiresGroup {
    // enabled: (deviceSetup.state == DeviceSetupState.assigned) && maximizeBrowserWhenBrowsingProp.value
    enabled: (deviceSetup.state == DeviceSetupState.assigned) && maximizeBrowserWhenBrowsingProp.value && !customBrowserModeProp.value

    Wire {
      from: Or
      {
        inputs: [ "surface.left.browse.is_turned", "surface.right.browse.is_turned" ]
      }
      to: "show_browser_full_screen_timer.input"
    }

    Wire {
      enabled: shiftProp.value && browseShiftPushActionProp.value == BrowseEncoderAction.browse_expand_tree;
      from: Or
      {
        inputs: [ "surface.left.browse.push", "surface.right.browse.push" ]
      }
      to: "show_browser_full_screen_timer.input"
    }

    Wire {
      enabled: !shiftProp.value && fullScreenTimerRunning && browserModeProp.value;
      from: Or
      {
        inputs: [ "surface.left.browse.push", "surface.right.browse.push" ]
      }
      to: ValuePropertyAdapter { path: "app.traktor.browser.full_screen"; output: false; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
    }
  }

  X1MK3FXSection
  {
    id: fxSection
    name: "fx_section"
    surface: "surface"
    shift: shiftProp.value
    propertiesPath: mapping.propertiesPath
    active: deviceSetup.state == DeviceSetupState.assigned

    leftDeckIdx: deviceSetup.leftDeckIdx
    rightDeckIdx: deviceSetup.rightDeckIdx

    leftPrimaryFxIdx: deviceSetup.leftPrimaryFxIdx
    rightPrimaryFxIdx: deviceSetup.rightPrimaryFxIdx
    leftSecondaryFxIdx: deviceSetup.leftSecondaryFxIdx
    rightSecondaryFxIdx: deviceSetup.rightSecondaryFxIdx
  }

  // Blinking timer for screens
  MappingPropertyDescriptor { id: blinkerProp; path: mapping.propertiesPath + ".blinker"; type: MappingPropertyDescriptor.Boolean; value: false }
  Timer { interval: 500 * masterClockTempoMultiplierProp.value; running: true; repeat: true; onTriggered: blinkerProp.value = blinkerProp.value ? false : true; }
} //Mapping
