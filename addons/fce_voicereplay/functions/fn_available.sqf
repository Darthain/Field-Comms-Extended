/*
    Field Comms Extended: voice replay. Can _unit's voice be replayed? (any machine)
    True when the server allows it and that player has opted in. Whether there's actually a clip yet is only known to
    each listener's plugin: fn_playAt's fallback covers the case where there isn't.
*/
params [["_unit", objNull]];
!isNull _unit && {missionNamespace getVariable ["fce_voiceReplay_enabled", false]} && {_unit getVariable ["fce_voiceReplay_consent", false]}
