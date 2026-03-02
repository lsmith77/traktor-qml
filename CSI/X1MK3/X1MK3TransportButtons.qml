import CSI 1.0
import QtQuick 2.12

Module
{
  id: module
  property bool shift: false
  property bool active: false
  property bool syncModifier: false
  property int deckIdx: 0
  property string surface: ""

  property int nudgePushAction: 0
  property int nudgeShiftPushAction: 0

  // Nudge buttons actions
  readonly property int nudgeTempoBend:            0
  readonly property int nudgeBeatjump:             1
  readonly property int nudgeTriggerHotcue_56:     2
  readonly property int nudgeDeleteHotcue_56:      3

  TransportSection
  {
    name: "transport"
    channel: module.deckIdx

    // syncColor: Color.Blue
    // fluxColor: Color.Blue
    // masterColor: Color.Blue
    syncColor: Color.Cyan
    fluxColor: Color.Red
    masterColor: Color.Red
  }

  Beatgrid        { name: "beatgrid";   channel: module.deckIdx }
  ButtonBeatjump  { name: "beatjump";   channel: module.deckIdx }
  ButtonTempoBend { name: "tempo_bend"; channel: module.deckIdx }
  Hotcues         { name: "hotcues";    channel: module.deckIdx }

  SwitchTrigger { name: "sync_inverter" }
  SwitchTimer { name: "sync_inverter_timer"; setTimeout: 200 }
  
  function hotcueTypeToLED(hotcueType) {
    if (hotcueType == 0) return Color.Turquoise
    else if (hotcueType == 1) return Color.DarkOrange
    else if (hotcueType == 2) return Color.Red
    else if (hotcueType == 3) return Color.Yellow
    else if (hotcueType == 4) return Color.White
    else if (hotcueType == 5) return Color.Green
    else return Color.Black
  }

  AppProperty { id: activeCuePositionProp; path: "app.traktor.decks." + module.deckIdx + ".track.cue.active.start_pos"; }
  AppProperty { id: playheadPositionProp; path: "app.traktor.decks." + module.deckIdx + ".track.player.playhead_position" }
  AppProperty { id: gridLockedProp; path: "app.traktor.decks." + module.deckIdx + ".track.grid.lock_bpm" }
  AppProperty { id: gridmarkerSetProp; path: "app.traktor.decks." + module.deckIdx + ".track.gridmarker.set" }
  AppProperty { id: gridmarkerDeleteProp; path: "app.traktor.decks." + module.deckIdx + ".track.gridmarker.delete" }
  AppProperty { id: gridTapProp; path: "app.traktor.decks." + module.deckIdx + ".track.grid.tap" }

  AppProperty { id: hotcue5Type; path: "app.traktor.decks." + module.deckIdx + ".track.cue.hotcues.5.type" }
  AppProperty { id: hotcue6Type; path: "app.traktor.decks." + module.deckIdx + ".track.cue.hotcues.6.type" }
  
  readonly property real timeTolerance: 0.001 // seconds
  property bool activeCueWithPlayhead: Math.abs(activeCuePositionProp.value - playheadPositionProp.value) < timeTolerance

  property int tapAvailable: module.shift && !gridLockedProp.value && (deckTypeProp.value == DeckType.Track || deckTypeProp.value == DeckType.Stem)
  property int gridLockAvailable: (deckTypeProp.value == DeckType.Track || deckTypeProp.value == DeckType.Stem)
  property int vinylBreakDurationInitialValue: 300
  property int vinylBreakStep: 100
  property int vinylBreakDuration: vinylBreakDurationInitialValue
  property double adjustedTempobend: stableTempoProp.value < 1 ? stableTempoProp.value : 1

  Timer {
    id: vinylBreakTrigger_countdown
    interval: 200
    repeat: false
    running: false;
    onTriggered: {
      vinylBreakDuration = vinylBreakDurationInitialValue
      vinylBreakLength_countdown.restart()
    }
  }

  Timer {
    id: vinylBreakLength_countdown
    interval: 50 // 300
    repeat: true
    running: false;
    onTriggered: {
      if (vinylBreakDuration < 4000) {
        vinylBreakDuration = vinylBreakDuration + vinylBreakStep
      }
    }
  }

  Timer {
    id: vinylBreak_countdown
    interval: (vinylBreakDuration/30) / adjustedTempobend
    repeat: true
    running: false;
    onTriggered: {
      if (tempoBendSteplessProp.value < 0.05) {
        vinylBreak_countdown.stop()
        vinylBreakProp.value = false
        tempoBendSteplessProp.value = 0
        resetSyncKeylock()
      }
      else tempoBendSteplessProp.value = tempoBendSteplessProp.value - 0.04
    }
  }

  ButtonScriptAdapter {
    // name: "VinylBreakTap"
    // name: "VinylBreakGridLock"
    name: "VinylBreak"
    // color: tapAvailable ? Color.White : Color.Green;
    // color: module.shift && module.gridLockAvailable ? Color.White : Color.Green;
    color: Color.Green;
    brightness: deckPlayingProp.value
    // brightness: (deckPlayingProp.value && !playBlinkerCueingTimer.running) ? 1.0 : playBlinkerCueingTimer.running ? playBlinkerCueingTimer.blink : !playBlinkerStoppedTimer.blink
    // brightness: (module.shift && module.gridLockAvailable) ? gridLockedProp.value : deckPlayingProp.value
    onPress: {
      // brightness = deckPlayingProp.value
      // if (tapAvailable) {
        // gridTapProp.value = !gridTapProp.value
      // }
      // if (module.shift && module.gridLockAvailable) {
        // gridLockedProp.value = !gridLockedProp.value
      // }
      // else {
        if (deckPlayingProp.value) {
          vinylBreakTrigger_countdown.restart()
        }
        else {
          deckPlayingProp.value = true
          vinylBreakProp.value = false
          tempoBendSteplessProp.value = 0
          if (vinylBreak_countdown.running) {
            vinylBreak_countdown.stop()
            resetSyncKeylock()
          }
        }
      // }
    }
    onRelease: {
      // brightness = deckPlayingProp.value
      if (vinylBreakTrigger_countdown.running) {
        deckPlayingProp.value = false
        vinylBreakTrigger_countdown.stop()
      }
      else if (vinylBreakLength_countdown.running) {
        vinylBreakLength_countdown.stop()
        deckPlayingProp.value = false
        disableSyncKeylock()
        vinylBreakProp.value = true
        tempoBendSteplessProp.value = adjustedTempobend
        vinylBreak_countdown.restart()
      }
    }
  }
  
  AppProperty { id: cueBlinkerToggleProp; path: "app.traktor.decks.1.remix.players." + module.deckIdx + ".sequencer.steps.1"; }
  AppProperty { id: playBlinkerToggleProp; path: "app.traktor.decks.1.remix.players." + module.deckIdx + ".sequencer.steps.2"; }
// Cue Blinker and Play Blinker

  Timer {
    id: playBlinkerStoppedTimer
    property bool blink: false
    interval: 500 * masterClockTempoMultiplierProp.value
    repeat: true
    running: (deckIsLoaded.value || deckTypeProp.value == DeckType.Remix) && !deckPlayingProp.value && !deckCueingProp.value && !tempoBendSteplessProp.value && !vinylBreakProp.value && !vinylBreakLength_countdown.running
    onTriggered: {
      blink = !blink;
      playBlinkerToggleProp.value = blink;
    }
    onRunningChanged: {
      blink = running
      playBlinkerToggleProp.value = running;
    }
  }

  Timer {
    id: playBlinkerCueingTimer
    property bool blink: false
    interval: 125 * masterClockTempoMultiplierProp.value
    repeat: true
    running: (deckIsLoaded.value || deckTypeProp.value == DeckType.Remix) && (deckCueingProp.value || tempoBendDiscreteProp.value || tempoBendSteplessProp.value || vinylBreakProp.value || vinylBreakLength_countdown.running)
    onTriggered: {
      blink = !blink;
      playBlinkerToggleProp.value = blink;
    }
    onRunningChanged: {
      blink = running
      playBlinkerToggleProp.value = running;
    }
  }

  Timer {
    id: cueBlinkerTimer
    property bool blink: false
    interval: 250 * masterClockTempoMultiplierProp.value
    repeat: true
    running: deckIsLoaded.value && !(deckTypeProp.value == DeckType.Remix) && !deckPlayingProp.value && !activeCueWithPlayhead
    onTriggered: {
      blink = !blink;
      cueBlinkerToggleProp.value = blink;
    }
    onRunningChanged: {
      blink = running
      cueBlinkerToggleProp.value = running;
    }
  }

  WiresGroup
  {
    enabled: module.active

    // Wire {
      // enabled: (deckIsLoaded.value  && !module.syncModifier) || (deckTypeProp.value == DeckType.Remix)
      // from: "%surface%.play";
      // // to: "VinylBreakTap"
      // to: "VinylBreakGridLock"
    // }
    Wire {
      enabled: (deckIsLoaded.value  && !module.syncModifier && !(module.shift && module.gridLockAvailable) ) || (deckTypeProp.value == DeckType.Remix)
      from: "%surface%.play";
      // to: "VinylBreakTap"
      to: "VinylBreak"
    }
    Wire { from: "%surface%.play";
      enabled: (deckIsLoaded.value  && !module.syncModifier && (module.shift && module.gridLockAvailable) ) || (deckTypeProp.value == DeckType.Remix)
      to: ButtonScriptAdapter {
        color: Color.White;
        brightness: gridLockedProp.value;
        onPress: {
          gridLockedProp.value = !gridLockedProp.value;
        }
      }
    }
    
    WiresGroup {
      enabled:  !previousSyncState.value
      Wire { from: "%surface%.sync";       to: "sync_inverter.input"      ; enabled: !module.shift }
      Wire { from: "%surface%.sync";       to: "sync_inverter_timer.input" ; enabled: !module.shift }
      Wire { from: "sync_inverter.output"; to: "transport.sync"           ; enabled: !module.shift }
      Wire { from: "%surface%.sync";       to: "transport.master"         ; enabled:  module.shift }
    }

    Wire {
      enabled: previousSyncState.value && !syncProp.value;
      from: "%surface%.sync";
      to: ButtonScriptAdapter {
        color: Color.Red;
        brightness: previousSyncState.value;
      }
    }

    Wire {
      enabled: !module.shift
      from: Or
      {
        inputs:
        [
          "sync_inverter_timer.output",
          "%surface%.loop.push",
          "%surface%.loop.is_turned"
        ]
      }
      to: "sync_inverter.reset"
    }

    // Wire { from: "%surface%.rev";       to: "transport.flux_reverse"    ; enabled: !module.shift }
    // Wire { from: "%surface%.rev";       to: "transport.flux"            ; enabled:  module.shift }
    
    Wire { from: "%surface%.rev";to: "transport.flux_reverse"; enabled: !module.shift && !module.syncModifier }
    Wire { from: "%surface%.rev";to: "transport.flux"; enabled:  module.shift && !module.syncModifier }
    
    // Wire { from: "%surface%.cue";       to: "transport.cue"             ; enabled: !module.shift }
    // Wire { from: "%surface%.cue";       to: "transport.return_to_zero"  ; enabled:  module.shift }

    WiresGroup {
      // enabled: (deckIsLoaded.value || deckTypeProp.value == DeckType.Remix)
      enabled: (deckIsLoaded.value || deckTypeProp.value == DeckType.Remix) && !module.syncModifier
      Wire { enabled: !module.shift && !customCueAndPlayProp.value; from: "%surface%.cue"; to: ButtonScriptAdapter { color: Color.Yellow; brightness: activeCueWithPlayhead; onPress: { deckCueingProp.value = true } onRelease: { deckCueingProp.value = false } } }
      Wire { enabled: !module.shift && customCueAndPlayProp.value; from: "%surface%.cue"; to: ButtonScriptAdapter { color: Color.Yellow; brightness: activeCueWithPlayhead; onPress: { deckCueAndPlayProp.value = true } onRelease: { deckCueAndPlayProp.value = false } } }
      Wire { enabled: !module.shift && deckPlayingProp.value; from: "%surface%.cue"; to: ButtonScriptAdapter { color: Color.Yellow; brightness: activeCueWithPlayhead && !(deckTypeProp.value == DeckType.Remix); } }
      Wire { enabled: !module.shift && !deckPlayingProp.value; from: "%surface%.cue.led"; to: "CueBlinker" }
      // Wire { enabled: !module.shift; from: "%surface%.cue"; to: ButtonScriptAdapter { color: Color.Yellow; brightness: !cueBlinkerTimer.blink && !deckPlayingProp.value; onPress: { deckCueingProp.value = true } onRelease: { deckCueingProp.value = false } } }
      Wire { enabled: module.shift; from: "%surface%.cue"; to: ButtonScriptAdapter { color: Color.Yellow; brightness: 0.0; onPress: { deckSeekProp.value = 0; brightness = 1.0 } onRelease: { brightness = 0.0 } } }
    }
    
    WiresGroup {
      enabled: deckIsLoaded.value && module.syncModifier && module.gridLockAvailable && !gridLockedProp.value

      // Wire { from: "%surface%.cue"; to: TriggerPropertyAdapter { path: "app.traktor.decks." + module.deckIdx + ".track.gridmarker.set" } }
      Wire { from: "%surface%.cue"; to: ButtonScriptAdapter { color: Color.Turquoise; brightness: 0.0; onPress: { gridmarkerSetProp.value = !gridmarkerSetProp.value; brightness = 1.0 } onRelease: { brightness = 0.0 } } }
      
      // Wire { from: "%surface%.rev"; to: TriggerPropertyAdapter { path: "app.traktor.decks." + module.deckIdx + ".track.gridmarker.delete" } }
      Wire { from: "%surface%.rev"; to: ButtonScriptAdapter { color: Color.Red; brightness: 0.0; onPress: { gridmarkerDeleteProp.value = !gridmarkerDeleteProp.value; brightness = 1.0 } onRelease: { brightness = 0.0 } } }
      
      // Wire { from: "%surface%.play"; to: TriggerPropertyAdapter { path: "app.traktor.decks." + module.deckIdx + ".track.grid.tap" } }
      Wire { from: "%surface%.play"; to: ButtonScriptAdapter { color: Color.White; brightness: 0.0; onPress: { gridTapProp.value = !gridTapProp.value; brightness = 1.0 } onRelease: { brightness = 0.0 } } }

    }

    WiresGroup
    {
      // enabled: (!module.shift && nudgePushAction == nudgeTempoBend) || (module.shift && nudgeShiftPushAction == nudgeTempoBend)
      enabled: (!module.shift && nudgePushAction == nudgeTempoBend) || (module.shift && nudgeShiftPushAction == nudgeTempoBend) || (module.syncModifier)

      Wire { from: "%surface%.nudge_slow"; to: "tempo_bend.down" }
      Wire { from: "%surface%.nudge_fast"; to: "tempo_bend.up"   }
    }

    WiresGroup
    {
      // enabled: !module.shift && (nudgePushAction == nudgeBeatjump)
      enabled: !module.shift && (nudgePushAction == nudgeBeatjump) && !module.syncModifier

      Wire { from: DirectPropertyAdapter { path: "mapping.settings.nudge_push_size"; input: false } to: "beatjump.size" }

      Wire { from: "%surface%.nudge_slow"; to: "beatjump.backward" }
      Wire { from: "%surface%.nudge_fast"; to: "beatjump.forward"  }
    }

    WiresGroup
    {
      // enabled: !module.shift && (nudgePushAction == nudgeTriggerHotcue_56)
      enabled: !module.shift && (nudgePushAction == nudgeTriggerHotcue_56) && !module.syncModifier

      // Wire { from: "%surface%.nudge_slow"; to: "hotcues.5.trigger" }
      // Wire { from: "%surface%.nudge_fast"; to: "hotcues.6.trigger" }
      Wire { from: "%surface%.nudge_slow"; to: HoldPropertyAdapter { path: "app.traktor.decks." + module.deckIdx + ".track.cue.select_or_set_hotcue"; value: 4; color: hotcueTypeToLED(hotcue5Type.value) } }
      Wire { from: "%surface%.nudge_fast"; to: HoldPropertyAdapter { path: "app.traktor.decks." + module.deckIdx + ".track.cue.select_or_set_hotcue"; value: 5; color: hotcueTypeToLED(hotcue6Type.value) } }
    }

    WiresGroup
    {
      // enabled: module.shift && (nudgeShiftPushAction == nudgeBeatjump)
      enabled: module.shift && (nudgeShiftPushAction == nudgeBeatjump) && !module.syncModifier

      Wire { from: DirectPropertyAdapter { path: "mapping.settings.nudge_shiftpush_size"; input: false } to: "beatjump.size" }

      Wire { from: "%surface%.nudge_slow"; to: "beatjump.backward" }
      Wire { from: "%surface%.nudge_fast"; to: "beatjump.forward"  }
    }

    WiresGroup
    {
      // enabled: module.shift && (nudgeShiftPushAction == nudgeDeleteHotcue_56)
      enabled: module.shift && (nudgeShiftPushAction == nudgeDeleteHotcue_56) && !module.syncModifier

      // Wire { from: "%surface%.nudge_slow"; to: "hotcues.5.delete" }
      // Wire { from: "%surface%.nudge_fast"; to: "hotcues.6.delete" }
      Wire { from: "%surface%.nudge_slow"; to: HoldPropertyAdapter { path: "app.traktor.decks." + module.deckIdx + ".track.cue.delete_hotcue"; value: 4; color: hotcueTypeToLED(hotcue5Type.value) } }
      Wire { from: "%surface%.nudge_fast"; to: HoldPropertyAdapter { path: "app.traktor.decks." + module.deckIdx + ".track.cue.delete_hotcue"; value: 5; color: hotcueTypeToLED(hotcue6Type.value) } }
    }
  }
  
  //Play should BLINK When Deck is Loaded & Paused or warn when Cueing but not playing
  Wire { from: "%surface%.play.led"; to: "PlayBlinkerStopped"; enabled: module.active && (deckIsLoaded.value || deckTypeProp.value == DeckType.Remix) && !module.syncModifier }
  Wire { from: "PlayBlinkerStopped.trigger"; to: ExpressionAdapter { type: ExpressionAdapter.Boolean; expression: module.active && !deckPlayingProp.value && (!deckCueingProp.value || (deckCueingProp.value && !deckRunningProp.value)) && (!tempoBendSteplessProp.value) && (!vinylBreakProp.value) && (deckIsLoaded.value || deckTypeProp.value == DeckType.Remix) && !(module.shift && module.gridLockAvailable) } }
  Blinker { name: "PlayBlinkerStopped"; cycle: 1000 * masterClockTempoMultiplierProp.value; color: Color.Green; defaultBrightness: 1.0; blinkBrightness: 0.0 }
  Wire { from: "%surface%.play.led"; to: "PlayBlinkerCueing"; enabled: module.active && (deckIsLoaded.value || deckTypeProp.value == DeckType.Remix) && !module.syncModifier }
  Wire { from: "PlayBlinkerCueing.trigger"; to: ExpressionAdapter { type: ExpressionAdapter.Boolean; expression: module.active && !deckPlayingProp.value && deckCueingProp.value && deckRunningProp.value && (deckIsLoaded.value || deckTypeProp.value == DeckType.Remix) && !(module.shift && module.gridLockAvailable) } }
  Wire { from: "PlayBlinkerCueing.trigger"; to: ExpressionAdapter { type: ExpressionAdapter.Boolean; expression: module.active && ((!deckPlayingProp.value && deckCueingProp.value && deckRunningProp.value) || (tempoBendDiscreteProp.value) || (tempoBendSteplessProp.value) || (vinylBreakProp.value) || (vinylBreakLength_countdown.running)) && (deckIsLoaded.value || deckTypeProp.value == DeckType.Remix) && !(module.shift && module.gridLockAvailable) } }
  Blinker { name: "PlayBlinkerCueing"; cycle: 250 * masterClockTempoMultiplierProp.value; color: Color.Green; defaultBrightness: 1.0; blinkBrightness: 0.0 }

  //Cue should BLINK when deck is Stopped and not in the Active Cue
  Blinker { name: "CueBlinker"; cycle: 500 * masterClockTempoMultiplierProp.value; color: Color.Yellow; defaultBrightness: 1.0; blinkBrightness: 0.0 } //CUE should BLINK when paused and out of Active Cue Position
  Wire { from: "CueBlinker.trigger"; to: ExpressionAdapter { type: ExpressionAdapter.Boolean; expression: !activeCueWithPlayhead } }
  
}
