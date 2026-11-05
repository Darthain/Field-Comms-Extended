// Field Comms Extended: the Side Encryption module, part of Field Comms Extended (GPL-3.0).
// Radio fixes and features live directly in the forked ACRE addons; this addon only adds mission-start
// encryption through ACRE's preset API.
class CfgPatches {
    class fce_main {
        name = "Field Comms Extended";
        author = "Field Comms Extended contributors";
        units[] = {"FCE_ModuleEncryption"};
        weapons[] = {};
        requiredVersion = 2.18;
        requiredAddons[] = {"cba_main", "cba_xeh", "cba_settings", "acre_main", "acre_api", "acre_sys_prc152", "acre_sys_prc117f", "acre_sys_prc148"};
    };
};
class Extended_PreInit_EventHandlers {
    class fce_main { init = "call compile preprocessFileLineNumbers '\z\fce\addons\main\XEH_preInit.sqf'"; };
};
class Extended_PostInit_EventHandlers {
    class fce_main { init = "call compile preprocessFileLineNumbers '\z\fce\addons\main\XEH_postInit.sqf'"; };
};
class CfgFunctions {
    class FCE {
        class comms {
            file = "\z\fce\addons\main\functions";
            class setupEncryption {};
            class applyEncryption {};
            class moduleEncryption {};
        };
    };
};
class CfgFactionClasses {
    class FCE_Modules { displayName = "Field Comms Extended"; priority = 2; side = 7; };
};
class CfgVehicles {
    class Logic;
    class Module_F: Logic {
        class AttributesBase { class Checkbox; class Edit; class ModuleDescription; };
        class ModuleDescription;
    };
    class FCE_ModuleEncryption: Module_F {
        scope = 2;
        displayName = "Side Encryption";
        category = "FCE_Modules";
        function = "FCE_fnc_moduleEncryption";
        functionPriority = 1;
        isGlobal = 1;
        isTriggerActivated = 0;
        is3DEN = 0;
        class Attributes: AttributesBase {
            class West: Checkbox { property = "FCE_encWest"; displayName = "BLUFOR encrypted"; typeName = "BOOL"; defaultValue = "false"; };
            class WestKey: Edit { property = "FCE_tekWest"; displayName = "BLUFOR key (TEK)"; typeName = "NUMBER"; defaultValue = "1"; };
            class East: Checkbox { property = "FCE_encEast"; displayName = "OPFOR encrypted"; typeName = "BOOL"; defaultValue = "false"; };
            class EastKey: Edit { property = "FCE_tekEast"; displayName = "OPFOR key (TEK)"; typeName = "NUMBER"; defaultValue = "2"; };
            class Guer: Checkbox { property = "FCE_encGuer"; displayName = "Independent encrypted"; typeName = "BOOL"; defaultValue = "false"; };
            class GuerKey: Edit { property = "FCE_tekGuer"; displayName = "Independent key (TEK)"; typeName = "NUMBER"; defaultValue = "3"; };
            class ModuleDescription: ModuleDescription {};
        };
        class ModuleDescription: ModuleDescription {
            description = "Turns ACRE encryption on from mission start for the chosen sides, each with its own key (TEK), on the PRC-152, PRC-117F and PRC-148. Radios only hear encrypted traffic with the same key. Overrides the matching CBA settings for this mission.";
        };
    };
};

