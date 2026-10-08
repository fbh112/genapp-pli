# AGENTS.md

This file provides guidance to agents when working with code in this repository.

## Project Overview

**GenApp-PLI** — a CICS-based general insurance application written in **PL/I** (z/OS mainframe). No build toolchain exists in this repo; compilation and deployment happen on the target z/OS system via JCL.

## Repository Layout

| Directory       | Contents                                                                                                                                                        |
| -----------------| -----------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `PLI Programs/` | PL/I source files (`.pli`) — business and DB tier programs                                                                                                      |
| `Includes/`     | PL/I copybooks (`.inc`) — shared data structures                                                                                                                |
| `Maps/`         | CICS BMS map source (`.bms`)                                                                                                                                    |
| `DDL/`          | DB2 DDL and seed data (`db2cre.jcl`) — contains `<placeholder>` tokens that must be substituted before execution                                                |
| `Resources/`    | CICS CSD definitions (`DFHCSDUP.csd`, `GenApp.CSD`) — all programs registered in group `GENASAP`                                                                |
| `docs/`         | Generated documentation — all agent-produced documents (implementation plans, impact analyses, program docs, wikis, data dictionaries, etc.) must be saved here |

## Program Naming Convention

Programs follow a strict 8-char naming scheme: `LG{A|D|I|U}{P|C}{DB|OL|VS}01`

- 3rd char: `A`=Add, `D`=Delete, `I`=Inquire, `U`=Update
- 4th char: `P`=Policy, `C`=Customer
- 5th-6th chars: `DB`=DB2 tier, `OL`=business logic tier, `VS`=VSAM tier
- `LGTESTP1` — CICS terminal menu program (motor policy)

**Three-tier calling chain** (all via `EXEC CICS LINK`):
```
LGxPOL01 (business logic) → LGxPDB01 (DB2 access) / LGxPVS01 (VSAM access)
```
Business logic programs optionally call `LGAPBR01` (ODM business rules — disabled by default, enabled by setting `BUSINESS_RULES = 'Y'`).

## Shared Copybooks (Includes/)

- **`LGCMAREA.inc`** — `%INCLUDE LGCMAREA;` — defines the universal 32500-byte `COMM_AREA` UNION and pointer `COMM_AREA_PTR`. Every program receives it as main entry parameter.
- **`LGPOLICY.inc`** — included via `EXEC SQL INCLUDE LGPOLICY;` (SQL precompiler include, not `%INCLUDE`) — DB2 host variable structures for all policy types.
- **`LGCMARER.inc`** — Business Rules request/response structures for ODM (`RQST_AREA_PTR` / `RSPN_AREA_PTR`).
- **`SSMAP.inc`** — BMS map symbolic definitions, included with `%INCLUDE SSMAP;`.

## PL/I Code Style Conventions

- **Sequence numbers**: Every line ends with an 8-digit sequence number (`00010000`, `00020000` …). These are z/OS source record numbers — do not remove them.
- **Indentation**: 1-space indent at proc level; nested structures use additional 2-space levels.
- **Declarations**: All `DCL` at top of proc before any executable code. Level-1 structures declared with `DCL 1 NAME,` followed by subordinate members.
- **UNION usage**: `COMM_AREA` and all DB2 host variable structures use `UNION` to overlay raw CHAR fields over structured sub-fields — do not add intermediate levels that break the overlay.
- **Error handling pattern**: All programs declare a common `ERROR_MSG` structure and call `WRITE_ERROR_MESSAGE` internal procedure, which links `LGSTSQ` (TSQ writer utility) to log to a transient data queue.
- **Commarea length check**: Every program checks `EIBCALEN = 0` (abend `LGCA`) and `EIBCALEN < WS_REQUIRED_CA_LEN` (return code `98`) before processing.
- **CA_RETURN_CODE**: Declared as `PIC '99'` (2-digit numeric picture), compared as `> 0` or set to `'00'`/`'98'`/`'99'` string literals.
- **Program entry**: `ProcName: Proc(COMM_AREA_PTR) Options(Main);` — terminal menu programs add `Reentrant` and also receive `DFHEIPTR`.

## DB2 Integration Notes

- DB2 host variable structures are in `LGPOLICY.inc` (included via SQL preprocessor `EXEC SQL INCLUDE`).
- Integer DB2 columns map to `FIXED BIN(31)`, SMALLINT to `FIXED BIN(15)`, DATE to `CHAR(10)`, TIMESTAMP to `CHAR(26)`.
- The `endowment.paddingData` column is `VARCHAR(32606)` — accessed via a `WS_VARY_FIELD` structure with `49 WS_VARY_LEN FIXED BIN(15)` + `49 WS_VARY_CHAR CHAR(3900)` to handle varying-length DB2 inserts.
- DDL placeholders (`<DB2HLQ>`, `<DB2SSID>`, `<DB2PLAN>`, `<DB2RUN>`, `<SQLID>`, `<DB2DBID>`) must be substituted before running `DDL/db2cre.jcl`.

## CICS Resources

- All programs are defined in CICS group `GENASAP` (see `Resources/DFHCSDUP.csd`).
- CSD definitions in `DFHCSDUP.csd` reflect COBOL language (`LANGUAGE(COBOL)`) even for PL/I programs — this is a known inconsistency in the CSD export; actual programs are PL/I.
- Error messages are written to a TSQ via the utility program `LGSTSQ` (CICS LINK, not direct TSQ API calls).

## Generated Document Output

All documents produced by agents **must** be saved under the `docs/` folder. This applies to every workflow and task type, including but not limited to:

- Implementation plans → `docs/implementation-plans/`
- Impact analysis reports → `docs/impact-analysis/`
- Program documentation → `docs/program-docs/`
- Application wikis → `docs/wiki/`
- Data dictionaries → `docs/data-dictionary/`
- Business rules extractions → `docs/business-rules/`

When a workflow or skill specifies a default output path (e.g. `.bobz/implementation-plans/…`), override that path and write to the corresponding `docs/` subdirectory instead.

## Local Metadata Database

A Bob local analysis database has been scanned and stored. Location is recorded in `.bobz/local-settings.json`. Use `execute_sql_query`, `get_program_dependencies`, `get_paragraphs`, or `get_control_flow` tools against it for dependency and flow analysis.
