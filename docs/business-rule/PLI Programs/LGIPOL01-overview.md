# Business rules: Overview

**Program:** LGIPOL01

## Table of Contents

- [1. Purpose](#1-purpose)
<<<<<<< Updated upstream
- [2. Function: Policy Inquiry Processing](#2-function-policy-inquiry-processing)
  - [2.1 SubFunction: Policy Data Retrieval](#21-subfunction-policy-data-retrieval)
  - [2.2 SubFunction: Policy Coverage Rules Application](#22-subfunction-policy-coverage-rules-application)
=======
- [2. Function: Policy Inquiry and Data Retrieval](#2-function-policy-inquiry-and-data-retrieval)
  - [2.1 SubFunction: Policy Data Extraction](#21-subfunction-policy-data-extraction)
  - [2.2 SubFunction: Motor Policy Term Adjustments](#22-subfunction-motor-policy-term-adjustments)
>>>>>>> Stashed changes

## 1. Purpose
This document presents a program-level functional view of the business logic in LGIPOL01. Business rules are organised into a Function → SubFunction → Business Rule hierarchy representing the business functions performed in the program. Semantically related rules are consolidated into named SubFunctions that group related business capabilities, and purely technical or setup logic is excluded. Each rule documents its purpose, ordered execution steps with conditions, actions, and outcomes, references to the contributing source paragraphs, and the business significance of each rule.

<<<<<<< Updated upstream
## 2. Function: Policy Inquiry Processing

### 2.1 SubFunction: Policy Data Retrieval

#### 2.1.1 Business Rule: Retrieve Insurance Policy Record

##### 2.1.1.1 Purpose
When a policy inquiry is initiated, the system establishes a default successful status and delegates the actual data retrieval to the back-end database program (LGIPDB01) via a CICS LINK call. The customer number and policy number are passed through the communication area to uniquely identify and fetch the requested policy record from DB2.

##### 2.1.1.2 Rule Steps
1. **Initialize inquiry return code to success**
   - Conditions: Executed unconditionally at the start of every policy inquiry request.
   - Actions: Set `CA_RETURN_CODE` to `'00'`, indicating a successful initial state.
   - Outcomes: The calling program receives an optimistic success signal that will be overwritten only if a subsequent error is detected.
   - Relevant Procedures: `LGIPOL01`

2. **Delegate policy retrieval to database program**
   - Conditions: Always executed following initialization; the communication area must contain valid `CA_CUSTOMER_NUM` and `CA_POLICY_NUM` values.
   - Actions: Issue a CICS LINK to program `LGIPDB01`, passing the full communication area including `CA_CUSTOMER_NUM` and `CA_POLICY_NUM` to drive the DB2 policy lookup.
   - Outcomes: The requested policy record is retrieved from DB2 and populated back into the communication area for the calling program; `CA_RETURN_CODE` is updated by `LGIPDB01` if retrieval fails.
   - Relevant Procedures: `LGIPOL01`, `LGIPDB01`

##### 2.1.1.3 Business Significance
If the delegation to `LGIPDB01` is incorrectly invoked, or the communication area does not carry the correct customer and policy identifiers, the wrong policy record — or no record at all — will be returned to the requester. This undermines the integrity of all downstream policy servicing, billing, and coverage decisions that depend on accurate policy data retrieval.

---

### 2.2 SubFunction: Policy Coverage Rules Application

#### 2.2.1 Business Rule: Extended Expiry Date Override for Honda Motor Vehicles

##### 2.2.1.1 Purpose
After policy data is retrieved, a special coverage rule is evaluated: if the insured motor vehicle's make is `'HONDA'`, the policy expiry date is unconditionally overridden to `2099-01-01`, regardless of the expiry date stored in the database. This grants effectively indefinite coverage duration to Honda motor vehicle policies, representing a distinct business underwriting exception.

##### 2.2.1.2 Rule Steps
1. **Evaluate vehicle make for Honda exception**
   - Conditions: Applies only to motor vehicle policies where the retrieved value of `CA_M_MAKE` equals `'HONDA'`.
   - Actions: Override `CA_EXPIRY_DATE` to `'2099-01-01'`.
   - Outcomes: The policy expiry date returned to the calling program reflects the extended far-future date rather than the originally stored expiry date, granting indefinitely extended coverage for the policy.
   - Relevant Procedures: `LGIPOL01`

##### 2.2.1.3 Business Significance
Incorrect application or omission of this rule directly affects coverage validity determinations. If the override is not applied, Honda motor vehicle policyholders may be incorrectly flagged as having lapsed or expired coverage. Conversely, if the rule fires erroneously for non-Honda vehicles, unauthorized coverage extensions would be granted, creating underwriting liability exposure and potential financial loss for the insurer.
=======
## 2. Function: Policy Inquiry and Data Retrieval

### 2.1 SubFunction: Policy Data Extraction
#### 2.1.1 Business Rule: Customer Policy Record Retrieval
##### 2.1.1.1 Purpose
Coordinates the retrieval of comprehensive policy details from the persistent policy repository for a specified customer and policy number.
##### 2.1.1.2 Rule Steps
1. Initialize Transaction Status
   - Conditions: None.
   - Actions: Set `CA_RETURN_CODE` to `'00'`.
   - Outcomes: Prepares the inquiry transaction in an initial successful state prior to data access.
   - Relevant Procedures: `LGIPOL01`
2. Delegate Policy Lookup to Back-End Data Access Service
   - Conditions: Customer identifier (`CA_CUSTOMER_NUM`) and policy number (`CA_POLICY_NUM`) are provided in the communication interface.
   - Actions: Pass the communication area and invoke back-end database service `LGIPDB01` via CICS LINK to query policy records.
   - Outcomes: Populates the communication area with full policy attributes from the database or returns an error status.
   - Relevant Procedures: `LGIPOL01`
##### 2.1.1.3 Business Significance
Failure to invoke or correctly pass parameters to the retrieval service prevents customer service representatives or downstream systems from viewing current policy contracts, disrupting policyholder inquiries and operations.

### 2.2 SubFunction: Motor Policy Term Adjustments
#### 2.2.1 Business Rule: Honda Vehicle Policy Expiry Date Override
##### 2.2.1.1 Purpose
Applies a specific underwriting rule that grants an indefinite coverage period for motor policies insuring Honda vehicles by overriding the stored expiry date.
##### 2.2.1.2 Rule Steps
1. Evaluate Vehicle Manufacturer
   - Conditions: The retrieved motor policy indicates vehicle make `CA_M_MAKE` is equal to `'HONDA'`.
   - Actions: Replace the standard database policy expiration date `CA_EXPIRY_DATE` with `'2099-01-01'`.
   - Outcomes: Extends the effective coverage validity of the Honda motor vehicle policy indefinitely.
   - Relevant Procedures: `LGIPOL01`
##### 2.2.1.3 Business Significance
Incorrect application of this rule may lead to premature policy expiration notices, accidental cancellation of active Honda coverage, or unauthorized lifetime coverage on non-qualifying vehicles, resulting in coverage disputes or financial liability.
>>>>>>> Stashed changes

---

Generated by IBM Bob Premium Package for Z
