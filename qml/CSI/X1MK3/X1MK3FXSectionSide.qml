import CSI 1.0
import QtQuick 2.0

import "Defines"

Module
{
  id: module
  property bool shift: false
  property bool active: false
  property int layer: 0
  property int deckIdx: 0
  property int primaryUnitIdx: 0
  property int secondaryUnitIdx: 0
  property string surface: ""
  property string propertiesPath: ""

  //------------------------SUBMODULES----------------------------

  MappingPropertyDescriptor { path: module.propertiesPath + ".active_deck"; type: MappingPropertyDescriptor.Integer; value: module.deckIdx }
  MappingPropertyDescriptor { path: module.propertiesPath + ".primary_fx_unit"; type: MappingPropertyDescriptor.Integer; value: module.primaryUnitIdx }
  MappingPropertyDescriptor { path: module.propertiesPath + ".secondary_fx_unit"; type: MappingPropertyDescriptor.Integer; value: module.secondaryUnitIdx }

  MappingPropertyDescriptor { id: lastActiveKnobProp; path: module.propertiesPath + ".last_active_knob"; type: MappingPropertyDescriptor.Integer; value: 1 }

  // Screen
  KontrolScreen { name: "fx_screen"; propertiesPath: module.propertiesPath; flavor: ScreenFlavor.X1MK3_FX }
  Wire { from: "fx_screen.output"; to: "%surface%.display" }

  MappingPropertyDescriptor { path: module.propertiesPath + ".knobs_are_active"; type: MappingPropertyDescriptor.Boolean; value: false }
  MappingPropertyDescriptor { path: module.propertiesPath + ".buttons_are_active"; type: MappingPropertyDescriptor.Boolean; value: false }
  // SwitchTimer { name: "knobs_activity_timer"; setTimeout: 0; resetTimeout: 1000 }
  SwitchTimer { name: "knobs_activity_timer"; setTimeout: 0; resetTimeout: 100 }
  SwitchTimer { name: "buttons_activity_timer"; setTimeout: 0; resetTimeout: 500 }

  //  SUPERKNOB CASCADE SWITCHES
  property bool eqHighOnlyActive:          ( (customKnobAssignmentEqHigh.value != customKnobAssignmentEqMid.value)
                                          || (customLayerAssignmentEqHigh.value != customLayerAssignmentEqMid.value) )
                                        && ( (customKnobAssignmentEqHigh.value != customKnobAssignmentEqMidLow.value)
                                          || (customLayerAssignmentEqHigh.value != customLayerAssignmentEqMidLow.value) )
                                        && ( (customKnobAssignmentEqHigh.value != customKnobAssignmentEqLow.value)
                                          || (customLayerAssignmentEqHigh.value != customLayerAssignmentEqLow.value) )
                                        && ( (customKnobAssignmentEqHigh.value != customKnobAssignmentVolume.value)
                                          || (customLayerAssignmentEqHigh.value != customLayerAssignmentVolume.value) )
                                        && ( (customKnobAssignmentEqHigh.value != customKnobAssignmentGain.value)
                                          || (customLayerAssignmentEqHigh.value != customLayerAssignmentGain.value) )
                                        && ( (customKnobAssignmentEqHigh.value != customKnobAssignmentMixerFx.value)
                                          || (customLayerAssignmentEqHigh.value != customLayerAssignmentMixerFx.value) )
  property bool midSuperknobActive:        ( (customKnobAssignmentEqMid.value != customKnobAssignmentEqHigh.value)
                                          || (customLayerAssignmentEqMid.value != customLayerAssignmentEqHigh.value) )
  property bool eqMidOnlyActive:             ( midSuperknobActive )
                                        && ( (customKnobAssignmentEqMid.value != customKnobAssignmentEqMidLow.value)
                                          || (customLayerAssignmentEqMid.value != customLayerAssignmentEqMidLow.value) )
                                        && ( (customKnobAssignmentEqMid.value != customKnobAssignmentEqLow.value)
                                          || (customLayerAssignmentEqMid.value != customLayerAssignmentEqLow.value) )
                                        && ( (customKnobAssignmentEqMid.value != customKnobAssignmentVolume.value)
                                          || (customLayerAssignmentEqMid.value != customLayerAssignmentVolume.value) )
                                        && ( (customKnobAssignmentEqMid.value != customKnobAssignmentGain.value)
                                          || (customLayerAssignmentEqMid.value != customLayerAssignmentGain.value) )
                                        && ( (customKnobAssignmentEqMid.value != customKnobAssignmentMixerFx.value)
                                          || (customLayerAssignmentEqMid.value != customLayerAssignmentMixerFx.value) )
  property bool midLowSuperknobActive:     ( (customKnobAssignmentEqMidLow.value != customKnobAssignmentEqHigh.value)
                                          || (customLayerAssignmentEqMidLow.value != customLayerAssignmentEqHigh.value) )
                                        && ( (customKnobAssignmentEqMidLow.value != customKnobAssignmentEqMid.value)
                                          || (customLayerAssignmentEqMidLow.value != customLayerAssignmentEqMid.value) )
  property bool eqMidLowOnlyActive:          ( midLowSuperknobActive )
                                        && ( (customKnobAssignmentEqMidLow.value != customKnobAssignmentEqLow.value)
                                          || (customLayerAssignmentEqMidLow.value != customLayerAssignmentEqLow.value) )
                                        && ( (customKnobAssignmentEqMidLow.value != customKnobAssignmentVolume.value)
                                          || (customLayerAssignmentEqMidLow.value != customLayerAssignmentVolume.value) )
                                        && ( (customKnobAssignmentEqMidLow.value != customKnobAssignmentGain.value)
                                          || (customLayerAssignmentEqMidLow.value != customLayerAssignmentGain.value) )
                                        && ( (customKnobAssignmentEqMidLow.value != customKnobAssignmentMixerFx.value)
                                          || (customLayerAssignmentEqMidLow.value != customLayerAssignmentMixerFx.value) )
  property bool lowSuperknobActive:        ( (customKnobAssignmentEqLow.value != customKnobAssignmentEqHigh.value)
                                          || (customLayerAssignmentEqLow.value != customLayerAssignmentEqHigh.value) )
                                        && ( (customKnobAssignmentEqLow.value != customKnobAssignmentEqMid.value)
                                          || (customLayerAssignmentEqLow.value != customLayerAssignmentEqMid.value) )
                                        && ( (customKnobAssignmentEqLow.value != customKnobAssignmentEqMidLow.value)
                                          || (customLayerAssignmentEqLow.value != customLayerAssignmentEqMidLow.value) )
  property bool eqLowOnlyActive:             ( lowSuperknobActive )
                                        && ( (customKnobAssignmentEqLow.value != customKnobAssignmentVolume.value)
                                          || (customLayerAssignmentEqLow.value != customLayerAssignmentVolume.value) )
                                        && ( (customKnobAssignmentEqLow.value != customKnobAssignmentGain.value)
                                          || (customLayerAssignmentEqLow.value != customLayerAssignmentGain.value) )
                                        && ( (customKnobAssignmentEqLow.value != customKnobAssignmentMixerFx.value)
                                          || (customLayerAssignmentEqLow.value != customLayerAssignmentMixerFx.value) )
  property bool volumeSuperknobActive:     ( (customKnobAssignmentVolume.value != customKnobAssignmentEqHigh.value)
                                          || (customLayerAssignmentVolume.value != customLayerAssignmentEqHigh.value) )
                                        && ( (customKnobAssignmentVolume.value != customKnobAssignmentEqMid.value)
                                          || (customLayerAssignmentVolume.value != customLayerAssignmentEqMid.value) )
                                        && ( (customKnobAssignmentVolume.value != customKnobAssignmentEqMidLow.value)
                                          || (customLayerAssignmentVolume.value != customLayerAssignmentEqMidLow.value) )
                                        && ( (customKnobAssignmentVolume.value != customKnobAssignmentEqLow.value)
                                          || (customLayerAssignmentVolume.value != customLayerAssignmentEqLow.value) )
  property bool volumeOnlyActive:            ( volumeSuperknobActive )
                                        && ( (customKnobAssignmentVolume.value != customKnobAssignmentGain.value)
                                          || (customLayerAssignmentVolume.value != customLayerAssignmentGain.value) )
                                        && ( (customKnobAssignmentVolume.value != customKnobAssignmentMixerFx.value)
                                          || (customLayerAssignmentVolume.value != customLayerAssignmentMixerFx.value) )
  property bool gainSuperknobActive:       ( (customKnobAssignmentGain.value != customKnobAssignmentEqHigh.value)
                                          || (customLayerAssignmentGain.value != customLayerAssignmentEqHigh.value) )
                                        && ( (customKnobAssignmentGain.value != customKnobAssignmentEqMid.value)
                                          || (customLayerAssignmentGain.value != customLayerAssignmentEqMid.value) )
                                        && ( (customKnobAssignmentGain.value != customKnobAssignmentEqMidLow.value)
                                          || (customLayerAssignmentGain.value != customLayerAssignmentEqMidLow.value) )
                                        && ( (customKnobAssignmentGain.value != customKnobAssignmentEqLow.value)
                                          || (customLayerAssignmentGain.value != customLayerAssignmentEqLow.value) )
                                        && ( (customKnobAssignmentGain.value != customKnobAssignmentVolume.value)
                                          || (customLayerAssignmentGain.value != customLayerAssignmentVolume.value) )
  property bool gainOnlyActive:              ( gainSuperknobActive )
                                        && ( (customKnobAssignmentGain.value != customKnobAssignmentMixerFx.value)
                                          || (customLayerAssignmentGain.value != customLayerAssignmentMixerFx.value) )
  property bool mixerFxSuperknobActive:    ( (customKnobAssignmentMixerFx.value != customKnobAssignmentEqHigh.value)
                                          || (customLayerAssignmentMixerFx.value != customLayerAssignmentEqHigh.value) )
                                        && ( (customKnobAssignmentMixerFx.value != customKnobAssignmentEqMid.value)
                                          || (customLayerAssignmentMixerFx.value != customLayerAssignmentEqMid.value) )
                                        && ( (customKnobAssignmentMixerFx.value != customKnobAssignmentEqMidLow.value)
                                          || (customLayerAssignmentMixerFx.value != customLayerAssignmentEqMidLow.value) )
                                        && ( (customKnobAssignmentMixerFx.value != customKnobAssignmentEqLow.value)
                                          || (customLayerAssignmentMixerFx.value != customLayerAssignmentEqLow.value) )
                                        && ( (customKnobAssignmentMixerFx.value != customKnobAssignmentVolume.value)
                                          || (customLayerAssignmentMixerFx.value != customLayerAssignmentVolume.value) )
                                        && ( (customKnobAssignmentMixerFx.value != customKnobAssignmentGain.value)
                                          || (customLayerAssignmentMixerFx.value != customLayerAssignmentGain.value) )

  // Knobs activity
  WiresGroup
  {
    enabled: module.active

    Wire {
      from: Or
      {
        inputs:
        [
          "%surface%.knobs.1.is_turned",
          "%surface%.knobs.2.is_turned",
          "%surface%.knobs.3.is_turned",
          "%surface%.knobs.4.is_turned"
        ]
      }
      to: "knobs_activity_timer.input"
    }

    Wire { from: "knobs_activity_timer.output.value"; to: ValuePropertyAdapter { path: module.propertiesPath + ".knobs_are_active"; output: false } }
    Wire { from: "buttons_activity_timer.output.value"; to: ValuePropertyAdapter { path: module.propertiesPath + ".buttons_are_active"; output: false } }

    Wire { from: "%surface%.knobs.1"; to: KnobScriptAdapter { onTurn: { lastActiveKnobProp.value = 1 } } }
    Wire { from: "%surface%.knobs.2"; to: KnobScriptAdapter { onTurn: { lastActiveKnobProp.value = 2 } } }
    Wire { from: "%surface%.knobs.3"; to: KnobScriptAdapter { onTurn: { lastActiveKnobProp.value = 3 } } }
    Wire { from: "%surface%.knobs.4"; to: KnobScriptAdapter { onTurn: { lastActiveKnobProp.value = 4 } } }
  }

  // Soft takeover
  SoftTakeover { name: "softtakeover1" }
  SoftTakeover { name: "softtakeover2" }
  SoftTakeover { name: "softtakeover3" }
  SoftTakeover { name: "softtakeover4" }

  MappingPropertyDescriptor { path: module.propertiesPath + ".softtakeover.1.direction"; type: MappingPropertyDescriptor.Integer; value: 0 }
  MappingPropertyDescriptor { path: module.propertiesPath + ".softtakeover.2.direction"; type: MappingPropertyDescriptor.Integer; value: 0 }
  MappingPropertyDescriptor { path: module.propertiesPath + ".softtakeover.3.direction"; type: MappingPropertyDescriptor.Integer; value: 0 }
  MappingPropertyDescriptor { path: module.propertiesPath + ".softtakeover.4.direction"; type: MappingPropertyDescriptor.Integer; value: 0 }

  WiresGroup
  {
    enabled: module.active

    Wire { from: "%surface%.knobs.1"; to: "softtakeover1.input" }
    Wire { from: "%surface%.knobs.2"; to: "softtakeover2.input" }
    Wire { from: "%surface%.knobs.3"; to: "softtakeover3.input" }
    Wire { from: "%surface%.knobs.4"; to: "softtakeover4.input" }

    Wire { from: "softtakeover1.direction_monitor"; to: DirectPropertyAdapter { path: module.propertiesPath + ".softtakeover.1.direction" } }
    Wire { from: "softtakeover2.direction_monitor"; to: DirectPropertyAdapter { path: module.propertiesPath + ".softtakeover.2.direction" } }
    Wire { from: "softtakeover3.direction_monitor"; to: DirectPropertyAdapter { path: module.propertiesPath + ".softtakeover.3.direction" } }
    Wire { from: "softtakeover4.direction_monitor"; to: DirectPropertyAdapter { path: module.propertiesPath + ".softtakeover.4.direction" } }
  }

  // FX units
  FxUnit { name: "fx_unit_1"; channel: 1 }
  FxUnit { name: "fx_unit_2"; channel: 2 }
  FxUnit { name: "fx_unit_3"; channel: 3 }
  FxUnit { name: "fx_unit_4"; channel: 4 }

  AppProperty { id: fxUnit1Type; path: "app.traktor.fx.1.type" }
  AppProperty { id: fxUnit2Type; path: "app.traktor.fx.2.type" }
  AppProperty { id: fxUnit3Type; path: "app.traktor.fx.3.type" }
  AppProperty { id: fxUnit4Type; path: "app.traktor.fx.4.type" }

  WiresGroup
  {
    enabled: module.active

    WiresGroup
    {
      enabled: (module.layer === FXSectionLayer.fx_primary && module.primaryUnitIdx === 1) ||
               (module.layer === FXSectionLayer.fx_secondary && module.secondaryUnitIdx === 1)

      WiresGroup
      {
        enabled: !shift

        Wire { from: "%surface%.buttons.1";   to: "fx_unit_1.enabled" }
        Wire { from: "%surface%.buttons.2";   to: "fx_unit_1.button1" }
        Wire { from: "%surface%.buttons.3";   to: "fx_unit_1.button2" }
        Wire { from: "%surface%.buttons.4";   to: "fx_unit_1.button3" }

        Wire { from: "softtakeover1.output"; to: "fx_unit_1.dry_wet" }
        Wire { from: "softtakeover2.output"; to: "fx_unit_1.knob1" }
        Wire { from: "softtakeover3.output"; to: "fx_unit_1.knob2" }
        Wire { from: "softtakeover4.output"; to: "fx_unit_1.knob3" }
      }

      WiresGroup
      {
        enabled: shift

        WiresGroup
        {
          enabled: fxUnit1Type.value == FxType.Single

          Wire { from: "%surface%.buttons.1";   to: RelativePropertyAdapter{ path: "app.traktor.fx.1.type"; mode: RelativeMode.Increment; wrap: true; color: Color.DarkOrange } }
          Wire { from: "%surface%.buttons.2";   to: RelativePropertyAdapter{ path: "app.traktor.fx.1.select.1"; mode: RelativeMode.Decrement; wrap: true; color: Color.WarmYellow } }
          Wire { from: "%surface%.buttons.3";   to: RelativePropertyAdapter{ path: "app.traktor.fx.1.select.1"; mode: RelativeMode.Increment; wrap: true; color: Color.WarmYellow } }
        }

        WiresGroup
        {
          enabled: fxUnit1Type.value == FxType.Group

          Wire { from: "%surface%.buttons.1";   to: RelativePropertyAdapter{ path: "app.traktor.fx.1.type"; mode: RelativeMode.Increment; wrap: true; color: Color.DarkOrange } }
          Wire { from: "%surface%.buttons.2";   to: RelativePropertyAdapter{ path: "app.traktor.fx.1.select.1"; mode: RelativeMode.Increment; wrap: true; color: Color.WarmYellow } }
          Wire { from: "%surface%.buttons.3";   to: RelativePropertyAdapter{ path: "app.traktor.fx.1.select.2"; mode: RelativeMode.Increment; wrap: true; color: Color.WarmYellow } }
          Wire { from: "%surface%.buttons.4";   to: RelativePropertyAdapter{ path: "app.traktor.fx.1.select.3"; mode: RelativeMode.Increment; wrap: true; color: Color.WarmYellow } }
        }

        WiresGroup
        {
          enabled: fxUnit1Type.value == FxType.PatternPlayer

          Wire { from: "%surface%.buttons.1";   to: RelativePropertyAdapter{ path: "app.traktor.fx.1.type"; mode: RelativeMode.Increment; wrap: true; color: Color.Green } }
          Wire { from: "%surface%.buttons.2";   to: RelativePropertyAdapter{ path: "app.traktor.fx.1.kitSelect"; mode: RelativeMode.Decrement; wrap: true; color: Color.Cyan } }
          Wire { from: "%surface%.buttons.3";   to: RelativePropertyAdapter{ path: "app.traktor.fx.1.kitSelect"; mode: RelativeMode.Increment; wrap: true; color: Color.Cyan } }
        }
      }
    }

    WiresGroup
    {
      enabled: (module.layer === FXSectionLayer.fx_primary && module.primaryUnitIdx === 2) ||
               (module.layer === FXSectionLayer.fx_secondary && module.secondaryUnitIdx === 2)

      WiresGroup
      {
        enabled: !shift

        Wire { from: "%surface%.buttons.1";   to: "fx_unit_2.enabled" }
        Wire { from: "%surface%.buttons.2";   to: "fx_unit_2.button1" }
        Wire { from: "%surface%.buttons.3";   to: "fx_unit_2.button2" }
        Wire { from: "%surface%.buttons.4";   to: "fx_unit_2.button3" }

        Wire { from: "softtakeover1.output"; to: "fx_unit_2.dry_wet" }
        Wire { from: "softtakeover2.output"; to: "fx_unit_2.knob1" }
        Wire { from: "softtakeover3.output"; to: "fx_unit_2.knob2" }
        Wire { from: "softtakeover4.output"; to: "fx_unit_2.knob3" }
      }

      WiresGroup
      {
        enabled: shift

        WiresGroup
        {
          enabled: fxUnit2Type.value == FxType.Single

          Wire { from: "%surface%.buttons.1";   to: RelativePropertyAdapter{ path: "app.traktor.fx.2.type"; mode: RelativeMode.Increment; wrap: true; color: Color.DarkOrange } }
          Wire { from: "%surface%.buttons.2";   to: RelativePropertyAdapter{ path: "app.traktor.fx.2.select.1"; mode: RelativeMode.Decrement; wrap: true; color: Color.WarmYellow } }
          Wire { from: "%surface%.buttons.3";   to: RelativePropertyAdapter{ path: "app.traktor.fx.2.select.1"; mode: RelativeMode.Increment; wrap: true; color: Color.WarmYellow } }
        }

        WiresGroup
        {
          enabled: fxUnit2Type.value == FxType.Group

          Wire { from: "%surface%.buttons.1";   to: RelativePropertyAdapter{ path: "app.traktor.fx.2.type"; mode: RelativeMode.Increment; wrap: true; color: Color.DarkOrange } }
          Wire { from: "%surface%.buttons.2";   to: RelativePropertyAdapter{ path: "app.traktor.fx.2.select.1"; mode: RelativeMode.Increment; wrap: true; color: Color.WarmYellow } }
          Wire { from: "%surface%.buttons.3";   to: RelativePropertyAdapter{ path: "app.traktor.fx.2.select.2"; mode: RelativeMode.Increment; wrap: true; color: Color.WarmYellow } }
          Wire { from: "%surface%.buttons.4";   to: RelativePropertyAdapter{ path: "app.traktor.fx.2.select.3"; mode: RelativeMode.Increment; wrap: true; color: Color.WarmYellow } }
        }

        WiresGroup
        {
          enabled: fxUnit2Type.value == FxType.PatternPlayer

          Wire { from: "%surface%.buttons.1";   to: RelativePropertyAdapter{ path: "app.traktor.fx.2.type"; mode: RelativeMode.Increment; wrap: true; color: Color.Green } }
          Wire { from: "%surface%.buttons.2";   to: RelativePropertyAdapter{ path: "app.traktor.fx.2.kitSelect"; mode: RelativeMode.Decrement; wrap: true; color: Color.Cyan } }
          Wire { from: "%surface%.buttons.3";   to: RelativePropertyAdapter{ path: "app.traktor.fx.2.kitSelect"; mode: RelativeMode.Increment; wrap: true; color: Color.Cyan } }
        }
      }
    }

    WiresGroup
    {
      enabled: (module.layer === FXSectionLayer.fx_primary && module.primaryUnitIdx === 3) ||
               (module.layer === FXSectionLayer.fx_secondary && module.secondaryUnitIdx === 3)

      WiresGroup
      {
        enabled: !shift

        Wire { from: "%surface%.buttons.1";   to: "fx_unit_3.enabled" }
        Wire { from: "%surface%.buttons.2";   to: "fx_unit_3.button1" }
        Wire { from: "%surface%.buttons.3";   to: "fx_unit_3.button2" }
        Wire { from: "%surface%.buttons.4";   to: "fx_unit_3.button3" }

        Wire { from: "softtakeover1.output"; to: "fx_unit_3.dry_wet" }
        Wire { from: "softtakeover2.output"; to: "fx_unit_3.knob1" }
        Wire { from: "softtakeover3.output"; to: "fx_unit_3.knob2" }
        Wire { from: "softtakeover4.output"; to: "fx_unit_3.knob3" }
      }

      WiresGroup
      {
        enabled: shift

        WiresGroup
        {
          enabled: fxUnit3Type.value == FxType.Single

          Wire { from: "%surface%.buttons.1";   to: RelativePropertyAdapter{ path: "app.traktor.fx.3.type"; mode: RelativeMode.Increment; wrap: true; color: Color.DarkOrange } }
          Wire { from: "%surface%.buttons.2";   to: RelativePropertyAdapter{ path: "app.traktor.fx.3.select.1"; mode: RelativeMode.Decrement; wrap: true; color: Color.WarmYellow } }
          Wire { from: "%surface%.buttons.3";   to: RelativePropertyAdapter{ path: "app.traktor.fx.3.select.1"; mode: RelativeMode.Increment; wrap: true; color: Color.WarmYellow } }
        }

        WiresGroup
        {
          enabled: fxUnit3Type.value == FxType.Group

          Wire { from: "%surface%.buttons.1";   to: RelativePropertyAdapter{ path: "app.traktor.fx.3.type"; mode: RelativeMode.Increment; wrap: true; color: Color.DarkOrange } }
          Wire { from: "%surface%.buttons.2";   to: RelativePropertyAdapter{ path: "app.traktor.fx.3.select.1"; mode: RelativeMode.Increment; wrap: true; color: Color.WarmYellow } }
          Wire { from: "%surface%.buttons.3";   to: RelativePropertyAdapter{ path: "app.traktor.fx.3.select.2"; mode: RelativeMode.Increment; wrap: true; color: Color.WarmYellow } }
          Wire { from: "%surface%.buttons.4";   to: RelativePropertyAdapter{ path: "app.traktor.fx.3.select.3"; mode: RelativeMode.Increment; wrap: true; color: Color.WarmYellow } }
        }

        WiresGroup
        {
          enabled: fxUnit3Type.value == FxType.PatternPlayer

          Wire { from: "%surface%.buttons.1";   to: RelativePropertyAdapter{ path: "app.traktor.fx.3.type"; mode: RelativeMode.Increment; wrap: true; color: Color.Green } }
          Wire { from: "%surface%.buttons.2";   to: RelativePropertyAdapter{ path: "app.traktor.fx.3.kitSelect"; mode: RelativeMode.Decrement; wrap: true; color: Color.Cyan } }
          Wire { from: "%surface%.buttons.3";   to: RelativePropertyAdapter{ path: "app.traktor.fx.3.kitSelect"; mode: RelativeMode.Increment; wrap: true; color: Color.Cyan } }
        }
      }
    }

    WiresGroup
    {
      enabled: (module.layer === FXSectionLayer.fx_primary && module.primaryUnitIdx === 4) ||
               (module.layer === FXSectionLayer.fx_secondary && module.secondaryUnitIdx === 4)

      WiresGroup
      {
        enabled: !shift

        Wire { from: "%surface%.buttons.1";   to: "fx_unit_4.enabled" }
        Wire { from: "%surface%.buttons.2";   to: "fx_unit_4.button1" }
        Wire { from: "%surface%.buttons.3";   to: "fx_unit_4.button2" }
        Wire { from: "%surface%.buttons.4";   to: "fx_unit_4.button3" }

        Wire { from: "softtakeover1.output"; to: "fx_unit_4.dry_wet" }
        Wire { from: "softtakeover2.output"; to: "fx_unit_4.knob1" }
        Wire { from: "softtakeover3.output"; to: "fx_unit_4.knob2" }
        Wire { from: "softtakeover4.output"; to: "fx_unit_4.knob3" }
      }

      WiresGroup
      {
        enabled: shift

        WiresGroup
        {
          enabled: fxUnit4Type.value == FxType.Single

          Wire { from: "%surface%.buttons.1";   to: RelativePropertyAdapter{ path: "app.traktor.fx.4.type"; mode: RelativeMode.Increment; wrap: true; color: Color.DarkOrange } }
          Wire { from: "%surface%.buttons.2";   to: RelativePropertyAdapter{ path: "app.traktor.fx.4.select.1"; mode: RelativeMode.Decrement; wrap: true; color: Color.WarmYellow } }
          Wire { from: "%surface%.buttons.3";   to: RelativePropertyAdapter{ path: "app.traktor.fx.4.select.1"; mode: RelativeMode.Increment; wrap: true; color: Color.WarmYellow } }
        }

        WiresGroup
        {
          enabled: fxUnit4Type.value == FxType.Group

          Wire { from: "%surface%.buttons.1";   to: RelativePropertyAdapter{ path: "app.traktor.fx.4.type"; mode: RelativeMode.Increment; wrap: true; color: Color.DarkOrange } }
          Wire { from: "%surface%.buttons.2";   to: RelativePropertyAdapter{ path: "app.traktor.fx.4.select.1"; mode: RelativeMode.Increment; wrap: true; color: Color.WarmYellow } }
          Wire { from: "%surface%.buttons.3";   to: RelativePropertyAdapter{ path: "app.traktor.fx.4.select.2"; mode: RelativeMode.Increment; wrap: true; color: Color.WarmYellow } }
          Wire { from: "%surface%.buttons.4";   to: RelativePropertyAdapter{ path: "app.traktor.fx.4.select.3"; mode: RelativeMode.Increment; wrap: true; color: Color.WarmYellow } }
        }

        WiresGroup
        {
          enabled: fxUnit4Type.value == FxType.PatternPlayer

          Wire { from: "%surface%.buttons.1";   to: RelativePropertyAdapter{ path: "app.traktor.fx.4.type"; mode: RelativeMode.Increment; wrap: true; color: Color.Green } }
          Wire { from: "%surface%.buttons.2";   to: RelativePropertyAdapter{ path: "app.traktor.fx.4.kitSelect"; mode: RelativeMode.Decrement; wrap: true; color: Color.Cyan } }
          Wire { from: "%surface%.buttons.3";   to: RelativePropertyAdapter{ path: "app.traktor.fx.4.kitSelect"; mode: RelativeMode.Increment; wrap: true; color: Color.Cyan } }
        }
      }
    }
  }

  // Mixer Mode
  // readonly property string mixer_prefix: "app.traktor.mixer.channels."
  AppProperty { id: channelKillHighProp; path: "app.traktor.mixer.channels." + module.deckIdx + ".eq.kill_high" }
  AppProperty { id: channelKillMidProp; path: "app.traktor.mixer.channels." + module.deckIdx + ".eq.kill_mid" }
  AppProperty { id: channelKillMidLowProp; path: "app.traktor.mixer.channels." + module.deckIdx + ".eq.kill_mid_low" }
  AppProperty { id: channelKillLowProp; path: "app.traktor.mixer.channels." + module.deckIdx + ".eq.kill_low" }
  AppProperty { id: mixerFXType; path: "app.traktor.mixer.channels." + module.deckIdx + ".fx.select" }
  AppProperty { id: mixerFXOn; path: "app.traktor.mixer.channels." + module.deckIdx + ".fx.on" }
  AppProperty { id: cueMonitorOn; path: "app.traktor.mixer.channels." + module.deckIdx + ".cue" }
  AppProperty { id: cueMonitorOn1; path: "app.traktor.mixer.channels.1.cue" }
  AppProperty { id: cueMonitorOn2; path: "app.traktor.mixer.channels.2.cue" }
  AppProperty { id: cueMonitorOn3; path: "app.traktor.mixer.channels.3.cue" }
  AppProperty { id: cueMonitorOn4; path: "app.traktor.mixer.channels.4.cue" }


  // DECK A MIXER SUPERKNOBS
  WiresGroup {
    enabled: module.active && (module.layer == FXSectionLayer.mixer) && (module.deckIdx == 1) && !(mixerStemOverlayProp.value && ( (deckTypeProp.value == DeckType.Stem) || (deckTypeProp.value == DeckType.Remix) ) )

    // EQ HI SUPERKNOB CASCADE
    WiresGroup {
      enabled: ( !shift && (customLayerAssignmentEqHigh.value != 2) ) || ( shift && (customLayerAssignmentEqHigh.value != 1) )
      
      Wire {
        enabled: (customKnobAssignmentEqHigh.value == 1) && !eqHighOnlyActive
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "mapping.state.1.channel_eq_high"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqHigh.value == 2) && !eqHighOnlyActive
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "mapping.state.1.channel_eq_high"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqHigh.value == 3) && !eqHighOnlyActive
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "mapping.state.1.channel_eq_high"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqHigh.value == 4) && !eqHighOnlyActive
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "mapping.state.1.channel_eq_high"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqHigh.value == 1) && eqHighOnlyActive
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.1.eq.high"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqHigh.value == 2) && eqHighOnlyActive
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.1.eq.high"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqHigh.value == 3) && eqHighOnlyActive
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.1.eq.high"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqHigh.value == 4) && eqHighOnlyActive
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.1.eq.high"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
    }
    
    // EQ MID SUPERKNOB CASCADE
    WiresGroup {
      enabled: midSuperknobActive && ( ( !shift && (customLayerAssignmentEqMid.value != 2) ) || ( shift && (customLayerAssignmentEqMid.value != 1) ) )
      
      Wire {
        enabled: (customKnobAssignmentEqMid.value == 1) && !eqMidOnlyActive
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "mapping.state.1.channel_eq_mid"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMid.value == 2) && !eqMidOnlyActive
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "mapping.state.1.channel_eq_mid"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMid.value == 3) && !eqMidOnlyActive
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "mapping.state.1.channel_eq_mid"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMid.value == 4) && !eqMidOnlyActive
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "mapping.state.1.channel_eq_mid"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMid.value == 1) && eqMidOnlyActive
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.1.eq.mid"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMid.value == 2) && eqMidOnlyActive
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.1.eq.mid"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMid.value == 3) && eqMidOnlyActive
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.1.eq.mid"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMid.value == 4) && eqMidOnlyActive
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.1.eq.mid"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
    }
    
    // EQ MIDLO SUPERKNOB CASCADE
    WiresGroup {
      enabled: midLowSuperknobActive && ( ( !shift && (customLayerAssignmentEqMidLow.value != 2) ) || ( shift && (customLayerAssignmentEqMidLow.value != 1) ) )
      
      Wire {
        enabled: (customKnobAssignmentEqMidLow.value == 1) && !eqMidLowOnlyActive
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "mapping.state.1.channel_eq_mid_low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMidLow.value == 2) && !eqMidLowOnlyActive
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "mapping.state.1.channel_eq_mid_low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMidLow.value == 3) && !eqMidLowOnlyActive
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "mapping.state.1.channel_eq_mid_low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMidLow.value == 4) && !eqMidLowOnlyActive
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "mapping.state.1.channel_eq_mid_low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMidLow.value == 1) && eqMidLowOnlyActive
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.1.eq.mid_low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMidLow.value == 2) && eqMidLowOnlyActive
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.1.eq.mid_low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMidLow.value == 3) && eqMidLowOnlyActive
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.1.eq.mid_low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMidLow.value == 4) && eqMidLowOnlyActive
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.1.eq.mid_low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
    }
    
    // EQ LO SUPERKNOB CASCADE
    WiresGroup {
      enabled: lowSuperknobActive && ( ( !shift && (customLayerAssignmentEqLow.value != 2) ) || ( shift && (customLayerAssignmentEqLow.value != 1) ) )
      
      Wire {
        enabled: (customKnobAssignmentEqLow.value == 1) && !eqLowOnlyActive
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "mapping.state.1.channel_eq_low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqLow.value == 2) && !eqLowOnlyActive
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "mapping.state.1.channel_eq_low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqLow.value == 3) && !eqLowOnlyActive
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "mapping.state.1.channel_eq_low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqLow.value == 4) && !eqLowOnlyActive
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "mapping.state.1.channel_eq_low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqLow.value == 1) && eqLowOnlyActive
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.1.eq.low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqLow.value == 2) && eqLowOnlyActive
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.1.eq.low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqLow.value == 3) && eqLowOnlyActive
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.1.eq.low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqLow.value == 4) && eqLowOnlyActive
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.1.eq.low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
    }
    
    // EQ VOLUME SUPERKNOB CASCADE
    WiresGroup {
      enabled: volumeSuperknobActive && ( ( !shift && (customLayerAssignmentVolume.value != 2) ) || ( shift && (customLayerAssignmentVolume.value != 1) ) )
      
      Wire {
        enabled: (customKnobAssignmentVolume.value == 1) && !volumeOnlyActive
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "mapping.state.1.channel_volume"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentVolume.value == 2) && !volumeOnlyActive
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "mapping.state.1.channel_volume"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentVolume.value == 3) && !volumeOnlyActive
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "mapping.state.1.channel_volume"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentVolume.value == 4) && !volumeOnlyActive
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "mapping.state.1.channel_volume"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentVolume.value == 1) && volumeOnlyActive
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.1.volume"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentVolume.value == 2) && volumeOnlyActive
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.1.volume"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentVolume.value == 3) && volumeOnlyActive
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.1.volume"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentVolume.value == 4) && volumeOnlyActive
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.1.volume"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
    }
      
    // EQ GAIN SUPERKNOB CASCADE
    WiresGroup {
      enabled: gainSuperknobActive && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) )
      
      Wire {
        enabled: (customKnobAssignmentGain.value == 1) && !gainOnlyActive
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "mapping.state.1.channel_gain"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentGain.value == 2) && !gainOnlyActive
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "mapping.state.1.channel_gain"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentGain.value == 3) && !gainOnlyActive
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "mapping.state.1.channel_gain"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentGain.value == 4) && !gainOnlyActive
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "mapping.state.1.channel_gain"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentGain.value == 1) && gainOnlyActive
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.1.gain"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentGain.value == 2) && gainOnlyActive
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.1.gain"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentGain.value == 3) && gainOnlyActive
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.1.gain"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentGain.value == 4) && gainOnlyActive
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.1.gain"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
    }
    
    // EQ MONITOR CUE (VOLUME/GAIN) SUPERKNOB COMBO CASCADE
    WiresGroup {
      enabled: ( volumeSuperknobActive && ( ( !shift && (customLayerAssignmentVolume.value != 2) ) || ( shift && (customLayerAssignmentVolume.value != 1) ) ) ) || ( gainSuperknobActive && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) ) )

      Wire {
        enabled: ( (customKnobAssignmentVolume.value == 1) || (customKnobAssignmentGain.value == 1) ) && ( !shift || ( shift && ( (customKnobAssignmentMixerFx.value != 1) || (customLayerAssignmentMixerFx.value != 0) ) ) )
        from: "%surface%.buttons.1";
        to: ButtonScriptAdapter {
          color: Color.Blue;
          brightness: cueMonitorOn1.value;
          onPress: {
            cueMonitorOn1.value = !cueMonitorOn1.value
            if (customSingleCueMonitorProp.value) {
              cueMonitorOn2.value = false
              cueMonitorOn3.value = false
              cueMonitorOn4.value = false
            }
          }
        }
      }
      Wire {
        enabled: ( (customKnobAssignmentVolume.value == 2) || (customKnobAssignmentGain.value == 2) ) && ( !shift || ( shift && ( (customKnobAssignmentMixerFx.value != 2) || (customLayerAssignmentMixerFx.value != 0) ) ) )
        from: "%surface%.buttons.2";
        to: ButtonScriptAdapter {
          color: Color.Blue;
          brightness: cueMonitorOn1.value;
          onPress: {
            cueMonitorOn1.value = !cueMonitorOn1.value
            if (customSingleCueMonitorProp.value) {
              cueMonitorOn2.value = false
              cueMonitorOn3.value = false
              cueMonitorOn4.value = false
            }
          }
        }
      }
      Wire {
        enabled: ( (customKnobAssignmentVolume.value == 3) || (customKnobAssignmentGain.value == 3) ) && ( !shift || ( shift && ( (customKnobAssignmentMixerFx.value != 3) || (customLayerAssignmentMixerFx.value != 0) ) ) )
        from: "%surface%.buttons.3";
        to: ButtonScriptAdapter {
          color: Color.Blue;
          brightness: cueMonitorOn1.value;
          onPress: {
            cueMonitorOn1.value = !cueMonitorOn1.value
            if (customSingleCueMonitorProp.value) {
              cueMonitorOn2.value = false
              cueMonitorOn3.value = false
              cueMonitorOn4.value = false
            }
          }
        }
      }
      Wire {
        enabled: ( (customKnobAssignmentVolume.value == 4) || (customKnobAssignmentGain.value == 4) ) && ( !shift || ( shift && ( (customKnobAssignmentMixerFx.value != 4) || (customLayerAssignmentMixerFx.value != 0) ) ) )
        from: "%surface%.buttons.4";
        to: ButtonScriptAdapter {
          color: Color.Blue;
          brightness: cueMonitorOn1.value;
          onPress: {
            cueMonitorOn1.value = !cueMonitorOn1.value
            if (customSingleCueMonitorProp.value) {
              cueMonitorOn2.value = false
              cueMonitorOn3.value = false
              cueMonitorOn4.value = false
            }
          }
        }
      }
    }
    
    // EQ MIXER FX SUPERKNOB (CASCADE)
    WiresGroup {
      enabled:  mixerFxSuperknobActive && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) )
      
      // Wire {
        // enabled: (customKnobAssignmentMixerFx.value == 1)
        // from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "mapping.state.1.channel_fx_adjust"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      // }
      // Wire {
        // enabled: (customKnobAssignmentMixerFx.value == 2)
        // from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "mapping.state.1.channel_fx_adjust"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      // }
      // Wire {
        // enabled: (customKnobAssignmentMixerFx.value == 3)
        // from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "mapping.state.1.channel_fx_adjust"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      // }
      // Wire {
        // enabled: (customKnobAssignmentMixerFx.value == 4)
        // from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "mapping.state.1.channel_fx_adjust"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      // }
      Wire {
        enabled: (customKnobAssignmentMixerFx.value == 1)
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.1.fx.adjust"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentMixerFx.value == 2)
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.1.fx.adjust"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentMixerFx.value == 3)
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.1.fx.adjust"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentMixerFx.value == 4)
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.1.fx.adjust"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
    }
          
  }


  // DECK B MIXER SUPERKNOBS
  WiresGroup {
    enabled: module.active && (module.layer == FXSectionLayer.mixer) && (module.deckIdx == 2) && !(mixerStemOverlayProp.value && ( (deckTypeProp.value == DeckType.Stem) || (deckTypeProp.value == DeckType.Remix) ) )

    // EQ HI SUPERKNOB CASCADE
    WiresGroup {
      enabled: ( !shift && (customLayerAssignmentEqHigh.value != 2) ) || ( shift && (customLayerAssignmentEqHigh.value != 1) )
      
      Wire {
        enabled: (customKnobAssignmentEqHigh.value == 1) && !eqHighOnlyActive
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "mapping.state.2.channel_eq_high"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqHigh.value == 2) && !eqHighOnlyActive
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "mapping.state.2.channel_eq_high"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqHigh.value == 3) && !eqHighOnlyActive
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "mapping.state.2.channel_eq_high"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqHigh.value == 4) && !eqHighOnlyActive
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "mapping.state.2.channel_eq_high"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqHigh.value == 1) && eqHighOnlyActive
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.2.eq.high"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqHigh.value == 2) && eqHighOnlyActive
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.2.eq.high"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqHigh.value == 3) && eqHighOnlyActive
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.2.eq.high"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqHigh.value == 4) && eqHighOnlyActive
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.2.eq.high"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
    }
    
    // EQ MID SUPERKNOB CASCADE
    WiresGroup {
      enabled: midSuperknobActive && ( ( !shift && (customLayerAssignmentEqMid.value != 2) ) || ( shift && (customLayerAssignmentEqMid.value != 1) ) )
      
      Wire {
        enabled: (customKnobAssignmentEqMid.value == 1) && !eqMidOnlyActive
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "mapping.state.2.channel_eq_mid"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMid.value == 2) && !eqMidOnlyActive
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "mapping.state.2.channel_eq_mid"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMid.value == 3) && !eqMidOnlyActive
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "mapping.state.2.channel_eq_mid"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMid.value == 4) && !eqMidOnlyActive
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "mapping.state.2.channel_eq_mid"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMid.value == 1) && eqMidOnlyActive
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.2.eq.mid"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMid.value == 2) && eqMidOnlyActive
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.2.eq.mid"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMid.value == 3) && eqMidOnlyActive
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.2.eq.mid"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMid.value == 4) && eqMidOnlyActive
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.2.eq.mid"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
    }
    
    // EQ MIDLO SUPERKNOB CASCADE
    WiresGroup {
      enabled: midLowSuperknobActive && ( ( !shift && (customLayerAssignmentEqMidLow.value != 2) ) || ( shift && (customLayerAssignmentEqMidLow.value != 1) ) )
      
      Wire {
        enabled: (customKnobAssignmentEqMidLow.value == 1) && !eqMidLowOnlyActive
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "mapping.state.2.channel_eq_mid_low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMidLow.value == 2) && !eqMidLowOnlyActive
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "mapping.state.2.channel_eq_mid_low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMidLow.value == 3) && !eqMidLowOnlyActive
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "mapping.state.2.channel_eq_mid_low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMidLow.value == 4) && !eqMidLowOnlyActive
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "mapping.state.2.channel_eq_mid_low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMidLow.value == 1) && eqMidLowOnlyActive
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.2.eq.mid_low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMidLow.value == 2) && eqMidLowOnlyActive
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.2.eq.mid_low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMidLow.value == 3) && eqMidLowOnlyActive
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.2.eq.mid_low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMidLow.value == 4) && eqMidLowOnlyActive
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.2.eq.mid_low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
    }
    
    // EQ LO SUPERKNOB CASCADE
    WiresGroup {
      enabled: lowSuperknobActive && ( ( !shift && (customLayerAssignmentEqLow.value != 2) ) || ( shift && (customLayerAssignmentEqLow.value != 1) ) )
      
      Wire {
        enabled: (customKnobAssignmentEqLow.value == 1) && !eqLowOnlyActive
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "mapping.state.2.channel_eq_low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqLow.value == 2) && !eqLowOnlyActive
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "mapping.state.2.channel_eq_low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqLow.value == 3) && !eqLowOnlyActive
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "mapping.state.2.channel_eq_low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqLow.value == 4) && !eqLowOnlyActive
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "mapping.state.2.channel_eq_low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqLow.value == 1) && eqLowOnlyActive
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.2.eq.low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqLow.value == 2) && eqLowOnlyActive
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.2.eq.low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqLow.value == 3) && eqLowOnlyActive
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.2.eq.low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqLow.value == 4) && eqLowOnlyActive
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.2.eq.low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
    }
    
    // EQ VOLUME SUPERKNOB CASCADE
    WiresGroup {
      enabled: volumeSuperknobActive && ( ( !shift && (customLayerAssignmentVolume.value != 2) ) || ( shift && (customLayerAssignmentVolume.value != 1) ) )
      
      Wire {
        enabled: (customKnobAssignmentVolume.value == 1) && !volumeOnlyActive
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "mapping.state.2.channel_volume"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentVolume.value == 2) && !volumeOnlyActive
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "mapping.state.2.channel_volume"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentVolume.value == 3) && !volumeOnlyActive
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "mapping.state.2.channel_volume"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentVolume.value == 4) && !volumeOnlyActive
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "mapping.state.2.channel_volume"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentVolume.value == 1) && volumeOnlyActive
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.2.volume"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentVolume.value == 2) && volumeOnlyActive
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.2.volume"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentVolume.value == 3) && volumeOnlyActive
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.2.volume"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentVolume.value == 4) && volumeOnlyActive
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.2.volume"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
    }
      
    // EQ GAIN SUPERKNOB CASCADE
    WiresGroup {
      enabled: gainSuperknobActive && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) )
      
      Wire {
        enabled: (customKnobAssignmentGain.value == 1) && !gainOnlyActive
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "mapping.state.2.channel_gain"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentGain.value == 2) && !gainOnlyActive
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "mapping.state.2.channel_gain"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentGain.value == 3) && !gainOnlyActive
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "mapping.state.2.channel_gain"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentGain.value == 4) && !gainOnlyActive
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "mapping.state.2.channel_gain"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentGain.value == 1) && gainOnlyActive
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.2.gain"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentGain.value == 2) && gainOnlyActive
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.2.gain"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentGain.value == 3) && gainOnlyActive
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.2.gain"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentGain.value == 4) && gainOnlyActive
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.2.gain"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
    }
    
    // EQ MONITOR CUE (VOLUME/GAIN) SUPERKNOB COMBO CASCADE
    WiresGroup {
      enabled: ( volumeSuperknobActive && ( ( !shift && (customLayerAssignmentVolume.value != 2) ) || ( shift && (customLayerAssignmentVolume.value != 1) ) ) ) || ( gainSuperknobActive && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) ) )

      Wire {
        enabled: ( (customKnobAssignmentVolume.value == 1) || (customKnobAssignmentGain.value == 1) ) && ( !shift || ( shift && ( (customKnobAssignmentMixerFx.value != 1) || (customLayerAssignmentMixerFx.value != 0) ) ) )
        from: "%surface%.buttons.1";
        to: ButtonScriptAdapter {
          color: Color.Blue;
          brightness: cueMonitorOn2.value;
          onPress: {
            cueMonitorOn2.value = !cueMonitorOn2.value
            if (customSingleCueMonitorProp.value) {
              cueMonitorOn1.value = false
              cueMonitorOn3.value = false
              cueMonitorOn4.value = false
            }
          }
        }
      }
      Wire {
        enabled: ( (customKnobAssignmentVolume.value == 2) || (customKnobAssignmentGain.value == 2) ) && ( !shift || ( shift && ( (customKnobAssignmentMixerFx.value != 2) || (customLayerAssignmentMixerFx.value != 0) ) ) )
        from: "%surface%.buttons.2";
        to: ButtonScriptAdapter {
          color: Color.Blue;
          brightness: cueMonitorOn2.value;
          onPress: {
            cueMonitorOn2.value = !cueMonitorOn2.value
            if (customSingleCueMonitorProp.value) {
              cueMonitorOn1.value = false
              cueMonitorOn3.value = false
              cueMonitorOn4.value = false
            }
          }
        }
      }
      Wire {
        enabled: ( (customKnobAssignmentVolume.value == 3) || (customKnobAssignmentGain.value == 3) ) && ( !shift || ( shift && ( (customKnobAssignmentMixerFx.value != 3) || (customLayerAssignmentMixerFx.value != 0) ) ) )
        from: "%surface%.buttons.3";
        to: ButtonScriptAdapter {
          color: Color.Blue;
          brightness: cueMonitorOn2.value;
          onPress: {
            cueMonitorOn2.value = !cueMonitorOn2.value
            if (customSingleCueMonitorProp.value) {
              cueMonitorOn1.value = false
              cueMonitorOn3.value = false
              cueMonitorOn4.value = false
            }
          }
        }
      }
      Wire {
        enabled: ( (customKnobAssignmentVolume.value == 4) || (customKnobAssignmentGain.value == 4) ) && ( !shift || ( shift && ( (customKnobAssignmentMixerFx.value != 4) || (customLayerAssignmentMixerFx.value != 0) ) ) )
        from: "%surface%.buttons.4";
        to: ButtonScriptAdapter {
          color: Color.Blue;
          brightness: cueMonitorOn2.value;
          onPress: {
            cueMonitorOn2.value = !cueMonitorOn2.value
            if (customSingleCueMonitorProp.value) {
              cueMonitorOn1.value = false
              cueMonitorOn3.value = false
              cueMonitorOn4.value = false
            }
          }
        }
      }
    }
    
    // EQ MIXER FX SUPERKNOB (CASCADE)
    WiresGroup {
      enabled:  mixerFxSuperknobActive && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) )
      
      // Wire {
        // enabled: (customKnobAssignmentMixerFx.value == 1)
        // from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "mapping.state.2.channel_fx_adjust"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      // }
      // Wire {
        // enabled: (customKnobAssignmentMixerFx.value == 2)
        // from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "mapping.state.2.channel_fx_adjust"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      // }
      // Wire {
        // enabled: (customKnobAssignmentMixerFx.value == 3)
        // from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "mapping.state.2.channel_fx_adjust"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      // }
      // Wire {
        // enabled: (customKnobAssignmentMixerFx.value == 4)
        // from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "mapping.state.2.channel_fx_adjust"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      // }
      Wire {
        enabled: (customKnobAssignmentMixerFx.value == 1)
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.2.fx.adjust"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentMixerFx.value == 2)
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.2.fx.adjust"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentMixerFx.value == 3)
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.2.fx.adjust"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentMixerFx.value == 4)
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.2.fx.adjust"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
    }
          
  }


  // DECK C MIXER SUPERKNOBS
  WiresGroup {
    enabled: module.active && (module.layer == FXSectionLayer.mixer) && (module.deckIdx == 3) && !(mixerStemOverlayProp.value && ( (deckTypeProp.value == DeckType.Stem) || (deckTypeProp.value == DeckType.Remix) ) )

    // EQ HI SUPERKNOB CASCADE
    WiresGroup {
      enabled: ( !shift && (customLayerAssignmentEqHigh.value != 2) ) || ( shift && (customLayerAssignmentEqHigh.value != 1) )
      
      Wire {
        enabled: (customKnobAssignmentEqHigh.value == 1) && !eqHighOnlyActive
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "mapping.state.3.channel_eq_high"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqHigh.value == 2) && !eqHighOnlyActive
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "mapping.state.3.channel_eq_high"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqHigh.value == 3) && !eqHighOnlyActive
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "mapping.state.3.channel_eq_high"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqHigh.value == 4) && !eqHighOnlyActive
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "mapping.state.3.channel_eq_high"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqHigh.value == 1) && eqHighOnlyActive
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.3.eq.high"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqHigh.value == 2) && eqHighOnlyActive
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.3.eq.high"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqHigh.value == 3) && eqHighOnlyActive
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.3.eq.high"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqHigh.value == 4) && eqHighOnlyActive
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.3.eq.high"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
    }
    
    // EQ MID SUPERKNOB CASCADE
    WiresGroup {
      enabled: midSuperknobActive && ( ( !shift && (customLayerAssignmentEqMid.value != 2) ) || ( shift && (customLayerAssignmentEqMid.value != 1) ) )
      
      Wire {
        enabled: (customKnobAssignmentEqMid.value == 1) && !eqMidOnlyActive
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "mapping.state.3.channel_eq_mid"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMid.value == 2) && !eqMidOnlyActive
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "mapping.state.3.channel_eq_mid"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMid.value == 3) && !eqMidOnlyActive
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "mapping.state.3.channel_eq_mid"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMid.value == 4) && !eqMidOnlyActive
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "mapping.state.3.channel_eq_mid"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMid.value == 1) && eqMidOnlyActive
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.3.eq.mid"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMid.value == 2) && eqMidOnlyActive
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.3.eq.mid"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMid.value == 3) && eqMidOnlyActive
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.3.eq.mid"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMid.value == 4) && eqMidOnlyActive
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.3.eq.mid"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
    }
    
    // EQ MIDLO SUPERKNOB CASCADE
    WiresGroup {
      enabled: midLowSuperknobActive && ( ( !shift && (customLayerAssignmentEqMidLow.value != 2) ) || ( shift && (customLayerAssignmentEqMidLow.value != 1) ) )
      
      Wire {
        enabled: (customKnobAssignmentEqMidLow.value == 1) && !eqMidLowOnlyActive
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "mapping.state.3.channel_eq_mid_low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMidLow.value == 2) && !eqMidLowOnlyActive
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "mapping.state.3.channel_eq_mid_low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMidLow.value == 3) && !eqMidLowOnlyActive
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "mapping.state.3.channel_eq_mid_low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMidLow.value == 4) && !eqMidLowOnlyActive
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "mapping.state.3.channel_eq_mid_low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMidLow.value == 1) && eqMidLowOnlyActive
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.3.eq.mid_low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMidLow.value == 2) && eqMidLowOnlyActive
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.3.eq.mid_low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMidLow.value == 3) && eqMidLowOnlyActive
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.3.eq.mid_low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMidLow.value == 4) && eqMidLowOnlyActive
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.3.eq.mid_low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
    }
    
    // EQ LO SUPERKNOB CASCADE
    WiresGroup {
      enabled: lowSuperknobActive && ( ( !shift && (customLayerAssignmentEqLow.value != 2) ) || ( shift && (customLayerAssignmentEqLow.value != 1) ) )
      
      Wire {
        enabled: (customKnobAssignmentEqLow.value == 1) && !eqLowOnlyActive
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "mapping.state.3.channel_eq_low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqLow.value == 2) && !eqLowOnlyActive
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "mapping.state.3.channel_eq_low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqLow.value == 3) && !eqLowOnlyActive
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "mapping.state.3.channel_eq_low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqLow.value == 4) && !eqLowOnlyActive
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "mapping.state.3.channel_eq_low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqLow.value == 1) && eqLowOnlyActive
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.3.eq.low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqLow.value == 2) && eqLowOnlyActive
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.3.eq.low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqLow.value == 3) && eqLowOnlyActive
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.3.eq.low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqLow.value == 4) && eqLowOnlyActive
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.3.eq.low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
    }
    
    // EQ VOLUME SUPERKNOB CASCADE
    WiresGroup {
      enabled: volumeSuperknobActive && ( ( !shift && (customLayerAssignmentVolume.value != 2) ) || ( shift && (customLayerAssignmentVolume.value != 1) ) )
      
      Wire {
        enabled: (customKnobAssignmentVolume.value == 1) && !volumeOnlyActive
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "mapping.state.3.channel_volume"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentVolume.value == 2) && !volumeOnlyActive
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "mapping.state.3.channel_volume"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentVolume.value == 3) && !volumeOnlyActive
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "mapping.state.3.channel_volume"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentVolume.value == 4) && !volumeOnlyActive
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "mapping.state.3.channel_volume"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentVolume.value == 1) && volumeOnlyActive
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.3.volume"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentVolume.value == 2) && volumeOnlyActive
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.3.volume"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentVolume.value == 3) && volumeOnlyActive
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.3.volume"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentVolume.value == 4) && volumeOnlyActive
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.3.volume"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
    }
      
    // EQ GAIN SUPERKNOB CASCADE
    WiresGroup {
      enabled: gainSuperknobActive && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) )
      
      Wire {
        enabled: (customKnobAssignmentGain.value == 1) && !gainOnlyActive
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "mapping.state.3.channel_gain"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentGain.value == 2) && !gainOnlyActive
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "mapping.state.3.channel_gain"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentGain.value == 3) && !gainOnlyActive
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "mapping.state.3.channel_gain"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentGain.value == 4) && !gainOnlyActive
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "mapping.state.3.channel_gain"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentGain.value == 1) && gainOnlyActive
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.3.gain"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentGain.value == 2) && gainOnlyActive
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.3.gain"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentGain.value == 3) && gainOnlyActive
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.3.gain"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentGain.value == 4) && gainOnlyActive
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.3.gain"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }

    }

    // EQ MONITOR CUE (VOLUME/GAIN) SUPERKNOB COMBO CASCADE
    WiresGroup {
      enabled: ( volumeSuperknobActive && ( ( !shift && (customLayerAssignmentVolume.value != 2) ) || ( shift && (customLayerAssignmentVolume.value != 1) ) ) ) || ( gainSuperknobActive && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) ) )

      Wire {
        enabled: ( (customKnobAssignmentVolume.value == 1) || (customKnobAssignmentGain.value == 1) ) && ( !shift || ( shift && ( (customKnobAssignmentMixerFx.value != 1) || (customLayerAssignmentMixerFx.value != 0) ) ) )
        from: "%surface%.buttons.1";
        to: ButtonScriptAdapter {
          color: Color.Blue;
          brightness: cueMonitorOn3.value;
          onPress: {
            cueMonitorOn3.value = !cueMonitorOn3.value
            if (customSingleCueMonitorProp.value) {
              cueMonitorOn1.value = false
              cueMonitorOn2.value = false
              cueMonitorOn4.value = false
            }
          }
        }
      }
      Wire {
        enabled: ( (customKnobAssignmentVolume.value == 2) || (customKnobAssignmentGain.value == 2) ) && ( !shift || ( shift && ( (customKnobAssignmentMixerFx.value != 2) || (customLayerAssignmentMixerFx.value != 0) ) ) )
        from: "%surface%.buttons.2";
        to: ButtonScriptAdapter {
          color: Color.Blue;
          brightness: cueMonitorOn3.value;
          onPress: {
            cueMonitorOn3.value = !cueMonitorOn3.value
            if (customSingleCueMonitorProp.value) {
              cueMonitorOn1.value = false
              cueMonitorOn2.value = false
              cueMonitorOn4.value = false
            }
          }
        }
      }
      Wire {
        enabled: ( (customKnobAssignmentVolume.value == 3) || (customKnobAssignmentGain.value == 3) ) && ( !shift || ( shift && ( (customKnobAssignmentMixerFx.value != 3) || (customLayerAssignmentMixerFx.value != 0) ) ) )
        from: "%surface%.buttons.3";
        to: ButtonScriptAdapter {
          color: Color.Blue;
          brightness: cueMonitorOn3.value;
          onPress: {
            cueMonitorOn3.value = !cueMonitorOn3.value
            if (customSingleCueMonitorProp.value) {
              cueMonitorOn1.value = false
              cueMonitorOn2.value = false
              cueMonitorOn4.value = false
            }
          }
        }
      }
      Wire {
        enabled: ( (customKnobAssignmentVolume.value == 4) || (customKnobAssignmentGain.value == 4) ) && ( !shift || ( shift && ( (customKnobAssignmentMixerFx.value != 4) || (customLayerAssignmentMixerFx.value != 0) ) ) )
        from: "%surface%.buttons.4";
        to: ButtonScriptAdapter {
          color: Color.Blue;
          brightness: cueMonitorOn3.value;
          onPress: {
            cueMonitorOn3.value = !cueMonitorOn3.value
            if (customSingleCueMonitorProp.value) {
              cueMonitorOn1.value = false
              cueMonitorOn2.value = false
              cueMonitorOn4.value = false
            }
          }
        }
      }
    }
    
    // EQ MIXER FX SUPERKNOB (CASCADE)
    WiresGroup {
      enabled:  mixerFxSuperknobActive && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) )
      
      // Wire {
        // enabled: (customKnobAssignmentMixerFx.value == 1)
        // from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "mapping.state.3.channel_fx_adjust"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      // }
      // Wire {
        // enabled: (customKnobAssignmentMixerFx.value == 2)
        // from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "mapping.state.3.channel_fx_adjust"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      // }
      // Wire {
        // enabled: (customKnobAssignmentMixerFx.value == 3)
        // from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "mapping.state.3.channel_fx_adjust"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      // }
      // Wire {
        // enabled: (customKnobAssignmentMixerFx.value == 4)
        // from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "mapping.state.3.channel_fx_adjust"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      // }
      Wire {
        enabled: (customKnobAssignmentMixerFx.value == 1)
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.3.fx.adjust"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentMixerFx.value == 2)
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.3.fx.adjust"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentMixerFx.value == 3)
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.3.fx.adjust"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentMixerFx.value == 4)
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.3.fx.adjust"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
    }
    
  }


  // DECK D MIXER SUPERKNOBS
  WiresGroup {
    enabled: module.active && (module.layer == FXSectionLayer.mixer) && (module.deckIdx == 4) && !(mixerStemOverlayProp.value && ( (deckTypeProp.value == DeckType.Stem) || (deckTypeProp.value == DeckType.Remix) ) )

    // EQ HI SUPERKNOB CASCADE
    WiresGroup {
      enabled: ( !shift && (customLayerAssignmentEqHigh.value != 2) ) || ( shift && (customLayerAssignmentEqHigh.value != 1) )
      
      Wire {
        enabled: (customKnobAssignmentEqHigh.value == 1) && !eqHighOnlyActive
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "mapping.state.4.channel_eq_high"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqHigh.value == 2) && !eqHighOnlyActive
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "mapping.state.4.channel_eq_high"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqHigh.value == 3) && !eqHighOnlyActive
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "mapping.state.4.channel_eq_high"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqHigh.value == 4) && !eqHighOnlyActive
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "mapping.state.4.channel_eq_high"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqHigh.value == 1) && eqHighOnlyActive
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.4.eq.high"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqHigh.value == 2) && eqHighOnlyActive
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.4.eq.high"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqHigh.value == 3) && eqHighOnlyActive
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.4.eq.high"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqHigh.value == 4) && eqHighOnlyActive
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.4.eq.high"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
    }
    
    // EQ MID SUPERKNOB CASCADE
    WiresGroup {
      enabled: midSuperknobActive && ( ( !shift && (customLayerAssignmentEqMid.value != 2) ) || ( shift && (customLayerAssignmentEqMid.value != 1) ) )
      
      Wire {
        enabled: (customKnobAssignmentEqMid.value == 1) && !eqMidOnlyActive
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "mapping.state.4.channel_eq_mid"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMid.value == 2) && !eqMidOnlyActive
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "mapping.state.4.channel_eq_mid"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMid.value == 3) && !eqMidOnlyActive
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "mapping.state.4.channel_eq_mid"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMid.value == 4) && !eqMidOnlyActive
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "mapping.state.4.channel_eq_mid"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMid.value == 1) && eqMidOnlyActive
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.4.eq.mid"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMid.value == 2) && eqMidOnlyActive
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.4.eq.mid"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMid.value == 3) && eqMidOnlyActive
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.4.eq.mid"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMid.value == 4) && eqMidOnlyActive
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.4.eq.mid"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
    }
    
    // EQ MIDLO SUPERKNOB CASCADE
    WiresGroup {
      enabled: midLowSuperknobActive && ( ( !shift && (customLayerAssignmentEqMidLow.value != 2) ) || ( shift && (customLayerAssignmentEqMidLow.value != 1) ) )
      
      Wire {
        enabled: (customKnobAssignmentEqMidLow.value == 1) && !eqMidLowOnlyActive
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "mapping.state.4.channel_eq_mid_low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMidLow.value == 2) && !eqMidLowOnlyActive
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "mapping.state.4.channel_eq_mid_low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMidLow.value == 3) && !eqMidLowOnlyActive
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "mapping.state.4.channel_eq_mid_low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMidLow.value == 4) && !eqMidLowOnlyActive
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "mapping.state.4.channel_eq_mid_low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMidLow.value == 1) && eqMidLowOnlyActive
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.4.eq.mid_low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMidLow.value == 2) && eqMidLowOnlyActive
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.4.eq.mid_low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMidLow.value == 3) && eqMidLowOnlyActive
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.4.eq.mid_low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqMidLow.value == 4) && eqMidLowOnlyActive
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.4.eq.mid_low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
    }
    
    // EQ LO SUPERKNOB CASCADE
    WiresGroup {
      enabled: lowSuperknobActive && ( ( !shift && (customLayerAssignmentEqLow.value != 2) ) || ( shift && (customLayerAssignmentEqLow.value != 1) ) )
      
      Wire {
        enabled: (customKnobAssignmentEqLow.value == 1) && !eqLowOnlyActive
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "mapping.state.4.channel_eq_low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqLow.value == 2) && !eqLowOnlyActive
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "mapping.state.4.channel_eq_low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqLow.value == 3) && !eqLowOnlyActive
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "mapping.state.4.channel_eq_low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqLow.value == 4) && !eqLowOnlyActive
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "mapping.state.4.channel_eq_low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqLow.value == 1) && eqLowOnlyActive
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.4.eq.low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqLow.value == 2) && eqLowOnlyActive
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.4.eq.low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqLow.value == 3) && eqLowOnlyActive
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.4.eq.low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentEqLow.value == 4) && eqLowOnlyActive
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.4.eq.low"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
    }
    
    // EQ VOLUME SUPERKNOB CASCADE
    WiresGroup {
      enabled: volumeSuperknobActive && ( ( !shift && (customLayerAssignmentVolume.value != 2) ) || ( shift && (customLayerAssignmentVolume.value != 1) ) )
      
      Wire {
        enabled: (customKnobAssignmentVolume.value == 1) && !volumeOnlyActive
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "mapping.state.4.channel_volume"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentVolume.value == 2) && !volumeOnlyActive
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "mapping.state.4.channel_volume"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentVolume.value == 3) && !volumeOnlyActive
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "mapping.state.4.channel_volume"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentVolume.value == 4) && !volumeOnlyActive
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "mapping.state.4.channel_volume"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentVolume.value == 1) && volumeOnlyActive
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.4.volume"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentVolume.value == 2) && volumeOnlyActive
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.4.volume"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentVolume.value == 3) && volumeOnlyActive
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.4.volume"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentVolume.value == 4) && volumeOnlyActive
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.4.volume"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
    }
    
    // EQ GAIN SUPERKNOB CASCADE
    WiresGroup {
      enabled: gainSuperknobActive && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) )
      
      Wire {
        enabled: (customKnobAssignmentGain.value == 1) && !gainOnlyActive
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "mapping.state.4.channel_gain"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentGain.value == 2) && !gainOnlyActive
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "mapping.state.4.channel_gain"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentGain.value == 3) && !gainOnlyActive
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "mapping.state.4.channel_gain"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentGain.value == 4) && !gainOnlyActive
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "mapping.state.4.channel_gain"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentGain.value == 1) && gainOnlyActive
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.4.gain"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentGain.value == 2) && gainOnlyActive
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.4.gain"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentGain.value == 3) && gainOnlyActive
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.4.gain"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentGain.value == 4) && gainOnlyActive
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.4.gain"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
    }
    
    // EQ MONITOR CUE (VOLUME/GAIN) SUPERKNOB COMBO CASCADE
    WiresGroup {
      enabled: ( volumeSuperknobActive && ( ( !shift && (customLayerAssignmentVolume.value != 2) ) || ( shift && (customLayerAssignmentVolume.value != 1) ) ) ) || ( gainSuperknobActive && ( ( !shift && (customLayerAssignmentGain.value != 2) ) || ( shift && (customLayerAssignmentGain.value != 1) ) ) )

      Wire {
        enabled: ( (customKnobAssignmentVolume.value == 1) || (customKnobAssignmentGain.value == 1) ) && ( !shift || ( shift && ( (customKnobAssignmentMixerFx.value != 1) || (customLayerAssignmentMixerFx.value != 0) ) ) )
        from: "%surface%.buttons.1";
        to: ButtonScriptAdapter {
          color: Color.Blue;
          brightness: cueMonitorOn4.value;
          onPress: {
            cueMonitorOn4.value = !cueMonitorOn4.value
            if (customSingleCueMonitorProp.value) {
              cueMonitorOn1.value = false
              cueMonitorOn2.value = false
              cueMonitorOn3.value = false
            }
          }
        }
      }
      Wire {
        enabled: ( (customKnobAssignmentVolume.value == 2) || (customKnobAssignmentGain.value == 2) ) && ( !shift || ( shift && ( (customKnobAssignmentMixerFx.value != 2) || (customLayerAssignmentMixerFx.value != 0) ) ) )
        from: "%surface%.buttons.2";
        to: ButtonScriptAdapter {
          color: Color.Blue;
          brightness: cueMonitorOn4.value;
          onPress: {
            cueMonitorOn4.value = !cueMonitorOn4.value
            if (customSingleCueMonitorProp.value) {
              cueMonitorOn1.value = false
              cueMonitorOn2.value = false
              cueMonitorOn3.value = false
            }
          }
        }
      }
      Wire {
        enabled: ( (customKnobAssignmentVolume.value == 3) || (customKnobAssignmentGain.value == 3) ) && ( !shift || ( shift && ( (customKnobAssignmentMixerFx.value != 3) || (customLayerAssignmentMixerFx.value != 0) ) ) )
        from: "%surface%.buttons.3";
        to: ButtonScriptAdapter {
          color: Color.Blue;
          brightness: cueMonitorOn4.value;
          onPress: {
            cueMonitorOn4.value = !cueMonitorOn4.value
            if (customSingleCueMonitorProp.value) {
              cueMonitorOn1.value = false
              cueMonitorOn2.value = false
              cueMonitorOn3.value = false
            }
          }
        }
      }
      Wire {
        enabled: ( (customKnobAssignmentVolume.value == 4) || (customKnobAssignmentGain.value == 4) ) && ( !shift || ( shift && ( (customKnobAssignmentMixerFx.value != 4) || (customLayerAssignmentMixerFx.value != 0) ) ) )
        from: "%surface%.buttons.4";
        to: ButtonScriptAdapter {
          color: Color.Blue;
          brightness: cueMonitorOn4.value;
          onPress: {
            cueMonitorOn4.value = !cueMonitorOn4.value
            if (customSingleCueMonitorProp.value) {
              cueMonitorOn1.value = false
              cueMonitorOn2.value = false
              cueMonitorOn3.value = false
            }
          }
        }
      }
    }

    // EQ MIXER FX SUPERKNOB (CASCADE)
    WiresGroup {
      enabled:  mixerFxSuperknobActive && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) )
      
      // Wire {
        // enabled: (customKnobAssignmentMixerFx.value == 1)
        // from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "mapping.state.4.channel_fx_adjust"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      // }
      // Wire {
        // enabled: (customKnobAssignmentMixerFx.value == 2)
        // from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "mapping.state.4.channel_fx_adjust"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      // }
      // Wire {
        // enabled: (customKnobAssignmentMixerFx.value == 3)
        // from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "mapping.state.4.channel_fx_adjust"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      // }
      // Wire {
        // enabled: (customKnobAssignmentMixerFx.value == 4)
        // from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "mapping.state.4.channel_fx_adjust"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      // }
      Wire {
        enabled: (customKnobAssignmentMixerFx.value == 1)
        from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.4.fx.adjust"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentMixerFx.value == 2)
        from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.4.fx.adjust"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentMixerFx.value == 3)
        from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.4.fx.adjust"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
      Wire {
        enabled: (customKnobAssignmentMixerFx.value == 4)
        from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "app.traktor.mixer.channels.4.fx.adjust"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled }
      }
    }
        
  }


  // EQ KILL BUTTONS, MIXER FX, FOR ALL DECKS (CASCADE IN X1MK3DECK.QML APPPROPERTIES)
  WiresGroup {
    enabled: module.active && (module.layer == FXSectionLayer.mixer) && !(mixerStemOverlayProp.value && ( (deckTypeProp.value == DeckType.Stem) || (deckTypeProp.value == DeckType.Remix) ) )

    // EQ HI SUPERKNOB CASCADE
    WiresGroup {
      enabled: ( !shift && (customLayerAssignmentEqHigh.value != 2) ) || ( shift && (customLayerAssignmentEqHigh.value != 1) )
      
      Wire {
        enabled: (customKnobAssignmentEqHigh.value == 1) && ( !shift || ( shift && ( (customKnobAssignmentMixerFx.value != 1) || (customLayerAssignmentMixerFx.value != 0) ) ) )
        from: "%surface%.buttons.1"; to: ButtonScriptAdapter { color: Color.Turquoise; brightness: channelKillHighProp.value; onPress: { channelKillHighProp.value = !channelKillHighProp.value } }
      }
      Wire {
        enabled: (customKnobAssignmentEqHigh.value == 2) && ( !shift || ( shift && ( (customKnobAssignmentMixerFx.value != 2) || (customLayerAssignmentMixerFx.value != 0) ) ) )
        from: "%surface%.buttons.2"; to: ButtonScriptAdapter { color: Color.Turquoise; brightness: channelKillHighProp.value; onPress: { channelKillHighProp.value = !channelKillHighProp.value } }
      }
      Wire {
        enabled: (customKnobAssignmentEqHigh.value == 3) && ( !shift || ( shift && ( (customKnobAssignmentMixerFx.value != 3) || (customLayerAssignmentMixerFx.value != 0) ) ) )
        from: "%surface%.buttons.3"; to: ButtonScriptAdapter { color: Color.Turquoise; brightness: channelKillHighProp.value; onPress: { channelKillHighProp.value = !channelKillHighProp.value } }
      }
      Wire {
        enabled: (customKnobAssignmentEqHigh.value == 4) && ( !shift || ( shift && ( (customKnobAssignmentMixerFx.value != 4) || (customLayerAssignmentMixerFx.value != 0) ) ) )
        from: "%surface%.buttons.4"; to: ButtonScriptAdapter { color: Color.Turquoise; brightness: channelKillHighProp.value; onPress: { channelKillHighProp.value = !channelKillHighProp.value } }
      }
    }

    // EQ MID SUPERKNOB CASCADE
    WiresGroup {
      enabled: midSuperknobActive && ( ( !shift && (customLayerAssignmentEqMid.value != 2) ) || ( shift && (customLayerAssignmentEqMid.value != 1) ) )
      
      Wire {
        enabled: (customKnobAssignmentEqMid.value == 1) && ( !shift || ( shift && ( (customKnobAssignmentMixerFx.value != 1) || (customLayerAssignmentMixerFx.value != 0) ) ) )
        from: "%surface%.buttons.1"; to: ButtonScriptAdapter { color: Color.WarmYellow; brightness: channelKillMidProp.value; onPress: { channelKillMidProp.value = !channelKillMidProp.value } }
      }
      Wire {
        enabled: (customKnobAssignmentEqMid.value == 2) && ( !shift || ( shift && ( (customKnobAssignmentMixerFx.value != 2) || (customLayerAssignmentMixerFx.value != 0) ) ) )
        from: "%surface%.buttons.2"; to: ButtonScriptAdapter { color: Color.WarmYellow; brightness: channelKillMidProp.value; onPress: { channelKillMidProp.value = !channelKillMidProp.value } }
      }
      Wire {
        enabled: (customKnobAssignmentEqMid.value == 3) && ( !shift || ( shift && ( (customKnobAssignmentMixerFx.value != 3) || (customLayerAssignmentMixerFx.value != 0) ) ) )
        from: "%surface%.buttons.3"; to: ButtonScriptAdapter { color: Color.WarmYellow; brightness: channelKillMidProp.value; onPress: { channelKillMidProp.value = !channelKillMidProp.value } }
      }
      Wire {
        enabled: (customKnobAssignmentEqMid.value == 4) && ( !shift || ( shift && ( (customKnobAssignmentMixerFx.value != 4) || (customLayerAssignmentMixerFx.value != 0) ) ) )
        from: "%surface%.buttons.4"; to: ButtonScriptAdapter { color: Color.WarmYellow; brightness: channelKillMidProp.value; onPress: { channelKillMidProp.value = !channelKillMidProp.value } }
      }
    }

    // EQ MIDLO SUPERKNOB CASCADE
    WiresGroup {
      enabled: midLowSuperknobActive && ( ( !shift && (customLayerAssignmentEqMidLow.value != 2) ) || ( shift && (customLayerAssignmentEqMidLow.value != 1) ) )
      
      Wire {
        enabled: (customKnobAssignmentEqMidLow.value == 1) && ( !shift || ( shift && ( (customKnobAssignmentMixerFx.value != 1) || (customLayerAssignmentMixerFx.value != 0) ) ) )
        from: "%surface%.buttons.1"; to: ButtonScriptAdapter { color: Color.DarkOrange; brightness: channelKillMidLowProp.value; onPress: { channelKillMidLowProp.value = !channelKillMidLowProp.value } }
      }
      Wire {
        enabled: (customKnobAssignmentEqMidLow.value == 2) && ( !shift || ( shift && ( (customKnobAssignmentMixerFx.value != 2) || (customLayerAssignmentMixerFx.value != 0) ) ) )
        from: "%surface%.buttons.2"; to: ButtonScriptAdapter { color: Color.DarkOrange; brightness: channelKillMidLowProp.value; onPress: { channelKillMidLowProp.value = !channelKillMidLowProp.value } }
      }
      Wire {
        enabled: (customKnobAssignmentEqMidLow.value == 3) && ( !shift || ( shift && ( (customKnobAssignmentMixerFx.value != 3) || (customLayerAssignmentMixerFx.value != 0) ) ) )
        from: "%surface%.buttons.3"; to: ButtonScriptAdapter { color: Color.DarkOrange; brightness: channelKillMidLowProp.value; onPress: { channelKillMidLowProp.value = !channelKillMidLowProp.value } }
      }
      Wire {
        enabled: (customKnobAssignmentEqMidLow.value == 4) && ( !shift || ( shift && ( (customKnobAssignmentMixerFx.value != 4) || (customLayerAssignmentMixerFx.value != 0) ) ) )
        from: "%surface%.buttons.4"; to: ButtonScriptAdapter { color: Color.DarkOrange; brightness: channelKillMidLowProp.value; onPress: { channelKillMidLowProp.value = !channelKillMidLowProp.value } }
      }
    }

    // EQ LO SUPERKNOB CASCADE
    WiresGroup {
      enabled: lowSuperknobActive && ( ( !shift && (customLayerAssignmentEqLow.value != 2) ) || ( shift && (customLayerAssignmentEqLow.value != 1) ) )
      
      Wire {
        enabled: (customKnobAssignmentEqLow.value == 1) && ( !shift || ( shift && ( (customKnobAssignmentMixerFx.value != 1) || (customLayerAssignmentMixerFx.value != 0) ) ) )
        from: "%surface%.buttons.1"; to: ButtonScriptAdapter { color: Color.Red; brightness: channelKillLowProp.value; onPress: { channelKillLowProp.value = !channelKillLowProp.value } }
      }
      Wire {
        enabled: (customKnobAssignmentEqLow.value == 2) && ( !shift || ( shift && ( (customKnobAssignmentMixerFx.value != 2) || (customLayerAssignmentMixerFx.value != 0) ) ) )
        from: "%surface%.buttons.2"; to: ButtonScriptAdapter { color: Color.Red; brightness: channelKillLowProp.value; onPress: { channelKillLowProp.value = !channelKillLowProp.value } }
      }
      Wire {
        enabled: (customKnobAssignmentEqLow.value == 3) && ( !shift || ( shift && ( (customKnobAssignmentMixerFx.value != 3) || (customLayerAssignmentMixerFx.value != 0) ) ) )
        from: "%surface%.buttons.3"; to: ButtonScriptAdapter { color: Color.Red; brightness: channelKillLowProp.value; onPress: { channelKillLowProp.value = !channelKillLowProp.value } }
      }
      Wire {
        enabled: (customKnobAssignmentEqLow.value == 4) && ( !shift || ( shift && ( (customKnobAssignmentMixerFx.value != 4) || (customLayerAssignmentMixerFx.value != 0) ) ) )
        from: "%surface%.buttons.4"; to: ButtonScriptAdapter { color: Color.Red; brightness: channelKillLowProp.value; onPress: { channelKillLowProp.value = !channelKillLowProp.value } }
      }
    }


    // EQ MIXER FX ONLY WITH FX SELECTION, FOR ALL DECKS (CASCADE IN X1MK3DECK.QML APPPROPERTIES)
    WiresGroup {
      enabled:  mixerFxSuperknobActive && ( ( !shift && (customLayerAssignmentMixerFx.value != 2) ) || ( shift && (customLayerAssignmentMixerFx.value != 1) ) )
      Wire {
        enabled: (customKnobAssignmentMixerFx.value == 1)
        from: "%surface%.buttons.1"; to: ButtonScriptAdapter {
          color: (mixerFXType.value == 1) ? Color.Red : (mixerFXType.value == 2) ? Color.Green : (mixerFXType.value == 3) ? Color.Turquoise : (mixerFXType.value == 4) ? Color.Yellow : Color.LightOrange;
          brightness: (customInvertMixerFxLedProp.value) ? !mixerFXOn.value : mixerFXOn.value;
          onPress: {
            if ( (customLayerAssignmentMixerFx.value == 0) && shift ) {
              if (mixerFXType.value < 4) mixerFXType.value = mixerFXType.value + 1;
              else mixerFXType.value = 0
            }
            else mixerFXOn.value = !mixerFXOn.value
          }
        }
      }
      Wire { enabled: (customKnobAssignmentMixerFx.value == 1) && (customLayerAssignmentMixerFx.value == 0) && shift; from: "%surface%.buttons.1"; to: "buttons_activity_timer.input" }
      Wire {
        enabled: (customKnobAssignmentMixerFx.value == 2)
        from: "%surface%.buttons.2"; to: ButtonScriptAdapter {
          color: (mixerFXType.value == 1) ? Color.Red : (mixerFXType.value == 2) ? Color.Green : (mixerFXType.value == 3) ? Color.Turquoise : (mixerFXType.value == 4) ? Color.Yellow : Color.LightOrange;
          brightness: (customInvertMixerFxLedProp.value) ? !mixerFXOn.value : mixerFXOn.value;
          onPress: {
            if ( (customLayerAssignmentMixerFx.value == 0) && shift ) {
              if (mixerFXType.value < 4) mixerFXType.value = mixerFXType.value + 1;
              else mixerFXType.value = 0
            }
            else mixerFXOn.value = !mixerFXOn.value
          }
        }
      }
      Wire { enabled: (customKnobAssignmentMixerFx.value == 2) && (customLayerAssignmentMixerFx.value == 0) && shift; from: "%surface%.buttons.2"; to: "buttons_activity_timer.input" }
      Wire {
        enabled: (customKnobAssignmentMixerFx.value == 3)
        from: "%surface%.buttons.3"; to: ButtonScriptAdapter {
          color: (mixerFXType.value == 1) ? Color.Red : (mixerFXType.value == 2) ? Color.Green : (mixerFXType.value == 3) ? Color.Turquoise : (mixerFXType.value == 4) ? Color.Yellow : Color.LightOrange;
          brightness: (customInvertMixerFxLedProp.value) ? !mixerFXOn.value : mixerFXOn.value;
          onPress: {
            if ( (customLayerAssignmentMixerFx.value == 0) && shift ) {
              if (mixerFXType.value < 4) mixerFXType.value = mixerFXType.value + 1;
              else mixerFXType.value = 0
            }
            else mixerFXOn.value = !mixerFXOn.value
          }
        }
      }
      Wire { enabled: (customKnobAssignmentMixerFx.value == 3) && (customLayerAssignmentMixerFx.value == 0) && shift; from: "%surface%.buttons.3"; to: "buttons_activity_timer.input" }
      Wire {
        enabled: (customKnobAssignmentMixerFx.value == 4)
        from: "%surface%.buttons.4"; to: ButtonScriptAdapter {
          color: (mixerFXType.value == 1) ? Color.Red : (mixerFXType.value == 2) ? Color.Green : (mixerFXType.value == 3) ? Color.Turquoise : (mixerFXType.value == 4) ? Color.Yellow : Color.LightOrange;
          brightness: (customInvertMixerFxLedProp.value) ? !mixerFXOn.value : mixerFXOn.value;
          onPress: {
            if ( (customLayerAssignmentMixerFx.value == 0) && shift ) {
              if (mixerFXType.value < 4) mixerFXType.value = mixerFXType.value + 1;
              else mixerFXType.value = 0
            }
            else mixerFXOn.value = !mixerFXOn.value
          }
        }
      }
      Wire { enabled: (customKnobAssignmentMixerFx.value == 4) && (customLayerAssignmentMixerFx.value == 0) && shift; from: "%surface%.buttons.4"; to: "buttons_activity_timer.input" }
    }
    
    // EQ MIXER FX, COMBO FX SELECTION ONLY, FOR ALL DECKS (CASCADE IN X1MK3DECK.QML APPPROPERTIES)
    WiresGroup {
      enabled:  !mixerFxSuperknobActive && ( shift && (customLayerAssignmentMixerFx.value == 0) )
      Wire {
        enabled: (customKnobAssignmentMixerFx.value == 1)
        from: "%surface%.buttons.1"; to: ButtonScriptAdapter {
          color: (mixerFXType.value == 1) ? Color.Red : (mixerFXType.value == 2) ? Color.Green : (mixerFXType.value == 3) ? Color.Turquoise : (mixerFXType.value == 4) ? Color.Yellow : Color.LightOrange;
          brightness: (customInvertMixerFxLedProp.value) ? !mixerFXOn.value : mixerFXOn.value;
          onPress: {
            if (mixerFXType.value < 4) mixerFXType.value = mixerFXType.value + 1;
            else mixerFXType.value = 0
          }
        }
      }
      Wire { enabled: (customKnobAssignmentMixerFx.value == 1); from: "%surface%.buttons.1"; to: "buttons_activity_timer.input" }
      Wire {
        enabled: (customKnobAssignmentMixerFx.value == 2)
        from: "%surface%.buttons.2"; to: ButtonScriptAdapter {
          color: (mixerFXType.value == 1) ? Color.Red : (mixerFXType.value == 2) ? Color.Green : (mixerFXType.value == 3) ? Color.Turquoise : (mixerFXType.value == 4) ? Color.Yellow : Color.LightOrange;
          brightness: (customInvertMixerFxLedProp.value) ? !mixerFXOn.value : mixerFXOn.value;
          onPress: {
            if (mixerFXType.value < 4) mixerFXType.value = mixerFXType.value + 1;
            else mixerFXType.value = 0
          }
        }
      }
      Wire { enabled: (customKnobAssignmentMixerFx.value == 2); from: "%surface%.buttons.2"; to: "buttons_activity_timer.input" }
      Wire {
        enabled: (customKnobAssignmentMixerFx.value == 3)
        from: "%surface%.buttons.3"; to: ButtonScriptAdapter {
          color: (mixerFXType.value == 1) ? Color.Red : (mixerFXType.value == 2) ? Color.Green : (mixerFXType.value == 3) ? Color.Turquoise : (mixerFXType.value == 4) ? Color.Yellow : Color.LightOrange;
          brightness: (customInvertMixerFxLedProp.value) ? !mixerFXOn.value : mixerFXOn.value;
          onPress: {
            if (mixerFXType.value < 4) mixerFXType.value = mixerFXType.value + 1;
            else mixerFXType.value = 0
          }
        }
      }
      Wire { enabled: (customKnobAssignmentMixerFx.value == 3); from: "%surface%.buttons.3"; to: "buttons_activity_timer.input" }
      Wire {
        enabled: (customKnobAssignmentMixerFx.value == 4)
        from: "%surface%.buttons.4"; to: ButtonScriptAdapter {
          color: (mixerFXType.value == 1) ? Color.Red : (mixerFXType.value == 2) ? Color.Green : (mixerFXType.value == 3) ? Color.Turquoise : (mixerFXType.value == 4) ? Color.Yellow : Color.LightOrange;
          brightness: (customInvertMixerFxLedProp.value) ? !mixerFXOn.value : mixerFXOn.value;
          onPress: {
            if (mixerFXType.value < 4) mixerFXType.value = mixerFXType.value + 1;
            else mixerFXType.value = 0
          }
        }
      }
      Wire { enabled: (customKnobAssignmentMixerFx.value == 4); from: "%surface%.buttons.4"; to: "buttons_activity_timer.input" }
    }
    
    // WiresGroup {
      // enabled:  mixerFxSuperknobActive && ( shift && (customLayerAssignmentMixerFx.value == 0) )
      // Wire { enabled: (customKnobAssignmentMixerFx.value == 1); from: "%surface%.buttons.1"; to: "buttons_activity_timer.input" }
      // Wire {
        // enabled: (customKnobAssignmentMixerFx.value == 1)
        // from: "%surface%.buttons.1"; to: ButtonScriptAdapter {
          // color: (mixerFXType.value == 1) ? Color.Red : (mixerFXType.value == 2) ? Color.Green : (mixerFXType.value == 3) ? Color.Turquoise : (mixerFXType.value == 4) ? Color.Yellow : Color.LightOrange;
          // brightness: 1.0
          // onPress: {
            // if (mixerFXType.value < 4) mixerFXType.value = mixerFXType.value + 1;
            // else mixerFXType.value = 0
            // brightness = 0.0
          // }
          // onRelease: {
            // brightness = 1.0
          // }
        // }
      // }
      // Wire { enabled: (customKnobAssignmentMixerFx.value == 2); from: "%surface%.buttons.2"; to: "buttons_activity_timer.input" }
      // Wire {
        // enabled: (customKnobAssignmentMixerFx.value == 2)
        // from: "%surface%.buttons.2"; to: ButtonScriptAdapter {
            // brightness : 1.0
          // onPress: {
            // if (mixerFXType.value < 4) mixerFXType.value = mixerFXType.value + 1;
            // else mixerFXType.value = 0
            // brightness = 0.0
          // }
          // onRelease: {
            // brightness = 1.0
          // }
        // }
      // }
      // Wire { enabled: (customKnobAssignmentMixerFx.value == 3); from: "%surface%.buttons.3"; to: "buttons_activity_timer.input" }
      // Wire {
        // enabled: (customKnobAssignmentMixerFx.value == 3)
        // from: "%surface%.buttons.3"; to: ButtonScriptAdapter {
          // color: (mixerFXType.value == 1) ? Color.Red : (mixerFXType.value == 2) ? Color.Green : (mixerFXType.value == 3) ? Color.Turquoise : (mixerFXType.value == 4) ? Color.Yellow : Color.LightOrange;
            // brightness : 1.0
          // onPress: {
            // if (mixerFXType.value < 4) mixerFXType.value = mixerFXType.value + 1;
            // else mixerFXType.value = 0
            // brightness = 0.0
          // }
          // onRelease: {
            // brightness = 1.0
          // }
        // }
      // }
      // Wire { enabled: (customKnobAssignmentMixerFx.value == 4); from: "%surface%.buttons.4"; to: "buttons_activity_timer.input" }
      // Wire {
        // enabled: (customKnobAssignmentMixerFx.value == 4)
        // from: "%surface%.buttons.4"; to: ButtonScriptAdapter {
          // color: (mixerFXType.value == 1) ? Color.Red : (mixerFXType.value == 2) ? Color.Green : (mixerFXType.value == 3) ? Color.Turquoise : (mixerFXType.value == 4) ? Color.Yellow : Color.LightOrange;
            // brightness : 1.0
          // onPress: {
            // if (mixerFXType.value < 4) mixerFXType.value = mixerFXType.value + 1;
            // else mixerFXType.value = 0
            // brightness = 0.0
          // }
          // onRelease: {
            // brightness = 1.0
          // }
        // }
      // }
    // }
    
  }

  // Stem controls
  StemDeckStreams { name: "stems"; channel: module.deckIdx }
  MappingPropertyDescriptor { id: mixerStemOverlayProp; path: module.propertiesPath + ".mixer_stem_overlay_active"; type: MappingPropertyDescriptor.Boolean; value: false }
  AppProperty { id: deckTypeProp; path: "app.traktor.decks." + module.deckIdx + ".type" }
  
  AppProperty { id: stemColorId_1;  path: "app.traktor.decks." + module.deckIdx + ".stems.1.color_id" }
  AppProperty { id: stemColorId_2;  path: "app.traktor.decks." + module.deckIdx + ".stems.2.color_id" }
  AppProperty { id: stemColorId_3;  path: "app.traktor.decks." + module.deckIdx + ".stems.3.color_id" }
  AppProperty { id: stemColorId_4;  path: "app.traktor.decks." + module.deckIdx + ".stems.4.color_id" }
  
  AppProperty { id: remixPlayersActiveCellRowProp_1; path: "app.traktor.decks." + module.deckIdx + ".remix.players.1.active_cell_row"; } // First cell has value zero. Add +1 for correct #
  AppProperty { id: remixPlayersActiveCellRowProp_2; path: "app.traktor.decks." + module.deckIdx + ".remix.players.2.active_cell_row"; } // First cell has value zero. Add +1 for correct #
  AppProperty { id: remixPlayersActiveCellRowProp_3; path: "app.traktor.decks." + module.deckIdx + ".remix.players.3.active_cell_row"; } // First cell has value zero. Add +1 for correct #
  AppProperty { id: remixPlayersActiveCellRowProp_4; path: "app.traktor.decks." + module.deckIdx + ".remix.players.4.active_cell_row"; } // First cell has value zero. Add +1 for correct #
  
  AppProperty { id: remixPlayersColorIdProp_1; path: "app.traktor.decks." + module.deckIdx + ".remix.cell.columns.1.rows." + (remixPlayersActiveCellRowProp_1.value + 1) + ".color_id"; }
  AppProperty { id: remixPlayersColorIdProp_2; path: "app.traktor.decks." + module.deckIdx + ".remix.cell.columns.2.rows." + (remixPlayersActiveCellRowProp_2.value + 1) + ".color_id"; }
  AppProperty { id: remixPlayersColorIdProp_3; path: "app.traktor.decks." + module.deckIdx + ".remix.cell.columns.3.rows." + (remixPlayersActiveCellRowProp_3.value + 1) + ".color_id"; }
  AppProperty { id: remixPlayersColorIdProp_4; path: "app.traktor.decks." + module.deckIdx + ".remix.cell.columns.4.rows." + (remixPlayersActiveCellRowProp_4.value + 1) + ".color_id"; }
  
  // AppProperty { id: remixPlayersColorIdProp_1; path: "app.traktor.decks." + module.deckIdx + ".remix.cell.columns.1.rows." + remixPlayersActiveCellProp_1.value + ".color_id"; }
  // AppProperty { id: remixPlayersColorIdProp_2; path: "app.traktor.decks." + module.deckIdx + ".remix.cell.columns.2.rows." + remixPlayersActiveCellProp_2.value + ".color_id"; }
  // AppProperty { id: remixPlayersColorIdProp_3; path: "app.traktor.decks." + module.deckIdx + ".remix.cell.columns.3.rows." + remixPlayersActiveCellProp_3.value + ".color_id"; }
  // AppProperty { id: remixPlayersColorIdProp_4; path: "app.traktor.decks." + module.deckIdx + ".remix.cell.columns.4.rows." + remixPlayersActiveCellProp_4.value + ".color_id"; }
  
  // WiresGroup {
    // enabled: module.active && (module.layer == FXSectionLayer.mixer) && mixerStemOverlayProp.value && deckTypeProp.value == DeckType.Stem

    // Wire { from: "%surface%.buttons.1"; to: "stems.1.muted" }
    // Wire { from: "%surface%.buttons.2"; to: "stems.2.muted" }
    // Wire { from: "%surface%.buttons.3"; to: "stems.3.muted" }
    // Wire { from: "%surface%.buttons.4"; to: "stems.4.muted" }

 // }
      
  // WiresGroup {
    // enabled: module.active && (module.layer == FXSectionLayer.mixer) && (module.deckIdx == 1) && mixerStemOverlayProp.value && deckTypeProp.value == DeckType.Stem

    // Wire { from: "%surface%.buttons.1"; to: TogglePropertyAdapter { path: "app.traktor.decks.1.stems.1.muted"; color: stemColorId_1.value; invertBrightness: true } }
    // Wire { from: "%surface%.buttons.2"; to: TogglePropertyAdapter { path: "app.traktor.decks.1.stems.2.muted"; color: stemColorId_2.value; invertBrightness: true } }
    // Wire { from: "%surface%.buttons.3"; to: TogglePropertyAdapter { path: "app.traktor.decks.1.stems.3.muted"; color: stemColorId_3.value; invertBrightness: true } }
    // Wire { from: "%surface%.buttons.4"; to: TogglePropertyAdapter { path: "app.traktor.decks.1.stems.4.muted"; color: stemColorId_4.value; invertBrightness: true  } }

 // }
            
  WiresGroup {
    enabled: module.active && (module.layer == FXSectionLayer.mixer) && (module.deckIdx == 1) && mixerStemOverlayProp.value && deckTypeProp.value == DeckType.Stem
    Wire { from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "mapping.state.1.stems_1_volume_filter"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled } }
    Wire { from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "mapping.state.1.stems_2_volume_filter"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled } }
    Wire { from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "mapping.state.1.stems_3_volume_filter"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled } }
    Wire { from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "mapping.state.1.stems_4_volume_filter"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled } }
    WiresGroup {
      enabled: (!customSubchannelMuteSendFXProp.value && !shift) || (customSubchannelMuteSendFXProp.value && shift)
      Wire { from: "%surface%.buttons.1"; to: TogglePropertyAdapter { path: "app.traktor.decks.1.stems.1.muted"; color: stemColorId_1.value; invertBrightness: false } }
      Wire { from: "%surface%.buttons.2"; to: TogglePropertyAdapter { path: "app.traktor.decks.1.stems.2.muted"; color: stemColorId_2.value; invertBrightness: false } }
      Wire { from: "%surface%.buttons.3"; to: TogglePropertyAdapter { path: "app.traktor.decks.1.stems.3.muted"; color: stemColorId_3.value; invertBrightness: false } }
      Wire { from: "%surface%.buttons.4"; to: TogglePropertyAdapter { path: "app.traktor.decks.1.stems.4.muted"; color: stemColorId_4.value; invertBrightness: false  } }
    }
    WiresGroup {
      enabled: (customSubchannelMuteSendFXProp.value && !shift) || (!customSubchannelMuteSendFXProp.value && shift)
      Wire { from: "%surface%.buttons.1"; to: TogglePropertyAdapter { path: "app.traktor.decks.1.stems.1.fx_send_on"; color: Color.LightOrange } }
      Wire { from: "%surface%.buttons.2"; to: TogglePropertyAdapter { path: "app.traktor.decks.1.stems.2.fx_send_on"; color: Color.LightOrange } }
      Wire { from: "%surface%.buttons.3"; to: TogglePropertyAdapter { path: "app.traktor.decks.1.stems.3.fx_send_on"; color: Color.LightOrange } }
      Wire { from: "%surface%.buttons.4"; to: TogglePropertyAdapter { path: "app.traktor.decks.1.stems.4.fx_send_on"; color: Color.LightOrange } }
    }
  }

  WiresGroup {
    enabled: module.active && (module.layer == FXSectionLayer.mixer) && (module.deckIdx == 2) && mixerStemOverlayProp.value && deckTypeProp.value == DeckType.Stem
    Wire { from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "mapping.state.2.stems_1_volume_filter"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled } }
    Wire { from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "mapping.state.2.stems_2_volume_filter"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled } }
    Wire { from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "mapping.state.2.stems_3_volume_filter"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled } }
    Wire { from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "mapping.state.2.stems_4_volume_filter"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled } }
    WiresGroup {
      enabled: (!customSubchannelMuteSendFXProp.value && !shift) || (customSubchannelMuteSendFXProp.value && shift)
      Wire { from: "%surface%.buttons.1"; to: TogglePropertyAdapter { path: "app.traktor.decks.2.stems.1.muted"; color: stemColorId_1.value; invertBrightness: false } }
      Wire { from: "%surface%.buttons.2"; to: TogglePropertyAdapter { path: "app.traktor.decks.2.stems.2.muted"; color: stemColorId_2.value; invertBrightness: false } }
      Wire { from: "%surface%.buttons.3"; to: TogglePropertyAdapter { path: "app.traktor.decks.2.stems.3.muted"; color: stemColorId_3.value; invertBrightness: false } }
      Wire { from: "%surface%.buttons.4"; to: TogglePropertyAdapter { path: "app.traktor.decks.2.stems.4.muted"; color: stemColorId_4.value; invertBrightness: false  } }
    }
    WiresGroup {
      enabled: (customSubchannelMuteSendFXProp.value && !shift) || (!customSubchannelMuteSendFXProp.value && shift)
      Wire { from: "%surface%.buttons.1"; to: TogglePropertyAdapter { path: "app.traktor.decks.2.stems.1.fx_send_on"; color: Color.LightOrange } }
      Wire { from: "%surface%.buttons.2"; to: TogglePropertyAdapter { path: "app.traktor.decks.2.stems.2.fx_send_on"; color: Color.LightOrange } }
      Wire { from: "%surface%.buttons.3"; to: TogglePropertyAdapter { path: "app.traktor.decks.2.stems.3.fx_send_on"; color: Color.LightOrange } }
      Wire { from: "%surface%.buttons.4"; to: TogglePropertyAdapter { path: "app.traktor.decks.2.stems.4.fx_send_on"; color: Color.LightOrange } }
    }
  }

  WiresGroup {
    enabled: module.active && (module.layer == FXSectionLayer.mixer) && (module.deckIdx == 3) && mixerStemOverlayProp.value && deckTypeProp.value == DeckType.Stem
    Wire { from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "mapping.state.3.stems_1_volume_filter"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled } }
    Wire { from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "mapping.state.3.stems_2_volume_filter"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled } }
    Wire { from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "mapping.state.3.stems_3_volume_filter"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled } }
    Wire { from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "mapping.state.3.stems_4_volume_filter"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled } }
    WiresGroup {
      enabled: (!customSubchannelMuteSendFXProp.value && !shift) || (customSubchannelMuteSendFXProp.value && shift)
      Wire { from: "%surface%.buttons.1"; to: TogglePropertyAdapter { path: "app.traktor.decks.3.stems.1.muted"; color: stemColorId_1.value; invertBrightness: false } }
      Wire { from: "%surface%.buttons.2"; to: TogglePropertyAdapter { path: "app.traktor.decks.3.stems.2.muted"; color: stemColorId_2.value; invertBrightness: false } }
      Wire { from: "%surface%.buttons.3"; to: TogglePropertyAdapter { path: "app.traktor.decks.3.stems.3.muted"; color: stemColorId_3.value; invertBrightness: false } }
      Wire { from: "%surface%.buttons.4"; to: TogglePropertyAdapter { path: "app.traktor.decks.3.stems.4.muted"; color: stemColorId_4.value; invertBrightness: false  } }
    }
    WiresGroup {
      enabled: (customSubchannelMuteSendFXProp.value && !shift) || (!customSubchannelMuteSendFXProp.value && shift)
      Wire { from: "%surface%.buttons.1"; to: TogglePropertyAdapter { path: "app.traktor.decks.3.stems.1.fx_send_on"; color: Color.LightOrange } }
      Wire { from: "%surface%.buttons.2"; to: TogglePropertyAdapter { path: "app.traktor.decks.3.stems.2.fx_send_on"; color: Color.LightOrange } }
      Wire { from: "%surface%.buttons.3"; to: TogglePropertyAdapter { path: "app.traktor.decks.3.stems.3.fx_send_on"; color: Color.LightOrange } }
      Wire { from: "%surface%.buttons.4"; to: TogglePropertyAdapter { path: "app.traktor.decks.3.stems.4.fx_send_on"; color: Color.LightOrange } }
    }
  }

  WiresGroup {
    enabled: module.active && (module.layer == FXSectionLayer.mixer) && (module.deckIdx == 4) && mixerStemOverlayProp.value && deckTypeProp.value == DeckType.Stem
    Wire { from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "mapping.state.4.stems_1_volume_filter"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled } }
    Wire { from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "mapping.state.4.stems_2_volume_filter"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled } }
    Wire { from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "mapping.state.4.stems_3_volume_filter"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled } }
    Wire { from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "mapping.state.4.stems_4_volume_filter"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled } }
    WiresGroup {
      enabled: (!customSubchannelMuteSendFXProp.value && !shift) || (customSubchannelMuteSendFXProp.value && shift)
      Wire { from: "%surface%.buttons.1"; to: TogglePropertyAdapter { path: "app.traktor.decks.4.stems.1.muted"; color: stemColorId_1.value; invertBrightness: false } }
      Wire { from: "%surface%.buttons.2"; to: TogglePropertyAdapter { path: "app.traktor.decks.4.stems.2.muted"; color: stemColorId_2.value; invertBrightness: false } }
      Wire { from: "%surface%.buttons.3"; to: TogglePropertyAdapter { path: "app.traktor.decks.4.stems.3.muted"; color: stemColorId_3.value; invertBrightness: false } }
      Wire { from: "%surface%.buttons.4"; to: TogglePropertyAdapter { path: "app.traktor.decks.4.stems.4.muted"; color: stemColorId_4.value; invertBrightness: false  } }
    }
    WiresGroup {
      enabled: (customSubchannelMuteSendFXProp.value && !shift) || (!customSubchannelMuteSendFXProp.value && shift)
      Wire { from: "%surface%.buttons.1"; to: TogglePropertyAdapter { path: "app.traktor.decks.4.stems.1.fx_send_on"; color: Color.LightOrange } }
      Wire { from: "%surface%.buttons.2"; to: TogglePropertyAdapter { path: "app.traktor.decks.4.stems.2.fx_send_on"; color: Color.LightOrange } }
      Wire { from: "%surface%.buttons.3"; to: TogglePropertyAdapter { path: "app.traktor.decks.4.stems.3.fx_send_on"; color: Color.LightOrange } }
      Wire { from: "%surface%.buttons.4"; to: TogglePropertyAdapter { path: "app.traktor.decks.4.stems.4.fx_send_on"; color: Color.LightOrange } }
    }
  }

  WiresGroup {
    enabled: module.active && (module.layer == FXSectionLayer.mixer) && (module.deckIdx == 1) && mixerStemOverlayProp.value && deckTypeProp.value == DeckType.Remix
    Wire { from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "mapping.state.1.remix_players_1_volume_filter"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled } }
    Wire { from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "mapping.state.1.remix_players_2_volume_filter"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled } }
    Wire { from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "mapping.state.1.remix_players_3_volume_filter"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled } }
    Wire { from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "mapping.state.1.remix_players_4_volume_filter"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled } }
    WiresGroup {
      enabled: (!customSubchannelMuteSendFXProp.value && !shift) || (customSubchannelMuteSendFXProp.value && shift)
      Wire { from: "%surface%.buttons.1"; to: TogglePropertyAdapter { path: "app.traktor.decks.1.remix.players.1.muted"; color: remixPlayersColorIdProp_1.value; invertBrightness: false } }
      Wire { from: "%surface%.buttons.2"; to: TogglePropertyAdapter { path: "app.traktor.decks.1.remix.players.2.muted"; color: remixPlayersColorIdProp_2.value; invertBrightness: false } }
      Wire { from: "%surface%.buttons.3"; to: TogglePropertyAdapter { path: "app.traktor.decks.1.remix.players.3.muted"; color: remixPlayersColorIdProp_3.value; invertBrightness: false } }
      Wire { from: "%surface%.buttons.4"; to: TogglePropertyAdapter { path: "app.traktor.decks.1.remix.players.4.muted"; color: remixPlayersColorIdProp_4.value; invertBrightness: false  } }
    }
    WiresGroup {
      enabled: (customSubchannelMuteSendFXProp.value && !shift) || (!customSubchannelMuteSendFXProp.value && shift)
      Wire { from: "%surface%.buttons.1"; to: TogglePropertyAdapter { path: "app.traktor.decks.1.remix.players.1.fx_send_on"; color: Color.LightOrange } }
      Wire { from: "%surface%.buttons.2"; to: TogglePropertyAdapter { path: "app.traktor.decks.1.remix.players.2.fx_send_on"; color: Color.LightOrange } }
      Wire { from: "%surface%.buttons.3"; to: TogglePropertyAdapter { path: "app.traktor.decks.1.remix.players.3.fx_send_on"; color: Color.LightOrange } }
      Wire { from: "%surface%.buttons.4"; to: TogglePropertyAdapter { path: "app.traktor.decks.1.remix.players.4.fx_send_on"; color: Color.LightOrange } }
    }
  }

  WiresGroup {
    enabled: module.active && (module.layer == FXSectionLayer.mixer) && (module.deckIdx == 2) && mixerStemOverlayProp.value && deckTypeProp.value == DeckType.Remix
    Wire { from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "mapping.state.2.remix_players_1_volume_filter"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled } }
    Wire { from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "mapping.state.2.remix_players_2_volume_filter"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled } }
    Wire { from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "mapping.state.2.remix_players_3_volume_filter"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled } }
    Wire { from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "mapping.state.2.remix_players_4_volume_filter"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled } }
    WiresGroup {
      enabled: (!customSubchannelMuteSendFXProp.value && !shift) || (customSubchannelMuteSendFXProp.value && shift)
      Wire { from: "%surface%.buttons.1"; to: TogglePropertyAdapter { path: "app.traktor.decks.2.remix.players.1.muted"; color: remixPlayersColorIdProp_1.value; invertBrightness: false } }
      Wire { from: "%surface%.buttons.2"; to: TogglePropertyAdapter { path: "app.traktor.decks.2.remix.players.2.muted"; color: remixPlayersColorIdProp_2.value; invertBrightness: false } }
      Wire { from: "%surface%.buttons.3"; to: TogglePropertyAdapter { path: "app.traktor.decks.2.remix.players.3.muted"; color: remixPlayersColorIdProp_3.value; invertBrightness: false } }
      Wire { from: "%surface%.buttons.4"; to: TogglePropertyAdapter { path: "app.traktor.decks.2.remix.players.4.muted"; color: remixPlayersColorIdProp_4.value; invertBrightness: false  } }
    }
    WiresGroup {
      enabled: (customSubchannelMuteSendFXProp.value && !shift) || (!customSubchannelMuteSendFXProp.value && shift)
      Wire { from: "%surface%.buttons.1"; to: TogglePropertyAdapter { path: "app.traktor.decks.2.remix.players.1.fx_send_on"; color: Color.LightOrange } }
      Wire { from: "%surface%.buttons.2"; to: TogglePropertyAdapter { path: "app.traktor.decks.2.remix.players.2.fx_send_on"; color: Color.LightOrange } }
      Wire { from: "%surface%.buttons.3"; to: TogglePropertyAdapter { path: "app.traktor.decks.2.remix.players.3.fx_send_on"; color: Color.LightOrange } }
      Wire { from: "%surface%.buttons.4"; to: TogglePropertyAdapter { path: "app.traktor.decks.2.remix.players.4.fx_send_on"; color: Color.LightOrange } }
    }
  }

  WiresGroup {
    enabled: module.active && (module.layer == FXSectionLayer.mixer) && (module.deckIdx == 3) && mixerStemOverlayProp.value && deckTypeProp.value == DeckType.Remix
    Wire { from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "mapping.state.3.remix_players_1_volume_filter"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled } }
    Wire { from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "mapping.state.3.remix_players_2_volume_filter"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled } }
    Wire { from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "mapping.state.3.remix_players_3_volume_filter"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled } }
    Wire { from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "mapping.state.3.remix_players_4_volume_filter"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled } }
    WiresGroup {
      enabled: (!customSubchannelMuteSendFXProp.value && !shift) || (customSubchannelMuteSendFXProp.value && shift)
      Wire { from: "%surface%.buttons.1"; to: TogglePropertyAdapter { path: "app.traktor.decks.3.remix.players.1.muted"; color: remixPlayersColorIdProp_1.value; invertBrightness: false } }
      Wire { from: "%surface%.buttons.2"; to: TogglePropertyAdapter { path: "app.traktor.decks.3.remix.players.2.muted"; color: remixPlayersColorIdProp_2.value; invertBrightness: false } }
      Wire { from: "%surface%.buttons.3"; to: TogglePropertyAdapter { path: "app.traktor.decks.3.remix.players.3.muted"; color: remixPlayersColorIdProp_3.value; invertBrightness: false } }
      Wire { from: "%surface%.buttons.4"; to: TogglePropertyAdapter { path: "app.traktor.decks.3.remix.players.4.muted"; color: remixPlayersColorIdProp_4.value; invertBrightness: false  } }
    }
    WiresGroup {
      enabled: (customSubchannelMuteSendFXProp.value && !shift) || (!customSubchannelMuteSendFXProp.value && shift)
      Wire { from: "%surface%.buttons.1"; to: TogglePropertyAdapter { path: "app.traktor.decks.3.remix.players.1.fx_send_on"; color: Color.LightOrange } }
      Wire { from: "%surface%.buttons.2"; to: TogglePropertyAdapter { path: "app.traktor.decks.3.remix.players.2.fx_send_on"; color: Color.LightOrange } }
      Wire { from: "%surface%.buttons.3"; to: TogglePropertyAdapter { path: "app.traktor.decks.3.remix.players.3.fx_send_on"; color: Color.LightOrange } }
      Wire { from: "%surface%.buttons.4"; to: TogglePropertyAdapter { path: "app.traktor.decks.3.remix.players.4.fx_send_on"; color: Color.LightOrange } }
    }
  }

  WiresGroup {
    enabled: module.active && (module.layer == FXSectionLayer.mixer) && (module.deckIdx == 4) && mixerStemOverlayProp.value && deckTypeProp.value == DeckType.Remix
    Wire { from: "softtakeover1.output"; to: ValuePropertyAdapter { path: "mapping.state.4.remix_players_1_volume_filter"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled } }
    Wire { from: "softtakeover2.output"; to: ValuePropertyAdapter { path: "mapping.state.4.remix_players_2_volume_filter"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled } }
    Wire { from: "softtakeover3.output"; to: ValuePropertyAdapter { path: "mapping.state.4.remix_players_3_volume_filter"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled } }
    Wire { from: "softtakeover4.output"; to: ValuePropertyAdapter { path: "mapping.state.4.remix_players_4_volume_filter"; ignoreEvents: PinEvent.WireEnabled | PinEvent.WireDisabled } }
    WiresGroup {
      enabled: (!customSubchannelMuteSendFXProp.value && !shift) || (customSubchannelMuteSendFXProp.value && shift)
      Wire { from: "%surface%.buttons.1"; to: TogglePropertyAdapter { path: "app.traktor.decks.4.remix.players.1.muted"; color: remixPlayersColorIdProp_1.value; invertBrightness: false } }
      Wire { from: "%surface%.buttons.2"; to: TogglePropertyAdapter { path: "app.traktor.decks.4.remix.players.2.muted"; color: remixPlayersColorIdProp_2.value; invertBrightness: false } }
      Wire { from: "%surface%.buttons.3"; to: TogglePropertyAdapter { path: "app.traktor.decks.4.remix.players.3.muted"; color: remixPlayersColorIdProp_3.value; invertBrightness: false } }
      Wire { from: "%surface%.buttons.4"; to: TogglePropertyAdapter { path: "app.traktor.decks.4.remix.players.4.muted"; color: remixPlayersColorIdProp_4.value; invertBrightness: false  } }
    }
    WiresGroup {
      enabled: (customSubchannelMuteSendFXProp.value && !shift) || (!customSubchannelMuteSendFXProp.value && shift)
      Wire { from: "%surface%.buttons.1"; to: TogglePropertyAdapter { path: "app.traktor.decks.4.remix.players.1.fx_send_on"; color: Color.LightOrange } }
      Wire { from: "%surface%.buttons.2"; to: TogglePropertyAdapter { path: "app.traktor.decks.4.remix.players.2.fx_send_on"; color: Color.LightOrange } }
      Wire { from: "%surface%.buttons.3"; to: TogglePropertyAdapter { path: "app.traktor.decks.4.remix.players.3.fx_send_on"; color: Color.LightOrange } }
      Wire { from: "%surface%.buttons.4"; to: TogglePropertyAdapter { path: "app.traktor.decks.4.remix.players.4.fx_send_on"; color: Color.LightOrange } }
    }
  }

}
