## Table of Contents

- [1. Purpose](#1-purpose)
- [2. Inputs](#2-inputs)
  - [2.1 CICS Communication Area (`COMM_AREA`)](#21-cics-communication-area-comm_area)
  - [2.2 Linked Back-End Program (`LGIPDB01`)](#22-linked-back-end-program-lgipdb01)
  - [2.3 DB2 Data Retrieved via `LGIPDB01`](#23-db2-data-retrieved-via-lgipdb01)
  - [2.4 CICS Environment Fields (implicit inputs)](#24-cics-environment-fields-implicit-inputs)
- [3. Outputs](#3-outputs)
- [4. Processing Logic](#4-processing-logic)
  - [4.1 Mermaid Flow Diagram](#41-mermaid-flow-diagram)
  - [4.2 Processing Logic Description](#42-processing-logic-description)
  - [4.3 Database Tables](#43-database-tables)
- [5. Paragraphs](#5-paragraphs)
- [6. Dependencies](#6-dependencies)
  - [6.1 Linked Programs (CICS `EXEC CICS LINK`)](#61-linked-programs-cics-exec-cics-link)
  - [6.2 CICS Communication Area (`COMM_AREA`)](#62-cics-communication-area-comm_area)
  - [6.3 Copybooks / Include Members](#63-copybooks--include-members)
  - [6.4 DB2 Host Variable Structures (populated by `LGIPDB01`)](#64-db2-host-variable-structures-populated-by-lgipdb01)
  - [6.5 CICS System Fields (EIB)](#65-cics-system-fields-eib)
  - [6.6 CICS Services Used](#66-cics-services-used)
  - [6.7 Business Rules](#67-business-rules)
- [7. Constraints](#7-constraints)
  - [7.1 Commarea Presence and Size Constraints](#71-commarea-presence-and-size-constraints)
  - [7.2 Commarea Structure and Field-Size Constraints](#72-commarea-structure-and-field-size-constraints)
  - [7.3 Processing Sequencing Constraints](#73-processing-sequencing-constraints)
  - [7.4 Business Rule Constraints](#74-business-rule-constraints)
  - [7.5 Error Logging Constraints](#75-error-logging-constraints)
  - [7.6 Downstream Program Invocation Constraints](#76-downstream-program-invocation-constraints)
- [8. Error Handling](#8-error-handling)
  - [8.1 Missing or Zero-Length Commarea Guard](#81-missing-or-zero-length-commarea-guard)
  - [8.2 Return Code Initialisation](#82-return-code-initialisation)
  - [8.3 Business Rule Override (Conditional Value Substitution)](#83-business-rule-override-conditional-value-substitution)
  - [8.4 Centralised Error Logging via `WRITE_ERROR_MESSAGE`](#84-centralised-error-logging-via-write_error_message)
- [9. Examples](#9-examples)
  - [9.1 Example 1: Standard Motor Policy Inquiry (Non-Honda Vehicle)](#91-example-1-standard-motor-policy-inquiry-non-honda-vehicle)
  - [9.2 Example 2: Motor Policy Inquiry — Honda Override Rule](#92-example-2-motor-policy-inquiry--honda-override-rule)
  - [9.3 Example 3: Missing Commarea — Abend Condition](#93-example-3-missing-commarea--abend-condition)

## 1. Purpose

The `LGIPOL01` program serves as the business logic controller for insurance policy inquiry operations within the GenApp CICS application, retrieving comprehensive details for endowment, house, or motor policies associated with a given customer and policy number. Upon validating the incoming communication area, it coordinates data retrieval by invoking the database service program `LGIPDB01` and applies specific business rules to the returned policy data, such as overriding the policy expiration date for specified motor vehicle makes before returning the populated contract details and execution status to the calling program.

## 2. Inputs

### 2.1 CICS Communication Area (`COMM_AREA`)
The program receives a single pointer (`COMM_AREA_PTR`) as its main entry parameter. All external inputs arrive through the `COMM_AREA` structure mapped over the CICS commarea. The commarea must be present (`EIBCALEN > 0`) and of sufficient length; its absence triggers an abend.

- **`CA_REQUEST_ID`** *(CHAR(6))* — identifies the type of business request being processed; governs how the rest of the commarea is interpreted
- **`CA_RETURN_CODE`** *(PIC '99')* — conveyed into the program from the caller; initialised to `'00'` at entry and updated to signal outcomes back to the caller
- **`CA_CUSTOMER_NUM`** *(PIC '9999999999')* — 10-digit customer identifier supplied by the caller; used to drive retrieval of the customer's policy record via `LGIPDB01`
- **`CA_POLICY_NUM`** *(PIC '9999999999')* — 10-digit policy identifier supplied by the caller; passed to `LGIPDB01` to select the specific policy record from DB2
- **Common policy fields** — present in `CA_POLICY_COMMON` within the commarea; populated by `LGIPDB01` on return and passed back to the caller:
  - **`CA_ISSUE_DATE`** *(CHAR(10))* — date the policy was originally issued
  - **`CA_EXPIRY_DATE`** *(CHAR(10))* — policy expiration date; subject to business-rule override (forced to `'2099-01-01'` for motor policies where `CA_M_MAKE = 'HONDA'`)
  - **`CA_BROKERID`** *(PIC '9999999999')* — identifier of the broker associated with the policy
  - **`CA_PAYMENT`** *(PIC '999999')* — premium or installment payment amount for the policy
- **Motor policy fields** — present in `CA_MOTOR` within the commarea:
  - **`CA_M_MAKE`** *(CHAR(15))* — vehicle manufacturer name; directly evaluated by a business rule that overrides `CA_EXPIRY_DATE` when the value is `'HONDA'`

### 2.2 Linked Back-End Program (`LGIPDB01`)
- **`LGIPDB01`** *(CHAR(8), value `'LGIPDB01'`)* — name of the DB2-tier program invoked via `EXEC CICS LINK`; the entire `COMM_AREA` is passed as its commarea so it can retrieve customer and policy data from DB2 and populate the response fields

### 2.3 DB2 Data Retrieved via `LGIPDB01`
These structures are declared as DB2 host variables in the included copybook (`LGPOLICY.inc`) and are populated when `LGIPDB01` returns:

- **`DB2_CUSTOMER`** — composite structure holding customer demographic data fetched from the DB2 Customer table:
  - `DB2_FIRSTNAME`, `DB2_LASTNAME`, `DB2_DATEOFBIRTH`, `DB2_HOUSENAME`, `DB2_HOUSENUMBER`, `DB2_POSTCODE`, `DB2_PHONE_MOBILE`, `DB2_PHONE_HOME`, `DB2_EMAIL_ADDRESS`
- **`DB2_POLICY`** — structure holding core policy data fetched from the DB2 Policy table:
  - **`DB2_POLICYTYPE`** *(CHAR(1))* — single-character code classifying the policy type (Endowment, House, Motor, Commercial, Claim); determines which policy-specific sub-structure applies
  - **`DB2_POLICYNUMBER`** *(PIC '(10)9')* — unique policy identifier as stored in DB2
  - **`DB2_EXPIRYDATE`** *(CHAR(10))* — policy expiry date as held in DB2, mapped to `CA_EXPIRY_DATE` for return

### 2.4 CICS Environment Fields (implicit inputs)
- **`EIBCALEN`** — CICS-supplied length of the incoming commarea; checked at entry to detect a missing commarea (abend `LGCA`) and to validate minimum required length
- **`EIBTRNID`**, **`EIBTRMID`**, **`EIBTASKN`** — CICS EIB fields providing the transaction ID, terminal ID, and task number of the current invocation; used to populate runtime diagnostic headers

## 3. Outputs

**Communication Area (COMM_AREA) — returned to the caller via `EXEC CICS RETURN`**
- `CA_RETURN_CODE` — 2-digit numeric return code written back to the caller; initialised to `'00'` at entry and may be set to a non-zero value by the linked DB2 program (`LGIPDB01`) to signal errors or absence of data
- `CA_REQUEST_ID` — 6-character request type identifier; passed through unchanged and echoed back to the caller as part of the commarea contract
- `CA_CUSTOMER_NUM` — 10-digit customer identifier; passed to `LGIPDB01` and returned populated as part of the commarea
- `CA_POLICY_NUM` — 10-digit policy identifier; passed to `LGIPDB01` and returned as part of the commarea
- **Common policy fields** — populated by `LGIPDB01` and returned to the caller
  - `CA_ISSUE_DATE` — issue date of the retrieved policy
  - `CA_EXPIRY_DATE` — expiry date of the retrieved policy; subject to business rule override: if the motor vehicle make (`CA_M_MAKE`) equals `'HONDA'`, this field is unconditionally overwritten with `'2099-01-01'` before return
  - `CA_BROKERID` — broker identifier associated with the policy
  - `CA_PAYMENT` — premium/payment amount for the policy
- **Policy-type-specific fields** — one of the following sections is populated by `LGIPDB01` depending on `DB2_POLICYTYPE` and returned in the commarea union overlay
  - `CA_ENDOWMENT` — endowment policy details (with-profits flag, equities, managed fund, fund name, term, sum assured, life assured)
  - `CA_HOUSE` — house policy details (property type, bedrooms, value, house name/number, postcode)
  - `CA_MOTOR` — motor policy details (make, model, value, registration number, colour, engine size, manufactured date, premium, accidents); `CA_M_MAKE` additionally drives the expiry-date override
  - `CA_COMMERCIAL` — commercial policy details (address, postcode, geo-coordinates, customer, property type, fire/crime/flood/weather perils and premiums, status, reject reason)
  - `CA_CLAIM` — claim details (claim number, date, paid amount, value, cause, observations)

**Error / diagnostic output written to the CICS Transient Data Queue (TDQ) via `LGSTSQ`**
- `ERROR_MSG` — structured diagnostic record linked to `LGSTSQ` on any error path; contains date, time, program name (`LGIPOL01`), customer number (`EM_CUSNUM`), policy number (`EM_POLNUM`), SQL request name, and SQL return code
- `CA_ERROR_MSG` — up to 90 bytes of raw commarea content (`CA_DATA`) prefixed with `'COMMAREA='`; written to the TDQ immediately after `ERROR_MSG` when a commarea is present, providing a hex dump of the in-flight commarea for diagnosis

**CICS Abend**
- `ABCODE('LGCA')` — issued via `EXEC CICS ABEND` (with `NODUMP`) when no commarea is received (`EIBCALEN = 0`); this is an observable side-effect that terminates the transaction abnormally and is recorded in the CICS system log

## 4. Processing Logic

### 4.1 Mermaid Flow Diagram

```mermaid
graph TD
    classDef startEnd fill:#b5ead7,stroke:#4caf8a,color:#000
    classDef process fill:#c5cae9,stroke:#5c6bc0,color:#000
    classDef decision fill:#fff9c4,stroke:#f9a825,color:#000
    classDef error fill:#ffccbc,stroke:#e64a19,color:#000
    classDef external fill:#d1c4e9,stroke:#7e57c2,color:#000

    A([Start - LGIPOL01 Entry]):::startEnd
    B[Capture transaction ID<br>terminal ID and task number]:::process
    C{{EIBCALEN = 0<br>No commarea received}}:::decision
    D[Write error message<br>Issue ABEND LGCA]:::error
    E[Initialize CA_RETURN_CODE to 00<br>Save commarea pointer and length]:::process
    F[Load customer and policy number<br>into error message fields]:::process
    G[EXEC CICS LINK to LGIPDB01<br>Pass COMM_AREA for DB2 retrieval]:::external
    H{{CA_M_MAKE = HONDA}}:::decision
    I[Override CA_EXPIRY_DATE<br>to 2099-01-01]:::process
    J[EXEC CICS RETURN<br>Return to caller]:::startEnd

    A --> B
    B --> C
    C -- Yes --> D
    C -- No --> E
    E --> F
    F --> G
    G --> H
    H -- Yes --> I
    H -- No --> J
    I --> J

    subgraph WRITE_ERROR_MESSAGE
        WE1[Get current date and time<br>via EXEC CICS ASKTIME and FORMATTIME]:::process
        WE2[Link to LGSTSQ<br>Write error message to TDQ]:::external
        WE3{{EIBCALEN greater than 0}}:::decision
        WE4{{EIBCALEN less than 91}}:::decision
        WE5[Write partial commarea<br>up to EIBCALEN bytes to TDQ]:::external
        WE6[Write first 90 bytes<br>of commarea to TDQ]:::external
        WE7([Return]):::startEnd
        WE1 --> WE2 --> WE3
        WE3 -- Yes --> WE4
        WE3 -- No --> WE7
        WE4 -- Yes --> WE5 --> WE7
        WE4 -- No --> WE6 --> WE7
    end

    D --> WE1
```

---

### 4.2 Processing Logic Description

#### 4.2.1 High-level Summary

LGIPOL01 is the **business logic tier** program for the **Inquire Policy** function in the GenApp CICS insurance application. Its primary responsibility is to accept a policy inquiry request via a CICS commarea, delegate the actual DB2 data retrieval to the back-end database program **LGIPDB01**, and apply any applicable business rule overrides to the returned data before returning control to the caller. It handles input validation, error logging, and a specific vehicle-make override rule.

---

#### 4.2.2 Execution Flow

**Step 1 — Entry and Environment Capture**
On entry, the program captures the CICS transaction ID (`EIBTRNID`), terminal ID (`EIBTRMID`), and task number (`EIBTASKN`) into working storage (`WS_HEADER`). These are diagnostic fields used in error messages.

**Step 2 — Commarea Presence Check**
The program immediately checks `EIBCALEN = 0`. If no commarea was passed by the caller, the program:
- Populates `EM_MSG_TEXT` with `' NO COMMAREA RECEIVED'`
- Calls the internal `WRITE_ERROR_MESSAGE` procedure to log the failure
- Issues `EXEC CICS ABEND ABCODE('LGCA')` to terminate abnormally with a recognisable abend code

This is a hard guard — processing cannot continue without a commarea.

**Step 3 — Commarea Initialization**
If a commarea is present:
- `CA_RETURN_CODE` is set to `'00'` (success assumed until proven otherwise)
- The commarea pointer and length are saved into `WS_ADDR_DFHCOMMAREA` and `WS_CALEN`
- `CA_CUSTOMER_NUM` and `CA_POLICY_NUM` are copied into the error message diagnostic fields (`EM_CUSNUM`, `EM_POLNUM`) for use in any subsequent error logging

**Step 4 — DB2 Retrieval via LGIPDB01**
`EXEC CICS LINK` is issued to the **LGIPDB01** program, passing the full `COMM_AREA` (32,000 bytes). LGIPDB01 uses the `CA_CUSTOMER_NUM` and `CA_POLICY_NUM` from the commarea to query DB2, populating the policy-type-specific fields (endowment, house, motor, commercial, or claim) on return. The return code from LGIPDB01 is conveyed back through `CA_RETURN_CODE` in the shared commarea.

**Step 5 — Business Rule: Honda Motor Policy Override**
After the DB2 call returns, the program checks:
> `IF CA_M_MAKE = 'HONDA'`

If the insured vehicle make is **HONDA**, the policy expiry date (`CA_EXPIRY_DATE`) is unconditionally overridden to **`2099-01-01`** — a far-future date that effectively means the policy never expires under normal circumstances. This applies regardless of the date actually held in DB2. No other vehicle makes are subject to this override.

**Step 6 — Return to Caller**
`EXEC CICS RETURN` is issued, passing control back to the calling program with the fully populated (and potentially business-rule-adjusted) commarea.

---

#### 4.2.3 WRITE_ERROR_MESSAGE Internal Procedure

This internal procedure is called only on the no-commarea error path. It:
1. Obtains the current date and time using `EXEC CICS ASKTIME` / `EXEC CICS FORMATTIME`
2. Formats and writes the error message (containing date, time, program name, customer number, policy number) to a Transient Data Queue (TDQ) via `EXEC CICS LINK PROGRAM('LGSTSQ')`
3. Conditionally dumps up to 90 bytes of the raw commarea to the TDQ for diagnostic purposes:
   - If `EIBCALEN < 91`: writes exactly `EIBCALEN` bytes
   - Otherwise: writes the first 90 bytes

---

#### 4.2.4 External Interactions

| Program / Resource | Interaction Type | Purpose |
|---|---|---|
| **LGIPDB01** | `EXEC CICS LINK` | Back-end DB2 access program; retrieves full policy and customer details from DB2 tables using the customer and policy numbers supplied in the commarea |
| **LGSTSQ** | `EXEC CICS LINK` | Transient Data Queue writer utility; used by `WRITE_ERROR_MESSAGE` to log error and diagnostic information to a TDQ |
| **DB2 Tables** | Indirect (via LGIPDB01) | `Customer`, `Policy`, and policy-type-specific tables (Endowment, House, Motor, Commercial, Claim) |

---

#### 4.2.5 Plain Language Summary

LGIPOL01 is a straightforward policy look-up handler. When a caller wants to see the full details of an insurance policy, it fills in a data block (commarea) with a customer number and policy number and calls this program.

The program first checks that a data block was actually sent — if not, it logs an error and aborts. It then passes the data block to a second program (LGIPDB01) that does the actual database work, fetching all the policy details. Once the database program returns, LGIPOL01 applies one specific business rule: if the policy is for a **Honda** vehicle, the expiry date is set to the year 2099 — effectively making the policy perpetual. Finally, the filled-in data block is returned to whoever called the program.

---

### 4.3 Database Tables

```mermaid
erDiagram
    CUSTOMER {
        string FIRSTNAME "First name of customer"
        string LASTNAME "Last name of customer"
        date DATEOFBIRTH "Customer date of birth"
        string HOUSENAME "House name"
        string HOUSENUMBER "House number"
        string POSTCODE "Postal code"
        string PHONE_MOBILE "Mobile phone number"
        string PHONE_HOME "Home phone number"
        string EMAIL_ADDRESS "Email address"
    }

    POLICY {
        string POLICYTYPE "E Endowment H House M Motor B Commercial C Claim"
        decimal POLICYNUMBER "Unique policy identifier"
        date ISSUEDATE "Date policy was issued"
        date EXPIRYDATE "Date policy expires"
        string LASTCHANGED "Timestamp of last change"
        decimal BROKERID "Broker identifier"
        string BROKERSREF "Broker reference"
        decimal PAYMENT "Premium payment amount"
    }

    ENDOWMENT {
        string E_WITHPROFITS "With-profits flag"
        string E_EQUITIES "Equities flag"
        string E_MANAGEDFUND "Managed fund flag"
        string E_FUNDNAME "Fund name"
        decimal E_TERM "Policy term in years"
        decimal E_SUMASSURED "Sum assured amount"
        string E_LIFEASSURED "Name of life assured"
        string E_PADDINGDATA "Variable padding data"
    }

    HOUSE {
        string H_PROPERTYTYPE "Type of property"
        decimal H_BEDROOMS "Number of bedrooms"
        decimal H_VALUE "Property value"
        string H_HOUSENAME "House name"
        string H_HOUSENUMBER "House number"
        string H_POSTCODE "Postal code"
    }

    MOTOR {
        string M_MAKE "Vehicle manufacturer"
        string M_MODEL "Vehicle model"
        decimal M_VALUE "Vehicle value"
        string M_REGNUMBER "Registration number"
        string M_COLOUR "Vehicle colour"
        decimal M_CC "Engine size in cc"
        date M_MANUFACTURED "Date of manufacture"
        decimal M_PREMIUM "Motor premium"
        decimal M_ACCIDENTS "Number of accidents"
    }

    COMMERCIAL {
        string B_ADDRESS "Business address"
        string B_POSTCODE "Business postcode"
        string B_LATITUDE "Geographic latitude"
        string B_LONGITUDE "Geographic longitude"
        string B_CUSTOMER "Customer description"
        string B_PROPTYPE "Property type"
        decimal B_FIREPERIL "Fire peril level"
        decimal B_FIREPREMIUM "Fire premium amount"
        decimal B_CRIMEPERIL "Crime peril level"
        decimal B_CRIMEPREMIUM "Crime premium amount"
        decimal B_FLOODPERIL "Flood peril level"
        decimal B_FLOODPREMIUM "Flood premium amount"
        decimal B_WEATHERPERIL "Weather peril level"
        decimal B_WEATHERPREMIUM "Weather premium amount"
        decimal B_STATUS "Policy status code"
        string B_REJECTREASON "Rejection reason text"
    }

    CLAIM {
        decimal C_NUM "Claim number"
        date C_DATE "Claim date"
        decimal C_PAID "Amount paid"
        decimal C_VALUE "Claim value"
        string C_CAUSE "Cause of claim"
        string C_OBSERVATIONS "Claim observations"
    }

    CUSTOMER ||--o{ POLICY : "holds"
    POLICY ||--o| ENDOWMENT : "typed as"
    POLICY ||--o| HOUSE : "typed as"
    POLICY ||--o| MOTOR : "typed as"
    POLICY ||--o| COMMERCIAL : "typed as"
    POLICY ||--o{ CLAIM : "has"
```

## 5. Paragraphs

- **Main Procedure (LGIPOL01)**  
  - The top-level main procedure of the program, declared with `Proc(COMM_AREA_PTR) Options(Main)`. Its purpose is to orchestrate a policy inquiry by validating the incoming commarea, capturing runtime/debug information, delegating database retrieval to a linked CICS program, applying a motor-policy business rule override, and then returning control to CICS.  
  - Operations performed:  
    - Declares working-storage structures for runtime/debug info (`WS_HEADER`), time/date processing (`ABS_TIME`, `TIME1`, `DATE1`), the error-message buffer (`ERROR_MSG`, `CA_ERROR_MSG`), commarea-length tracking (`WS_COMMAREA_LENGTHS`), the policy-type discriminator (`END_POLICY_POS`), and the CICS program-name constant (`LGIPDB01`).  
    - Captures CICS-supplied runtime identifiers by assigning `EIBTRNID`, `EIBTRMID`, and `EIBTASKN` into `WS_TRANSID`, `WS_TERMID`, and `WS_TASKNUM`.  
  - Control flow elements: conditional abend — `IF EIBCALEN = 0 THEN DO ... END` issues an abend with ABCODE `'LGCA'` when no commarea is received. On valid commarea, processing continues linearly. After the DB2 retrieval and business-rule application, execution flows unconditionally into `EXEC CICS RETURN`.  
  - Interactions with external systems: receives the commarea pointer from CICS; issues `EXEC CICS LINK Program(LGIPDB01) Commarea(COMM_AREA) Length(32000)` to invoke the back-end database-access program that performs the DB2 query; and concludes with `EXEC CICS RETURN` to pass the populated commarea back to the caller. A `RETURN` statement follows the CICS RETURN as an unreachable safety net.

- **Business-Rule Override (Motor Policy Expiry Check)**  
  - A single conditional statement located between the CICS LINK to LGIPDB01 and the `EXEC CICS RETURN`. Its purpose is to enforce a business rule: motor policies whose `CA_M_MAKE` equals `'HONDA'` have their expiry date overridden.  
  - Operations performed: evaluates `CA_M_MAKE` against the literal `'HONDA'`; when the condition is true, assigns `'2099-01-01'` to `CA_EXPIRY_DATE` in the policy-common section of the commarea.  
  - Control flow elements: simple `IF ... THEN` construct with no `ELSE` branch; if the make is not HONDA the expiry date is left unchanged.  
  - Interactions with external systems: none of its own — it modifies the commarea that was just filled by the linked LGIPDB01 program, preparing the final returned data.

- **WRITE_ERROR_MESSAGE procedure**  
  - A separable procedure (declared `WRITE_ERROR_MESSAGE: PROC`) that logs diagnostic information to a CICS transient-data queue. Its purpose is to support the abend path: when the main procedure detects a missing commarea (or other error), it calls this routine to record the date/time, program identity, customer number, policy number, SQLCODE, and a snapshot of the incoming commarea bytes.  
  - Operations performed:  
    - Captures the current time and date via `EXEC CICS ASKTIME ABSTIME(ABS_TIME)` and `EXEC CICS FORMATTIME`, then moves the formatted date and time into the error-message structure (`EM_DATE`, `EM_TIME`).  
    - Writes the fully-formatted error message (which already carries the literal `' LGIPOL01'` suffix, plus the CNUM, PNUM, and SQL-request fields populated earlier in the main body) to the TDQ by `EXEC CICS LINK PROGRAM('LGSTSQ') COMMAREA(ERROR_MSG)`.  
    - Performs a second conditional block — `IF EIBCALEN > 0 THEN DO ... END` with nested `IF EIBCALEN < 91 THEN ... ELSE ...` — to write a 90-byte (or shorter) slice of the raw commarea to the TDQ as a diagnostic hex/ascii dump via another `CALL`/LINK to `LGSTSQ` using the `CA_ERROR_MSG` structure.  
  - Control flow elements: nested `IF ... THEN ... ELSE` conditional logic controlling whether the commarea snapshot is written and whether it is truncated to 90 bytes or copied in full when shorter than 91 bytes.  
  - Interactions with external systems: calls the CICS-time services `ASKTIME` and `FORMATTIME`, and performs two `EXEC CICS LINK PROGRAM('LGSTSQ')` calls — one to write the structured error message and one to write the raw commarea bytes — both using `COMMAREA`/`LENGTH` parameters to exchange data with the queue-handler program.

## 6. Dependencies

### 6.1 Linked Programs (CICS `EXEC CICS LINK`)
- **LGIPDB01** — DB2-tier database access program invoked via `EXEC CICS LINK` to perform the actual retrieval of customer and policy records from DB2; receives the full `COMM_AREA` (length 32,000) as its commarea and populates all policy-type-specific fields before returning
- **LGSTSQ** — CICS transient-data-queue (TDQ) writer utility invoked twice within `WRITE_ERROR_MESSAGE`; receives `ERROR_MSG` (date/time/program/customer/policy/SQLCODE) and `CA_ERROR_MSG` (raw commarea dump) to log diagnostic information

---

### 6.2 CICS Communication Area (`COMM_AREA`)
- **Incoming commarea** — a 32,500-byte based structure pointed to by `COMM_AREA_PTR`; passed by the calling program and checked for presence (`EIBCALEN = 0` → abend `LGCA`) and minimum length before any processing
  - `CA_REQUEST_ID` — 6-character request type identifier driving the processing path
  - `CA_RETURN_CODE` — 2-digit numeric return code initialised to `'00'`; returned to the caller to signal success or error
  - `CA_CUSTOMER_NUM` — 10-digit customer identifier extracted from the commarea and used to drive DB2 retrieval
  - `CA_POLICY_NUM` — 10-digit policy identifier passed through to `LGIPDB01` for record lookup
  - `CA_EXPIRY_DATE` — policy expiry date field subject to a business-rule override (set to `'2099-01-01'` for Honda motor policies)
  - `CA_M_MAKE` — 15-character motor vehicle make field evaluated post-DB2-retrieval to apply the Honda expiry-date override rule
  - `CA_ISSUE_DATE`, `CA_PAYMENT`, `CA_BROKERID` — additional core policy contract fields populated by `LGIPDB01` and returned to the caller

---

### 6.3 Copybooks / Include Members
- **`LGCMAREA.inc`** (`%INCLUDE LGCMAREA`) — defines the universal 32,500-byte `COMM_AREA` UNION structure and `COMM_AREA_PTR` pointer; the primary data-exchange contract between all programs in the application tier
- **`LGPOLICY.inc`** (`EXEC SQL INCLUDE LGPOLICY`) — SQL-precompiler include that defines all DB2 host-variable structures (`DB2_CUSTOMER`, `DB2_POLICY`, `DB2_ENDOWMENT`, `DB2_HOUSE`, `DB2_MOTOR`, `DB2_COMMERCIAL`, `DB2_CLAIM`) and associated length constants used for field mapping after database retrieval

---

### 6.4 DB2 Host Variable Structures (populated by `LGIPDB01`)
- **`DB2_CUSTOMER`** — holds customer demographic data (name, date of birth, address, phone, email) retrieved from the DB2 Customer table
- **`DB2_POLICY`** — holds core policy record fields including `DB2_POLICYTYPE` (policy classification character), `DB2_POLICYNUMBER`, `DB2_EXPIRYDATE`, `DB2_ISSUEDATE`, `DB2_BROKERID`, `DB2_PAYMENT`, and other common policy attributes
- **`DB2_ENDOWMENT`**, **`DB2_HOUSE`**, **`DB2_MOTOR`**, **`DB2_COMMERCIAL`**, **`DB2_CLAIM`** — type-specific policy data structures overlaid via UNION; the applicable structure is selected based on `DB2_POLICYTYPE`

---

### 6.5 CICS System Fields (EIB)
- **`EIBCALEN`** — CICS Execute Interface Block field giving the length of the received commarea; used for presence check (`= 0` → abend) and boundary validation
- **`EIBTRNID`** — CICS transaction identifier stored in `WS_TRANSID` for diagnostic logging
- **`EIBTRMID`** — CICS terminal identifier stored in `WS_TERMID` for diagnostic logging
- **`EIBTASKN`** — CICS task number stored in `WS_TASKNUM` for diagnostic logging

---

### 6.6 CICS Services Used
- **`EXEC CICS ABEND ABCODE('LGCA')`** — raised when no commarea is received, terminating the task with a named abend code
- **`EXEC CICS ASKTIME` / `EXEC CICS FORMATTIME`** — used within `WRITE_ERROR_MESSAGE` to obtain and format the current timestamp for inclusion in error log entries
- **`EXEC CICS RETURN`** — returns control to CICS after normal completion of processing

---

### 6.7 Business Rules
- **Honda motor policy expiry override** — an inline rule applied after `LGIPDB01` returns: if `CA_M_MAKE = 'HONDA'`, the policy's `CA_EXPIRY_DATE` is unconditionally overridden to `'2099-01-01'`; no external ODM/`LGAPBR01` call is made in this program

## 7. Constraints

### 7.1 Commarea Presence and Size Constraints

- **Commarea must be present at invocation**
  - `EIBCALEN` is tested for a value of `0` immediately on entry; if no commarea is passed, the program logs an error message and issues `EXEC CICS ABEND ABCODE('LGCA') NODUMP`, terminating execution unconditionally
  - This enforces that `LGIPOL01` can never be invoked without a caller-supplied commarea

- **Commarea is fixed at 32 500 bytes**
  - `COMM_AREA` is declared as a `UNION` overlaying a `CHAR(32500)` raw field (`COMM_AREA_RAW`); the logical commarea layout must therefore fit within 32 500 bytes
  - The `EXEC CICS LINK` to `LGIPDB01` passes the commarea with an explicit `LENGTH(32000)`, meaning only the first 32 000 bytes are presented to the downstream DB2 program

### 7.2 Commarea Structure and Field-Size Constraints

- **`CA_REQUEST_ID`** — fixed at 6 characters; controls request routing and commarea interpretation
- **`CA_RETURN_CODE`** — declared `PIC '99'`; must be a 2-digit numeric value; initialised to `'00'` at entry
- **`CA_CUSTOMER_NUM`** — declared `PIC '9999999999'`; must be exactly 10 numeric digits
- **`CA_POLICY_NUM`** — declared `PIC '9999999999'`; must be exactly 10 numeric digits
- **`CA_ISSUE_DATE` / `CA_EXPIRY_DATE` / `CA_LASTCHANGED`** — fixed-length date fields (`CHAR(10)` and `CHAR(26)` respectively); no format validation is performed in this program, but width is enforced by the structure declaration
- **`CA_BROKERID`** — `PIC '9999999999'`; exactly 10 numeric digits
- **`CA_PAYMENT`** — `PIC '999999'`; exactly 6 numeric digits
- **Policy-type-specific sections** are overlaid via a `UNION` (`CA_POLICY_SPECIFIC`); each sub-structure has a fixed declared size with filler fields to pad to the union width of 32 400 bytes:
  - `CA_ENDOWMENT` — 32 400 bytes total (with `CA_E_PADDING_DATA CHAR(32348)` filler)
  - `CA_HOUSE` — 32 400 bytes total (with `CA_H_FILLER CHAR(32342)`)
  - `CA_MOTOR` — 32 400 bytes total (with `CA_M_FILLER CHAR(32323)`)
  - `CA_COMMERCIAL` — 32 400 bytes total (with `CA_B_FILLER CHAR(31298)`)
  - `CA_CLAIM` — 32 400 bytes total (with `CA_C_FILLER CHAR(31854)`)

### 7.3 Processing Sequencing Constraints

- **DB2 retrieval must precede business-rule evaluation**
  - The `EXEC CICS LINK` to `LGIPDB01` (which populates the commarea with policy data) is performed before any business-rule checks; the Honda expiry-date override at line 337 reads `CA_M_MAKE`, which is only meaningful after the DB2 program has returned data
- **Return code initialisation must precede downstream calls**
  - `CA_RETURN_CODE` is set to `'00'` before the link to `LGIPDB01`, ensuring the downstream program sees a clean return code on entry
- **`EXEC CICS RETURN` terminates processing**; no code after this statement is reachable in the normal path, enforcing that the Honda override is the last business operation before the program exits

### 7.4 Business Rule Constraints

- **Motor policy Honda expiry-date override**
  - If `CA_M_MAKE` equals the literal `'HONDA'` (exact 15-character match, case-sensitive), `CA_EXPIRY_DATE` is unconditionally overridden to `'2099-01-01'` regardless of the date returned by the database
  - This rule applies to all policy types sharing the commarea union layout because no policy-type guard (`DB2_POLICYTYPE` check) is performed before the comparison; any commarea whose motor-make field contains `'HONDA'` will trigger the override

### 7.5 Error Logging Constraints

- **Error message commarea dump is capped at 90 bytes**
  - In `WRITE_ERROR_MESSAGE`, if `EIBCALEN > 0` and `EIBCALEN < 91`, exactly `EIBCALEN` bytes of the raw commarea are written to the TSQ; otherwise exactly 90 bytes are written — enforcing a hard upper limit of 90 bytes on the diagnostic commarea snapshot
- **Error logging requires a live commarea pointer**
  - `CA_DATA` is populated only when `EIBCALEN > 0`; if `EIBCALEN = 0` (the abend path), no commarea bytes are logged, only the fixed error text

### 7.6 Downstream Program Invocation Constraints

- **`LGIPDB01` is the sole permitted DB2 handler**
  - The program name is hard-coded in `DCL 1 LGIPDB01 CHAR(8) INIT('LGIPDB01')`; there is no configuration mechanism to redirect the call to any other program
- **Link commarea length is fixed at 32 000**
  - `EXEC CICS LINK Program(LGIPDB01) Commarea(COMM_AREA) Length(32000)` hard-codes the data window passed to the DB2 tier; fields beyond offset 32 000 in `COMM_AREA` are not visible to `LGIPDB01`
- **Error logging delegate is hard-coded to `LGSTSQ`**
  - Both error-message writes inside `WRITE_ERROR_MESSAGE` use `PROGRAM('LGSTSQ')` as a literal; no alternative TSQ writer can be substituted at runtime

## 8. Error Handling

### 8.1 Missing or Zero-Length Commarea Guard

- **Trigger condition**: Checked at program entry by evaluating whether `EIBCALEN` equals zero, meaning no commarea was passed by the calling program
- **Error population**: The error message text field `EM_MSG_TEXT` is set to a literal describing the absence of a commarea before any other error action is taken
- **Logging**: The internal procedure `WRITE_ERROR_MESSAGE` is invoked to capture and persist a timestamped diagnostic record
- **Program termination**: An `EXEC CICS ABEND` is issued with abend code `LGCA` and the `NODUMP` option, causing the task to terminate abnormally without generating a system dump

### 8.2 Return Code Initialisation

- **Default safe state**: `CA_RETURN_CODE` is unconditionally set to `'00'` immediately after the commarea guard passes, ensuring that if no downstream error overrides it the caller receives a success indicator
- This acts as a passive fallback mechanism — if the linked database program does not set an error return code, the successful default is preserved

### 8.3 Business Rule Override (Conditional Value Substitution)

- **Trigger condition**: After the CICS LINK to `LGIPDB01` returns, a check is made on whether the motor policy vehicle make field `CA_M_MAKE` equals the literal value `'HONDA'`
- **Recovery / fallback logic**: When the condition is true, the policy expiry date `CA_EXPIRY_DATE` is unconditionally overridden with the hardcoded future date `'2099-01-01'`, representing a business rule that grants an effectively permanent expiry for that specific vehicle make
- This is a data correction mechanism embedded in the business logic tier that silently adjusts output without raising an error

### 8.4 Centralised Error Logging via `WRITE_ERROR_MESSAGE`

- **Implementation**: An internal procedure named `WRITE_ERROR_MESSAGE` consolidates all diagnostic message construction and output in one place
- **Timestamp capture**: On every invocation, `EXEC CICS ASKTIME` and `EXEC CICS FORMATTIME` are called to obtain and format the current date and time, which are embedded in the error record
- **Structured error record**: The `ERROR_MSG` structure carries the date, time, a hardcoded program identifier (`LGIPOL01`), the customer number (`EM_CUSNUM`), the policy number (`EM_POLNUM`), a SQL request label (`EM_SQLREQ`), and the SQL return code (`EM_SQLRC`), providing a rich diagnostic payload
- **Transient data queue logging**: The formatted error message is written by linking to the utility program `LGSTSQ` via `EXEC CICS LINK`, passing `ERROR_MSG` as the commarea — this delegates actual queue writing to a shared TSQ/TDQ writer utility
- **Commarea dump logging**: After logging the primary error message, the procedure checks whether `EIBCALEN` is greater than zero and, if so, also logs a raw snapshot of the commarea contents
    - If the commarea length is less than 91 bytes, the entire commarea is captured into `CA_DATA` and written via a second `EXEC CICS LINK` to `LGSTSQ`
    - If the commarea is 91 bytes or longer, the first 90 bytes are extracted and written, preventing buffer overrun while still providing diagnostic context
- **Reusability**: The procedure is designed to be called from any error condition point within the program, supporting consistent logging behaviour across all error paths

## 9. Examples

### 9.1 Example 1: Standard Motor Policy Inquiry (Non-Honda Vehicle)

**Input commarea:**
| Field | Value |
|---|---|
| `CA_REQUEST_ID` | `IPOLCY` |
| `CA_RETURN_CODE` | `00` |
| `CA_CUSTOMER_NUM` | `0000000042` |
| `CA_POLICY_NUM` | `0000000099` |

**DB2 data returned by LGIPDB01 (motor policy):**
| Field | Value |
|---|---|
| `DB2_POLICYTYPE` | `M` |
| `CA_ISSUE_DATE` | `2020-03-15` |
| `CA_EXPIRY_DATE` | `2025-03-15` |
| `CA_PAYMENT` | `001200` |
| `CA_BROKERID` | `0000000007` |
| `CA_M_MAKE` | `FORD` |
| `CA_M_MODEL` | `FIESTA` |
| `CA_M_REGNUMBER` | `AB21XYZ` |

**Expected output commarea (returned to caller):**
| Field | Value |
|---|---|
| `CA_RETURN_CODE` | `00` |
| `CA_EXPIRY_DATE` | `2025-03-15` *(unchanged)* |
| `CA_M_MAKE` | `FORD` |
| All other policy fields | As retrieved from DB2 |

**Explanation:**  
LGIPOL01 initialises `CA_RETURN_CODE` to `'00'`, then issues a `CICS LINK` to `LGIPDB01`, passing the full commarea. `LGIPDB01` looks up customer `0000000042` and policy `0000000099` in DB2 and populates all policy fields. On return, the program checks `CA_M_MAKE`. Because the vehicle make is `'FORD'` (not `'HONDA'`), the expiry date override is **not** triggered, and `CA_EXPIRY_DATE` remains `2025-03-15` exactly as stored in DB2.

---

### 9.2 Example 2: Motor Policy Inquiry — Honda Override Rule

**Input commarea:**
| Field | Value |
|---|---|
| `CA_REQUEST_ID` | `IPOLCY` |
| `CA_CUSTOMER_NUM` | `0000000101` |
| `CA_POLICY_NUM` | `0000000250` |

**DB2 data returned by LGIPDB01 (motor policy):**
| Field | Value |
|---|---|
| `DB2_POLICYTYPE` | `M` |
| `CA_ISSUE_DATE` | `2019-06-01` |
| `CA_EXPIRY_DATE` | `2024-06-01` |
| `CA_PAYMENT` | `000950` |
| `CA_M_MAKE` | `HONDA` |
| `CA_M_MODEL` | `CIVIC` |
| `CA_M_REGNUMBER` | `HN70ABC` |

**Expected output commarea (returned to caller):**
| Field | Value |
|---|---|
| `CA_RETURN_CODE` | `00` |
| `CA_EXPIRY_DATE` | `2099-01-01` *(overridden)* |
| `CA_M_MAKE` | `HONDA` |

**Explanation:**  
After `LGIPDB01` returns the policy data, LGIPOL01 evaluates the business rule `IF CA_M_MAKE = 'HONDA'`. Because the vehicle make matches, the program unconditionally overrides `CA_EXPIRY_DATE` to the hardcoded far-future date `'2099-01-01'`, regardless of the actual expiry date stored in the database. The modified commarea is then returned to the caller via `EXEC CICS RETURN`.

---

### 9.3 Example 3: Missing Commarea — Abend Condition

**Input:** LGIPOL01 is invoked with `EIBCALEN = 0` (no commarea passed).

**Expected behaviour:**
- `WRITE_ERROR_MESSAGE` is called, writing `' NO COMMAREA RECEIVED'` along with timestamp to the transient data queue via `LGSTSQ`.
- `EXEC CICS ABEND ABCODE('LGCA') NODUMP` is issued, terminating the task abnormally with abend code `LGCA`.

**Explanation:**  
The very first executable check in LGIPOL01 tests whether `EIBCALEN = 0`. If the calling program did not pass a commarea, the program cannot safely reference any `COMM_AREA` fields. It therefore logs a diagnostic error message (including date, time, and program name) and abends with code `LGCA` rather than continuing with an unmapped data area.

---

Generated by IBM Bob Premium Package for Z
