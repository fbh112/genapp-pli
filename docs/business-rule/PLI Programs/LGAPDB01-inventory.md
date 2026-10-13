# Business rules: Inventory

**Program:** LGAPDB01

**Total rules extracted:** 9

## Table of Contents

- [1. Purpose](#1-purpose)
- [2. Rule Inventory](#2-rule-inventory)
  - [2.1 Procedure: LGAPDB01](#21-procedure-lgapdb01)
  - [2.2 Procedure: INSERT_POLICY](#22-procedure-insert_policy)
  - [2.3 Procedure: INSERT_ENDOW](#23-procedure-insert_endow)
  - [2.4 Procedure: INSERT_HOUSE](#24-procedure-insert_house)
  - [2.5 Procedure: INSERT_MOTOR](#25-procedure-insert_motor)
  - [2.6 Procedure: INSERT_COMMERCIAL](#26-procedure-insert_commercial)
  - [2.7 Procedure: INSERT_CLAIM](#27-procedure-insert_claim)

## 1. Purpose

This document is an inventory of all business rules extracted from LGAPDB01, organised at the Procedure level. Each Procedure contributes one or more named rule blocks, where each block captures a discrete business policy with its title, decision logic, conditions, actions, outcomes, and the exact source code that realises it. Key variables, when available, are annotated with their role (input or output) and their specific purpose within the rule. References to related Procedures called or invoked by each rule are also recorded.

## 2. Rule Inventory

### 2.1 Procedure: LGAPDB01

#### 2.1.1 Request type mapping to policy type and required commarea length

**Description:** Interprets the request identifier to determine which kind of policy is being added (Endowment, House, Motor, Commercial or Claim) and sets the corresponding policy type code. Unrecognized request types are rejected with a return code of 99 and processing ends.

**Core decision logic:**
- 01AEND maps to policy type 'E' (Endowment)
- 01AHOU maps to policy type 'H' (House)
- 01AMOT maps to policy type 'M' (Motor)
- 01ACOM maps to policy type 'C' (Commercial)
- 01ACLM maps to policy type 'X' (Claim)
- Any other request ID is rejected with return code 99

**Code:**
```pl1
  SELECT (CA_REQUEST_ID);                                                       
                                                                                
    WHEN ('01AEND') DO;                                                         
      WS_REQUIRED_CA_LEN = WS_FULL_ENDOW_LEN + WS_REQUIRED_CA_LEN;              
      DB2_POLICYTYPE = 'E';                                                     
    END;                                                                        
                                                                                
    WHEN ('01AHOU') DO;                                                         
      WS_REQUIRED_CA_LEN = WS_FULL_HOUSE_LEN + WS_REQUIRED_CA_LEN;              
      DB2_POLICYTYPE = 'H';                                                     
    END;                                                                        
                                                                                
    WHEN ('01AMOT') DO;                                                         
      WS_REQUIRED_CA_LEN = WS_FULL_MOTOR_LEN + WS_REQUIRED_CA_LEN;              
      DB2_POLICYTYPE = 'M';                                                     
    END;                                                                        
                                                                                
    WHEN ('01ACOM') DO;                                                         
      DB2_POLICYTYPE = 'C';                                                     
    END;                                                                        
                                                                                
    WHEN ('01ACLM') DO;                                                         
      DB2_POLICYTYPE = 'X';                                                     
    END;                                                                        
                                                                                
    OTHERWISE DO;                                                               
      CA_RETURN_CODE = '99';                                                    
      EXEC CICS RETURN;                                                         
    END;                                                                        
                                                                                
  END; /* SELECT (CA_REQUEST_ID) */
```

**Variables:**

| Variable name | Role | Purpose |
|---|---|---|
| `CA_REQUEST_ID` | input | Identifies the requested transaction type that determines the policy type. |
| `DB2_POLICYTYPE` | output | Receives the single-character policy classification code derived from the request ID. |

#### 2.1.2 Policy table insert for non-claim requests

**Description:** Creates a general policy record for every request except claims, since claims are not policies and have no policy header row.

**Core decision logic:**
- Claim requests (01ACLM) skip the policy record creation
- All other request types create a policy record

**Code:**
```pl1
  If (CA_REQUEST_ID <> '01ACLM') THEN DO;                                       
    CALL INSERT_POLICY;                                                         
  END;
```

**Variables:**

| Variable name | Role | Purpose |
|---|---|---|
| `CA_REQUEST_ID` | input | Determines whether the request is a claim, which bypasses the policy insert. |

**Procedures:**

* INSERT_POLICY
#### 2.1.3 Dispatch to policy-type-specific insert

**Description:** Based on the request type, records the details specific to the policy type (endowment, house, motor, commercial) or the claim in the appropriate table. Unknown request types are flagged with return code 99.

**Core decision logic:**
- 01AEND creates an endowment policy record
- 01AHOU creates a house policy record
- 01AMOT creates a motor policy record
- 01ACOM creates a commercial policy record
- 01ACLM creates a claim record
- Unknown request types yield return code 99

**Code:**
```pl1
  SELECT (CA_REQUEST_ID);                                                       
                                                                                
    WHEN ('01AEND') DO;                                                         
      CALL INSERT_ENDOW;                                                        
    END;                                                                        
                                                                                
    WHEN ('01AHOU') DO;                                                         
      CALL INSERT_HOUSE;                                                        
    END;                                                                        
                                                                                
    WHEN ('01AMOT') DO;                                                         
      CALL INSERT_MOTOR;                                                        
    END;                                                                        
                                                                                
    WHEN ('01ACOM') DO;                                                         
      CALL INSERT_COMMERCIAL;                                                   
    END;                                                                        
                                                                                
    WHEN ('01ACLM') DO;                                                         
      CALL INSERT_CLAIM;                                                        
    END;                                                                        
                                                                                
    OTHERWISE DO;                                                               
      CA_RETURN_CODE = '99';                                                    
    END;                                                                        
                                                                                
  END; /* SELECT (CA_REQUEST_ID) */
```

**Variables:**

| Variable name | Role | Purpose |
|---|---|---|
| `CA_REQUEST_ID` | input | Selects which type-specific insert routine is executed. |

**Procedures:**

* INSERT_ENDOW
* INSERT_HOUSE
* INSERT_MOTOR
* INSERT_COMMERCIAL
* INSERT_CLAIM
### 2.2 Procedure: INSERT_POLICY

#### 2.2.1 Insert new policy record

**Description:** Creates a new policy record in the POLICY table with customer, issue and expiry dates, policy type, broker details and premium payment. The policy number is system-assigned and the last-changed timestamp is set to the current time.

**Core decision logic:**
- A new policy is created with a system-generated policy number
- The last-changed timestamp is set to the current time at creation

**Code:**
```pl1
  EM_SQLREQ = ' INSERT POLICY';                                                 
  EXEC SQL                                                                      
        INSERT INTO POLICY                                                      
                  ( POLICYNUMBER,                                               
                    CUSTOMERNUMBER,                                             
                    ISSUEDATE,                                                  
                    EXPIRYDATE,                                                 
                    POLICYTYPE,                                                 
                    LASTCHANGED,                                                
                    BROKERID,                                                   
                    BROKERSREFERENCE,                                           
                    PAYMENT           )                                         
           VALUES ( DEFAULT,                                                    
                    :DB2_CUSTOMERNUM_INT,                                       
                    :CA_ISSUE_DATE,                                             
                    :CA_EXPIRY_DATE,                                            
                    :DB2_POLICYTYPE,                                            
                    CURRENT TIMESTAMP,                                          
                    :DB2_BROKERID_INT,                                          
                    :CA_BROKERSREF,                                             
                    :DB2_PAYMENT_INT      );
```

**Variables:**

| Variable name | Role | Purpose |
|---|---|---|
| `CA_ISSUE_DATE` | input | Policy inception date stored on the new policy record. |
| `CA_EXPIRY_DATE` | input | Policy expiry date stored on the new policy record. |
| `DB2_POLICYTYPE` | input | Classification of the policy inserted into the policy record. |
| `CA_BROKERSREF` | input | Broker reference stored with the policy. |

### 2.3 Procedure: INSERT_ENDOW

#### 2.3.1 Insert endowment policy details with optional padding data

**Description:** Creates the endowment record for the policy. If the incoming data contains extra padding data, it is stored with the record; otherwise the record is created without it.

**Core decision logic:**
- If the communication area carries extra data beyond the required length, the endowment is stored with padding data
- Otherwise the endowment is stored without padding data

**Code:**
```pl1
  WS_VARY_LEN = EIBCALEN - WS_REQUIRED_CA_LEN;                                  
                                                                                
  IF (WS_VARY_LEN > 0) THEN DO;                                                 
 /*       Commarea contains data for Varchar field */                           
     SUBSTR(WS_VARY_CHAR,1,WS_VARY_LEN) = CA_E_PADDING_DATA;                    
                                                                                
     EXEC SQL                                                                   
       INSERT INTO ENDOWMENT                                                    
                 ( POLICYNUMBER,                                                
                   WITHPROFITS,                                                 
                   EQUITIES,                                                    
                   MANAGEDFUND,                                                 
                   FUNDNAME,                                                    
                   TERM,                                                        
                   SUMASSURED,                                                  
                   LIFEASSURED,                                                 
                   PADDINGDATA    )                                             
          VALUES ( :DB2_POLICYNUM_INT,                                          
                   :CA_E_WITH_PROFITS,                                          
                   :CA_E_EQUITIES,                                              
                   :CA_E_MANAGED_FUND,                                          
                   :CA_E_FUND_NAME,                                             
                   :DB2_E_TERM_SINT,                                            
                   :DB2_E_SUMASSURED_INT,                                       
                   :CA_E_LIFE_ASSURED,                                          
                   :WS_VARY_FIELD );                                            
  END;                                                                          
  ELSE DO;                                                                      
     EXEC SQL                                                                   
       INSERT INTO ENDOWMENT                                                    
                 ( POLICYNUMBER,                                                
                   WITHPROFITS,                                                 
                   EQUITIES,                                                    
                   MANAGEDFUND,                                                 
                   FUNDNAME,                                                    
                   TERM,                                                        
                   SUMASSURED,                                                  
                   LIFEASSURED    )                                             
          VALUES ( :DB2_POLICYNUM_INT,                                          
                   :CA_E_WITH_PROFITS,                                          
                   :CA_E_EQUITIES,                                              
                   :CA_E_MANAGED_FUND,                                          
                   :CA_E_FUND_NAME,                                             
                   :DB2_E_TERM_SINT,                                            
                   :DB2_E_SUMASSURED_INT,                                       
                   :CA_E_LIFE_ASSURED );                                        
  END;
```

**Variables:**

| Variable name | Role | Purpose |
|---|---|---|
| `CA_E_TERM` | input | Endowment term stored through its integer form. |
| `CA_E_SUM_ASSURED` | input | Sum assured stored through its integer form. |

### 2.4 Procedure: INSERT_HOUSE

#### 2.4.1 Insert house policy details

**Description:** Creates the house insurance record for the policy, holding property type, bedrooms, value and address details.

**Core decision logic:**
- A house record is created and linked to the policy number

**Code:**
```pl1
  EM_SQLREQ = ' INSERT HOUSE ';                                                 
  EXEC SQL                                                                      
        INSERT INTO HOUSE                                                       
                  ( POLICYNUMBER,                                               
                    PROPERTYTYPE,                                               
                    BEDROOMS,                                                   
                    VALUE,                                                      
                    HOUSENAME,                                                  
                    HOUSENUMBER,                                                
                    POSTCODE          )                                         
           VALUES ( :DB2_POLICYNUM_INT,                                         
                    :CA_H_PROPERTY_TYPE,                                        
                    :DB2_H_BEDROOMS_SINT,                                       
                    :DB2_H_VALUE_INT,                                           
                    :CA_H_HOUSE_NAME,                                           
                    :CA_H_HOUSE_NUMBER,                                         
                    :CA_H_POSTCODE      );
```

**Variables:**

| Variable name | Role | Purpose |
|---|---|---|
| `CA_H_VALUE` | input | House value copied through its integer form into the house record. |

### 2.5 Procedure: INSERT_MOTOR

#### 2.5.1 Insert motor policy details

**Description:** Creates the motor insurance record for the policy, holding vehicle details, premium and accident history.

**Core decision logic:**
- A motor record is created and linked to the policy number

**Code:**
```pl1
  EM_SQLREQ = ' INSERT MOTOR ';                                                 
  EXEC SQL                                                                      
        INSERT INTO MOTOR                                                       
                  ( POLICYNUMBER,                                               
                    MAKE,                                                       
                    MODEL,                                                      
                    VALUE,                                                      
                    REGNUMBER,                                                  
                    COLOUR,                                                     
                    CC,                                                         
                    YEAROFMANUFACTURE,                                          
                    PREMIUM,                                                    
                    ACCIDENTS )                                                 
           VALUES ( :DB2_POLICYNUM_INT,                                         
                    :CA_M_MAKE,                                                 
                    :CA_M_MODEL,                                                
                    :DB2_M_VALUE_INT,                                           
                    :CA_M_REGNUMBER,                                            
                    :CA_M_COLOUR,                                               
                    :DB2_M_CC_SINT,                                             
                    :CA_M_MANUFACTURED,                                         
                    :DB2_M_PREMIUM_INT,                                         
                    :DB2_M_ACCIDENTS_INT );
```

**Variables:**

| Variable name | Role | Purpose |
|---|---|---|
| `CA_M_REGNUMBER` | input | Vehicle registration number stored in the motor record. |

### 2.6 Procedure: INSERT_COMMERCIAL

#### 2.6.1 Insert Commercial Policy Record

**Description:** Inserts a new commercial insurance policy record into the COMMERCIAL table, persisting property details, coverage perils, individual peril premiums, and approval status.

**Core decision logic:**
- Store commercial policy details including property location, peril coverages (fire, crime, flood, weather), and associated premiums
- Associate commercial policy record with the generated policy number and specified policy term dates

**Code:**
```pl1
  EXEC SQL                                                                      
        INSERT INTO COMMERCIAL                                                  
                  (                                                             
                    PolicyNumber,                                               
                    RequestDate,                                                
                    StartDate,                                                  
                    RenewalDate,                                                
                    Address,                                                    
                    Zipcode,                                                    
                    LatitudeN,                                                  
                    LongitudeW,                                                 
                    Customer,                                                   
                    PropertyType,                                               
                    FirePeril,                                                  
                    FirePremium,                                                
                    CrimePeril,                                                 
                    CrimePremium,                                               
                    FloodPeril,                                                 
                    FloodPremium,                                               
                    WeatherPeril,                                               
                    WeatherPremium,                                             
                    Status,                                                     
                    RejectionReason                                             
                                        )                                       
           VALUES (                                                             
                    :DB2_POLICYNUM_INT,                                         
                    :CA_LASTCHANGED,                                            
                    :CA_ISSUE_DATE,                                             
                    :CA_EXPIRY_DATE,                                            
                    :CA_B_Address,                                              
                    :CA_B_Postcode,                                             
                    :CA_B_Latitude,                                             
                    :CA_B_Longitude,                                            
                    :CA_B_Customer,                                             
                    :CA_B_PropType,                                             
                    :DB2_B_FirePeril_INT,                                       
                    :DB2_B_FirePremium_INT,                                     
                    :DB2_B_CrimePeril_INT,                                      
                    :DB2_B_CrimePremium_INT,                                    
                    :DB2_B_FloodPeril_INT,                                      
                    :DB2_B_FloodPremium_INT,                                    
                    :DB2_B_WeatherPeril_INT,                                    
                    :DB2_B_WeatherPremium_INT,                                  
                    :DB2_B_Status_INT,                                          
                    :CA_B_RejectReason                                          
                                        );
```

**Variables:**

| Variable name | Role | Purpose |
|---|---|---|
| `CA_ISSUE_DATE` | input | Supplies the inception start date for the commercial policy to be stored in the database. |
| `CA_EXPIRY_DATE` | input | Supplies the expiration renewal date for the commercial policy to be stored in the database. |

### 2.7 Procedure: INSERT_CLAIM

#### 2.7.1 Insert Insurance Claim Record

**Description:** Inserts a new insurance claim record into the CLAIM table with claim identification, associated policy number, claim date, settlement amount paid, estimated claim value, cause, and observations.

**Core decision logic:**
- Create a new claim record linked to the specified policy number
- Record claim financial amounts including paid settlement and total claim value alongside cause and observations

**Code:**
```pl1
  EXEC SQL                                                                      
        INSERT INTO CLAIM                                                       
                  (                                                             
                    ClaimNumber,                                                
                    PolicyNumber,                                               
                    ClaimDate,                                                  
                    Paid,                                                       
                    Value,                                                      
                    Cause,                                                      
                    Observations                                                
                                        )                                       
           VALUES (                                                             
                    :DB2_C_Num_INT,                                             
                    :DB2_C_Policynum_INT,                                       
                    :CA_C_Date,                                                 
                    :DB2_C_Paid_INT,                                            
                    :DB2_C_Value_INT,                                           
                    :CA_C_CAuse,                                                
                    :CA_C_Observations                                          
                                        );
```

---

Generated by IBM Bob Premium Package for Z
