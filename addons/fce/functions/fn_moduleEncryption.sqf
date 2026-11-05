/*
 * Field Comms Extended
 * Copyright (C) 2026 Field Comms Extended contributors. Based on ACRE2 by IDI-Systems.
 * SPDX-License-Identifier: GPL-3.0-only
 */
/*
    Function: FCE_fnc_moduleEncryption (Side Encryption module, every machine)
    Stores the module's per-side encryption choices; FCE_fnc_applyEncryption uses them in place
    of the CBA settings for this mission.
*/
params ["_logic", "", ["_activated", true]];
if (!_activated || {isNull _logic}) exitWith {};
FCE_moduleEnc = createHashMapFromArray [
    ["west", [_logic getVariable ["West", false], _logic getVariable ["WestKey", 1]]],
    ["east", [_logic getVariable ["East", false], _logic getVariable ["EastKey", 2]]],
    ["guer", [_logic getVariable ["Guer", false], _logic getVariable ["GuerKey", 3]]]
];
