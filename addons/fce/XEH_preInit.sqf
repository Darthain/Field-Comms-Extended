/*
 * Field Comms Extended
 * Copyright (C) 2026 Field Comms Extended contributors. Based on ACRE2 by IDI-Systems.
 * SPDX-License-Identifier: GPL-3.0-only
 */
private _cat = "Field Comms Extended";
{
    _x params ["_side", "_name", "_key"];
    [format ["FCE_enc%1", _side], "CHECKBOX", [format ["%1 encrypted", _name], format ["%1's PRC-152, PRC-117F and PRC-148 radios start with encryption on, using the key below. Radios only hear encrypted traffic with the same key. A Side Encryption module in the mission overrides this.", _name]],
        [_cat, "Encryption"], false, 1, {}, true] call CBA_fnc_addSetting;
    [format ["FCE_tek%1", _side], "SLIDER", [format ["%1 key (TEK)", _name], "The traffic encryption key number. Radios must share it to hear each other."],
        [_cat, "Encryption"], [1, 8, _key, 0], 1, {}, true] call CBA_fnc_addSetting;
} forEach [["West", "BLUFOR", 1], ["East", "OPFOR", 2], ["Guer", "Independent", 3]];
