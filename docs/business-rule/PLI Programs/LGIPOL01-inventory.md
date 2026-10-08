# Business rules: Inventory

**Program:** LGIPOL01

**Total rules extracted:** 3

## Table of Contents

- [1. Purpose](#1-purpose)
- [2. Rule Inventory](#2-rule-inventory)
  - [2.1 Procedure: LGIPOL01](#21-procedure-lgipol01)

## 1. Purpose

This document is an inventory of all business rules extracted from LGIPOL01, organised at the Procedure level. Each Procedure contributes one or more named rule blocks, where each block captures a discrete business policy with its title, decision logic, conditions, actions, outcomes, and the exact source code that realises it. Key variables, when available, are annotated with their role (input or output) and their specific purpose within the rule. References to related Procedures called or invoked by each rule are also recorded.

## 2. Rule Inventory

### 2.1 Procedure: LGIPOL01

#### 2.1.1 Initialize Policy Inquiry Return Code

<<<<<<< Updated upstream
**Description:** Sets the communication area return code to '00' at the start of policy inquiry processing, indicating an initially successful status to the calling program.

**Core decision logic:**
- The default outcome of a policy inquiry is success ('00') until an error is encountered
=======
**Description:** Sets the communication area return code to '00' at the start of processing, indicating a successful initial state for the policy inquiry transaction.

**Core decision logic:**
- Return code is initialized to '00' to signal a successful starting state before any processing occurs
>>>>>>> Stashed changes

**Code:**
```pl1
CA_RETURN_CODE = '00';
```

**Variables:**

| Variable name | Role | Purpose |
|---|---|---|
<<<<<<< Updated upstream
| `CA_RETURN_CODE` | output | Initialized to '00' to signal a successful start of the policy inquiry operation to the calling program |

#### 2.1.2 Link to Policy Database Retrieval Program

**Description:** Invokes the back-end database program LGIPDB01 via a CICS LINK call, passing the full communication area, to retrieve the requested insurance policy record from DB2 based on the customer and policy numbers provided.

**Core decision logic:**
- Policy data retrieval is delegated to the dedicated database program LGIPDB01
- The full communication area including customer number and policy number is passed to the database program for policy lookup
=======
| `CA_RETURN_CODE` | output | Receives the initial success value '00' to indicate no errors have occurred at the start of policy inquiry processing |

#### 2.1.2 Link to Policy Database Retrieval Program

**Description:** Invokes the back-end database program LGIPDB01 via a CICS LINK command to retrieve the full policy details from DB2 for the customer and policy number provided in the communication area.

**Core decision logic:**
- The back-end program LGIPDB01 is responsible for performing the actual DB2 policy inquiry
- The full communication area is passed to the database program to carry both request parameters and receive policy details
>>>>>>> Stashed changes

**Code:**
```pl1
EXEC CICS LINK Program(LGIPDB01)
           Commarea(COMM_AREA)
           Length(32000);
```

**Variables:**

| Variable name | Role | Purpose |
|---|---|---|
<<<<<<< Updated upstream
| `LGIPDB01` | input | Identifies the back-end database program to be invoked via CICS LINK for performing the DB2 policy inquiry |
| `CA_CUSTOMER_NUM` | input | Passed within the communication area to LGIPDB01 to identify the customer whose policy is being retrieved |
| `CA_POLICY_NUM` | input | Passed within the communication area to LGIPDB01 to identify the specific policy to be retrieved |

#### 2.1.3 Override Policy Expiry Date for Honda Motor Vehicles

**Description:** Applies a special business rule that overrides the policy expiry date to a far-future date of 2099-01-01 when the insured motor vehicle's make is 'HONDA'. This rule effectively grants indefinite or extended coverage for Honda motor policies.

**Core decision logic:**
- Motor policies for Honda vehicles receive a special extended expiry date of 2099-01-01 regardless of the originally stored expiry date
- The vehicle make 'HONDA' is the trigger condition for this expiry date override business rule
=======
| `LGIPDB01` | input | Provides the name of the back-end database program to be invoked via CICS LINK to perform the DB2 policy retrieval |
| `CA_CUSTOMER_NUM` | input | Carried within the communication area passed to LGIPDB01 to identify the customer whose policy is being inquired upon |
| `CA_POLICY_NUM` | input | Carried within the communication area passed to LGIPDB01 to identify the specific policy to be retrieved |

#### 2.1.3 Honda Vehicle Policy Expiry Date Override

**Description:** Applies a special business rule that overrides the policy expiry date to '2099-01-01' when the insured motor vehicle make is 'HONDA', granting an effectively indefinite policy term for Honda vehicles.

**Core decision logic:**
- Motor policies where the vehicle make is 'HONDA' receive a special expiry date of '2099-01-01', effectively extending the policy indefinitely
- This override is applied after policy data retrieval, replacing whatever expiry date was returned from the database
>>>>>>> Stashed changes

**Code:**
```pl1
IF CA_M_MAKE = 'HONDA' THEN
   CA_EXPIRY_DATE = '2099-01-01';
```

**Variables:**

| Variable name | Role | Purpose |
|---|---|---|
<<<<<<< Updated upstream
| `CA_M_MAKE` | input | Evaluated to determine whether the insured vehicle is a Honda, which triggers the expiry date override rule |
| `CA_EXPIRY_DATE` | output | Overridden to '2099-01-01' when the vehicle make is 'HONDA', extending the policy's effective coverage period |
=======
| `CA_M_MAKE` | input | Tested against the value 'HONDA' to determine whether the special expiry date override business rule should be applied |
| `CA_EXPIRY_DATE` | output | Receives the overridden expiry date value of '2099-01-01' when the insured vehicle make is 'HONDA' |
>>>>>>> Stashed changes

---

Generated by IBM Bob Premium Package for Z
