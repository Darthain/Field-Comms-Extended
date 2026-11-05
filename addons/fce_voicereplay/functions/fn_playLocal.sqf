/*
    Field Comms Extended: voice replay (client). Ask my TeamSpeak plugin to play one of _unit's clips from _posASL.
    ACRE places it in 3D like a voice; walls muffle it the way ACRE muffles direct speech.
*/
params [["_unit", objNull], ["_posASL", [0, 0, 0]], ["_range", 60], ["_volume", 1], ["_pitch", 1], ["_fallback", []]];
if (!hasInterface || {isNull player}) exitWith {};
private _runFallback = { if (_fallback isNotEqualTo []) then {(_fallback param [1, []]) call (_fallback select 0)} };
if (_unit == player) exitWith {call _runFallback};   // you never hear yourself
private _id = _unit getVariable ["acre_sys_core_ts3id", -1];
if !(_id isEqualType 0 && {_id >= 0}) then {_id = (missionNamespace getVariable ["fce_voiceReplay_ids", createHashMap]) getOrDefault [getPlayerUID _unit, -1]};
if !([_unit] call fce_voicereplay_fnc_available) exitWith {call _runFallback};
if !(_id isEqualType 0 && {_id >= 0}) exitWith {call _runFallback};
private _dist = (getPosASL player) vectorDistance _posASL;
if (_dist > _range) exitWith {};
// walls and floors in the way muffle it, like ACRE's direct speech
private _occ = 1;
if (!isNil "acre_sys_core_fnc_findOcclusion") then {
    private _ear = missionNamespace getVariable ["ACRE_LISTENER_POS", eyePos player];
    _occ = [_posASL vectorAdd [0, 0, 1.5], _ear, player] call acre_sys_core_fnc_findOcclusion;
    if !(_occ isEqualType 0) then {_occ = 1};
};
private _vol = ((_volume max 0) min 1) * _occ * (missionNamespace getVariable ["acre_sys_core_globalVolume", 1]);
private _dir = (ASLToAGL _posASL) vectorFromTo (ASLToAGL (eyePos player));
private _tag = format ["%1_%2", round (diag_tickTime * 1000), floor random 100000];
fce_voiceReplay_pending set [_tag, _fallback];
["fce_playVoiceReplay", [_id, _posASL # 0, _posASL # 1, _posASL # 2, _dir # 0, _dir # 1, _dir # 2, _vol, _pitch, 0, _tag]] call acre_sys_rpc_fnc_callRemoteProcedure;
// no answer from the plugin (an unpatched plugin doesn't know the command): fall back
[_tag] spawn {
    params ["_tag"];
    sleep 1.5;
    private _fb = fce_voiceReplay_pending getOrDefault [_tag, []];
    fce_voiceReplay_pending deleteAt _tag;
    if (_fb isNotEqualTo []) then {(_fb param [1, []]) call (_fb select 0)};
};
