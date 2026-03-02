import CSI 1.0
import QtQuick 2.0

import "../../CSI/X1MK3/Defines"
import "Scripts/DisplayHelpers.js" as DisplayHelpers

Item {
  id: screen

  property int side: ScreenSide.Left;

  property string settingsPath: ""
  property string propertiesPath: ""

  width:  128
  height: 64
  clip:   true

  readonly property variant fxText: ["FX 1", "FX 2", "FX 3", "FX 4"]
  readonly property variant setupTextButton: ["", buttonText1[leftSide], buttonText2[leftSide], buttonText3[leftSide], buttonText4[leftSide], buttonText5[leftSide], buttonText6[leftSide], buttonText7[leftSide], buttonText8[leftSide], buttonText9[leftSide], buttonText10[leftSide], buttonText11[leftSide], buttonText12[leftSide], buttonText13[leftSide], buttonText14[leftSide], buttonText15[leftSide], buttonText16[leftSide], buttonText17[leftSide], buttonText18[leftSide], buttonText19[leftSide], buttonText20[leftSide]]

  readonly property variant buttonText1: ["EQ High " + eqHighKnobAssignment, "Volume " + eqVolumeKnobAssignment]
  readonly property variant buttonText2: ["EQ Mid " + eqMidKnobAssignment, "Gain    " + eqGainKnobAssignment]
  readonly property variant buttonText3: ["EQ MidLow " + eqMidLowKnobAssignment, "Mixer FX " + eqMixerFxKnobAssignment]
  readonly property variant buttonText4: ["EQ Low " + eqLowKnobAssignment, "Block Mxer Overlay"]
  readonly property variant buttonText5: ["EQ High " + eqHighKnobLayerAssignment, "Volume " + eqVolumeKnobLayerAssignment]
  readonly property variant buttonText6: ["EQ Mid " + eqMidKnobLayerAssignment, "Gain    " + eqGainKnobLayerAssignment]
  readonly property variant buttonText7: ["EQ MidLow " + eqMidLowKnobLayerAssignment, "Mixer FX " + eqMixerFxKnobLayerAssignment]
  readonly property variant buttonText8: ["EQ Low " + eqLowKnobLayerAssignment, ""]
  readonly property variant buttonText9: ["Browser Mode", "" + deckDisplayMainInfoString]
  readonly property variant buttonText10: ["Maximize Browser", "" + timeBeatCounter]
  readonly property variant buttonText11: ["Load Minim. Browser", "Phrase L. " + phraseLength + " Bar"]
  readonly property variant buttonText12: ["Single Tap: Deck Swtch", ""]
  readonly property variant buttonText13: ["Single Monitor", "Overmap Modifier"]
  readonly property variant buttonText14: ["Switch Mute/FX", "FX Assignm. Unit Focus"]
  readonly property variant buttonText15: ["Cue And Play", "FX Units Deck-Link"]
  readonly property variant buttonText16: ["Mixer FX Invt. LED", "Block 2nd FX Overlay"]
  readonly property variant buttonText17: ["", ""]
  readonly property variant buttonText18: ["", ""]
  readonly property variant buttonText19: ["", ""]
  readonly property variant buttonText20: ["", ""]
  
  property int leftSide: propertiesPath == "mapping.state.left.fx" ? 0 : 1;
  readonly property string setupText: "" + setupTextButton[lastTouchedButton]
  
  MappingProperty { id: deckDisplayMainInfoProp; path: "mapping.settings.deck_display.main_info" }
  property string deckDisplayMainInfoString: (deckDisplayMainInfoProp.value == 0) ? ( customBeatCounterEngagedProp.value ? "Beats To Cue" : "Remaining Time" ) : (deckDisplayMainInfoProp.value == 1) ? ( customBeatCounterEngagedProp.value ? "Elapsed Beats" : "Elapsed Time" ) : "Display Loop Size"
  
  MappingProperty { id: customBeatCounterEngagedProp; path: "mapping.settings.custom_beatcounter_engaged" }
  property string timeBeatCounter: customBeatCounterEngagedProp.value ? "Display Beats" : "Display Time"
  
  MappingProperty { id: customBeatCounterPhraseLengthProp; path: "mapping.settings.custom_phrase_length" }
  property string phraseLength: Math.pow (2, customBeatCounterPhraseLengthProp.value)

  MappingProperty {
    id: customKnobAssignmentEqHigh;
    path: "mapping.settings.custom_mixer_eq_high_knob_assignment"
  }
  MappingProperty {
    id: customLayerAssignmentEqHigh;
    path: "mapping.settings.custom_mixer_eq_high_knob_layer_assignment"
  }
  
  MappingProperty {
    id: customKnobAssignmentEqMid;
    path: "mapping.settings.custom_mixer_eq_mid_knob_assignment"
  }
  MappingProperty {
    id: customLayerAssignmentEqMid;
    path: "mapping.settings.custom_mixer_eq_mid_knob_layer_assignment"
  }

  MappingProperty {
    id: customKnobAssignmentEqMidLow;
    path: "mapping.settings.custom_mixer_eq_midlow_knob_assignment"
  }
  MappingProperty {
    id: customLayerAssignmentEqMidLow;
    path: "mapping.settings.custom_mixer_eq_midlow_knob_layer_assignment"
  }

  MappingProperty {
    id: customKnobAssignmentEqLow;
    path: "mapping.settings.custom_mixer_eq_low_knob_assignment"
  }
  MappingProperty {
    id: customLayerAssignmentEqLow;
    path: "mapping.settings.custom_mixer_eq_low_knob_layer_assignment"
  }

  MappingProperty {
    id: customKnobAssignmentVolume;
    path: "mapping.settings.custom_mixer_volume_knob_assignment"
  }
  MappingProperty {
    id: customLayerAssignmentVolume;
    path: "mapping.settings.custom_mixer_volume_knob_layer_assignment"
  }

  MappingProperty {
    id: customKnobAssignmentGain;
    path: "mapping.settings.custom_mixer_gain_knob_assignment"
  }
  MappingProperty {
    id: customLayerAssignmentGain;
    path: "mapping.settings.custom_mixer_gain_knob_layer_assignment"
  }

  MappingProperty {
    id: customKnobAssignmentMixerFx;
    path: "mapping.settings.custom_mixer_fx_knob_assignment"
  }
  MappingProperty {
    id: customLayerAssignmentMixerFx;
    path: "mapping.settings.custom_mixer_fx_knob_layer_assignment"
  }

  property string eqHighKnobAssignment: "" + mixerKnobAssignment(customKnobAssignmentEqHigh.value)
  property string eqHighKnobLayerAssignment: "" + mixerKnobLayerAssignment(customLayerAssignmentEqHigh.value)

  property string eqMidKnobAssignment: "" + mixerKnobAssignment(customKnobAssignmentEqMid.value)
  property string eqMidKnobLayerAssignment: "" + mixerKnobLayerAssignment(customLayerAssignmentEqMid.value)

  property string eqMidLowKnobAssignment: "" + mixerKnobAssignment(customKnobAssignmentEqMidLow.value)
  property string eqMidLowKnobLayerAssignment: "" + mixerKnobLayerAssignment(customLayerAssignmentEqMidLow.value)

  property string eqLowKnobAssignment: "" + mixerKnobAssignment(customKnobAssignmentEqLow.value)
  property string eqLowKnobLayerAssignment: "" + mixerKnobLayerAssignment(customLayerAssignmentEqLow.value)

  property string eqVolumeKnobAssignment: "" + mixerKnobAssignment(customKnobAssignmentVolume.value)
  property string eqVolumeKnobLayerAssignment: "" + mixerKnobLayerAssignment(customLayerAssignmentVolume.value)

  property string eqGainKnobAssignment: "" + mixerKnobAssignment(customKnobAssignmentGain.value)
  property string eqGainKnobLayerAssignment: "" + mixerKnobLayerAssignment(customLayerAssignmentGain.value)

  property string eqMixerFxKnobAssignment: "" + mixerKnobAssignment(customKnobAssignmentMixerFx.value)
  property string eqMixerFxKnobLayerAssignment: "" + mixerKnobLayerAssignment(customLayerAssignmentMixerFx.value)

  MappingProperty { id: deviceSetupStateProp; path: "mapping.state.device_setup_state" }
  property alias deviceSetupState: deviceSetupStateProp.value

  MappingProperty { id: fxSectionLayerProp; path: "mapping.state.fx_section_layer"; onValueChanged: onLayerChanged() }
  property alias fxSectionLayer: fxSectionLayerProp.value

  MappingProperty { id: primaryFxUnitProp; path: screen.propertiesPath + ".primary_fx_unit" }
  MappingProperty { id: secondaryFxUnitProp; path: screen.propertiesPath + ".secondary_fx_unit" }
  readonly property int fxUnitIdx: (fxSectionLayer === FXSectionLayer.fx_primary ? primaryFxUnitProp.value : secondaryFxUnitProp.value)

  MappingProperty { id: deckIdxProp; path: screen.propertiesPath + ".active_deck" }
  property alias deckIdx: deckIdxProp.value

  MappingProperty { id: knobsAreActiveProp; path: screen.propertiesPath + ".knobs_are_active" }
  MappingProperty { id: buttonsAreActiveProp; path: screen.propertiesPath + ".buttons_are_active" }
  // property alias knobsAreActive: knobsAreActiveProp.value
  property bool knobsAreActive: knobsAreActiveProp.value || buttonsAreActiveProp.value

  MappingProperty { id: lastTouchedKnobProp; path: screen.propertiesPath + ".last_active_knob" }
  property alias lastTouchedKnob: lastTouchedKnobProp.value

  MappingProperty { id: softTakeoverDirectionProp; path: screen.propertiesPath + ".softtakeover." + lastTouchedKnob + ".direction" }
  property alias softTakeoverDirection: softTakeoverDirectionProp.value

  MappingProperty { id: shiftProp; path: "mapping.state.shift" }
  property alias shift: shiftProp.value

  // MappingProperty { id: browseShiftPushActionProp; path: "mapping.settings.browse_shiftpush_action" }
  // property alias browseShiftPushAction: browseShiftPushActionProp.value

  MappingProperty { id: lastTouchedButtonProp; path: screen.propertiesPath + ".last_active_button" }
  property alias lastTouchedButton: lastTouchedButtonProp.value

  AppProperty { id: deckTypeProp; path: "app.traktor.decks." + deckIdx + ".type" }
  
  MappingProperty { id: mixerStemOverlayProp; path: screen.propertiesPath + ".mixer_stem_overlay_active" }
  property bool isStemOverlayActive: (deckTypeProp.value == DeckType.Stem) && mixerStemOverlayProp.value && fxSectionLayer === FXSectionLayer.mixer
  property bool isRemixOverlayActive: (deckTypeProp.value == DeckType.Remix) && mixerStemOverlayProp.value && fxSectionLayer === FXSectionLayer.mixer

  // Effect unit properties
  AppProperty { id: fxUnitType; path: "app.traktor.fx." + fxUnitIdx + ".type"; onValueChanged: onFxChanged() }
  AppProperty { id: fxSelect1; path: "app.traktor.fx." + fxUnitIdx + ".select.1"; onValueChanged: onFxChanged() }
  AppProperty { id: fxSelect2; path: "app.traktor.fx." + fxUnitIdx + ".select.2" }
  AppProperty { id: fxSelect3; path: "app.traktor.fx." + fxUnitIdx + ".select.3" }
  AppProperty { id: fxDryWet; path: "app.traktor.fx." + fxUnitIdx + ".dry_wet" }
  AppProperty { id: fxParameterName1; path: "app.traktor.fx." + fxUnitIdx + ".knobs.1.name" }
  AppProperty { id: fxParameterName2; path: "app.traktor.fx." + fxUnitIdx + ".knobs.2.name" }
  AppProperty { id: fxParameterName3; path: "app.traktor.fx." + fxUnitIdx + ".knobs.3.name" }
  AppProperty { id: fxParameterValue1; path: "app.traktor.fx." + fxUnitIdx + ".parameters.1" }
  AppProperty { id: fxParameterValue2; path: "app.traktor.fx." + fxUnitIdx + ".parameters.2" }
  AppProperty { id: fxParameterValue3; path: "app.traktor.fx." + fxUnitIdx + ".parameters.3" }

  // Pattern Player properties
  AppProperty { id: currentKit;   path: "app.traktor.fx." + fxUnitIdx + ".pattern_player.kit_shortname" }
  AppProperty { id: currentStep;  path: "app.traktor.fx." + fxUnitIdx + ".pattern_player.current_step" }
  AppProperty { id: currentSound; path: "app.traktor.fx." + fxUnitIdx + ".pattern_player.current_sound" }

  // Mixer Mode properties
  AppProperty { id: deckCue; path: "app.traktor.mixer.channels." + deckIdx + ".cue"  }
  AppProperty { id: deckVolume; path: "app.traktor.mixer.channels." + deckIdx + ".volume"  }
  AppProperty { id: deckEqHigh; path: "app.traktor.mixer.channels." + deckIdx + ".eq.high" }
  AppProperty { id: deckEqMid;  path: "app.traktor.mixer.channels." + deckIdx + ".eq.mid"  }
  AppProperty { id: deckEqMidLow;  path: "app.traktor.mixer.channels." + deckIdx + ".eq.mid_low"  }
  AppProperty { id: deckEqLow;  path: "app.traktor.mixer.channels." + deckIdx + ".eq.low"  }
  AppProperty { id: deckGain;  path: "app.traktor.mixer.channels." + deckIdx + ".gain"  }
  AppProperty { id: deckKillHigh;  path: "app.traktor.mixer.channels." + deckIdx + ".eq.kill_high" }
  AppProperty { id: deckKillMid;  path: "app.traktor.mixer.channels." + deckIdx + ".eq.kill_mid" }
  AppProperty { id: deckKillMidLow;  path: "app.traktor.mixer.channels." + deckIdx + ".eq.kill_mid_low" }
  AppProperty { id: deckKillLow;  path: "app.traktor.mixer.channels." + deckIdx + ".eq.kill_low" }
  AppProperty { id: deckFxOn;  path: "app.traktor.mixer.channels." + deckIdx + ".fx.on" }
  AppProperty { id: deckFXAdjust;  path: "app.traktor.mixer.channels." + deckIdx + ".fx.adjust"  }
  AppProperty { id: mixerFXTypeProp; path: "app.traktor.mixer.channels." + deckIdx + ".fx.select"; onValueChanged: (lastTouchedKnob = customKnobAssignmentMixerFx.value) }
  property alias mixerFXType: mixerFXTypeProp.value
  readonly property variant mixerFXName: mixerFXTypeProp.description

  MappingProperty { id: stemVolumeFilterProp_1; path: "mapping.state." + deckIdx + ".stems_1_volume_filter" }
  MappingProperty { id: stemVolumeFilterProp_2; path: "mapping.state." + deckIdx + ".stems_2_volume_filter" }
  MappingProperty { id: stemVolumeFilterProp_3; path: "mapping.state." + deckIdx + ".stems_3_volume_filter" }
  MappingProperty { id: stemVolumeFilterProp_4; path: "mapping.state." + deckIdx + ".stems_4_volume_filter" }
  MappingProperty { id: remixPlayersVolumeFilterProp_1; path: "mapping.state." + deckIdx + ".remix_players_1_volume_filter" }
  MappingProperty { id: remixPlayersVolumeFilterProp_2; path: "mapping.state." + deckIdx + ".remix_players_2_volume_filter" }
  MappingProperty { id: remixPlayersVolumeFilterProp_3; path: "mapping.state." + deckIdx + ".remix_players_3_volume_filter" }
  MappingProperty { id: remixPlayersVolumeFilterProp_4; path: "mapping.state." + deckIdx + ".remix_players_4_volume_filter" }

  AppProperty { id: stem1Mute; path: "app.traktor.decks." + deckIdx + ".stems.1.muted"; onValueChanged: (lastTouchedKnob = 1) }
  AppProperty { id: stem2Mute; path: "app.traktor.decks." + deckIdx + ".stems.2.muted"; onValueChanged: (lastTouchedKnob = 2) }
  AppProperty { id: stem3Mute; path: "app.traktor.decks." + deckIdx + ".stems.3.muted"; onValueChanged: (lastTouchedKnob = 3) }
  AppProperty { id: stem4Mute; path: "app.traktor.decks." + deckIdx + ".stems.4.muted"; onValueChanged: (lastTouchedKnob = 4) }
  AppProperty { id: stems1FxSend; path: "app.traktor.decks." + deckIdx + ".stems.1.fx_send_on"; onValueChanged: (lastTouchedKnob = 1) }
  AppProperty { id: stems2FxSend; path: "app.traktor.decks." + deckIdx + ".stems.2.fx_send_on"; onValueChanged: (lastTouchedKnob = 2) }
  AppProperty { id: stems3FxSend; path: "app.traktor.decks." + deckIdx + ".stems.3.fx_send_on"; onValueChanged: (lastTouchedKnob = 3) }
  AppProperty { id: stems4FxSend; path: "app.traktor.decks." + deckIdx + ".stems.4.fx_send_on"; onValueChanged: (lastTouchedKnob = 4) }
  AppProperty { id: remixSlot1Mute; path: "app.traktor.decks." + deckIdx + ".remix.players.1.muted"; onValueChanged: (lastTouchedKnob = 1) }
  AppProperty { id: remixSlot2Mute; path: "app.traktor.decks." + deckIdx + ".remix.players.2.muted"; onValueChanged: (lastTouchedKnob = 2) }
  AppProperty { id: remixSlot3Mute; path: "app.traktor.decks." + deckIdx + ".remix.players.3.muted"; onValueChanged: (lastTouchedKnob = 3) }
  AppProperty { id: remixSlot4Mute; path: "app.traktor.decks." + deckIdx + ".remix.players.4.muted"; onValueChanged: (lastTouchedKnob = 4) }
  AppProperty { id: remixSlot1FxSend; path: "app.traktor.decks." + deckIdx + ".remix.players.1.fx_send_on"; onValueChanged: (lastTouchedKnob = 1) }
  AppProperty { id: remixSlot2FxSend; path: "app.traktor.decks." + deckIdx + ".remix.players.2.fx_send_on"; onValueChanged: (lastTouchedKnob = 2) }
  AppProperty { id: remixSlot3FxSend; path: "app.traktor.decks." + deckIdx + ".remix.players.3.fx_send_on"; onValueChanged: (lastTouchedKnob = 3) }
  AppProperty { id: remixSlot4FxSend; path: "app.traktor.decks." + deckIdx + ".remix.players.4.fx_send_on"; onValueChanged: (lastTouchedKnob = 4) }

  function mixerKnobAssignment(knob)
  {
    switch(knob)
    {
      case 0: return "Unassigned";
      case 1: return "Knob 1";
      case 2: return "Knob 2";
      case 3: return "Knob 3";
      case 4: return "Knob 4";
    }

    // break;
  }

  function mixerKnobLayerAssignment(shiftLayer)
  {
    switch(shiftLayer)
    {
      case 0: return "Both Lyrs.";
      case 1: return "Norm. Lyr.";
      case 2: return "Shift Lyr.";
    }

  }

  function onFxChanged()
  {
    lastTouchedKnob = 1;
  }

  function onLayerChanged()
  {
    switch(fxSectionLayer)
    {
      case FXSectionLayer.fx_primary:
      case FXSectionLayer.fx_secondary:
        lastTouchedKnob = 1; // Defaults to Dry/Wet
        break;

    }
  }

  function hasParameter(knob)
  {
    switch (fxSectionLayer)
    {
      case FXSectionLayer.fx_primary:
      case FXSectionLayer.fx_secondary:
      {
        switch (fxUnitType.value)
        {
          case FxType.Group:
          {
            switch(knob)
            {
              case 1: return true;
              case 2: return fxSelect1.value !== 0;
              case 3: return fxSelect2.value !== 0;
              case 4: return fxSelect3.value !== 0;
            }

            break;
          }

          case FxType.Single:
          {
            if (fxSelect1.value === 0)
              return false;

            switch(knob)
            {
              case 1: return true;
              case 2: return fxParameterName1.value.length !== 0;
              case 3: return fxParameterName2.value.length !== 0;
              case 4: return fxParameterName3.value.length !== 0;
            }

            break;
          }

          case FxType.PatternPlayer:
            return true;
        }

        break;
      }

      case FXSectionLayer.mixer:
        return true;
    }

    return false;
  }

  function parameterName(knob)
  {
    switch (fxSectionLayer)
    {
      case FXSectionLayer.fx_primary:
      case FXSectionLayer.fx_secondary:
      {
        switch (fxUnitType.value)
        {
          case FxType.Group:
          {
            switch(knob)
            {
              case 1: return "D/W";
              case 2: return DisplayHelpers.effectName(fxSelect1.description);
              case 3: return DisplayHelpers.effectName(fxSelect2.description);
              case 4: return DisplayHelpers.effectName(fxSelect3.description);
            }

            break;
          }

          case FxType.Single:
          {
            return DisplayHelpers.parameterName(fxSelect1.description, knob);
          }

          case FxType.PatternPlayer:
          {
            switch(knob)
            {
              case 1: return "VOL";
              case 2: return "PTRN";
              case 3: return "PTCH";
              case 4: return "DCAY";
            }

            break;
          }
        }

        break;
      }

      case FXSectionLayer.mixer:
      {
        // switch(knob)
        // {
          // case 1: return "HI";
          // case 2: return "MID";
          // case 3: return "LO";
          // case 4: return "VOL";
        // }
        // break;
        if (isStemOverlayActive) {
          switch(knob) {
            case 1: return "DRUM";
            case 2: return "BASS";
            case 3: return "OTHR";
            case 4: return "VOCL";
          }
          break;
        }
        else if (isRemixOverlayActive) {
          switch(knob) {
            case 1: return "SLT.1";
            case 2: return "SLT.2";
            case 3: return "SLT.3";
            case 4: return "SLT.4";
          }
          break;
        }
        else {
          switch(knob) {
            case 1: {
              if ( (customKnobAssignmentEqHigh.value == 1) && ( ( !shift && (customLayerAssignmentEqHigh.value != 2) ) || ( shift && (customLayerAssignmentEqHigh.value != 1) ) ) ) {
                if ( (customKnobAssignmentMixerFx.value == 1) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) && (deckEqHigh.value == 0.5) ) return "" + mixerFXName;
                else if ( (customKnobAssignmentGain.value == 1) && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) ) && (deckEqHigh.value == 0.5) ) return "GAIN";
                else return "HI";
              }
              else if ( (customKnobAssignmentEqMid.value == 1) && ( ( !shift && (customLayerAssignmentEqMid.value != 2) ) || ( shift && (customLayerAssignmentEqMid.value != 1) ) ) ) {
                if ( (customKnobAssignmentMixerFx.value == 1) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) && (deckEqMid.value == 0.5) ) return "" + mixerFXName;
                else if ( (customKnobAssignmentGain.value == 1) && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) ) && (deckEqMid.value == 0.5) ) return "GAIN";
                else return "MID";
              }
              else if ( (customKnobAssignmentEqMidLow.value == 1) && ( ( !shift && (customLayerAssignmentEqMidLow.value != 2) ) || ( shift && (customLayerAssignmentEqMidLow.value != 1) ) ) ) {
                if ( (customKnobAssignmentMixerFx.value == 1) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) && (deckEqMidLow.value == 0.5) ) return "" + mixerFXName;
                else if ( (customKnobAssignmentGain.value == 1) && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) ) && (deckEqMidLow.value == 0.5) ) return "GAIN";
                else return "M.LO";
              }
              else if ( (customKnobAssignmentEqLow.value == 1) && ( ( !shift && (customLayerAssignmentEqLow.value != 2) ) || ( shift && (customLayerAssignmentEqLow.value != 1) ) ) ) {
                if ( (customKnobAssignmentMixerFx.value == 1) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) && (deckEqLow.value == 0.5) ) return "" + mixerFXName;
                else if ( (customKnobAssignmentGain.value == 1) && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) ) && (deckEqLow.value == 0.5) ) return "GAIN";
                else return "LO";
              }
              else if ( (customKnobAssignmentVolume.value == 1) && ( ( !shift && (customLayerAssignmentVolume.value != 2) ) || ( shift && (customLayerAssignmentVolume.value != 1) ) ) ) {
                if ( (customKnobAssignmentMixerFx.value == 1) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) && (deckVolume.value == 1.0) ) return "" + mixerFXName;
                else if ( (customKnobAssignmentGain.value == 1) && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) )  && (deckVolume.value == 1.0) ) return "GAIN";
                else return "VOL";
              }
              else if ( (customKnobAssignmentGain.value == 1) && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) ) ) {
                if ( (customKnobAssignmentMixerFx.value == 1) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) && !(deckGain.value < 0.5) ) return "" + mixerFXName;
                else return "GAIN";
              }
              else if ( (customKnobAssignmentMixerFx.value == 1) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) ) {
                  return "" + mixerFXName;
              }
            }
            case 2: {
              if ( (customKnobAssignmentEqHigh.value == 2) && ( ( !shift && (customLayerAssignmentEqHigh.value != 2) ) || ( shift && (customLayerAssignmentEqHigh.value != 1) ) ) ) {
                if ( (customKnobAssignmentMixerFx.value == 2) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) && (deckEqHigh.value == 0.5) ) return "" + mixerFXName;
                else if ( (customKnobAssignmentGain.value == 2) && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) ) && (deckEqHigh.value == 0.5) ) return "GAIN";
                else return "HI";
              }
              else if ( (customKnobAssignmentEqMid.value == 2) && ( ( !shift && (customLayerAssignmentEqMid.value != 2) ) || ( shift && (customLayerAssignmentEqMid.value != 1) ) ) ) {
                if ( (customKnobAssignmentMixerFx.value == 2) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) && (deckEqMid.value == 0.5) ) return "" + mixerFXName;
                else if ( (customKnobAssignmentGain.value == 2) && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) ) && (deckEqMid.value == 0.5) ) return "GAIN";
                else return "MID";
              }
              else if ( (customKnobAssignmentEqMidLow.value == 2) && ( ( !shift && (customLayerAssignmentEqMidLow.value != 2) ) || ( shift && (customLayerAssignmentEqMidLow.value != 1) ) ) ) {
                if ( (customKnobAssignmentMixerFx.value == 2) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) && (deckEqMidLow.value == 0.5) ) return "" + mixerFXName;
                else if ( (customKnobAssignmentGain.value == 2) && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) ) && (deckEqMidLow.value == 0.5) ) return "GAIN";
                else return "M.LO";
              }
              else if ( (customKnobAssignmentEqLow.value == 2) && ( ( !shift && (customLayerAssignmentEqLow.value != 2) ) || ( shift && (customLayerAssignmentEqLow.value != 1) ) ) ) {
                if ( (customKnobAssignmentMixerFx.value == 2) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) && (deckEqLow.value == 0.5) ) return "" + mixerFXName;
                else if ( (customKnobAssignmentGain.value == 2) && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) ) && (deckEqLow.value == 0.5) ) return "GAIN";
                else return "LO";
              }
              else if ( (customKnobAssignmentVolume.value == 2) && ( ( !shift && (customLayerAssignmentVolume.value != 2) ) || ( shift && (customLayerAssignmentVolume.value != 1) ) ) ) {
                if ( (customKnobAssignmentMixerFx.value == 2) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) && (deckVolume.value == 1.0) ) return "" + mixerFXName;
                else if ( (customKnobAssignmentGain.value == 2) && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) )  && (deckVolume.value == 1.0) ) return "GAIN";
                else return "VOL";
              }
              else if ( (customKnobAssignmentGain.value == 2) && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) ) ) {
                if ( (customKnobAssignmentMixerFx.value == 2) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) && !(deckGain.value < 0.5) ) return "" + mixerFXName;
                else return "GAIN";
              }
              else if ( (customKnobAssignmentMixerFx.value == 2) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) ) {
                return "" + mixerFXName;
              }
            }
            case 3: {
              if ( (customKnobAssignmentEqHigh.value == 3) && ( ( !shift && (customLayerAssignmentEqHigh.value != 2) ) || ( shift && (customLayerAssignmentEqHigh.value != 1) ) ) ) {
                if ( (customKnobAssignmentMixerFx.value == 3) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) && (deckEqHigh.value == 0.5) ) return "" + mixerFXName;
                else if ( (customKnobAssignmentGain.value == 3) && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) ) && (deckEqHigh.value == 0.5) ) return "GAIN";
                else return "HI";
              }
              else if ( (customKnobAssignmentEqMid.value == 3) && ( ( !shift && (customLayerAssignmentEqMid.value != 2) ) || ( shift && (customLayerAssignmentEqMid.value != 1) ) ) ) {
                if ( (customKnobAssignmentMixerFx.value == 3) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) && (deckEqMid.value == 0.5) ) return "" + mixerFXName;
                else if ( (customKnobAssignmentGain.value == 3) && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) ) && (deckEqMid.value == 0.5) ) return "GAIN";
                else return "MID";
              }
              else if ( (customKnobAssignmentEqMidLow.value == 3) && ( ( !shift && (customLayerAssignmentEqMidLow.value != 2) ) || ( shift && (customLayerAssignmentEqMidLow.value != 1) ) ) ) {
                if ( (customKnobAssignmentMixerFx.value == 3) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) && (deckEqMidLow.value == 0.5) ) return "" + mixerFXName;
                else if ( (customKnobAssignmentGain.value == 3) && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) ) && (deckEqMidLow.value == 0.5) ) return "GAIN";
                else return "M.LO";
              }
              else if ( (customKnobAssignmentEqLow.value == 3) && ( ( !shift && (customLayerAssignmentEqLow.value != 2) ) || ( shift && (customLayerAssignmentEqLow.value != 1) ) ) ) {
                if ( (customKnobAssignmentMixerFx.value == 3) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) && (deckEqLow.value == 0.5) ) return "" + mixerFXName;
                else if ( (customKnobAssignmentGain.value == 3) && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) ) && (deckEqLow.value == 0.5) ) return "GAIN";
                else return "LO";
              }
              else if ( (customKnobAssignmentVolume.value == 3) && ( ( !shift && (customLayerAssignmentVolume.value != 2) ) || ( shift && (customLayerAssignmentVolume.value != 1) ) ) ) {
                if ( (customKnobAssignmentMixerFx.value == 3) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) && (deckVolume.value == 1.0) ) return "" + mixerFXName;
                else if ( (customKnobAssignmentGain.value == 3) && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) )  && (deckVolume.value == 1.0) ) return "GAIN";
                else return "VOL";
              }
              else if ( (customKnobAssignmentGain.value == 3) && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) ) ) {
                if ( (customKnobAssignmentMixerFx.value == 3) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) && !(deckGain.value < 0.5) ) return "" + mixerFXName;
                else return "GAIN";
              }
              else if ( (customKnobAssignmentMixerFx.value == 3) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) ) {
                return "" + mixerFXName;
              }
            }
            case 4: {
              if ( (customKnobAssignmentEqHigh.value == 4) && ( ( !shift && (customLayerAssignmentEqHigh.value != 2) ) || ( shift && (customLayerAssignmentEqHigh.value != 1) ) ) ) {
                if ( (customKnobAssignmentMixerFx.value == 4) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) && (deckEqHigh.value == 0.5) ) return "" + mixerFXName;
                else if ( (customKnobAssignmentGain.value == 4) && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) ) && (deckEqHigh.value == 0.5) ) return "GAIN";
                else return "HI";
              }
              else if ( (customKnobAssignmentEqMid.value == 4) && ( ( !shift && (customLayerAssignmentEqMid.value != 2) ) || ( shift && (customLayerAssignmentEqMid.value != 1) ) ) ) {
                if ( (customKnobAssignmentMixerFx.value == 4) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) && (deckEqMid.value == 0.5) ) return "" + mixerFXName;
                else if ( (customKnobAssignmentGain.value == 4) && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) ) && (deckEqMid.value == 0.5) ) return "GAIN";
                else return "MID";
              }
              else if ( (customKnobAssignmentEqMidLow.value == 4) && ( ( !shift && (customLayerAssignmentEqMidLow.value != 2) ) || ( shift && (customLayerAssignmentEqMidLow.value != 1) ) ) ) {
                if ( (customKnobAssignmentMixerFx.value == 4) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) && (deckEqMidLow.value == 0.5) ) return "" + mixerFXName;
                else if ( (customKnobAssignmentGain.value == 4) && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) ) && (deckEqMidLow.value == 0.5) ) return "GAIN";
                else return "M.LO";
              }
              else if ( (customKnobAssignmentEqLow.value == 4) && ( ( !shift && (customLayerAssignmentEqLow.value != 2) ) || ( shift && (customLayerAssignmentEqLow.value != 1) ) ) ) {
                if ( (customKnobAssignmentMixerFx.value == 4) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) && (deckEqLow.value == 0.5) ) return "" + mixerFXName;
                else if ( (customKnobAssignmentGain.value == 4) && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) ) && (deckEqLow.value == 0.5) ) return "GAIN";
                else return "LO";
              }
              else if ( (customKnobAssignmentVolume.value == 4) && ( ( !shift && (customLayerAssignmentVolume.value != 2) ) || ( shift && (customLayerAssignmentVolume.value != 1) ) ) ) {
                if ( (customKnobAssignmentMixerFx.value == 4) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) && (deckVolume.value == 1.0) ) return "" + mixerFXName;
                else if ( (customKnobAssignmentGain.value == 4) && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) )  && (deckVolume.value == 1.0) ) return "GAIN";
                else return "VOL";
              }
              else if ( (customKnobAssignmentGain.value == 4) && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) ) ) {
                if ( (customKnobAssignmentMixerFx.value == 4) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) && !(deckGain.value < 0.5) ) return "" + mixerFXName;
                else return "GAIN";
              }
              else if ( (customKnobAssignmentMixerFx.value == 4) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) ) {
                return "" + mixerFXName;
              }
            }
          }
          break;
        }
      }
    }

    return "";
  }

  function parameterValue(knob)
  {
    switch (fxSectionLayer)
    {
      case FXSectionLayer.fx_primary:
      case FXSectionLayer.fx_secondary:
      {
        switch(knob)
        {
          case 1: return fxDryWet.description;
          case 2: return fxParameterValue1.description;
          case 3: return fxParameterValue2.description;
          case 4: return fxParameterValue3.description;
        }

        break;
      }

      case FXSectionLayer.mixer:
      {
        // switch(knob)
        // {
          // case 1: return (200.0 * deckEqHigh.value - 100.0).toFixed();
          // case 2: return (200.0 * deckEqMid.value  - 100.0).toFixed();
          // case 3: return (200.0 * deckEqLow.value  - 100.0).toFixed();
          // case 4: return (100.0 * deckVolume.value).toFixed();
        // }
        // break;
        if (isStemOverlayActive) {
          switch(knob) {
            case 1: return Math.round((stemVolumeFilterProp_1.value - 0.5) * 200);
            case 2: return Math.round((stemVolumeFilterProp_2.value - 0.5) * 200);
            case 3: return Math.round((stemVolumeFilterProp_3.value - 0.5) * 200);
            case 4: return Math.round((stemVolumeFilterProp_4.value - 0.5) * 200);
          }
          break;
        }
        else if (isRemixOverlayActive) {
          switch(knob) {
            case 1: return Math.round((remixPlayersVolumeFilterProp_1.value - 0.5) * 200);
            case 2: return Math.round((remixPlayersVolumeFilterProp_2.value - 0.5) * 200);
            case 3: return Math.round((remixPlayersVolumeFilterProp_3.value - 0.5) * 200);
            case 4: return Math.round((remixPlayersVolumeFilterProp_4.value - 0.5) * 200);
          }
          break;
        }
        else {
          switch(knob) {
            case 1: {
              if ( (customKnobAssignmentEqHigh.value == 1) && ( ( !shift && (customLayerAssignmentEqHigh.value != 2) ) || ( shift && (customLayerAssignmentEqHigh.value != 1) ) ) ) {
                if ( (customKnobAssignmentMixerFx.value == 1) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) && (deckEqHigh.value == 0.5) ) return (200.0 * deckFXAdjust.value  - 100.0).toFixed();
                else if ( (customKnobAssignmentGain.value == 1) && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) ) && (deckEqHigh.value == 0.5) ) return (200.0 * deckGain.value - 100.0).toFixed();
                else return (200.0 * deckEqHigh.value - 100.0).toFixed();
              }
              else if ( (customKnobAssignmentEqMid.value == 1) && ( ( !shift && (customLayerAssignmentEqMid.value != 2) ) || ( shift && (customLayerAssignmentEqMid.value != 1) ) ) ) {
                if ( (customKnobAssignmentMixerFx.value == 1) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) && (deckEqMid.value == 0.5) ) return (200.0 * deckFXAdjust.value  - 100.0).toFixed();
                else if ( (customKnobAssignmentGain.value == 1) && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) ) && (deckEqMid.value == 0.5) ) return (200.0 * deckGain.value - 100.0).toFixed();
                else return (200.0 * deckEqMid.value  - 100.0).toFixed();
              }
              else if ( (customKnobAssignmentEqMidLow.value == 1) && ( ( !shift && (customLayerAssignmentEqMidLow.value != 2) ) || ( shift && (customLayerAssignmentEqMidLow.value != 1) ) ) ) {
                if ( (customKnobAssignmentMixerFx.value == 1) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) && (deckEqMidLow.value == 0.5) ) return (200.0 * deckFXAdjust.value  - 100.0).toFixed();
                else if ( (customKnobAssignmentGain.value == 1) && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) ) && (deckEqMidLow.value == 0.5) ) return (200.0 * deckGain.value - 100.0).toFixed();
                else return (200.0 * deckEqMidLow.value  - 100.0).toFixed();
              }
              else if ( (customKnobAssignmentEqLow.value == 1) && ( ( !shift && (customLayerAssignmentEqLow.value != 2) ) || ( shift && (customLayerAssignmentEqLow.value != 1) ) ) ) {
                if ( (customKnobAssignmentMixerFx.value == 1) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) && (deckEqLow.value == 0.5) ) return (200.0 * deckFXAdjust.value  - 100.0).toFixed();
                else if ( (customKnobAssignmentGain.value == 1) && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) ) && (deckEqLow.value == 0.5) ) return (200.0 * deckGain.value - 100.0).toFixed();
                else return (200.0 * deckEqLow.value  - 100.0).toFixed();
              }
              else if ( (customKnobAssignmentVolume.value == 1) && ( ( !shift && (customLayerAssignmentVolume.value != 2) ) || ( shift && (customLayerAssignmentVolume.value != 1) ) ) ) {
                if ( (customKnobAssignmentMixerFx.value == 1) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) && (deckVolume.value == 1.0) ) return (200.0 * deckFXAdjust.value  - 100.0).toFixed();
                else if ( (customKnobAssignmentGain.value == 1) && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) )  && (deckVolume.value == 1.0) ) return (200.0 * deckGain.value - 100.0).toFixed();
                else return (100.0 * deckVolume.value).toFixed();
              }
              else if ( (customKnobAssignmentGain.value == 1) && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) ) ) {
                if ( (customKnobAssignmentMixerFx.value == 1) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) && !(deckGain.value < 0.5) ) return (200.0 * deckFXAdjust.value  - 100.0).toFixed();
                else return (200.0 * deckGain.value - 100.0).toFixed();
              }
              else if ( (customKnobAssignmentMixerFx.value == 1) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) ) {
                return (200.0 * deckFXAdjust.value  - 100.0).toFixed();
              }
            }
            case 2: {
              if ( (customKnobAssignmentEqHigh.value == 2) && ( ( !shift && (customLayerAssignmentEqHigh.value != 2) ) || ( shift && (customLayerAssignmentEqHigh.value != 1) ) ) ) {
                if ( (customKnobAssignmentMixerFx.value == 2) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) && (deckEqHigh.value == 0.5) ) return (200.0 * deckFXAdjust.value  - 100.0).toFixed();
                else if ( (customKnobAssignmentGain.value == 2) && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) ) && (deckEqHigh.value == 0.5) ) return (200.0 * deckGain.value - 100.0).toFixed();
                else return (200.0 * deckEqHigh.value - 100.0).toFixed();
              }
              else if ( (customKnobAssignmentEqMid.value == 2) && ( ( !shift && (customLayerAssignmentEqMid.value != 2) ) || ( shift && (customLayerAssignmentEqMid.value != 1) ) ) ) {
                if ( (customKnobAssignmentMixerFx.value == 2) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) && (deckEqMid.value == 0.5) ) return (200.0 * deckFXAdjust.value  - 100.0).toFixed();
                else if ( (customKnobAssignmentGain.value == 2) && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) ) && (deckEqMid.value == 0.5) ) return (200.0 * deckGain.value - 100.0).toFixed();
                else return (200.0 * deckEqMid.value  - 100.0).toFixed();
              }
              else if ( (customKnobAssignmentEqMidLow.value == 2) && ( ( !shift && (customLayerAssignmentEqMidLow.value != 2) ) || ( shift && (customLayerAssignmentEqMidLow.value != 1) ) ) ) {
                if ( (customKnobAssignmentMixerFx.value == 2) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) && (deckEqMidLow.value == 0.5) ) return (200.0 * deckFXAdjust.value  - 100.0).toFixed();
                else if ( (customKnobAssignmentGain.value == 2) && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) ) && (deckEqMidLow.value == 0.5) ) return (200.0 * deckGain.value - 100.0).toFixed();
                else return (200.0 * deckEqMidLow.value  - 100.0).toFixed();
              }
              else if ( (customKnobAssignmentEqLow.value == 2) && ( ( !shift && (customLayerAssignmentEqLow.value != 2) ) || ( shift && (customLayerAssignmentEqLow.value != 1) ) ) ) {
                if ( (customKnobAssignmentMixerFx.value == 2) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) && (deckEqLow.value == 0.5) ) return (200.0 * deckFXAdjust.value  - 100.0).toFixed();
                else if ( (customKnobAssignmentGain.value == 2) && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) ) && (deckEqLow.value == 0.5) ) return (200.0 * deckGain.value - 100.0).toFixed();
                else return (200.0 * deckEqLow.value  - 100.0).toFixed();
              }
              else if ( (customKnobAssignmentVolume.value == 2) && ( ( !shift && (customLayerAssignmentVolume.value != 2) ) || ( shift && (customLayerAssignmentVolume.value != 1) ) ) ) {
                if ( (customKnobAssignmentMixerFx.value == 2) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) && (deckVolume.value == 1.0) ) return (200.0 * deckFXAdjust.value  - 100.0).toFixed();
                else if ( (customKnobAssignmentGain.value == 2) && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) )  && (deckVolume.value == 1.0) ) return (200.0 * deckGain.value - 100.0).toFixed();
                else return (100.0 * deckVolume.value).toFixed();
              }
              else if ( (customKnobAssignmentGain.value == 2) && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) ) ) {
                if ( (customKnobAssignmentMixerFx.value == 2) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) && !(deckGain.value < 0.5) ) return (200.0 * deckFXAdjust.value  - 100.0).toFixed();
                else return (200.0 * deckGain.value - 100.0).toFixed();
              }
              else if ( (customKnobAssignmentMixerFx.value == 2) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) ) {
                return (200.0 * deckFXAdjust.value  - 100.0).toFixed();
              }
            }
            case 3: {
              if ( (customKnobAssignmentEqHigh.value == 3) && ( ( !shift && (customLayerAssignmentEqHigh.value != 2) ) || ( shift && (customLayerAssignmentEqHigh.value != 1) ) ) ) {
                if ( (customKnobAssignmentMixerFx.value == 3) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) && (deckEqHigh.value == 0.5) ) return (200.0 * deckFXAdjust.value  - 100.0).toFixed();
                else if ( (customKnobAssignmentGain.value == 3) && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) ) && (deckEqHigh.value == 0.5) ) return (200.0 * deckGain.value - 100.0).toFixed();
                else return (200.0 * deckEqHigh.value - 100.0).toFixed();
              }
              else if ( (customKnobAssignmentEqMid.value == 3) && ( ( !shift && (customLayerAssignmentEqMid.value != 2) ) || ( shift && (customLayerAssignmentEqMid.value != 1) ) ) ) {
                if ( (customKnobAssignmentMixerFx.value == 3) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) && (deckEqMid.value == 0.5) ) return (200.0 * deckFXAdjust.value  - 100.0).toFixed();
                else if ( (customKnobAssignmentGain.value == 3) && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) ) && (deckEqMid.value == 0.5) ) return (200.0 * deckGain.value - 100.0).toFixed();
                else return (200.0 * deckEqMid.value  - 100.0).toFixed();
              }
              else if ( (customKnobAssignmentEqMidLow.value == 3) && ( ( !shift && (customLayerAssignmentEqMidLow.value != 2) ) || ( shift && (customLayerAssignmentEqMidLow.value != 1) ) ) ) {
                if ( (customKnobAssignmentMixerFx.value == 3) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) && (deckEqMidLow.value == 0.5) ) return (200.0 * deckFXAdjust.value  - 100.0).toFixed();
                else if ( (customKnobAssignmentGain.value == 3) && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) ) && (deckEqMidLow.value == 0.5) ) return (200.0 * deckGain.value - 100.0).toFixed();
                else return (200.0 * deckEqMidLow.value  - 100.0).toFixed();
              }
              else if ( (customKnobAssignmentEqLow.value == 3) && ( ( !shift && (customLayerAssignmentEqLow.value != 2) ) || ( shift && (customLayerAssignmentEqLow.value != 1) ) ) ) {
                if ( (customKnobAssignmentMixerFx.value == 3) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) && (deckEqLow.value == 0.5) ) return (200.0 * deckFXAdjust.value  - 100.0).toFixed();
                else if ( (customKnobAssignmentGain.value == 3) && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) ) && (deckEqLow.value == 0.5) ) return (200.0 * deckGain.value - 100.0).toFixed();
                else return (200.0 * deckEqLow.value  - 100.0).toFixed();
              }
              else if ( (customKnobAssignmentVolume.value == 3) && ( ( !shift && (customLayerAssignmentVolume.value != 2) ) || ( shift && (customLayerAssignmentVolume.value != 1) ) ) ) {
                if ( (customKnobAssignmentMixerFx.value == 3) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) && (deckVolume.value == 1.0) ) return (200.0 * deckFXAdjust.value  - 100.0).toFixed();
                else if ( (customKnobAssignmentGain.value == 3) && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) )  && (deckVolume.value == 1.0) ) return (200.0 * deckGain.value - 100.0).toFixed();
                else return (100.0 * deckVolume.value).toFixed();
              }
              else if ( (customKnobAssignmentGain.value == 3) && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) ) ) {
                if ( (customKnobAssignmentMixerFx.value == 3) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) && !(deckGain.value < 0.5) ) return (200.0 * deckFXAdjust.value  - 100.0).toFixed();
                else return (200.0 * deckGain.value - 100.0).toFixed();
              }
              else if ( (customKnobAssignmentMixerFx.value == 3) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) ) {
                return (200.0 * deckFXAdjust.value  - 100.0).toFixed();
              }
            }
            case 4: {
              if ( (customKnobAssignmentEqHigh.value == 4) && ( ( !shift && (customLayerAssignmentEqHigh.value != 2) ) || ( shift && (customLayerAssignmentEqHigh.value != 1) ) ) ) {
                if ( (customKnobAssignmentMixerFx.value == 4) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) && (deckEqHigh.value == 0.5) ) return (200.0 * deckFXAdjust.value  - 100.0).toFixed();
                else if ( (customKnobAssignmentGain.value == 4) && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) ) && (deckEqHigh.value == 0.5) ) return (200.0 * deckGain.value - 100.0).toFixed();
                else return (200.0 * deckEqHigh.value - 100.0).toFixed();
              }
              else if ( (customKnobAssignmentEqMid.value == 4) && ( ( !shift && (customLayerAssignmentEqMid.value != 2) ) || ( shift && (customLayerAssignmentEqMid.value != 1) ) ) ) {
                if ( (customKnobAssignmentMixerFx.value == 4) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) && (deckEqMid.value == 0.5) ) return (200.0 * deckFXAdjust.value  - 100.0).toFixed();
                else if ( (customKnobAssignmentGain.value == 4) && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) ) && (deckEqMid.value == 0.5) ) return (200.0 * deckGain.value - 100.0).toFixed();
                else return (200.0 * deckEqMid.value  - 100.0).toFixed();
              }
              else if ( (customKnobAssignmentEqMidLow.value == 4) && ( ( !shift && (customLayerAssignmentEqMidLow.value != 2) ) || ( shift && (customLayerAssignmentEqMidLow.value != 1) ) ) ) {
                if ( (customKnobAssignmentMixerFx.value == 4) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) && (deckEqMidLow.value == 0.5) ) return (200.0 * deckFXAdjust.value  - 100.0).toFixed();
                else if ( (customKnobAssignmentGain.value == 4) && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) ) && (deckEqMidLow.value == 0.5) ) return (200.0 * deckGain.value - 100.0).toFixed();
                else return (200.0 * deckEqMidLow.value  - 100.0).toFixed();
              }
              else if ( (customKnobAssignmentEqLow.value == 4) && ( ( !shift && (customLayerAssignmentEqLow.value != 2) ) || ( shift && (customLayerAssignmentEqLow.value != 1) ) ) ) {
                if ( (customKnobAssignmentMixerFx.value == 4) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) && (deckEqLow.value == 0.5) ) return (200.0 * deckFXAdjust.value  - 100.0).toFixed();
                else if ( (customKnobAssignmentGain.value == 4) && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) ) && (deckEqLow.value == 0.5) ) return (200.0 * deckGain.value - 100.0).toFixed();
                else return (200.0 * deckEqLow.value  - 100.0).toFixed();
              }
              else if ( (customKnobAssignmentVolume.value == 4) && ( ( !shift && (customLayerAssignmentVolume.value != 2) ) || ( shift && (customLayerAssignmentVolume.value != 1) ) ) ) {
                if ( (customKnobAssignmentMixerFx.value == 4) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) && (deckVolume.value == 1.0) ) return (200.0 * deckFXAdjust.value  - 100.0).toFixed();
                else if ( (customKnobAssignmentGain.value == 4) && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) )  && (deckVolume.value == 1.0) ) return (200.0 * deckGain.value - 100.0).toFixed();
                else return (100.0 * deckVolume.value).toFixed();
              }
              else if ( (customKnobAssignmentGain.value == 4) && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) ) ) {
                if ( (customKnobAssignmentMixerFx.value == 4) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) && !(deckGain.value < 0.5) ) return (200.0 * deckFXAdjust.value  - 100.0).toFixed();
                else return (200.0 * deckGain.value - 100.0).toFixed();
              }
              else if ( (customKnobAssignmentMixerFx.value == 4) && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) ) ) {
                return (200.0 * deckFXAdjust.value  - 100.0).toFixed();
              }
            }
          }
          break;
        }
      }
    }

    return "";
  }

  MappingProperty { id: blinkerProp; path: "mapping.state.blinker" }
  property alias blinkOnOff: blinkerProp.value

  readonly property bool isSingleGroupFx: (fxSectionLayer === FXSectionLayer.fx_primary || fxSectionLayer === FXSectionLayer.fx_secondary) && (fxUnitType.value !== FxType.PatternPlayer)
  readonly property bool isPatternPlayer: (fxSectionLayer === FXSectionLayer.fx_primary || fxSectionLayer === FXSectionLayer.fx_secondary) && (fxUnitType.value === FxType.PatternPlayer)

  Rectangle {
    color: "black"
    anchors.fill: parent

    Item
    {
      visible: deviceSetupState == DeviceSetupState.assigned
      anchors.fill: parent

      // Pre-listen
      Image {
        id: preListenImage
        anchors {
            top: parent.top
            left: parent.left
            // left: speakerImage.right
            leftMargin: 2
        }

        source:    "Images/Indicator.png"
        fillMode:  Image.PreserveAspectFit
        visible: fxSectionLayer == FXSectionLayer.mixer && deckCue.value
      }

      // Speaker
      Image {
        id: speakerImage
        anchors {
            top: parent.top
            // left: parent.left
            left: preListenImage.right
            topMargin: 2
            leftMargin: 1
        }

        source:    "Images/Speaker.png"
        fillMode:  Image.PreserveAspectFit
        visible: fxSectionLayer == FXSectionLayer.mixer
      }

      // Single/Group Fx Title
      ThickText {
        visible: isSingleGroupFx

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: 0
            leftMargin: 1
        }

        text: fxUnitType.value === FxType.Single ? fxSelect1.description : "FX GROUP"
        wrapMode: Text.Wrap
      }

      // Pattern Player Kit
      ThickText {
        visible: isPatternPlayer

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: 0
            leftMargin: 1
        }

        text: currentKit.description
        wrapMode: Text.NoWrap
      }

      // Pattern Player Sound
      ThickText {
        visible: isPatternPlayer

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: 16
            leftMargin: 1
        }

        text: currentSound.description
        wrapMode: Text.NoWrap
      }

      // Pattern Player view
      Item
      {
        visible: isPatternPlayer && (!knobsAreActive || lastTouchedKnob == 2)
        anchors.fill: parent

        AnimatedImage {
            anchors {
                top: parent.top
                right: parent.right
                topMargin: 13
                rightMargin: 6
            }
            visible:   (softTakeoverDirection !== 0) && hasParameter(lastTouchedKnob)
            source:    softTakeoverDirection === 1 ? "Images/SoftTakeoverUp.gif" : "Images/SoftTakeoverDown.gif"
            fillMode:  Image.PreserveAspectFit
        }
        
        Repeater {
          model: 16
          Rectangle
          {
            AppProperty { id: stepState;  path: "app.traktor.fx." + fxUnitIdx + ".pattern_player.steps." + (index + 1) + ".state"  }

            anchors {
              left: parent.left
              bottom: parent.bottom
              leftMargin: (index % 8) * 16
              bottomMargin: (index < 8) ? 16 : 0
            }
            border {
              width: 1
              color: "white"
            }

            width: 12
            height: 12
            color: stepState.value ? "white" : "black"

            Rectangle
            {
                visible: currentStep.value == index

                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }

                width: 4
                height: 4
                color: stepState.value ? "black" : "white"
            }
          }
        }
      }

      // Mixer view
      Item {
        visible: !knobsAreActive && (fxSectionLayer == FXSectionLayer.mixer)
        anchors.fill: parent

        // Channel fader
        Item {
          anchors {
            bottom: parent.bottom
            left: parent.left
          }
          width: 95

          // Image {
            // anchors {
                // bottom: parent.bottom
                // left: parent.left
            // }

            // source:    "Images/Speaker.png"
            // fillMode:  Image.PreserveAspectFit
          // }

          AnimatedImage {
              anchors {
                  bottom: parent.bottom
                  right: volumeText.left
                  rightMargin: -10
                  bottomMargin: 3
              }

              visible:   faderSoftTakeoverDirection !== 0
              source:    faderSoftTakeoverDirection === 1 ? "Images/SoftTakeoverUp.gif" : "Images/SoftTakeoverDown.gif"
              fillMode:  Image.PreserveAspectFit
          }

          ThinText {
            id: volumeText
            anchors {
                bottom: parent.bottom
                right: parent.right
                bottomMargin: -3
                // rightMargin: 16
                // rightMargin: 28
                rightMargin: 46
              }
              //font.pixelSize: 24
              horizontalAlignment: Text.AlignRight
              font.capitalization: Font.AllUppercase
              text: " " + Math.round(deckVolume.value * 100)
          }
        }

        // EQ indicators
        Item {
          visible: !isStemOverlayActive && !isRemixOverlayActive
          anchors.fill: parent

          // High level
          Item {
            anchors {
              bottom: parent.bottom
              right: parent.right
              rightMargin: 2
            }
            width: 12
            height: 55
            
            Rectangle {
              // color: (!blinkOnOff && deckKillHigh.value) || ((deckEqHigh.value == 0) && !deckKillHigh.value) ? "white" : "black"
              color: deckKillHigh.value ? "white" : "black"
              anchors {
                top: parent.top
                right: parent.right
                topMargin: 2
              }
              width: 7
              height: 9
            }

            ThinText {
              anchors {
                  top: parent.top
                  right: parent.right
                }
                font.pixelSize: 12
                horizontalAlignment: Text.AlignRight
                text: "H"
                // color: (!blinkOnOff && deckKillHigh.value) || ((deckEqHigh.value == 0) && !deckKillHigh.value) ? "black" : "white"
                color: deckKillHigh.value ? "black" : "white"
            }

            Image {
              anchors {
                  bottom: parent.bottom
                  right: parent.right
              }

              source:    "Images/EQMeter_unipolar.png"
              fillMode:  Image.PreserveAspectFit

              Rectangle
              {
                visible: !deckKillHigh.value || (deckKillHigh.value && blinkOnOff)
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                }

                color: "white"
                height: Math.min(deckEqHigh.value * parent.height, 41)
              }
            }
          }

          // Mid level
          Item {
            anchors {
              bottom: parent.bottom
              right: parent.right
              // rightMargin: 26
              rightMargin: 14
            }
            width: 12
            height: 55

            Rectangle {
              // color: (!blinkOnOff && deckKillMid.value) || ((deckEqMid.value == 0) && !deckKillMid.value) ? "white" : "black"
              color: deckKillMid.value ? "white" : "black"
              anchors {
                top: parent.top
                right: parent.right
                topMargin: 2
              }
              width: 7
              height: 9
            }

            ThinText {
              anchors {
                  top: parent.top
                  right: parent.right
                }
                font.pixelSize: 12
                horizontalAlignment: Text.AlignRight
                text: "M"
                // color: (!blinkOnOff && deckKillMid.value) || ((deckEqMid.value == 0) && !deckKillMid.value) ? "black" : "white"
                color: deckKillMid.value ? "black" : "white"
            }

            Image {
              anchors {
                  bottom: parent.bottom
                  right: parent.right
              }

              source:    "Images/EQMeter_unipolar.png"
              fillMode:  Image.PreserveAspectFit

              Rectangle
              {
                visible: !deckKillMid.value || (deckKillMid.value && blinkOnOff)
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                }

                color: "white"
                height: Math.min(deckEqMid.value * parent.height, 41)
              }
            }
          }

          // Mid Low level
          Item {
            visible: (customKnobAssignmentEqMidLow.value > 0)
            anchors {
              bottom: parent.bottom
              right: parent.right
              // rightMargin: 38
              // rightMargin: 2
              rightMargin: 26
            }
            width: 12
            height: 55

            Rectangle {
              // color: (!blinkOnOff && deckKillMidLow.value) || ((deckEqMidLow.value == 0) && !deckKillMidLow.value) ? "white" : "black"
              color: deckKillMidLow.value ? "white" : "black"
              anchors {
                top: parent.top
                right: parent.right
                topMargin: 2
                rightMargin: -3
              }
              // width: 7
              width: 13
              height: 9
            }

            ThinText {
              anchors {
                  top: parent.top
                  right: parent.right
                  rightMargin: -3
                }
                font.pixelSize: 12
                horizontalAlignment: Text.AlignRight
                text: "ML"
                // color: (!blinkOnOff && deckKillMidLow.value) || ((deckEqMidLow.value == 0) && !deckKillMidLow.value) ? "black" : "white"
                color: deckKillMidLow.value ? "black" : "white"
            }

            Image {
              anchors {
                  bottom: parent.bottom
                  right: parent.right
              }

              source:    "Images/EQMeter_unipolar.png"
              fillMode:  Image.PreserveAspectFit

              Rectangle
              {
                visible: !deckKillMidLow.value || (deckKillMidLow.value && blinkOnOff)
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                }

                color: "white"
                height: Math.min(deckEqMidLow.value * parent.height, 41)
              }
            }
          }

          // Low level
          Item {
            anchors {
              bottom: parent.bottom
              right: parent.right
              // rightMargin: 38
              // rightMargin: 2
              // rightMargin: 26
              rightMargin: (customKnobAssignmentEqMidLow.value > 0) ? 38 : 26
            }
            width: 12
            height: 55

            Rectangle {
              // color: (!blinkOnOff && deckKillLow.value) || ((deckEqLow.value == 0) && !deckKillLow.value) ? "white" : "black"
              color: deckKillLow.value ? "white" : "black"
              anchors {
                top: parent.top
                right: parent.right
                topMargin: 2
              }
              width: 7
              height: 9
            }

            ThinText {
              anchors {
                  top: parent.top
                  right: parent.right
                }
                font.pixelSize: 12
                horizontalAlignment: Text.AlignRight
                text: "L"
                // color: (!blinkOnOff && deckKillLow.value) || ((deckEqLow.value == 0) && !deckKillLow.value) ? "black" : "white"
                color: deckKillLow.value ? "black" : "white"
            }

            Image {
              anchors {
                  bottom: parent.bottom
                  right: parent.right
              }

              source:    "Images/EQMeter_unipolar.png"
              fillMode:  Image.PreserveAspectFit

              Rectangle
              {
                visible: !deckKillLow.value || (deckKillLow.value && blinkOnOff)
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                }

                color: "white"
                height: Math.min(deckEqLow.value * parent.height, 41)
              }
            }
          }

          // MixerFX level
          Item {
            visible: (customKnobAssignmentMixerFx.value > 0)
            anchors {
              bottom: parent.bottom
              right: parent.right
              rightMargin: (customKnobAssignmentEqMidLow.value > 0) ? 53 : 44
            }
            width: 12
            height: 55

            Rectangle {
              // color: (!blinkOnOff && !deckFxOn.value) || ((deckFXAdjust.value == 0.5) && deckFxOn.value) ? "white" : "black"
              color: !deckFxOn.value ? "white" : "black"
              anchors {
                top: parent.top
                right: parent.right
                topMargin: 2
                rightMargin: -3
              }
              // width: 7
              width: 13
              height: 9
            }

            ThinText {
              anchors {
                  top: parent.top
                  right: parent.right
                  rightMargin: -3
                }
                font.pixelSize: 12
                horizontalAlignment: Text.AlignRight
                text: "FX"
                // color: (!blinkOnOff && !deckFxOn.value) || ((deckFXAdjust.value == 0.5) && deckFxOn.value) ? "black" : "white"
                color: !deckFxOn.value ? "black" : "white"
            }

            Image {
              anchors {
                  bottom: parent.bottom
                  right: parent.right
              }

              source: ( deckFxOn.value || (!deckFxOn.value && blinkOnOff) ) ? "Images/EQMeter_bipolar.png" : "Images/EQMeter_unipolar.png"
              fillMode:  Image.PreserveAspectFit

              Rectangle
              {
                visible: (deckFXAdjust.value > 0.5) && ( deckFxOn.value || (!deckFxOn.value && blinkOnOff) )
                anchors {
                    bottom: parent.verticalCenter
                    left: parent.left
                    right: parent.right
                }

                color: "white"
                height: Math.min((deckFXAdjust.value - 0.5), 0.5) * 41
              }
              
              Rectangle
              {
                visible: (deckFXAdjust.value < 0.5) && ( deckFxOn.value || (!deckFxOn.value && blinkOnOff) )
                anchors {
                    top: parent.verticalCenter
                    left: parent.left
                    right: parent.right
                }

                color: "white"
                height: Math.min((0.5 - deckFXAdjust.value), 0.5) * 41
              }
              
            }
          }

          // Gain level
          Item {
            anchors {
              bottom: parent.bottom
              right: parent.right
              // rightMargin: 2
              // rightMargin: 38
              // rightMargin: 50
              // rightMargin: (customKnobAssignmentEqMidLow.value > 1) || (customKnobAssignmentMixerFx.value > 1) ? 62 : 50
              rightMargin: (customKnobAssignmentEqMidLow.value > 1) || (customKnobAssignmentMixerFx.value > 1) ? 68 : 56
            }
            width: 12
            height: 55

            Rectangle {
              color: (deckGain.value == 0) ? "white" : "black"
              anchors {
                top: parent.top
                right: parent.right
                topMargin: 2
              }
              width: 7
              height: 9
            }

            ThinText {
              anchors {
                  top: parent.top
                  right: parent.right
                }
                font.pixelSize: 12
                horizontalAlignment: Text.AlignRight
                text: "G"
                color: (deckGain.value == 0) ? "black" : "white"
            }

            Image {
              anchors {
                  bottom: parent.bottom
                  right: parent.right
              }

              source:    "Images/EQMeter_unipolar.png"
              fillMode:  Image.PreserveAspectFit

              Rectangle
              {
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                }

                color: "white"
                height: Math.min(deckGain.value * parent.height, 41)
              }
            }
          }

        }

        // Stem indicators
        Item {
          visible: isStemOverlayActive
          anchors.fill: parent

          Item {
            anchors {
              bottom: parent.bottom
              right: parent.right
              bottomMargin: 38
            }
            width: 46
            height: 12

            Rectangle {
              color: (!blinkOnOff && stem1Mute.value) || (((stemVolumeFilterProp_1.value == 0) || (stemVolumeFilterProp_1.value == 1)) && !stem1Mute.value) ? "white" : "black"
              anchors {
                bottom: parent.bottom
                left: parent.left
                leftMargin: -1
              }
              width: 7
              height: 9
            }

            ThinText {
              anchors {
                  bottom: parent.bottom
                  left: parent.left
                  bottomMargin: -2
                }
                font.pixelSize: 12
                horizontalAlignment: Text.AlignRight
                text: "D"
                color: (!blinkOnOff && stem1Mute.value) || (((stemVolumeFilterProp_1.value == 0) || (stemVolumeFilterProp_1.value == 1)) && !stem1Mute.value) ? "black" : "white"
            }

            Image {
              anchors {
                  bottom: parent.bottom
                  right: parent.right
              }

              source:    "Images/StemMeter.png"
              fillMode:  Image.PreserveAspectFit

              // Drums level
              Rectangle
              {
                visible: (stemVolumeFilterProp_1.value > 0.5) && (!stem1Mute.value || (stem1Mute.value && blinkOnOff))
                anchors {
                    bottom: parent.bottom
                    right: parent.right
                    top: parent.top
                }

                color: "white"
                width: Math.min((1.0 - stemVolumeFilterProp_1.value) * 2 * parent.width, 36)
              }
              
              Rectangle
              {
                visible: (stemVolumeFilterProp_1.value <= 0.5) && (!stem1Mute.value || (stem1Mute.value && blinkOnOff))
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                    top: parent.top
                }

                color: "white"
                width: Math.min(stemVolumeFilterProp_1.value * 2 * parent.width, 36)
              }
            }
          }

          Item {
            anchors {
              bottom: parent.bottom
              right: parent.right
              bottomMargin: 26
            }
            width: 46
            height: 12

            Rectangle {
              color: (!blinkOnOff && stem2Mute.value) || (((stemVolumeFilterProp_2.value == 0) || (stemVolumeFilterProp_2.value == 1)) && !stem2Mute.value) ? "white" : "black"
              anchors {
                bottom: parent.bottom
                left: parent.left
                leftMargin: -1
              }
              width: 7
              height: 9
            }

            ThinText {
              anchors {
                  bottom: parent.bottom
                  left: parent.left
                  bottomMargin: -2
                }
                font.pixelSize: 12
                horizontalAlignment: Text.AlignRight
                text: "B"
                color: (!blinkOnOff && stem2Mute.value) || (((stemVolumeFilterProp_2.value == 0) || (stemVolumeFilterProp_2.value == 1)) && !stem2Mute.value) ? "black" : "white"
            }

            Image {
              anchors {
                  bottom: parent.bottom
                  right: parent.right
              }

              source:    "Images/StemMeter.png"
              fillMode:  Image.PreserveAspectFit

              // Bass level
              Rectangle
              {
                visible: (stemVolumeFilterProp_2.value > 0.5) && (!stem2Mute.value || (stem2Mute.value && blinkOnOff))
                anchors {
                    bottom: parent.bottom
                    right: parent.right
                    top: parent.top
                }

                color: "white"
                width: Math.min((1.0 - stemVolumeFilterProp_2.value) * 2 * parent.width, 36)
              }
              
              Rectangle
              {
                visible: (stemVolumeFilterProp_2.value <= 0.5) && (!stem2Mute.value || (stem2Mute.value && blinkOnOff))
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                    top: parent.top
                }

                color: "white"
                width: Math.min(stemVolumeFilterProp_2.value * 2 * parent.width, 36)
              }
            }
          }

          Item {
            anchors {
              bottom: parent.bottom
              right: parent.right
              bottomMargin: 14
            }
            width: 46
            height: 12

            Rectangle {
              color: (!blinkOnOff && stem3Mute.value) || (((stemVolumeFilterProp_3.value == 0) || (stemVolumeFilterProp_3.value == 1)) && !stem3Mute.value) ? "white" : "black"
              anchors {
                bottom: parent.bottom
                left: parent.left
                leftMargin: -1
              }
              width: 7
              height: 9
            }

            ThinText {
              anchors {
                  bottom: parent.bottom
                  left: parent.left
                  bottomMargin: -2
                }
                font.pixelSize: 12
                horizontalAlignment: Text.AlignRight
                text: "O"
                color: (!blinkOnOff && stem3Mute.value) || (((stemVolumeFilterProp_3.value == 0) || (stemVolumeFilterProp_3.value == 1)) && !stem3Mute.value) ? "black" : "white"
            }

            Image {
              anchors {
                  bottom: parent.bottom
                  right: parent.right
              }

              source:    "Images/StemMeter.png"
              fillMode:  Image.PreserveAspectFit

              // Other level
              Rectangle
              {
                visible: (stemVolumeFilterProp_3.value > 0.5) && (!stem3Mute.value || (stem3Mute.value && blinkOnOff))
                anchors {
                    bottom: parent.bottom
                    right: parent.right
                    top: parent.top
                }

                color: "white"
                width: Math.min((1.0 - stemVolumeFilterProp_3.value) * 2 * parent.width, 36)
              }
              
              Rectangle
              {
                visible: (stemVolumeFilterProp_3.value <= 0.5) && (!stem3Mute.value || (stem3Mute.value && blinkOnOff))
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                    top: parent.top
                }

                color: "white"
                width: Math.min(stemVolumeFilterProp_3.value * 2 * parent.width, 36)
              }
            }
          }

          Item {
            anchors {
              bottom: parent.bottom
              right: parent.right
              bottomMargin: 2
            }
            width: 46
            height: 12

            Rectangle {
              color: (!blinkOnOff && stem4Mute.value) || (((stemVolumeFilterProp_4.value == 0) || (stemVolumeFilterProp_4.value == 1)) && !stem4Mute.value) ? "white" : "black"
              anchors {
                bottom: parent.bottom
                left: parent.left
                leftMargin: -1
              }
              width: 7
              height: 9
            }

            ThinText {
              anchors {
                  bottom: parent.bottom
                  left: parent.left
                  bottomMargin: -2
                }
                font.pixelSize: 12
                horizontalAlignment: Text.AlignRight
                text: "V"
                color: (!blinkOnOff && stem4Mute.value) || (((stemVolumeFilterProp_4.value == 0) || (stemVolumeFilterProp_4.value == 1)) && !stem4Mute.value) ? "black" : "white"
            }

            Image {
              anchors {
                  bottom: parent.bottom
                  right: parent.right
              }

              source:    "Images/StemMeter.png"
              fillMode:  Image.PreserveAspectFit

              // Vocal level
              Rectangle
              {
                visible: (stemVolumeFilterProp_4.value > 0.5) && (!stem4Mute.value || (stem4Mute.value && blinkOnOff))
                anchors {
                    bottom: parent.bottom
                    right: parent.right
                    top: parent.top
                }

                color: "white"
                width: Math.min((1.0 - stemVolumeFilterProp_4.value) * 2 * parent.width, 36)
              }
              
              Rectangle
              {
                visible: (stemVolumeFilterProp_4.value <= 0.5) && (!stem4Mute.value || (stem4Mute.value && blinkOnOff))
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                    top: parent.top
                }

                color: "white"
                width: Math.min(stemVolumeFilterProp_4.value * 2 * parent.width, 36)
              }
            }
          }
        }

        // Remix Slot indicators
        Item {
          visible: isRemixOverlayActive
          anchors.fill: parent

          Item {
            anchors {
              bottom: parent.bottom
              right: parent.right
              bottomMargin: 38
            }
            width: 46
            height: 12

            Rectangle {
              color: (!blinkOnOff && remixSlot1Mute.value) || (((remixPlayersVolumeFilterProp_1.value == 0) || (remixPlayersVolumeFilterProp_1.value == 1)) && !remixSlot1Mute.value) ? "white" : "black"
              anchors {
                bottom: parent.bottom
                left: parent.left
                leftMargin: -1
              }
              width: 7
              height: 9
            }

            ThinText {
              anchors {
                  bottom: parent.bottom
                  left: parent.left
                  bottomMargin: -2
                }
                font.pixelSize: 12
                horizontalAlignment: Text.AlignRight
                text: "1"
                color: (!blinkOnOff && remixSlot1Mute.value) || (((remixPlayersVolumeFilterProp_1.value == 0) || (remixPlayersVolumeFilterProp_1.value == 1)) && !remixSlot1Mute.value) ? "black" : "white"
            }

            Image {
              anchors {
                  bottom: parent.bottom
                  right: parent.right
              }

              source:    "Images/StemMeter.png"
              fillMode:  Image.PreserveAspectFit

              // Slot 1 Level
              Rectangle
              {
                visible: (remixPlayersVolumeFilterProp_1.value > 0.5) && (!remixSlot1Mute.value || (remixSlot1Mute.value && blinkOnOff))
                anchors {
                    bottom: parent.bottom
                    right: parent.right
                    top: parent.top
                }

                color: "white"
                width: Math.min((1.0 - remixPlayersVolumeFilterProp_1.value) * 2 * parent.width, 36)
              }
              
              Rectangle
              {
                visible: (remixPlayersVolumeFilterProp_1.value <= 0.5) && (!remixSlot1Mute.value || (remixSlot1Mute.value && blinkOnOff))
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                    top: parent.top
                }

                color: "white"
                width: Math.min(remixPlayersVolumeFilterProp_1.value * 2 * parent.width, 36)
              }
            }
          }

          Item {
            anchors {
              bottom: parent.bottom
              right: parent.right
              bottomMargin: 26
            }
            width: 46
            height: 12

            Rectangle {
              color: (!blinkOnOff && remixSlot2Mute.value) || (((remixPlayersVolumeFilterProp_2.value == 0) || (remixPlayersVolumeFilterProp_2.value == 1)) && !remixSlot2Mute.value) ? "white" : "black"
              anchors {
                bottom: parent.bottom
                left: parent.left
                leftMargin: -1
              }
              width: 7
              height: 9
            }

            ThinText {
              anchors {
                  bottom: parent.bottom
                  left: parent.left
                  bottomMargin: -2
                }
                font.pixelSize: 12
                horizontalAlignment: Text.AlignRight
                text: "2"
                color: (!blinkOnOff && remixSlot2Mute.value) || (((remixPlayersVolumeFilterProp_2.value == 0) || (remixPlayersVolumeFilterProp_2.value == 1)) && !remixSlot2Mute.value) ? "black" : "white"
            }

            Image {
              anchors {
                  bottom: parent.bottom
                  right: parent.right
              }

              source:    "Images/StemMeter.png"
              fillMode:  Image.PreserveAspectFit

              // Slot 2 level
              Rectangle
              {
                visible: (remixPlayersVolumeFilterProp_2.value > 0.5) && (!remixSlot2Mute.value || (remixSlot2Mute.value && blinkOnOff))
                anchors {
                    bottom: parent.bottom
                    right: parent.right
                    top: parent.top
                }

                color: "white"
                width: Math.min((1.0 - remixPlayersVolumeFilterProp_2.value) * 2 * parent.width, 36)
              }
              
              Rectangle
              {
                visible: (remixPlayersVolumeFilterProp_2.value <= 0.5) && (!remixSlot2Mute.value || (remixSlot2Mute.value && blinkOnOff))
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                    top: parent.top
                }

                color: "white"
                width: Math.min(remixPlayersVolumeFilterProp_2.value * 2 * parent.width, 36)
              }
            }
          }

          Item {
            anchors {
              bottom: parent.bottom
              right: parent.right
              bottomMargin: 14
            }
            width: 46
            height: 12

            Rectangle {
              color: (!blinkOnOff && remixSlot3Mute.value) || (((remixPlayersVolumeFilterProp_3.value == 0) || (remixPlayersVolumeFilterProp_3.value == 1)) && !remixSlot3Mute.value) ? "white" : "black"
              anchors {
                bottom: parent.bottom
                left: parent.left
                leftMargin: -1
              }
              width: 7
              height: 9
            }

            ThinText {
              anchors {
                  bottom: parent.bottom
                  left: parent.left
                  bottomMargin: -2
                }
                font.pixelSize: 12
                horizontalAlignment: Text.AlignRight
                text: "3"
                color: (!blinkOnOff && remixSlot3Mute.value) || (((remixPlayersVolumeFilterProp_3.value == 0) || (remixPlayersVolumeFilterProp_3.value == 1)) && !remixSlot3Mute.value) ? "black" : "white"
            }

            Image {
              anchors {
                  bottom: parent.bottom
                  right: parent.right
              }

              source:    "Images/StemMeter.png"
              fillMode:  Image.PreserveAspectFit

              // Slot 3 level
              Rectangle
              {
                visible: (remixPlayersVolumeFilterProp_3.value > 0.5) && (!remixSlot3Mute.value || (remixSlot3Mute.value && blinkOnOff))
                anchors {
                    bottom: parent.bottom
                    right: parent.right
                    top: parent.top
                }

                color: "white"
                width: Math.min((1.0 - remixPlayersVolumeFilterProp_3.value) * 2 * parent.width, 36)
              }
              
              Rectangle
              {
                visible: (remixPlayersVolumeFilterProp_3.value <= 0.5) && (!remixSlot3Mute.value || (remixSlot3Mute.value && blinkOnOff))
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                    top: parent.top
                }

                color: "white"
                width: Math.min(remixPlayersVolumeFilterProp_3.value * 2 * parent.width, 36)
              }
            }
          }

          Item {
            anchors {
              bottom: parent.bottom
              right: parent.right
              bottomMargin: 2
            }
            width: 46
            height: 12

            Rectangle {
              color: (!blinkOnOff && remixSlot4Mute.value) || (((remixPlayersVolumeFilterProp_4.value == 0) || (remixPlayersVolumeFilterProp_4.value == 1)) && !remixSlot4Mute.value) ? "white" : "black"
              anchors {
                bottom: parent.bottom
                left: parent.left
                leftMargin: -1
              }
              width: 7
              height: 9
            }

            ThinText {
              anchors {
                  bottom: parent.bottom
                  left: parent.left
                  bottomMargin: -2
                }
                font.pixelSize: 12
                horizontalAlignment: Text.AlignRight
                text: "4"
                color: (!blinkOnOff && remixSlot4Mute.value) || (((remixPlayersVolumeFilterProp_4.value == 0) || (remixPlayersVolumeFilterProp_4.value == 1)) && !remixSlot4Mute.value) ? "black" : "white"
            }

            Image {
              anchors {
                  bottom: parent.bottom
                  right: parent.right
              }

              source:    "Images/StemMeter.png"
              fillMode:  Image.PreserveAspectFit

              // Slot 4 level
              Rectangle
              {
                visible: (remixPlayersVolumeFilterProp_4.value > 0.5) && (!remixSlot4Mute.value || (remixSlot4Mute.value && blinkOnOff))
                anchors {
                    bottom: parent.bottom
                    right: parent.right
                    top: parent.top
                }

                color: "white"
                width: Math.min((1.0 - remixPlayersVolumeFilterProp_4.value) * 2 * parent.width, 36)
              }
              
              Rectangle
              {
                visible: (remixPlayersVolumeFilterProp_4.value <= 0.5) && (!remixSlot4Mute.value || (remixSlot4Mute.value && blinkOnOff))
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                    top: parent.top
                }

                color: "white"
                width: Math.min(remixPlayersVolumeFilterProp_4.value * 2 * parent.width, 36)
              }
            }
          }
        }
      }
      

      // Parameter overlay
      Item
      {
        // visible: !(isPatternPlayer && (!knobsAreActive || lastTouchedKnob == 2))
        visible: isSingleGroupFx || (isPatternPlayer && (knobsAreActive && lastTouchedKnob !== 2)) || (!isPatternPlayer && !isSingleGroupFx && knobsAreActive)
        anchors.fill: parent

        // // Pre-listen
        // Image {
          // anchors {
              // top: parent.top
              // left: parent.left
          // }

          // source:    "Images/Indicator.png"
          // fillMode:  Image.PreserveAspectFit
          // visible: fxSectionLayer == FXSectionLayer.mixer && deckCue.value
        // }

        ThinText {
            anchors {
                bottom: parent.bottom
                left: parent.left
                leftMargin: -13
                bottomMargin: -5
            }
            font.capitalization: Font.AllUppercase
            text: " " + (hasParameter(lastTouchedKnob) ? parameterName(lastTouchedKnob) : "EMPTY")
        }

        ThinText {
            id: valueText

            anchors {
                bottom: parent.bottom
                right: parent.right
                bottomMargin: -5
                rightMargin: -3
            }
            font.capitalization: Font.AllUppercase
            text: " " + (hasParameter(lastTouchedKnob) ? parameterValue(lastTouchedKnob) : "")
        }

        AnimatedImage {
            anchors {
                bottom: parent.bottom
                right: valueText.left
                rightMargin: -10
            }
            visible:   (softTakeoverDirection !== 0) && hasParameter(lastTouchedKnob)
            source:    softTakeoverDirection === 1 ? "Images/SoftTakeoverUp.gif" : "Images/SoftTakeoverDown.gif"
            fillMode:  Image.PreserveAspectFit
        }
      }
    }

    // Deck assignment
    Item {
      visible: deviceSetupState == DeviceSetupState.unassigned && lastTouchedButton == 0
      anchors.fill: parent

      Rectangle {
        color: blinkOnOff ? "white" : "black"
        anchors {
        horizontalCenter: parent.horizontalCenter
        verticalCenter: parent.verticalCenter
        }

        width: 120
        height: 44

        ThinText {
          anchors {
            top: parent.top
            left: parent.left
            topMargin: -10
            leftMargin: -20
          }
          font.pixelSize: 60
          font.capitalization: Font.AllUppercase

          text: " " + fxText[primaryFxUnitProp.value - 1]
          color: blinkOnOff ? "black" : "white"
        }
      }
    }
    
    // Custom Toggle Display
    Item {
      visible: deviceSetupState == DeviceSetupState.unassigned && lastTouchedButton != 0
      anchors.fill: parent

      Rectangle {
        // color: blinkOnOff ? "white" : "black"
        color: "black"
        anchors {
          horizontalCenter: parent.horizontalCenter
          verticalCenter: parent.verticalCenter
        }

        width: 120
        // height: 44
        height: 56

        ThinText {
          // anchors {
            // top: parent.top
            // left: parent.left
            // topMargin: -10
            // leftMargin: -20
          // }
          anchors {
              top: parent.top
              left: parent.left
              right: parent.right
              topMargin: 0
              leftMargin: 1
          }
          // font.pixelSize: 30
          font.pixelSize: 24
          font.capitalization: Font.AllUppercase

          text: "" + setupText
          wrapMode: Text.Wrap
          // color: blinkOnOff ? "black" : "white"
          color: "white"
        }
      }
    }
    
  }
  
}
