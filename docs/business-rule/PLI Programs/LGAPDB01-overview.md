# Business rules: Overview

**Program:** LGAPDB01

## Table of Contents

- [1. Purpose](#1-purpose)
- [2. Function: Insurance Transaction Intake and Classification](#2-function-insurance-transaction-intake-and-classification)
  - [2.1 SubFunction: Request Type Recognition and Policy Classification](#21-subfunction-request-type-recognition-and-policy-classification)
- [3. Function: Policy and Claim Record Creation](#3-function-policy-and-claim-record-creation)
  - [3.1 SubFunction: Policy Header Creation](#31-subfunction-policy-header-creation)
  - [3.2 SubFunction: Product-Specific Detail Creation](#32-subfunction-product-specific-detail-creation)
  - [3.3 SubFunction: Claim Registration](#33-subfunction-claim-registration)

## 1. Purpose
This document presents a program-level functional view of the business logic in LGAPDB01. Business rules are organised into a Function → SubFunction → Business Rule hierarchy representing the business functions performed in the program. Semantically related rules are consolidated into named SubFunctions that group related business capabilities, and purely technical or setup logic is excluded. Each rule documents its purpose, ordered execution steps with conditions, actions, and outcomes, references to the contributing source paragraphs, and the business significance of each rule.

## 2. Function: Insurance Transaction Intake and Classification

### 2.1 SubFunction: Request Type Recognition and Policy Classification

#### 2.1.1 Business Rule: Request Type to Policy Type Mapping and Rejection of Unrecognized Requests

##### 2.1.1.1 Purpose
Every inbound transaction is identified by a request ID. This rule translates the request ID into the business classification of the item being added (Endowment, House, Motor, Commercial policy, or a Claim). The classification code drives all downstream persistence. Requests that cannot be classified are rejected so that no partial or incorrect records are created.

##### 2.1.1.2 Rule Steps
1. Interpret the request identifier and assign the policy type code.
   - Conditions: `CA_REQUEST_ID` = `01AEND` → 'E' (Endowment); `01AHOU` → 'H' (House); `01AMOT` → 'M' (Motor); `01ACOM` → 'C' (Commercial); `01ACLM` → 'X' (Claim).
   - Actions: Set `DB2_POLICYTYPE` to the single-character code that corresponds to the request ID.
   - Outcomes: The transaction is classified and may proceed to persistence.
   - Relevant Procedures: LGAPDB01

2. Reject unrecognized request types.
   - Conditions: `CA_REQUEST_ID` matches none of the five supported values.
   - Actions: Set the return code to 99 and end processing without creating any records.
   - Outcomes: Unsupported requests are rejected with return code 99.
   - Relevant Procedures: LGAPDB01

##### 2.1.1.3 Business Significance
Incorrect mapping would store a policy under the wrong classification, which affects product reporting and how the policy is later serviced or claimed against. Failure to reject unknown requests would allow invalid transactions to create orphaned or inconsistent data.

---

## 3. Function: Policy and Claim Record Creation

### 3.1 SubFunction: Policy Header Creation

#### 3.1.1 Business Rule: Create Policy Header for Non-Claim Requests

##### 3.1.1.1 Purpose
Every new policy (endowment, house, motor, commercial) receives a general policy header record that serves as the master anchor for the type-specific details. Claims are not policies and therefore have no header row. This rule decides when a header is created and what it contains.

##### 3.1.1.2 Rule Steps
1. Decide whether a policy header is required.
   - Conditions: `CA_REQUEST_ID` = `01ACLM` (claim) versus any other request type.
   - Actions: Skip header creation for claims; create it for all other request types.
   - Outcomes: Only genuine policy requests produce a policy header.
   - Relevant Procedures: LGAPDB01, INSERT_POLICY

2. Insert the policy header with system-assigned identity and timestamp.
   - Conditions: Request is a non-claim request.
   - Actions: Insert a record in the POLICY table with customer, issue date (`CA_ISSUE_DATE`), expiry date (`CA_EXPIRY_DATE`), policy type (`DB2_POLICYTYPE`), broker details (`CA_BROKERSREF`) and premium payment. The policy number is system-generated and the last-changed timestamp is set to the current time.
   - Outcomes: A uniquely numbered policy header exists, to which type-specific details are linked.
   - Relevant Procedures: INSERT_POLICY

##### 3.1.1.3 Business Significance
The generated policy number is the key for all subsequent detail records. A missing or duplicate header breaks the link between policy and details, and incorrect dates or broker references affect coverage validity, renewal processing and broker commission attribution.

---

### 3.2 SubFunction: Product-Specific Detail Creation

#### 3.2.1 Business Rule: Route Request to Type-Specific Detail Creation

##### 3.2.1.1 Purpose
After classification and header creation, the details specific to the product, or the claim itself, are recorded in the table appropriate to the request type. Unknown request types are flagged with a failure code as a safeguard.

##### 3.2.1.2 Rule Steps
1. Select the detail record to be created from the request type.
   - Conditions: `CA_REQUEST_ID` = `01AEND`, `01AHOU`, `01AMOT`, `01ACOM` or `01ACLM`.
   - Actions: Create, respectively, an endowment, house, motor, commercial or claim record.
   - Outcomes: Exactly one type-specific record is created for each valid request.
   - Relevant Procedures: LGAPDB01, INSERT_ENDOW, INSERT_HOUSE, INSERT_MOTOR, INSERT_COMMERCIAL, INSERT_CLAIM

2. Flag unknown request types.
   - Conditions: `CA_REQUEST_ID` is not one of the supported values.
   - Actions: Set return code 99.
   - Outcomes: No detail record is created and the failure is signalled to the caller.
   - Relevant Procedures: LGAPDB01

##### 3.2.1.3 Business Significance
Wrong routing would store details in the wrong product table or leave a header without details, which results in policies that cannot be priced, serviced or claimed on.

---

#### 3.2.2 Business Rule: Endowment Policy Detail Recording

##### 3.2.2.1 Purpose
Records the endowment-specific information for the policy. Additional padding data carried by the incoming request is preserved when present.

##### 3.2.2.2 Rule Steps
1. Choose the storage variant based on extra incoming data.
   - Conditions: The communication area carries data beyond the required length.
   - Actions: Store the endowment with the padding data; otherwise store it without. Term (`CA_E_TERM`) and sum assured (`CA_E_SUM_ASSURED`) are stored in their integer forms.
   - Outcomes: An endowment record linked to the policy exists, with any supplementary data retained.
   - Relevant Procedures: INSERT_ENDOW

##### 3.2.2.3 Business Significance
Term and sum assured determine maturity benefits and liabilities. Loss of the supplementary data or incorrect numeric conversion would misstate the contract.

---

#### 3.2.3 Business Rule: Property and Vehicle Policy Detail Recording (House and Motor)

##### 3.2.3.1 Purpose
Records the risk details for house and motor policies and links them to the policy number, so that cover can be assessed and serviced.

##### 3.2.3.2 Rule Steps
1. Record house details.
   - Conditions: Request is `01AHOU`.
   - Actions: Insert a house record linked to the policy number with property type, bedrooms, value (`CA_H_VALUE` stored in integer form) and address.
   - Outcomes: The house risk is captured against the policy.
   - Relevant Procedures: INSERT_HOUSE

2. Record motor details.
   - Conditions: Request is `01AMOT`.
   - Actions: Insert a motor record linked to the policy number with vehicle details including registration (`CA_M_REGNUMBER`), premium and accident history.
   - Outcomes: The vehicle risk is captured against the policy.
   - Relevant Procedures: INSERT_MOTOR

##### 3.2.3.3 Business Significance
Insured value, vehicle identity and accident history underpin underwriting and claim validation. Errors misstate the insured risk and may lead to wrong payouts or disputes.

---

#### 3.2.4 Business Rule: Commercial Policy Detail Recording

##### 3.2.4.1 Purpose
Persists the commercial property cover, including the location, the peril coverages (fire, crime, flood, weather), the premium for each peril and the approval status, tied to the policy and its term.

##### 3.2.4.2 Rule Steps
1. Store commercial policy details for the policy term.
   - Conditions: Request is `01ACOM`.
   - Actions: Insert a record in the COMMERCIAL table associated with the generated policy number, with the policy term from `CA_ISSUE_DATE` and `CA_EXPIRY_DATE`, property location, peril coverages, individual peril premiums and approval status.
   - Outcomes: The commercial cover is fully recorded and linked to the policy.
   - Relevant Procedures: INSERT_COMMERCIAL

##### 3.2.4.3 Business Significance
Peril premiums and approval status determine what is covered and charged. Mistakes would cause incorrect billing or coverage disputes.

---

### 3.3 SubFunction: Claim Registration

#### 3.3.1 Business Rule: Register Insurance Claim Against a Policy

##### 3.3.1.1 Purpose
Records a new claim as a standalone record (without a policy header) linked to the policy it is made against, capturing the financial and descriptive details required for claim handling.

##### 3.3.1.2 Rule Steps
1. Create the claim record.
   - Conditions: Request is `01ACLM`.
   - Actions: Insert a record in the CLAIM table with claim identification, the associated policy number, claim date, cause and observations.
   - Outcomes: A claim is registered against the specified policy.
   - Relevant Procedures: INSERT_CLAIM

2. Record claim financial amounts.
   - Conditions: Claim record is being created.
   - Actions: Store the settlement amount paid and the estimated total claim value.
   - Outcomes: The claim carries its financial position for settlement and reserving.
   - Relevant Procedures: INSERT_CLAIM

##### 3.3.1.3 Business Significance
Claim amounts and the policy link drive settlement, reserving and fraud review. An incorrect link or amount leads to wrongful or misdirected payments and misstated liabilities.

---

Generated by IBM Bob Premium Package for Z
