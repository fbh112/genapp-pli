 /*********************************************************************/00010000
 /*                                                                   */00020000
 /*               COPYBOOK for COMMAREA structure                     */00030000
 /*                                                                   */00040000
 /*   This commarea can be used for all functions                     */00050000
 /*                                                                   */00060000
 /*********************************************************************/00070000
 DCL COMM_AREA_PTR PTR;                                                 00080000
                                                                        00090000
 DCL 1 COMM_AREA UNION BASED(COMM_AREA_PTR),                            00100004
      2 COMM_AREA_RAW            CHAR(32500),                           00110004
 /* DCL 1 COMM_AREA BASED(COMM_AREA_PTR), */                            00111004
      2 *,                                                              00112004
       3 CA_REQUEST_ID            CHAR(6),                              00130001
       3 CA_RETURN_CODE           PIC '99',                             00140001
       3 CA_CUSTOMER_NUM          PIC '9999999999',                     00150001
       3 CA_REQUEST_SPECIFIC      UNION,                                00160001
         5 CA_REQUEST_INITIALISER CHAR(32482),                          00170001
         /* Fields used in INQ All and ADD customer */                  00180001
         5 CA_CUSTOMER_REQUEST,                                         00190001
           7 CA_FIRST_NAME        CHAR(10),                             00200001
           7 CA_LAST_NAME         CHAR(20),                             00210001
           7 CA_DOB               CHAR(10),                             00220001
           7 CA_HOUSE_NAME        CHAR(20),                             00230001
           7 CA_HOUSE_NUM         CHAR(4),                              00240001
           7 CA_POSTCODE          CHAR(8),                              00250001
           7 CA_NUM_POLICIES      PIC '999',                            00260001
           7 CA_PHONE_MOBILE      CHAR(20),                             00270001
           7 CA_PHONE_HOME        CHAR(20),                             00280001
           7 CA_EMAIL_ADDRESS     CHAR(100),                            00290001
           7 CA_POLICY_DATA       CHAR(32267),                          00300001
         /* Fields used in Customer security call */                    00310001
         5 CA_CUSTSECR_REQUEST,                                         00320001
           7 CA_CUSTSECR_PASS      CHAR(32),                            00330001
           7 CA_CUSTSECR_COUNT     CHAR(4),                             00340001
           7 CA_CUSTSECR_STATE     CHAR,                                00350001
           7 CA_CUSTSECR_DATA      CHAR(32445),                         00360001
         /* Fields used in INQ, UPD, ADD & DELETE policy */             00370001
         5 CA_POLICY_REQUEST,                                           00380001
           7 CA_POLICY_NUM         PIC '9999999999',                    00390001
           /* Common policy details */                                  00400001
           7 CA_POLICY_COMMON,                                          00410001
             9 CA_ISSUE_DATE      CHAR(10),                             00420001
             9 CA_EXPIRY_DATE     CHAR(10),                             00430001
             9 CA_LASTCHANGED     CHAR(26),                             00440001
             9 CA_BROKERID        PIC '9999999999',                     00450001
             9 CA_BROKERSREF      CHAR(10),                             00460001
             9 CA_PAYMENT         PIC '999999',                         00470001
             9 CA_POLICY_SPECIFIC UNION,                                00481001
               11 CA_POLICY_RAW            CHAR(32400),                 00482005
               /* Endowment policy description */                       00490005
               11 CA_ENDOWMENT,                                         00510001
                  13 CA_E_WITH_PROFITS     CHAR,                        00520001
                  13 CA_E_EQUITIES         CHAR,                        00530001
                  13 CA_E_MANAGED_FUND     CHAR,                        00540001
                  13 CA_E_FUND_NAME        CHAR(10),                    00550001
                  13 CA_E_TERM             PIC '99',                    00560001
                  13 CA_E_SUM_ASSURED      PIC '999999',                00570001
                  13 CA_E_LIFE_ASSURED     CHAR(31),                    00580001
                  13 CA_E_PADDING_DATA     CHAR(32348),                 00590003
               /* House policy description */                           00600005
               11 CA_HOUSE,                                             00620001
                  13 CA_H_PROPERTY_TYPE    CHAR(15),                    00630001
                  13 CA_H_BEDROOMS         PIC '999',                   00640001
                  13 CA_H_VALUE            PIC '99999999',              00650001
                  13 CA_H_HOUSE_NAME       CHAR(20),                    00660001
                  13 CA_H_HOUSE_NUMBER     CHAR(4),                     00670001
                  13 CA_H_POSTCODE         CHAR(8),                     00680001
                  13 CA_H_FILLER           CHAR(32342),                 00690003
 /* Motor policy description */                                         00700000
               11 CA_MOTOR,                                             00720001
                  13 CA_M_MAKE             CHAR(15),                    00730001
                  13 CA_M_MODEL            CHAR(15),                    00740001
                  13 CA_M_VALUE            PIC '999999',                00750001
                  13 CA_M_REGNUMBER        CHAR(7),                     00760001
                  13 CA_M_COLOUR           CHAR(8),                     00770001
                  13 CA_M_CC               PIC '9999',                  00780001
                  13 CA_M_MANUFACTURED     CHAR(10),                    00790001
                  13 CA_M_PREMIUM          PIC '999999',                00800001
                  13 CA_M_ACCIDENTS        PIC '999999',                00810001
                  13 CA_M_FILLER           CHAR(32323),                 00820003
 /* Commercial policy description */                                    00830000
               11 CA_COMMERCIAL,                                        00850001
                  13 CA_B_Address          CHAR(255),                   00860001
                  13 CA_B_Postcode         CHAR(8),                     00870001
                  13 CA_B_Latitude         CHAR(11),                    00880001
                  13 CA_B_Longitude        CHAR(11),                    00890001
                  13 CA_B_Customer         CHAR(255),                   00900001
                  13 CA_B_PropType         CHAR(255),                   00910001
                  13 CA_B_FirePeril        PIC '9999',                  00920001
                  13 CA_B_FirePremium      PIC '99999999',              00930001
                  13 CA_B_CrimePeril       PIC '9999',                  00940001
                  13 CA_B_CrimePremium     PIC '99999999',              00950001
                  13 CA_B_FloodPeril       PIC '9999',                  00960001
                  13 CA_B_FloodPremium     PIC '99999999',              00970001
                  13 CA_B_WeatherPeril     PIC '9999',                  00980001
                  13 CA_B_WeatherPremium   PIC '99999999',              00990001
                  13 CA_B_Status           PIC '9999',                  01000001
                  13 CA_B_RejectReason     CHAR(255),                   01010001
                  13 CA_B_FILLER           CHAR(31298),                 01020003
 /* CLAIM policy description */                                         01030000
               11 CA_CLAIM,                                             01050001
                  13 CA_C_Num              PIC '9999999999',            01060001
                  13 CA_C_Date             CHAR(10),                    01070001
                  13 CA_C_Paid             PIC '99999999',              01080001
                  13 CA_C_Value            PIC '99999999',              01090001
                  13 CA_C_Cause            CHAR(255),                   01100001
                  13 CA_C_Observations     CHAR(255),                   01110001
                  13 CA_C_FILLER           CHAR(31854);                 01120001