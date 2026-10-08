# Project Coding Rules (Non-Obvious Only)

- **Sequence numbers are mandatory**: Every source line must end with an 8-digit sequence number (e.g. `00010000`). Increment by 10 for new lines; use mid-range values (e.g. `00015000`) for insertions between existing lines.
- **Include syntax differs by type**: Use `%INCLUDE LGCMAREA;` for PL/I compile-time includes; use `EXEC SQL INCLUDE LGPOLICY;` for SQL preprocessor includes. Mixing the two will cause compile failures.
- **COMM_AREA is a UNION**: The `COMM_AREA` structure in `Includes/LGCMAREA.inc` overlays `COMM_AREA_RAW CHAR(32500)` over all typed sub-fields. Never add new top-level members — add inside the existing `2 *,` branch or it will break the UNION overlay.
- **`CA_RETURN_CODE` is `PIC '99'`** (character picture), not binary. Set it with string literals (`'00'`, `'98'`) and compare with `> 0`, not `= 0`.
- **`WRITE_ERROR_MESSAGE` is an internal subroutine**, not a program call. It calls `LGSTSQ` via `EXEC CICS LINK` — do not replicate TSQ writes directly; always route through this procedure.
- **Business Rules (ODM) is disabled by default**: The `LGAPBR01` call in `LGAPOL01` only fires when `BUSINESS_RULES = 'Y'`. The commented-out `MOVE` line is intentional — do not uncomment unless ODM is deployed.
- **`LGPOLICY.inc` field lengths are the single source of truth** for DB2 record sizes. If DB2 schema changes, update `WS_*_LEN` constants in `LGPOLICY.inc` first — programs read these at run time.
- **Data dictionary location**: `.bobz/DD.json` (if created). Check `.bobz/local-settings.json` for `databaseLocation` before running analysis queries.
