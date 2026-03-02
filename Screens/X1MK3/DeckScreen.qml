import CSI 1.0
import QtQuick 2.0

import "../Defines" as Defines
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

  readonly property variant deckText: ["A", "B", "C", "D"]
  readonly property variant loopText: ["'32", "'16", "'8", "'4", "'2", "1", "2", "4", "8", "16", "32"]

  readonly property int remainingTimeInfo: 0
  readonly property int elapsedTimeInfo:   1
  readonly property int loopSizeInfo:      2

  MappingProperty { id: deckIdxProp; path: screen.propertiesPath + ".deck_index" }
  property alias deckIdx: deckIdxProp.value

  MappingProperty { id: leftDeckIdxProp; path: "mapping.settings.left_deck_index" }
  property alias leftDeckIdx: leftDeckIdxProp.value

  readonly property bool isLeftScreen: (deckIdx == leftDeckIdx) ? true : false

  MappingProperty { id: showEndWarningProp; path: "mapping.settings.bottom_leds.show_end_warning" }
  
  MappingProperty { id: showLoopSizeProp; path: screen.propertiesPath + ".show_loop_size" }
  property alias showLoopSize: showLoopSizeProp.value

  MappingProperty { id: syncModifierProp; path: screen.propertiesPath + ".sync_modifier" }
  property alias showBPMInfo: syncModifierProp.value

  MappingProperty { id: shiftProp; path: "mapping.state.shift" }
  property alias shift: shiftProp.value
  onShiftChanged: { resetTitle() }

  MappingProperty { id: deviceSetupStateProp; path: "mapping.state.device_setup_state" }
  property alias deviceSetupState: deviceSetupStateProp.value

  MappingProperty { id: deckDisplayMainInfoProp; path: "mapping.settings.deck_display.main_info" }
  property alias deckDisplayMainInfo: deckDisplayMainInfoProp.value

  MappingProperty { id: loopShiftActionProp; path: "mapping.settings.loop_shift_action" }
  property alias loopShiftAction: loopShiftActionProp.value

  Defines.Utils  { id: utils }

  AppProperty { id: deckTypeProp; path: "app.traktor.decks." + deckIdx + ".type" }
  AppProperty { id: deckPlayProp; path: "app.traktor.decks." + deckIdx + ".play"; onValueChanged: resetTitle() }
  AppProperty { id: trackTitleProp; path: "app.traktor.decks." + deckIdx + ".content.title"; onValueChanged: resetTitle() }
  AppProperty { id: trackLengthProp; path: "app.traktor.decks." + deckIdx + ".track.content.track_length" }
  AppProperty { id: elapsedTimeProp; path: "app.traktor.decks." + deckIdx + ".track.player.elapsed_time"  }
  AppProperty { id: trackEndWarningProp; path: "app.traktor.decks." + deckIdx + ".track.track_end_warning" }

  property bool isRemixDeck: (deckTypeProp.value === DeckType.Remix)

  AppProperty { id: remixQuantProp; path: "app.traktor.decks." + deckIdx + ".remix.quant" }
  property bool remixQuantActive: remixQuantProp.value

  AppProperty { id: remixQuantIndexProp; path: "app.traktor.decks." + deckIdx + ".remix.quant_index" }
  readonly property string remixQuantIndexString: remixQuantIndexProp.description
  
  AppProperty { id: remixBeatPosProp; path: "app.traktor.decks." + deckIdx + ".remix.current_beat_pos" }
  
  AppProperty { id: remixCaptureSourceProp; path: "app.traktor.decks." + deckIdx + ".capture_source"  }
  readonly property string remixCaptureSourceString: remixCaptureSourceProp.description
  
  MappingProperty { id: quantizeEngagedProp; path: screen.propertiesPath + "." + deckIdx + ".quantize_engaged" }
  property alias quantizeEngaged: quantizeEngagedProp.value

  AppProperty { id: trackBPMProp; path: "app.traktor.decks." + deckIdx + ".tempo.base_bpm" }

  AppProperty { id: nextCuePointProp; path: "app.traktor.decks." + deckIdx + ".track.player.next_cue_point" }
  AppProperty { id: gridOffsetProp; path: "app.traktor.decks." + deckIdx + ".content.grid_offset" }
  readonly property double cuePos: (nextCuePointProp.value >= 0) ? nextCuePointProp.value : trackLengthProp.value * 1000
  readonly property string beatsToCue: computeBarsBeatsFromPosition(((elapsedTimeProp.value * 1000 - cuePos) * trackBPMProp.value) / 60000.0)
  readonly property string beats: computeBarsBeatsFromPosition(((elapsedTimeProp.value * 1000 - gridOffsetProp.value) * trackBPMProp.value) / 60000.0)
  // readonly property string remixBeatPositionString: " " + remixBeatPosProp.description
  readonly property string remixBeats: computeBarsBeatsFromPosition(remixBeatPosProp.value)

  AppProperty { id: loopSizeProp; path: "app.traktor.decks." + deckIdx + ".loop.size" }
  AppProperty { id: loopActiveProp; path: "app.traktor.decks." + deckIdx + ".loop.active" }

  AppProperty { id: tempoBpmProp; path: "app.traktor.decks." + deckIdx + ".tempo.adjust_bpm" }

  AppProperty { id: keyAdjustProp; path: "app.traktor.decks." + deckIdx + ".track.key.adjust" }
  AppProperty { id: keyLockProp; path: "app.traktor.decks." + deckIdx + ".track.key.lock_enabled" }
  readonly property string  keyAdjustText: keyLockProp.value ? (keyAdjustProp.value < 0 ? "" : "+") + (keyAdjustProp.value * 12).toFixed(0).toString() : ""
  AppProperty { id: resultingKeyProp; path: "app.traktor.decks." + deckIdx + ".track.key.resulting.quantized" }

  readonly property bool isLoaded: (trackLengthProp.value > 0) || (deckTypeProp.value === DeckType.Remix)
  readonly property string remainingTime: " " + isLoaded ? utils.computeRemainingTimeString(trackLengthProp.value, elapsedTimeProp.value) : "00:00"
  readonly property string elapsedTime: " " + isLoaded ? utils.convertToTimeString(elapsedTimeProp.value) : "00:00"

  // Loop encoder actions
  readonly property int beatjump_loop:      0
  readonly property int key_adjust:         1

  MappingProperty { id: blinkerProp; path: "mapping.state.blinker" }
  property alias blinkOnOff: blinkerProp.value

  MappingProperty { id: customBeatCounterEngagedProp; path: "mapping.settings.custom_beatcounter_engaged" }
  property alias customBeatCounterEngaged: customBeatCounterEngagedProp.value
  MappingProperty { id: customBeatCounterPhraseLengthProp; path: "mapping.settings.custom_phrase_length" }
  property alias customBeatCounterPhraseLength: customBeatCounterPhraseLengthProp.value

  MappingProperty { id: browserModeProp; path: "mapping.state.browser_mode" }
  MappingProperty { id: customBrowserModeProp; path: "mapping.settings.custom_browser_mode" }
  // AppProperty { id: browserFullScreen; path:"app.traktor.browser.full_screen" }
  AppProperty { id: previewLengthProp; path: "app.traktor.browser.preview_content.track_length" }
  AppProperty { id: previewElapsedTimeProp; path: "app.traktor.browser.preview_player.elapsed_time"  }
  AppProperty { id: previewDeckLoadedProp; path: "app.traktor.browser.preview_player.is_loaded"  }
  AppProperty { id: previewDeckPlayingProp; path: "app.traktor.browser.preview_player.play"  }

  AppProperty { id: deckLoadedSignal; path: "app.traktor.decks." + deckIdx + ".is_loaded_signal"; onValueChanged: resetTitle() }
  
  function resetTitle() {
    myText.x = 0;
    myText.text = trackTitleProp.value;
    startTimer.restart();
    scrollTimer.stop();
    endTimer1.stop();
    endTimer2.stop();
  }
//----------------------------------------------------------------------------------------------------------

  function computeBarsBeatsFromPosition(beat) {    
    var phraseLen   = Math.pow (2, customBeatCounterPhraseLength) // 8 // 4
    var rawInt      = parseInt(beat+0.0001); //value 0.0001 to counter rounding error offset
    var prefix      = (beat < 0) ? "-" : " ";    
    var absBeats    = Math.abs(rawInt);
    var phrases     = parseInt(absBeats / (phraseLen * 4) ) + 1;
    var bars        = parseInt((absBeats / 4) % phraseLen) + 1;
    var phrasesBars = (customBeatCounterPhraseLength == 0) ? phrases + "." : phrases + "." + bars + "."
    var beatInBar   = parseInt(absBeats % 4) + 1;
    // var nearestBeat = Math.abs(Math.round(beat));
    // var phrases     = parseInt(nearestBeat / (phraseLen * 4) ) + 1; 
    // var bars        = parseInt((nearestBeat / 4) % phraseLen) + 1;
    // var beatInBar   = parseInt(nearestBeat % 4) + 1;
    return prefix + phrasesBars + beatInBar;
  }

  // function computeBarsBeatsFromPosition(beat) {    
    // var prefix      = (beat < 0) ? "-" : " ";
    // var phrasesBars = (customBeatCounterPhraseLength == 0) ? phrases + "." : phrases + "." + bars + "."
    // var phraseLen   = Math.pow (2, customBeatCounterPhraseLength) // 8 // 4
    // var rawInt      = parseInt(beat+0.0001); //value 0.0001 to counter rounding error offset
    // var absBeats    = Math.abs(rawInt);
    // var phrases     = parseInt(absBeats / (phraseLen * 4) ) + 1;
    // var bars        = parseInt((absBeats / 4) % phraseLen) + 1;
    // var beatInBar   = parseInt(absBeats % 4) + 1;
    // return prefix + phrasesBars + beatInBar;
  // }
  
  // function computeBarsBeatsFromPosition(beat) {    
      // var sign = (beat < 0) ? "-" : "";
      // var nearestBeat = Math.abs(Math.round(beat));
      // var bars = Math.ceil(nearestBeat / 4);
      // var beatInBar = (nearestBeat - 1) % 4 + 1;
      // return sign + bars + "." + beatInBar;          
// }

  //----------------------------------------------------------------------------------------------------------
  Rectangle {
    color: "black"
    anchors.fill: parent

    // Track/Stem/Remix Deck
    Item
    {
      visible: (deviceSetupState == DeviceSetupState.assigned) && (deckTypeProp.value != DeckType.Live)
      anchors.fill: parent

      Item
      {
        // visible: !showLoopSize && !showBPMInfo
        visible: !showLoopSize && !showBPMInfo && !browserModeProp.value
        anchors.fill: parent

        // Track title

/*
        // pixel style chop work. thank you buddy. nice and clean.
        
        // Defines the space at the end of the track title (for animation effects)
        property string trackTitleSpace: "    "

        // Removes non-ASCII characters (e.g., special characters) from the title and appends space
        property string trackTitleExpanded: trackTitleProp.value.replace(/[^\x00-\x7F]/g, '') + trackTitleSpace

        // Defines the visible text output by "cutting" the title in a cyclic manner
        property string titleRoundEnd: trackTitleExpanded.substring(step)
        property string showCutTitle: titleRoundEnd + trackTitleExpanded.substring(0, step)

        // Defines the step (offset) for the title cut (this will be updated in the timers)
        property int step: 0

        // Timer that is triggered after 2000ms (2 seconds) and checks if the track title is long enough
        // to start the animation
        Timer {
            id: startTimer
            interval: 3000         // Interval of 3 seconds
            repeat: false          // Trigger only once
            running: false         // Timer is not running yet
            onTriggered: if (parent.trackTitleExpanded.length > (parent.trackTitleSpace.length + 16)) cutTrackTitle.restart()
            // If the track title is longer than the space plus 16 characters, the timer to "cut" the title starts
        }

        // Timer that is triggered every 160ms to display the title in a "scrolling" manner
        Timer {
            id: cutTrackTitle
            interval: 120          // Interval of 120ms for the animation
            repeat: true           // Repeats continuously
            running: false         // Timer is not running yet
            onTriggered: {
              parent.step = ++parent.step % parent.trackTitleExpanded.length;
              if (parent.trackTitleExpanded.length == parent.titleRoundEnd.length) {
                cutTrackTitle.stop()
                startTimer.restart()
              }
            } // Increases the step (offset) by 1 and ensures it starts over at 0 before and after a short break when it reaches the end of the title
            
            onRunningChanged: parent.step = 0
            // When the timer stops, the step is reset to 0
        }

        // Loads a monospace font (Roboto Mono, bold) for displaying the title
        FontLoader {
            id: monospace
            source: "../Fonts/RobotoMono-Bold.ttf" // Path to the monospace font
        }

        // The Text element that displays the "cut" track title
        ThickText {
            visible: !shift
            
            font.family: monospace.name  // Sets the font to the loaded monospace font
            font.pixelSize: 12           // Sets the font size to 12 pixels
            
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                topMargin: 0
                leftMargin: 1
            }
            
            text: parent.showCutTitle    // The text displayed is the "cut" track title
        }
*/

        Timer {
            id: startTimer
            interval: 3000       
            repeat: false         
            running: false       
            onTriggered: {
                if (parent.width < myText.width) {
                    scrollTimer.restart();
                }
            }
        }

        Timer {
            id: scrollTimer
            interval: 17
            running: false
            repeat: true
            onTriggered: {
                --myText.x;
                if (myText.x + myText.width <= parent.width - 1) {
                    endTimer1.restart()
                    scrollTimer.stop()
                }
            }
        }

        Timer {
            id: endTimer1
            interval: 2000       
            repeat: false         
            running: false       
            onTriggered: {
                myText.x = 0;
                // myText.text = "";
                endTimer2.restart();
            }
        }

        Timer {
            id: endTimer2
            interval: 200       
            repeat: false         
            running: false       
            onTriggered: {
                // myText.text = trackTitleProp.value;
                startTimer.restart();
            }
        }

        // ThickText {
        ThinText {
            visible: !shift && !endTimer2.running
            x: 0
            
            id: myText
            text: trackTitleProp.value
            font.family: "Helvetica"
            font.pixelSize: 12
            // font.pixelSize: 16
            font.bold: true
            anchors {
                top: parent.top
                topMargin: 0
                leftMargin: 2
            }
        }
        
        // ThickText {
            // visible: !shift

            // anchors {
                // top: parent.top
                // left: parent.left
                // right: parent.right
                // topMargin: 0
                // leftMargin: 1
            // }
            // text: trackTitleProp.value
        // }

        // Remaining/Elapsed Time
        ThinText {
            visible: (deckDisplayMainInfo != loopSizeInfo) && !shift && !customBeatCounterEngaged && !isRemixDeck

            anchors {
                top: parent.top
                left: parent.left
                // leftMargin: -13
                leftMargin: 0
                topMargin: 19
            }
            font.family: "Helvetica"
            // font.pixelSize: 32
            font.pixelSize: 28
            font.capitalization: Font.AllUppercase
            text: "" + (deckDisplayMainInfo == elapsedTimeInfo ? elapsedTime : remainingTime)
            color: !trackEndWarningProp.value || screen.blinkOnOff ? "white" : "black"
        }

        // Remaining/Elapsed [Phrases].[Bars].[Beats]
        ThinText {
            visible: (deckDisplayMainInfo != loopSizeInfo) && !shift && customBeatCounterEngaged && !isRemixDeck

            anchors {
                top: parent.top
                left: parent.left
                // leftMargin: -13
                leftMargin: 0
                topMargin: 19
            }
            font.family: "Helvetica"
            // font.pixelSize: 32
            font.pixelSize: 28
            font.capitalization: Font.AllUppercase
            // text: "" + (deckDisplayMainInfo == elapsedTimeInfo ? elapsedTime : beatsToCue)
            text: "" + (deckDisplayMainInfo == elapsedTimeInfo ? beats : beatsToCue)
            color: !trackEndWarningProp.value || screen.blinkOnOff ? "white" : "black"
        }

        // Remix Deck Beat Counter
        ThinText {
            visible: (deckDisplayMainInfo != loopSizeInfo) && !shift && isRemixDeck

            anchors {
                top: parent.top
                left: parent.left
                // leftMargin: -13
                leftMargin: 0
                topMargin: 19
            }
            font.family: "Helvetica"
            // font.pixelSize: 32
            font.pixelSize: 28
            font.capitalization: Font.AllUppercase
            // text: "" + remixBeatPositionString
            text: "" + remixBeats
            color: !trackEndWarningProp.value || screen.blinkOnOff ? "white" : "black"
        }

        // [SHIFT] Remaining time
        ThinText {
            visible: shift && customBeatCounterEngaged && !isRemixDeck && (customBrowserModeProp.value || (!customBrowserModeProp.value && (loopShiftAction == key_adjust) ) )

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                topMargin: 0
                leftMargin: 1
            }
            font.family: "Helvetica"
            font.pixelSize: 16
            font.capitalization: Font.AllUppercase
            text: "" + (deckDisplayMainInfo == elapsedTimeInfo ? elapsedTime : remainingTime)
        }

        // Loop headline
        ThickText {
            // visible: shift && loopShiftAction == beatjump_loop
            // visible: false
            visible: shift && !customBrowserModeProp.value && (loopShiftAction == beatjump_loop)

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                topMargin: 0
                leftMargin: 1
            }
            text: loopActiveProp.value ? "LOOP MOVE" : "BEATJUMP"
        }

        // Loop size (big)
        Rectangle {
          // visible: (deckDisplayMainInfo == loopSizeInfo) || (shift && loopShiftAction == beatjump_loop)
          // visible: (deckDisplayMainInfo == loopSizeInfo)
          visible: (deckDisplayMainInfo == loopSizeInfo) || ( shift && !customBrowserModeProp.value && (loopShiftAction == beatjump_loop) )

          anchors {
              top: parent.top
              left: parent.left
              leftMargin: -13
              topMargin: 20
          }
          width: 85
          height: 35
          color: loopActiveProp.value ? "white" : "black"

          ThinText {
              anchors.fill: parent 
              font.pixelSize: 48
              font.capitalization: Font.AllUppercase
              horizontalAlignment: Text.AlignHCenter

              text: " " + screen.loopText[loopSizeProp.value]
              color: loopActiveProp.value ? "black" : "white"
          }
        }

        // Capture Source / Quantization
        ThickText {
            visible: shift && isRemixDeck && ( ((loopShiftAction == key_adjust) && !customBrowserModeProp.value ) || (customBrowserModeProp.value && !browserModeProp.value) )

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                topMargin: 0
                leftMargin: 1
            }
            text: quantizeEngaged ? "QUANT" : "SOURCE"
        }

        // Quantize (small)
        Rectangle {
          visible: shift && isRemixDeck && !quantizeEngaged && ( ((loopShiftAction == key_adjust) && !customBrowserModeProp.value ) || (customBrowserModeProp.value && !browserModeProp.value) )

          color: "black"
          anchors {
            top: parent.top
            right: parent.right

            rightMargin: 0
            topMargin: 13 // 14
          }
          width: 32
          height: 19

          ThinText {
              anchors.fill: parent
              anchors.rightMargin: 7
              font.pixelSize: 24
              font.capitalization: Font.AllUppercase
              horizontalAlignment: Text.AlignHCenter

              // text: " Q.I"
              text: " QNT"
              color: "white"
          }
        }

        // Quantize Index (small)
        Rectangle {
          visible: shift && isRemixDeck && !quantizeEngaged && ( ((loopShiftAction == key_adjust) && !customBrowserModeProp.value ) || (customBrowserModeProp.value && !browserModeProp.value) )

          color: remixQuantActive ? "white" : "black"
          anchors {
            top: parent.top
            right: parent.right

            rightMargin: 0
            topMargin: 35
          }
          width: 32
          height: 19

          ThinText {
              anchors.fill: parent
              anchors.rightMargin: 7
              font.pixelSize: 24
              font.capitalization: Font.AllUppercase
              horizontalAlignment: Text.AlignHCenter

              text: " " + remixQuantIndexString
              color: remixQuantActive ? "black" : "white"
          }
        }

        // Capture Source (big)
        Rectangle {
          visible: shift && isRemixDeck && !quantizeEngaged && ( ((loopShiftAction == key_adjust) && !customBrowserModeProp.value ) || (customBrowserModeProp.value && !browserModeProp.value) )

          anchors {
            top: parent.top
            left: parent.left
            // leftMargin: -13
            leftMargin: 2
            topMargin: 20
          }
          width: 85
          height: 35
          color: "black"

          ThinText {
            anchors.fill: parent 
            // font.pixelSize: 48
            font.pixelSize: 24
            font.capitalization: Font.AllUppercase
            horizontalAlignment: Text.AlignHCenter

            // text: " " + screen.loopText[loopSizeProp.value]
            text: " " + remixCaptureSourceString
            color: "white"
          }
        }

        // Quantize Index (Big)
        Rectangle {
          visible: shift && isRemixDeck && quantizeEngaged && ( ((loopShiftAction == key_adjust) && !customBrowserModeProp.value ) || (customBrowserModeProp.value && !browserModeProp.value) )

          anchors {
            top: parent.top
            left: parent.left
            leftMargin: -13
            // leftMargin: 0
            topMargin: 20
          }
          width: 85
          height: 35
          color: remixQuantActive ? "white" : "black"

          ThinText {
            anchors.fill: parent 
            // font.pixelSize: 48
            font.pixelSize: 40
            font.capitalization: Font.AllUppercase
            horizontalAlignment: Text.AlignHCenter

            // text: " " + screen.loopText[loopSizeProp.value]
            text: " " + remixQuantIndexString
            color: remixQuantActive ? "black" : "white"
          }
        }

        // Resulting key (big)
        Rectangle {
          // visible: shift && (loopShiftAction == key_adjust)
          // visible: shift
          // visible: shift && (customBrowserModeProp.value || (!customBrowserModeProp.value && (loopShiftAction == key_adjust) ) )
          visible: shift && !isRemixDeck && (customBrowserModeProp.value || (!customBrowserModeProp.value && (loopShiftAction == key_adjust) ) )

          anchors {
            top: parent.top
            left: parent.left
            leftMargin: -13
            topMargin: 20
          }
          width: 85
          height: 35
          color: "black"

          ThinText {
            anchors.fill: parent 
            font.pixelSize: 48
            horizontalAlignment: Text.AlignHCenter

            text: " " + resultingKeyProp.value
            color: "white"
          }
        }

        // Key offset
        Rectangle {
          // visible: shift && (loopShiftAction == key_adjust)
          // visible: shift
          // visible: shift && (customBrowserModeProp.value || (!customBrowserModeProp.value && (loopShiftAction == key_adjust) ) )
          visible: shift && !isRemixDeck && (customBrowserModeProp.value || (!customBrowserModeProp.value && (loopShiftAction == key_adjust) ) )

          color: "black"
          anchors {
            top: parent.top
            right: parent.right

            rightMargin: 0
            topMargin: 35
          }
          width: 32
          height: 19

          ThinText {
              anchors.fill: parent
              anchors.rightMargin: 7
              font.pixelSize: 24
              font.capitalization: Font.AllUppercase
              horizontalAlignment: Text.AlignHCenter

              text: " " + keyAdjustText
              color: "white"
          }
        }
        
        // Loop size (small)
        Rectangle {
          visible: (deckDisplayMainInfo != loopSizeInfo) && !shift

          color: loopActiveProp.value ? "white" : "black"
          anchors {
            top: parent.top
            right: parent.right

            rightMargin: 0
            topMargin: 14 // 18
          }
          width: 32
          height: 19 // 18

          ThinText {
              anchors.fill: parent
              anchors.rightMargin: 7
              font.pixelSize: 24
              font.capitalization: Font.AllUppercase
              horizontalAlignment: Text.AlignHCenter

              text: " " + screen.loopText[loopSizeProp.value]
              color: loopActiveProp.value ? "black" : "white"
          }
        }
        
        // Assigned deck
        Rectangle {
          visible: !shift

          color: deckPlayProp.value ? "white" : "black"
          anchors {
            top: parent.top
            right: parent.right

            rightMargin: 0
            topMargin: 35 // 36
          }
          width: 32
          height: 19 // 18

          ThinText {
              anchors.fill: parent
              anchors.rightMargin: 7
              font.pixelSize: 24
              font.capitalization: Font.AllUppercase
              horizontalAlignment: Text.AlignHCenter

              text: " " + screen.deckText[deckIdx - 1]
              color: deckPlayProp.value ? "black" : "white"
          }
        }

      }

      // Loop Overlay
      Item {
        // visible: showLoopSize && !showBPMInfo
        visible: showLoopSize && !showBPMInfo && !browserModeProp.value
        anchors.fill: parent

        // Loop headline
        ThickText {
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                topMargin: 0
                leftMargin: 1
            }
            text: "LOOP"
        }

        // Loop size
        Rectangle {
          anchors {
              top: parent.top
              left: parent.left
              leftMargin: -13
              topMargin: 20
          }
          width: 85
          height: 35
          color: loopActiveProp.value ? "white" : "black"

          ThinText {
              anchors.fill: parent 
              font.pixelSize: 48
              font.capitalization: Font.AllUppercase
              horizontalAlignment: Text.AlignHCenter

              text: " " + screen.loopText[loopSizeProp.value]
              color: loopActiveProp.value ? "black" : "white"
          }
        }
      }

      // BPM Overlay
      Item {
        // visible: !showLoopSize && showBPMInfo
        visible: !showLoopSize && showBPMInfo && !browserModeProp.value
        anchors.fill: parent

        // BPM
        Rectangle {
          anchors {
              top: parent.top
              left: parent.left
              leftMargin: -13
              topMargin: 20
          }
          width: parent.width
          height: 35
          color: "black"

          ThinText {
              anchors.fill: parent 
              font.pixelSize: 48
              font.capitalization: Font.AllUppercase
              horizontalAlignment: Text.AlignLeft

              text: " " + tempoBpmProp.value.toFixed(2).toString()
              color: "white"
          }
        }
      }

      // BrowserMode Overlay
      Item {
        visible: browserModeProp.value
        anchors.fill: parent

        // Browse Headline
          ThinText {
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                topMargin: 0
                leftMargin: 4
            }
            font.pixelSize: 18
            font.capitalization: Font.AllUppercase
            text: "BROWSE LIST"
        }
        
        Rectangle {
          anchors {
              top: parent.top
              left: parent.left
              // leftMargin: -13
              leftMargin: 2
              topMargin: 20
          }
          width: parent.width
          height: 35
          color: "black"

          ThinText {
              anchors.fill: parent 
              font.pixelSize: 18
              font.capitalization: Font.AllUppercase
              horizontalAlignment: Text.AlignLeft

              text:  isLeftScreen ? " BROWSE TREE" : shift ? "FAVORITES PREP" : "PREVIEW PLAYER"
              color:  isLeftScreen || shift ? "white" : previewDeckPlayingProp.value && screen.blinkOnOff ? "black" : "white"
          }
        }
      }

      // Track progress
      Rectangle {
        z: 1
        color: "black"
        visible: !browserModeProp.value
        anchors {
          bottom: parent.bottom
          left: parent.left

          leftMargin: 0
          bottomMargin: 0
        }
        border {
          color: "white"
          width: 1
        }
        width: screen.width
        height: 6

        Rectangle {
          // color: !trackEndWarningProp.value || screen.blinkOnOff ? "white" : "black"
          color: (!trackEndWarningProp.value || screen.blinkOnOff) || showEndWarningProp.value ? "white" : "black"
          anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            margins: 1
          }
          width: isLoaded ? Math.round(screen.width * elapsedTimeProp.value / trackLengthProp.value) : 0
        }
      }
    }

      // Preview Player progress
      Rectangle {
        z: 1
        color: "black"
        visible: browserModeProp.value && !(isLeftScreen)
        anchors {
          bottom: parent.bottom
          left: parent.left

          leftMargin: 0
          bottomMargin: 0
        }
        border {
          color: "white"
          width: 1
        }
        width: screen.width
        height: 6

        Rectangle {
          color: "white"
          anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            margins: 1
          }
          width: previewDeckLoadedProp.value ? Math.round(screen.width * previewElapsedTimeProp.value / previewLengthProp.value) : 0
        }
      }
      
    // Live Deck
    Item
    {
      visible: (deviceSetupState == DeviceSetupState.assigned) && (deckTypeProp.value == DeckType.Live)
      anchors.fill: parent

      ThinText {
          anchors.fill: parent
          text: "LIVE INPUT"
          horizontalAlignment: Text.AlignHCenter
          wrapMode: Text.WordWrap
          lineHeight: 29
          lineHeightMode: Text.FixedHeight
      }
    }

    // Deck assignment
    Item {
      // visible: deviceSetupState == DeviceSetupState.unassigned
      visible: deviceSetupState != DeviceSetupState.assigned
      anchors.fill: parent

      Rectangle {
        color: blinkOnOff ? "white" : "black"
        anchors {
        horizontalCenter: parent.horizontalCenter
        verticalCenter: parent.verticalCenter
        }

        width: 44
        height: 44

        ThinText {
          anchors {
            top: parent.top
            left: parent.left
            topMargin: -10
            leftMargin: -15
          }
          font.pixelSize: 60
          font.capitalization: Font.AllUppercase

          text: " " + deckText[screen.deckIdx - 1]
          color: blinkOnOff ? "black" : "white"
        }
      }
    }
  }
}
