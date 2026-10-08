# Project Coding Rules (Non-Obvious Only)

## Include Syntax — Critical Distinction
- Use `%INCLUDE filename;` (PL/I preprocessor) in `*OL01` business-logic programs.
- Use `EXEC SQL INCLUDE filename;` (DB2 precompiler) in `*DB01` data-access programs.
- Using the wrong include syntax for the wrong tier is a compile/precompile error.

## DB2 Host Variable Conversion (Mandatory)
PIC numeric COMMAREA fields cannot be used directly in `EXEC SQL`. Always move them to `FIXED BIN(15)` or `FIXED BIN(31)` variables in the program's `DB2_IN_INTEGERS` structure before any SQL statement. Skipping this causes a DB2 precompile error.

## Sequence Numbers
Every source line must end with an 8-digit sequence number (`NNNNN000`). Increment by 10 for new lines inserted between existing ones (e.g., `00100005` for a line inserted between `00100000` and `00110000`). Do not leave lines without sequence numbers.

## Sub-Table Insert Failure Backout
When an insert to a sub-table (ENDOWMENT, HOUSE, MOTOR, COMMERCIAL, CLAIM) fails after the POLICY row was already inserted, issue `EXEC CICS ABEND ABCODE('LGSQ') NODUMP` to trigger transaction backout — do not just set `CA_RETURN_CODE` and return.

## Varying-Length Field (ENDOWMENT PADDINGDATA)
The DB2 `PADDINGDATA` VARCHAR column requires a two-part structure: `WS_VARY_LEN FIXED BIN(15)` + `WS_VARY_CHAR CHAR(3900)` declared at level 49. Pass `WS_VARY_FIELD` (the parent level) as the host variable — not the char subfield.

## COMMAREA Length Check
Always validate `EIBCALEN >= WS_CA_HEADER_LEN + <policy-specific-len>` before accessing policy-specific fields. The specific lengths are constants in `Includes/LGPOLICY.inc` — do not hardcode them in individual programs.

## Policy Field Lengths — Single Source of Truth
All policy record length constants (`WS_CUSTOMER_LEN`, `WS_FULL_ENDOW_LEN`, etc.) live exclusively in [`Includes/LGPOLICY.inc`](../../Includes/LGPOLICY.inc). Change lengths only there.
