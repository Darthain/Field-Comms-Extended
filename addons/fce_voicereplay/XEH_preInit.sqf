// Field Comms Extended: voice replay settings
[
    "fce_voiceReplay_enabled", "CHECKBOX",
    ["Allow voice replay", "Lets mods replay short clips of what players said (for example SCP-939 calling out in a dead teammate's voice). Only players who opt in themselves are ever recorded. Clips stay in each player's TeamSpeak plugin memory: never saved, never sent anywhere, wiped on disconnect."],
    ["Field Comms Extended", "Voice replay"],
    false,
    1,   // server decides, for everyone
    {}
] call CBA_fnc_addSetting;
[
    "fce_voiceReplay_consent", "CHECKBOX",
    ["Allow my voice to be replayed", "Opt in: other players' TeamSpeak plugins may keep a few seconds of what you last said, in memory only, so mods can play it back in the game (for example SCP-939 mimicking you). Off by default. Turning it off drops your clips from everyone's memory."],
    ["Field Comms Extended", "Voice replay"],
    false,
    2,   // each player's own choice
    {call fce_voicereplay_fnc_syncConsent}
] call CBA_fnc_addSetting;
