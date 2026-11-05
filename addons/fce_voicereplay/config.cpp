// Field Comms Extended: voice replay (game side). Needs Field Comms Extended's TeamSpeak plugin (with voice-replay.patch).
// A short in-memory record of what opted-in players last said, played back from a position in the world on request.
// Off unless the server allows it AND each player opts in; nothing is ever written to disk or sent between machines.
class CfgPatches {
    class fce_voicereplay {
        name = "Field Comms Extended - Voice Replay";
        author = "Darth; ACRE2 by the ACRE2 Team (IDI-Systems)";
        requiredVersion = 2.18;
        requiredAddons[] = {"acre_main", "acre_sys_core", "acre_sys_rpc", "cba_settings"};
        units[] = {};
        weapons[] = {};
    };
};
class Extended_PreInit_EventHandlers {
    class fce_voicereplay {
        init = "call compileScript ['\fce_voicereplay\XEH_preInit.sqf']";
    };
};
class CfgFunctions {
    class fce_voicereplay {
        tag = "fce_voicereplay";
        class core {
            file = "\fce_voicereplay\functions";
            class postInit {postInit = 1;};
            class available {};
            class playAt {};
            class playLocal {};
            class handleReply {};
            class syncConsent {};
        };
    };
};
