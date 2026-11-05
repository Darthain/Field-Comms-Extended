/*
    Field Comms Extended: voice replay (client).
    Keeps this player's plugin told who has opted in, and publishes this player's own choice.
*/
if (!hasInterface) exitWith {};
fce_voiceReplay_pending = createHashMap;   // tag -> [code, args] to run if there was nothing to replay
fce_voiceReplay_sent = "";
fce_voiceReplay_ids = createHashMap;       // player UID -> TeamSpeak ID, as last heard (survives their respawn)
["fce_handleVoiceReplay", fce_voicereplay_fnc_handleReply] call acre_sys_rpc_fnc_addProcedure;
// someone opted in has just started talking: make sure my plugin knows them before their first words are gone
["acre_remoteStartedSpeaking", {
    params [["_unit", objNull]];
    if (isNull _unit) exitWith {};
    private _id = _unit getVariable ["acre_sys_core_ts3id", -1];
    if (_id isEqualType 0 && {_id >= 0} && {getPlayerUID _unit != ""}) then {fce_voiceReplay_ids set [getPlayerUID _unit, _id]};
    if (_unit getVariable ["fce_voiceReplay_consent", false]) then {call fce_voicereplay_fnc_syncConsent};
}] call CBA_fnc_addEventHandler;
[] spawn {
    waitUntil {!isNull player};
    while {true} do {
        call fce_voicereplay_fnc_syncConsent;
        sleep 2;
    };
};
