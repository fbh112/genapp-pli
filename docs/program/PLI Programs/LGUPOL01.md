## Table of Contents

- [1. Purpose](#1-purpose)
- [2. Inputs](#2-inputs)
  - [2.1 CICS Communications Area (COMMAREA) — Primary Input](#21-cics-communications-area-commarea--primary-input)
  - [2.2 CICS Execution Interface Block (EIB) — Runtime Environment Inputs](#22-cics-execution-interface-block-eib--runtime-environment-inputs)
- [3. Outputs](#3-outputs)
  - [3.1 COMMAREA Return Code (`CA_RETURN_CODE`)](#31-commarea-return-code-ca_return_code)
  - [3.2 DB2 Update via Linked Program (`LGUPDB01`)](#32-db2-update-via-linked-program-lgupdb01)
  - [3.3 Error / Diagnostic Messages Written to TDQ (via `LGSTSQ`)](#33-error--diagnostic-messages-written-to-tdq-via-lgstsq)
  - [3.4 CICS ABEND](#34-cics-abend)
- [4. Processing Logic](#4-processing-logic)
  - [4.1 Mermaid Flow Diagram](#41-mermaid-flow-diagram)
  - [4.2 Processing Logic Description](#42-processing-logic-description)
- [5. Paragraphs](#5-paragraphs)
- [6. Dependencies](#6-dependencies)
  - [6.1 CICS Infrastructure and Runtime Environment](#61-cics-infrastructure-and-runtime-environment)
  - [6.2 Invoked Programs and Modules](#62-invoked-programs-and-modules)
  - [6.3 Input Parameters and Data Structures](#63-input-parameters-and-data-structures)
- [7. Constraints](#7-constraints)
  - [7.1 COMMAREA Presence and Size Constraints](#71-commarea-presence-and-size-constraints)
  - [7.2 Request Identifier (Policy Type) Constraints](#72-request-identifier-policy-type-constraints)
  - [7.3 Processing Sequencing Constraints](#73-processing-sequencing-constraints)
  - [7.4 Null-Handling Constraints for DB2 Columns](#74-null-handling-constraints-for-db2-columns)
  - [7.5 Error Capture and Logging Constraints](#75-error-capture-and-logging-constraints)
- [8. Error Handling](#8-error-handling)
  - [8.1 COMMAREA Presence Validation](#81-commarea-presence-validation)
  - [8.2 COMMAREA Length Validation (Insufficient Data)](#82-commarea-length-validation-insufficient-data)
  - [8.3 Invalid Request Code Handling](#83-invalid-request-code-handling)
  - [8.4 SQL Null Indicator Variables](#84-sql-null-indicator-variables)
  - [8.5 Error Message Logging (WRITE_ERROR_MESSAGE Procedure)](#85-error-message-logging-write_error_message-procedure)
  - [8.6 Return Code Signalling to the Caller](#86-return-code-signalling-to-the-caller)
- [9. Examples](#9-examples)
  - [9.1 Example 1 — Successful Motor Policy Update](#91-example-1--successful-motor-policy-update)
  - [9.2 Example 2 — House Policy Update Rejected Due to Short COMMAREA](#92-example-2--house-policy-update-rejected-due-to-short-commarea)
  - [9.3 Example 3 — Unrecognised Request Code](#93-example-3--unrecognised-request-code)

## 1. Purpose

`LGUPOL01` is the business logic tier program responsible for updating existing insurance policy records within the GenApp CICS application. It receives a communications area (COMMAREA) containing a customer number, policy number, and a request code that identifies the policy type to be updated — endowment (`01UEND`), house (`01UHOU`), or motor (`01UMOT`). Before delegating any database work, the program validates the incoming request by confirming that a COMMAREA was provided (aborting with code `LGCA` if not), and then verifying that its length meets the minimum required size for the specified policy type; an insufficient length results in a return code of `98` being set back to the caller. Once input validation passes, the program forwards the full COMMAREA to the DB2 data access tier program `LGUPDB01` via a CICS LINK call to perform the actual database update. Throughout execution, any errors are timestamped using CICS time services and logged to a transient data queue via the shared utility program `LGSTSQ`, capturing the date, time, customer number, policy number, and a snapshot of the COMMAREA content for diagnostic purposes.

## 2. Inputs

### 2.1 CICS Communications Area (COMMAREA) — Primary Input

The program is invoked via `EXEC CICS LINK` and receives all its input through a single pointer parameter (`COMM_AREA_PTR`) that maps onto the shared `LGCMAREA` copybook structure. Every field below is an inbound value supplied by the calling program.

- **Request Control Fields** (`CA_REQUEST_ID`, `CA_RETURN_CODE`)
    - `CA_REQUEST_ID` — 6-byte code identifying the policy type and operation to perform; drives the main `SELECT` branching logic. Valid values are `'01UEND'` (endowment), `'01UHOU'` (house), and `'01UMOT'` (motor).
    - `CA_RETURN_CODE` — 2-digit numeric picture field; initialised to `'00'` on entry and set to `'98'` (COMMAREA too short) or `'99'` (unrecognised request ID) by the program before returning to the caller.

- **Customer Identification**
    - `CA_CUSTOMER_NUM` — 10-digit numeric customer identifier, carried in the COMMAREA header; used to identify the customer whose policy is being updated and copied into the error message for diagnostic logging.

- **Policy Identification and Common Policy Fields** (within `CA_POLICY_REQUEST`)
    - `CA_POLICY_NUM` — 10-digit numeric policy number; identifies the specific policy record to update and is copied into the error message for diagnostic logging.
    - `CA_ISSUE_DATE` — 10-byte character date representing the policy issue date, passed through to the DB2 tier for update.
    - `CA_EXPIRY_DATE` — 10-byte character date representing the policy expiry date, passed through to the DB2 tier for update.
    - `CA_LASTCHANGED` — 26-byte character timestamp of the last change to the policy, passed through to the DB2 tier for update.
    - `CA_BROKERID` — 10-digit numeric broker identifier; a nullable column, guarded by the `IND_BROKERID` indicator variable during DB2 operations.
    - `CA_BROKERSREF` — 10-byte character broker's own reference for the policy; a nullable column, guarded by the `IND_BROKERSREF` indicator variable during DB2 operations.
    - `CA_PAYMENT` — 6-digit numeric payment amount associated with the policy; a nullable column, guarded by the `IND_PAYMENT` indicator variable during DB2 operations.

- **Policy-Type-Specific Data** (mutually exclusive overlays within `CA_POLICY_SPECIFIC`)

    - **Endowment policy fields** (`CA_ENDOWMENT`) — supplied when `CA_REQUEST_ID = '01UEND'`; the full endowment block must be at least 124 bytes:
        - `CA_E_WITH_PROFITS` — single-character flag indicating with-profits participation.
        - `CA_E_EQUITIES` — single-character flag indicating equities investment.
        - `CA_E_MANAGED_FUND` — single-character flag indicating managed-fund investment.
        - `CA_E_FUND_NAME` — 10-byte name of the investment fund.
        - `CA_E_TERM` — 2-digit numeric policy term.
        - `CA_E_SUM_ASSURED` — 6-digit numeric sum assured.
        - `CA_E_LIFE_ASSURED` — 31-byte name of the life assured.
        - `CA_E_PADDING_DATA` — variable-length padding data passed to DB2 as a VARCHAR column.

    - **House policy fields** (`CA_HOUSE`) — supplied when `CA_REQUEST_ID = '01UHOU'`; the full house block must be at least 130 bytes:
        - `CA_H_PROPERTY_TYPE` — 15-byte property type description.
        - `CA_H_BEDROOMS` — 3-digit numeric bedroom count.
        - `CA_H_VALUE` — 8-digit numeric property value.
        - `CA_H_HOUSE_NAME` — 20-byte house name.
        - `CA_H_HOUSE_NUMBER` — 4-byte house number.
        - `CA_H_POSTCODE` — 8-byte postcode.

    - **Motor policy fields** (`CA_MOTOR`) — supplied when `CA_REQUEST_ID = '01UMOT'`; the full motor block must be at least 137 bytes:
        - `CA_M_MAKE` — 15-byte vehicle make.
        - `CA_M_MODEL` — 15-byte vehicle model.
        - `CA_M_VALUE` — 6-digit numeric vehicle value.
        - `CA_M_REGNUMBER` — 7-byte vehicle registration number.
        - `CA_M_COLOUR` — 8-byte vehicle colour.
        - `CA_M_CC` — 4-digit numeric engine cubic capacity.
        - `CA_M_MANUFACTURED` — 10-byte manufacture date.
        - `CA_M_PREMIUM` — 6-digit numeric premium amount.
        - `CA_M_ACCIDENTS` — 6-digit numeric accident count/history.

### 2.2 CICS Execution Interface Block (EIB) — Runtime Environment Inputs

These fields are automatically populated by CICS and are read by the program at runtime; they are not part of the COMMAREA but represent external context injected by the CICS runtime.

- `EIBCALEN` — length of the COMMAREA passed by the caller; used to validate that sufficient data has been provided before any processing begins (abend `LGCA` if zero; return code `98` if shorter than the policy-type minimum).
- `EIBTRNID` — 4-byte transaction identifier of the currently executing CICS transaction; captured into `WS_TRANSID` for diagnostic context.
- `EIBTRMID` — 4-byte terminal identifier; captured into `WS_TERMID` for diagnostic context.
- `EIBTASKN` — 7-digit task number of the current CICS task; captured into `WS_TASKNUM` for diagnostic context.

## 3. Outputs

### 3.1 COMMAREA Return Code (`CA_RETURN_CODE`)
- **`CA_RETURN_CODE`** — A 2-digit numeric picture field written back into the COMMAREA and returned to the caller via `EXEC CICS RETURN`. It is the primary status indicator of the update operation:
  - Set to `'00'` on successful initialisation, indicating processing can proceed
  - Set to `'98'` when the COMMAREA length is insufficient for the requested policy type (endowment, house, or motor), signalling a bad-length error to the caller
  - Set to `'99'` when the request ID (`CA_REQUEST_ID`) does not match any recognised policy update code, signalling an unrecognised request to the caller

### 3.2 DB2 Update via Linked Program (`LGUPDB01`)
- **`COMM_AREA_RAW`** — The full 32,500-byte raw COMMAREA is passed to the DB2-tier program `LGUPDB01` via `EXEC CICS LINK`. This is the mechanism by which the policy update is committed to the database; the result of the update (including any DB2 `CA_RETURN_CODE` written by `LGUPDB01`) is reflected back into the COMMAREA on return.

### 3.3 Error / Diagnostic Messages Written to TDQ (via `LGSTSQ`)
- **`ERROR_MSG`** — A structured error message record linked to the transient data queue writer `LGSTSQ` when an error condition is detected. Contains:
  - `EM_DATE` — formatted current date (MMDDYYYY), derived from `WS_DATE`
  - `EM_TIME` — formatted current time (8 chars), derived from `WS_TIME`
  - `EM_CUSNUM` — customer number at the time of the error, copied from `CA_CUSTOMER_NUM`
  - `EM_POLNUM` — policy number at the time of the error, copied from `CA_POLICY_NUM`
  - `EM_SQLREQ` — identifies the SQL operation in progress when the error occurred
  - `EM_SQLRC` — the DB2 SQLCODE at the time of the error
- **`CA_ERROR_MSG`** — A secondary diagnostic record also linked to `LGSTSQ`, written immediately after `ERROR_MSG`. Contains:
  - `CA_DATA` — up to 90 bytes of raw COMMAREA content at the time of the error, providing a snapshot of the input data for diagnostic purposes

### 3.4 CICS ABEND
- **`ABCODE('LGCA')`** — A CICS abend is issued (via `EXEC CICS ABEND ABCODE('LGCA') NODUMP`) when the program is invoked with no COMMAREA (`EIBCALEN = 0`). This is a terminal error output that halts task execution and signals a missing-commarea condition to the CICS environment.

## 4. Processing Logic

### 4.1 Mermaid Flow Diagram

```mermaid
graph TD
    classDef startEnd fill:#E8F0FE,stroke:#4285F4,stroke-width:2px,color:#000;
    classDef process fill:#E6F4EA,stroke:#34A853,stroke-width:1px,color:#000;
    classDef decision fill:#FEF7E0,stroke:#FBBC04,stroke-width:1px,color:#000;
    classDef errorNode fill:#FCE8E6,stroke:#EA4335,stroke-width:1px,color:#000;

    A([Start Program LGUPOL01]) :::startEnd
    B[Capture CICS Task Details<br>EIBTRNID, EIBTRMID, EIBTASKN] :::process
    C{{Is EIBCALEN Equal to 0?}} :::decision
    D[Format Timestamp and TDQ Message<br>Write Error via LGSTSQ] :::errorNode
    E[ABEND Transaction LGCA] :::errorNode
    F[Initialize Return Code to 00<br>Save Customer and Policy Number] :::process
    G{{Evaluate Request ID}} :::decision
    
    H[Calculate Required Length for Endowment<br>Header 28 + Endowment 124] :::process
    I[Calculate Required Length for House<br>Header 28 + House 130] :::process
    J[Calculate Required Length for Motor<br>Header 28 + Motor 137] :::process
    K[Set Return Code to 99<br>Unknown Request ID] :::errorNode

    L{{Is EIBCALEN Less than Required Length?}} :::decision
    M{{Is EIBCALEN Less than Required Length?}} :::decision
    N{{Is EIBCALEN Less than Required Length?}} :::decision

    O[Set Return Code to 98<br>COMMAREA Too Short] :::errorNode
    P[Link to DB2 Update Program LGUPDB01<br>Pass COMMAREA Length 32500] :::process
    Q([Return to Caller]) :::startEnd

    A --> B
    B --> C
    C -- Yes --> D
    D --> E
    C -- No --> F
    F --> G
    
    G -- 01UEND --> H
    G -- 01UHOU --> I
    G -- 01UMOT --> J
    G -- Invalid --> K

    H --> L
    L -- Yes --> O
    L -- No --> P

    I --> M
    M -- Yes --> O
    M -- No --> P

    J --> N
    N -- Yes --> O
    N -- No --> P

    K --> P
    O --> Q
    P --> Q
```

---

### 4.2 Processing Logic Description

#### 4.2.1 High-level Summary
`LGUPOL01` is a CICS PL/I business logic program responsible for orchestrating the update of insurance policy details in the General Insurance Application. It validates the incoming Communication Area (COMMAREA), identifies the specific policy type (Endowment, House, or Motor), verifies that the COMMAREA buffer meets the minimum required length for the requested policy type, and invokes the database update program (`LGUPDB01`) via `EXEC CICS LINK`.

#### 4.2.2 Execution Flow
1. **Initialization and Context Capture**:
   - The program receives the pointer to the COMMAREA and captures the CICS execution context (`EIBTRNID`, `EIBTRMID`, and `EIBTASKN`) into working storage.
2. **COMMAREA Presence Check**:
   - The program checks `EIBCALEN`. If `EIBCALEN` is equal to 0, no data was passed:
     - Formats an error record with current system date and time (`EXEC CICS ASKTIME` and `EXEC CICS FORMATTIME`).
     - Calls `WRITE_ERROR_MESSAGE`, which links to `LGSTSQ` to log the failure to a Transient Data Queue (TDQ).
     - Issues `EXEC CICS ABEND` with abend code `'LGCA'` and terminates execution without a dump.
3. **Parameter Setup**:
   - If COMMAREA is present, initializes `CA_RETURN_CODE` to `'00'`.
   - Saves `CA_CUSTOMER_NUM` and `CA_POLICY_NUM` to error message fields.
4. **Request Type Validation and Length Calculation**:
   - Evaluates `CA_REQUEST_ID` through a `SELECT` construct:
     - **`01UEND` (Endowment Policy Update)**: Adds header length (28 bytes) and endowment length (124 bytes) to calculate a required COMMAREA size of 152 bytes. If `EIBCALEN` is less than 152 bytes, sets `CA_RETURN_CODE` to `'98'` and immediately issues `EXEC CICS RETURN`.
     - **`01UHOU` (House Policy Update)**: Adds header length (28 bytes) and house length (130 bytes) to calculate a required COMMAREA size of 158 bytes. If `EIBCALEN` is less than 158 bytes, sets `CA_RETURN_CODE` to `'98'` and immediately issues `EXEC CICS RETURN`.
     - **`01UMOT` (Motor Policy Update)**: Adds header length (28 bytes) and motor length (137 bytes) to calculate a required COMMAREA size of 165 bytes. If `EIBCALEN` is less than 165 bytes, sets `CA_RETURN_CODE` to `'98'` and immediately issues `EXEC CICS RETURN`.
     - **OTHERWISE (Invalid/Unsupported Request)**: Sets `CA_RETURN_CODE` to `'99'`.
5. **Database Update Dispatch**:
   - Invokes `LGUPDB01` via `EXEC CICS LINK` passing the raw COMMAREA (`COMM_AREA_RAW`) with a fixed length of 32500 bytes to perform the database persistence operations.
6. **Program Termination**:
   - Returns control back to the caller using `EXEC CICS RETURN`.

#### 4.2.3 External Interactions
- **`LGUPDB01` (Program Link)**: Subordinate CICS program called via `EXEC CICS LINK` with the 32,500-byte COMMAREA to execute the DB2 SQL update statements against the relevant policy database tables.
- **`LGSTSQ` (Error Logging Program)**: Subordinate CICS logging utility called via `EXEC CICS LINK` when errors occur, recording structured error messages and COMMAREA snapshots into CICS Transient Data Queues (TDQs).

#### 4.2.4 Plain Language Summary
When a user or client application requests an update to an existing insurance policy, `LGUPOL01` acts as a gatekeeper. It first checks that valid request data has been supplied. Next, it examines whether the request is for an Endowment, House, or Motor insurance policy and verifies that the provided data buffer contains enough bytes to hold that policy type's information. If the request is invalid or incomplete, it sets an error code and exits or logs the error. If the validation passes, it forwards the request to the database update module (`LGUPDB01`) to save the updated policy information into the database.

## 5. Paragraphs

- **LGUPOL01 (Main Procedure / Mainline)**
  - Entry point of the program, declared as `LGUPOL01: Proc(COMM_AREA_PTR) Options(Main)`.
  - Contains all working storage declarations: diagnostic header fields (`WS_HEADER`), date/time fields (`WS_ABSTIME`, `WS_DATE`, `WS_TIME`), policy length constants (`WS_POLICY_LENGTHS`), COMMAREA length accumulators (`WS_COMMAREA_LENGTHS`), the `ERROR_MSG` and `CA_ERROR_MSG` error structures, the varying-length field `WS_VARY_FIELD`, the target DB2 program name `LGUPDB1`, and the null indicator variables (`IND_BROKERID`, `IND_BROKERSREF`, `IND_PAYMENT`).
  - On entry, captures the current CICS transaction ID, terminal ID, and task number into `WS_HEADER` fields from the EIB.
  - **COMMAREA presence check**: If `EIBCALEN = 0`, sets `EM_MSG_TEXT` to a "NO COMMAREA RECEIVED" message, calls `WRITE_ERROR_MESSAGE`, then issues `EXEC CICS ABEND ABCODE('LGCA') NODUMP` to terminate abnormally.
  - Initialises `CA_RETURN_CODE` to `'00'`, saves `EIBCALEN` in `WS_CALEN`, and sets `WS_ADDR_DFHCOMMAREA` to the received pointer.
  - Pre-populates `EM_CUSNUM` and `EM_POLNUM` from `CA_CUSTOMER_NUM` and `CA_POLICY_NUM` for use in any subsequent error messages.
  - **Policy-type dispatch and COMMAREA length validation**: Uses a `SELECT (CA_REQUEST_ID)` construct (equivalent to a CASE statement) with three branches:
    - `'01UEND'` (endowment): accumulates `WS_CA_HEADER_LEN` + `WS_FULL_ENDOW_LEN` (28 + 124 = 152) into `WS_REQUIRED_CA_LEN`; if `EIBCALEN < WS_REQUIRED_CA_LEN`, sets `CA_RETURN_CODE = '98'` and returns immediately to the caller via `EXEC CICS RETURN`.
    - `'01UHOU'` (house): accumulates `WS_CA_HEADER_LEN` + `WS_FULL_HOUSE_LEN` (28 + 130 = 158); same short-circuit return on insufficient length.
    - `'01UMOT'` (motor): accumulates `WS_CA_HEADER_LEN` + `WS_FULL_MOTOR_LEN` (28 + 137 = 165); same short-circuit return on insufficient length.
    - `OTHERWISE`: sets `CA_RETURN_CODE = '99'` to signal an unrecognised request code; no return is issued here, allowing fall-through to the DB2 call (which the DB2 program is expected to handle gracefully).
  - After the `SELECT`, calls the internal procedure `UPDATE_POLICY_DB2_INFO`.
  - Issues a final `EXEC CICS RETURN` to hand control back to CICS.

- **UPDATE_POLICY_DB2_INFO**
  - A short internal procedure that delegates policy update processing to the DB2-tier program.
  - Issues `EXEC CICS LINK Program('LGUPDB01') Commarea(COMM_AREA_RAW) LENGTH(32500)` to synchronously invoke the DB2 update program `LGUPDB01`, passing the full raw COMMAREA.
  - No conditional logic is contained within this procedure; all branch decisions have been made in the mainline prior to the call.
  - Interacts with the external CICS program `LGUPDB01` (the DB2 data access tier), which performs the actual SQL update against the insurance policy tables.

- **WRITE_ERROR_MESSAGE**
  - A reusable internal procedure responsible for formatting and writing diagnostic error messages to the CICS transient data queue via the utility program `LGSTSQ`.
  - Obtains the current absolute time with `EXEC CICS ASKTIME ABSTIME(WS_ABSTIME)`, then formats it into `WS_DATE` (MMDDYYYY) and `WS_TIME` using `EXEC CICS FORMATTIME`, copying those values into `EM_DATE` and `EM_TIME` in the `ERROR_MSG` structure.
  - Issues a first `EXEC CICS LINK PROGRAM('LGSTSQ') COMMAREA(ERROR_MSG)` to write the primary error message (containing date, time, program name, customer number, policy number, and SQLCODE) to the transient data queue.
  - Contains conditional logic to write a COMMAREA dump:
    - If `EIBCALEN > 0` and `EIBCALEN < 91`: copies `EIBCALEN` bytes of `COMM_AREA_RAW` into `CA_DATA` using the `LEFT` built-in, then links `LGSTSQ` with `CA_ERROR_MSG` to write the partial COMMAREA.
    - If `EIBCALEN >= 91`: copies the first 90 bytes of `COMM_AREA_RAW` into `CA_DATA` and similarly links `LGSTSQ`.
    - If `EIBCALEN = 0`, no COMMAREA dump is written.
  - Interacts with the external CICS program `LGSTSQ` (transient data queue writer utility) up to twice per invocation — once for the error message and once for the COMMAREA snapshot.

## 6. Dependencies

### 6.1 CICS Infrastructure and Runtime Environment
- **CICS Transaction Server**: Provides the execution environment, transaction context, and API runtime services.
  - **`EXEC CICS LINK`**: Used to invoke external programs synchronously, passing control and data via communications areas.
  - **`EXEC CICS RETURN`**: Used to terminate program execution and return control to the CICS runtime or invoking program.
  - **`EXEC CICS ABEND`**: Used to abnormally terminate the task with abend code `LGCA` when required input data is missing (`EIBCALEN = 0`).
  - **`EXEC CICS ASKTIME` & `EXEC CICS FORMATTIME`**: Used to retrieve system absolute time and format it into human-readable date (`MMDDYYYY`) and time strings for error diagnostics.
  - **Execute Interface Block (EIB)**: Provides runtime execution context and parameters:
    - **`EIBCALEN`**: Length of the passed communications area; evaluated to validate message integrity against required minimum lengths.
    - **`EIBTRNID`**: Current CICS transaction identifier.
    - **`EIBTRMID`**: CICS terminal identifier.
    - **`EIBTASKN`**: CICS task number.

### 6.2 Invoked Programs and Modules
- **`LGUPDB01`**: DB2-tier policy update program. Invoked via `EXEC CICS LINK` passing `COMM_AREA_RAW` (32,500 bytes) to perform database updates across the supported policy types (Endowment, House, Motor).
- **`LGSTSQ`**: Common error logging and transient data queue service. Invoked via `EXEC CICS LINK` during error conditions to log structured error details (`ERROR_MSG`) and raw communications area payloads (`CA_ERROR_MSG`).

### 6.3 Input Parameters and Data Structures
- **`COMM_AREA` / `COMM_AREA_PTR`**: Universal 32,500-byte communications area passed as the main entry parameter, representing the request and response interface between the caller and the program:
  - **`CA_REQUEST_ID`**: Operation code indicating the specific policy update requested (`01UEND` for Endowment, `01UHOU` for House, `01UMOT` for Motor).
  - **`CA_CUSTOMER_NUM`**: 10-digit customer identifier associated with the policy update.
  - **`CA_POLICY_NUM`**: 10-digit policy identifier to be updated.
  - **`CA_RETURN_CODE`**: 2-digit status code returned to the caller (`00` for success, `98` for insufficient length, `99` for invalid request ID).
  - **`COMM_AREA_RAW`**: 32,500-byte character view of the commarea forwarded to `LGUPDB01`.
- **`LGCMAREA` Copybook (`LGCMAREA.inc`)**: Defines the shared layout, unions, and structures for the application-wide `COMM_AREA` used across the business logic tier.

## 7. Constraints

### 7.1 COMMAREA Presence and Size Constraints

- **COMMAREA must be present at entry**
  - Enforced by checking `EIBCALEN = 0` immediately on program entry
  - If no COMMAREA is passed, the error message `' NO COMMAREA RECEIVED'` is written to the transient data queue via `WRITE_ERROR_MESSAGE`, and the program issues `EXEC CICS ABEND ABCODE('LGCA') NODUMP` — a hard abend with no dump
  - This is a mandatory prerequisite; no processing of any kind takes place without a COMMAREA

- **COMMAREA must meet a minimum length for the requested policy type**
  - The minimum is computed at runtime as `WS_CA_HEADER_LEN` (fixed at 28 bytes) plus the full policy-type-specific length
    - For endowment (`'01UEND'`): minimum = 28 + 124 = **152 bytes** (`WS_FULL_ENDOW_LEN = 124`)
    - For house (`'01UHOU'`): minimum = 28 + 130 = **158 bytes** (`WS_FULL_HOUSE_LEN = 130`)
    - For motor (`'01UMOT'`): minimum = 28 + 137 = **165 bytes** (`WS_FULL_MOTOR_LEN = 137`)
  - If `EIBCALEN < WS_REQUIRED_CA_LEN`, `CA_RETURN_CODE` is set to `'98'` and `EXEC CICS RETURN` is issued immediately — no DB2 update is attempted
  - The maximum COMMAREA passable to the downstream DB2 program is hard-coded at **32,500 bytes** (the `LENGTH(32500)` parameter on `EXEC CICS LINK Program('LGUPDB01')`)

---

### 7.2 Request Identifier (Policy Type) Constraints

- **`CA_REQUEST_ID` must be one of three recognised values**
  - The `SELECT (CA_REQUEST_ID)` statement accepts only `'01UEND'`, `'01UHOU'`, or `'01UMOT'`
  - Any other value falls into the `OTHERWISE` branch, which sets `CA_RETURN_CODE = '99'` — indicating an invalid request — and implicitly bypasses the DB2 update call (`CALL UPDATE_POLICY_DB2_INFO` is still issued unconditionally after the SELECT, meaning even a `'99'` code proceeds to DB2; the DB2 tier is responsible for honouring that code)
  - The three supported request codes map exactly to the three supported policy types: Endowment, House, and Motor

---

### 7.3 Processing Sequencing Constraints

- **COMMAREA validation must complete before the DB2 update is invoked**
  - The `SELECT (CA_REQUEST_ID)` block — which validates the request code and COMMAREA length — is always executed before `CALL UPDATE_POLICY_DB2_INFO`
  - If a length violation (`'98'`) is detected, `EXEC CICS RETURN` exits the program entirely, preventing the DB2 call
  - If no COMMAREA is present, the abend prevents any further processing

- **Error logging must obtain current time before writing**
  - Within `WRITE_ERROR_MESSAGE`, `EXEC CICS ASKTIME` must execute before `EXEC CICS FORMATTIME`, which in turn must populate `WS_DATE`/`WS_TIME` before they are copied into `ERROR_MSG`
  - This sequential dependency is enforced by the linear code order inside the procedure

- **COMMAREA snapshot is written only after the primary error message**
  - The `EXEC CICS LINK PROGRAM('LGSTSQ')` call for the main `ERROR_MSG` structure always precedes the conditional call that writes `CA_ERROR_MSG` (the raw COMMAREA dump)
  - The COMMAREA dump is only written if `EIBCALEN > 0`, preserving log coherence

---

### 7.4 Null-Handling Constraints for DB2 Columns

- **Nullable DB2 columns must have indicator variables declared**
  - Three indicator variables are declared: `IND_BROKERID`, `IND_BROKERSREF`, and `IND_PAYMENT`, each `FIXED BIN(15)`
  - Without these indicators, any SQL FETCH returning a null value for these columns would cause an SQLCODE failure
  - Their presence is a mandatory constraint on how these columns may be fetched or updated — the program will not tolerate unhandled nulls from the database

---

### 7.5 Error Capture and Logging Constraints

- **COMMAREA snapshot is capped at 90 bytes**
  - If `EIBCALEN < 91`, exactly `EIBCALEN` bytes of the COMMAREA are captured into `CA_DATA` (90-byte field)
  - If `EIBCALEN >= 91`, the first 90 bytes are captured — enforced by the conditional `IF ( EIBCALEN < 91 )` inside `WRITE_ERROR_MESSAGE`
  - This prevents overflow of the fixed 90-byte `CA_DATA` field within `CA_ERROR_MSG`

- **`CA_RETURN_CODE` must be initialised before use**
  - It is set to `'00'` immediately after the zero-length COMMAREA check and before any conditional processing, ensuring that a defined value is always present in the COMMAREA when control returns to the caller

## 8. Error Handling

### 8.1 COMMAREA Presence Validation

- On every invocation, the program checks whether `EIBCALEN` equals zero, indicating that no COMMAREA was passed by the caller
  - If no COMMAREA is present, an error message is prepared in the `ERROR_MSG` structure with the text `NO COMMAREA RECEIVED` and `WRITE_ERROR_MESSAGE` is invoked to log the condition
  - After logging, `EXEC CICS ABEND` is issued with abend code `LGCA` and `NODUMP` to terminate the transaction abnormally in a controlled manner without producing a transaction dump

### 8.2 COMMAREA Length Validation (Insufficient Data)

- After confirming the COMMAREA exists, the program determines the minimum required length based on the specific policy type requested (`CA_REQUEST_ID`)
  - For each recognised request code (`01UEND`, `01UHOU`, `01UMOT`), `WS_REQUIRED_CA_LEN` is calculated by summing the fixed header length (`WS_CA_HEADER_LEN`, 28 bytes) with the full policy-type-specific data length (`WS_FULL_ENDOW_LEN` = 124, `WS_FULL_HOUSE_LEN` = 130, or `WS_FULL_MOTOR_LEN` = 137 respectively)
  - `EIBCALEN` is then compared against `WS_REQUIRED_CA_LEN`; if the actual COMMAREA is shorter than required, `CA_RETURN_CODE` is set to `'98'` and `EXEC CICS RETURN` is issued immediately, signalling an input data error to the caller without further processing

### 8.3 Invalid Request Code Handling

- The `SELECT (CA_REQUEST_ID)` construct includes an `OTHERWISE` branch that handles any request code not matching the three known values (`01UEND`, `01UHOU`, `01UMOT`)
  - In this case `CA_RETURN_CODE` is set to `'99'`, indicating an unrecognised or invalid request type and allowing the caller to detect and respond to the error condition

### 8.4 SQL Null Indicator Variables

- Three null indicator variables — `IND_BROKERID`, `IND_BROKERSREF`, and `IND_PAYMENT` — are declared as `FIXED BIN(15)` to accompany SQL FETCH operations for columns that may legitimately contain null values in the database
  - Without these indicators, a null value returned by DB2 for any of these columns would cause an `SQLCODE` failure; their presence acts as a passive defensive mechanism to prevent unexpected SQL errors during policy data retrieval or update

### 8.5 Error Message Logging (WRITE_ERROR_MESSAGE Procedure)

- A dedicated internal procedure `WRITE_ERROR_MESSAGE` centralises all error notification and logging activity
  - `EXEC CICS ASKTIME` and `EXEC CICS FORMATTIME` are called to obtain and format the current date (`WS_DATE`) and time (`WS_TIME`), which are stamped into the `ERROR_MSG` structure to provide temporal context for the error
  - The formatted `ERROR_MSG` (containing date, time, program name, customer number, policy number, and SQLCODE fields) is written to the transient data queue by linking to the utility program `LGSTSQ` via `EXEC CICS LINK`
  - A second pass writes up to 90 bytes of raw COMMAREA content to the same queue via `CA_ERROR_MSG`:
    - If `EIBCALEN` is between 1 and 90, the exact number of COMMAREA bytes is captured in `CA_DATA` and written
    - If `EIBCALEN` exceeds 90, only the first 90 bytes are captured and written, preventing buffer overrun while still preserving the most relevant diagnostic data
  - Customer number (`CA_CUSTOMER_NUM`) and policy number (`CA_POLICY_NUM`) are proactively copied into `EM_CUSNUM` and `EM_POLNUM` at the start of processing so that they are available in the error message regardless of how early in execution an error occurs

### 8.6 Return Code Signalling to the Caller

- `CA_RETURN_CODE` is initialised to `'00'` at the start of processing to indicate a clean state
  - It is set to `'98'` when the COMMAREA is present but too short for the requested policy type, signalling a data-length error
  - It is set to `'99'` when the request code is unrecognised, signalling an invalid request type
  - These return codes are passed back through the COMMAREA to the calling program, which is responsible for interpreting and acting on them

## 9. Examples

### 9.1 Example 1 — Successful Motor Policy Update

**Input COMMAREA**

| Field | Value |
|---|---|
| `CA_REQUEST_ID` | `01UMOT` |
| `CA_CUSTOMER_NUM` | `0000000042` |
| `CA_POLICY_NUM` | `0000000007` |
| COMMAREA total length | `165` bytes (≥ 28 header + 137 motor = 165) |
| Motor policy fields | Vehicle registration, make, model, premium, etc. (137 bytes) |

**Expected Output**

- `CA_RETURN_CODE` is set to `'00'` (success).
- Program links to `LGUPDB01` (DB2 tier) via `EXEC CICS LINK`, passing the full 32 500-byte COMMAREA.
- `LGUPDB01` performs the actual DB2 UPDATE; control returns to LGUPOL01, which then issues `EXEC CICS RETURN` to the caller.

**How the input leads to the output**

1. `EIBCALEN` is non-zero, so the ABEND path (`LGCA`) is skipped.
2. `CA_RETURN_CODE` is initialised to `'00'`.
3. The `SELECT` on `CA_REQUEST_ID = '01UMOT'` computes `WS_REQUIRED_CA_LEN = 28 + 137 = 165`. Because `EIBCALEN (165) >= 165`, the short-COMMAREA path (`CA_RETURN_CODE = '98'`) is not taken.
4. `UPDATE_POLICY_DB2_INFO` is called, which links to `LGUPDB01` to persist the motor policy changes.

---

### 9.2 Example 2 — House Policy Update Rejected Due to Short COMMAREA

**Input COMMAREA**

| Field | Value |
|---|---|
| `CA_REQUEST_ID` | `01UHOU` |
| `CA_CUSTOMER_NUM` | `0000000015` |
| `CA_POLICY_NUM` | `0000000003` |
| COMMAREA total length | `100` bytes (< 28 header + 130 house = 158 required) |

**Expected Output**

- `CA_RETURN_CODE` is set to `'98'`.
- `EXEC CICS RETURN` is issued immediately; `LGUPDB01` is **never** called.
- No DB2 update occurs; the caller receives the `'98'` error code indicating an insufficiently sized COMMAREA.

**How the input leads to the output**

1. `EIBCALEN = 100`, which is non-zero, so no abend.
2. `CA_RETURN_CODE` initialised to `'00'`.
3. `SELECT` matches `'01UHOU'`; `WS_REQUIRED_CA_LEN = 28 + 130 = 158`.
4. `EIBCALEN (100) < 158` is true, so `CA_RETURN_CODE = '98'` and the program returns immediately without calling the DB2 tier.

---

### 9.3 Example 3 — Unrecognised Request Code

**Input COMMAREA**

| Field | Value |
|---|---|
| `CA_REQUEST_ID` | `01UXXX` (unknown code) |
| `CA_CUSTOMER_NUM` | `0000000099` |
| `CA_POLICY_NUM` | `0000000001` |
| COMMAREA total length | `200` bytes |

**Expected Output**

- `CA_RETURN_CODE` is set to `'99'`.
- Despite the error code being set, the `OTHERWISE` branch falls through and `UPDATE_POLICY_DB2_INFO` **is still called** (the `CALL` is unconditional after the `SELECT`).
- `LGUPDB01` will receive the COMMAREA with the unrecognised request code and is expected to handle or reject it at the DB2 tier.

**How the input leads to the output**

1. `EIBCALEN > 0`, no abend.
2. The `SELECT` exhausts all `WHEN` clauses (`01UEND`, `01UHOU`, `01UMOT`) without a match and falls into `OTHERWISE`, setting `CA_RETURN_CODE = '99'`.
3. Execution continues past the `SELECT` and unconditionally calls `UPDATE_POLICY_DB2_INFO`, delegating further handling to `LGUPDB01`.

---

Generated by IBM Bob Premium Package for Z
