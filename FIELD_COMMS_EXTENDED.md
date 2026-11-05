# Field Comms Extended (FCE): a fork of ACRE2 2.14.0.1064

Field Comms Extended is a community fork of **ACRE2** by the ACRE2 Team / IDI-Systems
(github.com/IDI-Systems/acre2), licensed **GPL-3.0** like ACRE2. It is **not** the official ACRE2 and is not
affiliated with or endorsed by the ACRE2 Team.

**Script-only fork.** Only ACRE's SQF / config addons are changed. ACRE's TeamSpeak plugin, game extension and every
unchanged PBO stay exactly as released, and the internal version stays **2.14.0.1064** so they accept the forked
addons. ACRE's addon and function names are kept, so mods built for ACRE keep working. Fixes are offered back to
ACRE (UPSTREAM.md).

Release: **2.14.0-fce1** (the former ARTIC ACRE 2.14.0-artic2, renamed).

## Changes (all marked "FCE" in the code)
- **PRC-117F digital squelch works** (`sys_prc117f`): PGM > SQ > DIGITAL SQUELCH ON is saved on the radio (synced),
  then a DIGITAL SQ CODE (1-8) is chosen. With it on, the radio only opens for transmissions carrying its code
  (others still interfere). Every radio transmits its own code (1 unless set). The SQ menu opens on the saved state.
- **PRC-152 screens** (`sys_prc152`): OPT > GPS OPTIONS (8-figure grid, altitude, heading), SYSTEM CLOCK (mission
  date and time), NETWORK STATUS (TX/RX frequency, encryption and key). Previously "NO ITEMS IN MENU".
- **Fixed: undefined `_rxChannel`** in the CTCSS check of `handleSignalData` (`sys_prc148`, `sys_prc152`, `sys_prc117f`).
- **Fixed: `_rowCount` undefined** for left-aligned text in `drawCursor` (`sys_prc152`, `sys_prc117f`).
- **Fixed: `createMenu` errors on static screens** (it treated their text rows as sub-menus) (`sys_prc152`, `sys_prc117f`).
- **Fixed: `setStateCritical` ignored** by the PRC-117F and PRC-152 (config), so synced radio settings were never stored.
- **Side Encryption** (`fce` addon, `acre_fce.pbo`): turn ACRE encryption on per side from mission start, each with
  its own key (Eden module *Side Encryption* under Field Comms Extended, or CBA settings under Field Comms Extended).

## Installing
1. Copy your **@ACRE2** mod folder to **@Field_Comms_Extended** (keeps ACRE's plugin, extension and unchanged PBOs),
   and delete its `meta.cpp` (it holds ACRE's Workshop ID).
2. In `addons`, **replace** `acre_sys_prc117f.pbo`, `acre_sys_prc152.pbo`, `acre_sys_prc148.pbo` with FCE's, delete
   those three PBOs' old `.bisign` files, and **add** `acre_fce.pbo`. Replace `mod.cpp` with FCE's.
3. Sign the four FCE PBOs with your own key and add your `.bikey` to `keys` (keep ACRE's key: the unchanged PBOs
   still carry ACRE's signatures).
4. Load **@Field_Comms_Extended instead of @ACRE2** (never both).
5. After each ACRE update: re-copy the new @ACRE2 and rebuild FCE from the new ACRE source with FCE's changes merged.

## Upgrading from ARTIC ACRE (2.14.0-artic1/2)
The encryption addon was renamed: remove `acre_artic_comms.pbo` (and its signature), add `acre_fce.pbo`. Missions
using the old *Side Encryption* module (ARTIC Comms) need it placed again from the Field Comms Extended category, and
server encryption settings re-entered under Field Comms Extended.
