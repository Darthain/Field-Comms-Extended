/*
 * Field Comms Extended
 * Copyright (C) 2026 Field Comms Extended contributors. Based on ACRE2 by IDI-Systems.
 * SPDX-License-Identifier: GPL-3.0-only
 */
/*
    Function: FCE_fnc_applyEncryption (CLIENT)
    If the player's side is set to encrypted (Side Encryption module, else the CBA settings), gives their
    PRC-152, PRC-117F and PRC-148 radios an encrypted preset with the side's key. ACRE applies a preset to
    radios as they're issued, so radios already set up before this ran keep their old settings until
    re-issued (a known limitation; apply at mission start).
    Also records each side's key in FCE_keys (for EW mods such as ARTIC Signals & EW: captured keys as intel).
*/
private _key = toLowerANSI str playerSide;
if !(_key in ["west", "east", "guer"]) exitWith {};
private _cfgSide = ["West", "East", "Guer"] select (["west", "east", "guer"] find _key);
private _mod = missionNamespace getVariable ["FCE_moduleEnc", createHashMap];
(_mod getOrDefault [_key, [
    missionNamespace getVariable [format ["FCE_enc%1", _cfgSide], false],
    missionNamespace getVariable [format ["FCE_tek%1", _cfgSide], 1]
]]) params ["_on", "_tek"];
if (isNil "FCE_keys") then { FCE_keys = createHashMap; };
FCE_keys set [_key, [_on, round _tek]];
if (!_on) exitWith {};
private _preset = format ["fce_enc_%1", _key];
{
    if ([_x, _preset, _tek] call FCE_fnc_setupEncryption) then { [_x, _preset] call acre_api_fnc_setPreset; };
} forEach ["ACRE_PRC152", "ACRE_PRC117F", "ACRE_PRC148"];
diag_log format ["Field Comms Extended: %1 radios encrypted with key %2.", _cfgSide, round _tek];
