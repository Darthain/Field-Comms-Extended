/*
    Field Comms Extended: voice replay (client).
    Publishes my own opt-in, and tells my TeamSpeak plugin which other players opted in (by their TeamSpeak ID).
    The plugin forgets anyone not on the list straight away, and keeps nothing at all while the server setting is off.
*/
if (!hasInterface || {isNull player}) exitWith {};
private _enabled = missionNamespace getVariable ["fce_voiceReplay_enabled", false];
private _mine = _enabled && {missionNamespace getVariable ["fce_voiceReplay_consent", false]};
if ((player getVariable ["fce_voiceReplay_consent", false]) isNotEqualTo _mine) then {player setVariable ["fce_voiceReplay_consent", _mine, true]};
private _ids = [];
if (_enabled) then {
    {
        if (_x != player && {_x getVariable ["fce_voiceReplay_consent", false]}) then {
            private _id = _x getVariable ["acre_sys_core_ts3id", -1];
            if !(_id isEqualType 0 && {_id >= 0}) then {_id = (missionNamespace getVariable ["fce_voiceReplay_ids", createHashMap]) getOrDefault [getPlayerUID _x, -1]};
            if (_id isEqualType 0 && {_id >= 0}) then {_ids pushBackUnique _id};
        };
    } forEach allPlayers;
};
_ids sort true;
private _msg = format ["%1|%2", [0, 1] select _enabled, (_ids apply {str _x}) joinString ";"];
if (_msg != fce_voiceReplay_sent) then {
    fce_voiceReplay_sent = _msg;
    ["fce_setVoiceReplay", [[0, 1] select _enabled, (_ids apply {str _x}) joinString ";"]] call acre_sys_rpc_fnc_callRemoteProcedure;
};
