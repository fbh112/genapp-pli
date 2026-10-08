# AGENTS.md

This file provides guidance to agents when working with code in this repository.

## Project Overview

**GenApp-PLI** — IBM CICS/DB2 insurance application written in **PL/I** (z/OS mainframe). No build system, package manager, or test runner exists locally; all compilation, testing, and deployment occurs on the z/OS host.

## Repository Layout

| Directory | Contents |
|---|---|
| `PLI Programs/` | PL/I source files (`.pli`) — main application programs |
| `Includes/` | PL/I include files (`.inc`) — shared copybooks |
| `DDL/` | DB2 DDL and seed data in JCL (`db2cre.jcl`) |
| `Maps/` | BMS map source (`SSMAP.bms`) |
| `Resources/` | CICS CSD definitions (`DFHCSDUP.csd`, `GenApp.CSD`) |

## Program Naming Convention (non-obvious)

Programs follow a strict 8-character naming scheme: `LG` + operation + object + `01`:
- **Operation**: `A`=Add, `D`=Delete, `I`=Inquire, `U`=Update
- **Object**: `P`=Policy, `C`=Customer
- **Tier suffix**: `OL`=business logic (orchestrator), `DB`=DB2 data access, `VS`=VSAM data access

Examples: `LGAPOL01` (Add Policy business logic), `LGAPDB01` (Add Policy DB2), `LGAPVS01` (Add Policy VSAM).

`LGTESTP1` is the CICS interactive menu/test harness for Motor policies (transaction `SSP1`).

## Architecture: Three-Tier CICS LINK Chain

Every operation flows: **Menu program** → `EXEC CICS LINK` → **`LGxxOL01`** (business logic) → `EXEC CICS LINK` → **`LGxxDB01`** (DB2) **and** **`LGxxVS01`** (VSAM).

- All programs communicate exclusively via a **32,500-byte COMMAREA** (`COMM_AREA` / `COMM_AREA_PTR`).
- The COMMAREA structure is defined in [`Includes/LGCMAREA.inc`](Includes/LGCMAREA.inc) and included with `%INCLUDE LGCMAREA;` (PL/I preprocessor) or `EXEC SQL INCLUDE LGCMAREA;` (DB2 precompiler).
- Policy field lengths are centralised in [`Includes/LGPOLICY.inc`](Includes/LGPOLICY.inc) — change sizes **only there**, not in individual programs.

## Include Mechanism — Two Different Syntaxes

PL/I programs use **two distinct include mechanisms** that are not interchangeable:
- `%INCLUDE LGCMAREA;` — PL/I compile-time preprocessor include (used in `*OL01` programs)
- `EXEC SQL INCLUDE LGCMAREA;` — DB2 precompiler include (used in `*DB01` programs)

Both reference the same `.inc` files in `Includes/`. Using the wrong syntax for a given tier will cause compile/precompile failures.

## COMMAREA Request IDs

The `CA_REQUEST_ID` (6-char) field routes operations:

| ID | Operation |
|---|---|
| `01AEND` / `01IEND` / `01UEND` / `01DEND` | Endowment policy |
| `01AHOU` / `01IHOU` / `01UHOU` / `01DHOU` | House policy |
| `01AMOT` / `01IMOT` / `01UMOT` / `01DMOT` | Motor policy |
| `01ACOM` / `01ICOM` / `01UCOM` / `01DCOM` | Commercial policy |
| `01ACLM` / `01ICLM` | Claim |

## DB2 Type Conversion Pattern

Numeric PIC fields in the COMMAREA cannot be used directly as DB2 host variables. They must first be moved to `FIXED BIN(15)` (SMALLINT) or `FIXED BIN(31)` (INTEGER) variables prefixed `DB2_*` declared in a `DB2_IN_INTEGERS` structure before the `EXEC SQL` statement.

## Error Handling

- SQL errors: check `SQLCODE` after every `EXEC SQL`; use `SELECT (SQLCODE)` with explicit `WHEN (0)`, `WHEN (-530)`, and `OTHERWISE` branches.
- Non-SQL failures on sub-table inserts: issue `EXEC CICS ABEND ABCODE('LGSQ') NODUMP` to force transaction backout of the already-committed POLICY row.
- Missing COMMAREA: `EXEC CICS ABEND ABCODE('LGCA') NODUMP`.
- Error details written to CICS TSQ via `WRITE_ERROR_MESSAGE` procedure (present in every `*DB01` program).

## CICS Transactions (from `Resources/DFHCSDUP.csd`)

| Transaction | Program | Purpose |
|---|---|---|
| `SSP1` | `LGTESTP1` | Motor policy interactive menu |
| `SSC1` | `LGTESTC1` | Customer menu |
| `LGCF` | `LGICVS01` | Inquire customer (VSAM) |
| `LGPF` | `LGIPVS01` | Inquire policy (VSAM) |

## DB2 Schema Placeholders

[`DDL/db2cre.jcl`](DDL/db2cre.jcl) uses substitution placeholders that must be replaced before execution: `<DB2HLQ>`, `<DB2SSID>`, `<DB2PLAN>`, `<DB2RUN>`, `<SQLID>`, `<DB2DBID>`.

## Code Style Conventions

- **Indentation**: 1-space indent for statements; procedures use 1-space indent within the procedure body.
- **Comments**: Block comments use `/*===…===*/` borders for major sections, `/*---…---*/` for subsections.
- **Sequence numbers**: Each source line ends with an 8-digit sequence number (e.g., `00010000`). These are mainframe sequence numbers — preserve the pattern when adding lines.
- **Data names**: UPPER_CASE with underscores. DB2 host variable structures prefixed `DB2_`; working storage prefixed `WS_`; COMMAREA fields prefixed `CA_`; error message fields prefixed `EM_`.
- **Procedures**: Internal `PROCEDURE` / `END procedureName;` blocks (not `BEGIN`/`END`). Each major DB operation is its own named procedure (e.g., `INSERT_POLICY`, `INSERT_HOUSE`).
- **BMS map field names**: follow DFHBMS convention — field name + `I` (input), `O` (output), `L` (length attr), `A` (attribute byte), `F` (flag).

## Data Dictionary

The `.bobz/` directory (when present) contains `DD.json` — the semantic data dictionary for program variables. Read it alongside source files when performing analysis or planning changes.

## Generated Documentation

All documentation generated by AI assistants (program explanations, impact analyses, implementation plans, architecture docs, wiki pages, etc.) must be saved under the `docs/` folder in the workspace root. Use descriptive subdirectory names to organise output, e.g.:

```
docs/
├── impact-analysis/
├── implementation-plans/
├── program-explanations/
├── architecture/
└── wiki/
```

When tools or workflows produce output files and do not specify a path, default to `docs/<tool-output-type>/<filename>`.
