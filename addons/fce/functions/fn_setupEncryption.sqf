/*
 * Field Comms Extended
 * Copyright (C) 2026 Field Comms Extended contributors. Based on ACRE2 by IDI-Systems.
 * SPDX-License-Identifier: GPL-3.0-only
 */
/*
    Function: FCE_fnc_setupEncryption
    Builds an encrypted copy of ACRE's default preset for one radio type: every channel gets
    encryption on and the given key (TEK). ACRE already refuses encrypted traffic from radios with
    encryption off or a different key (PRC-148, PRC-152, PRC-117F); this switches it on for a side.
    Arguments: 0: Radio base class, 1: Preset name to create, 2: Key (TEK)
    Return: <BOOL> true if built
*/
params ["_radio", "_preset", "_tek"];
private _data = [_radio, "default"] call acre_api_fnc_getPresetData;
if (isNil "_data") exitWith { false };
[_radio, "default", _preset] call acre_api_fnc_copyPreset;
private _channels = _data getVariable ["channels", []];
for "_i" from 1 to (count _channels) do {
    [_radio, _preset, _i, "encryption", 1] call acre_api_fnc_setPresetChannelField;
    [_radio, _preset, _i, "TEK", round _tek] call acre_api_fnc_setPresetChannelField;
};
true
