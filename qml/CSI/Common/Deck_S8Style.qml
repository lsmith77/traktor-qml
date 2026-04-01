import CSI 1.0
import QtQuick 2.0

import "../../Defines"

Module
{
  id: module
  property bool   useMIDIControls: false
  property string surface
  property int    decksAssignment: DecksAssignment.AC
  property string settingsPath:    "path"
  property string propertiesPath:  "path"
  property alias  deckFocus:       deckFocusProp.value

  property bool   keyOrBPMOverlay: false;
  property bool   tempBPMOverlay:  false;

  readonly property double syncPhase: (syncPhaseProp.value * 2.0).toFixed(2)

  //------------------------------------------------------------------------------------------------------------------

  function initializeModule()
  {
    updateFocusDependentDeckTypes();
    updateDeckPadsMode(topDeckType, topDeckPadsMode);
    updateDeckPadsMode(bottomDeckType, bottomDeckPadsMode);
  }


  MappingPropertyDescriptor {
    id: screenOverlay;
    path: propertiesPath + ".overlay";
    type: MappingPropertyDescriptor.Integer;
    value: Overlay.none;
    onValueChanged: {
      keyOrBPMOverlay = screenOverlay.value == Overlay.bpm || screenOverlay.value == Overlay.key || screenOverlay.value == Overlay.mixerFx;
      if (value == Overlay.fx) {
        editMode.value  = editModeNone;
      }
      // idle timeout for BPM and Key overlays
      if (keyOrBPMOverlay) {
        overlay_countdown.restart();
      }
    }
  }
  
  MappingPropertyDescriptor { path: propertiesPath + ".top_info_show"; type: MappingPropertyDescriptor.Boolean; value: false }
  MappingPropertyDescriptor { path: propertiesPath + ".bottom_info_show"; type: MappingPropertyDescriptor.Boolean; value: false }

  AppProperty { id: masterDeckIdProp; path: "app.traktor.masterclock.source_id" }
  AppProperty { id: isTempoSynced;    path: "app.traktor.decks." + (focusedDeckId) + ".sync.enabled" }
  AppProperty { id: syncPhaseProp;    path: "app.traktor.decks." + (focusedDeckId) + ".tempo.phase"; }
  AppProperty { id: mixerFxSelect;    path: "app.traktor.mixer.channels." + focusedDeckId + ".fx.select" }

  AppProperty { 
    path: "app.traktor.masterclock.tempo"; 
    onValueChanged: { 
      var masterDeckId = masterDeckIdProp.value + 1;
      if( screenOverlay.value == Overlay.bpm && (isTempoSynced.value || masterDeckId == focusedDeckId) )
        overlay_countdown.restart(); 
    } 
  }

  //------------------------------------------------------------------------------------------------------------------
  //  KEY/BPM IDLE TIMEOUT METHODS
  //------------------------------------------------------------------------------------------------------------------

  Timer {
    id: overlay_countdown;
    interval: 5000;
    onTriggered:
    {
      if (keyOrBPMOverlay) {
        screenOverlay.value = Overlay.none;
      }
    }
  }

  Wire {
    enabled: keyOrBPMOverlay
    from: Or
    {
      inputs:
      [
        "%surface%.browse.push",
        "%surface%.browse.touch",
        "%surface%.browse.is_turned",
        "%surface%.back"
      ]
    }
    to: ButtonScriptAdapter{
        onPress: overlay_countdown.stop()
        onRelease: overlay_countdown.restart()
    }
  }

//------------------------------------------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------------------------------------------


  MappingPropertyDescriptor { id: screenIsSingleDeck;  path: propertiesPath + ".deck_single";   type: MappingPropertyDescriptor.Boolean; value: true }

  MappingPropertyDescriptor { id: deckFocusProp;
    path: propertiesPath + ".deck_focus";
    type: MappingPropertyDescriptor.Boolean;
    value: false;
    onValueChanged: {
      updateFocusDependentDeckTypes();
      updateFooter();
      updatePads();
      updateEncoder();
      if(screenViewProp.value  == ScreenView.deck) {
        screenOverlay.value  = Overlay.none;
      }
      editMode.value  = editModeNone;
    }
  }

  readonly property int focusedDeckId:   (deckFocus ? bottomDeckId : topDeckId)
  readonly property int unfocusedDeckId: (deckFocus ? topDeckId : bottomDeckId)

  readonly property int padsFocusedDeckId:    (padsFocus.value    ? bottomDeckId : topDeckId)
  readonly property int footerFocusedDeckId:  (footerFocus.value  ? bottomDeckId : topDeckId)
  readonly property int encoderFocusedDeckId: (encoderFocus.value ? bottomDeckId : topDeckId)

  property int topDeckType:    (decksAssignment == DecksAssignment.AC ? deckAType : deckBType)
  property int bottomDeckType: (decksAssignment == DecksAssignment.AC ? deckCType : deckDType)

  property int focusedDeckType
  property int unfocusedDeckType

  function updateFocusDependentDeckTypes()
  {
    focusedDeckType   = (deckFocus ? bottomDeckType : topDeckType);
    unfocusedDeckType = (deckFocus ? topDeckType : bottomDeckType);
  }

  onTopDeckTypeChanged:
  {
    updateFocusDependentDeckTypes();
    updateEditMode();
    updateEncoder();

    defaultFooterPage(topDeckType, topDeckRemixMode, topDeckFooterPage);

    updateDeckPadsMode(topDeckType, topDeckPadsMode);
    validateDeckPadsMode(bottomDeckType, topDeckType, bottomDeckPadsMode);
  }

  onBottomDeckTypeChanged:
  {
    updateFocusDependentDeckTypes();
    updateEditMode();
    updateEncoder();

    defaultFooterPage(bottomDeckType, bottomDeckRemixMode, bottomDeckFooterPage);

    updateDeckPadsMode(bottomDeckType, bottomDeckPadsMode);
    validateDeckPadsMode(topDeckType, bottomDeckType, topDeckPadsMode);
  }

  onFocusedDeckTypeChanged:
  {
    showDisplayButtonArea.value = true;
    screenOverlay.value = Overlay.none;
  }

  AppProperty { id: deckAIsLoaded; path: "app.traktor.decks.1.is_loaded" }
  AppProperty { id: deckBIsLoaded; path: "app.traktor.decks.2.is_loaded" }
  AppProperty { id: deckCIsLoaded; path: "app.traktor.decks.3.is_loaded" }
  AppProperty { id: deckDIsLoaded; path: "app.traktor.decks.4.is_loaded" }

  readonly property bool footerHasDetails:  module.useMIDIControls || (fxMode.value == FxMode.FourFxUnits)
                                            || (hasBottomControls(deckAType) && decksAssignment == DecksAssignment.AC)
                                            || (hasBottomControls(deckCType) && decksAssignment == DecksAssignment.AC)
                                            || (hasBottomControls(deckBType) && decksAssignment == DecksAssignment.BD)
                                            || (hasBottomControls(deckDType) && decksAssignment == DecksAssignment.BD)

  readonly property bool footerShouldPopup: module.useMIDIControls || (fxMode.value == FxMode.FourFxUnits)
                                            || (hasBottomControls(deckAType) && deckAIsLoaded.value && decksAssignment == DecksAssignment.AC)
                                            || (hasBottomControls(deckCType) && deckCIsLoaded.value && decksAssignment == DecksAssignment.AC)
                                            || (hasBottomControls(deckBType) && deckBIsLoaded.value && decksAssignment == DecksAssignment.BD)
                                            || (hasBottomControls(deckDType) && deckDIsLoaded.value && decksAssignment == DecksAssignment.BD)

  MappingPropertyDescriptor { id: browserIsTemporary;          path: propertiesPath + ".browser.is_temporary";            type: MappingPropertyDescriptor.Boolean; value: false }
  MappingPropertyDescriptor { id: browserFullScreenWasOpen;  path: propertiesPath + ".browser.full_screen_was_open";  type: MappingPropertyDescriptor.Boolean; value: false }
  property bool browserFullScreenActive: false

  //------------------------------------------------------------------------------------------------------------------
  //  GENERIC PURPOSE CONSTANTS
  //------------------------------------------------------------------------------------------------------------------  

  readonly property real onBrightness:     1.0
  readonly property real dimmedBrightness: 0.0

  readonly property int touchstripLedBarSize: 25

  //------------------------------------------------------------------------------------------------------------------
  // DECK TYPES of Deck A, B, C and D
  //------------------------------------------------------------------------------------------------------------------

  AppProperty { id: deckADeckType;   path: "app.traktor.decks.1.type" }
  AppProperty { id: deckBDeckType;   path: "app.traktor.decks.2.type" }
  AppProperty { id: deckCDeckType;   path: "app.traktor.decks.3.type" }
  AppProperty { id: deckDDeckType;   path: "app.traktor.decks.4.type" }
  AppProperty { id: deckADirectThru; path: "app.traktor.decks.1.direct_thru" }
  AppProperty { id: deckBDirectThru; path: "app.traktor.decks.2.direct_thru" }
  AppProperty { id: deckCDirectThru; path: "app.traktor.decks.3.direct_thru" }
  AppProperty { id: deckDDirectThru; path: "app.traktor.decks.4.direct_thru" }

  readonly property int thruDeckType:   4
  readonly property int deckAType : deckADirectThru.value ? thruDeckType : deckADeckType.value;
  readonly property int deckBType : deckBDirectThru.value ? thruDeckType : deckBDeckType.value;
  readonly property int deckCType : deckCDirectThru.value ? thruDeckType : deckCDeckType.value;
  readonly property int deckDType : deckDDirectThru.value ? thruDeckType : deckDDeckType.value;

  function hasEditMode       (deckType) { return deckType == DeckType.Track  || deckType == DeckType.Stem;}
  function hasHotcues        (deckType) { return deckType == DeckType.Track  || deckType == DeckType.Stem;}
  function hasSeek           (deckType) { return deckType == DeckType.Track  || deckType == DeckType.Stem;}
  function hasWaveform       (deckType) { return deckType == DeckType.Track  || deckType == DeckType.Stem;}
  function hasBpmAdjust      (deckType) { return deckType == DeckType.Track  || deckType == DeckType.Stem || deckType == DeckType.Remix;}
  function hasKeylock        (deckType) { return deckType == DeckType.Track  || deckType == DeckType.Stem;}

  function hasTransport      (deckType) { return deckType == DeckType.Track  || deckType == DeckType.Stem || deckType == DeckType.Remix;}
  function hasButtonArea     (deckType) { return deckType == DeckType.Track  || deckType == DeckType.Stem || deckType == DeckType.Remix;}
  function hasLoopMode       (deckType) { return deckType == DeckType.Track  || deckType == DeckType.Stem || deckType == DeckType.Remix;}
  function hasFreezeMode     (deckType) { return deckType == DeckType.Track  || deckType == DeckType.Stem || deckType == DeckType.Remix;}

  function hasBottomControls (deckType) { return deckType == DeckType.Remix ||  deckType == DeckType.Stem;}

  function hasPitchPage      (deckType, remixMode) { return (deckType == DeckType.Remix && !remixMode); }
  function hasFilterPage     (deckType, remixMode) { return (deckType == DeckType.Remix && !remixMode) || deckType == DeckType.Stem; }
  function hasFxSendPage     (deckType, remixMode) { return (deckType == DeckType.Remix && !remixMode) || deckType == DeckType.Stem; }
  function hasSlotPages      (deckType, remixMode) { return (deckType == DeckType.Remix && remixMode); }

  function hasRemixMode      (deckType) { return deckType == DeckType.Remix; }

  //------------------------------------------------------------------------------------------------------------------
  //  Soft takeover faders & knobs
  //------------------------------------------------------------------------------------------------------------------ 

  SoftTakeoverIndicator
  {
    name: "softtakeover_faders1"
    surfaceObject: surface + ".faders.1"
    propertiesPath: module.propertiesPath + ".softtakeover.faders.1";
  }

  SoftTakeoverIndicator
  {
    name: "softtakeover_faders2"
    surfaceObject: surface + ".faders.2"
    propertiesPath: module.propertiesPath + ".softtakeover.faders.2";
  }

  SoftTakeoverIndicator
  {
    name: "softtakeover_faders3"
    surfaceObject: surface + ".faders.3"
    propertiesPath: module.propertiesPath + ".softtakeover.faders.3";
  }

  SoftTakeoverIndicator
  {
    name: "softtakeover_faders4"
    surfaceObject: surface + ".faders.4"
    propertiesPath: module.propertiesPath + ".softtakeover.faders.4";
  }

  SoftTakeoverIndicator
  {
    name: "softtakeover_knobs1"
    surfaceObject: surface + ".fx.knobs.1"
    propertiesPath: module.propertiesPath + ".softtakeover.knobs.1";
  }

  SoftTakeoverIndicator
  {
    name: "softtakeover_knobs2"
    surfaceObject: surface + ".fx.knobs.2"
    propertiesPath: module.propertiesPath + ".softtakeover.knobs.2";
  }

  SoftTakeoverIndicator
  {
    name: "softtakeover_knobs3"
    surfaceObject: surface + ".fx.knobs.3"
    propertiesPath: module.propertiesPath + ".softtakeover.knobs.3";
  }

  SoftTakeoverIndicator
  {
    name: "softtakeover_knobs4"
    surfaceObject: surface + ".fx.knobs.4"
    propertiesPath: module.propertiesPath + ".softtakeover.knobs.4";
  }

  MappingPropertyDescriptor { id: showSofttakeoverKnobs;  path: propertiesPath + ".softtakeover.show_knobs";   type: MappingPropertyDescriptor.Boolean; value: false }
  MappingPropertyDescriptor { id: showSofttakeoverFaders; path: propertiesPath + ".softtakeover.show_faders";  type: MappingPropertyDescriptor.Boolean; value: false }

  SwitchTimer { name: "softtakeover_knobs_timer";  resetTimeout: 300 }
  SwitchTimer { name: "softtakeover_faders_timer"; resetTimeout: 300 }

  Wire
  {
    from:
      Or
      {
        inputs:
        [
          "softtakeover_knobs1.indicate",
          "softtakeover_knobs2.indicate",
          "softtakeover_knobs3.indicate",
          "softtakeover_knobs4.indicate"
        ]
      }
    to: "softtakeover_knobs_timer.input"
  }

  Wire
  {
    from:
      Or
      {
        inputs:
        [
          "softtakeover_faders1.indicate",
          "softtakeover_faders2.indicate",
          "softtakeover_faders3.indicate",
          "softtakeover_faders4.indicate"
        ]
      }
    to: "softtakeover_faders_timer.input"
  }

  //------------------------------------------------------------------------------------------------------------------
  //  GENERIC PURPOSE PROPERTIES
  //------------------------------------------------------------------------------------------------------------------  

  AppProperty { id: fxMode; path: "app.traktor.fx.4fx_units"; onValueChanged: { defaultFooterPage(topDeckType, topDeckRemixMode, topDeckFooterPage); defaultFooterPage(bottomDeckType, bottomDeckRemixMode, bottomDeckFooterPage); } }

  AppProperty { id: deckALoopActive;   path: "app.traktor.decks.1.loop.is_in_active_loop" }
  AppProperty { id: deckBLoopActive;   path: "app.traktor.decks.2.loop.is_in_active_loop" }
  AppProperty { id: deckCLoopActive;   path: "app.traktor.decks.3.loop.is_in_active_loop" }
  AppProperty { id: deckDLoopActive;   path: "app.traktor.decks.4.loop.is_in_active_loop" }

  function getTopDeckId(assignment)
  {
    switch (assignment)
    {
      case DecksAssignment.AC: return 1;
      case DecksAssignment.BD: return 2;
    }
  }

  function getBottomDeckId(assignment)
  {
    switch (assignment)
    {
      case DecksAssignment.AC: return 3;
      case DecksAssignment.BD: return 4;
    }
  }

  property int topDeckId: getTopDeckId(decksAssignment);
  property int bottomDeckId: getBottomDeckId(decksAssignment);

  //------------------------------------------------------------------------------------------------------------------
  // ENCODER FOCUS AND MODE
  //------------------------------------------------------------------------------------------------------------------

  // Constants to use in enablers for loop encoder modes
  readonly property int encoderLoopMode:    1
  readonly property int encoderSlicerMode:  2
  readonly property int encoderRemixMode:   3
  readonly property int encoderCaptureMode: 4

  MappingPropertyDescriptor { id: encoderMode;   path: propertiesPath + ".encoder_mode";     type: MappingPropertyDescriptor.Integer;  value: encoderLoopMode  }
  MappingPropertyDescriptor { id: encoderFocus;  path: propertiesPath + ".encoder_focus";    type: MappingPropertyDescriptor.Boolean;  value: false            }

  //------------------------------------------------------------------------------------------------------------------

  MappingPropertyDescriptor { id: captureState;  path: propertiesPath + ".capture";  type: MappingPropertyDescriptor.Boolean;  value: false; onValueChanged: updateEncoder(); }
  MappingPropertyDescriptor { id: freezeState;   path: propertiesPath + ".freeze";   type: MappingPropertyDescriptor.Boolean;  value: false; onValueChanged: updateEncoder(); }
  MappingPropertyDescriptor { id: remixState;    path: propertiesPath + ".remix";    type: MappingPropertyDescriptor.Boolean;  value: false; onValueChanged: updateEncoder(); }

  function updateEncoder()
  {
    if (!freezeState.value && !remixState.value && !captureState.value)
    {
      encoderMode.value = encoderLoopMode;
    }
    else if (freezeState.value && !remixState.value)
    {
      encoderMode.value = encoderSlicerMode;
    }
    else if (captureState.value && !remixState.value)
    {
      encoderMode.value = encoderCaptureMode;
    }
    else
    {
      encoderMode.value = encoderRemixMode;
    }

    if (encoderMode.value == encoderCaptureMode || encoderMode.value == encoderRemixMode)
    {
      if (topDeckType == DeckType.Remix && bottomDeckType == DeckType.Remix)
      {
        encoderFocus.value = deckFocus;
      }
      else if (topDeckType == DeckType.Remix)
      {
        encoderFocus.value = false;
      }
      else if (bottomDeckType == DeckType.Remix)
      {
        encoderFocus.value = true;
      }
    }
    else
    {
      encoderFocus.value = deckFocus;
    }
  }

  //------------------------------------------------------------------------------------------------------------------
  //  RESET TO DECK VIEW AFTER LOAD
  //  After a deck has been loaded with new content the controller display is reset to default deck view
  //------------------------------------------------------------------------------------------------------------------

  AppProperty { path: "app.traktor.decks.1.is_loaded_signal";  onValueChanged: onDeckLoaded(1); }
  AppProperty { path: "app.traktor.decks.2.is_loaded_signal";  onValueChanged: onDeckLoaded(2); }
  AppProperty { path: "app.traktor.decks.3.is_loaded_signal";  onValueChanged: onDeckLoaded(3); }
  AppProperty { path: "app.traktor.decks.4.is_loaded_signal";  onValueChanged: onDeckLoaded(4); }

  function onDeckLoaded(deckId)
  {
    if (deckId == topDeckId || deckId == bottomDeckId)
    {
      if (screenViewProp.value == ScreenView.browser)
      {
        screenViewProp.value = ScreenView.deck;
      }
    }

    // Post-duplicate setup: apply stem split and auto-play when the target deck finishes loading.
    if (deckId > 0 && deckId == duplicateDeckPendingTargetId)
    {
      // Target deck: mute vocals (stem 4), unmute instrumentals (stems 1-3).
      dupTargetStem1Muted.value = false
      dupTargetStem2Muted.value = false
      dupTargetStem3Muted.value = false
      dupTargetStem4Muted.value = true
      // Start playing target deck if source was already running.
      if (duplicateDeckSourceWasRunning)
      {
        dupTargetPlay.value = true
      }
      duplicateDeckPendingTargetId = -1
    }
  }

  //------------------------------------------------------------------------------------------------------------------
  // PERFORMANCE CONTROLS PAGE AND FOCUS
  //------------------------------------------------------------------------------------------------------------------

  MappingPropertyDescriptor { id: footerPage;   path: propertiesPath + ".footer_page";    type: MappingPropertyDescriptor.Integer;  value: FooterPage.empty }
  MappingPropertyDescriptor { id: footerFocus;  path: propertiesPath + ".footer_focus";   type: MappingPropertyDescriptor.Boolean;  value: false     }

  MappingPropertyDescriptor { id: topDeckFooterPage;   path: propertiesPath + ".top.footer_page";  type: MappingPropertyDescriptor.Integer;  value: FooterPage.empty;  onValueChanged: updateFooter(); }
  MappingPropertyDescriptor { id: bottomDeckFooterPage;   path: propertiesPath + ".bottom.footer_page";  type: MappingPropertyDescriptor.Integer;  value: FooterPage.empty;  onValueChanged: updateFooter(); }

  onUseMIDIControlsChanged: { defaultFooterPage(topDeckType, topDeckRemixMode, topDeckFooterPage); defaultFooterPage(bottomDeckType, bottomDeckRemixMode, bottomDeckFooterPage); }

  function defaultFooterPage(deckType, deckRemixMode, footerPage)
  {
    if (!validateFooterPage(deckType, deckRemixMode, footerPage.value))
    {
      if (hasFilterPage(deckType, deckRemixMode))
      {
        footerPage.value = FooterPage.filter;
      }
      else if (hasSlotPages(deckType, deckRemixMode))
      {
          footerPage.value = FooterPage.slot1;
      }
      else if (fxMode.value == FxMode.FourFxUnits)
      {
        footerPage.value = FooterPage.fx;
      }
      else if (module.useMIDIControls)
      {
        footerPage.value = FooterPage.midi;
      }
      else
      {
        footerPage.value = FooterPage.empty;
      }
    }
  }

  function updateFooter()
    {
    var upperDeckHasControls = hasBottomControls(topDeckType);
    var lowerDeckHasControls = hasBottomControls(bottomDeckType);

    if (lowerDeckHasControls && upperDeckHasControls)
      {
      footerFocus.value = deckFocus;
      }
    else if (lowerDeckHasControls)
      {
      footerFocus.value = true;
      }
    else if (upperDeckHasControls)
    {
      footerFocus.value = false;
    }
    else
    {
      footerFocus.value = false;
    }

      footerPage.value = (footerFocus.value ? bottomDeckFooterPage.value : topDeckFooterPage.value);
    }

  //------------------------------------------------------------------------------------------------------------------
  // WAVEFORM ZOOM LEVEL
  //------------------------------------------------------------------------------------------------------------------

  MappingPropertyDescriptor { path: settingsPath + ".top.waveform_zoom";       type: MappingPropertyDescriptor.Integer;   value: 9;   min: 0;  max: 9;   }
  MappingPropertyDescriptor { path: settingsPath + ".bottom.waveform_zoom";    type: MappingPropertyDescriptor.Integer;   value: 9;   min: 0;  max: 9;   }

  //------------------------------------------------------------------------------------------------------------------
  // STEM DECK STYLE (Track- or DAW-deck style)
  //------------------------------------------------------------------------------------------------------------------

  MappingPropertyDescriptor { path: propertiesPath + ".top.stem_deck_style";    type: MappingPropertyDescriptor.Integer;  value: StemStyle.daw  }
  MappingPropertyDescriptor { path: propertiesPath + ".bottom.stem_deck_style"; type: MappingPropertyDescriptor.Integer;  value: StemStyle.daw  }

  //------------------------------------------------------------------------------------------------------------------
  // REMIX DECK STYLE (Remixdeck style)
  //------------------------------------------------------------------------------------------------------------------

  AppProperty { id: deckASequencerOn;   path: "app.traktor.decks.1.remix.sequencer.on" }
  AppProperty { id: deckBSequencerOn;   path: "app.traktor.decks.2.remix.sequencer.on" }
  AppProperty { id: deckCSequencerOn;   path: "app.traktor.decks.3.remix.sequencer.on" }
  AppProperty { id: deckDSequencerOn;   path: "app.traktor.decks.4.remix.sequencer.on" }

  // "Remix mode" is a secretive way to mean "Step sequencer on" since we have all this code under feature toggle!
  property bool topDeckRemixMode:    (decksAssignment == DecksAssignment.AC ? deckASequencerOn.value : deckBSequencerOn.value)
  property bool bottomDeckRemixMode: (decksAssignment == DecksAssignment.AC ? deckCSequencerOn.value : deckDSequencerOn.value)

  onTopDeckRemixModeChanged: { defaultFooterPage(topDeckType, topDeckRemixMode, topDeckFooterPage); updateSlotFooterPage(); }
  onBottomDeckRemixModeChanged: { defaultFooterPage(bottomDeckType, bottomDeckRemixMode, bottomDeckFooterPage); updateSlotFooterPage(); }

  MappingPropertyDescriptor { id: sequencerSampleLock; path: propertiesPath + ".sequencer_sample_lock";      type: MappingPropertyDescriptor.Boolean; value: false }

  MappingPropertyDescriptor { id: topSequencerSlot;    path: propertiesPath + ".top.sequencer_deck_slot";    type: MappingPropertyDescriptor.Integer;  value: 1; min: 1; max: 4; onValueChanged: updateSlotFooterPage(); }
  MappingPropertyDescriptor { id: bottomSequencerSlot; path: propertiesPath + ".bottom.sequencer_deck_slot"; type: MappingPropertyDescriptor.Integer;  value: 1; min: 1; max: 4; onValueChanged: updateSlotFooterPage(); }

  function updateSlotFooterPage()
  {
    var deckType = (footerFocus.value ? bottomDeckType : topDeckType);
    var remixMode = (footerFocus.value ? bottomDeckRemixMode : topDeckRemixMode);

    if ((deckType == DeckType.Remix) && remixMode)
    {
      var footerPage = (footerFocus.value ? bottomDeckFooterPage : topDeckFooterPage);
      var sequencerSlot = (footerFocus.value ? bottomSequencerSlot : topSequencerSlot);

      switch (sequencerSlot.value)
      {
        case 1:
          footerPage.value = FooterPage.slot1;
          break;

        case 2:
          footerPage.value = FooterPage.slot2;
          break;

        case 3:
          footerPage.value = FooterPage.slot3;
          break;

        case 4:
          footerPage.value = FooterPage.slot4;
          break;
      }
    }
  }

  DirectPropertyAdapter { name: "topSequencerSlot";    path: propertiesPath + ".top.sequencer_deck_slot"    }
  DirectPropertyAdapter { name: "bottomSequencerSlot"; path: propertiesPath + ".bottom.sequencer_deck_slot" }

  MappingPropertyDescriptor { id: topSequencerPage;    path: propertiesPath + ".top.sequencer_deck_page";    type: MappingPropertyDescriptor.Integer;  value: 1; min: 1; max: 2; }
  MappingPropertyDescriptor { id: bottomSequencerPage; path: propertiesPath + ".bottom.sequencer_deck_page"; type: MappingPropertyDescriptor.Integer;  value: 1; min: 1; max: 2; }

  DirectPropertyAdapter { name: "topSequencerPage";    path: propertiesPath + ".top.sequencer_deck_page"    }
  DirectPropertyAdapter { name: "bottomSequencerPage"; path: propertiesPath + ".bottom.sequencer_deck_page" }

  //------------------------------------------------------------------------------------------------------------------
  // SHOW/HIDE LOOP PREVIEW
  //------------------------------------------------------------------------------------------------------------------

  MappingPropertyDescriptor { path: propertiesPath + ".top.show_loop_size";    type: MappingPropertyDescriptor.Boolean; value: false }
  MappingPropertyDescriptor { path: propertiesPath + ".bottom.show_loop_size"; type: MappingPropertyDescriptor.Boolean; value: false }

  //------------------------------------------------------------------------------------------------------------------
  // PADS MODE AND FOCUS
  //------------------------------------------------------------------------------------------------------------------

  // Constants defining valid Mode values
  readonly property int disabledMode: 0
  readonly property int hotcueMode:   1
  readonly property int freezeMode:   2
  readonly property int loopMode:     3
  readonly property int remixMode:    4
  readonly property int stemMode:     5

  // D2 v0.4.0: Stem filter state per stem slot (shift+pads 5-8 toggle)
  AppProperty { id: sfxStem1FilterOn; path: "app.traktor.decks." + padsFocusedDeckId + ".stems.1.filter_on" }
  AppProperty { id: sfxStem2FilterOn; path: "app.traktor.decks." + padsFocusedDeckId + ".stems.2.filter_on" }
  AppProperty { id: sfxStem3FilterOn; path: "app.traktor.decks." + padsFocusedDeckId + ".stems.3.filter_on" }
  AppProperty { id: sfxStem4FilterOn; path: "app.traktor.decks." + padsFocusedDeckId + ".stems.4.filter_on" }

  // D2 v0.4.0: Dynamic AppProperties for the pad-focused deck's stems (stem FX pads 5-8).
  // Paths update automatically when padsFocusedDeckId changes.
  // Standard stem layout: Stem 1=Drums, Stem 2=Bass, Stem 3=Melody, Stem 4=Vocals.
  AppProperty { id: sfxStem1Muted;    path: "app.traktor.decks." + padsFocusedDeckId + ".stems.1.muted"      }
  AppProperty { id: sfxStem1FxSendOn; path: "app.traktor.decks." + padsFocusedDeckId + ".stems.1.fx_send_on" }
  AppProperty { id: sfxStem2Muted;    path: "app.traktor.decks." + padsFocusedDeckId + ".stems.2.muted"      }
  AppProperty { id: sfxStem2FxSendOn; path: "app.traktor.decks." + padsFocusedDeckId + ".stems.2.fx_send_on" }
  AppProperty { id: sfxStem3Muted;    path: "app.traktor.decks." + padsFocusedDeckId + ".stems.3.muted"      }
  AppProperty { id: sfxStem3FxSendOn; path: "app.traktor.decks." + padsFocusedDeckId + ".stems.3.fx_send_on" }
  AppProperty { id: sfxStem4Muted;    path: "app.traktor.decks." + padsFocusedDeckId + ".stems.4.muted"      }
  AppProperty { id: sfxStem4FxSendOn; path: "app.traktor.decks." + padsFocusedDeckId + ".stems.4.fx_send_on" }

  // Duplicate deck triggers — one per direction (source→target).
  AppProperty { id: dupDeck3From1; path: "app.traktor.decks.3.track.duplicate_deck.1" }  // AC: A→C
  AppProperty { id: dupDeck1From3; path: "app.traktor.decks.1.track.duplicate_deck.3" }  // AC: C→A
  AppProperty { id: dupDeck4From2; path: "app.traktor.decks.4.track.duplicate_deck.2" }  // BD: B→D
  AppProperty { id: dupDeck2From4; path: "app.traktor.decks.2.track.duplicate_deck.4" }  // BD: D→B

  // Dynamic bindings for the duplicate target deck — paths update when duplicateDeckPendingTargetId changes.
  // Used by onDeckLoaded to apply mutes and start playback after the load completes.
  AppProperty { id: dupTargetStem1Muted; path: "app.traktor.decks." + duplicateDeckPendingTargetId + ".stems.1.muted" }
  AppProperty { id: dupTargetStem2Muted; path: "app.traktor.decks." + duplicateDeckPendingTargetId + ".stems.2.muted" }
  AppProperty { id: dupTargetStem3Muted; path: "app.traktor.decks." + duplicateDeckPendingTargetId + ".stems.3.muted" }
  AppProperty { id: dupTargetStem4Muted; path: "app.traktor.decks." + duplicateDeckPendingTargetId + ".stems.4.muted" }
  AppProperty { id: dupTargetPlay;       path: "app.traktor.decks." + duplicateDeckPendingTargetId + ".play" }

  // Per-deck play/pause — used to stop the opposing deck on second Edit press.
  // Static paths avoid the stale-value race that dynamic AppProperty path rebinding can introduce.
  // Path: app.traktor.decks.N.play (bool) — true = playing, false = stopped.
  AppProperty { id: deckAPlay; path: "app.traktor.decks.1.play" }
  AppProperty { id: deckBPlay; path: "app.traktor.decks.2.play" }
  AppProperty { id: deckCPlay; path: "app.traktor.decks.3.play" }
  AppProperty { id: deckDPlay; path: "app.traktor.decks.4.play" }

  // Target-deck stem mutes bound to duplicateDeckTargetId — stable before onPress fires so no
  // rebinding race.  Used to re-enable all stem slots on the target deck on the second Edit press.
  AppProperty { id: dupStopTargetStem1Muted; path: "app.traktor.decks." + duplicateDeckTargetId + ".stems.1.muted" }
  AppProperty { id: dupStopTargetStem2Muted; path: "app.traktor.decks." + duplicateDeckTargetId + ".stems.2.muted" }
  AppProperty { id: dupStopTargetStem3Muted; path: "app.traktor.decks." + duplicateDeckTargetId + ".stems.3.muted" }
  AppProperty { id: dupStopTargetStem4Muted; path: "app.traktor.decks." + duplicateDeckTargetId + ".stems.4.muted" }

  // FX unit constants — change these to reassign effects to different FX units.
  // sfxDelayUnit:     single-mode Delay+Freeze (pads 5, 7, 8).
  // sfxTurntableUnit: group-mode Turntable FX with Beatmasher/Gater/Turntable FX (pad 6).
  readonly property int sfxDelayUnit:   3
  readonly property int sfxTurntableUnit: 4

  // Delay FX unit (single mode): channel routing and controls.
  // Delay: buttons.2 = Freeze; knobs.1 = Rate, knobs.2 = Feedback, knobs.3 = Depth.
  AppProperty { id: sfxChannelFxAssignDelay;   path: "app.traktor.mixer.channels." + padsFocusedDeckId + ".fx.assign." + sfxDelayUnit }
  AppProperty { id: sfxChannelFxAssignDelay_1; path: "app.traktor.mixer.channels.1.fx.assign." + sfxDelayUnit }
  AppProperty { id: sfxChannelFxAssignDelay_2; path: "app.traktor.mixer.channels.2.fx.assign." + sfxDelayUnit }
  AppProperty { id: sfxChannelFxAssignDelay_3; path: "app.traktor.mixer.channels.3.fx.assign." + sfxDelayUnit }
  AppProperty { id: sfxChannelFxAssignDelay_4; path: "app.traktor.mixer.channels.4.fx.assign." + sfxDelayUnit }
  AppProperty { id: sfxFxUnitDelayEnabled;   path: "app.traktor.fx." + sfxDelayUnit + ".enabled"   }
  AppProperty { id: sfxFxUnitDelayDryWet;    path: "app.traktor.fx." + sfxDelayUnit + ".dry_wet"   }
  AppProperty { id: sfxFxUnitDelayType;      path: "app.traktor.fx." + sfxDelayUnit + ".type"      }
  AppProperty { id: sfxFxUnitDelaySelect;    path: "app.traktor.fx." + sfxDelayUnit + ".select.1"  }
  AppProperty { id: sfxFxUnitDelayButton1;   path: "app.traktor.fx." + sfxDelayUnit + ".buttons.1" }
  AppProperty { id: sfxFxUnitDelayButton2;   path: "app.traktor.fx." + sfxDelayUnit + ".buttons.2" }
  AppProperty { id: sfxFxUnitDelayButton3;   path: "app.traktor.fx." + sfxDelayUnit + ".buttons.3" }
  AppProperty { id: sfxFxUnitDelayKnob1;     path: "app.traktor.fx." + sfxDelayUnit + ".knobs.1"   }
  AppProperty { id: sfxFxUnitDelayKnob2;     path: "app.traktor.fx." + sfxDelayUnit + ".knobs.2"   }
  AppProperty { id: sfxFxUnitDelayKnob3;     path: "app.traktor.fx." + sfxDelayUnit + ".knobs.3"   }

  // Turntable FX unit (group mode): channel routing and controls.
  // Group mode slots: Slot 1 = Beatmasher, Slot 2 = Gater, Slot 3 = Turntable FX (BRK).
  // Turntable FX: buttons.3 = BRK trigger; knobs.3 = B.SPD. B.SPD: 0.9-1.0 glitch, 0.6-0.75 1-beat, 0.3-0.4 classic.
  AppProperty { id: sfxChannelFxAssignTurntable;   path: "app.traktor.mixer.channels." + padsFocusedDeckId + ".fx.assign." + sfxTurntableUnit }
  AppProperty { id: sfxChannelFxAssignTurntable_1; path: "app.traktor.mixer.channels.1.fx.assign." + sfxTurntableUnit }
  AppProperty { id: sfxChannelFxAssignTurntable_2; path: "app.traktor.mixer.channels.2.fx.assign." + sfxTurntableUnit }
  AppProperty { id: sfxChannelFxAssignTurntable_3; path: "app.traktor.mixer.channels.3.fx.assign." + sfxTurntableUnit }
  AppProperty { id: sfxChannelFxAssignTurntable_4; path: "app.traktor.mixer.channels.4.fx.assign." + sfxTurntableUnit }
  AppProperty { id: sfxFxUnitTurntableEnabled;   path: "app.traktor.fx." + sfxTurntableUnit + ".enabled"   }
  AppProperty { id: sfxFxUnitTurntableDryWet;    path: "app.traktor.fx." + sfxTurntableUnit + ".dry_wet"   }
  AppProperty { id: sfxFxUnitTurntableType;      path: "app.traktor.fx." + sfxTurntableUnit + ".type"      }
  AppProperty { id: sfxFxUnitTurntableSelect1;   path: "app.traktor.fx." + sfxTurntableUnit + ".select.1"  }
  AppProperty { id: sfxFxUnitTurntableSelect2;   path: "app.traktor.fx." + sfxTurntableUnit + ".select.2"  }
  AppProperty { id: sfxFxUnitTurntableSelect3;   path: "app.traktor.fx." + sfxTurntableUnit + ".select.3"  }
  AppProperty { id: sfxFxUnitTurntableButton1;   path: "app.traktor.fx." + sfxTurntableUnit + ".buttons.1" }
  AppProperty { id: sfxFxUnitTurntableButton2;   path: "app.traktor.fx." + sfxTurntableUnit + ".buttons.2" }
  AppProperty { id: sfxFxUnitTurntableButton3;   path: "app.traktor.fx." + sfxTurntableUnit + ".buttons.3" }
  AppProperty { id: sfxFxUnitTurntableKnob1;     path: "app.traktor.fx." + sfxTurntableUnit + ".knobs.1"   }
  AppProperty { id: sfxFxUnitTurntableKnob2;     path: "app.traktor.fx." + sfxTurntableUnit + ".knobs.2"   }
  AppProperty { id: sfxFxUnitTurntableKnob3;     path: "app.traktor.fx." + sfxTurntableUnit + ".knobs.3"   }

  // Effect indices (verify in Traktor by selecting each effect and reading the debug overlay).
  readonly property int sfxDelayEffectIndex:  6   // Delay (single mode on sfxDelayUnit, verify in Traktor)
  readonly property int sfxFxTypeSingle:     1   // Single Mode type value
  readonly property int sfxFxTypeGroup:      0   // Group Mode type value
  readonly property int sfxBeatmasherIndex:  1   // Beatmasher (group mode slot 1)
  readonly property int sfxGaterIndex:       5   // Gater (group mode slot 2)
  readonly property int sfxTurntableFxIndex: 18  // Turntable FX (group mode slot 3)
  // Flag to track if group mode has been initialized (true = don't reinitialize every pad press)
  property bool sfxGroupModeInitialized: false
  // Per-pad held state for LEDs (hold-to-apply: press activates, release reverts).
  property bool sfxPad5Held: false
  property bool sfxPad6Held: false
  property bool sfxPad7Held: false
  property bool sfxPad8Held: false
  // Capture button toggle: true while all-stems Delay+Freeze is locked on.
  property bool sfxCaptureFreezeActive: false
  // Configuration: whether Capture Freeze only works in stem mode (true) or on all decks (false).
  // Set to false to enable Capture Freeze on any deck, including non-stems and Remix decks.
  property bool sfxCaptureFreezeOnlyInStemMode: false

  // Configuration: whether Duplicate Deck (Edit) only works in stem mode (true) or always (false).
  // Set to false to allow Edit to duplicate the current deck on any deck type.
  property bool duplicateDeckOnlyInStemMode: false

  // State: target deck awaiting post-load mute+play setup (-1 = no pending duplicate).
  property int  duplicateDeckPendingTargetId:    -1
  property bool duplicateDeckSourceWasRunning:   false

  // Live opposing deck ID — the sister deck of whichever deck currently has pad focus.
  // Uses padsFocus (not deckFocus) since stem mode is pad-focused; the two can diverge.
  readonly property int  duplicateDeckTargetId: padsFocus.value ? topDeckId : bottomDeckId

  // Whether the opposing deck is currently running, derived from the static deckXRunning AppProperties.
  // Avoids the async stale-value race that AppProperties with dynamic path bindings can have on rebind.
  readonly property bool duplicateDeckOpposingRunning:
    duplicateDeckTargetId == 1 ? deckARunning.value :
    duplicateDeckTargetId == 2 ? deckBRunning.value :
    duplicateDeckTargetId == 3 ? deckCRunning.value : deckDRunning.value

  //------------------------------------------------------------------------------------------------------------------
  //  STEM SUPER SEPARATION (SSS)
  //  Shift + FX knob: vocal/instrumental crossfader with per-stem soft-takeover.
  //  Shift+Flux toggles StemSuperSeparationMode (persistent; FLUX LED pulsates while active).
  //
  //  Knob 1: focused deck only       — standard formula
  //  Knob 2: sibling deck only       — standard formula
  //  Knob 3: other-side deck only    — reversed formula
  //  Knob 4: all 4 decks             — focused: standard; sibling/other-side/other-sib: reversed
  //
  //  Standard formula — center (0.5) = all stems at 100%:
  //    Instrumental (stems 1-3): min(1.0, knob × 2)       →  100% at center, 0% at full left
  //    Vocal (stem 4):           min(1.0, (1-knob) × 2)   →  100% at center, 0% at full right
  //
  //  Reversed formula (knob 3 and secondary decks in knob 4): mirror of the above.
  //    Instrumental (stems 1-3): min(1.0, (1-knob) × 2)   →  100% at center, 0% at full right
  //    Vocal (stem 4):           min(1.0, knob × 2)        →  100% at center, 0% at full left
  //
  //  Restore behavior on shift release / mode exit is governed by sssRestoreMode (see below).
  //  Soft-takeover per stem: each stem only responds once the knob reaches its current volume
  //  level from above (no sudden jumps). The first Wire callback after shift press is skipped
  //  to avoid a jump when the knob is displaced from center.
  //------------------------------------------------------------------------------------------------------------------

  // Config: restrict SSS to Stem decks only (true) or allow on any deck type (false).
  property bool sssOnlyInStemMode: true

  // Config: restore behavior for all four knobs on shift release / StemSuperSeparationMode exit.
  //   "snapshot": restore all modified deck(s) to pre-engagement volumes (default).
  //   "fader":    restore secondary deck(s) only; focused deck latches (keeps SSS position).
  //               For knob 1 (focused only): no secondary → same as "latch".
  //               For knobs 2 and 3 (single secondary): secondary restored → same as "snapshot".
  //               For knob 4 (all 4 decks): sibling, other-side, other-sib restored; focused latches.
  //   "latch":    all modified decks latch — no restoration at all.
  property string sssRestoreMode: "snapshot"

  // StemSuperSeparationMode: persistent mode toggled by Shift+Flux.
  // When active, FX knobs 1-4 perform SSS without holding shift.
  // FLUX button LED pulsates while active.  Shift+Flux again exits the mode.
  property bool sssModeActive: false

  // Sibling deck: the other deck in this controller's pair (A↔C or B↔D).
  readonly property int sssSiblingDeckId: footerFocusedDeckId == topDeckId ? bottomDeckId : topDeckId

  // Other-side deck: the deck at the same position on the opposing controller pair.
  //   AC controller focused on A (top) → B (top of BD);  focused on C (bottom) → D (bottom of BD).
  //   BD controller focused on B (top) → A (top of AC);  focused on D (bottom) → C (bottom of AC).
  readonly property int sssOtherSideDeckId:
    decksAssignment == DecksAssignment.AC ?
      (footerFocusedDeckId == topDeckId ? 2 : 4) :
      (footerFocusedDeckId == topDeckId ? 1 : 3)

  // Other-sib deck: the sibling of the other-side deck (the 4th deck not covered by the above three).
  //   AC focused on A(1) → D(4);  AC focused on C(3) → B(2).
  //   BD focused on B(2) → C(3);  BD focused on D(4) → A(1).
  readonly property int sssOtherSibDeckId:
    decksAssignment == DecksAssignment.AC ?
      (footerFocusedDeckId == topDeckId ? 4 : 2) :
      (footerFocusedDeckId == topDeckId ? 3 : 1)

  // Enable conditions (auto-update when deck type changes).
  readonly property bool sssFocusedEnabled: !sssOnlyInStemMode || (
    footerFocusedDeckId == 1 ? deckAType == DeckType.Stem :
    footerFocusedDeckId == 2 ? deckBType == DeckType.Stem :
    footerFocusedDeckId == 3 ? deckCType == DeckType.Stem :
    deckDType == DeckType.Stem)

  readonly property bool sssSiblingEnabled: !sssOnlyInStemMode || (
    sssSiblingDeckId == 1 ? deckAType == DeckType.Stem :
    sssSiblingDeckId == 2 ? deckBType == DeckType.Stem :
    sssSiblingDeckId == 3 ? deckCType == DeckType.Stem :
    deckDType == DeckType.Stem)

  readonly property bool sssOtherSideEnabled: !sssOnlyInStemMode || (
    sssOtherSideDeckId == 1 ? deckAType == DeckType.Stem :
    sssOtherSideDeckId == 2 ? deckBType == DeckType.Stem :
    sssOtherSideDeckId == 3 ? deckCType == DeckType.Stem :
    deckDType == DeckType.Stem)

  // Knob-active flags: set on first movement after shift press, cleared on shift release.
  property bool sssKnob1Active: false   // focused deck only (standard formula), sssRestoreMode applies
  property bool sssKnob2Active: false   // sibling deck only (standard formula), sssRestoreMode applies
  property bool sssKnob3Active: false   // other-side deck only (reversed formula), sssRestoreMode applies
  property bool sssKnob4Active: false   // all 4 decks (focused standard + others reversed), sssRestoreMode applies

  // JustEngaged flags: absorb the first Wire callback after shift press so a displaced knob
  // position doesn't immediately jump stem volumes. Reset to true on shift press.
  property bool sssKnob1JustEngaged: false
  property bool sssKnob2JustEngaged: false
  property bool sssKnob3JustEngaged: false
  property bool sssKnob4JustEngaged: false

  // Pre-engagement volumes captured at shift press (used when sssRestoreMode="snapshot" or "fader").
  property real sssPreVol1: 1.0          // focused deck stem 1 (drums)
  property real sssPreVol2: 1.0          // focused deck stem 2 (bass)
  property real sssPreVol3: 1.0          // focused deck stem 3 (other)
  property real sssPreVol4: 1.0          // focused deck stem 4 (vocal)
  property real sssSibPreVol1: 1.0       // sibling deck stem 1
  property real sssSibPreVol2: 1.0       // sibling deck stem 2
  property real sssSibPreVol3: 1.0       // sibling deck stem 3
  property real sssSibPreVol4: 1.0       // sibling deck stem 4
  property real sssOtherPreVol1: 1.0     // other-side deck stem 1
  property real sssOtherPreVol2: 1.0     // other-side deck stem 2
  property real sssOtherPreVol3: 1.0     // other-side deck stem 3
  property real sssOtherPreVol4: 1.0     // other-side deck stem 4
  property real sssOtherSibPreVol1: 1.0  // other-sib deck stem 1
  property real sssOtherSibPreVol2: 1.0  // other-sib deck stem 2
  property real sssOtherSibPreVol3: 1.0  // other-sib deck stem 3
  property real sssOtherSibPreVol4: 1.0  // other-sib deck stem 4

  // Per-stem soft-takeover caught state: reset at shift press; set when the crossfader target
  // first reaches or drops below the stem's current volume (prevents jumps).
  property bool sssCaught1: false         // focused deck stem 1
  property bool sssCaught2: false         // focused deck stem 2
  property bool sssCaught3: false         // focused deck stem 3
  property bool sssCaught4: false         // focused deck stem 4
  property bool sssSibCaught1: false      // sibling deck stem 1
  property bool sssSibCaught2: false      // sibling deck stem 2
  property bool sssSibCaught3: false      // sibling deck stem 3
  property bool sssSibCaught4: false      // sibling deck stem 4
  property bool sssOtherCaught1: false    // other-side deck stem 1
  property bool sssOtherCaught2: false    // other-side deck stem 2
  property bool sssOtherCaught3: false    // other-side deck stem 3
  property bool sssOtherCaught4: false    // other-side deck stem 4
  property bool sssOtherSibCaught1: false // other-sib deck stem 1
  property bool sssOtherSibCaught2: false // other-sib deck stem 2
  property bool sssOtherSibCaught3: false // other-sib deck stem 3
  property bool sssOtherSibCaught4: false // other-sib deck stem 4

  // Stem volume AppProperties — paths update automatically when deck IDs change.
  AppProperty { id: sssVol1;         path: "app.traktor.decks." + footerFocusedDeckId + ".stems.1.volume" }
  AppProperty { id: sssVol2;         path: "app.traktor.decks." + footerFocusedDeckId + ".stems.2.volume" }
  AppProperty { id: sssVol3;         path: "app.traktor.decks." + footerFocusedDeckId + ".stems.3.volume" }
  AppProperty { id: sssVol4;         path: "app.traktor.decks." + footerFocusedDeckId + ".stems.4.volume" }
  AppProperty { id: sssSibVol1;      path: "app.traktor.decks." + sssSiblingDeckId    + ".stems.1.volume" }
  AppProperty { id: sssSibVol2;      path: "app.traktor.decks." + sssSiblingDeckId    + ".stems.2.volume" }
  AppProperty { id: sssSibVol3;      path: "app.traktor.decks." + sssSiblingDeckId    + ".stems.3.volume" }
  AppProperty { id: sssSibVol4;      path: "app.traktor.decks." + sssSiblingDeckId    + ".stems.4.volume" }
  AppProperty { id: sssOtherVol1;    path: "app.traktor.decks." + sssOtherSideDeckId  + ".stems.1.volume" }
  AppProperty { id: sssOtherVol2;    path: "app.traktor.decks." + sssOtherSideDeckId  + ".stems.2.volume" }
  AppProperty { id: sssOtherVol3;    path: "app.traktor.decks." + sssOtherSideDeckId  + ".stems.3.volume" }
  AppProperty { id: sssOtherVol4;    path: "app.traktor.decks." + sssOtherSideDeckId  + ".stems.4.volume" }
  AppProperty { id: sssOtherSibVol1; path: "app.traktor.decks." + sssOtherSibDeckId   + ".stems.1.volume" }
  AppProperty { id: sssOtherSibVol2; path: "app.traktor.decks." + sssOtherSibDeckId   + ".stems.2.volume" }
  AppProperty { id: sssOtherSibVol3; path: "app.traktor.decks." + sssOtherSibDeckId   + ".stems.3.volume" }
  AppProperty { id: sssOtherSibVol4; path: "app.traktor.decks." + sssOtherSibDeckId   + ".stems.4.volume" }

  // Captured knob values: populated by WiresGroups when shift is active.
  MappingPropertyDescriptor
  {
    id: sssKnob1Prop; path: propertiesPath + ".sss.knob.1"; type: MappingPropertyDescriptor.Float; value: 0.5
    onValueChanged: {
      if (module.shift === sssModeActive) return
      if (sssKnob1JustEngaged) { sssKnob1JustEngaged = false; return }
      if (!sssKnob1Active) sssKnob1Active = true
      sssApplyFocused(value)
    }
  }
  MappingPropertyDescriptor
  {
    id: sssKnob2Prop; path: propertiesPath + ".sss.knob.2"; type: MappingPropertyDescriptor.Float; value: 0.5
    onValueChanged: {
      if (module.shift === sssModeActive) return
      if (sssKnob2JustEngaged) { sssKnob2JustEngaged = false; return }
      if (!sssKnob2Active) sssKnob2Active = true
      sssApplySiblingOnly(value)
    }
  }
  MappingPropertyDescriptor
  {
    id: sssKnob3Prop; path: propertiesPath + ".sss.knob.3"; type: MappingPropertyDescriptor.Float; value: 0.5
    onValueChanged: {
      if (module.shift === sssModeActive) return
      if (sssKnob3JustEngaged) { sssKnob3JustEngaged = false; return }
      if (!sssKnob3Active) sssKnob3Active = true
      sssApplyOtherSideOnly(value)
    }
  }
  MappingPropertyDescriptor
  {
    id: sssKnob4Prop; path: propertiesPath + ".sss.knob.4"; type: MappingPropertyDescriptor.Float; value: 0.5
    onValueChanged: {
      if (module.shift === sssModeActive) return
      if (sssKnob4JustEngaged) { sssKnob4JustEngaged = false; return }
      if (!sssKnob4Active) sssKnob4Active = true
      sssApplyAll(value)
    }
  }

  // Snapshot pre-engagement volumes and reset all per-stem state on shift press.
  function sssOnShiftPressed() {
    sssPreVol1 = sssVol1.value;                       sssPreVol2 = sssVol2.value
    sssPreVol3 = sssVol3.value;                       sssPreVol4 = sssVol4.value
    sssSibPreVol1 = sssSibVol1.value;                 sssSibPreVol2 = sssSibVol2.value
    sssSibPreVol3 = sssSibVol3.value;                 sssSibPreVol4 = sssSibVol4.value
    sssOtherPreVol1 = sssOtherVol1.value;             sssOtherPreVol2 = sssOtherVol2.value
    sssOtherPreVol3 = sssOtherVol3.value;             sssOtherPreVol4 = sssOtherVol4.value
    sssOtherSibPreVol1 = sssOtherSibVol1.value;       sssOtherSibPreVol2 = sssOtherSibVol2.value
    sssOtherSibPreVol3 = sssOtherSibVol3.value;       sssOtherSibPreVol4 = sssOtherSibVol4.value
    sssCaught1 = false; sssCaught2 = false; sssCaught3 = false; sssCaught4 = false
    sssSibCaught1 = false; sssSibCaught2 = false; sssSibCaught3 = false; sssSibCaught4 = false
    sssOtherCaught1 = false; sssOtherCaught2 = false; sssOtherCaught3 = false; sssOtherCaught4 = false
    sssOtherSibCaught1 = false; sssOtherSibCaught2 = false; sssOtherSibCaught3 = false; sssOtherSibCaught4 = false
    sssKnob1Active = false; sssKnob2Active = false; sssKnob3Active = false; sssKnob4Active = false
    sssKnob1JustEngaged = true; sssKnob2JustEngaged = true; sssKnob3JustEngaged = true; sssKnob4JustEngaged = true
  }

  // On shift release (or SSS mode exit): apply restore or latch behavior per sssRestoreMode.
  //
  //  Knob 1 (focused only, standard):
  //    "snapshot": restore focused.
  //    "fader"/"latch": focused latches — no-op. (No secondary was touched.)
  //  Knob 2 (sibling only, standard):
  //    "snapshot"/"fader": restore sibling. (Sibling is the only affected deck; fader=snapshot here.)
  //    "latch": no-op.
  //  Knob 3 (other-side only, reversed):
  //    "snapshot"/"fader": restore other-side. (Other-side is the only affected deck; fader=snapshot here.)
  //    "latch": no-op.
  //  Knob 4 (all 4 decks, focused standard + others reversed):
  //    "snapshot": restore all 4 decks.
  //    "fader":    restore sibling, other-side, and other-sib only; focused deck latches.
  //    "latch":    all 4 decks latch — no-op.
  function sssOnShiftReleased() {
    // Knob 1: focused deck only.
    if (sssKnob1Active) {
      if (sssRestoreMode === "snapshot") {
        sssVol1.value = sssPreVol1; sssVol2.value = sssPreVol2
        sssVol3.value = sssPreVol3; sssVol4.value = sssPreVol4
      }
      // "fader"/"latch": no secondary to restore; focused latches — no-op
    }
    // Knob 2: sibling deck only. "fader" = "snapshot" (sibling is already secondary).
    if (sssKnob2Active) {
      if (sssRestoreMode !== "latch") {
        sssSibVol1.value = sssSibPreVol1; sssSibVol2.value = sssSibPreVol2
        sssSibVol3.value = sssSibPreVol3; sssSibVol4.value = sssSibPreVol4
      }
    }
    // Knob 3: other-side deck only. "fader" = "snapshot" (other-side is already secondary).
    if (sssKnob3Active) {
      if (sssRestoreMode !== "latch") {
        sssOtherVol1.value = sssOtherPreVol1; sssOtherVol2.value = sssOtherPreVol2
        sssOtherVol3.value = sssOtherPreVol3; sssOtherVol4.value = sssOtherPreVol4
      }
    }
    // Knob 4: all 4 decks.
    if (sssKnob4Active) {
      if (sssRestoreMode === "snapshot") {
        sssVol1.value = sssPreVol1;                   sssVol2.value = sssPreVol2
        sssVol3.value = sssPreVol3;                   sssVol4.value = sssPreVol4
        sssSibVol1.value = sssSibPreVol1;             sssSibVol2.value = sssSibPreVol2
        sssSibVol3.value = sssSibPreVol3;             sssSibVol4.value = sssSibPreVol4
        sssOtherVol1.value = sssOtherPreVol1;         sssOtherVol2.value = sssOtherPreVol2
        sssOtherVol3.value = sssOtherPreVol3;         sssOtherVol4.value = sssOtherPreVol4
        sssOtherSibVol1.value = sssOtherSibPreVol1;   sssOtherSibVol2.value = sssOtherSibPreVol2
        sssOtherSibVol3.value = sssOtherSibPreVol3;   sssOtherSibVol4.value = sssOtherSibPreVol4
      } else if (sssRestoreMode === "fader") {
        // Restore the three secondary decks; focused deck latches.
        sssSibVol1.value = sssSibPreVol1;             sssSibVol2.value = sssSibPreVol2
        sssSibVol3.value = sssSibPreVol3;             sssSibVol4.value = sssSibPreVol4
        sssOtherVol1.value = sssOtherPreVol1;         sssOtherVol2.value = sssOtherPreVol2
        sssOtherVol3.value = sssOtherPreVol3;         sssOtherVol4.value = sssOtherPreVol4
        sssOtherSibVol1.value = sssOtherSibPreVol1;   sssOtherSibVol2.value = sssOtherSibPreVol2
        sssOtherSibVol3.value = sssOtherSibPreVol3;   sssOtherSibVol4.value = sssOtherSibPreVol4
      }
      // "latch": nothing
    }
    sssKnob1Active = false; sssKnob2Active = false; sssKnob3Active = false; sssKnob4Active = false
  }

  // Enter StemSuperSeparationMode: snapshot volumes and arm knobs identically to a shift press.
  function sssOnEnterMode() { sssOnShiftPressed() }

  // Exit StemSuperSeparationMode: apply the configured latch/restore behavior.
  function sssOnExitMode() { sssOnShiftReleased() }

  // Single-deck crossfade: focused deck only, standard formula (knob 1).
  //
  //  Center (0.5) = all stems at 100%.
  //  Full left  (0.0): vocal MAX, inst MIN  (isolate vocal).
  //  Full right (1.0): inst MAX, vocal MIN  (isolate inst).
  //
  //  inst = min(1, knob×2)       vocal = min(1, (1−knob)×2)
  function sssApplyFocused(knobPos) {
    var inst = Math.min(1.0, knobPos * 2.0)           // focused inst target
    var voc  = Math.min(1.0, (1.0 - knobPos) * 2.0)  // focused vocal target
    // Focused deck: stems 1–3 = inst, stem 4 = voc
    if (!sssCaught1) { if (inst <= sssVol1.value) sssCaught1 = true }
    if  (sssCaught1) sssVol1.value = inst
    if (!sssCaught2) { if (inst <= sssVol2.value) sssCaught2 = true }
    if  (sssCaught2) sssVol2.value = inst
    if (!sssCaught3) { if (inst <= sssVol3.value) sssCaught3 = true }
    if  (sssCaught3) sssVol3.value = inst
    if (!sssCaught4) { if (voc  <= sssVol4.value) sssCaught4 = true }
    if  (sssCaught4) sssVol4.value = voc
  }

  // Single-deck crossfade: sibling deck only, standard formula (knob 2).
  // Same direction as knob 1 — left isolates vocal, right isolates inst — but on sibling.
  function sssApplySiblingOnly(knobPos) {
    var inst = Math.min(1.0, knobPos * 2.0)           // sibling inst target
    var voc  = Math.min(1.0, (1.0 - knobPos) * 2.0)  // sibling vocal target
    // Sibling deck: stems 1–3 = inst, stem 4 = voc
    if (!sssSibCaught1) { if (inst <= sssSibVol1.value) sssSibCaught1 = true }
    if  (sssSibCaught1) sssSibVol1.value = inst
    if (!sssSibCaught2) { if (inst <= sssSibVol2.value) sssSibCaught2 = true }
    if  (sssSibCaught2) sssSibVol2.value = inst
    if (!sssSibCaught3) { if (inst <= sssSibVol3.value) sssSibCaught3 = true }
    if  (sssSibCaught3) sssSibVol3.value = inst
    if (!sssSibCaught4) { if (voc  <= sssSibVol4.value) sssSibCaught4 = true }
    if  (sssSibCaught4) sssSibVol4.value = voc
  }

  // Single-deck crossfade: other-side deck only, reversed formula (knob 3).
  //
  //  Reversed means the opposite direction to knobs 1 and 2:
  //  Full left  (0.0): inst MAX, vocal MIN  (isolate inst on other-side).
  //  Full right (1.0): inst MIN, vocal MAX  (isolate vocal on other-side).
  //
  //  inst = min(1, (1−knob)×2)   vocal = min(1, knob×2)
  function sssApplyOtherSideOnly(knobPos) {
    var inst = Math.min(1.0, (1.0 - knobPos) * 2.0)  // other-side inst target (reversed)
    var voc  = Math.min(1.0, knobPos * 2.0)           // other-side vocal target (reversed)
    // Other-side deck: stems 1–3 = inst, stem 4 = voc
    if (!sssOtherCaught1) { if (inst <= sssOtherVol1.value) sssOtherCaught1 = true }
    if  (sssOtherCaught1) sssOtherVol1.value = inst
    if (!sssOtherCaught2) { if (inst <= sssOtherVol2.value) sssOtherCaught2 = true }
    if  (sssOtherCaught2) sssOtherVol2.value = inst
    if (!sssOtherCaught3) { if (inst <= sssOtherVol3.value) sssOtherCaught3 = true }
    if  (sssOtherCaught3) sssOtherVol3.value = inst
    if (!sssOtherCaught4) { if (voc  <= sssOtherVol4.value) sssOtherCaught4 = true }
    if  (sssOtherCaught4) sssOtherVol4.value = voc
  }

  // Four-deck crossfade: focused (standard) + sibling, other-side, other-sib (all reversed) (knob 4).
  //
  //  Full left  (0.0): focused isolates vocal;        sibling/other-side/other-sib isolate inst.
  //  Full right (1.0): focused isolates inst;         sibling/other-side/other-sib isolate vocal.
  //  Center (0.5): all stems on all 4 decks at 100%.
  //
  //  focInst = min(1, knob×2)        focVoc = min(1, (1−knob)×2)   — standard for focused
  //  secInst = min(1, (1−knob)×2)    secVoc = min(1, knob×2)       — reversed for secondaries
  function sssApplyAll(knobPos) {
    var focInst = Math.min(1.0, knobPos * 2.0)           // focused inst target
    var focVoc  = Math.min(1.0, (1.0 - knobPos) * 2.0)  // focused vocal target
    var secInst = focVoc                                  // secondary inst target (reversed = focVoc)
    var secVoc  = focInst                                 // secondary vocal target (reversed = focInst)
    // Focused deck (standard): stems 1–3 = focInst, stem 4 = focVoc
    if (!sssCaught1) { if (focInst <= sssVol1.value) sssCaught1 = true }
    if  (sssCaught1) sssVol1.value = focInst
    if (!sssCaught2) { if (focInst <= sssVol2.value) sssCaught2 = true }
    if  (sssCaught2) sssVol2.value = focInst
    if (!sssCaught3) { if (focInst <= sssVol3.value) sssCaught3 = true }
    if  (sssCaught3) sssVol3.value = focInst
    if (!sssCaught4) { if (focVoc  <= sssVol4.value) sssCaught4 = true }
    if  (sssCaught4) sssVol4.value = focVoc
    // Sibling deck (reversed): stems 1–3 = secInst, stem 4 = secVoc
    if (!sssSibCaught1) { if (secInst <= sssSibVol1.value) sssSibCaught1 = true }
    if  (sssSibCaught1) sssSibVol1.value = secInst
    if (!sssSibCaught2) { if (secInst <= sssSibVol2.value) sssSibCaught2 = true }
    if  (sssSibCaught2) sssSibVol2.value = secInst
    if (!sssSibCaught3) { if (secInst <= sssSibVol3.value) sssSibCaught3 = true }
    if  (sssSibCaught3) sssSibVol3.value = secInst
    if (!sssSibCaught4) { if (secVoc  <= sssSibVol4.value) sssSibCaught4 = true }
    if  (sssSibCaught4) sssSibVol4.value = secVoc
    // Other-side deck (reversed): stems 1–3 = secInst, stem 4 = secVoc
    if (!sssOtherCaught1) { if (secInst <= sssOtherVol1.value) sssOtherCaught1 = true }
    if  (sssOtherCaught1) sssOtherVol1.value = secInst
    if (!sssOtherCaught2) { if (secInst <= sssOtherVol2.value) sssOtherCaught2 = true }
    if  (sssOtherCaught2) sssOtherVol2.value = secInst
    if (!sssOtherCaught3) { if (secInst <= sssOtherVol3.value) sssOtherCaught3 = true }
    if  (sssOtherCaught3) sssOtherVol3.value = secInst
    if (!sssOtherCaught4) { if (secVoc  <= sssOtherVol4.value) sssOtherCaught4 = true }
    if  (sssOtherCaught4) sssOtherVol4.value = secVoc
    // Other-sib deck (reversed): stems 1–3 = secInst, stem 4 = secVoc
    if (!sssOtherSibCaught1) { if (secInst <= sssOtherSibVol1.value) sssOtherSibCaught1 = true }
    if  (sssOtherSibCaught1) sssOtherSibVol1.value = secInst
    if (!sssOtherSibCaught2) { if (secInst <= sssOtherSibVol2.value) sssOtherSibCaught2 = true }
    if  (sssOtherSibCaught2) sssOtherSibVol2.value = secInst
    if (!sssOtherSibCaught3) { if (secInst <= sssOtherSibVol3.value) sssOtherSibCaught3 = true }
    if  (sssOtherSibCaught3) sssOtherSibVol3.value = secInst
    if (!sssOtherSibCaught4) { if (secVoc  <= sssOtherSibVol4.value) sssOtherSibCaught4 = true }
    if  (sssOtherSibCaught4) sssOtherSibVol4.value = secVoc
  }

  // Initialize both FX units when entering stem mode.
  // Delay unit stays in single mode throughout the session (effect selected once, enabled with dry signal).
  // Turntable unit is set to group mode with Beatmasher + Gater + Turntable FX (guarded by sfxGroupModeInitialized).
  function sfxInit() {
    sfxFxUnitDelayType.value      = sfxFxTypeSingle
    sfxFxUnitDelaySelect.value    = sfxDelayEffectIndex
    sfxFxUnitDelayEnabled.value   = true
    sfxFxUnitDelayDryWet.value    = 0.0
    if (!sfxGroupModeInitialized) {
      sfxFxUnitTurntableType.value    = sfxFxTypeGroup
      sfxFxUnitTurntableSelect1.value = sfxBeatmasherIndex
      sfxFxUnitTurntableSelect2.value = sfxGaterIndex
      sfxFxUnitTurntableSelect3.value = sfxTurntableFxIndex
      sfxFxUnitTurntableEnabled.value = true
      sfxFxUnitTurntableDryWet.value  = 0.0
      sfxGroupModeInitialized      = true
    }
  }

  // Route target stems through the delay unit (single mode, Delay+Freeze).
  // config.stems[0..3]: stems to route. config.dryWet; config.knob1 (TIME), config.knob2 (FEEDBACK),
  // config.knob3 (DEPTH/DRY-WET within effect); config.button2 (Freeze).
  function sfxDelayStart(config) {
    sfxStem1FxSendOn.value          = config.stems[0] || false
    sfxStem2FxSendOn.value          = config.stems[1] || false
    sfxStem3FxSendOn.value          = config.stems[2] || false
    sfxStem4FxSendOn.value          = config.stems[3] || false
    sfxChannelFxAssignDelay_1.value = false
    sfxChannelFxAssignDelay_2.value = false
    sfxChannelFxAssignDelay_3.value = false
    sfxChannelFxAssignDelay_4.value = false
    sfxChannelFxAssignDelay.value   = true
    sfxFxUnitDelayDryWet.value      = config.dryWet || 1.0
    if (config.knob1 !== undefined) sfxFxUnitDelayKnob1.value = config.knob1
    if (config.knob2 !== undefined) sfxFxUnitDelayKnob2.value = config.knob2
    if (config.knob3 !== undefined) sfxFxUnitDelayKnob3.value = config.knob3
    if (config.button2) sfxFxUnitDelayButton2.value = true
  }

  // Route target stems through the turntable unit (group mode, Turntable FX on slot 3).
  // config.stems[0..3]: stems to route. config.dryWet; config.knob3 (B.SPD); config.button3 (BRK).
  function sfxTurntableStart(config) {
    sfxStem1FxSendOn.value           = config.stems[0] || false
    sfxStem2FxSendOn.value           = config.stems[1] || false
    sfxStem3FxSendOn.value           = config.stems[2] || false
    sfxStem4FxSendOn.value           = config.stems[3] || false
    sfxChannelFxAssignTurntable_1.value = false
    sfxChannelFxAssignTurntable_2.value = false
    sfxChannelFxAssignTurntable_3.value = false
    sfxChannelFxAssignTurntable_4.value = false
    sfxChannelFxAssignTurntable.value   = true
    sfxFxUnitTurntableDryWet.value      = config.dryWet || 1.0
    if (config.knob3 !== undefined) sfxFxUnitTurntableKnob3.value = config.knob3
    if (config.button3) sfxFxUnitTurntableButton3.value = true
  }

  // Teardown: reset stem routing and both FX units to dry/idle state (units stay enabled).
  // Call from onRelease. FX units remain enabled so next pad press takes effect immediately.
  function sfxTeardown() {
    sfxStem1FxSendOn.value           = false
    sfxStem2FxSendOn.value           = false
    sfxStem3FxSendOn.value           = false
    sfxStem4FxSendOn.value           = false
    sfxChannelFxAssignDelay.value     = false
    sfxChannelFxAssignTurntable.value   = false
    sfxFxUnitDelayDryWet.value        = 0.0
    sfxFxUnitDelayButton1.value       = false
    sfxFxUnitDelayButton2.value       = false
    sfxFxUnitDelayButton3.value       = false
    sfxFxUnitDelayKnob1.value         = 0.0
    sfxFxUnitDelayKnob2.value         = 0.0
    sfxFxUnitDelayKnob3.value         = 0.0
    sfxFxUnitTurntableDryWet.value      = 0.0
    sfxFxUnitTurntableButton1.value     = false
    sfxFxUnitTurntableButton2.value     = false
    sfxFxUnitTurntableButton3.value     = false
    sfxFxUnitTurntableKnob1.value       = 0.0
    sfxFxUnitTurntableKnob2.value       = 0.0
    sfxFxUnitTurntableKnob3.value       = 0.0
    sfxCaptureFreezeActive              = false
  }

  // Shutdown: full teardown + clear all static channel assigns + disable both FX units.
  // Call on stem mode exit or remix-button reset.
  function sfxShutdown() {
    sfxTeardown()
    sfxChannelFxAssignDelay_1.value   = false
    sfxChannelFxAssignDelay_2.value   = false
    sfxChannelFxAssignDelay_3.value   = false
    sfxChannelFxAssignDelay_4.value   = false
    sfxChannelFxAssignTurntable_1.value = false
    sfxChannelFxAssignTurntable_2.value = false
    sfxChannelFxAssignTurntable_3.value = false
    sfxChannelFxAssignTurntable_4.value = false
    sfxFxUnitDelayEnabled.value       = false
    sfxFxUnitTurntableEnabled.value     = false
  }

  MappingPropertyDescriptor { id: padsMode;   path: propertiesPath + ".pads_mode";     type: MappingPropertyDescriptor.Integer;  value: disabledMode
    // Initialize FX units when entering stem mode.
    onValueChanged:
    {
      if (value == stemMode)
      {
        sfxInit()
      }
      // Shut down all stem FX state when leaving stem mode.
      // Static channel assigns cover all decks (focused deck may have changed since press).
      if (value != stemMode)
      {
        sfxPad5Held = false
        sfxPad6Held = false
        sfxPad7Held = false
        sfxPad8Held = false
        sfxShutdown()
      }
    }
  }
  MappingPropertyDescriptor { id: padsFocus;  path: propertiesPath + ".pads_focus";    type: MappingPropertyDescriptor.Boolean;  value: false         }

  MappingPropertyDescriptor
  {
    id: topDeckPadsMode
    path: propertiesPath + ".top.pads_mode"
    type: MappingPropertyDescriptor.Integer
    value: disabledMode
    onValueChanged:
    {
      updatePads();

      switch (decksAssignment)
      {
        case DecksAssignment.AC:
          deckAFreezeEnabled.value = (topDeckPadsMode.value == freezeMode);
          break;

        case DecksAssignment.BD:
          deckBFreezeEnabled.value = (topDeckPadsMode.value == freezeMode);
          break;
      }
    }
  }

  MappingPropertyDescriptor
  {
    id: bottomDeckPadsMode
    path: propertiesPath + ".bottom.pads_mode"
    type: MappingPropertyDescriptor.Integer
    value: disabledMode
    onValueChanged:
    {
      updatePads();

      switch (decksAssignment)
      {
        case DecksAssignment.AC:
          deckCFreezeEnabled.value = (bottomDeckPadsMode.value == freezeMode);
          break;

        case DecksAssignment.BD:
          deckDFreezeEnabled.value = (bottomDeckPadsMode.value == freezeMode);
          break;
      }
    }
  }

  function updatePads()
  {
    var focusedDeckPadsMode = (deckFocus ? bottomDeckPadsMode : topDeckPadsMode);

    switch (focusedDeckPadsMode.value)
    {
      case hotcueMode:
        if ( hasHotcues(focusedDeckType) )
        {
          padsMode.value = hotcueMode;
          padsFocus.value = deckFocus;
        }
        else
        {
          padsMode.value = disabledMode;
          padsFocus.value = false;
        }
        break;

      case freezeMode:
        if ( hasFreezeMode(focusedDeckType) )
        {
          padsMode.value = freezeMode;
          padsFocus.value = deckFocus;
        }
        else
        {
          padsMode.value = disabledMode;
          padsFocus.value = false;
        }
        break;

      case loopMode:
        if (hasLoopMode(focusedDeckType))
        {
          padsMode.value = loopMode;
          padsFocus.value = deckFocus;
        }
        else
        {
          padsMode.value = disabledMode;
          padsFocus.value = false;
        }
        break;

      case remixMode:
        if (focusedDeckType == DeckType.Remix)
        {
          padsMode.value = remixMode;
          padsFocus.value = deckFocus;
        }
        // D2 v0.5.0: redirect Remix button press to stemMode for Stem decks
        else if (focusedDeckType == DeckType.Stem)
        {
          // Reset FX units when triggering the Remix button in stemMode
          if (padsMode.value == stemMode)
          {
            sfxGroupModeInitialized = false
            sfxShutdown()
            sfxInit()
          }
          padsMode.value = stemMode;
          padsFocus.value = deckFocus;
        }
        else if (unfocusedDeckType == DeckType.Remix)
        {
          padsMode.value = remixMode;
          padsFocus.value = !deckFocus;
        }
        else
        {
          padsMode.value = disabledMode;
          padsFocus.value = false;
        }
        break;

      case disabledMode:
        padsMode.value = disabledMode;
        padsFocus.value = false;
        break;
    }
  }

  function updateDeckPadsMode(deckType, deckPadsMode)
  {
      switch (deckType)
      {
        case DeckType.Track:
        case DeckType.Stem:        
          deckPadsMode.value = hotcueMode;
          break;

        case DeckType.Remix:
          deckPadsMode.value = remixMode;
          break;

        case DeckType.Live:
          deckPadsMode.value = disabledMode;
          break;

        case thruDeckType:
          deckPadsMode.value = disabledMode;
          break;
      }
  }

  function validateDeckPadsMode(thisDeckType, otherDeckType, deckPadsMode)
  {
    var isValid = false;

    switch (deckPadsMode.value)
    {
      case hotcueMode:
        isValid = hasHotcues(thisDeckType);
        break;

      case loopMode:
        isValid = hasLoopMode(thisDeckType);
        break;

      case freezeMode:
        isValid = hasFreezeMode(thisDeckType);
        break;

      case remixMode:
        // D2 v0.4.0: Stem decks are valid in remixMode context (redirected to stemMode at runtime)
        isValid = hasRemixMode(thisDeckType) || hasRemixMode(otherDeckType)
                  || thisDeckType == DeckType.Stem;
        break;
    }

    if (!isValid)
    {
      updateDeckPadsMode(thisDeckType, deckPadsMode);
    }
  }

  // Freeze modeselektor (when entering or leaving freeze mode all overlays should be hidden)
  AppProperty { id: deckASliceCount;   path: "app.traktor.decks.1.freeze.slice_count" }
  AppProperty { id: deckBSliceCount;   path: "app.traktor.decks.2.freeze.slice_count" }
  AppProperty { id: deckCSliceCount;   path: "app.traktor.decks.3.freeze.slice_count" }
  AppProperty { id: deckDSliceCount;   path: "app.traktor.decks.4.freeze.slice_count" }

  AppProperty
  {
    id: deckAFreezeEnabled
    path: "app.traktor.decks.1.freeze.enabled"

    onValueChanged:
    {
      if (decksAssignment == DecksAssignment.AC)
      {
        if (value)
        {
          deckASliceCount.value = 8;
          screenOverlay.value = Overlay.none;
        }
        else if (topDeckPadsMode.value == freezeMode)
        {
          updateDeckPadsMode(topDeckType, topDeckPadsMode);
        }
      }
    }
  }

  AppProperty
  {
    id: deckBFreezeEnabled
    path: "app.traktor.decks.2.freeze.enabled"

    onValueChanged:
    {
     if (decksAssignment == DecksAssignment.BD)
      {
        if (value)
        {
          deckBSliceCount.value = 8;
          screenOverlay.value = Overlay.none;
        }
        else if (topDeckPadsMode.value == freezeMode)
        {
          updateDeckPadsMode(topDeckType, topDeckPadsMode);
        }
      }
    }
  }

  AppProperty
  {
    id: deckCFreezeEnabled
    path: "app.traktor.decks.3.freeze.enabled"

    onValueChanged:
    {
      if (decksAssignment == DecksAssignment.AC)
      {
        if (value)
        {
          deckCSliceCount.value = 8;
          screenOverlay.value = Overlay.none;
        }
        else if (bottomDeckPadsMode.value == freezeMode)
        {
          updateDeckPadsMode(bottomDeckType, bottomDeckPadsMode);
        }
      }
    }
  }

  AppProperty
  {
    id: deckDFreezeEnabled
    path: "app.traktor.decks.4.freeze.enabled"

    onValueChanged:
    {
      if (decksAssignment == DecksAssignment.BD)
      {
        if (value)
        {
          deckDSliceCount.value = 8;
          screenOverlay.value = Overlay.none;
        }
        else if (bottomDeckPadsMode.value == freezeMode)
        {
          updateDeckPadsMode(bottomDeckType, bottomDeckPadsMode);
        }
      }
    }
  }

  //------------------------------------------------------------------------------------------------------------------
  // BROWSER WARNINGS
  // Show informer warnings of the currently focused deck
  //------------------------------------------------------------------------------------------------------------------

  AppProperty   { id: deckALoadingWarning; path: "app.traktor.informer.deck_loading_warnings.1.active" }
  AppProperty   { id: deckBLoadingWarning; path: "app.traktor.informer.deck_loading_warnings.2.active" }
  AppProperty   { id: deckCLoadingWarning; path: "app.traktor.informer.deck_loading_warnings.3.active" }
  AppProperty   { id: deckDLoadingWarning; path: "app.traktor.informer.deck_loading_warnings.4.active" }

  function focusedDeckLoadingWarning(assignment, focus)
  {
    switch (assignment)
    {
      case DecksAssignment.AC: return (focus ? deckCLoadingWarning.value : deckALoadingWarning.value);
      case DecksAssignment.BD: return (focus ? deckDLoadingWarning.value : deckBLoadingWarning.value);
    }
  }

  property bool showBrowserWarning: (screenViewProp.value == ScreenView.browser) && focusedDeckLoadingWarning(decksAssignment, deckFocus)

  onShowBrowserWarningChanged:
  {
    if(showBrowserWarning)
    {
      screenOverlay.value = Overlay.browserWarnings;
    }
    else if(screenOverlay.value == Overlay.browserWarnings)
    {
      screenOverlay.value = Overlay.none;
    }
  }

  //------------------------------------------------------------------------------------------------------------------
  // BEATGRID EDIT MODE
  //------------------------------------------------------------------------------------------------------------------

  readonly property int editModeNone:  0
  readonly property int editModeArmed: 1
  readonly property int editModeUsed:  2
  readonly property int editModeFull:  3

  MappingPropertyDescriptor { id: editMode;  path: propertiesPath + ".edit_mode";  type: MappingPropertyDescriptor.Integer; value: editModeNone; }

  //------------------------------------------------------------------------------------------------------------------
  //  EDIT MODE STATE MACHINE
  //------------------------------------------------------------------------------------------------------------------

  function updateEditMode()
  {
    //Disable editMode if we are not (anymore) in track or stem deck. Other decks don't have edit mode!
    if (editMode != editModeNone && !hasEditMode(focusedDeckType))
    {
      editMode.value = editModeNone;
    }
  }

  readonly property bool isInEditMode: (editMode.value == editModeFull)

  property bool preEditIsSingleDeck: false

  onIsInEditModeChanged:
  {
    if (isInEditMode)
    {
      screenOverlay.value = Overlay.none;
      preEditIsSingleDeck = screenIsSingleDeck.value;
      screenIsSingleDeck.value = true;
    }
    else
    {
      screenIsSingleDeck.value = preEditIsSingleDeck;
    }

    showDisplayButtonArea.value = true;
    showDisplayButtonAreaResetTimer.restart();
  }

  Wire { from: "%surface%.edit"; to: ButtonScriptAdapter { brightness: (isInEditMode ? onBrightness : dimmedBrightness); onPress: onEditPressed(); onRelease: onEditReleased(); } enabled: hasEditMode(focusedDeckType) && module.screenView.value == ScreenView.deck && padsMode.value != stemMode }

  function onEditPressed()
  {
    if (editMode.value == editModeNone)
    {
      editMode.value = editModeArmed;
    }
    else if (editMode.value == editModeFull)
    {
      editMode.value = editModeNone;
    }
  }

  function onEditReleased()
  {
    if (editMode.value == editModeArmed)
    {
      zoomedEditView.value = false;
      editMode.value = editModeFull;
    }
    else if (editMode.value == editModeUsed)
    {
      editMode.value = editModeNone;
    }
  }

  function onSyncPressed()
  {
    if (editMode.value == editModeArmed)
    {
      editMode.value = editModeUsed;
    }
  }

  /////////////////////////

  Blinker { name: "ScreenViewBlinker";  cycle: 1000; defaultBrightness: onBrightness; blinkBrightness: dimmedBrightness }

  Wire { from: "%surface%.display.buttons.5.value";  to: ButtonScriptAdapter { onPress: handleViewButton(); } }
  Wire { from: "%surface%.display.buttons.5.led";    to: "ScreenViewBlinker"  }
  Wire { from: "ScreenViewBlinker.trigger"; to: ExpressionAdapter { type: ExpressionAdapter.Boolean; expression: (module.screenView.value == ScreenView.deck && screenOverlay.value != Overlay.none) || (module.screenView.value == ScreenView.browser && !browserIsTemporary.value) || isInEditMode }  }

  function handleViewButton()
  {
    if (screenViewProp.value == ScreenView.deck)
    {
      if (screenOverlay.value == Overlay.none && editMode.value != editModeFull)
      {
        screenIsSingleDeck.value = !screenIsSingleDeck.value;
      }
      else
      {
        screenOverlay.value = Overlay.none;
        editMode.value      = editModeNone;
      }
    }
    else if (screenViewProp.value == ScreenView.browser)
    {
      if (browserIsTemporary.value)
      {
        browserIsTemporary.value = false;
      }
      else
      {
        screenViewProp.value = ScreenView.deck;
      }
    }
  }
  /////////////////////////

  AppProperty { id: deckARunning;   path: "app.traktor.decks.1.running" } 
  AppProperty { id: deckBRunning;   path: "app.traktor.decks.2.running" }
  AppProperty { id: deckCRunning;   path: "app.traktor.decks.3.running" }
  AppProperty { id: deckDRunning;   path: "app.traktor.decks.4.running" }

  AppProperty { id: previewIsLoaded;     path: "app.traktor.browser.preview_player.is_loaded" }
  AppProperty { id: previewIsPlaying;    path: "app.traktor.browser.preview_player.play" }
  AppProperty { id: previewElapsedTime;  path: "app.traktor.browser.preview_player.elapsed_time" }
  AppProperty { id: previewTrackLength;  path: "app.traktor.browser.preview_content.track_length" }
  AppProperty { id: browserFullScreen;   path: "app.traktor.browser.full_screen" }

  // Shift //
  property alias shift: shiftProp.value
  MappingPropertyDescriptor
  {
    id: shiftProp
    path: propertiesPath + ".shift"
    type: MappingPropertyDescriptor.Boolean
    value: false
    onValueChanged: {
      if (!sssModeActive) {
        if (value) { sssOnShiftPressed() } else { sssOnShiftReleased() }
      } else {
        // In SSS mode shift suppresses the knobs (pre-positioning). Re-arm justEngaged on
        // shift release so the first Wire callback after shift is released is absorbed.
        if (!value) { sssKnob1JustEngaged = true; sssKnob2JustEngaged = true; sssKnob3JustEngaged = true; sssKnob4JustEngaged = true }
      }
    }
  }
  Wire { from: "%surface%.shift";  to: DirectPropertyAdapter { path: propertiesPath + ".shift"  } }

  MappingPropertyDescriptor { id: browserIsContentList;  path: propertiesPath + ".browser.is_content_list";  type: MappingPropertyDescriptor.Boolean; value: false }
  
  // Screen
  KontrolScreen { name: "screen"; side: (decksAssignment == DecksAssignment.AC ? ScreenSide.Left : ScreenSide.Right); flavor: ScreenFlavor.S8; settingsPath: module.settingsPath; propertiesPath: module.propertiesPath }
  Wire { from: "screen.output";   to: "%surface%.display" }
  Wire { from: "screen.screen_view_state";  to: DirectPropertyAdapter { path: propertiesPath + ".screen_view";  input: false } }
  AppProperty { id: unloadPreviewPlayer;  path: "app.traktor.browser.preview_player.unload" }

  property alias screenView: screenViewProp
  MappingPropertyDescriptor
  {
    id: screenViewProp
    path: propertiesPath + ".screen_view"
    type: MappingPropertyDescriptor.Integer
    value: ScreenView.deck

    onValueChanged:
    {
      if (screenViewProp.value != ScreenView.deck)
      {
        editMode.value = editModeNone;
        screenOverlay.value = Overlay.none;
      }
      else if (screenViewProp.value != ScreenView.browser)
      {
        unloadPreviewPlayer.value = true;
      }
      if (screenViewProp.value != ScreenView.browser && browserFullScreenActive)
      {
        browserFullScreen.value = browserFullScreenWasOpen.value;
        browserFullScreenActive = false;
      }
    }
  }

  // Button area timer
  MappingPropertyDescriptor
  {
    id: showDisplayButtonArea;
    path: propertiesPath + ".show_display_button_area";
    type: MappingPropertyDescriptor.Boolean;
    value: false;
    onValueChanged:
    {
      if(value)
        showDisplayButtonAreaResetTimer.restart();
    }
  }

  Timer
  {
    id: showDisplayButtonAreaResetTimer
    triggeredOnStart: false
    interval: 1000
    running:  false
    repeat:   false
    onTriggered:
    {
      if (!isInEditMode)
        showDisplayButtonArea.value = false;
    }
  }

  SetPropertyAdapter { name: "ShowDisplayButtonArea_ButtonAdapter";    path: propertiesPath + ".show_display_button_area";  value: true }
  EncoderScriptAdapter { name: "ShowDisplayButtonArea_EncoderAdapter";   onTick: { showDisplayButtonArea.value = true; showDisplayButtonAreaResetTimer.restart(); } }

  Wire
  {
    enabled: (module.screenView.value == ScreenView.deck) && hasButtonArea(focusedDeckType)
    from:
      Or
      {
        inputs:
        [
          "%surface%.display.buttons.2",
          "%surface%.display.buttons.3",
          "%surface%.display.buttons.6",
          "%surface%.display.buttons.7"
        ]
      }
    to: "ShowDisplayButtonArea_ButtonAdapter.input"
  }

  // Browser Pop-outs
  WiresGroup
  {
    enabled: (module.screenView.value == ScreenView.browser) && browserIsContentList

    Wire { to: "ShowDisplayButtonArea_ButtonAdapter.input"; from: "%surface%.display.buttons.6" }
    Wire { to: "ShowDisplayButtonArea_ButtonAdapter.input"; from: "%surface%.display.buttons.7" }
  }

  SwitchTimer { name: "BrowserBackTimer"; setTimeout: 500 }
  Wire { from: "%surface%.back";                to: "BrowserBackTimer.input" }
  Wire { from: "BrowserBackTimer.output"; to: SetPropertyAdapter { path: propertiesPath + ".screen_view"; value: ScreenView.deck } enabled: module.screenView.value == ScreenView.browser }

  //------------------------------------------------------------------------------------------------------------------
  //  Loop/Beatjump pad sizes wiring
  //------------------------------------------------------------------------------------------------------------------


  ButtonSection { name: "loop_pads";      buttons: 4; color: Color.Green; stateHandling: ButtonSection.External }
  ButtonSection { name: "beatjump_pads";  buttons: 4; color: Color.LightOrange }

  Wire { from: DirectPropertyAdapter { path:"mapping.settings.pad_loop_size.1"; input: false } to: "loop_pads.button1.value" }
  Wire { from: DirectPropertyAdapter { path:"mapping.settings.pad_loop_size.2"; input: false } to: "loop_pads.button2.value" }
  Wire { from: DirectPropertyAdapter { path:"mapping.settings.pad_loop_size.3"; input: false } to: "loop_pads.button3.value" }
  Wire { from: DirectPropertyAdapter { path:"mapping.settings.pad_loop_size.4"; input: false } to: "loop_pads.button4.value" }
  Wire { from: DirectPropertyAdapter { path:"mapping.settings.pad_jump_size.1"; input: false } to: "beatjump_pads.button1.value" }
  Wire { from: DirectPropertyAdapter { path:"mapping.settings.pad_jump_size.2"; input: false } to: "beatjump_pads.button2.value" }
  Wire { from: DirectPropertyAdapter { path:"mapping.settings.pad_jump_size.3"; input: false } to: "beatjump_pads.button3.value" }
  Wire { from: DirectPropertyAdapter { path:"mapping.settings.pad_jump_size.4"; input: false } to: "beatjump_pads.button4.value" }

  // Browser stuff
  SwitchTimer
  {
    name: "BrowserLeaveTimer"
    resetTimeout: 2000

    onSet:
    {
      if((screenViewProp.value != ScreenView.browser) && (screenOverlay.value == Overlay.none) && showBrowserOnTouch.value)
      {
        browserIsTemporary.value = true;
        screenViewProp.value = ScreenView.browser;
      }
    }

    onReset:
    {
      if((screenViewProp.value == ScreenView.browser) && showBrowserOnTouch.value && browserIsTemporary.value)
      {
        screenViewProp.value = ScreenView.deck;
      }
    }
  }

  Wire { from: "%surface%.browse.push"; to: SetPropertyAdapter { path: propertiesPath + ".overlay"; value: Overlay.none } enabled: screenOverlay.value == Overlay.browserWarnings }

      WiresGroup
      {
          enabled: !showBrowserOnTouch.value

          Wire { from: "%surface%.browse.push"; to: ButtonScriptAdapter { onPress: { browserIsTemporary.value = false; module.screenView.value = ScreenView.browser; } } enabled: screenOverlay.value == Overlay.none }
      }

      WiresGroup
      {
          enabled: showBrowserOnTouch.value

          Wire { from: "%surface%.browse.touch"; to: "BrowserLeaveTimer.input";  enabled: module.screenView.value == ScreenView.deck && screenOverlay.value == Overlay.none }

          Wire
          {
            enabled: module.screenView.value  == ScreenView.browser
            from: Or
            {
              inputs:
              [
                "%surface%.browse.touch",
                "%surface%.knobs.1.touch",
                "%surface%.knobs.2.touch",
                "%surface%.knobs.3.touch",
                "%surface%.knobs.4.touch"
              ]
            }
            to: "BrowserLeaveTimer.input"
          }
      }

      // Open laptop browser full screen while browse knob is touched; restore on lift
      SwitchTimer
      {
        name: "BrowserFullScreenTimer"
        resetTimeout: 200

        onSet:
        {
          if (!browserFullScreenActive && screenOverlay.value == Overlay.none && !module.shift)
          {
            browserFullScreenWasOpen.value = browserFullScreen.value;
            browserFullScreen.value = true;
            browserFullScreenActive = true;
          }
        }

        onReset:
        {
          if (browserFullScreenActive)
          {
            browserFullScreen.value = browserFullScreenWasOpen.value;
            browserFullScreenActive = false;
          }
        }
      }

      Wire { from: "%surface%.browse.touch"; to: "BrowserFullScreenTimer.input"; enabled: module.screenView.value == ScreenView.browser && screenOverlay.value == Overlay.none && !module.shift }

      //------------------------------------------------------------------------------------------------------------------
      // Browser
      //------------------------------------------------------------------------------------------------------------------

      AppProperty { id: browserSortId;  path: "app.traktor.browser.sort_id" }

      WiresGroup
      {
        enabled: module.screenView.value == ScreenView.browser

        Wire { from: "%surface%.back";         to: "screen.exit_browser_node" }
        // browse.push: normal open, or Shift+push to load/play/stop preview (load_or_play toggles play without unloading)
        Wire { from: "%surface%.browse.push";  to: "screen.open_browser_node";                                                      enabled: screenOverlay.value == Overlay.none && !module.shift }
        Wire { from: "%surface%.browse.push";  to: TriggerPropertyAdapter { path: "app.traktor.browser.preview_player.load_or_play" } enabled: screenOverlay.value == Overlay.none && module.shift }
        // browse.turn: seek preview player when preview is playing, otherwise scroll browser
        Wire { from: "%surface%.browse.turn";  to: RelativePropertyAdapter { path: "app.traktor.browser.preview_player.seek"; step: 0.01; mode: RelativeMode.Stepped } enabled: previewIsPlaying.value }
        Wire { from: "%surface%.browse.turn";  to: "screen.scroll_browser_row";  enabled: !module.shift && !previewIsPlaying.value }
        Wire { from: "%surface%.browse.turn";  to: "screen.scroll_browser_page"; enabled:  module.shift && !previewIsPlaying.value }

        WiresGroup
        {
          enabled: browserIsContentList.value

          Wire { from: "%surface%.knobs.1";             to: "screen.browser_sorting"    }
          Wire { from: "%surface%.buttons.1";           to: TriggerPropertyAdapter  { path:"app.traktor.browser.flip_sort_up_down"  } enabled: (browserSortId.value > 0) }

          Wire { from: "%surface%.display.buttons.6";   to: TriggerPropertyAdapter { path:"app.traktor.browser.preparation.append" } }
          Wire { from: "%surface%.display.buttons.7";   to: TriggerPropertyAdapter { path:"app.traktor.browser.preparation.jump_to_list" } }
        }

        Wire { from: "%surface%.buttons.4";         to: DirectPropertyAdapter   { path: "app.traktor.browser.preview_player.load_or_play" } }
        Wire { from: "%surface%.knobs.4";           to: RelativePropertyAdapter { path: "app.traktor.browser.preview_player.seek"; step: 0.01; mode: RelativeMode.Stepped } }
        //Wire { from: "%surface%.display.buttons.6"; to: RelativePropertyAdapter { path: "mapping.state.browser_view_mode"; wrap: true; mode: RelativeMode.Increment } }

        WiresGroup
        {
          enabled: module.shift && previewIsLoaded.value

          WiresGroup
          {
            enabled:  (decksAssignment == DecksAssignment.AC)

            Wire { from: "%surface%.buttons.4"; to: TriggerPropertyAdapter { path:"app.traktor.decks.1.load.from_preview_player" } enabled: !deckFocus }
            Wire { from: "%surface%.buttons.4"; to: TriggerPropertyAdapter { path:"app.traktor.decks.3.load.from_preview_player" } enabled:  deckFocus }
          }

          WiresGroup
          {
            enabled:  (decksAssignment == DecksAssignment.BD)

            Wire { from: "%surface%.buttons.4"; to: TriggerPropertyAdapter { path:"app.traktor.decks.2.load.from_preview_player" } enabled: !deckFocus }
            Wire { from: "%surface%.buttons.4"; to: TriggerPropertyAdapter { path:"app.traktor.decks.4.load.from_preview_player" } enabled:  deckFocus }
          }
        }
      }

      //------------------------------------------------------------------------------------------------------------------
      // Center Overlays
      //------------------------------------------------------------------------------------------------------------------
    
      
      
      WiresGroup
      {
        enabled: module.screenView.value == ScreenView.deck

        Wire { from: "%surface%.fx.select"; to: TogglePropertyAdapter { path: propertiesPath + ".overlay"; value: Overlay.fx } enabled: !module.shift }
        Wire { from: "%surface%.fx.select"; to: TogglePropertyAdapter { path: propertiesPath + ".overlay"; value: Overlay.mixerFx } enabled: module.shift }

        WiresGroup
        {
          enabled: !isInEditMode

          Wire {
              from: "%surface%.display.buttons.2";
              to: TogglePropertyAdapter {
                  path: propertiesPath + ".overlay";
                  value: Overlay.bpm
              }
              enabled: hasBpmAdjust(focusedDeckType)
          }
          Wire {
              from: "%surface%.display.buttons.3";
              to: TogglePropertyAdapter {
                  path: propertiesPath + ".overlay";
                  value: Overlay.key
              }
              enabled: hasKeylock(focusedDeckType)
          }

          Wire { from: "softtakeover_faders_timer.output"; to: DirectPropertyAdapter { path: propertiesPath + ".softtakeover.show_faders"; output: false } }
        }
      }

      Group
      {
        name: "decks"

        Group
        {
          name: "1"

          DeckTempo       { name: "tempo";            channel: 1 }
          KeyControl      { name: "key_control";      channel: 1 }
          QuantizeControl { name: "quantize_control"; channel: 1 }

          Hotcues      { name: "hotcues";       channel: 1 }
          Beatjump     { name: "beatjump";      channel: 1 }
          FreezeSlicer { name: "freeze_slicer"; channel: 1; numberOfSlices: 8 }

          TransportSection { name: "transport"; channel: 1 }
          Scratch     { name: "scratch";    channel: 1; ledBarSize: touchstripLedBarSize }
          TouchstripTempoBend   { name: "tempo_bend"; channel: 1; ledBarSize: touchstripLedBarSize }
          TouchstripTrackSeek   { name: "track_seek"; channel: 1; ledBarSize: touchstripLedBarSize }

          Loop { name: "loop";  channel: 1; numberOfLeds: 4; color: Color.Blue }

          RemixDeck   { name: "remix"; channel: 1; size: RemixDeck.Small }
          RemixDeckStepSequencer   { name: "remix_sequencer"; channel: 1; size: RemixDeck.Small }
          RemixDeckSlots { name: "remix_slots"; channel: 1 }

          StemDeckStreams { name: "stems"; channel: 1 }
        }

        Group
        {
          name: "2"

          DeckTempo       { name: "tempo";            channel: 2 }
          KeyControl      { name: "key_control";      channel: 2 }
          QuantizeControl { name: "quantize_control"; channel: 2 }

          Hotcues      { name: "hotcues";       channel: 2 }
          Beatjump     { name: "beatjump";      channel: 2 }
          FreezeSlicer { name: "freeze_slicer"; channel: 2; numberOfSlices: 8 }

          TransportSection { name: "transport"; channel: 2 }
          Scratch     { name: "scratch";    channel: 2; ledBarSize: touchstripLedBarSize }
          TouchstripTempoBend   { name: "tempo_bend"; channel: 2; ledBarSize: touchstripLedBarSize }
          TouchstripTrackSeek   { name: "track_seek"; channel: 2; ledBarSize: touchstripLedBarSize }

          Loop { name: "loop";  channel: 2; numberOfLeds: 4; color: Color.Blue }

          RemixDeck   { name: "remix"; channel: 2; size: RemixDeck.Small }
          RemixDeckStepSequencer   { name: "remix_sequencer"; channel: 2; size: RemixDeck.Small }

          RemixDeckSlots { name: "remix_slots"; channel: 2 }

          StemDeckStreams { name: "stems"; channel: 2 }
        }

        Group
        {
          name: "3"

          DeckTempo       { name: "tempo";            channel: 3 }
          KeyControl      { name: "key_control";      channel: 3 }
          QuantizeControl { name: "quantize_control"; channel: 3 }

          Hotcues      { name: "hotcues";       channel: 3 }
          Beatjump     { name: "beatjump";      channel: 3 }
          FreezeSlicer { name: "freeze_slicer"; channel: 3; numberOfSlices: 8 }

          TransportSection { name: "transport"; channel: 3 }
          Scratch     { name: "scratch";    channel: 3; ledBarSize: touchstripLedBarSize }
          TouchstripTempoBend   { name: "tempo_bend"; channel: 3; ledBarSize: touchstripLedBarSize }
          TouchstripTrackSeek   { name: "track_seek"; channel: 3; ledBarSize: touchstripLedBarSize }

          Loop { name: "loop";  channel: 3; numberOfLeds: 4; color: Color.White }

          RemixDeck   { name: "remix"; channel: 3; size: RemixDeck.Small }
          RemixDeckStepSequencer   { name: "remix_sequencer"; channel: 3; size: RemixDeck.Small }

          RemixDeckSlots { name: "remix_slots"; channel: 3 }

          StemDeckStreams { name: "stems"; channel: 3 }
        }

        Group
        {
          name: "4"

          DeckTempo       { name: "tempo";            channel: 4 }
          KeyControl      { name: "key_control";      channel: 4 }
          QuantizeControl { name: "quantize_control"; channel: 4 }

          Hotcues      { name: "hotcues";       channel: 4 }
          Beatjump     { name: "beatjump";      channel: 4 }
          FreezeSlicer { name: "freeze_slicer"; channel: 4; numberOfSlices: 8 }

          TransportSection { name: "transport"; channel: 4 }
          Scratch     { name: "scratch";    channel: 4; ledBarSize: touchstripLedBarSize }
          TouchstripTempoBend   { name: "tempo_bend"; channel: 4; ledBarSize: touchstripLedBarSize }
          TouchstripTrackSeek   { name: "track_seek"; channel: 4; ledBarSize: touchstripLedBarSize }

          Loop { name: "loop";  channel: 4; numberOfLeds: 4; color: Color.White }

          RemixDeck   { name: "remix"; channel: 4; size: RemixDeck.Small }
          RemixDeckStepSequencer   { name: "remix_sequencer"; channel: 4; size: RemixDeck.Small }

          RemixDeckSlots { name: "remix_slots"; channel: 4 }

          StemDeckStreams { name: "stems"; channel: 4 }
        }
      }

      //------------------------------------------------------------------------------------------------------------------
      // BPM/Tempo Overlay
      //------------------------------------------------------------------------------------------------------------------

      WiresGroup
      {
        enabled: screenOverlay.value == Overlay.bpm

        // Deck A
        WiresGroup
        {
          enabled: focusedDeckId == 1

          Wire { from: "%surface%.back";   to: "decks.1.tempo.reset" }
          Wire { from: "%surface%.browse"; to: "decks.1.tempo.fine";   enabled:  module.shift }
          Wire { from: "%surface%.browse"; to: "decks.1.tempo.coarse"; enabled: !module.shift }
        }

        // Deck B
        WiresGroup
        {
          enabled: focusedDeckId == 2

          Wire { from: "%surface%.back";   to: "decks.2.tempo.reset" }
          Wire { from: "%surface%.browse"; to: "decks.2.tempo.fine";   enabled:  module.shift }
          Wire { from: "%surface%.browse"; to: "decks.2.tempo.coarse"; enabled: !module.shift }
        }

        // Deck C
        WiresGroup
        {
          enabled: focusedDeckId == 3

          Wire { from: "%surface%.back";   to: "decks.3.tempo.reset" }
          Wire { from: "%surface%.browse"; to: "decks.3.tempo.fine";   enabled:  module.shift }
          Wire { from: "%surface%.browse"; to: "decks.3.tempo.coarse"; enabled: !module.shift }
        }

        // Deck D
        WiresGroup
        {
          enabled: focusedDeckId == 4

          Wire { from: "%surface%.back";   to: "decks.4.tempo.reset" }
          Wire { from: "%surface%.browse"; to: "decks.4.tempo.fine";   enabled:  module.shift }
          Wire { from: "%surface%.browse"; to: "decks.4.tempo.coarse"; enabled: !module.shift }
        }
      }

      //------------------------------------------------------------------------------------------------------------------
      // Key Overlay
      //------------------------------------------------------------------------------------------------------------------

      WiresGroup
      {
        enabled: screenOverlay.value == Overlay.key

        // Deck A
        WiresGroup
        {
          enabled: focusedDeckId == 1

          Wire { from: "%surface%.back";    to: "decks.1.key_control.reset" }
          Wire { from: "%surface%.browse";  to: "decks.1.key_control.fine";   enabled:  module.shift }
          Wire { from: "%surface%.browse";  to: "decks.1.key_control.coarse"; enabled: !module.shift }
        }

        // Deck B
        WiresGroup
        {
          enabled: focusedDeckId == 2

          Wire { from: "%surface%.back";    to: "decks.2.key_control.reset" }
          Wire { from: "%surface%.browse";  to: "decks.2.key_control.fine";   enabled:  module.shift }
          Wire { from: "%surface%.browse";  to: "decks.2.key_control.coarse"; enabled: !module.shift }
        }

        // Deck C
        WiresGroup
        {
          enabled: focusedDeckId == 3

          Wire { from: "%surface%.back";    to: "decks.3.key_control.reset" }
          Wire { from: "%surface%.browse";  to: "decks.3.key_control.fine";   enabled:  module.shift }
          Wire { from: "%surface%.browse";  to: "decks.3.key_control.coarse"; enabled: !module.shift }
        }

        // Deck D
        WiresGroup
        {
          enabled: focusedDeckId == 4

          Wire { from: "%surface%.back";    to: "decks.4.key_control.reset" }
          Wire { from: "%surface%.browse";  to: "decks.4.key_control.fine";   enabled:  module.shift }
          Wire { from: "%surface%.browse";  to: "decks.4.key_control.coarse"; enabled: !module.shift }
        }
      }

      //------------------------------------------------------------------------------------------------------------------
      // Quantize Overlay
      //------------------------------------------------------------------------------------------------------------------

      WiresGroup
      {
        enabled: screenOverlay.value == Overlay.quantize

        Wire { from: "%surface%.browse"; to: "decks.1.quantize_control"; enabled: focusedDeckId == 1 }
        Wire { from: "%surface%.browse"; to: "decks.2.quantize_control"; enabled: focusedDeckId == 2 }
        Wire { from: "%surface%.browse"; to: "decks.3.quantize_control"; enabled: focusedDeckId == 3 }
        Wire { from: "%surface%.browse"; to: "decks.4.quantize_control"; enabled: focusedDeckId == 4 }
      }

      //------------------------------------------------------------------------------------------------------------------
      // Swing Overlay
      //------------------------------------------------------------------------------------------------------------------

      WiresGroup
      {
        enabled: screenOverlay.value == Overlay.swing

        Wire { from: "%surface%.browse"; to: RelativePropertyAdapter { path: "app.traktor.decks.1.remix.sequencer.swing"; step: 0.01; mode: RelativeMode.Stepped } enabled: focusedDeckId == 1 }
        Wire { from: "%surface%.browse"; to: RelativePropertyAdapter { path: "app.traktor.decks.2.remix.sequencer.swing"; step: 0.01; mode: RelativeMode.Stepped } enabled: focusedDeckId == 2 }
        Wire { from: "%surface%.browse"; to: RelativePropertyAdapter { path: "app.traktor.decks.3.remix.sequencer.swing"; step: 0.01; mode: RelativeMode.Stepped } enabled: focusedDeckId == 3 }
        Wire { from: "%surface%.browse"; to: RelativePropertyAdapter { path: "app.traktor.decks.4.remix.sequencer.swing"; step: 0.01; mode: RelativeMode.Stepped } enabled: focusedDeckId == 4 }
      }

      //------------------------------------------------------------------------------------------------------------------
      //  PERFORMANCE CONTROLS PAGES
      //------------------------------------------------------------------------------------------------------------------

      function validateFooterPage(footerFocusDeckType, footerFocusRemixMode, page)
      {
        switch (page)
        {
          case FooterPage.filter:
            return hasFilterPage(footerFocusDeckType, footerFocusRemixMode);

          case FooterPage.pitch:
            return hasPitchPage(footerFocusDeckType, footerFocusRemixMode);

          case FooterPage.fxSend:
            return hasFxSendPage(footerFocusDeckType, footerFocusRemixMode);

          case FooterPage.fx:
            return (fxMode.value == FxMode.FourFxUnits);

          case FooterPage.midi:
            return module.useMIDIControls;

          case FooterPage.slot1:
          case FooterPage.slot2:
          case FooterPage.slot3:
          case FooterPage.slot4:
            return hasSlotPages(footerFocusDeckType, footerFocusRemixMode);

          default:
            return !hasBottomControls(footerFocusDeckType) && (fxMode.value != FxMode.FourFxUnits) && !module.useMIDIControls;
        }
      }

      function footerPageInc(footerFocusDeckType, footerFocusRemixMode, footerPage)
      {
        if (footerHasDetails)
        {
          var tempPage = footerPage.value;

          while (true)
          {
            // Go to the next footer page...
            switch (tempPage)
            {
              case FooterPage.filter:
                tempPage = FooterPage.pitch;
              break;

              case FooterPage.pitch:
                tempPage = FooterPage.fxSend;
              break;

              case FooterPage.fxSend:
                tempPage = FooterPage.slot1;
              break;

              case FooterPage.slot1:
                tempPage = FooterPage.slot2;
              break;

              case FooterPage.slot2:
                tempPage = FooterPage.slot3;
              break;

              case FooterPage.slot3:
                tempPage = FooterPage.slot4;
              break;

              case FooterPage.slot4:
                tempPage = FooterPage.fx;
              break;

              case FooterPage.fx:
                tempPage = FooterPage.midi;
              break;

              case FooterPage.midi:
                tempPage = FooterPage.filter;
                break;
          }

            // Validate the page and eventually switch to it!
            if (validateFooterPage(footerFocusDeckType, footerFocusRemixMode, tempPage))
            {
              footerPage.value = tempPage;
              return;
        }
          }
        }
        else
        {
          footerPage.value = FooterPage.empty;
        }
      }

      function footerPageDec( footerFocusDeckType, footerFocusRemixMode, footerPage )
      {
        if (footerHasDetails)
        {
          var tempPage = footerPage.value;

          while (true)
          {
            // Go to the next footer page...
            switch (tempPage)
            {
              case FooterPage.filter:
                tempPage = FooterPage.midi;
              break;

              case FooterPage.pitch:
                tempPage = FooterPage.filter;
              break;

              case FooterPage.fxSend:
                tempPage = FooterPage.pitch;
              break;

              case FooterPage.slot1:
                tempPage = FooterPage.fxSend;
              break;

              case FooterPage.slot2:
                tempPage = FooterPage.slot1;
              break;

              case FooterPage.slot3:
                tempPage = FooterPage.slot2;
              break;

              case FooterPage.slot4:
                tempPage = FooterPage.slot3;
              break;

              case FooterPage.fx:
                tempPage = FooterPage.slot4;
              break;

              case FooterPage.midi:
                tempPage = FooterPage.fx;
              break;
          }

            // Validate the page and eventually switch to it!
            if (validateFooterPage(footerFocusDeckType, footerFocusRemixMode, tempPage))
            {
              footerPage.value = tempPage;
              return;
        }
          }
        }
        else
        {
          footerPage.value = FooterPage.empty;
        }
      }

      WiresGroup
      {
        enabled: !isInEditMode && module.screenView.value == ScreenView.deck

        Wire
        {
          from: "%surface%.display.buttons.8"
          to: ButtonScriptAdapter
          {
            onPress:
            {
              var footerPage = (footerFocus.value ? bottomDeckFooterPage : topDeckFooterPage);
              footerPageInc(footerFocus.value ? bottomDeckType : topDeckType, footerFocus.value ? bottomDeckRemixMode : topDeckRemixMode, /*out*/ footerPage);

              var sequencerSlot = (footerFocus.value ? bottomSequencerSlot : topSequencerSlot);

              switch (footerPage.value)
              {
                case FooterPage.slot1:
                  sequencerSlot.value = 1;
                  break;

                case FooterPage.slot2:
                  sequencerSlot.value = 2;
                  break;

                case FooterPage.slot3:
                  sequencerSlot.value = 3;
                  break;

                case FooterPage.slot4:
                  sequencerSlot.value = 4;
                  break;
              }
            }
            brightness: onBrightness
          }
        }

        Wire
        {
          from: "%surface%.display.buttons.4"
          to: ButtonScriptAdapter
          {
            onPress:
            {
              var footerPage = (footerFocus.value ? bottomDeckFooterPage : topDeckFooterPage);
              footerPageDec(footerFocus.value ? bottomDeckType : topDeckType, footerFocus.value ? bottomDeckRemixMode : topDeckRemixMode, /*out*/ footerPage);

              var sequencerSlot = (footerFocus.value ? bottomSequencerSlot : topSequencerSlot);

              switch (footerPage.value)
              {
                case FooterPage.slot1:
                  sequencerSlot.value = 1;
                  break;

                case FooterPage.slot2:
                  sequencerSlot.value = 2;
                  break;

                case FooterPage.slot3:
                  sequencerSlot.value = 3;
                  break;

                case FooterPage.slot4:
                  sequencerSlot.value = 4;
                  break;
              }
            }
            brightness: onBrightness
          }
        }
      }

      //------------------------------------------------------------------------------------------------------------------
      // Effects Overlay
      //------------------------------------------------------------------------------------------------------------------

      MappingPropertyDescriptor { path: propertiesPath + ".fx_button_selection"; type: MappingPropertyDescriptor.Integer; value: FxOverlay.upper_button_2 }

      WiresGroup
      {
        enabled: (screenOverlay.value == Overlay.fx)

        Wire { from: "%surface%.browse";       to: "screen.fx_selection" }
        Wire { from: "%surface%.fx.buttons.1"; to: SetPropertyAdapter { path: propertiesPath + ".fx_button_selection"; value: FxOverlay.upper_button_1 } }
        Wire { from: "%surface%.fx.buttons.2"; to: SetPropertyAdapter { path: propertiesPath + ".fx_button_selection"; value: FxOverlay.upper_button_2 } }
        Wire { from: "%surface%.fx.buttons.3"; to: SetPropertyAdapter { path: propertiesPath + ".fx_button_selection"; value: FxOverlay.upper_button_3 } }
        Wire { from: "%surface%.fx.buttons.4"; to: SetPropertyAdapter { path: propertiesPath + ".fx_button_selection"; value: FxOverlay.upper_button_4 } }

        WiresGroup
        {
          enabled: (footerPage.value == FooterPage.fx) && !isInEditMode

          Wire { from: "%surface%.buttons.1"; to: SetPropertyAdapter { path: propertiesPath + ".fx_button_selection"; value: FxOverlay.lower_button_1 } }
          Wire { from: "%surface%.buttons.2"; to: SetPropertyAdapter { path: propertiesPath + ".fx_button_selection"; value: FxOverlay.lower_button_2 } }
          Wire { from: "%surface%.buttons.3"; to: SetPropertyAdapter { path: propertiesPath + ".fx_button_selection"; value: FxOverlay.lower_button_3 } }
          Wire { from: "%surface%.buttons.4"; to: SetPropertyAdapter { path: propertiesPath + ".fx_button_selection"; value: FxOverlay.lower_button_4 } }
        }
      }

      //------------------------------------------------------------------------------------------------------------------
      // Mixer FX Overlay
      //------------------------------------------------------------------------------------------------------------------

      WiresGroup {
        enabled: screenOverlay.value == Overlay.mixerFx

        Wire {
          from: "%surface%.browse.turn"
          to: EncoderScriptAdapter {
            onIncrement: mixerFxSelect.value = Math.min(mixerFxSelect.value + 1, 4)
            onDecrement: mixerFxSelect.value = Math.max(mixerFxSelect.value - 1, 0)
          }
        }
      }

      //------------------------------------------------------------------------------------------------------------------
      // Capture Overlay
      //------------------------------------------------------------------------------------------------------------------

      Wire
      {
        enabled:  (encoderMode.value == encoderCaptureMode) && ((topDeckType == DeckType.Remix) || (bottomDeckType == DeckType.Remix))
        from: Or
        {
          inputs:
          [
            "%surface%.encoder.touch",
            "%surface%.encoder.is_turned"
          ]
        }
        to: HoldPropertyAdapter { path: propertiesPath + ".overlay"; value: Overlay.capture }
      }

      //------------------------------------------------------------------------------------------------------------------
      // MODESELEKTOR
      //------------------------------------------------------------------------------------------------------------------

      property bool deckAExitFreeze:  false
      property bool deckBExitFreeze:  false
      property bool deckCExitFreeze:  false
      property bool deckDExitFreeze:  false

      function onFreezeButtonPress(padsMode, deckIsLoaded)
      {
        var exitFreeze = false;

        if (padsMode.value == freezeMode)
        {
          exitFreeze = true;
        }
        else if (deckIsLoaded)
        {
          exitFreeze = false;
          padsMode.value = freezeMode;
        }
        return exitFreeze;
      }

      function onFreezeButtonRelease(padsMode, exitFreeze, deckType)
      {
        if (exitFreeze)
        {
          updateDeckPadsMode(deckType, padsMode);
        }
      }

      // Deck A
      WiresGroup
      {
        enabled: (focusedDeckId == 1)

        Wire { from: "%surface%.hotcue";  to: SetPropertyAdapter { path: propertiesPath + ".top.pads_mode"; value: hotcueMode;  color: Color.Blue } enabled: hasHotcues(deckAType) }
        Wire { from: "%surface%.loop";    to: SetPropertyAdapter { path: propertiesPath + ".top.pads_mode"; value: loopMode;    color: Color.Blue } enabled: hasLoopMode(deckAType) }
        Wire { from: "%surface%.freeze";  to: ButtonScriptAdapter { brightness: ((topDeckPadsMode.value == freezeMode) ? onBrightness : dimmedBrightness); color: Color.Blue; onPress: { deckAExitFreeze = onFreezeButtonPress(topDeckPadsMode, deckAIsLoaded.value);  } onRelease: { onFreezeButtonRelease(topDeckPadsMode, deckAExitFreeze, deckAType); } } enabled: hasFreezeMode(deckAType) }
        Wire { from: "%surface%.remix";   to: SetPropertyAdapter { path: propertiesPath + ".top.pads_mode"; value: remixMode;   color: (hasRemixMode(deckAType) ? Color.Blue : Color.White) } enabled: hasRemixMode(deckAType) || hasRemixMode(deckCType) || deckAType == DeckType.Stem || deckCType == DeckType.Stem  }
      }

      // Deck C
      WiresGroup
      {
        enabled: (focusedDeckId == 3)

        Wire { from: "%surface%.hotcue";  to: SetPropertyAdapter { path: propertiesPath + ".bottom.pads_mode"; value: hotcueMode;  color: Color.White } enabled: hasHotcues(deckCType) }
        Wire { from: "%surface%.loop";    to: SetPropertyAdapter { path: propertiesPath + ".bottom.pads_mode"; value: loopMode;    color: Color.White } enabled: hasLoopMode(deckCType) }
        Wire { from: "%surface%.freeze";  to: ButtonScriptAdapter  { brightness: ((bottomDeckPadsMode.value == freezeMode) ? onBrightness : dimmedBrightness); color: Color.White; onPress: { deckCExitFreeze = onFreezeButtonPress(bottomDeckPadsMode, deckCIsLoaded.value);  } onRelease: { onFreezeButtonRelease(bottomDeckPadsMode, deckCExitFreeze, deckCType); } } enabled: hasFreezeMode(deckCType) }
        Wire { from: "%surface%.remix";   to: SetPropertyAdapter { path: propertiesPath + ".bottom.pads_mode"; value: remixMode;   color: (hasRemixMode(deckCType) ? Color.White : Color.Blue) } enabled: hasRemixMode(deckAType) || hasRemixMode(deckCType) || deckAType == DeckType.Stem || deckCType == DeckType.Stem }
      }

      // Deck B
      WiresGroup
      {
        enabled: (focusedDeckId == 2)

        Wire { from: "%surface%.hotcue"; to: SetPropertyAdapter { path: propertiesPath + ".top.pads_mode"; value: hotcueMode;  color: Color.Blue } enabled: hasHotcues(deckBType)}
        Wire { from: "%surface%.loop";   to: SetPropertyAdapter { path: propertiesPath + ".top.pads_mode"; value: loopMode;    color: Color.Blue } enabled: hasLoopMode(deckBType) || (deckBType == DeckType.Remix) }
        Wire { from: "%surface%.freeze"; to: ButtonScriptAdapter  { brightness: ((topDeckPadsMode.value == freezeMode) ? onBrightness : dimmedBrightness); color: Color.Blue; onPress: { deckBExitFreeze = onFreezeButtonPress(topDeckPadsMode, deckBIsLoaded.value);  } onRelease: { onFreezeButtonRelease(topDeckPadsMode, deckBExitFreeze, deckBType); } } enabled: hasFreezeMode(deckBType) }
        Wire { from: "%surface%.remix";  to: SetPropertyAdapter { path: propertiesPath + ".top.pads_mode"; value: remixMode;   color: (hasRemixMode(deckBType)? Color.Blue : Color.White) } enabled: hasRemixMode(deckBType) || hasRemixMode(deckDType) || deckBType == DeckType.Stem || deckDType == DeckType.Stem }
      }

      // Deck D
      WiresGroup
      {
        enabled: (focusedDeckId == 4)

        Wire { from: "%surface%.hotcue"; to: SetPropertyAdapter { path: propertiesPath + ".bottom.pads_mode"; value: hotcueMode;  color: Color.White } enabled: hasHotcues(deckDType) }
        Wire { from: "%surface%.loop";   to: SetPropertyAdapter { path: propertiesPath + ".bottom.pads_mode"; value: loopMode;    color: Color.White } enabled: hasLoopMode(deckDType ) }
        Wire { from: "%surface%.freeze"; to: ButtonScriptAdapter  { brightness: ((bottomDeckPadsMode.value == freezeMode) ? onBrightness : dimmedBrightness); color: Color.White; onPress: { deckDExitFreeze = onFreezeButtonPress(bottomDeckPadsMode, deckDIsLoaded.value);  } onRelease: { onFreezeButtonRelease(bottomDeckPadsMode, deckDExitFreeze, deckDType); } } enabled: hasFreezeMode(deckDType) }
        Wire { from: "%surface%.remix";  to: SetPropertyAdapter { path: propertiesPath + ".bottom.pads_mode"; value: remixMode;   color: (hasRemixMode(deckDType)? Color.White : Color.Blue) } enabled: hasRemixMode(deckBType) || hasRemixMode(deckDType) || deckBType == DeckType.Stem || deckDType == DeckType.Stem }
      }

      //------------------------------------------------------------------------------------------------------------------
      // PADS
      //------------------------------------------------------------------------------------------------------------------

      // Deck A
      WiresGroup
      {
        enabled: padsFocusedDeckId == 1

        // Hotcues
        WiresGroup
        {
          enabled: padsMode.value == hotcueMode

          WiresGroup
          {
            enabled: !module.shift

            Wire { from: "%surface%.pads.1";   to: "decks.1.hotcues.1.trigger" }
            Wire { from: "%surface%.pads.2";   to: "decks.1.hotcues.2.trigger" }
            Wire { from: "%surface%.pads.3";   to: "decks.1.hotcues.3.trigger" }
            Wire { from: "%surface%.pads.4";   to: "decks.1.hotcues.4.trigger" }
            Wire { from: "%surface%.pads.5";   to: "decks.1.hotcues.5.trigger" }
            Wire { from: "%surface%.pads.6";   to: "decks.1.hotcues.6.trigger" }
            Wire { from: "%surface%.pads.7";   to: "decks.1.hotcues.7.trigger" }
            Wire { from: "%surface%.pads.8";   to: "decks.1.hotcues.8.trigger" }
          }

          WiresGroup
          {
            enabled: module.shift

            Wire { from: "%surface%.pads.1";   to: "decks.1.hotcues.1.delete" }
            Wire { from: "%surface%.pads.2";   to: "decks.1.hotcues.2.delete" }
            Wire { from: "%surface%.pads.3";   to: "decks.1.hotcues.3.delete" }
            Wire { from: "%surface%.pads.4";   to: "decks.1.hotcues.4.delete" }
            Wire { from: "%surface%.pads.5";   to: "decks.1.hotcues.5.delete" }
            Wire { from: "%surface%.pads.6";   to: "decks.1.hotcues.6.delete" }
            Wire { from: "%surface%.pads.7";   to: "decks.1.hotcues.7.delete" }
            Wire { from: "%surface%.pads.8";   to: "decks.1.hotcues.8.delete" }
          }
        }

        // Loop
        WiresGroup
        {
          enabled: padsMode.value == loopMode

          Wire { from: "%surface%.pads.1";     to: "loop_pads.button1" }
          Wire { from: "%surface%.pads.2";     to: "loop_pads.button2" }
          Wire { from: "%surface%.pads.3";     to: "loop_pads.button3" }
          Wire { from: "%surface%.pads.4";     to: "loop_pads.button4" }
          Wire { from: "%surface%.pads.5";     to: "beatjump_pads.button1" }
          Wire { from: "%surface%.pads.6";     to: "beatjump_pads.button2" }
          Wire { from: "%surface%.pads.7";     to: "beatjump_pads.button3" }
          Wire { from: "%surface%.pads.8";     to: "beatjump_pads.button4" }

          Wire { from: "loop_pads.value";      to: "decks.1.loop.autoloop_size"   }
          Wire { from: "loop_pads.active";     to: "decks.1.loop.autoloop_active" }

          Wire { from: "beatjump_pads.value";  to: "decks.1.beatjump.size"      }
          Wire { from: "beatjump_pads.active"; to: "decks.1.beatjump.active"    }
        }

        // Freeze/Slicer
        WiresGroup
        {
          enabled: padsMode.value == freezeMode

          Wire { from: "%surface%.pads.1";   to: "decks.1.freeze_slicer.slice1" }
          Wire { from: "%surface%.pads.2";   to: "decks.1.freeze_slicer.slice2" }
          Wire { from: "%surface%.pads.3";   to: "decks.1.freeze_slicer.slice3" }
          Wire { from: "%surface%.pads.4";   to: "decks.1.freeze_slicer.slice4" }
          Wire { from: "%surface%.pads.5";   to: "decks.1.freeze_slicer.slice5" }
          Wire { from: "%surface%.pads.6";   to: "decks.1.freeze_slicer.slice6" }
          Wire { from: "%surface%.pads.7";   to: "decks.1.freeze_slicer.slice7" }
          Wire { from: "%surface%.pads.8";   to: "decks.1.freeze_slicer.slice8" }
        }

        // Remix
        WiresGroup
        {
          enabled: padsMode.value == remixMode

          WiresGroup
          {
            enabled: !deckASequencerOn.value

            Wire { from: "decks.1.remix.capture_mode.input";  to: DirectPropertyAdapter { path: propertiesPath + ".capture"; input: false } }

            WiresGroup
            {
              enabled: !module.shift

              Wire { from: "%surface%.pads.1"; to: "decks.1.remix.1_1.primary" }
              Wire { from: "%surface%.pads.2"; to: "decks.1.remix.2_1.primary" }
              Wire { from: "%surface%.pads.3"; to: "decks.1.remix.3_1.primary" }
              Wire { from: "%surface%.pads.4"; to: "decks.1.remix.4_1.primary" }
              Wire { from: "%surface%.pads.5"; to: "decks.1.remix.1_2.primary" }
              Wire { from: "%surface%.pads.6"; to: "decks.1.remix.2_2.primary" }
              Wire { from: "%surface%.pads.7"; to: "decks.1.remix.3_2.primary" }
              Wire { from: "%surface%.pads.8"; to: "decks.1.remix.4_2.primary" }
            }

            WiresGroup
            {
              enabled: module.shift

              Wire { from: "%surface%.pads.1"; to: "decks.1.remix.1_1.secondary"  }
              Wire { from: "%surface%.pads.2"; to: "decks.1.remix.2_1.secondary"  }
              Wire { from: "%surface%.pads.3"; to: "decks.1.remix.3_1.secondary"  }
              Wire { from: "%surface%.pads.4"; to: "decks.1.remix.4_1.secondary"  }
              Wire { from: "%surface%.pads.5"; to: "decks.1.remix.1_2.secondary"  }
              Wire { from: "%surface%.pads.6"; to: "decks.1.remix.2_2.secondary"  }
              Wire { from: "%surface%.pads.7"; to: "decks.1.remix.3_2.secondary"  }
              Wire { from: "%surface%.pads.8"; to: "decks.1.remix.4_2.secondary"  }
            }

            WiresGroup
            {
              Wire { from: "decks.1.remix.1_1";     to: "%surface%.pads.1.led" }
              Wire { from: "decks.1.remix.2_1";     to: "%surface%.pads.2.led" }
              Wire { from: "decks.1.remix.3_1";     to: "%surface%.pads.3.led" }
              Wire { from: "decks.1.remix.4_1";     to: "%surface%.pads.4.led" }
              Wire { from: "decks.1.remix.1_2";     to: "%surface%.pads.5.led" }
              Wire { from: "decks.1.remix.2_2";     to: "%surface%.pads.6.led" }
              Wire { from: "decks.1.remix.3_2";     to: "%surface%.pads.7.led" }
              Wire { from: "decks.1.remix.4_2";     to: "%surface%.pads.8.led" }
            }
          }

          WiresGroup
          {
            enabled: deckASequencerOn.value

            WiresGroup
            {
              enabled: !module.shift && !remixState.value

              Wire { from: "%surface%.pads.1"; to: "decks.1.remix_sequencer.1_1.steps" }
              Wire { from: "%surface%.pads.2"; to: "decks.1.remix_sequencer.2_1.steps" }
              Wire { from: "%surface%.pads.3"; to: "decks.1.remix_sequencer.3_1.steps" }
              Wire { from: "%surface%.pads.4"; to: "decks.1.remix_sequencer.4_1.steps" }
              Wire { from: "%surface%.pads.5"; to: "decks.1.remix_sequencer.1_2.steps" }
              Wire { from: "%surface%.pads.6"; to: "decks.1.remix_sequencer.2_2.steps" }
              Wire { from: "%surface%.pads.7"; to: "decks.1.remix_sequencer.3_2.steps" }
              Wire { from: "%surface%.pads.8"; to: "decks.1.remix_sequencer.4_2.steps" }

              Wire { from: "decks.1.remix_sequencer.1_1";     to: "%surface%.pads.1.led" }
              Wire { from: "decks.1.remix_sequencer.2_1";     to: "%surface%.pads.2.led" }
              Wire { from: "decks.1.remix_sequencer.3_1";     to: "%surface%.pads.3.led" }
              Wire { from: "decks.1.remix_sequencer.4_1";     to: "%surface%.pads.4.led" }
              Wire { from: "decks.1.remix_sequencer.1_2";     to: "%surface%.pads.5.led" }
              Wire { from: "decks.1.remix_sequencer.2_2";     to: "%surface%.pads.6.led" }
              Wire { from: "decks.1.remix_sequencer.3_2";     to: "%surface%.pads.7.led" }
              Wire { from: "decks.1.remix_sequencer.4_2";     to: "%surface%.pads.8.led" }
            }

            WiresGroup
            {
              enabled: module.shift && !remixState.value

              Wire { from: "%surface%.pads.1"; to: SetPropertyAdapter { path: propertiesPath + ".top.sequencer_deck_slot"; value: 1 } }
              Wire { from: "%surface%.pads.2"; to: SetPropertyAdapter { path: propertiesPath + ".top.sequencer_deck_slot"; value: 2 } }
              Wire { from: "%surface%.pads.3"; to: SetPropertyAdapter { path: propertiesPath + ".top.sequencer_deck_slot"; value: 3 } }
              Wire { from: "%surface%.pads.4"; to: SetPropertyAdapter { path: propertiesPath + ".top.sequencer_deck_slot"; value: 4 } }

              Wire { from:  "%surface%.edit";  to: "decks.1.remix_sequencer.clear_selected_slot";  }
            }
          }
        }

        // D2 v0.4.0: Stem Mute (S5-style: pads 1-4 toggle stem slot mute)
        WiresGroup
        {
          enabled: padsMode.value == stemMode && !module.shift

          Wire { from: "%surface%.pads.1"; to: "decks.1.stems.1.muted" }
          Wire { from: "%surface%.pads.2"; to: "decks.1.stems.2.muted" }
          Wire { from: "%surface%.pads.3"; to: "decks.1.stems.3.muted" }
          Wire { from: "%surface%.pads.4"; to: "decks.1.stems.4.muted" }
        }

        // D2 v0.4.0: Stem shift pads — FX send on/off (1-4) + filter on/off (5-8)
        WiresGroup
        {
          enabled: padsMode.value == stemMode && module.shift

          Wire { from: "%surface%.pads.1"; to: "decks.1.stems.1.fx_send_on" }
          Wire { from: "%surface%.pads.2"; to: "decks.1.stems.2.fx_send_on" }
          Wire { from: "%surface%.pads.3"; to: "decks.1.stems.3.fx_send_on" }
          Wire { from: "%surface%.pads.4"; to: "decks.1.stems.4.fx_send_on" }

          Wire { from: "%surface%.pads.5"; to: ButtonScriptAdapter { color: Color.Blue; brightness: sfxStem1FilterOn.value ? onBrightness : dimmedBrightness; onPress: { sfxStem1FilterOn.value = !sfxStem1FilterOn.value } } }
          Wire { from: "%surface%.pads.6"; to: ButtonScriptAdapter { color: Color.Blue; brightness: sfxStem2FilterOn.value ? onBrightness : dimmedBrightness; onPress: { sfxStem2FilterOn.value = !sfxStem2FilterOn.value } } }
          Wire { from: "%surface%.pads.7"; to: ButtonScriptAdapter { color: Color.Blue; brightness: sfxStem3FilterOn.value ? onBrightness : dimmedBrightness; onPress: { sfxStem3FilterOn.value = !sfxStem3FilterOn.value } } }
          Wire { from: "%surface%.pads.8"; to: ButtonScriptAdapter { color: Color.Blue; brightness: sfxStem4FilterOn.value ? onBrightness : dimmedBrightness; onPress: { sfxStem4FilterOn.value = !sfxStem4FilterOn.value } } }
        }
      }

      // Deck C
      WiresGroup
      {
        enabled: (padsFocusedDeckId == 3)

        // Hotcues
        WiresGroup
        {
          enabled: padsMode.value == hotcueMode

          WiresGroup
          {
            enabled: !module.shift

            Wire { from: "%surface%.pads.1";   to: "decks.3.hotcues.1.trigger" }
            Wire { from: "%surface%.pads.2";   to: "decks.3.hotcues.2.trigger" }
            Wire { from: "%surface%.pads.3";   to: "decks.3.hotcues.3.trigger" }
            Wire { from: "%surface%.pads.4";   to: "decks.3.hotcues.4.trigger" }
            Wire { from: "%surface%.pads.5";   to: "decks.3.hotcues.5.trigger" }
            Wire { from: "%surface%.pads.6";   to: "decks.3.hotcues.6.trigger" }
            Wire { from: "%surface%.pads.7";   to: "decks.3.hotcues.7.trigger" }
            Wire { from: "%surface%.pads.8";   to: "decks.3.hotcues.8.trigger" }
          }

          WiresGroup
          {
            enabled: module.shift

            Wire { from: "%surface%.pads.1";   to: "decks.3.hotcues.1.delete" }
            Wire { from: "%surface%.pads.2";   to: "decks.3.hotcues.2.delete" }
            Wire { from: "%surface%.pads.3";   to: "decks.3.hotcues.3.delete" }
            Wire { from: "%surface%.pads.4";   to: "decks.3.hotcues.4.delete" }
            Wire { from: "%surface%.pads.5";   to: "decks.3.hotcues.5.delete" }
            Wire { from: "%surface%.pads.6";   to: "decks.3.hotcues.6.delete" }
            Wire { from: "%surface%.pads.7";   to: "decks.3.hotcues.7.delete" }
            Wire { from: "%surface%.pads.8";   to: "decks.3.hotcues.8.delete" }
          }
        }

        // Loop
        WiresGroup
        {
          enabled: padsMode.value == loopMode

          Wire { from: "%surface%.pads.1";     to: "loop_pads.button1" }
          Wire { from: "%surface%.pads.2";     to: "loop_pads.button2" }
          Wire { from: "%surface%.pads.3";     to: "loop_pads.button3" }
          Wire { from: "%surface%.pads.4";     to: "loop_pads.button4" }
          Wire { from: "%surface%.pads.5";     to: "beatjump_pads.button1" }
          Wire { from: "%surface%.pads.6";     to: "beatjump_pads.button2" }
          Wire { from: "%surface%.pads.7";     to: "beatjump_pads.button3" }
          Wire { from: "%surface%.pads.8";     to: "beatjump_pads.button4" }

          Wire { from: "loop_pads.value";      to: "decks.3.loop.autoloop_size"   }
          Wire { from: "loop_pads.active";     to: "decks.3.loop.autoloop_active" }

          Wire { from: "beatjump_pads.value";  to: "decks.3.beatjump.size"      }
          Wire { from: "beatjump_pads.active"; to: "decks.3.beatjump.active"    }
        }

        // Freeze/Slicer
        WiresGroup
        {
          enabled: padsMode.value == freezeMode

          Wire { from: "%surface%.pads.1";   to: "decks.3.freeze_slicer.slice1" }
          Wire { from: "%surface%.pads.2";   to: "decks.3.freeze_slicer.slice2" }
          Wire { from: "%surface%.pads.3";   to: "decks.3.freeze_slicer.slice3" }
          Wire { from: "%surface%.pads.4";   to: "decks.3.freeze_slicer.slice4" }
          Wire { from: "%surface%.pads.5";   to: "decks.3.freeze_slicer.slice5" }
          Wire { from: "%surface%.pads.6";   to: "decks.3.freeze_slicer.slice6" }
          Wire { from: "%surface%.pads.7";   to: "decks.3.freeze_slicer.slice7" }
          Wire { from: "%surface%.pads.8";   to: "decks.3.freeze_slicer.slice8" }
        }

        // Remix
        WiresGroup
        {
          enabled: padsMode.value == remixMode

          WiresGroup
          {
            enabled: !deckCSequencerOn.value

            Wire { from: "decks.3.remix.capture_mode.input";  to: DirectPropertyAdapter { path: propertiesPath + ".capture"; input: false } }

            WiresGroup
            {
              enabled: !module.shift

              Wire { from: "%surface%.pads.1"; to: "decks.3.remix.1_1.primary" }
              Wire { from: "%surface%.pads.2"; to: "decks.3.remix.2_1.primary" }
              Wire { from: "%surface%.pads.3"; to: "decks.3.remix.3_1.primary" }
              Wire { from: "%surface%.pads.4"; to: "decks.3.remix.4_1.primary" }
              Wire { from: "%surface%.pads.5"; to: "decks.3.remix.1_2.primary" }
              Wire { from: "%surface%.pads.6"; to: "decks.3.remix.2_2.primary" }
              Wire { from: "%surface%.pads.7"; to: "decks.3.remix.3_2.primary" }
              Wire { from: "%surface%.pads.8"; to: "decks.3.remix.4_2.primary" }
            }

            WiresGroup
            {
              enabled: module.shift

              Wire { from: "%surface%.pads.1"; to: "decks.3.remix.1_1.secondary" }
              Wire { from: "%surface%.pads.2"; to: "decks.3.remix.2_1.secondary" }
              Wire { from: "%surface%.pads.3"; to: "decks.3.remix.3_1.secondary" }
              Wire { from: "%surface%.pads.4"; to: "decks.3.remix.4_1.secondary" }
              Wire { from: "%surface%.pads.5"; to: "decks.3.remix.1_2.secondary" }
              Wire { from: "%surface%.pads.6"; to: "decks.3.remix.2_2.secondary" }
              Wire { from: "%surface%.pads.7"; to: "decks.3.remix.3_2.secondary" }
              Wire { from: "%surface%.pads.8"; to: "decks.3.remix.4_2.secondary" }
            }

            WiresGroup
            {
              Wire { from: "decks.3.remix.1_1";     to: "%surface%.pads.1.led" }
              Wire { from: "decks.3.remix.2_1";     to: "%surface%.pads.2.led" }
              Wire { from: "decks.3.remix.3_1";     to: "%surface%.pads.3.led" }
              Wire { from: "decks.3.remix.4_1";     to: "%surface%.pads.4.led" }
              Wire { from: "decks.3.remix.1_2";     to: "%surface%.pads.5.led" }
              Wire { from: "decks.3.remix.2_2";     to: "%surface%.pads.6.led" }
              Wire { from: "decks.3.remix.3_2";     to: "%surface%.pads.7.led" }
              Wire { from: "decks.3.remix.4_2";     to: "%surface%.pads.8.led" }
            }
          }

          WiresGroup
          {
            enabled: deckCSequencerOn.value

            WiresGroup
            {
              enabled: !module.shift && !remixState.value

              Wire { from: "%surface%.pads.1"; to: "decks.3.remix_sequencer.1_1.steps" }
              Wire { from: "%surface%.pads.2"; to: "decks.3.remix_sequencer.2_1.steps" }
              Wire { from: "%surface%.pads.3"; to: "decks.3.remix_sequencer.3_1.steps" }
              Wire { from: "%surface%.pads.4"; to: "decks.3.remix_sequencer.4_1.steps" }
              Wire { from: "%surface%.pads.5"; to: "decks.3.remix_sequencer.1_2.steps" }
              Wire { from: "%surface%.pads.6"; to: "decks.3.remix_sequencer.2_2.steps" }
              Wire { from: "%surface%.pads.7"; to: "decks.3.remix_sequencer.3_2.steps" }
              Wire { from: "%surface%.pads.8"; to: "decks.3.remix_sequencer.4_2.steps" }

              Wire { from: "decks.3.remix_sequencer.1_1";     to: "%surface%.pads.1.led" }
              Wire { from: "decks.3.remix_sequencer.2_1";     to: "%surface%.pads.2.led" }
              Wire { from: "decks.3.remix_sequencer.3_1";     to: "%surface%.pads.3.led" }
              Wire { from: "decks.3.remix_sequencer.4_1";     to: "%surface%.pads.4.led" }
              Wire { from: "decks.3.remix_sequencer.1_2";     to: "%surface%.pads.5.led" }
              Wire { from: "decks.3.remix_sequencer.2_2";     to: "%surface%.pads.6.led" }
              Wire { from: "decks.3.remix_sequencer.3_2";     to: "%surface%.pads.7.led" }
              Wire { from: "decks.3.remix_sequencer.4_2";     to: "%surface%.pads.8.led" }
            }

            WiresGroup
            {
              enabled: module.shift && !remixState.value

              Wire { from: "%surface%.pads.1"; to: SetPropertyAdapter { path: propertiesPath + ".bottom.sequencer_deck_slot"; value: 1 } }
              Wire { from: "%surface%.pads.2"; to: SetPropertyAdapter { path: propertiesPath + ".bottom.sequencer_deck_slot"; value: 2 } }
              Wire { from: "%surface%.pads.3"; to: SetPropertyAdapter { path: propertiesPath + ".bottom.sequencer_deck_slot"; value: 3 } }
              Wire { from: "%surface%.pads.4"; to: SetPropertyAdapter { path: propertiesPath + ".bottom.sequencer_deck_slot"; value: 4 } }

              Wire { from:  "%surface%.edit";  to: "decks.3.remix_sequencer.clear_selected_slot";  }
            }
          }
        }

        // D2 v0.4.0: Stem Mute (S5-style: pads 1-4 toggle stem slot mute)
        WiresGroup
        {
          enabled: padsMode.value == stemMode && !module.shift

          Wire { from: "%surface%.pads.1"; to: "decks.3.stems.1.muted" }
          Wire { from: "%surface%.pads.2"; to: "decks.3.stems.2.muted" }
          Wire { from: "%surface%.pads.3"; to: "decks.3.stems.3.muted" }
          Wire { from: "%surface%.pads.4"; to: "decks.3.stems.4.muted" }
        }

        // D2 v0.4.0: Stem shift pads — FX send on/off (1-4) + filter on/off (5-8)
        WiresGroup
        {
          enabled: padsMode.value == stemMode && module.shift

          Wire { from: "%surface%.pads.1"; to: "decks.3.stems.1.fx_send_on" }
          Wire { from: "%surface%.pads.2"; to: "decks.3.stems.2.fx_send_on" }
          Wire { from: "%surface%.pads.3"; to: "decks.3.stems.3.fx_send_on" }
          Wire { from: "%surface%.pads.4"; to: "decks.3.stems.4.fx_send_on" }

          Wire { from: "%surface%.pads.5"; to: ButtonScriptAdapter { color: Color.Blue; brightness: sfxStem1FilterOn.value ? onBrightness : dimmedBrightness; onPress: { sfxStem1FilterOn.value = !sfxStem1FilterOn.value } } }
          Wire { from: "%surface%.pads.6"; to: ButtonScriptAdapter { color: Color.Blue; brightness: sfxStem2FilterOn.value ? onBrightness : dimmedBrightness; onPress: { sfxStem2FilterOn.value = !sfxStem2FilterOn.value } } }
          Wire { from: "%surface%.pads.7"; to: ButtonScriptAdapter { color: Color.Blue; brightness: sfxStem3FilterOn.value ? onBrightness : dimmedBrightness; onPress: { sfxStem3FilterOn.value = !sfxStem3FilterOn.value } } }
          Wire { from: "%surface%.pads.8"; to: ButtonScriptAdapter { color: Color.Blue; brightness: sfxStem4FilterOn.value ? onBrightness : dimmedBrightness; onPress: { sfxStem4FilterOn.value = !sfxStem4FilterOn.value } } }
        }
      }

      // Deck B
      WiresGroup
      {
        enabled: (padsFocusedDeckId == 2)

        // Hotcues
        WiresGroup
        {
          enabled: padsMode.value == hotcueMode

          WiresGroup
          {
            enabled: !module.shift

            Wire { from: "%surface%.pads.1";    to: "decks.2.hotcues.1.trigger" }
            Wire { from: "%surface%.pads.2";    to: "decks.2.hotcues.2.trigger" }
            Wire { from: "%surface%.pads.3";    to: "decks.2.hotcues.3.trigger" }
            Wire { from: "%surface%.pads.4";    to: "decks.2.hotcues.4.trigger" }
            Wire { from: "%surface%.pads.5";    to: "decks.2.hotcues.5.trigger" }
            Wire { from: "%surface%.pads.6";    to: "decks.2.hotcues.6.trigger" }
            Wire { from: "%surface%.pads.7";    to: "decks.2.hotcues.7.trigger" }
            Wire { from: "%surface%.pads.8";    to: "decks.2.hotcues.8.trigger" }
          }

          WiresGroup
          {
            enabled: module.shift

            Wire { from: "%surface%.pads.1";    to: "decks.2.hotcues.1.delete" }
            Wire { from: "%surface%.pads.2";    to: "decks.2.hotcues.2.delete" }
            Wire { from: "%surface%.pads.3";    to: "decks.2.hotcues.3.delete" }
            Wire { from: "%surface%.pads.4";    to: "decks.2.hotcues.4.delete" }
            Wire { from: "%surface%.pads.5";    to: "decks.2.hotcues.5.delete" }
            Wire { from: "%surface%.pads.6";    to: "decks.2.hotcues.6.delete" }
            Wire { from: "%surface%.pads.7";    to: "decks.2.hotcues.7.delete" }
            Wire { from: "%surface%.pads.8";    to: "decks.2.hotcues.8.delete" }
          }
        }

        // Loop
        WiresGroup
        {
          enabled: padsMode.value == loopMode

          Wire { from: "%surface%.pads.1";     to: "loop_pads.button1" }
          Wire { from: "%surface%.pads.2";     to: "loop_pads.button2" }
          Wire { from: "%surface%.pads.3";     to: "loop_pads.button3" }
          Wire { from: "%surface%.pads.4";     to: "loop_pads.button4" }
          Wire { from: "%surface%.pads.5";     to: "beatjump_pads.button1" }
          Wire { from: "%surface%.pads.6";     to: "beatjump_pads.button2" }
          Wire { from: "%surface%.pads.7";     to: "beatjump_pads.button3" }
          Wire { from: "%surface%.pads.8";     to: "beatjump_pads.button4" }

          Wire { from: "loop_pads.value";      to: "decks.2.loop.autoloop_size"   }
          Wire { from: "loop_pads.active";     to: "decks.2.loop.autoloop_active" }

          Wire { from: "beatjump_pads.value";  to: "decks.2.beatjump.size"      }
          Wire { from: "beatjump_pads.active"; to: "decks.2.beatjump.active"    }
        }

        // Freeze/Slicer
        WiresGroup
        {
          enabled: padsMode.value == freezeMode

          Wire { from: "%surface%.pads.1";   to: "decks.2.freeze_slicer.slice1" }
          Wire { from: "%surface%.pads.2";   to: "decks.2.freeze_slicer.slice2" }
          Wire { from: "%surface%.pads.3";   to: "decks.2.freeze_slicer.slice3" }
          Wire { from: "%surface%.pads.4";   to: "decks.2.freeze_slicer.slice4" }
          Wire { from: "%surface%.pads.5";   to: "decks.2.freeze_slicer.slice5" }
          Wire { from: "%surface%.pads.6";   to: "decks.2.freeze_slicer.slice6" }
          Wire { from: "%surface%.pads.7";   to: "decks.2.freeze_slicer.slice7" }
          Wire { from: "%surface%.pads.8";   to: "decks.2.freeze_slicer.slice8" }
        }
        // Remix
        WiresGroup
        {
          enabled: padsMode.value == remixMode

          WiresGroup
          {
            enabled: !deckBSequencerOn.value

            Wire { from: "decks.2.remix.capture_mode.input";  to: DirectPropertyAdapter { path: propertiesPath + ".capture"; input: false } }

            WiresGroup
            {
              enabled: !module.shift

              Wire { from: "%surface%.pads.1"; to: "decks.2.remix.1_1.primary" }
              Wire { from: "%surface%.pads.2"; to: "decks.2.remix.2_1.primary" }
              Wire { from: "%surface%.pads.3"; to: "decks.2.remix.3_1.primary" }
              Wire { from: "%surface%.pads.4"; to: "decks.2.remix.4_1.primary" }
              Wire { from: "%surface%.pads.5"; to: "decks.2.remix.1_2.primary" }
              Wire { from: "%surface%.pads.6"; to: "decks.2.remix.2_2.primary" }
              Wire { from: "%surface%.pads.7"; to: "decks.2.remix.3_2.primary" }
              Wire { from: "%surface%.pads.8"; to: "decks.2.remix.4_2.primary" }
            }

            WiresGroup
            {
              enabled: module.shift

              Wire { from: "%surface%.pads.1"; to: "decks.2.remix.1_1.secondary" }
              Wire { from: "%surface%.pads.2"; to: "decks.2.remix.2_1.secondary" }
              Wire { from: "%surface%.pads.3"; to: "decks.2.remix.3_1.secondary" }
              Wire { from: "%surface%.pads.4"; to: "decks.2.remix.4_1.secondary" }
              Wire { from: "%surface%.pads.5"; to: "decks.2.remix.1_2.secondary" }
              Wire { from: "%surface%.pads.6"; to: "decks.2.remix.2_2.secondary" }
              Wire { from: "%surface%.pads.7"; to: "decks.2.remix.3_2.secondary" }
              Wire { from: "%surface%.pads.8"; to: "decks.2.remix.4_2.secondary" }
            }

            WiresGroup
            {
              Wire { from: "decks.2.remix.1_1";     to: "%surface%.pads.1.led" }
              Wire { from: "decks.2.remix.2_1";     to: "%surface%.pads.2.led" }
              Wire { from: "decks.2.remix.3_1";     to: "%surface%.pads.3.led" }
              Wire { from: "decks.2.remix.4_1";     to: "%surface%.pads.4.led" }
              Wire { from: "decks.2.remix.1_2";     to: "%surface%.pads.5.led" }
              Wire { from: "decks.2.remix.2_2";     to: "%surface%.pads.6.led" }
              Wire { from: "decks.2.remix.3_2";     to: "%surface%.pads.7.led" }
              Wire { from: "decks.2.remix.4_2";     to: "%surface%.pads.8.led" }
            }
          }

          WiresGroup
          {
            enabled: deckBSequencerOn.value

            WiresGroup
            {
              enabled: !module.shift && !remixState.value

              Wire { from: "%surface%.pads.1"; to: "decks.2.remix_sequencer.1_1.steps" }
              Wire { from: "%surface%.pads.2"; to: "decks.2.remix_sequencer.2_1.steps" }
              Wire { from: "%surface%.pads.3"; to: "decks.2.remix_sequencer.3_1.steps" }
              Wire { from: "%surface%.pads.4"; to: "decks.2.remix_sequencer.4_1.steps" }
              Wire { from: "%surface%.pads.5"; to: "decks.2.remix_sequencer.1_2.steps" }
              Wire { from: "%surface%.pads.6"; to: "decks.2.remix_sequencer.2_2.steps" }
              Wire { from: "%surface%.pads.7"; to: "decks.2.remix_sequencer.3_2.steps" }
              Wire { from: "%surface%.pads.8"; to: "decks.2.remix_sequencer.4_2.steps" }

              Wire { from: "decks.2.remix_sequencer.1_1";     to: "%surface%.pads.1.led" }
              Wire { from: "decks.2.remix_sequencer.2_1";     to: "%surface%.pads.2.led" }
              Wire { from: "decks.2.remix_sequencer.3_1";     to: "%surface%.pads.3.led" }
              Wire { from: "decks.2.remix_sequencer.4_1";     to: "%surface%.pads.4.led" }
              Wire { from: "decks.2.remix_sequencer.1_2";     to: "%surface%.pads.5.led" }
              Wire { from: "decks.2.remix_sequencer.2_2";     to: "%surface%.pads.6.led" }
              Wire { from: "decks.2.remix_sequencer.3_2";     to: "%surface%.pads.7.led" }
              Wire { from: "decks.2.remix_sequencer.4_2";     to: "%surface%.pads.8.led" }
            }

            WiresGroup
            {
              enabled: module.shift && !remixState.value

              Wire { from: "%surface%.pads.1"; to: SetPropertyAdapter { path: propertiesPath + ".top.sequencer_deck_slot"; value: 1 } }
              Wire { from: "%surface%.pads.2"; to: SetPropertyAdapter { path: propertiesPath + ".top.sequencer_deck_slot"; value: 2 } }
              Wire { from: "%surface%.pads.3"; to: SetPropertyAdapter { path: propertiesPath + ".top.sequencer_deck_slot"; value: 3 } }
              Wire { from: "%surface%.pads.4"; to: SetPropertyAdapter { path: propertiesPath + ".top.sequencer_deck_slot"; value: 4 } }

              Wire { from: "%surface%.edit";   to: "decks.2.remix_sequencer.clear_selected_slot";  }
            }
          }
        }

        // D2 v0.4.0: Stem Mute (S5-style: pads 1-4 toggle stem slot mute)
        WiresGroup
        {
          enabled: padsMode.value == stemMode && !module.shift

          Wire { from: "%surface%.pads.1"; to: "decks.2.stems.1.muted" }
          Wire { from: "%surface%.pads.2"; to: "decks.2.stems.2.muted" }
          Wire { from: "%surface%.pads.3"; to: "decks.2.stems.3.muted" }
          Wire { from: "%surface%.pads.4"; to: "decks.2.stems.4.muted" }
        }

        // D2 v0.4.0: Stem shift pads — FX send on/off (1-4) + filter on/off (5-8)
        WiresGroup
        {
          enabled: padsMode.value == stemMode && module.shift

          Wire { from: "%surface%.pads.1"; to: "decks.2.stems.1.fx_send_on" }
          Wire { from: "%surface%.pads.2"; to: "decks.2.stems.2.fx_send_on" }
          Wire { from: "%surface%.pads.3"; to: "decks.2.stems.3.fx_send_on" }
          Wire { from: "%surface%.pads.4"; to: "decks.2.stems.4.fx_send_on" }

          Wire { from: "%surface%.pads.5"; to: ButtonScriptAdapter { color: Color.Blue; brightness: sfxStem1FilterOn.value ? onBrightness : dimmedBrightness; onPress: { sfxStem1FilterOn.value = !sfxStem1FilterOn.value } } }
          Wire { from: "%surface%.pads.6"; to: ButtonScriptAdapter { color: Color.Blue; brightness: sfxStem2FilterOn.value ? onBrightness : dimmedBrightness; onPress: { sfxStem2FilterOn.value = !sfxStem2FilterOn.value } } }
          Wire { from: "%surface%.pads.7"; to: ButtonScriptAdapter { color: Color.Blue; brightness: sfxStem3FilterOn.value ? onBrightness : dimmedBrightness; onPress: { sfxStem3FilterOn.value = !sfxStem3FilterOn.value } } }
          Wire { from: "%surface%.pads.8"; to: ButtonScriptAdapter { color: Color.Blue; brightness: sfxStem4FilterOn.value ? onBrightness : dimmedBrightness; onPress: { sfxStem4FilterOn.value = !sfxStem4FilterOn.value } } }
        }
      }

      // Deck D
      WiresGroup
      {
        enabled: (padsFocusedDeckId == 4)

        // Hotcues
        WiresGroup
        {
          enabled: padsMode.value == hotcueMode

          WiresGroup
          {
            enabled: !module.shift

            Wire { from: "%surface%.pads.1";    to: "decks.4.hotcues.1.trigger" }
            Wire { from: "%surface%.pads.2";    to: "decks.4.hotcues.2.trigger" }
            Wire { from: "%surface%.pads.3";    to: "decks.4.hotcues.3.trigger" }
            Wire { from: "%surface%.pads.4";    to: "decks.4.hotcues.4.trigger" }
            Wire { from: "%surface%.pads.5";    to: "decks.4.hotcues.5.trigger" }
            Wire { from: "%surface%.pads.6";    to: "decks.4.hotcues.6.trigger" }
            Wire { from: "%surface%.pads.7";    to: "decks.4.hotcues.7.trigger" }
            Wire { from: "%surface%.pads.8";    to: "decks.4.hotcues.8.trigger" }
          }

          WiresGroup
          {
            enabled: module.shift

            Wire { from: "%surface%.pads.1";    to: "decks.4.hotcues.1.delete" }
            Wire { from: "%surface%.pads.2";    to: "decks.4.hotcues.2.delete" }
            Wire { from: "%surface%.pads.3";    to: "decks.4.hotcues.3.delete" }
            Wire { from: "%surface%.pads.4";    to: "decks.4.hotcues.4.delete" }
            Wire { from: "%surface%.pads.5";    to: "decks.4.hotcues.5.delete" }
            Wire { from: "%surface%.pads.6";    to: "decks.4.hotcues.6.delete" }
            Wire { from: "%surface%.pads.7";    to: "decks.4.hotcues.7.delete" }
            Wire { from: "%surface%.pads.8";    to: "decks.4.hotcues.8.delete" }
          }
        }

        // Loop
        WiresGroup
        {
          enabled: padsMode.value == loopMode

          Wire { from: "%surface%.pads.1";     to: "loop_pads.button1" }
          Wire { from: "%surface%.pads.2";     to: "loop_pads.button2" }
          Wire { from: "%surface%.pads.3";     to: "loop_pads.button3" }
          Wire { from: "%surface%.pads.4";     to: "loop_pads.button4" }
          Wire { from: "%surface%.pads.5";     to: "beatjump_pads.button1" }
          Wire { from: "%surface%.pads.6";     to: "beatjump_pads.button2" }
          Wire { from: "%surface%.pads.7";     to: "beatjump_pads.button3" }
          Wire { from: "%surface%.pads.8";     to: "beatjump_pads.button4" }

          Wire { from: "loop_pads.value";      to: "decks.4.loop.autoloop_size"   }
          Wire { from: "loop_pads.active";     to: "decks.4.loop.autoloop_active" }

          Wire { from: "beatjump_pads.value";  to: "decks.4.beatjump.size"      }
          Wire { from: "beatjump_pads.active"; to: "decks.4.beatjump.active"    }
        }

        // Freeze/Slicer
        WiresGroup
        {
          enabled: padsMode.value == freezeMode

          Wire { from: "%surface%.pads.1";   to: "decks.4.freeze_slicer.slice1" }
          Wire { from: "%surface%.pads.2";   to: "decks.4.freeze_slicer.slice2" }
          Wire { from: "%surface%.pads.3";   to: "decks.4.freeze_slicer.slice3" }
          Wire { from: "%surface%.pads.4";   to: "decks.4.freeze_slicer.slice4" }
          Wire { from: "%surface%.pads.5";   to: "decks.4.freeze_slicer.slice5" }
          Wire { from: "%surface%.pads.6";   to: "decks.4.freeze_slicer.slice6" }
          Wire { from: "%surface%.pads.7";   to: "decks.4.freeze_slicer.slice7" }
          Wire { from: "%surface%.pads.8";   to: "decks.4.freeze_slicer.slice8" }
        }

        // Remix
        WiresGroup
        {
          enabled: padsMode.value == remixMode

          WiresGroup
          {
            enabled: !deckDSequencerOn.value

            Wire { from: "decks.4.remix.capture_mode.input";  to: DirectPropertyAdapter { path: propertiesPath + ".capture"; input: false } }

            WiresGroup
            {
              enabled: !module.shift

              Wire { from: "%surface%.pads.1"; to: "decks.4.remix.1_1.primary" }
              Wire { from: "%surface%.pads.2"; to: "decks.4.remix.2_1.primary" }
              Wire { from: "%surface%.pads.3"; to: "decks.4.remix.3_1.primary" }
              Wire { from: "%surface%.pads.4"; to: "decks.4.remix.4_1.primary" }
              Wire { from: "%surface%.pads.5"; to: "decks.4.remix.1_2.primary" }
              Wire { from: "%surface%.pads.6"; to: "decks.4.remix.2_2.primary" }
              Wire { from: "%surface%.pads.7"; to: "decks.4.remix.3_2.primary" }
              Wire { from: "%surface%.pads.8"; to: "decks.4.remix.4_2.primary" }
            }

            WiresGroup
            {
              enabled: module.shift

              Wire { from: "%surface%.pads.1"; to: "decks.4.remix.1_1.secondary" }
              Wire { from: "%surface%.pads.2"; to: "decks.4.remix.2_1.secondary" }
              Wire { from: "%surface%.pads.3"; to: "decks.4.remix.3_1.secondary" }
              Wire { from: "%surface%.pads.4"; to: "decks.4.remix.4_1.secondary" }
              Wire { from: "%surface%.pads.5"; to: "decks.4.remix.1_2.secondary" }
              Wire { from: "%surface%.pads.6"; to: "decks.4.remix.2_2.secondary" }
              Wire { from: "%surface%.pads.7"; to: "decks.4.remix.3_2.secondary" }
              Wire { from: "%surface%.pads.8"; to: "decks.4.remix.4_2.secondary" }
            }

            WiresGroup
            {
              Wire { from: "decks.4.remix.1_1";     to: "%surface%.pads.1.led" }
              Wire { from: "decks.4.remix.2_1";     to: "%surface%.pads.2.led" }
              Wire { from: "decks.4.remix.3_1";     to: "%surface%.pads.3.led" }
              Wire { from: "decks.4.remix.4_1";     to: "%surface%.pads.4.led" }
              Wire { from: "decks.4.remix.1_2";     to: "%surface%.pads.5.led" }
              Wire { from: "decks.4.remix.2_2";     to: "%surface%.pads.6.led" }
              Wire { from: "decks.4.remix.3_2";     to: "%surface%.pads.7.led" }
              Wire { from: "decks.4.remix.4_2";     to: "%surface%.pads.8.led" }
            }
          }

          WiresGroup
          {
            enabled: deckDSequencerOn.value

            WiresGroup
            {
              enabled: !module.shift && !remixState.value

              Wire { from: "%surface%.pads.1"; to: "decks.4.remix_sequencer.1_1.steps" }
              Wire { from: "%surface%.pads.2"; to: "decks.4.remix_sequencer.2_1.steps" }
              Wire { from: "%surface%.pads.3"; to: "decks.4.remix_sequencer.3_1.steps" }
              Wire { from: "%surface%.pads.4"; to: "decks.4.remix_sequencer.4_1.steps" }
              Wire { from: "%surface%.pads.5"; to: "decks.4.remix_sequencer.1_2.steps" }
              Wire { from: "%surface%.pads.6"; to: "decks.4.remix_sequencer.2_2.steps" }
              Wire { from: "%surface%.pads.7"; to: "decks.4.remix_sequencer.3_2.steps" }
              Wire { from: "%surface%.pads.8"; to: "decks.4.remix_sequencer.4_2.steps" }

              Wire { from: "decks.4.remix_sequencer.1_1";     to: "%surface%.pads.1.led" }
              Wire { from: "decks.4.remix_sequencer.2_1";     to: "%surface%.pads.2.led" }
              Wire { from: "decks.4.remix_sequencer.3_1";     to: "%surface%.pads.3.led" }
              Wire { from: "decks.4.remix_sequencer.4_1";     to: "%surface%.pads.4.led" }
              Wire { from: "decks.4.remix_sequencer.1_2";     to: "%surface%.pads.5.led" }
              Wire { from: "decks.4.remix_sequencer.2_2";     to: "%surface%.pads.6.led" }
              Wire { from: "decks.4.remix_sequencer.3_2";     to: "%surface%.pads.7.led" }
              Wire { from: "decks.4.remix_sequencer.4_2";     to: "%surface%.pads.8.led" }
            }

            WiresGroup
            {
              enabled: module.shift && !remixState.value

              Wire { from: "%surface%.pads.1"; to: SetPropertyAdapter { path: propertiesPath + ".bottom.sequencer_deck_slot"; value: 1 } }
              Wire { from: "%surface%.pads.2"; to: SetPropertyAdapter { path: propertiesPath + ".bottom.sequencer_deck_slot"; value: 2 } }
              Wire { from: "%surface%.pads.3"; to: SetPropertyAdapter { path: propertiesPath + ".bottom.sequencer_deck_slot"; value: 3 } }
              Wire { from: "%surface%.pads.4"; to: SetPropertyAdapter { path: propertiesPath + ".bottom.sequencer_deck_slot"; value: 4 } }

              Wire { from: "%surface%.edit"  ; to: "decks.4.remix_sequencer.clear_selected_slot";  }
            }
          }
        }

        // D2 v0.4.0: Stem Mute (S5-style: pads 1-4 toggle stem slot mute)
        WiresGroup
        {
          enabled: padsMode.value == stemMode && !module.shift

          Wire { from: "%surface%.pads.1"; to: "decks.4.stems.1.muted" }
          Wire { from: "%surface%.pads.2"; to: "decks.4.stems.2.muted" }
          Wire { from: "%surface%.pads.3"; to: "decks.4.stems.3.muted" }
          Wire { from: "%surface%.pads.4"; to: "decks.4.stems.4.muted" }
        }

        // D2 v0.4.0: Stem shift pads — FX send on/off (1-4) + filter on/off (5-8)
        WiresGroup
        {
          enabled: padsMode.value == stemMode && module.shift

          Wire { from: "%surface%.pads.1"; to: "decks.4.stems.1.fx_send_on" }
          Wire { from: "%surface%.pads.2"; to: "decks.4.stems.2.fx_send_on" }
          Wire { from: "%surface%.pads.3"; to: "decks.4.stems.3.fx_send_on" }
          Wire { from: "%surface%.pads.4"; to: "decks.4.stems.4.fx_send_on" }

          Wire { from: "%surface%.pads.5"; to: ButtonScriptAdapter { color: Color.Blue; brightness: sfxStem1FilterOn.value ? onBrightness : dimmedBrightness; onPress: { sfxStem1FilterOn.value = !sfxStem1FilterOn.value } } }
          Wire { from: "%surface%.pads.6"; to: ButtonScriptAdapter { color: Color.Blue; brightness: sfxStem2FilterOn.value ? onBrightness : dimmedBrightness; onPress: { sfxStem2FilterOn.value = !sfxStem2FilterOn.value } } }
          Wire { from: "%surface%.pads.7"; to: ButtonScriptAdapter { color: Color.Blue; brightness: sfxStem3FilterOn.value ? onBrightness : dimmedBrightness; onPress: { sfxStem3FilterOn.value = !sfxStem3FilterOn.value } } }
          Wire { from: "%surface%.pads.8"; to: ButtonScriptAdapter { color: Color.Blue; brightness: sfxStem4FilterOn.value ? onBrightness : dimmedBrightness; onPress: { sfxStem4FilterOn.value = !sfxStem4FilterOn.value } } }
        }
      }

      // Freeze
      Wire { from: "%surface%.freeze"; to: DirectPropertyAdapter { path: propertiesPath + ".freeze"; output: false } enabled: hasFreezeMode(focusedDeckType) }

      // Edit: Duplicate focused deck to the other deck in the pair (A↔C or B↔D).
      //   On press: mutes instrumentals on source, triggers duplicate, records running state.
      //   On load:  onDeckLoaded mutes vocals on target and auto-plays if source was running.
      //   Note: the standard beatgrid Edit wire is guarded with padsMode != stemMode so there is no conflict.
      WiresGroup
      {
        enabled: (duplicateDeckOnlyInStemMode ? padsMode.value == stemMode : true)

        Wire
        {
          from: "%surface%.edit"
          to: ButtonScriptAdapter
          {
            brightness: duplicateDeckOpposingRunning ? onBrightness : dimmedBrightness
            onPress:
            {
              if (duplicateDeckOpposingRunning)
              {
                // Opposing deck is playing — stop it by setting app.traktor.decks.N.play to false.
                // (false = stopped, true = playing; same property auto-play uses to start the deck)
                switch (duplicateDeckTargetId) {
                  case 1: deckAPlay.value = false; break
                  case 2: deckBPlay.value = false; break
                  case 3: deckCPlay.value = false; break
                  case 4: deckDPlay.value = false; break
                }

                // Re-enable all stem slots on both decks (undo the vocal/instrumental split).
                dupStopTargetStem1Muted.value = false
                dupStopTargetStem2Muted.value = false
                dupStopTargetStem3Muted.value = false
                dupStopTargetStem4Muted.value = false
                sfxStem1Muted.value = false
                sfxStem2Muted.value = false
                sfxStem3Muted.value = false
                sfxStem4Muted.value = false
              }
              else
              {
                // Record running state before anything changes.
                switch (padsFocusedDeckId) {
                  case 1: duplicateDeckSourceWasRunning = deckARunning.value; break
                  case 2: duplicateDeckSourceWasRunning = deckBRunning.value; break
                  case 3: duplicateDeckSourceWasRunning = deckCRunning.value; break
                  case 4: duplicateDeckSourceWasRunning = deckDRunning.value; break
                }

                // Set pending target so onDeckLoaded knows which deck to finish setting up.
                duplicateDeckPendingTargetId = duplicateDeckTargetId

                // Target deck: keep instrumentals (stems 1-3) playing, mute vocals (stem 4).
                dupStopTargetStem1Muted.value = false
                dupStopTargetStem2Muted.value = false
                dupStopTargetStem3Muted.value = false
                dupStopTargetStem4Muted.value = true
                // Source deck: mute instrumentals (stems 1-3), keep vocals (stem 4) playing.
                sfxStem1Muted.value = true
                sfxStem2Muted.value = true
                sfxStem3Muted.value = true
                sfxStem4Muted.value = false

                // Trigger the duplicate.
                if (decksAssignment == DecksAssignment.AC)
                {
                  if (!padsFocus.value) dupDeck3From1.value = true  // A→C
                  else                  dupDeck1From3.value = true  // C→A
                }
                else
                {
                  if (!padsFocus.value) dupDeck4From2.value = true  // B→D
                  else                  dupDeck2From4.value = true  // D→B
                }
              }
            }
          }
        }
      }

      SwitchTimer { name: "RemixHoldTimer";  setTimeout: 250 }

      //------------------------------------------------------------------------------------------------------------------
      // D2 v0.5.0: STEM FX PADS (Serato-style: pads 5-8 in stemMode — hold to apply, release to revert)
      //
      //  Standard stem layout: Stem 1=Drums  Stem 2=Bass  Stem 3=Melody  Stem 4=Vocals
      //
      //  Pad 5  Drums Delay            — mutes stem 1       + fx_send_on stem 1 only   (Delay+Freeze on FX unit sfxDelayUnit, single mode)
      //  Pad 6  Instrumental Turntable — mutes stems 1+2+3  + fx_send_on stems 1+2+3   (Turntable FX slot 3 on FX unit sfxTurntableUnit, group mode)
      //  Pad 7  Instrumental Delay     — mutes stems 1+2+3  + fx_send_on stems 1+2+3   (Delay+Freeze on FX unit sfxDelayUnit, single mode)
      //  Pad 8  Vocal Delay            — mutes stem 4       + fx_send_on stem 4 only   (Delay+Freeze on FX unit sfxDelayUnit, single mode)
      //
      //  On press (stems not muted): route target stems through the FX unit (fx_send_on + channel assign).
      //              Stems stay audible until release — mute is applied on release, not press.
      //  On press (stems muted):     unmute immediately; no FX.
      //  On release: if FX was applied, mute target stems; tear down FX state.
      //
      //  To move echo to a different FX unit: change sfxDelayUnit. To move braker: change sfxTurntableUnit.
      //------------------------------------------------------------------------------------------------------------------

      WiresGroup
      {
        // Keep enabled while any serato FX pad is held so that pressing shift mid-hold does not
        // disable the WiresGroup before onRelease fires (which would leave FX units in active state).
        enabled: (sfxCaptureFreezeOnlyInStemMode
          ? (padsMode.value == stemMode && (!module.shift || sfxPad5Held || sfxPad6Held || sfxPad7Held || sfxPad8Held))
          : (!module.shift || sfxPad5Held || sfxPad6Held || sfxPad7Held || sfxPad8Held))

        // Pad 5: Drums Delay (Delay+Freeze, single mode, FX unit sfxDelayUnit)
        //   Press (unmuted): Route stem 1 through Delay+Freeze; mute applied on release.
        //   Press (muted):   Unmute stem 1 immediately; no FX.
        //   Release:         If FX was active, mute stem 1 and tear down FX state.
        //   Shift+release:   Tear down FX state without muting stem 1.
        Wire
        {
          from: "%surface%.pads.5"
          to: ButtonScriptAdapter
          {
            brightness: sfxPad5Held ? onBrightness : (sfxStem1Muted.value ? 0.8 : 0.1)
            onPress:
            {
              if (sfxStem1Muted.value)
              {
                sfxStem1Muted.value = false
              }
              else
              {
                sfxPad5Held = true
                sfxDelayStart({ stems: [true, false, false, false], dryWet: 0.3, knob1: 0.7, knob2: 0.0, knob3: 0.6, button1: true, button2: true })
              }
            }
            onRelease:
            {
              if (sfxPad5Held && !module.shift) { sfxStem1Muted.value = true }
              sfxPad5Held = false
              sfxTeardown()
            }
          }
        }

        // Pad 6: Instrumental Turntable FX (group mode slot 3, FX unit sfxTurntableUnit)
        //   Press (not all muted): Route stems 1+2+3 through Turntable FX (BRK); mute applied on release.
        //   Press (all muted):     Unmute stems 1+2+3 immediately; no FX.
        //   Release:               If FX was active, mute stems 1+2+3 and tear down FX state.
        //   Shift+release:         Tear down FX state without muting stems 1+2+3.
        //   knob3 = B.SPD (brake speed) at 0.55 ≈ 2-4 beats; 0.3 = classic 1-2 bar vinyl stop.
        //   Short hold → brief pitch-down + mute on release; long hold → more of the brake cycle heard.
        Wire
        {
          from: "%surface%.pads.6"
          to: ButtonScriptAdapter
          {
            brightness: sfxPad6Held ? onBrightness : ((sfxStem1Muted.value && sfxStem2Muted.value && sfxStem3Muted.value) ? 0.8 : 0.1)
            onPress:
            {
              var allMuted = sfxStem1Muted.value && sfxStem2Muted.value && sfxStem3Muted.value
              if (allMuted)
              {
                sfxStem1Muted.value = false
                sfxStem2Muted.value = false
                sfxStem3Muted.value = false
              }
              else
              {
                sfxPad6Held = true
                sfxTurntableStart({ stems: [true, true, true, false], dryWet: 1.0, knob3: 0.55, button3: true })
              }
            }
            onRelease:
            {
              if (sfxPad6Held && !module.shift) { sfxStem1Muted.value = true; sfxStem2Muted.value = true; sfxStem3Muted.value = true }
              sfxPad6Held = false
              sfxTeardown()
            }
          }
        }

        // Pad 7: Instrumental Delay (Delay+Freeze, single mode, FX unit sfxDelayUnit)
        //   Press (not all muted): Route stems 1+2+3 through Delay+Freeze; mute applied on release.
        //   Press (all muted):     Unmute stems 1+2+3 immediately; no FX.
        //   Release:               If FX was active, mute stems 1+2+3 and tear down FX state.
        //   Shift+release:         Tear down FX state without muting stems 1+2+3.
        Wire
        {
          from: "%surface%.pads.7"
          to: ButtonScriptAdapter
          {
            brightness: sfxPad7Held ? onBrightness : ((sfxStem1Muted.value && sfxStem2Muted.value && sfxStem3Muted.value) ? 0.8 : 0.1)
            onPress:
            {
              var allMuted = sfxStem1Muted.value && sfxStem2Muted.value && sfxStem3Muted.value
              if (allMuted)
              {
                sfxStem1Muted.value = false
                sfxStem2Muted.value = false
                sfxStem3Muted.value = false
              }
              else
              {
                sfxPad7Held = true
                sfxDelayStart({ stems: [true, true, true, false], dryWet: 0.3, knob1: 0.7, knob2: 0.0, knob3: 0.6, button1: true, button2: true })
              }
            }
            onRelease:
            {
              if (sfxPad7Held && !module.shift) { sfxStem1Muted.value = true; sfxStem2Muted.value = true; sfxStem3Muted.value = true }
              sfxPad7Held = false
              sfxTeardown()
            }
          }
        }

        // Pad 8: Vocal Delay (Delay+Freeze, single mode, FX unit sfxDelayUnit)
        //   Press (unmuted): Route stem 4 through Delay+Freeze; mute applied on release.
        //   Press (muted):   Unmute stem 4 immediately; no FX.
        //   Release:         If FX was active, mute stem 4 and tear down FX state.
        //   Shift+release:   Tear down FX state without muting stem 4.
        Wire
        {
          from: "%surface%.pads.8"
          to: ButtonScriptAdapter
          {
            brightness: sfxPad8Held ? onBrightness : (sfxStem4Muted.value ? 0.8 : 0.1)
            onPress:
            {
              if (sfxStem4Muted.value)
              {
                sfxStem4Muted.value = false
              }
              else
              {
                sfxPad8Held = true
                sfxDelayStart({ stems: [false, false, false, true], dryWet: 0.3, knob1: 0.7, knob2: 0.0, knob3: 0.6, button1: true, button2: true })
              }
            }
            onRelease:
            {
              if (sfxPad8Held && !module.shift) { sfxStem4Muted.value = true }
              sfxPad8Held = false
              sfxTeardown()
            }
          }
        }

        // Capture: All-Stems Delay Freeze (toggle — first press locks freeze on all stems, second press releases)
        //   Lights up when frozen. Any stem pad press also cancels the freeze (via sfxTeardown on pad release).
        Wire
        {
          from: "%surface%.capture"
          to: ButtonScriptAdapter
          {
            brightness: sfxCaptureFreezeActive ? onBrightness : dimmedBrightness
            onPress:
            {
              if (sfxCaptureFreezeActive)
              {
                sfxCaptureFreezeActive = false
                sfxTeardown()
              }
              else
              {
                sfxCaptureFreezeActive = true
                sfxDelayStart({ stems: [true, true, true, true], dryWet: 0.3, knob1: 0.7, knob2: 0.0, knob3: 0.6, button1: true, button2: true })
              }
            }
          }
        }
      }

      WiresGroup
      {
        enabled: ((topDeckType == DeckType.Remix) || (bottomDeckType == DeckType.Remix))

        Wire { from: "%surface%.remix.value";  to: "RemixHoldTimer.input"  }
        Wire { from: "RemixHoldTimer.output";  to: DirectPropertyAdapter { path: propertiesPath + ".remix"; output: false } }
      }

      // Remix-mode capture: disabled in stemMode so the stem capture-freeze wire takes priority.
      WiresGroup
      {
        enabled: ((topDeckType == DeckType.Remix) || (bottomDeckType == DeckType.Remix)) && padsMode.value != stemMode

        Wire { from: "%surface%.capture";      to: DirectPropertyAdapter { path: propertiesPath + ".capture" } }
      }

      //------------------------------------------------------------------------------------------------------------------
      //  LOOP ENCODER
      //------------------------------------------------------------------------------------------------------------------

      HoldPropertyAdapter  { name: "ShowSliceOverlay";    path: propertiesPath + ".overlay";  value: Overlay.slice   }

      DirectPropertyAdapter { name: "Top_ShowLoopSize";    path: propertiesPath + ".top.show_loop_size" }
      DirectPropertyAdapter { name: "Bottom_ShowLoopSize"; path: propertiesPath + ".bottom.show_loop_size" }

      Blinker { name: "loop_encoder_blinker_blue";  ledCount: 4; autorun: true; color: Color.Blue  }
      Blinker { name: "loop_encoder_blinker_white"; ledCount: 4; autorun: true; color: Color.White }

      // Deck A
      SwitchTimer { name: "DeckA_ShowLoopSizeTouchTimer"; setTimeout: 50 }

      WiresGroup
      {
        enabled: (encoderFocusedDeckId == 1 )

        // Loop and Freeze modes
        WiresGroup
        {
          enabled: hasLoopMode(deckAType) && !(deckAType == DeckType.Remix && deckASequencerOn.value)

          WiresGroup
          {
            enabled: encoderMode.value == encoderLoopMode

            Wire { from: "%surface%.encoder";       to: "decks.1.loop.autoloop";     enabled: !module.shift }
            Wire { from: "%surface%.encoder";       to: "decks.1.loop.move";         enabled:  module.shift }
            Wire { from: "decks.1.loop.active";     to: "%surface%.encoder.leds";                              }
            Wire { from: "%surface%.encoder.touch"; to: "DeckA_ShowLoopSizeTouchTimer.input"                 }

            Wire
            {
              enabled: !module.shift
              from: Or
              {
                inputs:
                [
                  "DeckA_ShowLoopSizeTouchTimer.output",
                  "%surface%.encoder.is_turned"
                ]
              }
              to: "Top_ShowLoopSize.input"
            }

          }

          WiresGroup
          {
            enabled: encoderMode.value == encoderSlicerMode

            Wire
            {
              from: Or
              {
                inputs:
                [
                  "%surface%.encoder.touch",
                  "%surface%.encoder.is_turned"
                ]
              }
              to: "ShowSliceOverlay"
            }

            Wire { from: "%surface%.encoder.touch"; to: ButtonScriptAdapter  { onPress: { deckAExitFreeze = false; } } }
            Wire { from: "%surface%.encoder.leds";  to: "loop_encoder_blinker_blue" }

            Wire { from: "%surface%.encoder.turn"; to: "decks.1.freeze_slicer.slice_size"; enabled: !deckALoopActive.value }
            Wire { from: "%surface%.encoder.turn"; to: "decks.1.loop.autoloop";          enabled:  deckALoopActive.value }
          }
        }

        WiresGroup
        {
          enabled: (deckAType == DeckType.Remix) && deckASequencerOn.value && (encoderMode.value == encoderLoopMode)
          Wire { from: "%surface%.encoder.turn"; to: "decks.1.remix_sequencer.selected_slot_pattern_length"; enabled: !module.shift }
          Wire { from: "%surface%.encoder.turn"; to: "decks.1.remix_sequencer.all_slots_pattern_length";     enabled:  module.shift }
        }

        // Remix pages scrolling
        WiresGroup
        {
          enabled: (deckAType == DeckType.Remix) && (encoderMode.value == encoderRemixMode) && !deckASequencerOn.value

          Wire { from: "%surface%.encoder";         to: "decks.1.remix.page" }
          Wire { from: "%surface%.encoder";         to: "ShowDisplayButtonArea_EncoderAdapter"; enabled: !deckFocus }
          Wire { from: "loop_encoder_blinker_blue"; to: "%surface%.encoder.leds" }
        }

        // Remix capture source
        WiresGroup
        {
          enabled: encoderMode.value == encoderCaptureMode

          Wire { from: "%surface%.encoder.turn";    to: "decks.1.remix.capture_source" }
          Wire { from: "loop_encoder_blinker_blue"; to: "%surface%.encoder.leds" }
        }
      }

      // Deck C
      SwitchTimer { name: "DeckC_ShowLoopSizeTouchTimer"; setTimeout: 50 }

      WiresGroup
      {
        enabled: (encoderFocusedDeckId == 3)

        // Loop and Freeze modes
        WiresGroup
        {
          enabled: hasLoopMode(deckCType) && !(deckCType == DeckType.Remix && deckCSequencerOn.value)

          WiresGroup
          {
            enabled: encoderMode.value == encoderLoopMode

            Wire { from: "%surface%.encoder";       to: "decks.3.loop.autoloop";     enabled: !module.shift }
            Wire { from: "%surface%.encoder";       to: "decks.3.loop.move";         enabled:  module.shift }
            Wire { from: "decks.3.loop.active";     to: "%surface%.encoder.leds";                              }
            Wire { from: "%surface%.encoder.touch"; to: "DeckC_ShowLoopSizeTouchTimer.input"                 }

            Wire
            {
              enabled: !module.shift
              from: Or
              {
                inputs:
                [
                  "DeckC_ShowLoopSizeTouchTimer.output",
                  "%surface%.encoder.is_turned"
                ]
              }
              to: "Bottom_ShowLoopSize.input"
            }
          }

          WiresGroup
          {
            enabled: encoderMode.value == encoderSlicerMode

            Wire
            {
              from: Or
              {
                inputs:
                [
                  "%surface%.encoder.touch",
                  "%surface%.encoder.is_turned"
                ]
              }
              to: "ShowSliceOverlay"
            }

            Wire { from: "%surface%.encoder.touch"; to: ButtonScriptAdapter  { onPress: { deckCExitFreeze = false; } } }
            Wire { from: "%surface%.encoder.leds";  to: "loop_encoder_blinker_white" }

            Wire { from: "%surface%.encoder.turn"; to: "decks.3.freeze_slicer.slice_size"; enabled: !deckCLoopActive.value }
            Wire { from: "%surface%.encoder.turn"; to: "decks.3.loop.autoloop";          enabled:  deckCLoopActive.value }
          }
        }

        WiresGroup
        {
          enabled: (deckCType == DeckType.Remix) && deckCSequencerOn.value && (encoderMode.value == encoderLoopMode)
          Wire { from: "%surface%.encoder.turn"; to: "decks.3.remix_sequencer.selected_slot_pattern_length"; enabled: !module.shift }
          Wire { from: "%surface%.encoder.turn"; to: "decks.3.remix_sequencer.all_slots_pattern_length";     enabled:  module.shift }
        }

        // Remix pages scrolling
        WiresGroup
        {
          enabled: (deckCType == DeckType.Remix) && (encoderMode.value == encoderRemixMode) && !deckCSequencerOn.value

          Wire { from: "%surface%.encoder";          to: "decks.3.remix.page" }
          Wire { from: "%surface%.encoder";          to: "ShowDisplayButtonArea_EncoderAdapter"; enabled: deckFocus }
          Wire { from: "loop_encoder_blinker_white"; to: "%surface%.encoder.leds" }
        }

        // Remix capture source
        WiresGroup
        {
          enabled:  encoderMode.value == encoderCaptureMode

          Wire { from: "%surface%.encoder.turn";     to: "decks.3.remix.capture_source" }
          Wire { from: "loop_encoder_blinker_white"; to: "%surface%.encoder.leds" }
        }
      }

      // Deck B
      SwitchTimer { name: "DeckB_ShowLoopSizeTouchTimer"; setTimeout: 50 }

      WiresGroup
      {
        enabled: (encoderFocusedDeckId == 2)

        // Loop and Freeze modes
        WiresGroup
        {
          enabled: hasLoopMode(deckBType) && !(deckBType == DeckType.Remix && deckBSequencerOn.value)

          WiresGroup
          {
            enabled: encoderMode.value == encoderLoopMode

            Wire { from: "%surface%.encoder";       to: "decks.2.loop.autoloop";     enabled: !module.shift }
            Wire { from: "%surface%.encoder";       to: "decks.2.loop.move";         enabled:  module.shift }
            Wire { from: "decks.2.loop.active";     to: "%surface%.encoder.leds"                          }
            Wire { from: "%surface%.encoder.touch"; to: "DeckB_ShowLoopSizeTouchTimer.input"              }

            Wire
            {
              enabled: !module.shift
              from: Or
              {
                inputs:
                [
                  "DeckB_ShowLoopSizeTouchTimer.output",
                  "%surface%.encoder.is_turned"
                ]
              }
              to: "Top_ShowLoopSize.input"
            }
          }

          WiresGroup
          {
            enabled: encoderMode.value == encoderSlicerMode

            Wire
            {
              from: Or
              {
                inputs:
                [
                  "%surface%.encoder.touch",
                  "%surface%.encoder.is_turned"
                ]
              }
              to: "ShowSliceOverlay"
            }

            Wire { from: "%surface%.encoder.touch"; to: ButtonScriptAdapter  { onPress: { deckBExitFreeze = false; } } }
            Wire { from: "%surface%.encoder.leds";  to: "loop_encoder_blinker_blue" }

            Wire { from: "%surface%.encoder.turn"; to: "decks.2.freeze_slicer.slice_size"; enabled: !deckBLoopActive.value }
            Wire { from: "%surface%.encoder.turn"; to: "decks.2.loop.autoloop";          enabled:  deckBLoopActive.value }
          }
        }

        WiresGroup
        {
          enabled: (deckBType == DeckType.Remix) && deckBSequencerOn.value && (encoderMode.value == encoderLoopMode)
          Wire { from: "%surface%.encoder.turn"; to: "decks.2.remix_sequencer.selected_slot_pattern_length"; enabled: !module.shift }
          Wire { from: "%surface%.encoder.turn"; to: "decks.2.remix_sequencer.all_slots_pattern_length";     enabled:  module.shift }
        }

        // Remix pages scrolling
        WiresGroup
        {
          enabled: (deckBType == DeckType.Remix) && (encoderMode.value == encoderRemixMode) && !deckBSequencerOn.value

          Wire { from: "%surface%.encoder";         to: "decks.2.remix.page" }
          Wire { from: "%surface%.encoder";         to: "ShowDisplayButtonArea_EncoderAdapter"; enabled: !deckFocus }
          Wire { from: "loop_encoder_blinker_blue"; to: "%surface%.encoder.leds" }
        }

        // Remix capture source
        WiresGroup
        {
          enabled:  encoderMode.value == encoderCaptureMode

          Wire { from: "%surface%.encoder.turn";    to: "decks.2.remix.capture_source" }
          Wire { from: "loop_encoder_blinker_blue"; to: "%surface%.encoder.leds" }
        }
      }

      // Deck D
      SwitchTimer { name: "DeckD_ShowLoopSizeTouchTimer"; setTimeout: 50 }

      WiresGroup
      {
        enabled: (encoderFocusedDeckId == 4)

        // Loop and Freeze modes
        WiresGroup
        {
          enabled: hasLoopMode(deckDType) && !(deckDType == DeckType.Remix && deckDSequencerOn.value)

          WiresGroup
          {
            enabled: encoderMode.value == encoderLoopMode

            Wire { from: "%surface%.encoder";       to: "decks.4.loop.autoloop";     enabled: !module.shift }
            Wire { from: "%surface%.encoder";       to: "decks.4.loop.move";         enabled:  module.shift }
            Wire { from: "decks.4.loop.active";     to: "%surface%.encoder.leds";                              }
            Wire { from: "%surface%.encoder.touch"; to: "DeckD_ShowLoopSizeTouchTimer.input"                 }

            Wire
            {
              enabled: !module.shift
              from: Or
              {
                inputs:
                [
                  "DeckD_ShowLoopSizeTouchTimer.output",
                  "%surface%.encoder.is_turned"
                ]
              }
              to: "Bottom_ShowLoopSize.input"
            }
          }

          WiresGroup
          {
            enabled: encoderMode.value == encoderSlicerMode

            Wire
            {
              from: Or
              {
                inputs:
                [
                  "%surface%.encoder.touch",
                  "%surface%.encoder.is_turned"
                ]
              }
              to: "ShowSliceOverlay"
            }

            Wire { from: "%surface%.encoder.touch"; to: ButtonScriptAdapter  { onPress: { deckDExitFreeze = false; } } }
            Wire { from: "%surface%.encoder.leds";  to: "loop_encoder_blinker_white" }

            Wire { from: "%surface%.encoder.turn"; to: "decks.4.freeze_slicer.slice_size"; enabled: !deckDLoopActive.value }
            Wire { from: "%surface%.encoder.turn"; to: "decks.4.loop.autoloop";          enabled:  deckDLoopActive.value }
          }
        }

        WiresGroup
        {
          enabled: (deckDType == DeckType.Remix) && deckDSequencerOn.value && (encoderMode.value == encoderLoopMode)
          Wire { from: "%surface%.encoder.turn"; to: "decks.4.remix_sequencer.selected_slot_pattern_length"; enabled: !module.shift }
          Wire { from: "%surface%.encoder.turn"; to: "decks.4.remix_sequencer.all_slots_pattern_length";     enabled:  module.shift }
        }

        // Remix pages scrolling
        WiresGroup
        {
          enabled:  (deckDType == DeckType.Remix) && (encoderMode.value == encoderRemixMode) && !deckDSequencerOn.value

          Wire { from: "%surface%.encoder";          to: "decks.4.remix.page" }
          Wire { from: "%surface%.encoder";          to: "ShowDisplayButtonArea_EncoderAdapter"; enabled: deckFocus }
          Wire { from: "loop_encoder_blinker_white"; to: "%surface%.encoder.leds" }
        }

        // Remix capture source
        WiresGroup
        {
          enabled: encoderMode.value == encoderCaptureMode

          Wire { from: "%surface%.encoder.turn";     to: "decks.4.remix.capture_source" }
          Wire { from: "loop_encoder_blinker_white"; to: "%surface%.encoder.leds" }
        }
      }

      //------------------------------------------------------------------------------------------------------------------
      //  BEATGRID EDIT
      //------------------------------------------------------------------------------------------------------------------

      MappingPropertyDescriptor { path: propertiesPath + ".beatgrid.scan_control";      type: MappingPropertyDescriptor.Float;   value: 0.0   }
      MappingPropertyDescriptor { path: propertiesPath + ".beatgrid.scan_beats_offset"; type: MappingPropertyDescriptor.Integer; value: 0     }
      MappingPropertyDescriptor { id: zoomedEditView; path: propertiesPath + ".beatgrid.zoomed_view";       type: MappingPropertyDescriptor.Boolean; value: false }

      Beatgrid { name: "DeckA_Beatgrid"; channel: 1 }
      Beatgrid { name: "DeckB_Beatgrid"; channel: 2 }
      Beatgrid { name: "DeckC_Beatgrid"; channel: 3 }
      Beatgrid { name: "DeckD_Beatgrid"; channel: 4 }

      WiresGroup
      {
        enabled: isInEditMode && hasEditMode(focusedDeckType)

        Wire { from: "%surface%.knobs.4"; to: DirectPropertyAdapter { path: propertiesPath + ".beatgrid.scan_control" } }
        Wire { from: "%surface%.buttons.1"; to: TogglePropertyAdapter { path: propertiesPath + ".beatgrid.zoomed_view" }  }
      }

      // Deck A
      WiresGroup
      {
        enabled: (focusedDeckId == 1) && isInEditMode && hasEditMode(deckAType)

        WiresGroup
        {
          enabled: !zoomedEditView.value

          Wire { from: "%surface%.knobs.1"; to: "DeckA_Beatgrid.offset_fine";   enabled: !module.shift }
          Wire { from: "%surface%.knobs.1"; to: "DeckA_Beatgrid.offset_coarse"; enabled:  module.shift }
        }

        WiresGroup
        {
          enabled: zoomedEditView.value

          Wire { from: "%surface%.knobs.1"; to: "DeckA_Beatgrid.offset_ultrafine";   enabled: !module.shift }
          Wire { from: "%surface%.knobs.1"; to: "DeckA_Beatgrid.offset_fine";        enabled:  module.shift }
        }

        Wire { from: "%surface%.knobs.2"; to: "DeckA_Beatgrid.bpm_coarse"    }
        Wire { from: "%surface%.knobs.3"; to: "DeckA_Beatgrid.bpm_fine"      }

        Wire { from: "%surface%.display.buttons.2"; to: "DeckA_Beatgrid.lock"  }
        Wire { from: "%surface%.display.buttons.3"; to: "DeckA_Beatgrid.tick"  }
        Wire { from: "%surface%.display.buttons.6"; to: "DeckA_Beatgrid.tap"   }
        Wire { from: "%surface%.display.buttons.7"; to: "DeckA_Beatgrid.reset" }

        Wire{ from: DirectPropertyAdapter{path: propertiesPath + ".beatgrid.scan_beats_offset"; input:false} to: "DeckA_Beatgrid.beats_offset"}
      }

      // Deck B
      WiresGroup
      {
        enabled: (focusedDeckId == 2) && isInEditMode && hasEditMode(deckBType)

        WiresGroup
        {
          enabled: !zoomedEditView.value

          Wire { from: "%surface%.knobs.1"; to: "DeckB_Beatgrid.offset_fine";   enabled: !module.shift }
          Wire { from: "%surface%.knobs.1"; to: "DeckB_Beatgrid.offset_coarse"; enabled:  module.shift }
        }

        WiresGroup
        {
          enabled: zoomedEditView.value

          Wire { from: "%surface%.knobs.1"; to: "DeckB_Beatgrid.offset_ultrafine";   enabled: !module.shift }
          Wire { from: "%surface%.knobs.1"; to: "DeckB_Beatgrid.offset_fine";        enabled:  module.shift }
        }

        Wire { from: "%surface%.knobs.2"; to: "DeckB_Beatgrid.bpm_coarse"    }
        Wire { from: "%surface%.knobs.3"; to: "DeckB_Beatgrid.bpm_fine"      }

        Wire { from: "%surface%.display.buttons.2"; to: "DeckB_Beatgrid.lock"  }
        Wire { from: "%surface%.display.buttons.3"; to: "DeckB_Beatgrid.tick"  }
        Wire { from: "%surface%.display.buttons.6"; to: "DeckB_Beatgrid.tap"   }
        Wire { from: "%surface%.display.buttons.7"; to: "DeckB_Beatgrid.reset" }

        Wire{ from: DirectPropertyAdapter{path: propertiesPath + ".beatgrid.scan_beats_offset"; input:false} to: "DeckB_Beatgrid.beats_offset"}
      }

      // Deck C
      WiresGroup
      {
        enabled: (focusedDeckId == 3) && isInEditMode && hasEditMode(deckCType)

        WiresGroup
        {
          enabled: !zoomedEditView.value

          Wire { from: "%surface%.knobs.1"; to: "DeckC_Beatgrid.offset_fine";   enabled: !module.shift }
          Wire { from: "%surface%.knobs.1"; to: "DeckC_Beatgrid.offset_coarse"; enabled:  module.shift }
        }

        WiresGroup
        {
          enabled: zoomedEditView.value

          Wire { from: "%surface%.knobs.1"; to: "DeckC_Beatgrid.offset_ultrafine";   enabled: !module.shift }
          Wire { from: "%surface%.knobs.1"; to: "DeckC_Beatgrid.offset_fine";        enabled:  module.shift }
        }

        Wire { from: "%surface%.knobs.2"; to: "DeckC_Beatgrid.bpm_coarse"    }
        Wire { from: "%surface%.knobs.3"; to: "DeckC_Beatgrid.bpm_fine"      }

        Wire { from: "%surface%.display.buttons.2"; to: "DeckC_Beatgrid.lock"  }
        Wire { from: "%surface%.display.buttons.3"; to: "DeckC_Beatgrid.tick"  }
        Wire { from: "%surface%.display.buttons.6"; to: "DeckC_Beatgrid.tap"   }
        Wire { from: "%surface%.display.buttons.7"; to: "DeckC_Beatgrid.reset" }

        Wire{ from: DirectPropertyAdapter{path: propertiesPath + ".beatgrid.scan_beats_offset"; input:false} to: "DeckC_Beatgrid.beats_offset"}
      }

      // Deck D
      WiresGroup
      {
        enabled: (focusedDeckId == 4) && isInEditMode && hasEditMode(deckDType)

        WiresGroup
        {
          enabled: !zoomedEditView.value

          Wire { from: "%surface%.knobs.1"; to: "DeckD_Beatgrid.offset_fine";   enabled: !module.shift }
          Wire { from: "%surface%.knobs.1"; to: "DeckD_Beatgrid.offset_coarse"; enabled:  module.shift }
        }

        WiresGroup
        {
          enabled: zoomedEditView.value

          Wire { from: "%surface%.knobs.1"; to: "DeckD_Beatgrid.offset_ultrafine";   enabled: !module.shift }
          Wire { from: "%surface%.knobs.1"; to: "DeckD_Beatgrid.offset_fine";        enabled:  module.shift }
        }

        Wire { from: "%surface%.knobs.2"; to: "DeckD_Beatgrid.bpm_coarse"    }
        Wire { from: "%surface%.knobs.3"; to: "DeckD_Beatgrid.bpm_fine"      }

        Wire { from: "%surface%.display.buttons.2"; to: "DeckD_Beatgrid.lock"  }
        Wire { from: "%surface%.display.buttons.3"; to: "DeckD_Beatgrid.tick"  }
        Wire { from: "%surface%.display.buttons.6"; to: "DeckD_Beatgrid.tap"   }
        Wire { from: "%surface%.display.buttons.7"; to: "DeckD_Beatgrid.reset" }

        Wire{ from: DirectPropertyAdapter{path: propertiesPath + ".beatgrid.scan_beats_offset"; input:false} to: "DeckD_Beatgrid.beats_offset"}
      }

      //------------------------------------------------------------------------------------------------------------------
      //  PERFORMANCE CONTROLS
      //------------------------------------------------------------------------------------------------------------------

      // Stem Deck A
      WiresGroup
      {
        enabled: (footerFocusedDeckId == 1) && (deckAType == DeckType.Stem)

        Wire { from: "softtakeover_faders1.module.output";       to: "decks.1.stems.1.volume" }
        Wire { from: "softtakeover_faders2.module.output";       to: "decks.1.stems.2.volume" }
        Wire { from: "softtakeover_faders3.module.output";       to: "decks.1.stems.3.volume" }
        Wire { from: "softtakeover_faders4.module.output";       to: "decks.1.stems.4.volume" }

        WiresGroup
        {
          enabled: !isInEditMode && module.screenView.value == ScreenView.deck

          WiresGroup
          {
            enabled: footerPage.value == FooterPage.fxSend

            Wire { from: "%surface%.knobs.1"; to: "decks.1.stems.1.fx_send"    }
            Wire { from: "%surface%.knobs.2"; to: "decks.1.stems.2.fx_send"    }
            Wire { from: "%surface%.knobs.3"; to: "decks.1.stems.3.fx_send"    }
            Wire { from: "%surface%.knobs.4"; to: "decks.1.stems.4.fx_send"    }

            Wire { from: "%surface%.buttons.1"; to: "decks.1.stems.1.fx_send_on"     }
            Wire { from: "%surface%.buttons.2"; to: "decks.1.stems.2.fx_send_on"     }
            Wire { from: "%surface%.buttons.3"; to: "decks.1.stems.3.fx_send_on"     }
            Wire { from: "%surface%.buttons.4"; to: "decks.1.stems.4.fx_send_on"     }
          }

          WiresGroup
          {
            enabled: footerPage.value == FooterPage.filter

            Wire { from: "%surface%.knobs.1"; to: "decks.1.stems.1.filter"    }
            Wire { from: "%surface%.knobs.2"; to: "decks.1.stems.2.filter"    }
            Wire { from: "%surface%.knobs.3"; to: "decks.1.stems.3.filter"    }
            Wire { from: "%surface%.knobs.4"; to: "decks.1.stems.4.filter"    }

            Wire { from: "%surface%.buttons.1"; to: "decks.1.stems.1.filter_on"     }
            Wire { from: "%surface%.buttons.2"; to: "decks.1.stems.2.filter_on"     }
            Wire { from: "%surface%.buttons.3"; to: "decks.1.stems.3.filter_on"     }
            Wire { from: "%surface%.buttons.4"; to: "decks.1.stems.4.filter_on"     }
          }
        }
      }

      // Stem Deck B
      WiresGroup
      {
        enabled: (footerFocusedDeckId == 2) && (deckBType == DeckType.Stem)

        Wire { from: "softtakeover_faders1.module.output"; to: "decks.2.stems.1.volume" }
        Wire { from: "softtakeover_faders2.module.output"; to: "decks.2.stems.2.volume" }
        Wire { from: "softtakeover_faders3.module.output"; to: "decks.2.stems.3.volume" }
        Wire { from: "softtakeover_faders4.module.output"; to: "decks.2.stems.4.volume" }

        WiresGroup
        {
          enabled: !isInEditMode && module.screenView.value == ScreenView.deck

          WiresGroup
          {
            enabled: footerPage.value == FooterPage.fxSend

            Wire { from: "%surface%.knobs.1"; to: "decks.2.stems.1.fx_send"    }
            Wire { from: "%surface%.knobs.2"; to: "decks.2.stems.2.fx_send"    }
            Wire { from: "%surface%.knobs.3"; to: "decks.2.stems.3.fx_send"    }
            Wire { from: "%surface%.knobs.4"; to: "decks.2.stems.4.fx_send"    }

            Wire { from: "%surface%.buttons.1"; to: "decks.2.stems.1.fx_send_on"     }
            Wire { from: "%surface%.buttons.2"; to: "decks.2.stems.2.fx_send_on"     }
            Wire { from: "%surface%.buttons.3"; to: "decks.2.stems.3.fx_send_on"     }
            Wire { from: "%surface%.buttons.4"; to: "decks.2.stems.4.fx_send_on"     }
          }

          WiresGroup
          {
            enabled: footerPage.value == FooterPage.filter

            Wire { from: "%surface%.knobs.1"; to: "decks.2.stems.1.filter"    }
            Wire { from: "%surface%.knobs.2"; to: "decks.2.stems.2.filter"    }
            Wire { from: "%surface%.knobs.3"; to: "decks.2.stems.3.filter"    }
            Wire { from: "%surface%.knobs.4"; to: "decks.2.stems.4.filter"    }

            Wire { from: "%surface%.buttons.1"; to: "decks.2.stems.1.filter_on"     }
            Wire { from: "%surface%.buttons.2"; to: "decks.2.stems.2.filter_on"     }
            Wire { from: "%surface%.buttons.3"; to: "decks.2.stems.3.filter_on"     }
            Wire { from: "%surface%.buttons.4"; to: "decks.2.stems.4.filter_on"     }
          }
        }
      }

      // Stem Deck C
      WiresGroup
      {
        enabled: (footerFocusedDeckId == 3) && (deckCType == DeckType.Stem)

        Wire { from: "softtakeover_faders1.module.output"; to: "decks.3.stems.1.volume" }
        Wire { from: "softtakeover_faders2.module.output"; to: "decks.3.stems.2.volume" }
        Wire { from: "softtakeover_faders3.module.output"; to: "decks.3.stems.3.volume" }
        Wire { from: "softtakeover_faders4.module.output"; to: "decks.3.stems.4.volume" }

        WiresGroup
        {
          enabled: !isInEditMode && module.screenView.value == ScreenView.deck

          WiresGroup
          {
            enabled: footerPage.value == FooterPage.fxSend

            Wire { from: "%surface%.knobs.1"; to: "decks.3.stems.1.fx_send"    }
            Wire { from: "%surface%.knobs.2"; to: "decks.3.stems.2.fx_send"    }
            Wire { from: "%surface%.knobs.3"; to: "decks.3.stems.3.fx_send"    }
            Wire { from: "%surface%.knobs.4"; to: "decks.3.stems.4.fx_send"    }

            Wire { from: "%surface%.buttons.1"; to: "decks.3.stems.1.fx_send_on"     }
            Wire { from: "%surface%.buttons.2"; to: "decks.3.stems.2.fx_send_on"     }
            Wire { from: "%surface%.buttons.3"; to: "decks.3.stems.3.fx_send_on"     }
            Wire { from: "%surface%.buttons.4"; to: "decks.3.stems.4.fx_send_on"     }
          }

          WiresGroup
          {
            enabled: footerPage.value == FooterPage.filter

            Wire { from: "%surface%.knobs.1"; to: "decks.3.stems.1.filter"    }
            Wire { from: "%surface%.knobs.2"; to: "decks.3.stems.2.filter"    }
            Wire { from: "%surface%.knobs.3"; to: "decks.3.stems.3.filter"    }
            Wire { from: "%surface%.knobs.4"; to: "decks.3.stems.4.filter"    }

            Wire { from: "%surface%.buttons.1"; to: "decks.3.stems.1.filter_on"     }
            Wire { from: "%surface%.buttons.2"; to: "decks.3.stems.2.filter_on"     }
            Wire { from: "%surface%.buttons.3"; to: "decks.3.stems.3.filter_on"     }
            Wire { from: "%surface%.buttons.4"; to: "decks.3.stems.4.filter_on"     }
          }
        }
      }

      // Stem Deck D
      WiresGroup
      {
        enabled: (footerFocusedDeckId == 4) && (deckDType == DeckType.Stem)

        Wire { from: "softtakeover_faders1.module.output"; to: "decks.4.stems.1.volume" }
        Wire { from: "softtakeover_faders2.module.output"; to: "decks.4.stems.2.volume" }
        Wire { from: "softtakeover_faders3.module.output"; to: "decks.4.stems.3.volume" }
        Wire { from: "softtakeover_faders4.module.output"; to: "decks.4.stems.4.volume" }

        WiresGroup
        {
          enabled: !isInEditMode && module.screenView.value == ScreenView.deck

          WiresGroup
          {
            enabled: footerPage.value == FooterPage.fxSend

            Wire { from: "%surface%.knobs.1"; to: "decks.4.stems.1.fx_send"    }
            Wire { from: "%surface%.knobs.2"; to: "decks.4.stems.2.fx_send"    }
            Wire { from: "%surface%.knobs.3"; to: "decks.4.stems.3.fx_send"    }
            Wire { from: "%surface%.knobs.4"; to: "decks.4.stems.4.fx_send"    }

            Wire { from: "%surface%.buttons.1"; to: "decks.4.stems.1.fx_send_on"     }
            Wire { from: "%surface%.buttons.2"; to: "decks.4.stems.2.fx_send_on"     }
            Wire { from: "%surface%.buttons.3"; to: "decks.4.stems.3.fx_send_on"     }
            Wire { from: "%surface%.buttons.4"; to: "decks.4.stems.4.fx_send_on"     }
          }

          WiresGroup
          {
            enabled: footerPage.value == FooterPage.filter

            Wire { from: "%surface%.knobs.1"; to: "decks.4.stems.1.filter"    }
            Wire { from: "%surface%.knobs.2"; to: "decks.4.stems.2.filter"    }
            Wire { from: "%surface%.knobs.3"; to: "decks.4.stems.3.filter"    }
            Wire { from: "%surface%.knobs.4"; to: "decks.4.stems.4.filter"    }

            Wire { from: "%surface%.buttons.1"; to: "decks.4.stems.1.filter_on"     }
            Wire { from: "%surface%.buttons.2"; to: "decks.4.stems.2.filter_on"     }
            Wire { from: "%surface%.buttons.3"; to: "decks.4.stems.3.filter_on"     }
            Wire { from: "%surface%.buttons.4"; to: "decks.4.stems.4.filter_on"     }
          }
         }
      }

      // Remix Deck A
      WiresGroup
      {
        enabled: (footerFocusedDeckId == 1) && (deckAType == DeckType.Remix)

        Wire { from: "%surface%.shift";              to: "decks.1.remix_slots.1.compensate_gain" }
        Wire { from: "%surface%.shift";              to: "decks.1.remix_slots.2.compensate_gain" }
        Wire { from: "%surface%.shift";              to: "decks.1.remix_slots.3.compensate_gain" }
        Wire { from: "%surface%.shift";              to: "decks.1.remix_slots.4.compensate_gain" }
        Wire { from: "softtakeover_faders1.module.output"; to: "decks.1.remix_slots.1.volume" }
        Wire { from: "softtakeover_faders2.module.output"; to: "decks.1.remix_slots.2.volume" }
        Wire { from: "softtakeover_faders3.module.output"; to: "decks.1.remix_slots.3.volume" }
        Wire { from: "softtakeover_faders4.module.output"; to: "decks.1.remix_slots.4.volume" }

        WiresGroup
        {
          enabled: !isInEditMode && module.screenView.value == ScreenView.deck

          WiresGroup
          {
            enabled: footerPage.value == FooterPage.fxSend

            Wire { from: "%surface%.knobs.1"; to: "decks.1.remix_slots.1.fx_send"    }
            Wire { from: "%surface%.knobs.2"; to: "decks.1.remix_slots.2.fx_send"    }
            Wire { from: "%surface%.knobs.3"; to: "decks.1.remix_slots.3.fx_send"    }
            Wire { from: "%surface%.knobs.4"; to: "decks.1.remix_slots.4.fx_send"    }

            Wire { from: "%surface%.buttons.1"; to: "decks.1.remix_slots.1.fx_send_on"     }
            Wire { from: "%surface%.buttons.2"; to: "decks.1.remix_slots.2.fx_send_on"     }
            Wire { from: "%surface%.buttons.3"; to: "decks.1.remix_slots.3.fx_send_on"     }
            Wire { from: "%surface%.buttons.4"; to: "decks.1.remix_slots.4.fx_send_on"     }
          }

          WiresGroup
          {
            enabled: footerPage.value == FooterPage.filter

            Wire { from: "%surface%.knobs.1"; to: "decks.1.remix_slots.1.filter"    }
            Wire { from: "%surface%.knobs.2"; to: "decks.1.remix_slots.2.filter"    }
            Wire { from: "%surface%.knobs.3"; to: "decks.1.remix_slots.3.filter"    }
            Wire { from: "%surface%.knobs.4"; to: "decks.1.remix_slots.4.filter"    }

            Wire { from: "%surface%.buttons.1"; to: "decks.1.remix_slots.1.filter_on"     }
            Wire { from: "%surface%.buttons.2"; to: "decks.1.remix_slots.2.filter_on"     }
            Wire { from: "%surface%.buttons.3"; to: "decks.1.remix_slots.3.filter_on"     }
            Wire { from: "%surface%.buttons.4"; to: "decks.1.remix_slots.4.filter_on"     }
          }

          WiresGroup
          {
            enabled: footerPage.value == FooterPage.pitch

            Wire { from: "%surface%.knobs.1"; to: "decks.1.remix_slots.1.pitch"     }
            Wire { from: "%surface%.knobs.2"; to: "decks.1.remix_slots.2.pitch"     }
            Wire { from: "%surface%.knobs.3"; to: "decks.1.remix_slots.3.pitch"     }
            Wire { from: "%surface%.knobs.4"; to: "decks.1.remix_slots.4.pitch"     }

            Wire { from: "%surface%.buttons.1"; to: "decks.1.remix_slots.1.key_lock"      }
            Wire { from: "%surface%.buttons.2"; to: "decks.1.remix_slots.2.key_lock"      }
            Wire { from: "%surface%.buttons.3"; to: "decks.1.remix_slots.3.key_lock"      }
            Wire { from: "%surface%.buttons.4"; to: "decks.1.remix_slots.4.key_lock"      }
          }

          WiresGroup
          {
            enabled: footerPage.value == FooterPage.slot1

            Wire { from: "%surface%.knobs.1"; to: RelativePropertyAdapter{ path: "app.traktor.decks.1.remix.players.1.sequencer.selected_cell"; scaleFactor: 0.6 } enabled: !sequencerSampleLock.value }
            Wire { from: "%surface%.knobs.2"; to: "decks.1.remix_slots.1.filter"    }
            Wire { from: "%surface%.knobs.3"; to: "decks.1.remix_slots.1.pitch"     }
            Wire { from: "%surface%.knobs.4"; to: "decks.1.remix_slots.1.fx_send"   }

            Wire { from: "%surface%.buttons.1"; to: TogglePropertyAdapter { path: propertiesPath + ".sequencer_sample_lock" } }
            Wire { from: "%surface%.buttons.2"; to: "decks.1.remix_slots.1.filter_on"     }
            Wire { from: "%surface%.buttons.3"; to: "decks.1.remix_slots.1.key_lock"      }
            Wire { from: "%surface%.buttons.4"; to: "decks.1.remix_slots.1.fx_send_on"    }
          }

          WiresGroup
          {
            enabled: footerPage.value == FooterPage.slot2

            Wire { from: "%surface%.knobs.1"; to: RelativePropertyAdapter{ path: "app.traktor.decks.1.remix.players.2.sequencer.selected_cell"; scaleFactor: 0.6 } enabled: !sequencerSampleLock.value }
            Wire { from: "%surface%.knobs.2"; to: "decks.1.remix_slots.2.filter"    }
            Wire { from: "%surface%.knobs.3"; to: "decks.1.remix_slots.2.pitch"     }
            Wire { from: "%surface%.knobs.4"; to: "decks.1.remix_slots.2.fx_send"   }

            Wire { from: "%surface%.buttons.1"; to: TogglePropertyAdapter { path: propertiesPath + ".sequencer_sample_lock" } }
            Wire { from: "%surface%.buttons.2"; to: "decks.1.remix_slots.2.filter_on"     }
            Wire { from: "%surface%.buttons.3"; to: "decks.1.remix_slots.2.key_lock"      }
            Wire { from: "%surface%.buttons.4"; to: "decks.1.remix_slots.2.fx_send_on"    }
          }

          WiresGroup
          {
            enabled: footerPage.value == FooterPage.slot3

            Wire { from: "%surface%.knobs.1"; to: RelativePropertyAdapter{ path: "app.traktor.decks.1.remix.players.3.sequencer.selected_cell"; scaleFactor: 0.6 } enabled: !sequencerSampleLock.value }
            Wire { from: "%surface%.knobs.2"; to: "decks.1.remix_slots.3.filter"    }
            Wire { from: "%surface%.knobs.3"; to: "decks.1.remix_slots.3.pitch"     }
            Wire { from: "%surface%.knobs.4"; to: "decks.1.remix_slots.3.fx_send"   }

            Wire { from: "%surface%.buttons.1"; to: TogglePropertyAdapter { path: propertiesPath + ".sequencer_sample_lock" } }
            Wire { from: "%surface%.buttons.2"; to: "decks.1.remix_slots.3.filter_on"     }
            Wire { from: "%surface%.buttons.3"; to: "decks.1.remix_slots.3.key_lock"      }
            Wire { from: "%surface%.buttons.4"; to: "decks.1.remix_slots.3.fx_send_on"    }
          }

          WiresGroup
          {
            enabled: footerPage.value == FooterPage.slot4

            Wire { from: "%surface%.knobs.1"; to: RelativePropertyAdapter{ path: "app.traktor.decks.1.remix.players.4.sequencer.selected_cell"; scaleFactor: 0.6 } enabled: !sequencerSampleLock.value }
            Wire { from: "%surface%.knobs.2"; to: "decks.1.remix_slots.4.filter"    }
            Wire { from: "%surface%.knobs.3"; to: "decks.1.remix_slots.4.pitch"     }
            Wire { from: "%surface%.knobs.4"; to: "decks.1.remix_slots.4.fx_send"   }

            Wire { from: "%surface%.buttons.1"; to: TogglePropertyAdapter { path: propertiesPath + ".sequencer_sample_lock" } }
            Wire { from: "%surface%.buttons.2"; to: "decks.1.remix_slots.4.filter_on"     }
            Wire { from: "%surface%.buttons.3"; to: "decks.1.remix_slots.4.key_lock"      }
            Wire { from: "%surface%.buttons.4"; to: "decks.1.remix_slots.4.fx_send_on"    }
          }
        }
      }

      // Remix Deck B
      WiresGroup
      {
        enabled: (footerFocusedDeckId == 2) && (deckBType == DeckType.Remix)
                 
        Wire { from: "%surface%.shift";              to: "decks.2.remix_slots.1.compensate_gain" }
        Wire { from: "%surface%.shift";              to: "decks.2.remix_slots.2.compensate_gain" }
        Wire { from: "%surface%.shift";              to: "decks.2.remix_slots.3.compensate_gain" }
        Wire { from: "%surface%.shift";              to: "decks.2.remix_slots.4.compensate_gain" }
        Wire { from: "softtakeover_faders1.module.output"; to: "decks.2.remix_slots.1.volume" }
        Wire { from: "softtakeover_faders2.module.output"; to: "decks.2.remix_slots.2.volume" }
        Wire { from: "softtakeover_faders3.module.output"; to: "decks.2.remix_slots.3.volume" }
        Wire { from: "softtakeover_faders4.module.output"; to: "decks.2.remix_slots.4.volume" }

        WiresGroup
        {
          enabled: !isInEditMode && module.screenView.value == ScreenView.deck

          WiresGroup
          {
            enabled: footerPage.value == FooterPage.fxSend

            Wire { from: "%surface%.knobs.1"; to: "decks.2.remix_slots.1.fx_send"    }
            Wire { from: "%surface%.knobs.2"; to: "decks.2.remix_slots.2.fx_send"    }
            Wire { from: "%surface%.knobs.3"; to: "decks.2.remix_slots.3.fx_send"    }
            Wire { from: "%surface%.knobs.4"; to: "decks.2.remix_slots.4.fx_send"    }

            Wire { from: "%surface%.buttons.1"; to: "decks.2.remix_slots.1.fx_send_on"     }
            Wire { from: "%surface%.buttons.2"; to: "decks.2.remix_slots.2.fx_send_on"     }
            Wire { from: "%surface%.buttons.3"; to: "decks.2.remix_slots.3.fx_send_on"     }
            Wire { from: "%surface%.buttons.4"; to: "decks.2.remix_slots.4.fx_send_on"     }
          }

          WiresGroup
          {
            enabled: footerPage.value == FooterPage.filter

            Wire { from: "%surface%.knobs.1"; to: "decks.2.remix_slots.1.filter"    }
            Wire { from: "%surface%.knobs.2"; to: "decks.2.remix_slots.2.filter"    }
            Wire { from: "%surface%.knobs.3"; to: "decks.2.remix_slots.3.filter"    }
            Wire { from: "%surface%.knobs.4"; to: "decks.2.remix_slots.4.filter"    }

            Wire { from: "%surface%.buttons.1"; to: "decks.2.remix_slots.1.filter_on"     }
            Wire { from: "%surface%.buttons.2"; to: "decks.2.remix_slots.2.filter_on"     }
            Wire { from: "%surface%.buttons.3"; to: "decks.2.remix_slots.3.filter_on"     }
            Wire { from: "%surface%.buttons.4"; to: "decks.2.remix_slots.4.filter_on"     }
          }

          WiresGroup
          {
            enabled: footerPage.value == FooterPage.pitch

            Wire { from: "%surface%.knobs.1"; to: "decks.2.remix_slots.1.pitch"     }
            Wire { from: "%surface%.knobs.2"; to: "decks.2.remix_slots.2.pitch"     }
            Wire { from: "%surface%.knobs.3"; to: "decks.2.remix_slots.3.pitch"     }
            Wire { from: "%surface%.knobs.4"; to: "decks.2.remix_slots.4.pitch"     }

            Wire { from: "%surface%.buttons.1"; to: "decks.2.remix_slots.1.key_lock"      }
            Wire { from: "%surface%.buttons.2"; to: "decks.2.remix_slots.2.key_lock"      }
            Wire { from: "%surface%.buttons.3"; to: "decks.2.remix_slots.3.key_lock"      }
            Wire { from: "%surface%.buttons.4"; to: "decks.2.remix_slots.4.key_lock"      }
          }

          WiresGroup
          {
            enabled: footerPage.value == FooterPage.slot1

            Wire { from: "%surface%.knobs.1"; to: RelativePropertyAdapter{ path: "app.traktor.decks.2.remix.players.1.sequencer.selected_cell"; scaleFactor: 0.6 } enabled: !sequencerSampleLock.value }
            Wire { from: "%surface%.knobs.2"; to: "decks.2.remix_slots.1.filter"    }
            Wire { from: "%surface%.knobs.3"; to: "decks.2.remix_slots.1.pitch"     }
            Wire { from: "%surface%.knobs.4"; to: "decks.2.remix_slots.1.fx_send"   }

            Wire { from: "%surface%.buttons.1"; to: TogglePropertyAdapter { path: propertiesPath + ".sequencer_sample_lock" } }
            Wire { from: "%surface%.buttons.2"; to: "decks.2.remix_slots.1.filter_on"     }
            Wire { from: "%surface%.buttons.3"; to: "decks.2.remix_slots.1.key_lock"      }
            Wire { from: "%surface%.buttons.4"; to: "decks.2.remix_slots.1.fx_send_on"    }
          }

          WiresGroup
          {
            enabled: footerPage.value == FooterPage.slot2

            Wire { from: "%surface%.knobs.1"; to: RelativePropertyAdapter{ path: "app.traktor.decks.2.remix.players.2.sequencer.selected_cell"; scaleFactor: 0.6 } enabled: !sequencerSampleLock.value }
            Wire { from: "%surface%.knobs.2"; to: "decks.2.remix_slots.2.filter"    }
            Wire { from: "%surface%.knobs.3"; to: "decks.2.remix_slots.2.pitch"     }
            Wire { from: "%surface%.knobs.4"; to: "decks.2.remix_slots.2.fx_send"   }

            Wire { from: "%surface%.buttons.1"; to: TogglePropertyAdapter { path: propertiesPath + ".sequencer_sample_lock" } }
            Wire { from: "%surface%.buttons.2"; to: "decks.2.remix_slots.2.filter_on"     }
            Wire { from: "%surface%.buttons.3"; to: "decks.2.remix_slots.2.key_lock"      }
            Wire { from: "%surface%.buttons.4"; to: "decks.2.remix_slots.2.fx_send_on"    }
          }

          WiresGroup
          {
            enabled: footerPage.value == FooterPage.slot3

            Wire { from: "%surface%.knobs.1"; to: RelativePropertyAdapter{ path: "app.traktor.decks.2.remix.players.3.sequencer.selected_cell"; scaleFactor: 0.6 } enabled: !sequencerSampleLock.value }
            Wire { from: "%surface%.knobs.2"; to: "decks.2.remix_slots.3.filter"    }
            Wire { from: "%surface%.knobs.3"; to: "decks.2.remix_slots.3.pitch"     }
            Wire { from: "%surface%.knobs.4"; to: "decks.2.remix_slots.3.fx_send"   }

            Wire { from: "%surface%.buttons.1"; to: TogglePropertyAdapter { path: propertiesPath + ".sequencer_sample_lock" } }
            Wire { from: "%surface%.buttons.2"; to: "decks.2.remix_slots.3.filter_on"     }
            Wire { from: "%surface%.buttons.3"; to: "decks.2.remix_slots.3.key_lock"      }
            Wire { from: "%surface%.buttons.4"; to: "decks.2.remix_slots.3.fx_send_on"    }
          }

          WiresGroup
          {
            enabled: footerPage.value == FooterPage.slot4

            Wire { from: "%surface%.knobs.1"; to: RelativePropertyAdapter{ path: "app.traktor.decks.2.remix.players.4.sequencer.selected_cell"; scaleFactor: 0.6 } enabled: !sequencerSampleLock.value }
            Wire { from: "%surface%.knobs.2"; to: "decks.2.remix_slots.4.filter"    }
            Wire { from: "%surface%.knobs.3"; to: "decks.2.remix_slots.4.pitch"     }
            Wire { from: "%surface%.knobs.4"; to: "decks.2.remix_slots.4.fx_send"   }

            Wire { from: "%surface%.buttons.1"; to: TogglePropertyAdapter { path: propertiesPath + ".sequencer_sample_lock" } }
            Wire { from: "%surface%.buttons.2"; to: "decks.2.remix_slots.4.filter_on"     }
            Wire { from: "%surface%.buttons.3"; to: "decks.2.remix_slots.4.key_lock"      }
            Wire { from: "%surface%.buttons.4"; to: "decks.2.remix_slots.4.fx_send_on"    }
          }
        }
      }

      // Remix Deck C
      WiresGroup
      {
        enabled: (footerFocusedDeckId == 3) && (deckCType == DeckType.Remix)

        Wire { from: "%surface%.shift";              to: "decks.3.remix_slots.1.compensate_gain" }
        Wire { from: "%surface%.shift";              to: "decks.3.remix_slots.2.compensate_gain" }
        Wire { from: "%surface%.shift";              to: "decks.3.remix_slots.3.compensate_gain" }
        Wire { from: "%surface%.shift";              to: "decks.3.remix_slots.4.compensate_gain" }
        Wire { from: "softtakeover_faders1.module.output"; to: "decks.3.remix_slots.1.volume" }
        Wire { from: "softtakeover_faders2.module.output"; to: "decks.3.remix_slots.2.volume" }
        Wire { from: "softtakeover_faders3.module.output"; to: "decks.3.remix_slots.3.volume" }
        Wire { from: "softtakeover_faders4.module.output"; to: "decks.3.remix_slots.4.volume" }

        WiresGroup
        {
          enabled: !isInEditMode && module.screenView.value == ScreenView.deck

          WiresGroup
          {
            enabled: footerPage.value == FooterPage.fxSend

            Wire { from: "%surface%.knobs.1"; to: "decks.3.remix_slots.1.fx_send"    }
            Wire { from: "%surface%.knobs.2"; to: "decks.3.remix_slots.2.fx_send"    }
            Wire { from: "%surface%.knobs.3"; to: "decks.3.remix_slots.3.fx_send"    }
            Wire { from: "%surface%.knobs.4"; to: "decks.3.remix_slots.4.fx_send"    }

            Wire { from: "%surface%.buttons.1"; to: "decks.3.remix_slots.1.fx_send_on"     }
            Wire { from: "%surface%.buttons.2"; to: "decks.3.remix_slots.2.fx_send_on"     }
            Wire { from: "%surface%.buttons.3"; to: "decks.3.remix_slots.3.fx_send_on"     }
            Wire { from: "%surface%.buttons.4"; to: "decks.3.remix_slots.4.fx_send_on"     }
          }

          WiresGroup
          {
            enabled: footerPage.value == FooterPage.filter

            Wire { from: "%surface%.knobs.1"; to: "decks.3.remix_slots.1.filter"    }
            Wire { from: "%surface%.knobs.2"; to: "decks.3.remix_slots.2.filter"    }
            Wire { from: "%surface%.knobs.3"; to: "decks.3.remix_slots.3.filter"    }
            Wire { from: "%surface%.knobs.4"; to: "decks.3.remix_slots.4.filter"    }

            Wire { from: "%surface%.buttons.1"; to: "decks.3.remix_slots.1.filter_on"     }
            Wire { from: "%surface%.buttons.2"; to: "decks.3.remix_slots.2.filter_on"     }
            Wire { from: "%surface%.buttons.3"; to: "decks.3.remix_slots.3.filter_on"     }
            Wire { from: "%surface%.buttons.4"; to: "decks.3.remix_slots.4.filter_on"     }
          }

          WiresGroup
          {
            enabled: footerPage.value == FooterPage.pitch

            Wire { from: "%surface%.knobs.1"; to: "decks.3.remix_slots.1.pitch"     }
            Wire { from: "%surface%.knobs.2"; to: "decks.3.remix_slots.2.pitch"     }
            Wire { from: "%surface%.knobs.3"; to: "decks.3.remix_slots.3.pitch"     }
            Wire { from: "%surface%.knobs.4"; to: "decks.3.remix_slots.4.pitch"     }

            Wire { from: "%surface%.buttons.1"; to: "decks.3.remix_slots.1.key_lock"      }
            Wire { from: "%surface%.buttons.2"; to: "decks.3.remix_slots.2.key_lock"      }
            Wire { from: "%surface%.buttons.3"; to: "decks.3.remix_slots.3.key_lock"      }
            Wire { from: "%surface%.buttons.4"; to: "decks.3.remix_slots.4.key_lock"      }
          }

          WiresGroup
          {
            enabled: footerPage.value == FooterPage.slot1

            Wire { from: "%surface%.knobs.1"; to: RelativePropertyAdapter{ path: "app.traktor.decks.3.remix.players.1.sequencer.selected_cell"; scaleFactor: 0.6 } enabled: !sequencerSampleLock.value }
            Wire { from: "%surface%.knobs.2"; to: "decks.3.remix_slots.1.filter"    }
            Wire { from: "%surface%.knobs.3"; to: "decks.3.remix_slots.1.pitch"     }
            Wire { from: "%surface%.knobs.4"; to: "decks.3.remix_slots.1.fx_send"   }

            Wire { from: "%surface%.buttons.1"; to: TogglePropertyAdapter { path: propertiesPath + ".sequencer_sample_lock" } }
            Wire { from: "%surface%.buttons.2"; to: "decks.3.remix_slots.1.filter_on"     }
            Wire { from: "%surface%.buttons.3"; to: "decks.3.remix_slots.1.key_lock"      }
            Wire { from: "%surface%.buttons.4"; to: "decks.3.remix_slots.1.fx_send_on"    }
          }

          WiresGroup
          {
            enabled: footerPage.value == FooterPage.slot2

            Wire { from: "%surface%.knobs.1"; to: RelativePropertyAdapter{ path: "app.traktor.decks.3.remix.players.2.sequencer.selected_cell"; scaleFactor: 0.6 } enabled: !sequencerSampleLock.value }
            Wire { from: "%surface%.knobs.2"; to: "decks.3.remix_slots.2.filter"    }
            Wire { from: "%surface%.knobs.3"; to: "decks.3.remix_slots.2.pitch"     }
            Wire { from: "%surface%.knobs.4"; to: "decks.3.remix_slots.2.fx_send"   }

            Wire { from: "%surface%.buttons.1"; to: TogglePropertyAdapter { path: propertiesPath + ".sequencer_sample_lock" } }
            Wire { from: "%surface%.buttons.2"; to: "decks.3.remix_slots.2.filter_on"     }
            Wire { from: "%surface%.buttons.3"; to: "decks.3.remix_slots.2.key_lock"      }
            Wire { from: "%surface%.buttons.4"; to: "decks.3.remix_slots.2.fx_send_on"    }
          }

          WiresGroup
          {
            enabled: footerPage.value == FooterPage.slot3

            Wire { from: "%surface%.knobs.1"; to: RelativePropertyAdapter{ path: "app.traktor.decks.3.remix.players.3.sequencer.selected_cell"; scaleFactor: 0.6 } enabled: !sequencerSampleLock.value }
            Wire { from: "%surface%.knobs.2"; to: "decks.3.remix_slots.3.filter"    }
            Wire { from: "%surface%.knobs.3"; to: "decks.3.remix_slots.3.pitch"     }
            Wire { from: "%surface%.knobs.4"; to: "decks.3.remix_slots.3.fx_send"   }

            Wire { from: "%surface%.buttons.1"; to: TogglePropertyAdapter { path: propertiesPath + ".sequencer_sample_lock" } }
            Wire { from: "%surface%.buttons.2"; to: "decks.3.remix_slots.3.filter_on"     }
            Wire { from: "%surface%.buttons.3"; to: "decks.3.remix_slots.3.key_lock"      }
            Wire { from: "%surface%.buttons.4"; to: "decks.3.remix_slots.3.fx_send_on"    }
          }

          WiresGroup
          {
            enabled: footerPage.value == FooterPage.slot4

            Wire { from: "%surface%.knobs.1"; to: RelativePropertyAdapter{ path: "app.traktor.decks.3.remix.players.4.sequencer.selected_cell"; scaleFactor: 0.6 } enabled: !sequencerSampleLock.value }
            Wire { from: "%surface%.knobs.2"; to: "decks.3.remix_slots.4.filter"    }
            Wire { from: "%surface%.knobs.3"; to: "decks.3.remix_slots.4.pitch"     }
            Wire { from: "%surface%.knobs.4"; to: "decks.3.remix_slots.4.fx_send"   }

            Wire { from: "%surface%.buttons.1"; to: TogglePropertyAdapter { path: propertiesPath + ".sequencer_sample_lock" } }
            Wire { from: "%surface%.buttons.2"; to: "decks.3.remix_slots.4.filter_on"     }
            Wire { from: "%surface%.buttons.3"; to: "decks.3.remix_slots.4.key_lock"      }
            Wire { from: "%surface%.buttons.4"; to: "decks.3.remix_slots.4.fx_send_on"    }
          }
        }
      }

      // Remix Deck D
      WiresGroup
      {
        enabled: (footerFocusedDeckId == 4) && (deckDType == DeckType.Remix)

        Wire { from: "%surface%.shift";              to: "decks.4.remix_slots.1.compensate_gain" }
        Wire { from: "%surface%.shift";              to: "decks.4.remix_slots.2.compensate_gain" }
        Wire { from: "%surface%.shift";              to: "decks.4.remix_slots.3.compensate_gain" }
        Wire { from: "%surface%.shift";              to: "decks.4.remix_slots.4.compensate_gain" }
        Wire { from: "softtakeover_faders1.module.output"; to: "decks.4.remix_slots.1.volume" }
        Wire { from: "softtakeover_faders2.module.output"; to: "decks.4.remix_slots.2.volume" }
        Wire { from: "softtakeover_faders3.module.output"; to: "decks.4.remix_slots.3.volume" }
        Wire { from: "softtakeover_faders4.module.output"; to: "decks.4.remix_slots.4.volume" }

        WiresGroup
        {
          enabled: !isInEditMode && module.screenView.value == ScreenView.deck

          WiresGroup
          {
            enabled: footerPage.value == FooterPage.fxSend

            Wire { from: "%surface%.knobs.1";   to: "decks.4.remix_slots.1.fx_send"    }
            Wire { from: "%surface%.knobs.2";   to: "decks.4.remix_slots.2.fx_send"    }
            Wire { from: "%surface%.knobs.3";   to: "decks.4.remix_slots.3.fx_send"    }
            Wire { from: "%surface%.knobs.4";   to: "decks.4.remix_slots.4.fx_send"    }

            Wire { from: "%surface%.buttons.1"; to: "decks.4.remix_slots.1.fx_send_on" }
            Wire { from: "%surface%.buttons.2"; to: "decks.4.remix_slots.2.fx_send_on" }
            Wire { from: "%surface%.buttons.3"; to: "decks.4.remix_slots.3.fx_send_on" }
            Wire { from: "%surface%.buttons.4"; to: "decks.4.remix_slots.4.fx_send_on" }
          }

          WiresGroup
          {
            enabled: footerPage.value == FooterPage.filter

            Wire { from: "%surface%.knobs.1";   to: "decks.4.remix_slots.1.filter"     }
            Wire { from: "%surface%.knobs.2";   to: "decks.4.remix_slots.2.filter"     }
            Wire { from: "%surface%.knobs.3";   to: "decks.4.remix_slots.3.filter"     }
            Wire { from: "%surface%.knobs.4";   to: "decks.4.remix_slots.4.filter"     }

            Wire { from: "%surface%.buttons.1"; to: "decks.4.remix_slots.1.filter_on"  }
            Wire { from: "%surface%.buttons.2"; to: "decks.4.remix_slots.2.filter_on"  }
            Wire { from: "%surface%.buttons.3"; to: "decks.4.remix_slots.3.filter_on"  }
            Wire { from: "%surface%.buttons.4"; to: "decks.4.remix_slots.4.filter_on"  }
          }

          WiresGroup
          {
            enabled: footerPage.value == FooterPage.pitch
  
            Wire { from: "%surface%.knobs.1";   to: "decks.4.remix_slots.1.pitch"    }
            Wire { from: "%surface%.knobs.2";   to: "decks.4.remix_slots.2.pitch"    }
            Wire { from: "%surface%.knobs.3";   to: "decks.4.remix_slots.3.pitch"    }
            Wire { from: "%surface%.knobs.4";   to: "decks.4.remix_slots.4.pitch"    }

            Wire { from: "%surface%.buttons.1"; to: "decks.4.remix_slots.1.key_lock" }
            Wire { from: "%surface%.buttons.2"; to: "decks.4.remix_slots.2.key_lock" }
            Wire { from: "%surface%.buttons.3"; to: "decks.4.remix_slots.3.key_lock" }
            Wire { from: "%surface%.buttons.4"; to: "decks.4.remix_slots.4.key_lock" }
          }

          WiresGroup
          {
            enabled: footerPage.value == FooterPage.slot1

            Wire { from: "%surface%.knobs.1"; to: RelativePropertyAdapter{ path: "app.traktor.decks.4.remix.players.1.sequencer.selected_cell"; scaleFactor: 0.6 } enabled: !sequencerSampleLock.value }
            Wire { from: "%surface%.knobs.2"; to: "decks.4.remix_slots.1.filter"    }
            Wire { from: "%surface%.knobs.3"; to: "decks.4.remix_slots.1.pitch"     }
            Wire { from: "%surface%.knobs.4"; to: "decks.4.remix_slots.1.fx_send"   }

            Wire { from: "%surface%.buttons.1"; to: TogglePropertyAdapter { path: propertiesPath + ".sequencer_sample_lock" } }
            Wire { from: "%surface%.buttons.2"; to: "decks.4.remix_slots.1.filter_on"     }
            Wire { from: "%surface%.buttons.3"; to: "decks.4.remix_slots.1.key_lock"      }
            Wire { from: "%surface%.buttons.4"; to: "decks.4.remix_slots.1.fx_send_on"    }
          }

          WiresGroup
          {
            enabled: footerPage.value == FooterPage.slot2

            Wire { from: "%surface%.knobs.1"; to: RelativePropertyAdapter{ path: "app.traktor.decks.4.remix.players.2.sequencer.selected_cell"; scaleFactor: 0.6 } enabled: !sequencerSampleLock.value }
            Wire { from: "%surface%.knobs.2"; to: "decks.4.remix_slots.2.filter"    }
            Wire { from: "%surface%.knobs.3"; to: "decks.4.remix_slots.2.pitch"     }
            Wire { from: "%surface%.knobs.4"; to: "decks.4.remix_slots.2.fx_send"   }

            Wire { from: "%surface%.buttons.1"; to: TogglePropertyAdapter { path: propertiesPath + ".sequencer_sample_lock" } }
            Wire { from: "%surface%.buttons.2"; to: "decks.4.remix_slots.2.filter_on"     }
            Wire { from: "%surface%.buttons.3"; to: "decks.4.remix_slots.2.key_lock"      }
            Wire { from: "%surface%.buttons.4"; to: "decks.4.remix_slots.2.fx_send_on"    }
          }

          WiresGroup
          {
            enabled: footerPage.value == FooterPage.slot3

            Wire { from: "%surface%.knobs.1"; to: RelativePropertyAdapter{ path: "app.traktor.decks.4.remix.players.3.sequencer.selected_cell"; scaleFactor: 0.6 } enabled: !sequencerSampleLock.value }
            Wire { from: "%surface%.knobs.2"; to: "decks.4.remix_slots.3.filter"    }
            Wire { from: "%surface%.knobs.3"; to: "decks.4.remix_slots.3.pitch"     }
            Wire { from: "%surface%.knobs.4"; to: "decks.4.remix_slots.3.fx_send"   }

            Wire { from: "%surface%.buttons.1"; to: TogglePropertyAdapter { path: propertiesPath + ".sequencer_sample_lock" } }
            Wire { from: "%surface%.buttons.2"; to: "decks.4.remix_slots.3.filter_on"     }
            Wire { from: "%surface%.buttons.3"; to: "decks.4.remix_slots.3.key_lock"      }
            Wire { from: "%surface%.buttons.4"; to: "decks.4.remix_slots.3.fx_send_on"    }
          }

          WiresGroup
          {
            enabled: footerPage.value == FooterPage.slot4

            Wire { from: "%surface%.knobs.1"; to: RelativePropertyAdapter{ path: "app.traktor.decks.4.remix.players.4.sequencer.selected_cell"; scaleFactor: 0.6 } enabled: !sequencerSampleLock.value }
            Wire { from: "%surface%.knobs.2"; to: "decks.4.remix_slots.4.filter"    }
            Wire { from: "%surface%.knobs.3"; to: "decks.4.remix_slots.4.pitch"     }
            Wire { from: "%surface%.knobs.4"; to: "decks.4.remix_slots.4.fx_send"   }

            Wire { from: "%surface%.buttons.1"; to: TogglePropertyAdapter { path: propertiesPath + ".sequencer_sample_lock" } }
            Wire { from: "%surface%.buttons.2"; to: "decks.4.remix_slots.4.filter_on"     }
            Wire { from: "%surface%.buttons.3"; to: "decks.4.remix_slots.4.key_lock"      }
            Wire { from: "%surface%.buttons.4"; to: "decks.4.remix_slots.4.fx_send_on"    }
          }
        }
      }

  //------------------------------------------------------------------------------------------------------------------
  //  Show header/footer on touch
  //------------------------------------------------------------------------------------------------------------------

  SwitchTimer { name: "TopInfoOverlay";     resetTimeout: 1000 }
  SwitchTimer { name: "BottomInfoOverlay";  resetTimeout: 1000 }

  WiresGroup
  {
    enabled: showFxOnTouch.value && (screenOverlay.value != Overlay.fx)

    Wire {
      from:
      Or {
        inputs:
        [
          "%surface%.fx.knobs.1.touch",
          "%surface%.fx.knobs.2.touch",
          "%surface%.fx.knobs.3.touch",
          "%surface%.fx.knobs.4.touch"
        ]
      } 
      to: "TopInfoOverlay.input"
    }

    Wire { from: "TopInfoOverlay.output"; to: DirectPropertyAdapter{ path: propertiesPath + ".top_info_show" } }
  }

  WiresGroup
  {
    enabled: showPerformanceControlsOnTouch.value && (screenOverlay.value != Overlay.fx) && footerShouldPopup && !isInEditMode

    Wire
    {
      enabled: footerPage.value == FooterPage.fx
      from: Or
      {
        inputs:
        [
          "%surface%.knobs.1.touch",
          "%surface%.knobs.2.touch",
          "%surface%.knobs.3.touch",
          "%surface%.knobs.4.touch"
        ]
      }
      to: "BottomInfoOverlay.input"
    }

    Wire
    {
      enabled: footerPage.value != FooterPage.fx
      from: Or
      {
        inputs:
        [
          "%surface%.knobs.1.touch",
          "%surface%.knobs.2.touch",
          "%surface%.knobs.3.touch",
          "%surface%.knobs.4.touch",
          "%surface%.faders.1.touch",
          "%surface%.faders.2.touch",
          "%surface%.faders.3.touch",
          "%surface%.faders.4.touch"
        ]
      }
      to: "BottomInfoOverlay.input"
    }
         
    Wire { from: "BottomInfoOverlay.output"; to: DirectPropertyAdapter{ path: propertiesPath + ".bottom_info_show" } }
  }

  //------------------------------------------------------------------------------------------------------------------  
  //  Zoom / Sample page / StemDeckStyle
  //------------------------------------------------------------------------------------------------------------------

  WiresGroup
  {
    enabled: (module.screenView.value == ScreenView.deck) && !isInEditMode

    // Deck A
    WiresGroup
    {
      enabled: focusedDeckId == 1

      // Waveform zoom
      WiresGroup
      {
        enabled: hasWaveform(deckAType) && !module.shift

        Wire { from: "%surface%.browse.turn"; to: RelativePropertyAdapter { path: settingsPath + ".top.waveform_zoom"; step: -1; mode: RelativeMode.Stepped } enabled: screenOverlay.value == Overlay.none }
        Wire { from: "%surface%.display.buttons.6"; to: RelativePropertyAdapter { path: settingsPath + ".top.waveform_zoom"; mode: RelativeMode.Decrement } }
        Wire { from: "%surface%.display.buttons.7"; to: RelativePropertyAdapter { path: settingsPath + ".top.waveform_zoom"; mode: RelativeMode.Increment } }
      }

      // Remix page scroll
      WiresGroup
      {
        enabled: (deckAType == DeckType.Remix)

        WiresGroup
        {
          enabled: !deckASequencerOn.value

          Wire { from: "%surface%.browse.turn"; to: "decks.1.remix.page"; enabled: screenOverlay.value == Overlay.none }
          Wire { from: "%surface%.browse.turn"; to: "ShowDisplayButtonArea_EncoderAdapter"; enabled: screenOverlay.value == Overlay.none }
          Wire { from: "%surface%.display.buttons.3"; to: TogglePropertyAdapter { path: propertiesPath + ".overlay"; value: Overlay.quantize } }
          Wire { from: "%surface%.display.buttons.6"; to: "decks.1.remix.decrement_page" }
          Wire { from: "%surface%.display.buttons.7"; to: "decks.1.remix.increment_page" }
        }

        WiresGroup
        {
          enabled: deckASequencerOn.value

          Wire { from: "%surface%.browse.turn"; to: RelativePropertyAdapter { path: propertiesPath + ".top.sequencer_deck_page"; mode: RelativeMode.Stepped } enabled: screenOverlay.value == Overlay.none }
          Wire { from: "%surface%.display.buttons.3"; to: TogglePropertyAdapter { path: propertiesPath + ".overlay"; value: Overlay.swing } }
          Wire { from: "%surface%.display.buttons.6"; to: SetPropertyAdapter { path: propertiesPath + ".top.sequencer_deck_page"; value: 1 } }
          Wire { from: "%surface%.display.buttons.7"; to: SetPropertyAdapter { path: propertiesPath + ".top.sequencer_deck_page"; value: 2 } }
        }

        WiresGroup
        {
          enabled: module.shift

          Wire { from: "%surface%.remix.value";  to: TogglePropertyAdapter { path: "app.traktor.decks.1.remix.sequencer.on"} }
        }
      }

      //Stem Style selection
      WiresGroup
      {
        enabled: (deckAType == DeckType.Stem) && module.shift

        Wire { from: "%surface%.display.buttons.6"; to: SetPropertyAdapter { path: propertiesPath + ".top.stem_deck_style";  value: StemStyle.track } }
        Wire { from: "%surface%.display.buttons.7"; to: SetPropertyAdapter { path: propertiesPath + ".top.stem_deck_style";  value: StemStyle.daw   } }
      }
    }

    // Deck B
    WiresGroup
    {
      enabled: focusedDeckId == 2

      // Waveform zoom
      WiresGroup
      {
        enabled: hasWaveform(deckBType) && !module.shift

        Wire { from: "%surface%.browse.turn"; to: RelativePropertyAdapter { path: settingsPath + ".top.waveform_zoom"; step: -1; mode: RelativeMode.Stepped } enabled: screenOverlay.value == Overlay.none }
        Wire { from: "%surface%.display.buttons.6"; to: RelativePropertyAdapter { path: settingsPath + ".top.waveform_zoom"; mode: RelativeMode.Decrement } }
        Wire { from: "%surface%.display.buttons.7"; to: RelativePropertyAdapter { path: settingsPath + ".top.waveform_zoom"; mode: RelativeMode.Increment } }
      }

      // Remix page scroll
      WiresGroup
      {
        enabled: (deckBType == DeckType.Remix)

        WiresGroup
        {
          enabled: !deckBSequencerOn.value

          Wire { from: "%surface%.browse.turn"; to: "decks.2.remix.page"; enabled: screenOverlay.value == Overlay.none }
          Wire { from: "%surface%.browse.turn"; to: "ShowDisplayButtonArea_EncoderAdapter"; enabled: screenOverlay.value == Overlay.none }
          Wire { from: "%surface%.display.buttons.3"; to: TogglePropertyAdapter { path: propertiesPath + ".overlay"; value: Overlay.quantize } }
          Wire { from: "%surface%.display.buttons.6"; to: "decks.2.remix.decrement_page" }
          Wire { from: "%surface%.display.buttons.7"; to: "decks.2.remix.increment_page" }
        }

        WiresGroup
        {
          enabled: deckBSequencerOn.value

          Wire { from: "%surface%.browse.turn"; to: RelativePropertyAdapter { path: propertiesPath + ".top.sequencer_deck_page"; mode: RelativeMode.Stepped } enabled: screenOverlay.value == Overlay.none }
          Wire { from: "%surface%.display.buttons.3"; to: TogglePropertyAdapter { path: propertiesPath + ".overlay"; value: Overlay.swing } }
          Wire { from: "%surface%.display.buttons.6"; to: SetPropertyAdapter { path: propertiesPath + ".top.sequencer_deck_page"; value: 1 } }
          Wire { from: "%surface%.display.buttons.7"; to: SetPropertyAdapter { path: propertiesPath + ".top.sequencer_deck_page"; value: 2 } }
        }

        WiresGroup
        {
          enabled: module.shift

          Wire { from: "%surface%.remix.value";  to: TogglePropertyAdapter { path: "app.traktor.decks.2.remix.sequencer.on"} }
        }
      }

      //Stem Style selection
      WiresGroup
      {
        enabled: (deckBType == DeckType.Stem) && module.shift

        Wire { from: "%surface%.display.buttons.6"; to: SetPropertyAdapter { path: propertiesPath + ".top.stem_deck_style";  value: StemStyle.track } }
        Wire { from: "%surface%.display.buttons.7"; to: SetPropertyAdapter { path: propertiesPath + ".top.stem_deck_style";  value: StemStyle.daw   } }
      }
    }

    // Deck C
    WiresGroup
    {
      enabled: focusedDeckId == 3

      // Waveform zoom
      WiresGroup
      {
        enabled: hasWaveform(deckCType) && !module.shift

        Wire { from: "%surface%.browse.turn"; to: RelativePropertyAdapter { path: settingsPath + ".bottom.waveform_zoom"; step: -1; mode: RelativeMode.Stepped } enabled: screenOverlay.value == Overlay.none }
        Wire { from: "%surface%.display.buttons.6"; to: RelativePropertyAdapter { path: settingsPath + ".bottom.waveform_zoom"; mode: RelativeMode.Decrement } }
        Wire { from: "%surface%.display.buttons.7"; to: RelativePropertyAdapter { path: settingsPath + ".bottom.waveform_zoom"; mode: RelativeMode.Increment } }
      }

      // Remix page scroll
      WiresGroup
      {
        enabled: (deckCType == DeckType.Remix)

        WiresGroup
        {
          enabled: !deckCSequencerOn.value

          Wire { from: "%surface%.browse.turn"; to: "decks.3.remix.page"; enabled: screenOverlay.value == Overlay.none }
          Wire { from: "%surface%.browse.turn"; to: "ShowDisplayButtonArea_EncoderAdapter"; enabled: screenOverlay.value == Overlay.none }
          Wire { from: "%surface%.display.buttons.3"; to: TogglePropertyAdapter { path: propertiesPath + ".overlay"; value: Overlay.quantize } }
          Wire { from: "%surface%.display.buttons.6"; to: "decks.3.remix.decrement_page" }
          Wire { from: "%surface%.display.buttons.7"; to: "decks.3.remix.increment_page" }
        }

        WiresGroup
        {
          enabled: deckCSequencerOn.value

          Wire { from: "%surface%.browse.turn"; to: RelativePropertyAdapter { path: propertiesPath + ".bottom.sequencer_deck_page"; mode: RelativeMode.Stepped } enabled: screenOverlay.value == Overlay.none }
          Wire { from: "%surface%.display.buttons.3"; to: TogglePropertyAdapter { path: propertiesPath + ".overlay"; value: Overlay.swing } }
          Wire { from: "%surface%.display.buttons.6"; to: SetPropertyAdapter { path: propertiesPath + ".bottom.sequencer_deck_page"; value: 1 } }
          Wire { from: "%surface%.display.buttons.7"; to: SetPropertyAdapter { path: propertiesPath + ".bottom.sequencer_deck_page"; value: 2 } }
        }

        WiresGroup
        {
          enabled: module.shift

          Wire { from: "%surface%.remix.value";  to: TogglePropertyAdapter { path: "app.traktor.decks.3.remix.sequencer.on"} }
        }
      }

      //Stem Style selection
      WiresGroup
      {
        enabled: (deckCType == DeckType.Stem) && module.shift

        Wire { from: "%surface%.display.buttons.6"; to: SetPropertyAdapter { path: propertiesPath + ".bottom.stem_deck_style";  value: StemStyle.track } }
        Wire { from: "%surface%.display.buttons.7"; to: SetPropertyAdapter { path: propertiesPath + ".bottom.stem_deck_style";  value: StemStyle.daw   } }
      }
    }

    // Deck D
    WiresGroup
    {
      enabled: focusedDeckId == 4

      // Waveform zoom
      WiresGroup
      {
        enabled: hasWaveform(deckDType) && !module.shift

        Wire { from: "%surface%.browse.turn"; to: RelativePropertyAdapter { path: settingsPath + ".bottom.waveform_zoom"; step: -1; mode: RelativeMode.Stepped } enabled: screenOverlay.value == Overlay.none }
        Wire { from: "%surface%.display.buttons.6"; to: RelativePropertyAdapter { path: settingsPath + ".bottom.waveform_zoom"; mode: RelativeMode.Decrement } }
        Wire { from: "%surface%.display.buttons.7"; to: RelativePropertyAdapter { path: settingsPath + ".bottom.waveform_zoom"; mode: RelativeMode.Increment } }
      }

      // Remix page scroll
      WiresGroup
      {
        enabled: (deckDType == DeckType.Remix)

        WiresGroup
        {
          enabled: !deckDSequencerOn.value

          Wire { from: "%surface%.browse.turn"; to: "decks.4.remix.page"; enabled: screenOverlay.value == Overlay.none }
          Wire { from: "%surface%.browse.turn"; to: "ShowDisplayButtonArea_EncoderAdapter"; enabled: screenOverlay.value == Overlay.none }
          Wire { from: "%surface%.display.buttons.3"; to: TogglePropertyAdapter { path: propertiesPath + ".overlay"; value: Overlay.quantize } }
          Wire { from: "%surface%.display.buttons.6"; to: "decks.4.remix.decrement_page" }
          Wire { from: "%surface%.display.buttons.7"; to: "decks.4.remix.increment_page" }
        }

        WiresGroup
        {
          enabled: deckDSequencerOn.value

          Wire { from: "%surface%.browse.turn"; to: RelativePropertyAdapter { path: propertiesPath + ".bottom.sequencer_deck_page"; mode: RelativeMode.Stepped } enabled: screenOverlay.value == Overlay.none }
          Wire { from: "%surface%.display.buttons.3"; to: TogglePropertyAdapter { path: propertiesPath + ".overlay"; value: Overlay.swing } }
          Wire { from: "%surface%.display.buttons.6"; to: SetPropertyAdapter { path: propertiesPath + ".bottom.sequencer_deck_page"; value: 1 } }
          Wire { from: "%surface%.display.buttons.7"; to: SetPropertyAdapter { path: propertiesPath + ".bottom.sequencer_deck_page"; value: 2 } }
        }

        WiresGroup
        {
          enabled: module.shift

          Wire { from: "%surface%.remix.value";  to: TogglePropertyAdapter { path: "app.traktor.decks.4.remix.sequencer.on"} }
        }
      }

      //Stem Style selection
      WiresGroup
      {
        enabled: (deckDType == DeckType.Stem) && module.shift

        Wire { from: "%surface%.display.buttons.6"; to: SetPropertyAdapter { path: propertiesPath + ".bottom.stem_deck_style";  value: StemStyle.track } }
        Wire { from: "%surface%.display.buttons.7"; to: SetPropertyAdapter { path: propertiesPath + ".bottom.stem_deck_style";  value: StemStyle.daw   } }
      }
    }
  }

  //------------------------------------------------------------------------------------------------------------------
  //  TRANSPORT SECTION
  //------------------------------------------------------------------------------------------------------------------

  // Settings forwarding
  Group
  {
    name: "touchstrip_settings"

    DirectPropertyAdapter { name: "bend_bensitivity";    path: "mapping.settings.touchstrip_bend_sensitivity";        input: false    }
    DirectPropertyAdapter { name: "bend_invert";         path: "mapping.settings.touchstrip_bend_invert";             input: false    }
    DirectPropertyAdapter { name: "scratch_sensitivity"; path: "mapping.settings.touchstrip_scratch_sensitivity";     input: false    }
    DirectPropertyAdapter { name: "scratch_invert";      path: "mapping.settings.touchstrip_scratch_invert";          input: false    }
  }

  // Deck A
  Wire { from: "touchstrip_settings.bend_bensitivity";     to: "decks.1.tempo_bend.sensitivity" }
  Wire { from: "touchstrip_settings.bend_invert";          to: "decks.1.tempo_bend.invert"      }
  Wire { from: "touchstrip_settings.scratch_sensitivity";  to: "decks.1.scratch.sensitivity"    }
  Wire { from: "touchstrip_settings.scratch_invert";       to: "decks.1.scratch.invert"         }

  WiresGroup
  {
    id: transportA

    enabled: (focusedDeckId == 1) && (hasTransport(deckAType))

    WiresGroup
    {
      enabled: !module.shift

      Wire { from: "%surface%.flux"; to: "decks.1.transport.flux"; enabled: !module.shift }

      Wire { from: "%surface%.play"; to: "decks.1.transport.play" }
      Wire { from: "%surface%.cue";  to: "decks.1.transport.cue"  }
    }

    WiresGroup
    {
      enabled: module.shift

      Wire { from: "%surface%.flux"; to: "decks.1.transport.flux_reverse" }

      Wire { from: "%surface%.play"; to: "decks.1.transport.timecode"     }
      Wire { from: "%surface%.cue";  to: "decks.1.transport.return_to_zero" }
    }

    WiresGroup
    {
      enabled: module.shift && hasSeek(deckAType) && !(deckARunning.value  && scratchWithTouchstrip.value)

      Wire { from: "%surface%.touchstrip";        to: "decks.1.track_seek"      }
      Wire { from: "%surface%.touchstrip.leds";   to: "decks.1.track_seek.leds" }
    }

    WiresGroup
    {
      enabled: (!deckARunning.value && !(module.shift && hasSeek(deckAType)))
               || (deckARunning.value && module.shift && (!hasSeek(deckAType) || scratchWithTouchstrip.value))

      Wire { from: "%surface%.touchstrip";        to: "decks.1.scratch"        }
      Wire { from: "%surface%.touchstrip.leds";   to: "decks.1.scratch.leds"   }
    }

    WiresGroup
    {
      enabled: deckARunning.value && !module.shift

      Wire { from: "%surface%.touchstrip";        to: "decks.1.tempo_bend"      }
      Wire { from: "%surface%.touchstrip.leds";   to: "decks.1.tempo_bend.leds" }
    }
  }

  // Deck B
  Wire { from: "touchstrip_settings.bend_bensitivity";     to: "decks.2.tempo_bend.sensitivity" }
  Wire { from: "touchstrip_settings.bend_invert";          to: "decks.2.tempo_bend.invert"      }
  Wire { from: "touchstrip_settings.scratch_sensitivity";  to: "decks.2.scratch.sensitivity"    }
  Wire { from: "touchstrip_settings.scratch_invert";       to: "decks.2.scratch.invert"         }

  WiresGroup
  {
    id: transportB

    enabled: (focusedDeckId == 2) && (hasTransport(deckBType))

    WiresGroup
    {
      enabled: !module.shift

      Wire { from: "%surface%.flux"; to: "decks.2.transport.flux"; enabled: !module.shift }

      Wire { from: "%surface%.play"; to: "decks.2.transport.play" }
      Wire { from: "%surface%.cue";  to: "decks.2.transport.cue"  }
    }

    WiresGroup
    {
      enabled: module.shift

      Wire { from: "%surface%.flux"; to: "decks.2.transport.flux_reverse" }

      Wire { from: "%surface%.play"; to: "decks.2.transport.timecode"     }
      Wire { from: "%surface%.cue";  to: "decks.2.transport.return_to_zero" }
    }

    WiresGroup
    {
      enabled: module.shift && hasSeek(deckBType) && !(deckBRunning.value  && scratchWithTouchstrip.value)

      Wire { from: "%surface%.touchstrip";       to: "decks.2.track_seek"      }
      Wire { from: "%surface%.touchstrip.leds";  to: "decks.2.track_seek.leds" }
    }

    WiresGroup
    {
      enabled: (!deckBRunning.value && !(module.shift && hasSeek(deckBType)))
               || (deckBRunning.value && module.shift && (!hasSeek(deckBType) || scratchWithTouchstrip.value))

      Wire { from: "%surface%.touchstrip";       to: "decks.2.scratch"        }
      Wire { from: "%surface%.touchstrip.leds";  to: "decks.2.scratch.leds"   }
    }

    WiresGroup
    {
      enabled: deckBRunning.value && !module.shift

      Wire { from: "%surface%.touchstrip";       to: "decks.2.tempo_bend"      }
      Wire { from: "%surface%.touchstrip.leds";  to: "decks.2.tempo_bend.leds" }
    }
  }

  // Deck C
  Wire { from: "touchstrip_settings.bend_bensitivity";     to: "decks.3.tempo_bend.sensitivity" }
  Wire { from: "touchstrip_settings.bend_invert";          to: "decks.3.tempo_bend.invert"      }
  Wire { from: "touchstrip_settings.scratch_sensitivity";  to: "decks.3.scratch.sensitivity"    }
  Wire { from: "touchstrip_settings.scratch_invert";       to: "decks.3.scratch.invert"         }

  WiresGroup
  {
    id: transportC

    enabled: (focusedDeckId == 3) && (hasTransport(deckCType))

    WiresGroup
    {
      enabled: !module.shift

      Wire { from: "%surface%.flux"; to: "decks.3.transport.flux"; enabled: !module.shift }

      Wire { from: "%surface%.play"; to: "decks.3.transport.play" }
      Wire { from: "%surface%.cue";  to: "decks.3.transport.cue"  }
    }

    WiresGroup
    {
      enabled: module.shift

      Wire { from: "%surface%.flux"; to: "decks.3.transport.flux_reverse" }

      Wire { from: "%surface%.play"; to: "decks.3.transport.timecode"     }
      Wire { from: "%surface%.cue";  to: "decks.3.transport.return_to_zero" }
    }

    WiresGroup
    {
      enabled: module.shift && hasSeek(deckCType) && !(deckCRunning.value  && scratchWithTouchstrip.value)

      Wire { from: "%surface%.touchstrip";        to: "decks.3.track_seek"       }
      Wire { from: "%surface%.touchstrip.leds";   to: "decks.3.track_seek.leds"  }
    }

    WiresGroup
    {
      enabled: (!deckCRunning.value && !(module.shift && hasSeek(deckCType)))
               || (deckCRunning.value && module.shift && (!hasSeek(deckCType) || scratchWithTouchstrip.value))

      Wire { from: "%surface%.touchstrip";        to: "decks.3.scratch"         }
      Wire { from: "%surface%.touchstrip.leds";   to: "decks.3.scratch.leds"    }
    }

    WiresGroup
    {
      enabled: deckCRunning.value && !module.shift

      Wire { from: "%surface%.touchstrip";        to: "decks.3.tempo_bend"       }
      Wire { from: "%surface%.touchstrip.leds";   to: "decks.3.tempo_bend.leds"  }
    }
  }

  // Deck D
  Wire { from: "touchstrip_settings.bend_bensitivity";     to: "decks.4.tempo_bend.sensitivity" }
  Wire { from: "touchstrip_settings.bend_invert";          to: "decks.4.tempo_bend.invert"      }
  Wire { from: "touchstrip_settings.scratch_sensitivity";  to: "decks.4.scratch.sensitivity"    }
  Wire { from: "touchstrip_settings.scratch_invert";       to: "decks.4.scratch.invert"         }

  WiresGroup
  {
    id: transportD

    enabled: (focusedDeckId == 4) && (hasTransport(deckDType))

    WiresGroup
    {
      enabled: !module.shift

      Wire { from: "%surface%.flux"; to: "decks.4.transport.flux"; enabled: !module.shift }

      Wire { from: "%surface%.play"; to: "decks.4.transport.play" }
      Wire { from: "%surface%.cue";  to: "decks.4.transport.cue"  }
    }

    WiresGroup
    {
      enabled: module.shift

      Wire { from: "%surface%.flux"; to: "decks.4.transport.flux_reverse" }

      Wire { from: "%surface%.play"; to: "decks.4.transport.timecode"     }
      Wire { from: "%surface%.cue";  to: "decks.4.transport.return_to_zero" }
    }

    WiresGroup
    {
      enabled: module.shift && hasSeek(deckDType) && !(deckDRunning.value  && scratchWithTouchstrip.value)

      Wire { from: "%surface%.touchstrip";       to: "decks.4.track_seek"       }
      Wire { from: "%surface%.touchstrip.leds";  to: "decks.4.track_seek.leds"  }
    }

    WiresGroup
    {
      enabled: (!deckDRunning.value && !(module.shift && hasSeek(deckDType)))
               || (deckDRunning.value && module.shift && (!hasSeek(deckDType) || scratchWithTouchstrip.value))

      Wire { from: "%surface%.touchstrip";       to: "decks.4.scratch"         }
      Wire { from: "%surface%.touchstrip.leds";  to: "decks.4.scratch.leds"    }
    }

    WiresGroup
    {
      enabled: deckDRunning.value && !module.shift

      Wire { from: "%surface%.touchstrip";       to: "decks.4.tempo_bend"       }
      Wire { from: "%surface%.touchstrip.leds";  to: "decks.4.tempo_bend.leds"  }
    }
  }

  SwitchTimer { name: "TempBPMOverlay_Switch"; setTimeout: 250 }

  Wire { from: "%surface%.sync"; to: ButtonScriptAdapter { brightness: (isTempoSynced.value ? onBrightness : dimmedBrightness); color: ((!isTempoSynced.value || (syncPhase >= -0.01 && syncPhase <= 0.01)) ? Color.Green : Color.Red); onRelease: onSyncReleased(); } enabled: (editMode.value != editModeArmed) && (editMode.value != editModeUsed) && !module.shift }
  Wire { from: "%surface%.sync"; to: ButtonScriptAdapter { brightness: ((masterDeckIdProp.value == focusedDeckId - 1) ? onBrightness : dimmedBrightness); color: Color.Green; onRelease: onSyncReleased(); } enabled: (editMode.value != editModeArmed) && (editMode.value != editModeUsed) && module.shift }
  Wire { from: "%surface%.sync"; to: "TempBPMOverlay_Switch.input" }
  Wire { from: "TempBPMOverlay_Switch.output"; to: ButtonScriptAdapter { onPress: { screenOverlay.value = Overlay.bpm; tempBPMOverlay = true; } } }

  function onSyncReleased()
  {
    if (tempBPMOverlay)
    {
      screenOverlay.value = Overlay.none;
      tempBPMOverlay = false;
      return;
    }
    if (module.shift)
    {
      masterDeckIdProp.value = focusedDeckId - 1;
      return;
    }

    isTempoSynced.value = !isTempoSynced.value;
  }

  //------------------------------------------------------------------------------------------------------------------

  WiresGroup
  {
    enabled:  (decksAssignment == DecksAssignment.AC)

    Wire { from: "decks.1.remix.page"; to: "screen.upper_remix_deck_page" }
    Wire { from: "decks.3.remix.page"; to: "screen.lower_remix_deck_page" }

    Wire { from: "decks.1.remix_sequencer.slot.write"; to: "topSequencerSlot.read" }
    Wire { from: "decks.1.remix_sequencer.page.write"; to: "topSequencerPage.read" }
    Wire { from: "decks.3.remix_sequencer.slot.write"; to: "bottomSequencerSlot.read" }
    Wire { from: "decks.3.remix_sequencer.page.write"; to: "bottomSequencerPage.read" }
  }

  WiresGroup
  {
    enabled: (decksAssignment == DecksAssignment.BD)

    Wire { from: "decks.2.remix.page"; to: "screen.upper_remix_deck_page" }
    Wire { from: "decks.4.remix.page"; to: "screen.lower_remix_deck_page" }

    Wire { from: "decks.2.remix_sequencer.slot.write"; to: "topSequencerSlot.read" }
    Wire { from: "decks.2.remix_sequencer.page.write"; to: "topSequencerPage.read" }
    Wire { from: "decks.4.remix_sequencer.slot.write"; to: "bottomSequencerSlot.read" }
    Wire { from: "decks.4.remix_sequencer.page.write"; to: "bottomSequencerPage.read" }
  }

  //------------------------------------------------------------------------------------------------------------------
  //  SSS — FX KNOB CAPTURE (shift-active)
  //  Routes surface FX knobs to SSS MappingPropertyDescriptors when shift is held.
  //  Knob 1 → focused only.  Knob 2 → sibling only.  Knob 3 → other-side only.  Knob 4 → all 4 decks.
  //  The FX unit knob wiring above is suspended when shift is active; SSS takes priority.
  //------------------------------------------------------------------------------------------------------------------

  // FX knob 1: focused deck only (standard formula).
  // Disabled when both shift and SSS mode are active — shift suppresses SSS knobs in persistent mode
  // so the user can pre-position the knob before the separation takes effect.
  WiresGroup
  {
    enabled: (module.shift !== sssModeActive) && sssFocusedEnabled
    Wire { from: "%surface%.fx.knobs.1"; to: DirectPropertyAdapter { path: propertiesPath + ".sss.knob.1" } }
  }

  // FX knob 2: sibling deck only (standard formula).
  WiresGroup
  {
    enabled: (module.shift !== sssModeActive) && sssSiblingEnabled
    Wire { from: "%surface%.fx.knobs.2"; to: DirectPropertyAdapter { path: propertiesPath + ".sss.knob.2" } }
  }

  // FX knob 3: other-side deck only (reversed formula).
  WiresGroup
  {
    enabled: (module.shift !== sssModeActive) && sssOtherSideEnabled
    Wire { from: "%surface%.fx.knobs.3"; to: DirectPropertyAdapter { path: propertiesPath + ".sss.knob.3" } }
  }

  // FX knob 4: all 4 decks (focused standard + sibling/other-side/other-sib reversed).
  WiresGroup
  {
    enabled: (module.shift !== sssModeActive) && sssFocusedEnabled
    Wire { from: "%surface%.fx.knobs.4"; to: DirectPropertyAdapter { path: propertiesPath + ".sss.knob.4" } }
  }

  //------------------------------------------------------------------------------------------------------------------
  //  SSS MODE — SHIFT+FLUX TOGGLE, LED BLINKER
  //  Shift+Flux enters StemSuperSeparationMode.  FLUX LED pulsates.  Shift+Flux again exits.
  //------------------------------------------------------------------------------------------------------------------

  // Slow pulse: on-bright → dim → on-bright ...  Matches the style of other blinkers in this file.
  Blinker { name: "SssModeFluxBlinker"; cycle: 600; autorun: true; defaultBrightness: onBrightness; blinkBrightness: dimmedBrightness }

  // Override the FLUX button LED with the pulsating blinker while SSS mode is active.
  WiresGroup
  {
    enabled: sssModeActive
    Wire { from: "%surface%.flux.led"; to: "SssModeFluxBlinker" }
  }

  // Shift+Flux: toggle StemSuperSeparationMode.  LED brightness shows current state while shift is held.
  // The four flux-to-transport.flux Wires above are gated on !module.shift so this handler has sole ownership
  // of the flux button press when shift is active.
  WiresGroup
  {
    enabled: module.shift
    Wire
    {
      from: "%surface%.flux"
      to: ButtonScriptAdapter
      {
        brightness: sssModeActive ? onBrightness : dimmedBrightness
        onPress:
        {
          if (sssModeActive) {
            sssOnExitMode()
            sssModeActive = false
          } else {
            sssOnEnterMode()
            sssModeActive = true
          }
        }
      }
    }
  }

  //------------------------------------------------------------------------------------------------------------------
  //  COPY PHASE FROM MASTER
  //------------------------------------------------------------------------------------------------------------------

  CopyMasterPhase { name: "DeckA_CopyMasterPhase";  channel: 1 }
  SwitchTimer { name: "DeckA_CopyMasterPhase_Switch"; setTimeout: 1000 }

  CopyMasterPhase { name: "DeckB_CopyMasterPhase";  channel: 2 }
  SwitchTimer { name: "DeckB_CopyMasterPhase_Switch"; setTimeout: 1000 }

  CopyMasterPhase { name: "DeckC_CopyMasterPhase";  channel: 3 }
  SwitchTimer { name: "DeckC_CopyMasterPhase_Switch"; setTimeout: 1000 }

  CopyMasterPhase { name: "DeckD_CopyMasterPhase";  channel: 4 }
  SwitchTimer { name: "DeckD_CopyMasterPhase_Switch"; setTimeout: 1000 }
  
  Blinker { name: "CopyMasterPhase_Blinker"; cycle: 300; repetitions: 3; defaultBrightness: onBrightness; blinkBrightness: dimmedBrightness; color: Color.Green }

  WiresGroup
  {
    enabled: (editMode.value == editModeArmed) || (editMode.value == editModeUsed)

    Wire { from: "%surface%.sync.led"; to: "CopyMasterPhase_Blinker" }
    Wire { from: "%surface%.sync.value"; to: ButtonScriptAdapter { onPress: onSyncPressed(); } }

    // Deck A
    WiresGroup
    {
      enabled: (focusedDeckId == 1) && hasEditMode(deckAType)

      Wire { from: "%surface%.sync"; to: "DeckA_CopyMasterPhase_Switch.input" }
      Wire { from: "DeckA_CopyMasterPhase_Switch.output"; to: "DeckA_CopyMasterPhase" }
      Wire { from: "DeckA_CopyMasterPhase_Switch.output"; to: "CopyMasterPhase_Blinker.trigger" }
    }

    // Deck B
    WiresGroup
    {
      enabled: (focusedDeckId == 2) && hasEditMode(deckBType)

      Wire { from: "%surface%.sync"; to: "DeckB_CopyMasterPhase_Switch.input" }
      Wire { from: "DeckB_CopyMasterPhase_Switch.output"; to: "DeckB_CopyMasterPhase" }
      Wire { from: "DeckB_CopyMasterPhase_Switch.output"; to: "CopyMasterPhase_Blinker.trigger" }
    }

    // Deck C
    WiresGroup
    {
      enabled: (focusedDeckId == 3) && hasEditMode(deckCType)

      Wire { from: "%surface%.sync"; to: "DeckC_CopyMasterPhase_Switch.input" }
      Wire { from: "DeckC_CopyMasterPhase_Switch.output"; to: "DeckC_CopyMasterPhase" }
      Wire { from: "DeckC_CopyMasterPhase_Switch.output"; to: "CopyMasterPhase_Blinker.trigger" }
    }

    // Deck D
    WiresGroup
    {
      enabled: (focusedDeckId == 4) && hasEditMode(deckDType)

      Wire { from: "%surface%.sync"; to: "DeckD_CopyMasterPhase_Switch.input" }
      Wire { from: "DeckD_CopyMasterPhase_Switch.output"; to: "DeckD_CopyMasterPhase" }
      Wire { from: "DeckD_CopyMasterPhase_Switch.output"; to: "CopyMasterPhase_Blinker.trigger" }
    }
  }

  //------------------------------------------------------------------------------------------------------------------
  //  EFFECT UNITS
  //------------------------------------------------------------------------------------------------------------------

  Group
  {
    name: "fx_units"

    FxUnit { name: "1"; channel: 1 }
    FxUnit { name: "2"; channel: 2 }
    FxUnit { name: "3"; channel: 3 }
    FxUnit { name: "4"; channel: 4 }
  }

  WiresGroup
  {
    enabled: module.screenView.value == ScreenView.deck

    Wire
    {
      enabled: screenOverlay.value != Overlay.fx
      from: "softtakeover_knobs_timer.output"
      to: DirectPropertyAdapter { path: propertiesPath + ".softtakeover.show_knobs"; output: false }
    }

    // Effect Unit 1
    WiresGroup
    {
      enabled: decksAssignment == DecksAssignment.AC

      WiresGroup
      {
        enabled: screenOverlay.value != Overlay.fx

        Wire { from: "%surface%.fx.buttons.1";   to: "fx_units.1.enabled" }
        Wire { from: "%surface%.fx.buttons.2";   to: "fx_units.1.button1" }
        Wire { from: "%surface%.fx.buttons.3";   to: "fx_units.1.button2" }
        Wire { from: "%surface%.fx.buttons.4";   to: "fx_units.1.button3" }
      }

      WiresGroup
      {
        enabled: !module.shift
        Wire { from: "softtakeover_knobs1.module.output"; to: "fx_units.1.dry_wet" }
        Wire { from: "softtakeover_knobs2.module.output"; to: "fx_units.1.knob1"   }
        Wire { from: "softtakeover_knobs3.module.output"; to: "fx_units.1.knob2"   }
        Wire { from: "softtakeover_knobs4.module.output"; to: "fx_units.1.knob3"   }
      }
    }

    // Effect Unit 2
    WiresGroup
    {
      enabled: decksAssignment == DecksAssignment.BD

      WiresGroup
      {
        enabled: screenOverlay.value != Overlay.fx

        Wire { from: "%surface%.fx.buttons.1";   to: "fx_units.2.enabled" }
        Wire { from: "%surface%.fx.buttons.2";   to: "fx_units.2.button1" }
        Wire { from: "%surface%.fx.buttons.3";   to: "fx_units.2.button2" }
        Wire { from: "%surface%.fx.buttons.4";   to: "fx_units.2.button3" }
      }

      WiresGroup
      {
        enabled: !module.shift
        Wire { from: "softtakeover_knobs1.module.output"; to: "fx_units.2.dry_wet" }
        Wire { from: "softtakeover_knobs2.module.output"; to: "fx_units.2.knob1"   }
        Wire { from: "softtakeover_knobs3.module.output"; to: "fx_units.2.knob2"   }
        Wire { from: "softtakeover_knobs4.module.output"; to: "fx_units.2.knob3"   }
      }
    }

    WiresGroup
    {
      enabled: (fxMode.value == FxMode.FourFxUnits) && (footerPage.value == FooterPage.fx) && !isInEditMode

      // Effect Unit 3
      WiresGroup
      {
        enabled: decksAssignment == DecksAssignment.AC

        WiresGroup
        {
          enabled: screenOverlay.value != Overlay.fx

          Wire { from: "%surface%.buttons.1";   to: "fx_units.3.enabled" }
          Wire { from: "%surface%.buttons.2";   to: "fx_units.3.button1" }
          Wire { from: "%surface%.buttons.3";   to: "fx_units.3.button2" }
          Wire { from: "%surface%.buttons.4";   to: "fx_units.3.button3" }
        }

        Wire { from: "%surface%.knobs.1"; to: "fx_units.3.dry_wet" }
        Wire { from: "%surface%.knobs.2"; to: "fx_units.3.knob1"   }
        Wire { from: "%surface%.knobs.3"; to: "fx_units.3.knob2"   }
        Wire { from: "%surface%.knobs.4"; to: "fx_units.3.knob3"   }
      }

      // Effect Unit 4
      WiresGroup
      {
        enabled: decksAssignment == DecksAssignment.BD

        WiresGroup
        {
          enabled: screenOverlay.value != Overlay.fx

          Wire { from: "%surface%.buttons.1";   to: "fx_units.4.enabled" }
          Wire { from: "%surface%.buttons.2";   to: "fx_units.4.button1" }
          Wire { from: "%surface%.buttons.3";   to: "fx_units.4.button2" }
          Wire { from: "%surface%.buttons.4";   to: "fx_units.4.button3" }
        }

        Wire { from: "%surface%.knobs.1"; to: "fx_units.4.dry_wet" }
        Wire { from: "%surface%.knobs.2"; to: "fx_units.4.knob1"   }
        Wire { from: "%surface%.knobs.3"; to: "fx_units.4.knob2"   }
        Wire { from: "%surface%.knobs.4"; to: "fx_units.4.knob3"   }
      }
    }
  }

  //------------------------------------------------------------------------------------------------------------------
  //  MIDI CONTROLS
  //------------------------------------------------------------------------------------------------------------------

  WiresGroup
  {
    enabled: module.useMIDIControls

    WiresGroup
    {
      enabled: decksAssignment == DecksAssignment.AC 

      WiresGroup
      {
        enabled: !hasBottomControls(deckAType) && !hasBottomControls(deckCType)

        Wire { from: "%surface%.faders.1";       to: DirectPropertyAdapter { path: "app.traktor.midi.faders.1" } }
        Wire { from: "%surface%.faders.2";       to: DirectPropertyAdapter { path: "app.traktor.midi.faders.2" } }
        Wire { from: "%surface%.faders.3";       to: DirectPropertyAdapter { path: "app.traktor.midi.faders.3" } }
        Wire { from: "%surface%.faders.4";       to: DirectPropertyAdapter { path: "app.traktor.midi.faders.4" } }
      }

      WiresGroup
      {
        enabled: (module.screenView.value == ScreenView.deck) && !isInEditMode && (footerPage.value == FooterPage.midi)

        Wire { from: "%surface%.buttons.1";     to: TogglePropertyAdapter { path: "app.traktor.midi.buttons.1" } }
        Wire { from: "%surface%.buttons.2";     to: TogglePropertyAdapter { path: "app.traktor.midi.buttons.2" } }
        Wire { from: "%surface%.buttons.3";     to: TogglePropertyAdapter { path: "app.traktor.midi.buttons.3" } }
        Wire { from: "%surface%.buttons.4";     to: TogglePropertyAdapter { path: "app.traktor.midi.buttons.4" } }

        Wire { from: "%surface%.knobs.1";       to: RelativePropertyAdapter { path: "app.traktor.midi.knobs.1" } }
        Wire { from: "%surface%.knobs.2";       to: RelativePropertyAdapter { path: "app.traktor.midi.knobs.2" } }
        Wire { from: "%surface%.knobs.3";       to: RelativePropertyAdapter { path: "app.traktor.midi.knobs.3" } }
        Wire { from: "%surface%.knobs.4";       to: RelativePropertyAdapter { path: "app.traktor.midi.knobs.4" } }
      }
    }

    WiresGroup
    {
      enabled: decksAssignment == DecksAssignment.BD

      WiresGroup
      {
        enabled: !hasBottomControls(deckBType) && !hasBottomControls(deckDType)

        Wire { from: "%surface%.faders.1";       to: DirectPropertyAdapter { path: "app.traktor.midi.faders.5" } }
        Wire { from: "%surface%.faders.2";       to: DirectPropertyAdapter { path: "app.traktor.midi.faders.6" } }
        Wire { from: "%surface%.faders.3";       to: DirectPropertyAdapter { path: "app.traktor.midi.faders.7" } }
        Wire { from: "%surface%.faders.4";       to: DirectPropertyAdapter { path: "app.traktor.midi.faders.8" } }
      }

      WiresGroup
      {
        enabled: (module.screenView.value == ScreenView.deck) && !isInEditMode && (footerPage.value == FooterPage.midi)

        Wire { from: "%surface%.buttons.1";     to: TogglePropertyAdapter { path: "app.traktor.midi.buttons.5" } }
        Wire { from: "%surface%.buttons.2";     to: TogglePropertyAdapter { path: "app.traktor.midi.buttons.6" } }
        Wire { from: "%surface%.buttons.3";     to: TogglePropertyAdapter { path: "app.traktor.midi.buttons.7" } }
        Wire { from: "%surface%.buttons.4";     to: TogglePropertyAdapter { path: "app.traktor.midi.buttons.8" } }

        Wire { from: "%surface%.knobs.1";       to: RelativePropertyAdapter { path: "app.traktor.midi.knobs.5" } }
        Wire { from: "%surface%.knobs.2";       to: RelativePropertyAdapter { path: "app.traktor.midi.knobs.6" } }
        Wire { from: "%surface%.knobs.3";       to: RelativePropertyAdapter { path: "app.traktor.midi.knobs.7" } }
        Wire { from: "%surface%.knobs.4";       to: RelativePropertyAdapter { path: "app.traktor.midi.knobs.8" } }
      }
    }
  }

  
}
