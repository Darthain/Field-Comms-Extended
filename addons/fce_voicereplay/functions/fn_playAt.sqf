/*
    Field Comms Extended: voice replay. Play one of _unit's recent clips from _posASL, for everyone within _range.
    Run anywhere (usually the server). Each listener's own plugin plays its own copy; if a listener's plugin has nothing
    of that player (or they didn't opt in), _fallback runs on that listener's machine instead: [code, args] or [].

    Arguments: unit whose voice, position ASL, range m, volume 0..1, pitch (1 = as recorded), fallback
    Example:   [_victim, getPosASL _creature, 60, 0.9, 0.97, [{playSound3D [_this select 0, objNull, false, _this select 1, 2, 1, 60, 0, true]}, [_file, _pos]]] call fce_voicereplay_fnc_playAt;
*/
params [["_unit", objNull], ["_posASL", [0, 0, 0]], ["_range", 60], ["_volume", 1], ["_pitch", 1], ["_fallback", []]];
private _listeners = allPlayers select {alive _x && {(_x distance2D (ASLToAGL _posASL)) < _range}};
{
    [_unit, _posASL, _range, _volume, _pitch, _fallback] remoteExecCall ["fce_voicereplay_fnc_playLocal", _x];
} forEach _listeners;
