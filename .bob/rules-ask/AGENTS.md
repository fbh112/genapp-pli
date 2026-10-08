<<<<<<< Updated upstream
# Project Documentation Context (Non-Obvious Only)

- **CSD file lists programs as `LANGUAGE(COBOL)`** even though all source files in `PLI Programs/` are PL/I — this is a known export artifact from the original COBOL version of GenApp. The runtime language is PL/I.
- **`Includes/SSMAP.inc` does not exist as a file** — the BMS symbolic map is generated at assembly time from `Maps/SSMAP.bms`. Programs reference it with `%INCLUDE SSMAP;` expecting the generated copy to be on the compiler include path.
- **`DDL/db2cre.jcl` is not runnable as-is** — six `<placeholder>` tokens must be substituted for the actual DB2 subsystem, plan, and qualifier values before submission.
- **Three-tier architecture is implicit in naming**: The `OL`/`DB`/`VS` suffix in program names encodes the tier. There is no explicit configuration — the calling chain is hard-coded via `EXEC CICS LINK Program('...')` literals.
- **`Resources/GenApp.CSD`** is an alternate/older CSD export; `DFHCSDUP.csd` is the canonical one used for CICS install.
- **`LGSTSQ`** (error logging utility) and `LGSETUP` (TSQ initialisation) are referenced throughout but their source is not in this repo — they are COBOL programs from the parent GenApp project.
=======
# AGENTS.md - Ask Mode Guidance

- **Architecture Layout**:
  - `PLI Programs/`: CICS PL/I source modules split across operations (Add, Delete, Inquire, Update).
  - `Includes/`: Copybooks (`.inc`) for COMMAREA definitions (`LGCMAREA`), Db2 host variables (`LGPOLICY`), and BMS map structures (`SSMAP.inc`).
  - `DDL/`: JCL job (`db2cre.jcl`) defining Db2 tablespaces and databases.
  - `Maps/`: BMS map definition (`SSMAP.bms`).
  - `Resources/`: CICS CSD definitions (`GenApp.CSD`, `DFHCSDUP.csd`).
- **Data Flow**: Caller invokes `LGxPOL01` -> validates `EIBCALEN` -> Links to `LGxPDB01` (Db2) or `LGxPVS01` (VSAM) with 32KB COMMAREA -> applies business logic overrides -> returns to caller.
>>>>>>> Stashed changes
