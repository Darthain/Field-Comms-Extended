#include "..\script_component.hpp"

GVAR(OptRadioOptions) = ["RADIO_OPTIONS", "RADIO OPTIONS", "OPT-RADIO",
    MENUTYPE_LIST,
    [
        [nil, "SATCOM BURST MODE", "", MENU_ACTION_SUBMENU, ["ERROR_NOENTRY"], nil ],
        [nil, "RADIO SILENCE SCREEN", "", MENU_ACTION_SUBMENU, ["ERROR_NOENTRY"], nil ],
        [nil, "RADIO SPEAKER", "OPT-RADIO-SPEAKER",
            MENUTYPE_SELECTION,
            [
                [ROW_LARGE_2, ALIGN_CENTER, "RADIO SPEAKER"],
                [ROW_LARGE_3, ALIGN_CENTER, "%1"],
                [ROW_SMALL_5, ALIGN_CENTER, "^ TO SCROLL / ENT TO CONT"]
            ],
            [
                {
                    private _value = GET_STATE("audioPath");
                    //diag_log text format["render: %1", _value];
                    if (_value == "INTAUDIO") then {
                        SCRATCH_SET(GVAR(currentRadioId),"opt_radio_speaker","ON");
                        SET_STATE("menuSelection",1);
                    };
                },
                {
                    //diag_log text format["save!"];
                    // If its RX only, zero out the TX frequency and
                    // Skip the rest of the menus
                    private _menu = _this select 0;
                    private _value = SCRATCH_GET_DEF(GVAR(currentRadioId),"opt_radio_speaker","OFF");
                    if (_value == "ON") then {
                        //diag_log text format["ON!!!!!!!"];
                        SET_STATE("audioPath","INTAUDIO");
                    } else {
                        SET_STATE("audioPath","TOPAUDIO");
                    };
                },nil,nil
            ],
            [
                ["OFF", "ON"],
                [ROW_LARGE_3, 0, -1] // Highlighting cursor information
            ],
            "opt_radio_speaker"
        ],
        [nil, "AUXILIARY POWER", "", MENU_ACTION_SUBMENU, ["ERROR_NOENTRY"], nil ],
        [nil, "PRESET AUTOSAVE", "", MENU_ACTION_SUBMENU, ["ERROR_NOENTRY"], nil ],
        [nil, "RF FAULTS PERSIST", "", MENU_ACTION_SUBMENU, ["ERROR_NOENTRY"], nil ]
    ],
    nil
];
[GVAR(OptRadioOptions)] call FUNC(createMenu);


GVAR(OptTxOptions) = ["TX_POWER_OPTIONS", "TX POWER OPTIONS", "OPT-TX",
    MENUTYPE_LIST,
    [
        [nil, "ACCESS DENIED", "", MENU_ACTION_SUBMENU, ["ERROR_NOENTRY"], nil ]
    ],
    nil
];
[GVAR(OptTxOptions)] call FUNC(createMenu);



// FCE: SYSTEM CLOCK, GPS OPTIONS and NETWORK STATUS screens (previously "NO ITEMS IN MENU").
// Each fills its rows when opened (ACRE calls the entry function with the menu itself as _this).
private _articBack = {
    if ((_this select 1) select 0 in ["ENT", "CLR"]) then {
        private _home = GET_STATE_DEF("currentHome",GVAR(VULOSHOME));
        [_home] call FUNC(changeMenu);
    };
};
private _articScreen = {
    params ["_id", "_title", "_fill", "_back"];
    private _menu = [_id, _id, "", MENUTYPE_STATIC,
        [
            [ROW_SMALL_1, ALIGN_LEFT, "$transmitting $bat         $cch-channelmode $cch-squelch $cch-encryption"],
            [ROW_LARGE_1, ALIGN_CENTER, _title],
            [ROW_LARGE_2, ALIGN_CENTER, ""],
            [ROW_LARGE_3, ALIGN_CENTER, ""],
            [ROW_SMALL_5, ALIGN_CENTER, "ENT OR CLR TO CONT"]
        ],
        [_fill, nil, _back]
    ];
    [_menu] call FUNC(createMenu);
};
["FCE_GPS", "GPS", {
    private _p = getPosASL acre_player;
    private _pad = { params ["_v"]; private _s = str _v; while { count _s < 4 } do { _s = "0" + _s; }; _s select [count _s - 4, 4] };
    MENU_SUBMENUS(_this) set [2, [ROW_LARGE_2, ALIGN_CENTER, format ["%1 %2", [floor ((_p select 0) / 10)] call _pad, [floor ((_p select 1) / 10)] call _pad]]];
    MENU_SUBMENUS(_this) set [3, [ROW_LARGE_3, ALIGN_CENTER, format ["ALT %1M HDG %2", round (_p select 2), round (getDir acre_player)]]];
}, _articBack] call _articScreen;
["FCE_SYSTEM_CLOCK", "SYSTEM CLOCK", {
    date params ["_y", "_m", "_d", "_h", "_min"];
    private _two = { params ["_v"]; (["", "0"] select (_v < 10)) + str _v };
    MENU_SUBMENUS(_this) set [2, [ROW_LARGE_2, ALIGN_CENTER, format ["%1:%2Z", [_h] call _two, [_min] call _two]]];
    MENU_SUBMENUS(_this) set [3, [ROW_LARGE_3, ALIGN_CENTER, format ["%1-%2-%3", _y, [_m] call _two, [_d] call _two]]];
}, _articBack] call _articScreen;
["FCE_NETWORK_STATUS", "NETWORK STATUS", {
    private _data = [GVAR(currentRadioId), "getCurrentChannelData"] call EFUNC(sys_data,dataEvent);
    private _enc = HASH_GET(_data,"encryption") == 1;
    MENU_SUBMENUS(_this) set [2, [ROW_LARGE_2, ALIGN_CENTER, format ["TX %1 RX %2",
        [HASH_GET(_data,"frequencyTX"), 1, 3] call CBA_fnc_formatNumber, [HASH_GET(_data,"frequencyRX"), 1, 3] call CBA_fnc_formatNumber]]];
    MENU_SUBMENUS(_this) set [3, [ROW_LARGE_3, ALIGN_CENTER, ["PLAIN TEXT", format ["SECURE  TEK %1", HASH_GET(_data,"TEK")]] select _enc]];
}, _articBack] call _articScreen;

GVAR(OPT) = ["OPT", "OPT", "OPT",
    MENUTYPE_LIST,
    [
        // TODO: Locks all but next. 1,3,7,9 series unlocks. Display "Keypad is Locked"
        
        [nil, "LOCK KEYPAD", "", MENU_ACTION_SUBMENU, ["ERROR_NOENTRY"], nil ],
        [nil, "RADIO OPTIONS", "", MENU_ACTION_SUBMENU, ["RADIO_OPTIONS"], nil ],
        [nil, "WAVEFORM OPTIONS", "", MENU_ACTION_SUBMENU, ["ERROR_NOENTRY"], nil ],
        [nil, "TX POWER OPTIONS", "", MENU_ACTION_SUBMENU, ["TX_POWER_OPTIONS"], nil ],
        [nil, "SYSTEM CLOCK", "", MENU_ACTION_SUBMENU, ["FCE_SYSTEM_CLOCK"], nil ],
        [nil, "GPS OPTIONS", "", MENU_ACTION_SUBMENU, ["FCE_GPS"], nil ],
        [nil, "BATTERY INFORMATION", "", MENU_ACTION_SUBMENU, ["ERROR_NOENTRY"], nil ],
        [nil, "SA OPTIONS", "", MENU_ACTION_SUBMENU, ["ERROR_NOENTRY"], nil ],
        [nil, "DATA MODE", "", MENU_ACTION_SUBMENU, ["ERROR_NOENTRY"], nil ],
        [nil, "MISSION PLAN", "", MENU_ACTION_SUBMENU, ["ERROR_NOENTRY"], nil ],
        [nil, "NETWORK STATUS", "", MENU_ACTION_SUBMENU, ["FCE_NETWORK_STATUS"], nil ],
        [nil, "SYSTEM INFORMATION", "", MENU_ACTION_SUBMENU, ["ERROR_NOENTRY"], nil ],
        [nil, "TEST OPTIONS", "", MENU_ACTION_SUBMENU, ["ERROR_NOENTRY"], nil ],
        [nil, "VIEW KEY INFO", "", MENU_ACTION_SUBMENU, ["ERROR_NOENTRY"], nil ]
    ],
    nil
];
[GVAR(OPT)] call FUNC(createMenu);
