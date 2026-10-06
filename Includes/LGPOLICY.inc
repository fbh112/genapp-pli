 /*********************************************************************/00010001
 /*               COPYBOOK for Policy details                         */00020001
 /*                                                                   */00030001
 /*   Structures to map values obtained from DB2 tables:              */00040001
 /*   Customer, Policy, Endowment, House and Motor,                   */00050001
 /*                                                                   */00060001
 /*   All lengths of policy fields will be defined here so that       */00070001
 /*   if any of the DB2 table contents change the lengths will        */00080001
 /*   only need to be changed here,                                   */00090001
 /*                                                                   */00100001
 /*********************************************************************/00110001
 DCL 1 WS_POLICY_LENGTHS,                                               00120001
       3 WS_CUSTOMER_LEN          FIXED BIN(15) INIT(72),               00130001
       3 WS_POLICY_LEN            FIXED BIN(15) INIT(72),               00140001
       3 WS_ENDOW_LEN             FIXED BIN(15) INIT(52),               00150001
       3 WS_HOUSE_LEN             FIXED BIN(15) INIT(58),               00160001
       3 WS_MOTOR_LEN             FIXED BIN(15) INIT(65),               00170001
       3 WS_COMM_LEN              FIXED BIN(15) INIT(1102),             00180001
       3 WS_CLAIM_LEN             FIXED BIN(15) INIT(546),              00190001
       3 WS_FULL_ENDOW_LEN        FIXED BIN(15) INIT(124),              00200001
       3 WS_FULL_HOUSE_LEN        FIXED BIN(15) INIT(130),              00210001
       3 WS_FULL_MOTOR_LEN        FIXED BIN(15) INIT(137),              00220001
       3 WS_FULL_COMM_LEN         FIXED BIN(15) INIT(1174),             00230001
       3 WS_FULL_CLAIM_LEN        FIXED BIN(15) INIT(618),              00240001
       3 WS_SUMRY_ENDOW_LEN       FIXED BIN(15) INIT(25);               00250001
                                                                        00260001
 DCL 1 DB2_CUSTOMER,                                                    00270001
       3 DB2_FIRSTNAME            CHAR(10),                             00280001
       3 DB2_LASTNAME             CHAR(20),                             00290001
       3 DB2_DATEOFBIRTH          CHAR(10),                             00300001
       3 DB2_HOUSENAME            CHAR(20),                             00310001
       3 DB2_HOUSENUMBER          CHAR(4),                              00320001
       3 DB2_POSTCODE             CHAR(8),                              00330001
       3 DB2_PHONE_MOBILE         CHAR(20),                             00340001
       3 DB2_PHONE_HOME           CHAR(20),                             00350001
       3 DB2_EMAIL_ADDRESS        CHAR(100);                            00360001
                                                                        00370001
 DCL 1 DB2_POLICY,                                                      00380001
       3 DB2_POLICYTYPE           CHAR INIT(''),                        00390001
       3 DB2_POLICYNUMBER         PIC '(10)9' INIT(0),                  00400001
       3 DB2_POLICY_COMMON,                                             00410001
         5 DB2_ISSUEDATE         CHAR(10) INIT(''),                     00420001
         5 DB2_EXPIRYDATE        CHAR(10) INIT(''),                     00430001
         5 DB2_LASTCHANGED       CHAR(26) INIT(''),                     00440001
         5 DB2_BROKERID          PIC '(10)9' INIT(0),                   00450001
         5 DB2_BROKERSREF        CHAR(10) INIT(''),                     00460001
         5 DB2_PAYMENT           PIC '(6)9' INIT(0);                    00470001
                                                                        00480001
 DCL 1 DB2_ENDOWMENT UNION,                                             00490001
       3 DB2_ENDOW_TEXT          CHAR(32663),                           00500001
       3 DB2_ENDOW_DATA,                                                00501001
         4 DB2_ENDOW_FIXED,                                             00502001
           5 DB2_E_WITHPROFITS   CHAR INIT(''),                         00503001
           5 DB2_E_EQUITIES      CHAR INIT(''),                         00504001
           5 DB2_E_MANAGEDFUND   CHAR INIT(''),                         00505001
           5 DB2_E_FUNDNAME      CHAR(10) INIT(''),                     00506001
           5 DB2_E_TERM          PIC '(2)9' INIT(0),                    00507001
           5 DB2_E_SUMASSURED    PIC '(6)9' INIT(0),                    00508001
           5 DB2_E_LIFEASSURED   CHAR(31) INIT(''),                     00509001
         4 DB2_E_PADDINGDATA     CHAR(32611) INIT('');                  00510001
                                                                        00520001
 DCL 1 DB2_HOUSE UNION,                                                 00530001
       3 DB2_HOUSE_TEXT          CHAR(73),                              00540001
       3 DB2_HOUSE_DATA,                                                00550001
         4 DB2_HOUSE_TEXTTYPE    CHAR(15) INIT(''),                     00560001
         4 DB2_H_PROPERTYTYPE    CHAR(15) INIT(''),                     00570001
         4 DB2_H_BEDROOMS        PIC '(3)9' INIT(0),                    00580001
         4 DB2_H_VALUE           PIC '(8)9' INIT(0),                    00590001
         4 DB2_H_HOUSENAME       CHAR(20) INIT(''),                     00600001
         4 DB2_H_HOUSENUMBER     CHAR(4) INIT(''),                      00610001
         4 DB2_H_POSTCODE        CHAR(8) INIT('');                      00620001
                                                                        00630001
 DCL 1 DB2_MOTOR UNION,                                                 00640001
       3 DB2_MOTOR_TEXT          CHAR(77),                              00650001
       3 DB2_MOTOR_DATA,                                                00660001
         4 DB2_M_MAKE            CHAR(15) INIT(''),                     00670001
         4 DB2_M_MODEL           CHAR(15) INIT(''),                     00680001
         4 DB2_M_VALUE           PIC '(6)9' INIT(0),                    00690001
         4 DB2_M_REGNUMBER       CHAR(7) INIT(''),                      00700001
         4 DB2_M_COLOUR          CHAR(8) INIT(''),                      00710001
         4 DB2_M_CC              PIC '(4)9' INIT(0),                    00720001
         4 DB2_M_MANUFACTURED    CHAR(10) INIT(''),                     00730001
         4 DB2_M_PREMIUM         PIC '(6)9' INIT(0),                    00740001
         4 DB2_M_ACCIDENTS       PIC '(6)9' INIT(0);                    00750001
                                                                        00760001
 DCL 1 DB2_COMMERCIAL UNION,                                            00770001
       3 DB2_COMM_TEXT              CHAR(1102),                         00780001
       3 DB2_COMM_DATA,                                                 00790001
         4 DB2_B_Address            CHAR(255) INIT(''),                 00800001
         4 DB2_B_Postcode           CHAR(8) INIT(''),                   00810001
         4 DB2_B_Latitude           CHAR(11) INIT(''),                  00820001
         4 DB2_B_Longitude          CHAR(11) INIT(''),                  00830001
         4 DB2_B_Customer           CHAR(255) INIT(''),                 00840001
         4 DB2_B_PropType           CHAR(255) INIT(''),                 00850001
         4 DB2_B_FirePeril          PIC '(4)9' INIT(0),                 00860001
         4 DB2_B_FirePremium        PIC '(8)9' INIT(0),                 00870001
         4 DB2_B_CrimePeril         PIC '(4)9' INIT(0),                 00880001
         4 DB2_B_CrimePremium       PIC '(8)9' INIT(0),                 00890001
         4 DB2_B_FloodPeril         PIC '(4)9' INIT(0),                 00900001
         4 DB2_B_FloodPremium       PIC '(8)9' INIT(0),                 00910001
         4 DB2_B_WeatherPeril       PIC '(4)9' INIT(0),                 00920001
         4 DB2_B_WeatherPremium     PIC '(8)9' INIT(0),                 00930001
         4 DB2_B_Status             PIC '(4)9' INIT(0),                 00940001
         4 DB2_B_RejectReason       CHAR(255) INIT('');                 00950001
                                                                        00960001
 DCL 1 DB2_CLAIM UNION,                                                 00970001
       3 DB2_CLAIM_TEXT           CHAR(556),                            00980001
       3 DB2_CLAIM_DATA,                                                00981001
         4 DB2_C_Num              PIC '(10)9' INIT(0),                  00982001
         4 DB2_C_Date             CHAR(10) INIT(''),                    00983001
         4 DB2_C_Paid             PIC '(8)9' INIT(0),                   00984001
         4 DB2_C_Value            PIC '(8)9' INIT(0),                   00985001
         4 DB2_C_Cause            CHAR(255) INIT(''),                   00986001
         4 DB2_C_Observations     CHAR(255) INIT('');                   00987001