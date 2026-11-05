/*
 * Field Comms Extended
 * SPDX-License-Identifier: GPL-3.0-only
 */
if (!hasInterface) exitWith {};
// Encryption: once the player's side is known and any Side Encryption module has run.
[{ !isNull player && {time > 0} }, { call FCE_fnc_applyEncryption; }] call CBA_fnc_waitUntilAndExecute;
