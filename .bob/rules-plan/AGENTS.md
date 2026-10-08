<<<<<<< Updated upstream
# Project Architecture Constraints (Non-Obvious Only)

- **COMM_AREA is the only IPC mechanism**: All data between tiers passes through the single 32500-byte `COMM_AREA` structure. There is no shared memory, no MQ, no DB2 result passing — the `CA_REQUEST_ID` (6 chars, e.g. `'01AEND'`, `'01IMOT'`) controls which UNION branch is active.
- **Policy type is encoded as a 1-char code** in `policy.policyType`: `E`=Endowment, `H`=House, `M`=Motor, `C`=Commercial. This code determines which DB2 sub-table (`endowment`/`house`/`motor`/`Commercial`) is accessed — it is not stored in the COMM_AREA header.
- **`endowment.paddingData` is a DB2 VARCHAR(32606)** — the largest field in the schema. Any plan that restructures the endowment table must account for the varying-length insert pattern using `WS_VARY_FIELD` in `LGAPDB01.pli`.
- **VSAM tier programs (`LGxPVS01`) are parallel to DB2 programs** — same COMM_AREA interface. The `OL` (business logic) program decides which back-end to call; adding a new policy type requires changes in both tiers.
- **No automated test harness exists in this repo** — testing is performed interactively via CICS terminal transactions (`LGTE`, `LGSE`, etc.) mapped in `Resources/`. Plan for manual regression against the CICS region after any change.
- **Customer IDs auto-increment from 1000001** (DB2 GENERATED IDENTITY), but seed data inserts IDs 1–10 explicitly — any new seed inserts must use values outside 1–10 or reset the identity sequence to avoid conflicts.
=======
# AGENTS.md - Plan Mode Guidance

- **Layer Separation**: `LGxPOL01` contains business routing and rule validation only; data access logic is strictly decoupled into `LGxPDB01` (Db2) and `LGxPVS01` (VSAM). Maintain this separation for any refactoring or enhancements.
- **COMMAREA Compatibility**: Any change to `Includes/LGCMAREA.inc` affects all modules (`LGAP*`, `LGDP*`, `LGIP*`, `LGUP*`). Ensure field alignment and total size within 32,500 bytes.
- **Shared Error Reporting**: New programs must integrate with `LGSTSQ` temporary storage queue logging utility to follow standard system diagnostics.
>>>>>>> Stashed changes
