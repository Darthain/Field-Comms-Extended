# Field Comms Extended

**Field Comms Extended (FCE)** is a community fork of [ACRE2](https://github.com/IDI-Systems/acre2) (Advanced
Combat Radio Environment 2) by the ACRE2 Team / IDI-Systems. It finishes some of ACRE2's unfinished radio features
and fixes several bugs.

> FCE is **not** the official ACRE2 and is not affiliated with or endorsed by the ACRE2 Team. For ACRE2 itself,
> see https://github.com/IDI-Systems/acre2.

## What's different
FCE is a **script-only** fork of ACRE2 **2.14.0.1064**: only SQF and config addons change. ACRE2's TeamSpeak plugin,
game extensions and every unchanged addon stay exactly as released, and ACRE2's addon and function names are kept, so
mods built for ACRE2 keep working.

Current release **2.14.0-fce1**: working PRC-117F digital squelch, PRC-152 GPS / system clock / network status
screens, side encryption from mission start, and fixes for several ACRE2 bugs. Full details, install steps and the
change list: [FIELD_COMMS_EXTENDED.md](FIELD_COMMS_EXTENDED.md). Bugs reported back to ACRE2: [UPSTREAM.md](UPSTREAM.md).

## History
- Commit 1 imports ACRE2 `v2.14.0.1064` unmodified.
- Later commits are FCE's changes; every changed spot in the code is marked `FCE`.

## Licence
GPL-3.0, as ACRE2. Original code copyright the ACRE2 Team / IDI-Systems; modifications copyright the Field Comms
Extended contributors. See [LICENSE](LICENSE).
