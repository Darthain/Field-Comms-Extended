# ACRE2 issues found by Field Comms Extended (ready to file at github.com/IDI-Systems/acre2)

Found while building Field Comms Extended against ACRE2 2.14.0. ACRE compiles its functions as final in release builds,
so an addon can't patch these from outside; they need fixing in ACRE itself. Each is written as an issue.

## 1. `handleSignalData` reads an undefined `_rxChannel` (PRC-148, PRC-152, PRC-117F)
`sys_prc148/radio/fnc_handleSignalData.sqf` (identical in `sys_prc152` and `sys_prc117f`): the CTCSS check uses
`HASH_GET(_rxChannel,"CTCSSRx")`, but `_rxChannel` is never defined (the receiving radio's data is in
`_radioRxData`). It's reached only when modulation, encryption, TEK and traffic rate all match, so it errors in
that case. Suggested fix: use `_radioRxData` in both CTCSS terms.

## 2. `drawCursor` uses `_rowCount` when it may be undefined (PRC-152, PRC-117F)
`sys_prc152/menus/fnc_drawCursor.sqf` line 21 (`// TODO undefined in some cases`) and line 65-66, same in
`sys_prc117f`. `_rowCount` is only assigned inside some branches, then used for `_saveLength`. Suggested fix:
initialise `_rowCount` to the current row's column count before the branches.

## 3. PRC-152 OPT menu entries lead to "NO ITEMS IN MENU"
`sys_prc152/farris_menus/OPT.sqf`: LOCK KEYPAD, WAVEFORM OPTIONS, SYSTEM CLOCK, GPS OPTIONS, BATTERY INFORMATION,
SA OPTIONS, DATA MODE, MISSION PLAN, NETWORK STATUS, SYSTEM INFORMATION, TEST OPTIONS, and under RADIO OPTIONS:
SATCOM BURST MODE, RADIO SILENCE SCREEN, AUXILIARY POWER, PRESET AUTOSAVE, RF FAULTS PERSIST, all point at
`ERROR_NOENTRY`. Field Comms Extended implements GPS OPTIONS, SYSTEM CLOCK and NETWORK STATUS as static screens through
`createMenu` (code available to contribute). LOCK KEYPAD needs button handling inside ACRE (see the TODO above it).

## 4. PRC-117F digital squelch is UI-only
`sys_prc117f/farris_menus/SQ.sqf`: the DIGITAL SQUELCH selection isn't saved ("as there is no digital currently
(and the value is not saved)") and doesn't affect reception.

## 5. `getStates` not implemented (PRC-148, SEM 70, SEM 52 SL)
`sys_prc148/radio/fnc_getStates.sqf` is a stub; the SEM 70 and SEM 52 SL versions likewise, and the SEM 52 SL's
`PREP_MODULE(radio,getStates)` is commented out in `functions/__PREP__.sqf`.

## 6. PRC-117F and PRC-152 ignore `setStateCritical`
`CfgAcreRadios.hpp` of both radios maps `setState` to `FUNC(setState)` but has no `setStateCritical` entry (the
PRC-148 has `setStateCritical = QFUNC(setState)`). The system half of the event still broadcasts it, but no radio
stores the value, locally or remotely, so `SET_STATE_CRIT` silently does nothing on these radios. Suggested fix: add
`setStateCritical = QFUNC(setState);` as on the PRC-148.

## Correction (not a bug)
Encryption key (TEK) matching is implemented on the PRC-148, PRC-152 and PRC-117F (`handleMultipleTransmissions`
and `handleSignalData`); it's just off by default in the presets. Field Comms Extended' Side Encryption module turns it on.
