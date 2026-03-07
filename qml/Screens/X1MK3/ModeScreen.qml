import CSI 1.0
import QtQuick 2.0

import "../../CSI/X1MK3/Defines"

Item {
  id: screen

  // side is unused but needed for compatibility
  property int side: ScreenSide.Left;

  property string settingsPath: ""
  property string propertiesPath: ""

  width:  128
  height: 64
  clip:   true

  MappingProperty { id: fxSectionLayer; path: screen.propertiesPath + ".fx_section_layer" }

  MappingProperty { id: deviceSetupStateProp; path: screen.propertiesPath + ".device_setup_state" }
  property alias deviceSetupState: deviceSetupStateProp.value

  MappingProperty { id: deviceSetupPageProp; path: screen.propertiesPath + ".device_setup_page" }
  // readonly property string deviceSetupPageString: "SETUP PAGE " + deviceSetupPageProp.value
  readonly property string deviceSetupPageString: setupText[deviceSetupPageProp.value] + "SETUP P. " + deviceSetupPageProp.value
  readonly property variant setupText: ["", " MIXER  ", "BRWS./BEAT. ", " MISC./FX  "]
  
  MappingProperty { id: deckAssignmentProp; path: "mapping.settings.deck_assignment" }
  MappingProperty { id: customDeckSwitchAcVariantProp; path: "mapping.settings.custom_deck_switch_ac_variant" }
  
  MappingProperty { id: leftDeckIdxProp; path: screen.propertiesPath + ".left_deck_index" }
  property alias leftDeckIdx: leftDeckIdxProp.value

  MappingProperty { id: rightDeckIdxProp; path: screen.propertiesPath + ".right_deck_index" }
  property alias rightDeckIdx: rightDeckIdxProp.value

  MappingProperty { id: leftFxIdxProp; path: screen.propertiesPath + ".left_fx_index" }
  property alias leftFxIdx: leftFxIdxProp.value

  MappingProperty { id: rightFxIdxProp; path: screen.propertiesPath + ".right_fx_index" }
  property alias rightFxIdx: rightFxIdxProp.value

  AppProperty { id: deckAPlayProp; path: "app.traktor.decks.1.play" }
  AppProperty { id: deckBPlayProp; path: "app.traktor.decks.2.play" }
  AppProperty { id: deckCPlayProp; path: "app.traktor.decks.3.play" }
  AppProperty { id: deckDPlayProp; path: "app.traktor.decks.4.play" }
  AppProperty { id: deckALevelProp; path: "app.traktor.mixer.channels.1.level.prefader.linear.sum" }
  AppProperty { id: deckBLevelProp; path: "app.traktor.mixer.channels.2.level.prefader.linear.sum" }
  AppProperty { id: deckCLevelProp; path: "app.traktor.mixer.channels.3.level.prefader.linear.sum" }
  AppProperty { id: deckDLevelProp; path: "app.traktor.mixer.channels.4.level.prefader.linear.sum" }
  // readonly property real metersFactor: 0.8
  readonly property real metersFactor: 0.7

  AppProperty { id: masterLevelProp; path: "app.traktor.mixer.master.level.sum" }
  AppProperty { id: masterLevelClipProp; path: "app.traktor.mixer.master.level.clip.sum" }
  AppProperty { id: limiterStateProp; path: "app.traktor.mixer.master.limiter_state" }

  function deckImage(layer, deckIdx)
  {
    if (layer == FXSectionLayer.mixer)
    {
      switch(deckIdx)
      {
        case 1: return "A_" + (deckAPlayProp.value ? "A" : "U") + ".png";
        case 2: return "B_" + (deckBPlayProp.value ? "A" : "U") + ".png";
        case 3: return "C_" + (deckCPlayProp.value ? "A" : "U") + ".png";
        case 4: return "D_" + (deckDPlayProp.value ? "A" : "U") + ".png";
      }
    }

    return "A_A.png";
  }

  Rectangle {
    color: "black"
    anchors.fill: parent

    Item {
      anchors.fill: parent
      visible: (deviceSetupState == DeviceSetupState.assigned) &&
               ((fxSectionLayer.value == FXSectionLayer.fx_primary) || (fxSectionLayer.value == FXSectionLayer.fx_secondary))

      ThinText {
          anchors {
              top: parent.top
              left: parent.left
              right: parent.right
              topMargin: -8
              leftMargin: -12
          }
          text: " EFFECTS"        
      }
  
      Image {
          anchors {
              bottom: parent.bottom
              left: parent.left
          }
  
          source:    "Images/" + leftFxIdx + "_A.png"
          fillMode:  Image.PreserveAspectFit
      }
  
      Image {
          anchors {
              bottom: parent.bottom
              right: parent.right
          }
  
          source:    "Images/" + rightFxIdx + "_A.png"
          fillMode:  Image.PreserveAspectFit
      }
  
      AnimatedImage {
          id: fxAnimation1
          anchors {
              bottom: parent.bottom
              horizontalCenter: parent.horizontalCenter
              bottomMargin: 5
          }
  
          source: "Images/FX.gif"
      }
  
      AnimatedImage {
          id: fxAnimation2
          anchors {
              bottom: fxAnimation1.top
              horizontalCenter: parent.horizontalCenter
              bottomMargin: 5
          }
  
          source: "Images/FX.gif"
      }
    }

    Item {
      anchors.fill: parent
      visible: (deviceSetupState == DeviceSetupState.assigned) &&
               (fxSectionLayer.value == FXSectionLayer.mixer)

      // ThinText {
          // anchors {
              // top: parent.top
              // left: parent.left
              // right: parent.right
              // topMargin: -8
              // leftMargin: -12
          // }
          // text: " MIXER"
          // horizontalAlignment: Text.AlignHCenter
      // }

      // Master level meter
      Item {
        anchors {
          top: parent.top
          left: parent.left
          right: parent.right
        }
        height: 20

        Image {
          anchors {
              top: parent.top
              left: parent.left
              topMargin: 10
              leftMargin: 10
          }
          source: "Images/MasterMeter.png"

          // Master level
          Rectangle
          {
            anchors {
                top: parent.top
                left: parent.left
                bottom: parent.bottom
            }

            color: "white"
            width: Math.min(masterLevelProp.value * parent.width * 0.9, 86)
          }

          // Master Orange
          Rectangle
          {
            anchors {
                top: parent.top
                left: parent.left
                bottom: parent.bottom
                leftMargin: 64
            }

            color: "white"
            width: 2
          }

          // Master clip
          Rectangle
          {
            visible: masterLevelClipProp.value != 0
            anchors {
                top: parent.top
                left: parent.left
                bottom: parent.bottom
                leftMargin: 89
            }

            color: "white"
            width: 21
          }
        }

        // Limiter state
        Rectangle
        {
          visible: limiterStateProp.value != 0
          anchors {
              top: parent.top
              left: parent.left
              bottom: parent.bottom
              topMargin: 6
              leftMargin: 94
          }

          color: "white"
          width: 2
        }
      }
  
      // Channel ID Left
      Image {
        anchors {
          bottom: parent.bottom
          left: parent.left
          leftMargin: (deckAssignmentProp.value == DeviceAssignment.decks_a_b) ? 16 : (deckAssignmentProp.value == DeviceAssignment.decks_b_d) ? 30 : 0
        }
  
        source:    "Images/" + deckImage(fxSectionLayer.value, leftDeckIdx)
        fillMode:  Image.PreserveAspectFit
      }
 
      // Channel ID Right
      Image {
        anchors {
          bottom: parent.bottom
          right: parent.right
          rightMargin: (deckAssignmentProp.value == DeviceAssignment.decks_a_b) ? 16 : ( (deckAssignmentProp.value == DeviceAssignment.decks_c_d) || (deckAssignmentProp.value == DeviceAssignment.decks_b_d) ) ? 0 : 30
        }

        source:    "Images/" + deckImage(fxSectionLayer.value, rightDeckIdx)
        fillMode:  Image.PreserveAspectFit
      }
  
  
      // Channel 1 level meter
      Item {
        anchors {
          left: parent.left
            leftMargin: ( (deckAssignmentProp.value == DeviceAssignment.decks_a_b) || (deckAssignmentProp.value == DeviceAssignment.decks_b_d) ) ? 0 : 40
          bottom: parent.bottom
        }
        width: 12
        height: 55

        Image {
          anchors {
            left: parent.left
            bottom: parent.bottom
          }
          source: "Images/EQMeter_bipolar.png"

          Rectangle {
            anchors {
              left: parent.left
              right: parent.right
              bottom: parent.bottom
            }

            color: "white"
            height: customDeckSwitchAcVariantProp.value ? (Math.min(deckALevelProp.value * parent.height * metersFactor, 38)) : (Math.min(deckCLevelProp.value * parent.height * metersFactor, 38))
          }

        }
        
        Rectangle {
          // color: ( (deckAssignmentProp.value == DeviceAssignment.decks_a_c) || (deckAssignmentProp.value == DeviceAssignment.decks_c_a) || (deckAssignmentProp.value == DeviceAssignment.decks_c_d) ) ? "white" : "black"
          color: ( ( customDeckSwitchAcVariantProp.value && (deckALevelProp.value > 1.5) ) || ( !customDeckSwitchAcVariantProp.value && (deckCLevelProp.value > 1.5) ) ) ? "white" : "black"
          anchors {
            right: parent.right
            rightMargin: 6
            bottom: parent.bottom
            bottomMargin: 38
          }
          width: 7
          height: 9
        }

        ThinText {
          anchors {
            right: parent.right
            rightMargin: 6
            bottom: parent.bottom
            bottomMargin: 35
          }
          
          font.pixelSize: 12
          font.capitalization: Font.AllUppercase
          horizontalAlignment: Text.AlignRight
          text: customDeckSwitchAcVariantProp.value ? "A" : "C"
          // color: ( (deckAssignmentProp.value == DeviceAssignment.decks_a_c) || (deckAssignmentProp.value == DeviceAssignment.decks_c_a) || (deckAssignmentProp.value == DeviceAssignment.decks_c_d) ) ? "black" : "white"
          color: ( ( customDeckSwitchAcVariantProp.value && (deckALevelProp.value > 1.5) ) || ( !customDeckSwitchAcVariantProp.value && (deckCLevelProp.value > 1.5) ) ) ? "black" : "white"
        }

      }
      
      // Channel 2 level meter
      Item {
        anchors {
          left: parent.left
          leftMargin: ( (deckAssignmentProp.value == DeviceAssignment.decks_a_b) || (deckAssignmentProp.value == DeviceAssignment.decks_c_d) ) ? 56 : (deckAssignmentProp.value == DeviceAssignment.decks_b_d) ? 12 : 52
          bottom: parent.bottom
        }
        width: 12
        height: 55

        Image {
          anchors {
            left: parent.left
            bottom: parent.bottom
          }
          source: "Images/EQMeter_bipolar.png"

          Rectangle {
            anchors {
              left: parent.left
              right: parent.right
              bottom: parent.bottom
            }

            color: "white"
            height: customDeckSwitchAcVariantProp.value ? (Math.min(deckCLevelProp.value * parent.height * metersFactor, 38)) : (Math.min(deckALevelProp.value * parent.height * metersFactor, 38))
          }
          
        }
        
        Rectangle {
          // color: ( (deckAssignmentProp.value == DeviceAssignment.decks_a_b) || (deckAssignmentProp.value == DeviceAssignment.decks_a_c) || (deckAssignmentProp.value == DeviceAssignment.decks_c_a) ) ? "white" : "black"
          color: ( ( !customDeckSwitchAcVariantProp.value && (deckALevelProp.value > 1.5) ) || ( customDeckSwitchAcVariantProp.value && (deckCLevelProp.value > 1.5) ) ) ? "white" : "black"
          anchors {
            right: parent.right
            rightMargin: 6
            bottom: parent.bottom
            bottomMargin: 38
          }
          width: 7
          height: 9
        }

        ThinText {
          anchors {
            right: parent.right
            rightMargin: 6
            bottom: parent.bottom
            bottomMargin: 35
          }
          
          font.pixelSize: 12
          font.capitalization: Font.AllUppercase
          horizontalAlignment: Text.AlignRight
          text: customDeckSwitchAcVariantProp.value ? "C" : "A"
          // color: ( (deckAssignmentProp.value == DeviceAssignment.decks_a_b) || (deckAssignmentProp.value == DeviceAssignment.decks_a_c) || (deckAssignmentProp.value == DeviceAssignment.decks_c_a) ) ? "black" : "white"
          color: ( ( !customDeckSwitchAcVariantProp.value && (deckALevelProp.value > 1.5) ) || ( customDeckSwitchAcVariantProp.value && (deckCLevelProp.value > 1.5) ) ) ? "black" : "white"
        }

      }
      
      // Channel 3 level meter
      Item {
        anchors {
          right: parent.right
          rightMargin: ( (deckAssignmentProp.value == DeviceAssignment.decks_a_b) || (deckAssignmentProp.value == DeviceAssignment.decks_c_d) ) ? 56 : (deckAssignmentProp.value == DeviceAssignment.decks_b_d) ? 52 : 12
          bottom: parent.bottom
        }
        width: 12
        height: 55

        Image {
          anchors {
            right: parent.right
            bottom: parent.bottom
          }
          source: "Images/EQMeter_bipolar.png"

          Rectangle {
            anchors {
              left: parent.left
              right: parent.right
              bottom: parent.bottom
            }

            color: "white"
            height: Math.min(deckBLevelProp.value * parent.height * metersFactor, 38)
          }
          
        }
      
        Rectangle {
          // color: ( (deckAssignmentProp.value == DeviceAssignment.decks_a_b) || (deckAssignmentProp.value == DeviceAssignment.decks_b_d) ) ? "white" : "black"
          color: (deckBLevelProp.value > 1.5) ? "white" : "black"
          anchors {
            right: parent.right
            rightMargin: -1
            bottom: parent.bottom
            bottomMargin: 38
          }
          width: 7
          height: 9
        }

        ThinText {
          anchors {
            right: parent.right
            rightMargin: -1
            bottom: parent.bottom
            bottomMargin: 35
          }
          
          font.pixelSize: 12
          font.capitalization: Font.AllUppercase
          horizontalAlignment: Text.AlignRight
          text: "B"
          // color: ( (deckAssignmentProp.value == DeviceAssignment.decks_a_b) || (deckAssignmentProp.value == DeviceAssignment.decks_b_d) ) ? "black" : "white"
          color: (deckBLevelProp.value > 1.5) ? "black" : "white"
        }

      }

      // Channel 4 level meter
      Item {
        anchors {
          right: parent.right
          rightMargin: (deckAssignmentProp.value == DeviceAssignment.decks_a_b) ? 0 : ( (deckAssignmentProp.value == DeviceAssignment.decks_c_d) || (deckAssignmentProp.value == DeviceAssignment.decks_b_d) ) ? 40 : 0
          bottom: parent.bottom
        }
        width: 12
        height: 55

        Image {
          anchors {
            right: parent.right
            bottom: parent.bottom
          }
          source: "Images/EQMeter_bipolar.png"

          Rectangle {
            anchors {
              left: parent.left
              right: parent.right
              bottom: parent.bottom
            }

            color: "white"
            height: Math.min(deckDLevelProp.value * parent.height * metersFactor, 38)
          }

        }
      
        Rectangle {
          // color: ( (deckAssignmentProp.value == DeviceAssignment.decks_c_d) || (deckAssignmentProp.value == DeviceAssignment.decks_b_d) ) ? "white" : "black"
          color: (deckDLevelProp.value > 1.5) ? "white" : "black"
          anchors {
            right: parent.right
            rightMargin: -1
            bottom: parent.bottom
            bottomMargin: 38
          }
          width: 7
          height: 9
        }

        ThinText {
          anchors {
            right: parent.right
            rightMargin: -1
            bottom: parent.bottom
            bottomMargin: 35
          }
          
          font.pixelSize: 12
          font.capitalization: Font.AllUppercase
          horizontalAlignment: Text.AlignRight
          text: "D"
          // color: ( (deckAssignmentProp.value == DeviceAssignment.decks_c_d) || (deckAssignmentProp.value == DeviceAssignment.decks_b_d) ) ? "black" : "white"
          color: (deckDLevelProp.value > 1.5) ? "black" : "white"
        }
        
      }

    }

    Item {
      anchors.fill: parent
      visible: deviceSetupState == DeviceSetupState.unassigned
  
      ThinText {
          anchors.fill: parent
          // text: "DEVICE SETUP"
          text: deviceSetupPageString
          horizontalAlignment: Text.AlignHCenter
          wrapMode: Text.WordWrap
          // lineHeight: 29
          // lineHeightMode: Text.FixedHeight
          font.pixelSize: 24
          font.capitalization: Font.AllUppercase
      }
    }

    Item {
      anchors.fill: parent
      visible: deviceSetupState == DeviceSetupState.just_assigned
  
      ThinText {
          anchors.fill: parent
          // text: "¢"
          // text: "🦋"
          // font.pixelSize: 60
          text: "C.P.MOD V12 SÛLHEROKHH"
          font.pixelSize: 24
          horizontalAlignment: Text.AlignHCenter
          wrapMode: Text.WordWrap
          font.capitalization: Font.AllUppercase
      }
    }
  }
}
