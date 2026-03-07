import CSI 1.0
import QtQuick 2.5

import "Defines"

Module
{
  id: module
  property string surface: ""
  property string propertiesPath: ""
  property bool shift: false
  property alias state: deviceSetupStateProp.value

  readonly property int leftDeckIdx: DeviceAssignment.leftDeckIdx(deckAssignmentProp.value)
  readonly property int rightDeckIdx: DeviceAssignment.rightDeckIdx(deckAssignmentProp.value)

  readonly property int leftPrimaryFxIdx: DeviceAssignment.leftPrimaryFxIdx(fxAssignmentProp.value)
  readonly property int rightPrimaryFxIdx: DeviceAssignment.rightPrimaryFxIdx(fxAssignmentProp.value)

  readonly property int leftSecondaryFxIdx: DeviceAssignment.leftSecondaryFxIdx(fxAssignmentProp.value)
  readonly property int rightSecondaryFxIdx: DeviceAssignment.rightSecondaryFxIdx(fxAssignmentProp.value)

  function reset()
  {
    deviceSetupStateProp.value = DeviceSetupState.unassigned;
    lastTouchedButtonLeftSideProp.value = 0
    lastTouchedButtonRightSideProp.value = 0
    deviceSetupPageProp.value = 1
    resetOverlayOvermapping()
  }

  function deckswitch()
  {
    switch (deckAssignmentProp.value) {
      case DeviceAssignment.decks_a_b:
        deckAssignmentProp.value = DeviceAssignment.decks_c_d
        if (fxMode.value != FxMode.TwoFxUnits && customLinkFXOverlayToDeckProp.value) {
          fxAssignmentProp.value = DeviceAssignment.fx_3_4
        }
        break;

      case DeviceAssignment.decks_c_d:
        deckAssignmentProp.value = DeviceAssignment.decks_a_b
        if (fxMode.value != FxMode.TwoFxUnits && customLinkFXOverlayToDeckProp.value) {
          fxAssignmentProp.value = DeviceAssignment.fx_1_2
        }
        break;

      case DeviceAssignment.decks_c_a:
        deckAssignmentProp.value = DeviceAssignment.decks_b_d
        if (fxMode.value != FxMode.TwoFxUnits && customLinkFXOverlayToDeckProp.value) {
          fxAssignmentProp.value = DeviceAssignment.fx_2_4
        }
        break;
      case DeviceAssignment.decks_b_d:
        deckAssignmentProp.value = customDeckSwitchAcVariantProp.value ? DeviceAssignment.decks_a_c : DeviceAssignment.decks_c_a
        if (fxMode.value != FxMode.TwoFxUnits && customLinkFXOverlayToDeckProp.value) {
          fxAssignmentProp.value = customDeckSwitchAcVariantProp.value ? DeviceAssignment.fx_1_3 : DeviceAssignment.fx_3_1
        }
        break;
      case DeviceAssignment.decks_a_c:
        deckAssignmentProp.value = DeviceAssignment.decks_b_d
        if (fxMode.value != FxMode.TwoFxUnits && customLinkFXOverlayToDeckProp.value) {
          fxAssignmentProp.value = DeviceAssignment.fx_2_4
        }
        break;
    }
  }

  function resetOverlayOvermapping() {
    if (customOvermappingEngagedProp.value) {
      if (deviceSetupStateProp.value == DeviceSetupState.unassigned) {
        remixPageDeckA.value = 3
        remixPageDeckB.value = 3
      }
      else if (deviceSetupStateProp.value == DeviceSetupState.assigned) {
        if (deckAssignmentProp.value == DeviceAssignment.decks_a_b || deckAssignmentProp.value == DeviceAssignment.decks_c_a || deckAssignmentProp.value == DeviceAssignment.decks_a_c) {
          remixPageDeckB.value = 3
          if (fxSection.layer == FXSectionLayer.fx_primary) remixPageDeckA.value = 0
          else if (fxSection.layer == FXSectionLayer.fx_secondary) remixPageDeckA.value = 1
          else if (fxSection.layer == FXSectionLayer.mixer) remixPageDeckA.value = 2
        }
        else {
          remixPageDeckA.value = 3
          if (fxSection.layer == FXSectionLayer.fx_primary) remixPageDeckB.value = 0
          else if (fxSection.layer == FXSectionLayer.fx_secondary) remixPageDeckB.value = 1
          else if (fxSection.layer == FXSectionLayer.mixer) remixPageDeckB.value = 2
        }
      }
    }
  }
  
  function mixerAssignmentColor(mixerAssignment)
  {
    switch (mixerAssignment) {
      case 0: return Color.White
      case 1: return Color.Blue
      case 2: return Color.WarmYellow
      case 3: return Color.LightOrange
      case 4: return Color.Red
    }
  }

  function mixerAssignmentLayerColor(mixerAssignment)
  {
    switch (mixerAssignment) {
      case 0: return Color.White
      case 1: return Color.Yellow
      case 2: return Color.DarkOrange
    }
  }

  function alignKnobAssignments(sourceKnobAssignment,sourceLayerAssignment,targetKnobAssignment,targetLayerAssignment)
  {
    if (targetKnobAssignment == sourceKnobAssignment)
      {
      if (sourceLayerAssignment == 0)
      {
        return 0
      }
      else if ( (sourceLayerAssignment > 0) && (targetLayerAssignment == 0) )
      {
        return 1
      }
      else
      {
        return targetLayerAssignment
      }
    }
    
    else
    {
      return targetLayerAssignment
    }
  }
  
  
  MappingPropertyDescriptor {
    id: deviceSetupStateProp
    type: MappingPropertyDescriptor.Integer
    path: module.propertiesPath + ".device_setup_state"

    value: DeviceSetupState.unassigned
    min: DeviceSetupState.unassigned
    max: DeviceSetupState.assigned
    onValueChanged: {
      lastTouchedButtonLeftSideProp.value = 0
      lastTouchedButtonRightSideProp.value = 0
      resetOverlayOvermapping()
    }
  }

  MappingPropertyDescriptor {
    id: deviceSetupPageProp
    path: module.propertiesPath + ".device_setup_page"
    type: MappingPropertyDescriptor.Integer
    value: 1
    min: 1
    max: 4
    onValueChanged: {
      lastTouchedButtonLeftSideProp.value = 0
      lastTouchedButtonRightSideProp.value = 0
    }
  }

  RelativePropertyAdapter { name: "deck_selector"; path: deckAssignmentProp.path; mode: RelativeMode.Stepped; wrap: true }
  RelativePropertyAdapter { name: "fx_selection_prev"; path: fxAssignmentProp.path; mode: RelativeMode.Decrement; wrap: true }
  RelativePropertyAdapter { name: "fx_selection_next"; path: fxAssignmentProp.path; mode: RelativeMode.Increment; wrap: true }
  RelativePropertyAdapter { name: "deck_selection_prev"; path: deckAssignmentProp.path; mode: RelativeMode.Decrement; wrap: true }
  RelativePropertyAdapter { name: "deck_selection_next"; path: deckAssignmentProp.path; mode: RelativeMode.Increment; wrap: true }

  Timer {
    id: deviceSetupCompleted;
    // interval: 1000;
    interval: 1500;
    onTriggered:
    {
      // Device has finally been assigned!
      deviceSetupStateProp.value = DeviceSetupState.assigned;
    }
  }

  Timer {
    id: deviceSetupExitTimer;
    // interval: 1000;
    interval: 500;
    onTriggered: {
      deviceSetupStateProp.value = DeviceSetupState.just_assigned;
      deviceSetupCompleted.restart();
    }
  }
  
  ButtonScriptAdapter {
    name: "complete_device_setup";
    onPress: {
      // Decks have been assigned, temporarily go into just_assigned state
      deviceSetupStateProp.value = DeviceSetupState.just_assigned;
      deviceSetupCompleted.restart();
    }
  }

  WiresGroup
  {
    enabled: module.state == DeviceSetupState.unassigned

    Wire { from: "%surface%.left.loop"; to: "deck_selector" }
    Wire { from: "%surface%.left.loop.push"; to: "complete_device_setup" }

    Wire { from: "%surface%.left.browse"; to: "deck_selector" }
    Wire { from: "%surface%.left.browse.push"; to: "complete_device_setup" }

    Wire { from: "%surface%.right.loop"; to: "deck_selector" }
    Wire { from: "%surface%.right.loop.push"; to: "complete_device_setup" }

    Wire { from: "%surface%.right.browse"; to: "deck_selector" }
    Wire { from: "%surface%.right.browse.push"; to: "complete_device_setup" }
    
    // Wire { from: "%surface%.mode"; to: "complete_device_setup" }
    Wire {
      from: "%surface%.mode"
      to: ButtonScriptAdapter {
        onPress: {
          deviceSetupExitTimer.restart()
        }
        onRelease: {
          if (deviceSetupExitTimer.running) {
            deviceSetupExitTimer.stop()
            deviceSetupPageProp.value = (deviceSetupPageProp.value == 3) ? deviceSetupPageProp.value = 1 : deviceSetupPageProp.value = deviceSetupPageProp.value + 1
          }
        }
      }
    }

    WiresGroup {
      enabled: fxMode.value != FxMode.TwoFxUnits && !customLinkFXOverlayToDeckProp.value
      Wire { from: "%surface%.left.assign.left";   to: "fx_selection_prev" }
      Wire { from: "%surface%.left.assign.right";  to: "fx_selection_next" }
      Wire { from: "%surface%.right.assign.left";  to: "fx_selection_prev" }
      Wire { from: "%surface%.right.assign.right"; to: "fx_selection_next" }
    }

    WiresGroup {
      enabled: fxMode.value != FxMode.TwoFxUnits && customLinkFXOverlayToDeckProp.value
      Wire { from: "%surface%.left.assign.left";   to: "deck_selection_prev" }
      Wire { from: "%surface%.left.assign.right";  to: "deck_selection_next" }
      Wire { from: "%surface%.right.assign.left";  to: "deck_selection_prev" }
      Wire { from: "%surface%.right.assign.right"; to: "deck_selection_next" }
    }
    
    WiresGroup {
      enabled: (deviceSetupPageProp.value == 1)

      // CUSTOM MIXER
      WiresGroup {
        enabled: !shift

        Wire {
          from: "%surface%.left.fx.buttons.1"; to: ButtonScriptAdapter {
            color: mixerAssignmentColor(customKnobAssignmentEqHigh.value)
            brightness: customKnobAssignmentEqHigh.value;
            onPress: {
              lastTouchedButtonLeftSideProp.value = 1
              if (customKnobAssignmentEqHigh.value < 4) customKnobAssignmentEqHigh.value = customKnobAssignmentEqHigh.value + 1;
              else customKnobAssignmentEqHigh.value = 0
            }
            onRelease: {
              customLayerAssignmentEqHigh.value = alignKnobAssignments(customKnobAssignmentEqMid.value, customLayerAssignmentEqMid.value, customKnobAssignmentEqHigh.value, customLayerAssignmentEqHigh.value)
              customLayerAssignmentEqHigh.value = alignKnobAssignments(customKnobAssignmentEqMidLow.value, customLayerAssignmentEqMidLow.value, customKnobAssignmentEqHigh.value, customLayerAssignmentEqHigh.value)
              customLayerAssignmentEqHigh.value = alignKnobAssignments(customKnobAssignmentEqLow.value, customLayerAssignmentEqLow.value, customKnobAssignmentEqHigh.value, customLayerAssignmentEqHigh.value)
              customLayerAssignmentEqHigh.value = alignKnobAssignments(customKnobAssignmentVolume.value, customLayerAssignmentVolume.value, customKnobAssignmentEqHigh.value, customLayerAssignmentEqHigh.value)
              customLayerAssignmentEqHigh.value = alignKnobAssignments(customKnobAssignmentGain.value, customLayerAssignmentGain.value, customKnobAssignmentEqHigh.value, customLayerAssignmentEqHigh.value)
              customLayerAssignmentEqHigh.value = alignKnobAssignments(customKnobAssignmentMixerFx.value, customLayerAssignmentMixerFx.value, customKnobAssignmentEqHigh.value, customLayerAssignmentEqHigh.value)
            }
          }
        }
        Wire {
          from: "%surface%.left.fx.buttons.2"; to: ButtonScriptAdapter {
            color: mixerAssignmentColor(customKnobAssignmentEqMid.value)
            brightness: customKnobAssignmentEqMid.value;
            onPress: {
              lastTouchedButtonLeftSideProp.value = 2
              if (customKnobAssignmentEqMid.value < 4) customKnobAssignmentEqMid.value = customKnobAssignmentEqMid.value + 1;
              else customKnobAssignmentEqMid.value = 0
            }
            onRelease: {
              customLayerAssignmentEqMid.value = alignKnobAssignments(customKnobAssignmentEqHigh.value, customLayerAssignmentEqHigh.value, customKnobAssignmentEqMid.value, customLayerAssignmentEqMid.value)
              customLayerAssignmentEqMid.value = alignKnobAssignments(customKnobAssignmentEqMidLow.value, customLayerAssignmentEqMidLow.value, customKnobAssignmentEqMid.value, customLayerAssignmentEqMid.value)
              customLayerAssignmentEqMid.value = alignKnobAssignments(customKnobAssignmentEqLow.value, customLayerAssignmentEqLow.value, customKnobAssignmentEqMid.value, customLayerAssignmentEqMid.value)
              customLayerAssignmentEqMid.value = alignKnobAssignments(customKnobAssignmentVolume.value, customLayerAssignmentVolume.value, customKnobAssignmentEqMid.value, customLayerAssignmentEqMid.value)
              customLayerAssignmentEqMid.value = alignKnobAssignments(customKnobAssignmentGain.value, customLayerAssignmentGain.value, customKnobAssignmentEqMid.value, customLayerAssignmentEqMid.value)
              customLayerAssignmentEqMid.value = alignKnobAssignments(customKnobAssignmentMixerFx.value, customLayerAssignmentMixerFx.value, customKnobAssignmentEqMid.value, customLayerAssignmentEqMid.value)
            }
          }
        }
        Wire {
          from: "%surface%.left.fx.buttons.3"; to: ButtonScriptAdapter {
            color: mixerAssignmentColor(customKnobAssignmentEqMidLow.value)
            brightness: customKnobAssignmentEqMidLow.value;
            onPress: {
              lastTouchedButtonLeftSideProp.value = 3
              if (customKnobAssignmentEqMidLow.value < 4) customKnobAssignmentEqMidLow.value = customKnobAssignmentEqMidLow.value + 1;
              else customKnobAssignmentEqMidLow.value = 0
            }
            onRelease: {
              customLayerAssignmentEqMidLow.value = alignKnobAssignments(customKnobAssignmentEqHigh.value, customLayerAssignmentEqHigh.value, customKnobAssignmentEqMidLow.value, customLayerAssignmentEqMidLow.value)
              customLayerAssignmentEqMidLow.value = alignKnobAssignments(customKnobAssignmentEqMid.value, customLayerAssignmentEqMid.value, customKnobAssignmentEqMidLow.value, customLayerAssignmentEqMidLow.value)
              customLayerAssignmentEqMidLow.value = alignKnobAssignments(customKnobAssignmentEqLow.value, customLayerAssignmentEqLow.value, customKnobAssignmentEqMidLow.value, customLayerAssignmentEqMidLow.value)
              customLayerAssignmentEqMidLow.value = alignKnobAssignments(customKnobAssignmentVolume.value, customLayerAssignmentVolume.value, customKnobAssignmentEqMidLow.value, customLayerAssignmentEqMidLow.value)
              customLayerAssignmentEqMidLow.value = alignKnobAssignments(customKnobAssignmentGain.value, customLayerAssignmentGain.value, customKnobAssignmentEqMidLow.value, customLayerAssignmentEqMidLow.value)
              customLayerAssignmentEqMidLow.value = alignKnobAssignments(customKnobAssignmentMixerFx.value, customLayerAssignmentMixerFx.value, customKnobAssignmentEqMidLow.value, customLayerAssignmentEqMidLow.value)
            }
          }
        }
        Wire {
          from: "%surface%.left.fx.buttons.4"; to: ButtonScriptAdapter {
            color: mixerAssignmentColor(customKnobAssignmentEqLow.value)
            brightness: customKnobAssignmentEqLow.value;
            onPress: {
              lastTouchedButtonLeftSideProp.value = 4
              if (customKnobAssignmentEqLow.value < 4) customKnobAssignmentEqLow.value = customKnobAssignmentEqLow.value + 1;
              else customKnobAssignmentEqLow.value = 0
            }
            onRelease: {
              customLayerAssignmentEqLow.value = alignKnobAssignments(customKnobAssignmentEqHigh.value, customLayerAssignmentEqHigh.value, customKnobAssignmentEqLow.value, customLayerAssignmentEqLow.value)
              customLayerAssignmentEqLow.value = alignKnobAssignments(customKnobAssignmentEqMid.value, customLayerAssignmentEqMid.value, customKnobAssignmentEqLow.value, customLayerAssignmentEqLow.value)
              customLayerAssignmentEqLow.value = alignKnobAssignments(customKnobAssignmentEqMidLow.value, customLayerAssignmentEqMidLow.value, customKnobAssignmentEqLow.value, customLayerAssignmentEqLow.value)
              customLayerAssignmentEqLow.value = alignKnobAssignments(customKnobAssignmentVolume.value, customLayerAssignmentVolume.value, customKnobAssignmentEqLow.value, customLayerAssignmentEqLow.value)
              customLayerAssignmentEqLow.value = alignKnobAssignments(customKnobAssignmentGain.value, customLayerAssignmentGain.value, customKnobAssignmentEqLow.value, customLayerAssignmentEqLow.value)
              customLayerAssignmentEqLow.value = alignKnobAssignments(customKnobAssignmentMixerFx.value, customLayerAssignmentMixerFx.value, customKnobAssignmentEqLow.value, customLayerAssignmentEqLow.value)
            }
          }
        }
      
        Wire {
          from: "%surface%.right.fx.buttons.1"; to: ButtonScriptAdapter {
            color: mixerAssignmentColor(customKnobAssignmentVolume.value)
            brightness: customKnobAssignmentVolume.value;
            onPress: {
              lastTouchedButtonRightSideProp.value = 1
              if (customKnobAssignmentVolume.value < 4) customKnobAssignmentVolume.value = customKnobAssignmentVolume.value + 1;
              else customKnobAssignmentVolume.value = 0
            }
            onRelease: {
              customLayerAssignmentVolume.value = alignKnobAssignments(customKnobAssignmentEqHigh.value, customLayerAssignmentEqHigh.value, customKnobAssignmentVolume.value, customLayerAssignmentVolume.value)
              customLayerAssignmentVolume.value = alignKnobAssignments(customKnobAssignmentEqMid.value, customLayerAssignmentEqMid.value, customKnobAssignmentVolume.value, customLayerAssignmentVolume.value)
              customLayerAssignmentVolume.value = alignKnobAssignments(customKnobAssignmentEqMidLow.value, customLayerAssignmentEqMidLow.value, customKnobAssignmentVolume.value, customLayerAssignmentVolume.value)
              customLayerAssignmentVolume.value = alignKnobAssignments(customKnobAssignmentEqLow.value, customLayerAssignmentEqLow.value, customKnobAssignmentVolume.value, customLayerAssignmentVolume.value)
              customLayerAssignmentVolume.value = alignKnobAssignments(customKnobAssignmentGain.value, customLayerAssignmentGain.value, customKnobAssignmentVolume.value, customLayerAssignmentVolume.value)
              customLayerAssignmentVolume.value = alignKnobAssignments(customKnobAssignmentMixerFx.value, customLayerAssignmentMixerFx.value, customKnobAssignmentVolume.value, customLayerAssignmentVolume.value)
            }
          }
        }
        Wire {
          from: "%surface%.right.fx.buttons.2"; to: ButtonScriptAdapter {
            color: mixerAssignmentColor(customKnobAssignmentGain.value)
            brightness: customKnobAssignmentGain.value;
            onPress: {
              lastTouchedButtonRightSideProp.value = 2
              if (customKnobAssignmentGain.value < 4) customKnobAssignmentGain.value = customKnobAssignmentGain.value + 1;
              else customKnobAssignmentGain.value = 0
            }
            onRelease: {
              customLayerAssignmentGain.value = alignKnobAssignments(customKnobAssignmentEqHigh.value, customLayerAssignmentEqHigh.value, customKnobAssignmentGain.value, customLayerAssignmentGain.value)
              customLayerAssignmentGain.value = alignKnobAssignments(customKnobAssignmentEqMid.value, customLayerAssignmentEqMid.value, customKnobAssignmentGain.value, customLayerAssignmentGain.value)
              customLayerAssignmentGain.value = alignKnobAssignments(customKnobAssignmentEqMidLow.value, customLayerAssignmentEqMidLow.value, customKnobAssignmentGain.value, customLayerAssignmentGain.value)
              customLayerAssignmentGain.value = alignKnobAssignments(customKnobAssignmentEqLow.value, customLayerAssignmentEqLow.value, customKnobAssignmentGain.value, customLayerAssignmentGain.value)
              customLayerAssignmentGain.value = alignKnobAssignments(customKnobAssignmentVolume.value, customLayerAssignmentVolume.value, customKnobAssignmentGain.value, customLayerAssignmentGain.value)
              customLayerAssignmentGain.value = alignKnobAssignments(customKnobAssignmentMixerFx.value, customLayerAssignmentMixerFx.value, customKnobAssignmentGain.value, customLayerAssignmentGain.value)
            }
          }
        }
        Wire {
          from: "%surface%.right.fx.buttons.3"; to: ButtonScriptAdapter {
            color: mixerAssignmentColor(customKnobAssignmentMixerFx.value)
            brightness: customKnobAssignmentMixerFx.value;
            onPress: {
              lastTouchedButtonRightSideProp.value = 3
              if (customKnobAssignmentMixerFx.value < 4) customKnobAssignmentMixerFx.value = customKnobAssignmentMixerFx.value + 1;
              else customKnobAssignmentMixerFx.value = 0
            }
            onRelease: {
              customLayerAssignmentMixerFx.value = alignKnobAssignments(customKnobAssignmentEqHigh.value, customLayerAssignmentEqHigh.value, customKnobAssignmentMixerFx.value, customLayerAssignmentMixerFx.value)
              customLayerAssignmentMixerFx.value = alignKnobAssignments(customKnobAssignmentEqMid.value, customLayerAssignmentEqMid.value, customKnobAssignmentMixerFx.value, customLayerAssignmentMixerFx.value)
              customLayerAssignmentMixerFx.value = alignKnobAssignments(customKnobAssignmentEqMidLow.value, customLayerAssignmentEqMidLow.value, customKnobAssignmentMixerFx.value, customLayerAssignmentMixerFx.value)
              customLayerAssignmentMixerFx.value = alignKnobAssignments(customKnobAssignmentEqLow.value, customLayerAssignmentEqLow.value, customKnobAssignmentMixerFx.value, customLayerAssignmentMixerFx.value)
              customLayerAssignmentMixerFx.value = alignKnobAssignments(customKnobAssignmentVolume.value, customLayerAssignmentVolume.value, customKnobAssignmentMixerFx.value, customLayerAssignmentMixerFx.value)
              customLayerAssignmentMixerFx.value = alignKnobAssignments(customKnobAssignmentGain.value, customLayerAssignmentGain.value, customKnobAssignmentMixerFx.value, customLayerAssignmentMixerFx.value)
            }
          }
        }
      }

      WiresGroup {
        enabled: shift
        
        Wire {
          enabled: customKnobAssignmentEqHigh.value != 0
          from: "%surface%.left.fx.buttons.1"; to: ButtonScriptAdapter {
            color: mixerAssignmentLayerColor(customLayerAssignmentEqHigh.value)
            brightness: 1.0;
            onPress: {
              lastTouchedButtonLeftSideProp.value = 5
              if (customLayerAssignmentEqHigh.value < 2) customLayerAssignmentEqHigh.value = customLayerAssignmentEqHigh.value + 1;
              else customLayerAssignmentEqHigh.value = 0
            }
            onRelease: {
              customLayerAssignmentEqMid.value = alignKnobAssignments(customKnobAssignmentEqHigh.value, customLayerAssignmentEqHigh.value, customKnobAssignmentEqMid.value, customLayerAssignmentEqMid.value)
              customLayerAssignmentEqMidLow.value = alignKnobAssignments(customKnobAssignmentEqHigh.value, customLayerAssignmentEqHigh.value, customKnobAssignmentEqMidLow.value, customLayerAssignmentEqMidLow.value)
              customLayerAssignmentEqLow.value = alignKnobAssignments(customKnobAssignmentEqHigh.value, customLayerAssignmentEqHigh.value, customKnobAssignmentEqLow.value, customLayerAssignmentEqLow.value)
              customLayerAssignmentVolume.value = alignKnobAssignments(customKnobAssignmentEqHigh.value, customLayerAssignmentEqHigh.value, customKnobAssignmentVolume.value, customLayerAssignmentVolume.value)
              customLayerAssignmentGain.value = alignKnobAssignments(customKnobAssignmentEqHigh.value, customLayerAssignmentEqHigh.value, customKnobAssignmentGain.value, customLayerAssignmentGain.value)
              customLayerAssignmentMixerFx.value = alignKnobAssignments(customKnobAssignmentEqHigh.value, customLayerAssignmentEqHigh.value, customKnobAssignmentMixerFx.value, customLayerAssignmentMixerFx.value)
            }
          }
        }
        Wire {
          enabled: customKnobAssignmentEqMid.value != 0
          from: "%surface%.left.fx.buttons.2"; to: ButtonScriptAdapter {
            color: mixerAssignmentLayerColor(customLayerAssignmentEqMid.value)
            brightness: 1.0;
            onPress: {
              lastTouchedButtonLeftSideProp.value = 6
              if (customLayerAssignmentEqMid.value < 2) customLayerAssignmentEqMid.value = customLayerAssignmentEqMid.value + 1;
              else customLayerAssignmentEqMid.value = 0
            }
            onRelease: {
              customLayerAssignmentEqHigh.value = alignKnobAssignments(customKnobAssignmentEqMid.value, customLayerAssignmentEqMid.value, customKnobAssignmentEqHigh.value, customLayerAssignmentEqHigh.value)
              customLayerAssignmentEqMidLow.value = alignKnobAssignments(customKnobAssignmentEqMid.value, customLayerAssignmentEqMid.value, customKnobAssignmentEqMidLow.value, customLayerAssignmentEqMidLow.value)
              customLayerAssignmentEqLow.value = alignKnobAssignments(customKnobAssignmentEqMid.value, customLayerAssignmentEqMid.value, customKnobAssignmentEqLow.value, customLayerAssignmentEqLow.value)
              customLayerAssignmentVolume.value = alignKnobAssignments(customKnobAssignmentEqMid.value, customLayerAssignmentEqMid.value, customKnobAssignmentVolume.value, customLayerAssignmentVolume.value)
              customLayerAssignmentGain.value = alignKnobAssignments(customKnobAssignmentEqMid.value, customLayerAssignmentEqMid.value, customKnobAssignmentGain.value, customLayerAssignmentGain.value)
              customLayerAssignmentMixerFx.value = alignKnobAssignments(customKnobAssignmentEqMid.value, customLayerAssignmentEqMid.value, customKnobAssignmentMixerFx.value, customLayerAssignmentMixerFx.value)
            }
          }
        }
        Wire {
          enabled: customKnobAssignmentEqMidLow.value != 0
          from: "%surface%.left.fx.buttons.3"; to: ButtonScriptAdapter {
            color: mixerAssignmentLayerColor(customLayerAssignmentEqMidLow.value)
            brightness: 1.0;
            onPress: {
              lastTouchedButtonLeftSideProp.value = 7
              if (customLayerAssignmentEqMidLow.value < 2) customLayerAssignmentEqMidLow.value = customLayerAssignmentEqMidLow.value + 1;
              else customLayerAssignmentEqMidLow.value = 0
            }
            onRelease: {
              customLayerAssignmentEqHigh.value = alignKnobAssignments(customKnobAssignmentEqMidLow.value, customLayerAssignmentEqMidLow.value, customKnobAssignmentEqHigh.value, customLayerAssignmentEqHigh.value)
              customLayerAssignmentEqMid.value = alignKnobAssignments(customKnobAssignmentEqMidLow.value, customLayerAssignmentEqMidLow.value, customKnobAssignmentEqMid.value, customLayerAssignmentEqMid.value)
              customLayerAssignmentEqLow.value = alignKnobAssignments(customKnobAssignmentEqMidLow.value, customLayerAssignmentEqMidLow.value, customKnobAssignmentEqLow.value, customLayerAssignmentEqLow.value)
              customLayerAssignmentVolume.value = alignKnobAssignments(customKnobAssignmentEqMidLow.value, customLayerAssignmentEqMidLow.value, customKnobAssignmentVolume.value, customLayerAssignmentVolume.value)
              customLayerAssignmentGain.value = alignKnobAssignments(customKnobAssignmentEqMidLow.value, customLayerAssignmentEqMidLow.value, customKnobAssignmentGain.value, customLayerAssignmentGain.value)
              customLayerAssignmentMixerFx.value = alignKnobAssignments(customKnobAssignmentEqMidLow.value, customLayerAssignmentEqMidLow.value, customKnobAssignmentMixerFx.value, customLayerAssignmentMixerFx.value)
            }
          }
        }
        Wire {
          enabled: customKnobAssignmentEqLow.value != 0
          from: "%surface%.left.fx.buttons.4"; to: ButtonScriptAdapter {
            color: mixerAssignmentLayerColor(customLayerAssignmentEqLow.value)
            brightness: 1.0;
            onPress: {
              lastTouchedButtonLeftSideProp.value = 8
              if (customLayerAssignmentEqLow.value < 2) customLayerAssignmentEqLow.value = customLayerAssignmentEqLow.value + 1;
              else customLayerAssignmentEqLow.value = 0
            }
            onRelease: {
              customLayerAssignmentEqHigh.value = alignKnobAssignments(customKnobAssignmentEqLow.value, customLayerAssignmentEqLow.value, customKnobAssignmentEqHigh.value, customLayerAssignmentEqHigh.value)
              customLayerAssignmentEqMid.value = alignKnobAssignments(customKnobAssignmentEqLow.value, customLayerAssignmentEqLow.value, customKnobAssignmentEqMid.value, customLayerAssignmentEqMid.value)
              customLayerAssignmentEqMidLow.value = alignKnobAssignments(customKnobAssignmentEqLow.value, customLayerAssignmentEqLow.value, customKnobAssignmentEqMidLow.value, customLayerAssignmentEqMidLow.value)
              customLayerAssignmentVolume.value = alignKnobAssignments(customKnobAssignmentEqLow.value, customLayerAssignmentEqLow.value, customKnobAssignmentVolume.value, customLayerAssignmentVolume.value)
              customLayerAssignmentGain.value = alignKnobAssignments(customKnobAssignmentEqLow.value, customLayerAssignmentEqLow.value, customKnobAssignmentGain.value, customLayerAssignmentGain.value)
              customLayerAssignmentMixerFx.value = alignKnobAssignments(customKnobAssignmentEqLow.value, customLayerAssignmentEqLow.value, customKnobAssignmentMixerFx.value, customLayerAssignmentMixerFx.value)
            }
          }
        }

        Wire {
          enabled: customKnobAssignmentVolume.value != 0
          from: "%surface%.right.fx.buttons.1"; to: ButtonScriptAdapter {
            color: mixerAssignmentLayerColor(customLayerAssignmentVolume.value)
            brightness: 1.0;
            onPress: {
              lastTouchedButtonRightSideProp.value = 5
              if (customLayerAssignmentVolume.value < 2) customLayerAssignmentVolume.value = customLayerAssignmentVolume.value + 1;
              else customLayerAssignmentVolume.value = 0
            }
            onRelease: {
              customLayerAssignmentEqHigh.value = alignKnobAssignments(customKnobAssignmentVolume.value, customLayerAssignmentVolume.value, customKnobAssignmentEqHigh.value, customLayerAssignmentEqHigh.value)
              customLayerAssignmentEqMid.value = alignKnobAssignments(customKnobAssignmentVolume.value, customLayerAssignmentVolume.value, customKnobAssignmentEqMid.value, customLayerAssignmentEqMid.value)
              customLayerAssignmentEqMidLow.value = alignKnobAssignments(customKnobAssignmentVolume.value, customLayerAssignmentVolume.value, customKnobAssignmentEqMidLow.value, customLayerAssignmentEqMidLow.value)
              customLayerAssignmentEqLow.value = alignKnobAssignments(customKnobAssignmentVolume.value, customLayerAssignmentVolume.value, customKnobAssignmentEqLow.value, customLayerAssignmentEqLow.value)
              customLayerAssignmentGain.value = alignKnobAssignments(customKnobAssignmentVolume.value, customLayerAssignmentVolume.value, customKnobAssignmentGain.value, customLayerAssignmentGain.value)
              customLayerAssignmentMixerFx.value = alignKnobAssignments(customKnobAssignmentVolume.value, customLayerAssignmentVolume.value, customKnobAssignmentMixerFx.value, customLayerAssignmentMixerFx.value)
            }
          }
        }
        Wire {
          enabled: customKnobAssignmentGain.value != 0
          from: "%surface%.right.fx.buttons.2"; to: ButtonScriptAdapter {
            color: mixerAssignmentLayerColor(customLayerAssignmentGain.value)
            brightness: 1.0;
            onPress: {
              lastTouchedButtonRightSideProp.value = 6
              if (customLayerAssignmentGain.value < 2) customLayerAssignmentGain.value = customLayerAssignmentGain.value + 1;
              else customLayerAssignmentGain.value = 0
            }
            onRelease: {
              customLayerAssignmentEqHigh.value = alignKnobAssignments(customKnobAssignmentGain.value, customLayerAssignmentGain.value, customKnobAssignmentEqHigh.value, customLayerAssignmentEqHigh.value)
              customLayerAssignmentEqMid.value = alignKnobAssignments(customKnobAssignmentGain.value, customLayerAssignmentGain.value, customKnobAssignmentEqMid.value, customLayerAssignmentEqMid.value)
              customLayerAssignmentEqMidLow.value = alignKnobAssignments(customKnobAssignmentGain.value, customLayerAssignmentGain.value, customKnobAssignmentEqMidLow.value, customLayerAssignmentEqMidLow.value)
              customLayerAssignmentEqLow.value = alignKnobAssignments(customKnobAssignmentGain.value, customLayerAssignmentGain.value, customKnobAssignmentEqLow.value, customLayerAssignmentEqLow.value)
              customLayerAssignmentVolume.value = alignKnobAssignments(customKnobAssignmentGain.value, customLayerAssignmentGain.value, customKnobAssignmentVolume.value, customLayerAssignmentVolume.value)
              customLayerAssignmentMixerFx.value = alignKnobAssignments(customKnobAssignmentGain.value, customLayerAssignmentGain.value, customKnobAssignmentMixerFx.value, customLayerAssignmentMixerFx.value)
            }
          }
        }
        Wire {
          enabled: customKnobAssignmentMixerFx.value != 0
          from: "%surface%.right.fx.buttons.3"; to: ButtonScriptAdapter {
            color: mixerAssignmentLayerColor(customLayerAssignmentMixerFx.value)
            brightness: 1.0;
            onPress: {
              lastTouchedButtonRightSideProp.value = 7
              if (customLayerAssignmentMixerFx.value < 2) customLayerAssignmentMixerFx.value = customLayerAssignmentMixerFx.value + 1;
              else customLayerAssignmentMixerFx.value = 0
            }
            onRelease: {
              customLayerAssignmentEqHigh.value = alignKnobAssignments(customKnobAssignmentMixerFx.value, customLayerAssignmentMixerFx.value, customKnobAssignmentEqHigh.value, customLayerAssignmentEqHigh.value)
              customLayerAssignmentEqMid.value = alignKnobAssignments(customKnobAssignmentMixerFx.value, customLayerAssignmentMixerFx.value, customKnobAssignmentEqMid.value, customLayerAssignmentEqMid.value)
              customLayerAssignmentEqMidLow.value = alignKnobAssignments(customKnobAssignmentMixerFx.value, customLayerAssignmentMixerFx.value, customKnobAssignmentEqMidLow.value, customLayerAssignmentEqMidLow.value)
              customLayerAssignmentEqLow.value = alignKnobAssignments(customKnobAssignmentMixerFx.value, customLayerAssignmentMixerFx.value, customKnobAssignmentEqLow.value, customLayerAssignmentEqLow.value)
              customLayerAssignmentVolume.value = alignKnobAssignments(customKnobAssignmentMixerFx.value, customLayerAssignmentMixerFx.value, customKnobAssignmentVolume.value, customLayerAssignmentVolume.value)
              customLayerAssignmentGain.value = alignKnobAssignments(customKnobAssignmentMixerFx.value, customLayerAssignmentMixerFx.value, customKnobAssignmentGain.value, customLayerAssignmentGain.value)
            }
          }
        }
      }
      
      Wire {
        from: "%surface%.right.fx.buttons.4"
        to: ButtonScriptAdapter {
          color: Color.Magenta
          brightness: customMixerOverlayBlockProp.value
          onPress: {
            lastTouchedButtonRightSideProp.value = 4
            customMixerOverlayBlockProp.value = !customMixerOverlayBlockProp.value
          }
        }
      }
      
    }

    WiresGroup {
      enabled: (deviceSetupPageProp.value == 2)
      
      // BROWSER
      Wire {
        from: "%surface%.left.fx.buttons.1"
        to: ButtonScriptAdapter {
          color: Color.White
          brightness: maximizeBrowserWhenBrowsingProp.value
          onPress: {
            lastTouchedButtonLeftSideProp.value = 10 //change number and then labels in screen display file
            maximizeBrowserWhenBrowsingProp.value = !maximizeBrowserWhenBrowsingProp.value
          }
        }
      }

      Wire {
        from: "%surface%.left.fx.buttons.2"
        to: ButtonScriptAdapter {
          color: Color.White
          brightness: customBrowserModeProp.value
          onPress: {
            lastTouchedButtonLeftSideProp.value = 9 //change number and then labels in screen display file
            customBrowserModeProp.value = !customBrowserModeProp.value
          }
        }
      }

      Wire {
        enabled: customBrowserModeProp.value
        from: "%surface%.left.fx.buttons.3"
        to: ButtonScriptAdapter {
          color: Color.White
          brightness: minimizeBrowserWhenLoadingProp.value
          onPress: {
            lastTouchedButtonLeftSideProp.value = 11
            minimizeBrowserWhenLoadingProp.value = !minimizeBrowserWhenLoadingProp.value
          }
        }
      }
      
      Wire {
        from: "%surface%.left.fx.buttons.4"
        to: ButtonScriptAdapter {
          color: Color.LightOrange
          brightness: customDeckSwitchOnSingleClickProp.value
          onPress: {
            lastTouchedButtonLeftSideProp.value = 12
            customDeckSwitchOnSingleClickProp.value = !customDeckSwitchOnSingleClickProp.value
          }
        }
      }
      
      
      // DISPLAY MAIN INFO - REMAINING TIME (BEATS TO CUE) / ELAPSED TIME (BEATS) / LOOP SIZE
      Wire {
        from: "%surface%.right.fx.buttons.1"
        to: ButtonScriptAdapter {
          color: Color.Blue
          brightness: (deckDisplayMainInfoProp.value < 2) ? 1.0 : 0.0
          onPress: {
            lastTouchedButtonRightSideProp.value = 9
            if (deckDisplayMainInfoProp.value < 2) deckDisplayMainInfoProp.value = deckDisplayMainInfoProp.value + 1;
            else deckDisplayMainInfoProp.value = 0
          }
        }
      }
      
      Wire {
        enabled: (deckDisplayMainInfoProp.value < 2)
        from: "%surface%.right.fx.buttons.2"
        to: ButtonScriptAdapter {
          color: Color.Blue
          brightness: customBeatCounterEngagedProp.value
          onPress: {
            lastTouchedButtonRightSideProp.value = 10
            customBeatCounterEngagedProp.value = !customBeatCounterEngagedProp.value
          }
        }
      }
      
      Wire {
        enabled: (deckDisplayMainInfoProp.value < 2) // && customBeatCounterEngagedProp.value
        from: "%surface%.right.fx.buttons.3"
        to: ButtonScriptAdapter {
          color: Color.Turquoise
          brightness: (customBeatCounterPhraseLengthProp.value > 0) ? 1.0 : 0.0
          onPress: {
            lastTouchedButtonRightSideProp.value = 11
            customBeatCounterPhraseLengthProp.value = customBeatCounterPhraseLengthProp.value - 1
          }
        }
      }

      Wire {
        enabled: (deckDisplayMainInfoProp.value < 2) // && customBeatCounterEngagedProp.value
        from: "%surface%.right.fx.buttons.4"
        to: ButtonScriptAdapter {
          color: Color.Turquoise
          brightness: (customBeatCounterPhraseLengthProp.value < 6) ? 1.0 : 0.0
          onPress: {
            lastTouchedButtonRightSideProp.value = 11
            customBeatCounterPhraseLengthProp.value = customBeatCounterPhraseLengthProp.value + 1
          }
        }
      }
    }
    
    WiresGroup {
      enabled: (deviceSetupPageProp.value == 3)
      
      // MISCELLANEOUS
      Wire {
        from: "%surface%.left.fx.buttons.1"
        to: ButtonScriptAdapter {
          color: Color.Blue
          brightness: customSingleCueMonitorProp.value
          onPress: {
            lastTouchedButtonLeftSideProp.value = 13
            customSingleCueMonitorProp.value = !customSingleCueMonitorProp.value
          }
        }
      }
      
      Wire {
        from: "%surface%.left.fx.buttons.2"
        to: ButtonScriptAdapter {
          color: Color.Violet
          brightness: customSubchannelMuteSendFXProp.value
          onPress: {
            lastTouchedButtonLeftSideProp.value = 14
            customSubchannelMuteSendFXProp.value = !customSubchannelMuteSendFXProp.value
          }
        }
      }
      
      Wire {
        from: "%surface%.left.fx.buttons.3"
        to: ButtonScriptAdapter {
          color: Color.WarmYellow
          brightness: customCueAndPlayProp.value
          onPress: {
            lastTouchedButtonLeftSideProp.value = 15
            customCueAndPlayProp.value = !customCueAndPlayProp.value
          }
        }
      }
      
      Wire {
        from: "%surface%.left.fx.buttons.4"
        to: ButtonScriptAdapter {
          color: Color.Blue
          brightness: customInvertMixerFxLedProp.value
          onPress: {
            lastTouchedButtonLeftSideProp.value = 16
            customInvertMixerFxLedProp.value = !customInvertMixerFxLedProp.value
          }
        }
      }
      
      
      Wire {
        from: "%surface%.right.fx.buttons.1"
        to: ButtonScriptAdapter {
          color: Color.Plum
          brightness: customOvermappingEngagedProp.value
          onPress: {
            lastTouchedButtonRightSideProp.value = 13
            customOvermappingEngagedProp.value = !customOvermappingEngagedProp.value
          }
        }
      }
      
      // EFFECTS
      Wire {
        from: "%surface%.right.fx.buttons.2"
        to: ButtonScriptAdapter {
          color: Color.WarmYellow
          brightness: customFxAssignmentsUnitFocusProp.value
          onPress: {
            lastTouchedButtonRightSideProp.value = 14
            customFxAssignmentsUnitFocusProp.value = !customFxAssignmentsUnitFocusProp.value
          }
        }
      }
      
      Wire {
        enabled: fxMode.value != FxMode.TwoFxUnits
        from: "%surface%.right.fx.buttons.3"
        to: ButtonScriptAdapter {
          color: Color.Yellow
          brightness: customLinkFXOverlayToDeckProp.value
          onPress: {
            lastTouchedButtonRightSideProp.value = 15
            customLinkFXOverlayToDeckProp.value = !customLinkFXOverlayToDeckProp.value
          }
        }
      }
      
      Wire {
        enabled: (fxMode.value != FxMode.TwoFxUnits) && !customLinkFXOverlayToDeckProp.value
        from: "%surface%.right.fx.buttons.4"
        to: ButtonScriptAdapter {
          color: Color.Lime
          brightness: customSecondaryFXOverlayBlockProp.value
          onPress: {
            lastTouchedButtonRightSideProp.value = 16
            customSecondaryFXOverlayBlockProp.value = !customSecondaryFXOverlayBlockProp.value
          }
        }
      }
    }
    
  }
  
}
