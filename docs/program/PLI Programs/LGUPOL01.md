## Table of Contents

- [1. Purpose](#1-purpose)
- [2. Inputs](#2-inputs)
<<<<<<< Updated upstream
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
=======
  - [2.1 CICS Communication Area (COMMAREA)](#21-cics-communication-area-commarea)
  - [2.2 CICS Execute Interface Block (EIB)](#22-cics-execute-interface-block-eib)
  - [2.3 Linked Sub-programs](#23-linked-sub-programs)
- [3. Outputs](#3-outputs)
  - [3.1 CICS Communication Area Outputs](#31-cics-communication-area-outputs)
  - [3.2 Diagnostic and Error Logging Outputs](#32-diagnostic-and-error-logging-outputs)
  - [3.3 CICS System Side Effects](#33-cics-system-side-effects)
- [4. Processing Logic](#4-processing-logic)
  - [4.1 Mermaid Flow Diagram](#41-mermaid-flow-diagram)
  - [4.2 Processing Logic Description](#42-processing-logic-description)
  - [4.3 Database Tables](#43-database-tables)
- [5. Paragraphs](#5-paragraphs)
- [6. Dependencies](#6-dependencies)
  - [6.1 CICS System Services and Control Blocks](#61-cics-system-services-and-control-blocks)
  - [6.2 External Program Interfaces](#62-external-program-interfaces)
  - [6.3 Data Structures and Input Interfaces](#63-data-structures-and-input-interfaces)
- [7. Constraints](#7-constraints)
  - [7.1 Communication Area Presence](#71-communication-area-presence)
  - [7.2 Communication Area Length (Size Minimums by Policy Type)](#72-communication-area-length-size-minimums-by-policy-type)
  - [7.3 Request Identifier Validity](#73-request-identifier-validity)
  - [7.4 Processing Sequence (Ordering Constraint)](#74-processing-sequence-ordering-constraint)
  - [7.5 DB2 Sub-program Linkage](#75-db2-sub-program-linkage)
  - [7.6 Nullable DB2 Column Handling](#76-nullable-db2-column-handling)
  - [7.7 Error Message Content Limits](#77-error-message-content-limits)
  - [7.8 Return Code Communication](#78-return-code-communication)
- [8. Error Handling](#8-error-handling)
  - [8.1 Missing or Zero-Length Communication Area](#81-missing-or-zero-length-communication-area)
  - [8.2 Communication Area Length Validation by Policy Type](#82-communication-area-length-validation-by-policy-type)
  - [8.3 Error Message Logging Infrastructure (`WRITE_ERROR_MESSAGE`)](#83-error-message-logging-infrastructure-write_error_message)
  - [8.4 SQL Null Indicator Variables](#84-sql-null-indicator-variables)
- [9. Examples](#9-examples)
  - [9.1 Example 1: Update a Motor Insurance Policy (Happy Path)](#91-example-1-update-a-motor-insurance-policy-happy-path)
  - [9.2 Example 2: Update a House Insurance Policy — Communication Area Too Short (Validation Failure)](#92-example-2-update-a-house-insurance-policy--communication-area-too-short-validation-failure)
  - [9.3 Example 3: Unknown Policy Type (Invalid Request ID)](#93-example-3-unknown-policy-type-invalid-request-id)
  - [9.4 Example 4: No Communication Area Passed (ABEND Path)](#94-example-4-no-communication-area-passed-abend-path)

## 1. Purpose

The primary purpose of `LGUPOL01` is to serve as the CICS business logic controller for updating existing insurance policies across endowment, house, and motor categories within the General Insurance Application (GenApp). It receives policy update requests via the CICS communication area, verifies that the incoming request contains an appropriate request identifier (`01UEND`, `01UHOU`, or `01UMOT`), and validates that sufficient communication area length is supplied for the specific policy type. Upon successful request validation, the program delegates the data persistence and database update operations to the backend data access program (`LGUPDB01`), returning standard status codes and diagnostic information back to the calling client or interface.

## 2. Inputs

### 2.1 CICS Communication Area (COMMAREA)

The primary input to `LGUPOL01` is the CICS communication area, passed via the `COMM_AREA_PTR` parameter at program entry and accessed through the `COMM_AREA_RAW` based structure. It provides all policy update request data.

- **`COMM_AREA_PTR`** — Procedure parameter (pointer); the entry-point argument that delivers the address of the CICS communication area to the program. All communication area fields are accessed through this pointer.
  - **`CA_REQUEST_ID`** — Identifies the type of policy update being requested (`01UEND` = endowment, `01UHOU` = house, `01UMOT` = motor). Drives the main processing branch.
  - **`CA_RETURN_CODE`** — Initialised to `'00'` on entry; set to `'98'` (insufficient COMMAREA length) or `'99'` (unrecognised request type) on error, and returned to the caller.
  - **`CA_CUSTOMER_NUM`** — Customer number supplied by the caller; copied into the error message structure for diagnostic logging.
  - **`CA_POLICY_NUM`** — Policy number supplied by the caller; copied into the error message structure for diagnostic logging.
  - **`COMM_AREA_RAW`** — The raw byte content of the communication area, forwarded in full (up to 32,500 bytes) to the linked sub-program `LGUPDB01` for database update, and also captured (up to 90 bytes) in error messages written to the transient data queue.

### 2.2 CICS Execute Interface Block (EIB)

Runtime control fields provided automatically by CICS at task initialisation.

- **`EIBCALEN`** — The actual byte length of the passed communication area. Used to detect a missing COMMAREA (`= 0` triggers an ABEND) and to validate that sufficient data was passed for the requested policy type.
- **`EIBTRNID`** — The CICS transaction identifier of the running task; captured into `WS_TRANSID` for diagnostic purposes.
- **`EIBTRMID`** — The CICS terminal identifier; captured into `WS_TERMID` for diagnostic purposes.
- **`EIBTASKN`** — The CICS task number; captured into `WS_TASKNUM` for diagnostic purposes.

### 2.3 Linked Sub-programs

External programs invoked via `EXEC CICS LINK`; their responses constitute data fed back into the processing flow.

- **`LGUPDB01`** — The database update sub-program linked to via `UPDATE_POLICY_DB2_INFO`. Receives the full communication area (`COMM_AREA_RAW`) and performs the actual DB2 policy record update. Return results are reflected back through the shared communication area.
- **`LGSTSQ`** — A transient data queue writer utility linked to within `WRITE_ERROR_MESSAGE`. Receives the formatted error message (`ERROR_MSG`) and the raw communication area excerpt (`CA_ERROR_MSG`) for writing to the TDQ.

## 3. Outputs

### 3.1 CICS Communication Area Outputs
- `CA_RETURN_CODE`
  - Returns a two-digit numeric status code to the calling CICS program indicating the outcome of the policy update request:
    - `'00'`: Successfully validated and forwarded for database update.
    - `'98'`: Communication area length is shorter than the minimum length required for the specified policy type.
    - `'99'`: Unrecognised or unsupported `CA_REQUEST_ID`.
- `COMM_AREA_RAW`
  - Passes the entire 32,500-byte communication area payload to the downstream database update module `LGUPDB01` via `EXEC CICS LINK`, containing the policy and customer information to be updated in Db2.

### 3.2 Diagnostic and Error Logging Outputs
- `ERROR_MSG`
  - Formatted error message structure passed to the logging program `LGSTSQ` via `EXEC CICS LINK` when an error occurs (such as missing communication area on entry).
  - `EM_DATE`: Formatted calendar date (`MMDDYYYY`) derived from the CICS timestamp.
  - `EM_TIME`: Formatted time of day derived from the CICS timestamp.
  - `EM_MSG_TEXT`: Specific textual description of the encountered error (e.g., `' NO COMMAREA RECEIVED'`).
  - `EM_CUSNUM`: Customer number extracted from the communication area for tracing.
  - `EM_POLNUM`: Policy number extracted from the communication area for tracing.
  - `EM_SQLREQ`: Name of the SQL operation in context during an error condition.
  - `EM_SQLRC`: Numeric SQL return code associated with a database error.
- `CA_ERROR_MSG`
  - Diagnostic error structure passed to `LGSTSQ` via `EXEC CICS LINK` containing raw input payload details.
  - `CA_DATA`: Raw communication area data (up to 90 bytes) captured at the time of failure to aid troubleshooting.

### 3.3 CICS System Side Effects
- `EXEC CICS ABEND` (`ABCODE('LGCA')`, `NODUMP`)
  - Terminates the transaction abnormally with abend code `LGCA` when invoked without a valid communication area (`EIBCALEN = 0`).
- `EXEC CICS RETURN`
  - Terminates program execution and returns control back to CICS or the calling program after completing validation or processing.
>>>>>>> Stashed changes

## 4. Processing Logic

### 4.1 Mermaid Flow Diagram

```mermaid
graph TD
<<<<<<< Updated upstream
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
=======
    classDef startEnd fill:#b5ead7,stroke:#6abd96,color:#000
    classDef process fill:#c7ceea,stroke:#7e8dc9,color:#000
    classDef decision fill:#ffdac1,stroke:#f4a261,color:#000
    classDef error fill:#ffb7b2,stroke:#e07070,color:#000
    classDef sub fill:#e2f0cb,stroke:#86c16b,color:#000

    A([Program Start<br>LGUPOL01]):::startEnd
    B[Capture EIBTRNID<br>EIBTRMID<br>EIBTASKN into WS_HEADER]:::process
    C{{EIBCALEN = 0}}:::decision
    D[Set EM_MSG_TEXT<br>to NO COMMAREA RECEIVED<br>Call WRITE_ERROR_MESSAGE]:::error
    E[EXEC CICS ABEND<br>ABCODE LGCA NODUMP]:::error
    F[Set CA_RETURN_CODE = 00<br>Save EIBCALEN to WS_CALEN<br>Save comm area pointer]:::process
    G[Save CA_CUSTOMER_NUM and<br>CA_POLICY_NUM to error msg fields]:::process
    H{{Check CA_REQUEST_ID}}:::decision
    I[Calculate WS_REQUIRED_CA_LEN<br>= Header 28 plus Endow 124]:::process
    J{{EIBCALEN less than<br>WS_REQUIRED_CA_LEN}}:::decision
    K[Set CA_RETURN_CODE = 98<br>EXEC CICS RETURN]:::error
    L[Calculate WS_REQUIRED_CA_LEN<br>= Header 28 plus House 130]:::process
    M{{EIBCALEN less than<br>WS_REQUIRED_CA_LEN}}:::decision
    N[Set CA_RETURN_CODE = 98<br>EXEC CICS RETURN]:::error
    O[Calculate WS_REQUIRED_CA_LEN<br>= Header 28 plus Motor 137]:::process
    P{{EIBCALEN less than<br>WS_REQUIRED_CA_LEN}}:::decision
    Q[Set CA_RETURN_CODE = 98<br>EXEC CICS RETURN]:::error
    R[Set CA_RETURN_CODE = 99<br>Unknown request type]:::error
    S[Call UPDATE_POLICY_DB2_INFO]:::sub
    T[EXEC CICS LINK Program LGUPDB01<br>COMMAREA COMM_AREA_RAW<br>LENGTH 32500]:::process
    U[EXEC CICS RETURN to caller]:::startEnd
    V([Program End]):::startEnd

    WEM[WRITE_ERROR_MESSAGE]:::sub
    WEM1[EXEC CICS ASKTIME<br>EXEC CICS FORMATTIME]:::process
    WEM2[Set EM_DATE and EM_TIME]:::process
    WEM3[EXEC CICS LINK LGSTSQ<br>Write ERROR_MSG to TDQ]:::process
    WEM4{{EIBCALEN greater than 0}}:::decision
    WEM5{{EIBCALEN less than 91}}:::decision
    WEM6[Copy first EIBCALEN bytes<br>of COMMAREA to CA_DATA<br>Link LGSTSQ]:::process
    WEM7[Copy first 90 bytes<br>of COMMAREA to CA_DATA<br>Link LGSTSQ]:::process
    WEM8[Return from WRITE_ERROR_MESSAGE]:::startEnd
>>>>>>> Stashed changes

    A --> B
    B --> C
    C -- Yes --> D
    D --> E
    C -- No --> F
    F --> G
<<<<<<< Updated upstream
    
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
=======
    G --> H
    H -- 01UEND --> I
    H -- 01UHOU --> L
    H -- 01UMOT --> O
    H -- Otherwise --> R
    I --> J
    J -- Yes --> K
    J -- No --> S
    L --> M
    M -- Yes --> N
    M -- No --> S
    O --> P
    P -- Yes --> Q
    P -- No --> S
    R --> S
    S --> T
    T --> U
    U --> V

    WEM --> WEM1
    WEM1 --> WEM2
    WEM2 --> WEM3
    WEM3 --> WEM4
    WEM4 -- Yes --> WEM5
    WEM4 -- No --> WEM8
    WEM5 -- Yes --> WEM6
    WEM5 -- No --> WEM7
    WEM6 --> WEM8
    WEM7 --> WEM8
>>>>>>> Stashed changes
```

---

### 4.2 Processing Logic Description

#### 4.2.1 High-level Summary
<<<<<<< Updated upstream
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
=======

`LGUPOL01` is the **business logic / presentation layer** program for updating an existing insurance policy in the GenApp CICS application. It validates the inbound CICS communication area (COMMAREA), determines the policy type being updated (Endowment, House, or Motor), verifies that the COMMAREA contains enough data for that policy type, then delegates the actual DB2 database update to the linked program `LGUPDB01`. Any missing or mal-formed input triggers a structured error-logging sequence that writes diagnostic messages to a transient data queue (TDQ) via the shared utility program `LGSTSQ`.

---

#### 4.2.2 Execution Flow

**Step 1 — Program Initialisation**
The program captures key CICS Execute Interface Block (EIB) values — the transaction ID (`EIBTRNID`), terminal ID (`EIBTRMID`), and task number (`EIBTASKN`) — into the working-storage header structure `WS_HEADER`. These are used later for diagnostics.

**Step 2 — COMMAREA Presence Check**
`EIBCALEN` (the EIB field holding the length of the passed COMMAREA) is tested. If it equals zero, no COMMAREA was supplied:
- The error message text is set to `NO COMMAREA RECEIVED`.
- `WRITE_ERROR_MESSAGE` is called to log the diagnostic.
- `EXEC CICS ABEND ABCODE('LGCA') NODUMP` terminates the task abnormally with code `LGCA`, without producing a storage dump.

**Step 3 — COMMAREA Initialisation**
If a COMMAREA is present:
- `CA_RETURN_CODE` is set to `'00'` (no error yet).
- `WS_CALEN` captures the actual COMMAREA length from `EIBCALEN`.
- `WS_ADDR_DFHCOMMAREA` stores the pointer to the COMMAREA, enabling based-structure access.
- The customer number (`CA_CUSTOMER_NUM`) and policy number (`CA_POLICY_NUM`) are copied into the error message fields for use in any subsequent diagnostic output.

**Step 4 — Policy Type Identification and COMMAREA Length Validation**
A PL/I `SELECT` statement evaluates `CA_REQUEST_ID` (the 6-character request identifier from the COMMAREA header):

| Request ID | Policy Type | Required Min. Length |
|------------|-------------|---------------------|
| `01UEND` | Endowment | 28 (header) + 124 = 152 bytes |
| `01UHOU` | House | 28 (header) + 130 = 158 bytes |
| `01UMOT` | Motor | 28 (header) + 137 = 165 bytes |
| Otherwise | Unknown | — |

For each recognised policy type:
1. `WS_REQUIRED_CA_LEN` is computed by summing `WS_CA_HEADER_LEN` (28) with the appropriate full-record constant (`WS_FULL_ENDOW_LEN`, `WS_FULL_HOUSE_LEN`, or `WS_FULL_MOTOR_LEN`).
2. If `EIBCALEN` is less than `WS_REQUIRED_CA_LEN`, `CA_RETURN_CODE` is set to `'98'` (COMMAREA too short) and `EXEC CICS RETURN` returns control immediately to the calling program with that error code — no DB2 update is attempted.
3. For an unrecognised request ID, `CA_RETURN_CODE` is set to `'99'` (invalid request) and processing falls through to the DB2 call (which will also likely fail, but the error is flagged in the return code).

**Step 5 — Database Update**
`CALL UPDATE_POLICY_DB2_INFO` invokes the internal procedure, which issues:
```
EXEC CICS LINK Program('LGUPDB01')
          Commarea(COMM_AREA_RAW)
          LENGTH(32500);
```
This passes the full 32,500-byte raw COMMAREA to `LGUPDB01`, the DB2 data-access layer program. Control returns here when `LGUPDB01` issues its own `EXEC CICS RETURN`. Any result code or updated data is communicated back via the shared COMMAREA.

**Step 6 — Return to Caller**
`EXEC CICS RETURN` returns control to whatever program linked to `LGUPOL01`, passing back the (possibly modified) COMMAREA including `CA_RETURN_CODE`.

---

#### 4.2.3 WRITE_ERROR_MESSAGE Sub-procedure

Called only when no COMMAREA is present at entry. It:
1. Issues `EXEC CICS ASKTIME ABSTIME(WS_ABSTIME)` to retrieve the current time as a packed-decimal absolute timestamp.
2. Issues `EXEC CICS FORMATTIME` to convert it to a human-readable `MM/DD/YYYY` date and `HH:MM:SS` time.
3. Populates `EM_DATE` and `EM_TIME` in the `ERROR_MSG` structure.
4. Links to `LGSTSQ` with `ERROR_MSG` as the COMMAREA to write the primary error record to the TDQ.
5. If `EIBCALEN > 0` (there is some COMMAREA data), writes up to 90 bytes of the raw COMMAREA to `CA_DATA` and links to `LGSTSQ` again — capturing either the full COMMAREA (if ≤ 90 bytes) or the first 90 bytes, to assist with problem diagnosis.

---

#### 4.2.4 External Interactions

| Program / Resource | Interaction Type | Purpose |
|--------------------|-----------------|---------|
| `LGUPDB01` | `EXEC CICS LINK` | DB2 data-access layer — performs the actual policy record UPDATE against the database |
| `LGSTSQ` | `EXEC CICS LINK` | Shared TDQ writer utility — logs error messages and raw COMMAREA content for diagnostics |
| CICS EIB | Read | Reads `EIBCALEN`, `EIBTRNID`, `EIBTRMID`, `EIBTASKN` for runtime context |

---

#### 4.2.5 Plain Language Summary

When a user or calling application wants to update an insurance policy, this program acts as the gatekeeper. First, it checks that data was actually passed to it — if not, it raises an alarm (ABEND code `LGCA`) and logs a diagnostic message. If data is present, it looks at the request type to determine whether the policy being updated is an Endowment, House, or Motor policy, then confirms the data packet is large enough to contain all the required fields for that policy type. If the data is too short, it sends back error code `98` immediately. If the request type is unrecognised, it sets error code `99`. Assuming all checks pass, it hands the update request off to `LGUPDB01`, which performs the actual database write. The result is passed back to the calling program through the shared communication area.

---

### 4.3 Database Tables

The direct DB2 interaction is performed by the linked program `LGUPDB01`. Based on the COMMAREA fields visible in `LGCMAREA.inc` that are relevant to a policy update, the following ER diagram reflects the data structures involved:

```mermaid
erDiagram
    POLICY {
        string CA_POLICY_NUM "Policy number PIC 9999999999"
        string CA_ISSUE_DATE "Policy issue date CHAR 10"
        string CA_EXPIRY_DATE "Policy expiry date CHAR 10"
        string CA_LASTCHANGED "Last changed timestamp CHAR 26"
        decimal CA_BROKERID "Broker ID PIC 9999999999"
        string CA_BROKERSREF "Brokers reference CHAR 10"
        decimal CA_PAYMENT "Payment amount PIC 999999"
    }

    ENDOWMENT_POLICY {
        string CA_E_WITH_PROFITS "With profits flag CHAR 1"
        string CA_E_EQUITIES "Equities flag CHAR 1"
        string CA_E_MANAGED_FUND "Managed fund flag CHAR 1"
        string CA_E_FUND_NAME "Fund name CHAR 10"
        decimal CA_E_TERM "Term years PIC 99"
        decimal CA_E_SUM_ASSURED "Sum assured PIC 999999"
        string CA_E_LIFE_ASSURED "Life assured name CHAR 31"
    }

    HOUSE_POLICY {
        string CA_H_PROPERTY_TYPE "Property type CHAR 15"
        decimal CA_H_BEDROOMS "Number of bedrooms PIC 999"
        decimal CA_H_VALUE "Property value PIC 99999999"
        string CA_H_HOUSE_NAME "House name CHAR 20"
        string CA_H_HOUSE_NUMBER "House number CHAR 4"
        string CA_H_POSTCODE "Postcode CHAR 8"
    }

    MOTOR_POLICY {
        string CA_M_MAKE "Vehicle make CHAR 15"
        string CA_M_MODEL "Vehicle model CHAR 15"
        decimal CA_M_VALUE "Vehicle value PIC 999999"
        string CA_M_REGNUMBER "Registration number CHAR 7"
        string CA_M_COLOUR "Vehicle colour CHAR 8"
        decimal CA_M_CC "Engine CC PIC 9999"
        string CA_M_MANUFACTURED "Manufacture date CHAR 10"
        decimal CA_M_PREMIUM "Premium amount PIC 999999"
        decimal CA_M_ACCIDENTS "Accident count PIC 999999"
    }

    CUSTOMER {
        decimal CA_CUSTOMER_NUM "Customer number PIC 9999999999"
    }

    CUSTOMER ||--o{ POLICY : "holds"
    POLICY ||--o| ENDOWMENT_POLICY : "typed as"
    POLICY ||--o| HOUSE_POLICY : "typed as"
    POLICY ||--o| MOTOR_POLICY : "typed as"
```

## 5. Paragraphs

- **Main Procedure Body (LGUPOL01)**
  - Serves as the program entry point and overall orchestrator for updating insurance policy details within a CICS environment.
  - Initialises working storage header fields (`WS_TRANSID`, `WS_TERMID`, `WS_TASKNUM`) from the CICS EIB fields `EIBTRNID`, `EIBTRMID`, and `EIBTASKN`.
  - Checks whether `EIBCALEN` is zero (no communication area received); if so, sets the error message text to `' NO COMMAREA RECEIVED'`, calls `WRITE_ERROR_MESSAGE`, and issues `EXEC CICS ABEND ABCODE('LGCA') NODUMP` to terminate abnormally without a dump.
  - Sets `CA_RETURN_CODE` to `'00'`, saves `EIBCALEN` into `WS_CALEN`, and stores the communication area pointer into `WS_ADDR_DFHCOMMAREA`.
  - Copies the customer number and policy number from the communication area into `EM_CUSNUM` and `EM_POLNUM` for use in any subsequent error messages.
  - Uses a `SELECT (CA_REQUEST_ID)` construct to branch based on the policy type code:
    - `'01UEND'` (Endowment): accumulates `WS_CA_HEADER_LEN + WS_FULL_ENDOW_LEN` into `WS_REQUIRED_CA_LEN`; if `EIBCALEN` is less than the required length, sets `CA_RETURN_CODE = '98'` and issues `EXEC CICS RETURN`.
    - `'01UHOU'` (House): same pattern using `WS_FULL_HOUSE_LEN`; returns with `CA_RETURN_CODE = '98'` if the communication area is too short.
    - `'01UMOT'` (Motor): same pattern using `WS_FULL_MOTOR_LEN`; returns with `CA_RETURN_CODE = '98'` if the communication area is too short.
    - `OTHERWISE`: sets `CA_RETURN_CODE = '99'` for an unrecognised policy type.
  - After the `SELECT`, calls `UPDATE_POLICY_DB2_INFO` to delegate the actual DB2 update, then issues `EXEC CICS RETURN` to return control to CICS.

- **UPDATE_POLICY_DB2_INFO**
  - Handles the delegation of the DB2 update operation to a subordinate program.
  - Issues a single `EXEC CICS LINK Program('LGUPDB01')` call, passing the raw communication area (`COMM_AREA_RAW`) with a maximum length of 32,500 bytes.
  - No conditional logic or loops are present; the procedure is a thin pass-through that transfers control to the database update program `LGUPDB01` and returns when the link completes.
  - Interacts with the external sub-program `LGUPDB01`, which is responsible for performing the actual policy record update against the DB2 database.

- **WRITE_ERROR_MESSAGE**
  - Provides centralised error logging by formatting and writing diagnostic messages to a transient data queue via a shared queue-writing program.
  - Obtains the current timestamp by issuing `EXEC CICS ASKTIME ABSTIME(WS_ABSTIME)`, then formats it into a human-readable date (`WS_DATE`) and time (`WS_TIME`) using `EXEC CICS FORMATTIME` with the `MMDDYYYY` and `TIME` options.
  - Copies the formatted date and time into the `EM_DATE` and `EM_TIME` fields of the error message structure.
  - Writes the primary error message record to the transient data queue by calling the `LGSTSQ` program via `EXEC CICS LINK` with `COMMAREA(ERROR_MSG)`.
  - Contains conditional logic to also log the communication area contents:
    - If `EIBCALEN` is greater than zero and less than 91, copies the exact communication area bytes (using `LEFT(COMM_AREA_RAW, EIBCALEN)`) into `CA_DATA` and writes the `CA_ERROR_MSG` structure to the queue via another `EXEC CICS LINK` to `LGSTSQ`.
    - If `EIBCALEN` is 91 or greater, copies only the first 90 bytes into `CA_DATA` and writes the truncated `CA_ERROR_MSG` to the queue.
  - Interacts externally with the `LGSTSQ` utility program (up to two times per call) to write structured error records to the transient data queue.

## 6. Dependencies

### 6.1 CICS System Services and Control Blocks
- **DFHEIB (Execute Interface Block)**
  - Accesses runtime transaction execution context fields including `EIBTRNID` (Transaction ID), `EIBTRMID` (Terminal ID), `EIBTASKN` (Task Number), and `EIBCALEN` (Communication Area Length).
  - Used to validate that a communication area is present and check incoming request buffer lengths against required thresholds.
- **CICS Command-Level Services (EXEC CICS)**
  - `EXEC CICS ABEND`: Terminates the transaction with abend code `LGCA` when called without a valid communication area (`EIBCALEN = 0`).
  - `EXEC CICS ASKTIME` & `EXEC CICS FORMATTIME`: Captures system timestamp (`WS_ABSTIME`) and formats the date (`WS_DATE`) and time (`WS_TIME`) for error logging.
  - `EXEC CICS LINK`: Invokes external modules synchronously while passing communication areas.
  - `EXEC CICS RETURN`: Returns control to the calling program or CICS environment.

### 6.2 External Program Interfaces
- **LGUPDB01**
  - Invoked via `EXEC CICS LINK PROGRAM('LGUPDB01')` passing `COMM_AREA_RAW` with a length of 32,500 bytes.
  - Serves as the database access layer program responsible for executing the policy update operations in Db2 for endowment (`01UEND`), house (`01UHOU`), or motor (`01UMOT`) policies.
- **LGSTSQ**
  - Invoked via `EXEC CICS LINK PROGRAM('LGSTSQ')` passing `ERROR_MSG` and `CA_ERROR_MSG`.
  - Serves as the centralized diagnostic logging subroutine that writes formatted error records and communication area dumps to the CICS Transient Data Queue (TDQ).

### 6.3 Data Structures and Input Interfaces
- **COMM_AREA_PTR / LGCMAREA**
  - Input communication area pointer passed as the entry parameter (`LGUPOL01: Proc(COMM_AREA_PTR) Options(Main)`).
  - Defines mapped fields including `CA_REQUEST_ID`, `CA_RETURN_CODE`, `CA_CUSTOMER_NUM`, `CA_POLICY_NUM`, and `COMM_AREA_RAW`.
  - Supplies transaction input data and returns status/response codes (`00` for success, `98` for insufficient length, `99` for invalid request ID).

## 7. Constraints

### 7.1 Communication Area Presence

- **A communication area must be present at program entry**
  - Enforced by checking `EIBCALEN = 0` immediately after capturing runtime context (line 87)
  - If no COMMAREA is passed, the program writes an error message and issues `EXEC CICS ABEND ABCODE('LGCA') NODUMP`, terminating the transaction with abend code `LGCA`

### 7.2 Communication Area Length (Size Minimums by Policy Type)

- **The COMMAREA must meet a minimum byte length determined by the policy type being updated**
  - The minimum is calculated as `WS_CA_HEADER_LEN` (28 bytes, fixed header) plus the full policy-type-specific length
  - **Endowment update (`CA_REQUEST_ID = '01UEND'`)**: minimum COMMAREA length = 28 + 124 = **152 bytes**
    - Enforced at lines 105–110; if `EIBCALEN < WS_REQUIRED_CA_LEN`, `CA_RETURN_CODE` is set to `'98'` and the program returns immediately
  - **House update (`CA_REQUEST_ID = '01UHOU'`)**: minimum COMMAREA length = 28 + 130 = **158 bytes**
    - Enforced at lines 113–118 with the same `'98'` return code pattern
  - **Motor update (`CA_REQUEST_ID = '01UMOT'`)**: minimum COMMAREA length = 28 + 137 = **165 bytes**
    - Enforced at lines 121–126 with the same `'98'` return code pattern
  - A COMMAREA shorter than the required minimum causes an immediate return with error code `'98'` — no policy update is performed

### 7.3 Request Identifier Validity

- **`CA_REQUEST_ID` must be one of the three recognised values: `'01UEND'`, `'01UHOU'`, or `'01UMOT'`**
  - Enforced by the `SELECT (CA_REQUEST_ID)` construct (lines 103–131)
  - Any unrecognised value falls into the `OTHERWISE` branch, which sets `CA_RETURN_CODE = '99'` but still proceeds to call `UPDATE_POLICY_DB2_INFO`; no explicit ABEND or RETURN is issued for this case, meaning the `'99'` code signals an invalid request type to the caller

### 7.4 Processing Sequence (Ordering Constraint)

- **COMMAREA validation must complete before the database update sub-program is invoked**
  - The call to `UPDATE_POLICY_DB2_INFO` (line 132) is placed strictly after the full `SELECT` validation block; the DB2 update can only be reached if COMMAREA presence and length checks have passed (or if the request ID is unrecognised and `'99'` is set)
- **Return code initialisation must precede any validation or processing**
  - `CA_RETURN_CODE` is set to `'00'` (line 93) before any policy-type checks, ensuring a clean state before downstream logic writes an error code

### 7.5 DB2 Sub-program Linkage

- **The COMMAREA passed to the database update sub-program `LGUPDB01` is fixed at a maximum of 32,500 bytes**
  - Enforced by the `LENGTH(32500)` parameter on `EXEC CICS LINK Program('LGUPDB01')` (line 141)
  - Input data exceeding this length cannot be conveyed to the sub-program through this linkage call

### 7.6 Nullable DB2 Column Handling

- **SQL indicator variables must be declared for all nullable DB2 columns accessed in FETCH operations**
  - `IND_BROKERID`, `IND_BROKERSREF`, and `IND_PAYMENT` are declared (lines 72–74) to capture null indicators for the broker ID, broker reference, and payment columns respectively
  - Without these indicator variables, a DB2 FETCH returning a null value for any of these columns would fail; their presence is a structural constraint ensuring any null value is handled without an SQL error

### 7.7 Error Message Content Limits

- **Diagnostic COMMAREA data written to the transient data queue is capped at 90 bytes**
  - Enforced in `WRITE_ERROR_MESSAGE` (lines 162–175): if `EIBCALEN < 91`, the actual COMMAREA bytes (up to its real length) are captured; otherwise exactly 90 bytes are taken using `LEFT(COMM_AREA_RAW, 90)`
  - This prevents the `CA_DATA` field (declared as `CHAR(90)`) from overflowing and bounds the diagnostic output to the fixed 90-byte capacity of that field

### 7.8 Return Code Communication

- **The return code field `CA_RETURN_CODE` is the sole mechanism for communicating processing outcome back to the caller**
  - `'00'` — successful initialisation (set before validation); updated by the sub-program on completion
  - `'98'` — COMMAREA length insufficient for the requested policy type
  - `'99'` — unrecognised `CA_REQUEST_ID` value
  - Callers are implicitly constrained to inspect this field to determine whether the update was accepted or rejected

## 8. Error Handling

### 8.1 Missing or Zero-Length Communication Area

- **Check:** At program entry, the CICS-supplied field `EIBCALEN` is tested to determine whether any communication area was passed to the program. If the value is zero, the program treats this as a fatal condition.
- **Error message:** The error message variable `EM_MSG_TEXT` is set to a descriptive literal (`NO COMMAREA RECEIVED`) and the `WRITE_ERROR_MESSAGE` internal procedure is called to log the condition.
- **Termination:** Immediately after logging, a CICS `ABEND` command is issued with abend code `LGCA` and the `NODUMP` option, forcibly terminating the task without producing a system dump.

---

### 8.2 Communication Area Length Validation by Policy Type

- **Check:** After confirming a communication area is present, the program examines the `CA_REQUEST_ID` field using a `SELECT` construct to identify the requested policy type (endowment `01UEND`, house `01UHOU`, or motor `01UMOT`). For each recognised type, the minimum required communication area length is computed by adding the fixed header length (`WS_CA_HEADER_LEN`) to the appropriate full policy-type length (`WS_FULL_ENDOW_LEN`, `WS_FULL_HOUSE_LEN`, or `WS_FULL_MOTOR_LEN`).
- **Comparison:** The computed minimum (`WS_REQUIRED_CA_LEN`) is compared against the actual length (`EIBCALEN`). If the actual length is less than the required minimum, the request data is considered incomplete.
- **Return code:** `CA_RETURN_CODE` is set to `'98'` to signal an insufficient communication area length to the caller.
- **Early return:** A CICS `RETURN` is issued immediately, stopping further processing without proceeding to the database update step.
- **Unknown policy type:** If `CA_REQUEST_ID` does not match any of the three known values, the `OTHERWISE` branch sets `CA_RETURN_CODE` to `'99'` to signal an unrecognised request type. No further processing is performed.

---

### 8.3 Error Message Logging Infrastructure (`WRITE_ERROR_MESSAGE`)

- **Timestamping:** The procedure calls `EXEC CICS ASKTIME` to retrieve the current absolute time and `EXEC CICS FORMATTIME` to convert it into human-readable date (`WS_DATE`) and time (`WS_TIME`) strings, which are placed into the error message structure (`EM_DATE`, `EM_TIME`).
- **Message composition:** The `ERROR_MSG` structure pre-populates identifying labels for program name, customer number (`EM_CUSNUM`), policy number (`EM_POLNUM`), SQL request type (`EM_SQLREQ`), and SQL return code (`EM_SQLRC`), providing full diagnostic context in every logged message.
- **Writing to the transient data queue:** The composed error message is written to a transient data queue by linking to the `LGSTSQ` utility program with `ERROR_MSG` as the communication area.
- **Communication area content capture:** If a communication area is present (`EIBCALEN > 0`), its raw content is also written to the transient data queue via a second call to `LGSTSQ`:
  - If the communication area is shorter than 91 bytes, only the actual bytes present are captured into `CA_DATA`.
  - If it is 91 bytes or longer, the first 90 bytes are captured.
  - This provides a raw diagnostic snapshot of the input data alongside the formatted error message.

---

### 8.4 SQL Null Indicator Variables

- **Defensive DB2 handling:** Three null indicator variables (`IND_BROKERID`, `IND_BROKERSREF`, `IND_PAYMENT`) are declared to accompany DB2 columns that may hold null values. These indicators are passed alongside the corresponding host variables in SQL `FETCH` operations to receive the null status flag, preventing an SQL failure that would otherwise occur if a null value were returned into a host variable without a declared indicator.

## 9. Examples

### 9.1 Example 1: Update a Motor Insurance Policy (Happy Path)

**Input Communication Area**
>>>>>>> Stashed changes

| Field | Value |
|---|---|
| `CA_REQUEST_ID` | `01UMOT` |
<<<<<<< Updated upstream
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
=======
| `CA_CUSTOMER_NUM` | `0000000123` |
| `CA_POLICY_NUM` | `0000000456` |
| `EIBCALEN` (actual CA length) | `165` (≥ 28 + 137 = 165) |
| Motor policy data fields | Fully populated (vehicle reg, make, model, etc.) |

**Expected Output**

- `CA_RETURN_CODE` = `00`
- `LGUPDB01` is called via `EXEC CICS LINK` with the full communication area, which performs the actual DB2 update.
- Control returns to the caller with no error.

**How the logic flows**

1. `EIBCALEN` is non-zero, so the program does not ABEND.
2. `CA_RETURN_CODE` is initialised to `00`.
3. The `SELECT` on `CA_REQUEST_ID` matches `01UMOT`.
4. `WS_REQUIRED_CA_LEN` is computed as `WS_CA_HEADER_LEN (28) + WS_FULL_MOTOR_LEN (137) = 165`.
5. `EIBCALEN` (165) is **not** less than 165, so the length check passes.
6. `UPDATE_POLICY_DB2_INFO` is called, linking to `LGUPDB01` to commit the update.

---

### 9.2 Example 2: Update a House Insurance Policy — Communication Area Too Short (Validation Failure)

**Input Communication Area**
>>>>>>> Stashed changes

| Field | Value |
|---|---|
| `CA_REQUEST_ID` | `01UHOU` |
<<<<<<< Updated upstream
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
=======
| `CA_CUSTOMER_NUM` | `0000000789` |
| `CA_POLICY_NUM` | `0000000101` |
| `EIBCALEN` (actual CA length) | `100` (< 28 + 130 = 158) |

**Expected Output**

- `CA_RETURN_CODE` = `98`
- `EXEC CICS RETURN` is issued immediately; `LGUPDB01` is **never** called.
- No DB2 update takes place.

**How the logic flows**

1. `EIBCALEN` is non-zero, so no ABEND.
2. The `SELECT` on `CA_REQUEST_ID` matches `01UHOU`.
3. `WS_REQUIRED_CA_LEN` is computed as `28 + 130 = 158`.
4. `EIBCALEN` (100) is **less than** 158, so the length check fails.
5. `CA_RETURN_CODE` is set to `98` and `EXEC CICS RETURN` exits the program, signalling to the caller that insufficient data was passed.

---

### 9.3 Example 3: Unknown Policy Type (Invalid Request ID)

**Input Communication Area**

| Field | Value |
|---|---|
| `CA_REQUEST_ID` | `01ULIFE` (unrecognised) |
| `CA_CUSTOMER_NUM` | `0000000999` |
| `CA_POLICY_NUM` | `0000000202` |
| `EIBCALEN` | `200` |

**Expected Output**

- `CA_RETURN_CODE` = `99`
- `UPDATE_POLICY_DB2_INFO` is **still called** (the `SELECT OTHERWISE` only sets the return code; it does not `RETURN`).
- `LGUPDB01` receives the communication area; behaviour at the DB2 level depends on that sub-program's own validation.

**How the logic flows**

1. The `SELECT` on `CA_REQUEST_ID` does not match `01UEND`, `01UHOU`, or `01UMOT`.
2. The `OTHERWISE` branch sets `CA_RETURN_CODE = '99'`.
3. Execution falls through to `CALL UPDATE_POLICY_DB2_INFO`, which links to `LGUPDB01`. The `99` code in the communication area signals the invalid request to the downstream program.

---

### 9.4 Example 4: No Communication Area Passed (ABEND Path)

**Input**

| Field | Value |
|---|---|
| `EIBCALEN` | `0` (no COMMAREA) |

**Expected Output**

- Error message `' NO COMMAREA RECEIVED'` is written to the transient data queue via `LGSTSQ`.
- `EXEC CICS ABEND ABCODE('LGCA') NODUMP` is issued; the task terminates abnormally with abend code `LGCA`.

**How the logic flows**

1. On entry, `EIBCALEN = 0` satisfies the first `IF` condition.
2. `WRITE_ERROR_MESSAGE` is called: `CICS ASKTIME`/`FORMATTIME` capture the current timestamp, and the diagnostic message (including program name, customer number, policy number, and raw CA bytes) is sent to the TDQ via `LGSTSQ`.
3. `EXEC CICS ABEND ABCODE('LGCA') NODUMP` terminates the transaction without producing a system dump.
>>>>>>> Stashed changes

---

Generated by IBM Bob Premium Package for Z
