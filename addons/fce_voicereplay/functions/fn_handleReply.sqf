/*
    Field Comms Extended: voice replay (client). The plugin's answer to fce_playVoiceReplay: tag, 1 played / 0 nothing to play
*/
params [["_tag", ""], ["_played", "0"]];
private _fb = fce_voiceReplay_pending getOrDefault [_tag, []];
fce_voiceReplay_pending deleteAt _tag;
if ((parseNumber _played) != 1 && {_fb isNotEqualTo []}) then {(_fb param [1, []]) call (_fb select 0)};
