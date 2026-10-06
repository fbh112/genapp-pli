 /*********************************************************************/00010000
 /*                                                                   */00020000
 /*   LICENSED MATERIALS - PROPERTY OF IBM                            */00030001
 /*                                                                   */00040000
 /*   "RESTRICTED MATERIALS OF IBM"                                   */00050001
 /*                                                                   */00060000
 /*   CB12                                                            */00061001
 /*                                                                   */00062001
 /*   (C) COPYRIGHT IBM CORP. 2011, 2013 ALL RIGHTS RESERVED          */00063001
 /*                                                                   */00064001
 /*   US GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION,       */00065001
 /*   OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE                    */00066001
 /*   CONTRACT WITH IBM CORPORATION                                   */00067001
 /*                                                                   */00068001
 /*                                                                   */00069001
 /*    COPYBOOK for Business Rule processing                          */00069101
 /*                                                                   */00069201
 /*   This copybook is used to pass the Endowment policy data         */00069301
 /*   structure to the LGAPBR01 program                               */00069401
 /*                                                                   */00069501
 /*   CHANGE HISTORY:                                                 */00069601
 /*********************************************************************/00071001
 DCL RQST_AREA_PTR PTR;                                                 00080001
                                                                        00090000
 DCL 1 REQUEST  UNION  BASED(RQST_AREA_PTR),                            00100001
      2 RQST_AREA_RAW            CHAR(152),                             00110001
      2 POLICY,                                                         00112001
       3 REQUEST_ID               CHAR(6),                              00130001
       3 RET-CODE                 PIC '99',                             00140001
       3 CUSTOMER_NUM             PIC '9999999999',                     00150001
       3 POLICY_NUM               PIC '9999999999',                     00160001
       3 ISSUE_DATE               CHAR(10),                             00170001
       3 EXPIRY_DATE              CHAR(10),                             00180001
       3 LASTCHANGED              CHAR(26),                             00190001
       3 BROKERID                 PIC '9999999999',                     00200001
       3 BROKERSREF               CHAR(10),                             00210001
       3 PAYMENT                  PIC '999999',                         00220001
       3 WITH_PROFITS             CHAR,                                 00230001
       3 EQUITIES                 CHAR,                                 00240001
       3 MANAGED_FUND             CHAR,                                 00250001
       3 FUND_NAME                CHAR(10),                             00260001
       3 TERM                     PIC '99',                             00270001
       3 SUM_ASSURED              PIC '999999',                         00280001
       3 LIFE_ASSURED             CHAR(31);                             00290001
                                                                        00301001
 DCL RSPN_AREA_PTR PTR;                                                 00302001
                                                                        00310001
 DCL 1 RESPONSE  UNION BASED(RSPN_AREA_PTR),                            00320001
      2 RSPN_AREA_RAW             CHAR(41),                             00330001
      2 *,                                                              00340001
       3 PROCESSED                CHAR,                                 00350001
       3 MSG                      CHAR(40);                             00360001