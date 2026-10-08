# Project Documentation Context (Non-Obvious Only)

## File Extensions Are Non-Standard
- `.pli` = PL/I program source (not a typical mainframe `.pl1` extension)
- `.inc` = PL/I include/copybook (not a C header)
- `.bms` = BMS map source (generates the `.inc` file in `Includes/SSMAP.inc`)

## CSD File Contains the Complete Program Inventory
`Resources/DFHCSDUP.csd` is the authoritative list of all programs registered in CICS, including programs that have NO corresponding PL/I source in this repo (many `LGxx` COBOL programs appear there — this is a mixed-language application; the PLI programs are the `genapp-pli` counterparts to the COBOL `genapp` application).

## COMMAREA Is the Entire Interface
There are no REST APIs, message queues, or files between tiers. Every program-to-program call uses `EXEC CICS LINK` with a single 32,500-byte COMMAREA. All business routing decisions are based on the 6-character `CA_REQUEST_ID` field at offset 0.

## LGTESTP1 Is Both Test Harness and Production Menu
`LGTESTP1` (transaction `SSP1`) is the CICS terminal menu program for Motor policies. It is shipped as production code and used for interactive testing — there is no separate test framework.

## Inline Comments in PL/I Use `//`
Some code uses C++-style `//` line comments (visible in `LGTESTP1` lines 90–91). This is valid in IBM PL/I for z/OS but uncommon; the project mixes `/* */` block comments and `//` line comments.
