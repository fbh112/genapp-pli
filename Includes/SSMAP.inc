 DECLARE 1 SSMAPC1I AUTOMATIC UNALIGNED,                                00010000
       2  DFHMS1 CHARACTER (12),                                        00020000
      2  ENT1CNOL    FIXED BINARY (15,0),                               00030000
      2  ENT1CNOF    CHARACTER (1),                                     00040000
      2  ENT1CNOI  CHARACTER (10),                                      00050000
      2  ENT1FNAL    FIXED BINARY (15,0),                               00060000
      2  ENT1FNAF    CHARACTER (1),                                     00070000
      2  ENT1FNAI  CHARACTER (10),                                      00080000
      2  ENT1LNAL    FIXED BINARY (15,0),                               00090000
      2  ENT1LNAF    CHARACTER (1),                                     00100000
      2  ENT1LNAI  CHARACTER (20),                                      00110000
      2  ENT1DOBL    FIXED BINARY (15,0),                               00120000
      2  ENT1DOBF    CHARACTER (1),                                     00130000
      2  ENT1DOBI  CHARACTER (10),                                      00140000
      2  ENT1HNML    FIXED BINARY (15,0),                               00150000
      2  ENT1HNMF    CHARACTER (1),                                     00160000
      2  ENT1HNMI  CHARACTER (20),                                      00170000
      2  ENT1HNOL    FIXED BINARY (15,0),                               00180000
      2  ENT1HNOF    CHARACTER (1),                                     00190000
      2  ENT1HNOI  CHARACTER (4),                                       00200000
      2  ENT1HPCL    FIXED BINARY (15,0),                               00210000
      2  ENT1HPCF    CHARACTER (1),                                     00220000
      2  ENT1HPCI  CHARACTER (8),                                       00230000
      2  ENT1HP1L    FIXED BINARY (15,0),                               00240000
      2  ENT1HP1F    CHARACTER (1),                                     00250000
      2  ENT1HP1I  CHARACTER (20),                                      00260000
      2  ENT1HP2L    FIXED BINARY (15,0),                               00270000
      2  ENT1HP2F    CHARACTER (1),                                     00280000
      2  ENT1HP2I  CHARACTER (20),                                      00290000
      2  ENT1HMOL    FIXED BINARY (15,0),                               00300000
      2  ENT1HMOF    CHARACTER (1),                                     00310000
      2  ENT1HMOI  CHARACTER (27),                                      00320000
      2  ENT1OPTL    FIXED BINARY (15,0),                               00330000
      2  ENT1OPTF    CHARACTER (1),                                     00340000
      2  ENT1OPTI  CHARACTER (1),                                       00350000
      2  ERRFLDL    FIXED BINARY (15,0),                                00360000
      2  ERRFLDF    CHARACTER (1),                                      00370000
      2  ERRFLDI  CHARACTER (40),                                       00380000
      2 FILL0101  CHARACTER (1);                                        00390000
 DECLARE 1 SSMAPC1O BASED(ADDR(SSMAPC1I)) UNALIGNED,                    00400000
       2  DFHMS2 CHARACTER (12),                                        00410000
      2  DFHMS3 FIXED BINARY (15,0),                                    00420000
      2  ENT1CNOA    CHARACTER (1),                                     00430000
      2  ENT1CNOO  CHARACTER (10),                                      00440000
      2  DFHMS4 FIXED BINARY (15,0),                                    00450000
      2  ENT1FNAA    CHARACTER (1),                                     00460000
      2  ENT1FNAO  CHARACTER (10),                                      00470000
      2  DFHMS5 FIXED BINARY (15,0),                                    00480000
      2  ENT1LNAA    CHARACTER (1),                                     00490000
      2  ENT1LNAO  CHARACTER (20),                                      00500000
      2  DFHMS6 FIXED BINARY (15,0),                                    00510000
      2  ENT1DOBA    CHARACTER (1),                                     00520000
      2  ENT1DOBO  CHARACTER (10),                                      00530000
      2  DFHMS7 FIXED BINARY (15,0),                                    00540000
      2  ENT1HNMA    CHARACTER (1),                                     00550000
      2  ENT1HNMO  CHARACTER (20),                                      00560000
      2  DFHMS8 FIXED BINARY (15,0),                                    00570000
      2  ENT1HNOA    CHARACTER (1),                                     00580000
      2  ENT1HNOO  CHARACTER (4),                                       00590000
      2  DFHMS9 FIXED BINARY (15,0),                                    00600000
      2  ENT1HPCA    CHARACTER (1),                                     00610000
      2  ENT1HPCO  CHARACTER (8),                                       00620000
      2  DFHMS10 FIXED BINARY (15,0),                                   00630000
      2  ENT1HP1A    CHARACTER (1),                                     00640000
      2  ENT1HP1O  CHARACTER (20),                                      00650000
      2  DFHMS11 FIXED BINARY (15,0),                                   00660000
      2  ENT1HP2A    CHARACTER (1),                                     00670000
      2  ENT1HP2O  CHARACTER (20),                                      00680000
      2  DFHMS12 FIXED BINARY (15,0),                                   00690000
      2  ENT1HMOA    CHARACTER (1),                                     00700000
      2  ENT1HMOO  CHARACTER (27),                                      00710000
      2  DFHMS13 FIXED BINARY (15,0),                                   00720000
      2  ENT1OPTA    CHARACTER (1),                                     00730000
      2  ENT1OPTO  CHARACTER (1),                                       00740000
      2  DFHMS14 FIXED BINARY (15,0),                                   00750000
      2  ERRFLDA    CHARACTER (1),                                      00760000
      2  ERRFLDO  CHARACTER (40),                                       00770000
      2 FILL0101  CHARACTER (1);                                        00780000
                                                                        00790000
 DECLARE 1 SSMAPP1I AUTOMATIC UNALIGNED,                                00800000
       2  DFHMS15 CHARACTER (12),                                       00810000
      2  ENP1PNOL    FIXED BINARY (15,0),                               00820000
      2  ENP1PNOF    CHARACTER (1),                                     00830000
      2  ENP1PNOI  CHARACTER (10),                                      00840000
      2  ENP1CNOL    FIXED BINARY (15,0),                               00850000
      2  ENP1CNOF    CHARACTER (1),                                     00860000
      2  ENP1CNOI  CHARACTER (10),                                      00870000
      2  ENP1IDAL    FIXED BINARY (15,0),                               00880000
      2  ENP1IDAF    CHARACTER (1),                                     00890000
      2  ENP1IDAI  CHARACTER (10),                                      00900000
      2  ENP1EDAL    FIXED BINARY (15,0),                               00910000
      2  ENP1EDAF    CHARACTER (1),                                     00920000
      2  ENP1EDAI  CHARACTER (10),                                      00930000
      2  ENP1CMKL    FIXED BINARY (15,0),                               00940000
      2  ENP1CMKF    CHARACTER (1),                                     00950000
      2  ENP1CMKI  CHARACTER (20),                                      00960000
      2  ENP1CMOL    FIXED BINARY (15,0),                               00970000
      2  ENP1CMOF    CHARACTER (1),                                     00980000
      2  ENP1CMOI  CHARACTER (20),                                      00990000
      2  ENP1VALL    FIXED BINARY (15,0),                               01000000
      2  ENP1VALF    CHARACTER (1),                                     01010000
      2  ENP1VALI  CHARACTER (6),                                       01020000
      2  ENP1REGL    FIXED BINARY (15,0),                               01030000
      2  ENP1REGF    CHARACTER (1),                                     01040000
      2  ENP1REGI  CHARACTER (7),                                       01050000
      2  ENP1COLL    FIXED BINARY (15,0),                               01060000
      2  ENP1COLF    CHARACTER (1),                                     01070000
      2  ENP1COLI  CHARACTER (8),                                       01080000
      2  ENP1CCL    FIXED BINARY (15,0),                                01090000
      2  ENP1CCF    CHARACTER (1),                                      01100000
      2  ENP1CCI  CHARACTER (8),                                        01110000
      2  ENP1MANL    FIXED BINARY (15,0),                               01120000
      2  ENP1MANF    CHARACTER (1),                                     01130000
      2  ENP1MANI  CHARACTER (10),                                      01140000
      2  ENP1ACCL    FIXED BINARY (15,0),                               01150000
      2  ENP1ACCF    CHARACTER (1),                                     01160000
      2  ENP1ACCI  CHARACTER (6),                                       01170000
      2  ENP1PREL    FIXED BINARY (15,0),                               01180000
      2  ENP1PREF    CHARACTER (1),                                     01190000
      2  ENP1PREI  CHARACTER (6),                                       01200000
      2  ENP1OPTL    FIXED BINARY (15,0),                               01210000
      2  ENP1OPTF    CHARACTER (1),                                     01220000
      2  ENP1OPTI  CHARACTER (1),                                       01230000
      2  ERP1FLDL    FIXED BINARY (15,0),                               01240000
      2  ERP1FLDF    CHARACTER (1),                                     01250000
      2  ERP1FLDI  CHARACTER (40),                                      01260000
      2 FILL0201  CHARACTER (1);                                        01270000
 DECLARE 1 SSMAPP1O BASED(ADDR(SSMAPP1I)) UNALIGNED,                    01280000
       2  DFHMS16 CHARACTER (12),                                       01290000
      2  DFHMS17 FIXED BINARY (15,0),                                   01300000
      2  ENP1PNOA    CHARACTER (1),                                     01310000
      2  ENP1PNOO  CHARACTER (10),                                      01320000
      2  DFHMS18 FIXED BINARY (15,0),                                   01330000
      2  ENP1CNOA    CHARACTER (1),                                     01340000
      2  ENP1CNOO  CHARACTER (10),                                      01350000
      2  DFHMS19 FIXED BINARY (15,0),                                   01360000
      2  ENP1IDAA    CHARACTER (1),                                     01370000
      2  ENP1IDAO  CHARACTER (10),                                      01380000
      2  DFHMS20 FIXED BINARY (15,0),                                   01390000
      2  ENP1EDAA    CHARACTER (1),                                     01400000
      2  ENP1EDAO  CHARACTER (10),                                      01410000
      2  DFHMS21 FIXED BINARY (15,0),                                   01420000
      2  ENP1CMKA    CHARACTER (1),                                     01430000
      2  ENP1CMKO  CHARACTER (20),                                      01440000
      2  DFHMS22 FIXED BINARY (15,0),                                   01450000
      2  ENP1CMOA    CHARACTER (1),                                     01460000
      2  ENP1CMOO  CHARACTER (20),                                      01470000
      2  DFHMS23 FIXED BINARY (15,0),                                   01480000
      2  ENP1VALA    CHARACTER (1),                                     01490000
      2  ENP1VALO  CHARACTER (6),                                       01500000
      2  DFHMS24 FIXED BINARY (15,0),                                   01510000
      2  ENP1REGA    CHARACTER (1),                                     01520000
      2  ENP1REGO  CHARACTER (7),                                       01530000
      2  DFHMS25 FIXED BINARY (15,0),                                   01540000
      2  ENP1COLA    CHARACTER (1),                                     01550000
      2  ENP1COLO  CHARACTER (8),                                       01560000
      2  DFHMS26 FIXED BINARY (15,0),                                   01570000
      2  ENP1CCA    CHARACTER (1),                                      01580000
      2  ENP1CCO  CHARACTER (8),                                        01590000
      2  DFHMS27 FIXED BINARY (15,0),                                   01600000
      2  ENP1MANA    CHARACTER (1),                                     01610000
      2  ENP1MANO  CHARACTER (10),                                      01620000
      2  DFHMS28 FIXED BINARY (15,0),                                   01630000
      2  ENP1ACCA    CHARACTER (1),                                     01640000
      2  ENP1ACCO  CHARACTER (6),                                       01650000
      2  DFHMS29 FIXED BINARY (15,0),                                   01660000
      2  ENP1PREA    CHARACTER (1),                                     01670000
      2  ENP1PREO  CHARACTER (6),                                       01680000
      2  DFHMS30 FIXED BINARY (15,0),                                   01690000
      2  ENP1OPTA    CHARACTER (1),                                     01700000
      2  ENP1OPTO  CHARACTER (1),                                       01710000
      2  DFHMS31 FIXED BINARY (15,0),                                   01720000
      2  ERP1FLDA    CHARACTER (1),                                     01730000
      2  ERP1FLDO  CHARACTER (40),                                      01740000
      2 FILL0201  CHARACTER (1);                                        01750000
                                                                        01760000
 DECLARE 1 SSMAPP2I AUTOMATIC UNALIGNED,                                01770000
       2  DFHMS32 CHARACTER (12),                                       01780000
      2  ENP2PNOL    FIXED BINARY (15,0),                               01790000
      2  ENP2PNOF    CHARACTER (1),                                     01800000
      2  ENP2PNOI  CHARACTER (10),                                      01810000
      2  ENP2CNOL    FIXED BINARY (15,0),                               01820000
      2  ENP2CNOF    CHARACTER (1),                                     01830000
      2  ENP2CNOI  CHARACTER (10),                                      01840000
      2  ENP2IDAL    FIXED BINARY (15,0),                               01850000
      2  ENP2IDAF    CHARACTER (1),                                     01860000
      2  ENP2IDAI  CHARACTER (10),                                      01870000
      2  ENP2EDAL    FIXED BINARY (15,0),                               01880000
      2  ENP2EDAF    CHARACTER (1),                                     01890000
      2  ENP2EDAI  CHARACTER (10),                                      01900000
      2  ENP2FNML    FIXED BINARY (15,0),                               01910000
      2  ENP2FNMF    CHARACTER (1),                                     01920000
      2  ENP2FNMI  CHARACTER (10),                                      01930000
      2  ENP2TERL    FIXED BINARY (15,0),                               01940000
      2  ENP2TERF    CHARACTER (1),                                     01950000
      2  ENP2TERI  CHARACTER (2),                                       01960000
      2  ENP2SUML    FIXED BINARY (15,0),                               01970000
      2  ENP2SUMF    CHARACTER (1),                                     01980000
      2  ENP2SUMI  CHARACTER (6),                                       01990000
      2  ENP2LIFL    FIXED BINARY (15,0),                               02000000
      2  ENP2LIFF    CHARACTER (1),                                     02010000
      2  ENP2LIFI  CHARACTER (25),                                      02020000
      2  ENP2WPRL    FIXED BINARY (15,0),                               02030000
      2  ENP2WPRF    CHARACTER (1),                                     02040000
      2  ENP2WPRI  CHARACTER (1),                                       02050000
      2  ENP2EQUL    FIXED BINARY (15,0),                               02060000
      2  ENP2EQUF    CHARACTER (1),                                     02070000
      2  ENP2EQUI  CHARACTER (1),                                       02080000
      2  ENP2MANL    FIXED BINARY (15,0),                               02090000
      2  ENP2MANF    CHARACTER (1),                                     02100000
      2  ENP2MANI  CHARACTER (1),                                       02110000
      2  ENP2OPTL    FIXED BINARY (15,0),                               02120000
      2  ENP2OPTF    CHARACTER (1),                                     02130000
      2  ENP2OPTI  CHARACTER (1),                                       02140000
      2  ERP2FLDL    FIXED BINARY (15,0),                               02150000
      2  ERP2FLDF    CHARACTER (1),                                     02160000
      2  ERP2FLDI  CHARACTER (40),                                      02170000
      2 FILL0301  CHARACTER (1);                                        02180000
 DECLARE 1 SSMAPP2O BASED(ADDR(SSMAPP2I)) UNALIGNED,                    02190000
       2  DFHMS33 CHARACTER (12),                                       02200000
      2  DFHMS34 FIXED BINARY (15,0),                                   02210000
      2  ENP2PNOA    CHARACTER (1),                                     02220000
      2  ENP2PNOO  CHARACTER (10),                                      02230000
      2  DFHMS35 FIXED BINARY (15,0),                                   02240000
      2  ENP2CNOA    CHARACTER (1),                                     02250000
      2  ENP2CNOO  CHARACTER (10),                                      02260000
      2  DFHMS36 FIXED BINARY (15,0),                                   02270000
      2  ENP2IDAA    CHARACTER (1),                                     02280000
      2  ENP2IDAO  CHARACTER (10),                                      02290000
      2  DFHMS37 FIXED BINARY (15,0),                                   02300000
      2  ENP2EDAA    CHARACTER (1),                                     02310000
      2  ENP2EDAO  CHARACTER (10),                                      02320000
      2  DFHMS38 FIXED BINARY (15,0),                                   02330000
      2  ENP2FNMA    CHARACTER (1),                                     02340000
      2  ENP2FNMO  CHARACTER (10),                                      02350000
      2  DFHMS39 FIXED BINARY (15,0),                                   02360000
      2  ENP2TERA    CHARACTER (1),                                     02370000
      2  ENP2TERO  CHARACTER (2),                                       02380000
      2  DFHMS40 FIXED BINARY (15,0),                                   02390000
      2  ENP2SUMA    CHARACTER (1),                                     02400000
      2  ENP2SUMO  CHARACTER (6),                                       02410000
      2  DFHMS41 FIXED BINARY (15,0),                                   02420000
      2  ENP2LIFA    CHARACTER (1),                                     02430000
      2  ENP2LIFO  CHARACTER (25),                                      02440000
      2  DFHMS42 FIXED BINARY (15,0),                                   02450000
      2  ENP2WPRA    CHARACTER (1),                                     02460000
      2  ENP2WPRO  CHARACTER (1),                                       02470000
      2  DFHMS43 FIXED BINARY (15,0),                                   02480000
      2  ENP2EQUA    CHARACTER (1),                                     02490000
      2  ENP2EQUO  CHARACTER (1),                                       02500000
      2  DFHMS44 FIXED BINARY (15,0),                                   02510000
      2  ENP2MANA    CHARACTER (1),                                     02520000
      2  ENP2MANO  CHARACTER (1),                                       02530000
      2  DFHMS45 FIXED BINARY (15,0),                                   02540000
      2  ENP2OPTA    CHARACTER (1),                                     02550000
      2  ENP2OPTO  CHARACTER (1),                                       02560000
      2  DFHMS46 FIXED BINARY (15,0),                                   02570000
      2  ERP2FLDA    CHARACTER (1),                                     02580000
      2  ERP2FLDO  CHARACTER (40),                                      02590000
      2 FILL0301  CHARACTER (1);                                        02600000
                                                                        02610000
 DECLARE 1 SSMAPP3I AUTOMATIC UNALIGNED,                                02620000
       2  DFHMS47 CHARACTER (12),                                       02630000
      2  ENP3PNOL    FIXED BINARY (15,0),                               02640000
      2  ENP3PNOF    CHARACTER (1),                                     02650000
      2  ENP3PNOI  CHARACTER (10),                                      02660000
      2  ENP3CNOL    FIXED BINARY (15,0),                               02670000
      2  ENP3CNOF    CHARACTER (1),                                     02680000
      2  ENP3CNOI  CHARACTER (10),                                      02690000
      2  ENP3IDAL    FIXED BINARY (15,0),                               02700000
      2  ENP3IDAF    CHARACTER (1),                                     02710000
      2  ENP3IDAI  CHARACTER (10),                                      02720000
      2  ENP3EDAL    FIXED BINARY (15,0),                               02730000
      2  ENP3EDAF    CHARACTER (1),                                     02740000
      2  ENP3EDAI  CHARACTER (10),                                      02750000
      2  ENP3TYPL    FIXED BINARY (15,0),                               02760000
      2  ENP3TYPF    CHARACTER (1),                                     02770000
      2  ENP3TYPI  CHARACTER (15),                                      02780000
      2  ENP3BEDL    FIXED BINARY (15,0),                               02790000
      2  ENP3BEDF    CHARACTER (1),                                     02800000
      2  ENP3BEDI  CHARACTER (3),                                       02810000
      2  ENP3VALL    FIXED BINARY (15,0),                               02820000
      2  ENP3VALF    CHARACTER (1),                                     02830000
      2  ENP3VALI  CHARACTER (8),                                       02840000
      2  ENP3HNML    FIXED BINARY (15,0),                               02850000
      2  ENP3HNMF    CHARACTER (1),                                     02860000
      2  ENP3HNMI  CHARACTER (20),                                      02870000
      2  ENP3HNOL    FIXED BINARY (15,0),                               02880000
      2  ENP3HNOF    CHARACTER (1),                                     02890000
      2  ENP3HNOI  CHARACTER (4),                                       02900000
      2  ENP3HPCL    FIXED BINARY (15,0),                               02910000
      2  ENP3HPCF    CHARACTER (1),                                     02920000
      2  ENP3HPCI  CHARACTER (8),                                       02930000
      2  ENP3OPTL    FIXED BINARY (15,0),                               02940000
      2  ENP3OPTF    CHARACTER (1),                                     02950000
      2  ENP3OPTI  CHARACTER (1),                                       02960000
      2  ERP3FLDL    FIXED BINARY (15,0),                               02970000
      2  ERP3FLDF    CHARACTER (1),                                     02980000
      2  ERP3FLDI  CHARACTER (40),                                      02990000
      2 FILL0401  CHARACTER (1);                                        03000000
 DECLARE 1 SSMAPP3O BASED(ADDR(SSMAPP3I)) UNALIGNED,                    03010000
       2  DFHMS48 CHARACTER (12),                                       03020000
      2  DFHMS49 FIXED BINARY (15,0),                                   03030000
      2  ENP3PNOA    CHARACTER (1),                                     03040000
      2  ENP3PNOO  CHARACTER (10),                                      03050000
      2  DFHMS50 FIXED BINARY (15,0),                                   03060000
      2  ENP3CNOA    CHARACTER (1),                                     03070000
      2  ENP3CNOO  CHARACTER (10),                                      03080000
      2  DFHMS51 FIXED BINARY (15,0),                                   03090000
      2  ENP3IDAA    CHARACTER (1),                                     03100000
      2  ENP3IDAO  CHARACTER (10),                                      03110000
      2  DFHMS52 FIXED BINARY (15,0),                                   03120000
      2  ENP3EDAA    CHARACTER (1),                                     03130000
      2  ENP3EDAO  CHARACTER (10),                                      03140000
      2  DFHMS53 FIXED BINARY (15,0),                                   03150000
      2  ENP3TYPA    CHARACTER (1),                                     03160000
      2  ENP3TYPO  CHARACTER (15),                                      03170000
      2  DFHMS54 FIXED BINARY (15,0),                                   03180000
      2  ENP3BEDA    CHARACTER (1),                                     03190000
      2  ENP3BEDO  CHARACTER (3),                                       03200000
      2  DFHMS55 FIXED BINARY (15,0),                                   03210000
      2  ENP3VALA    CHARACTER (1),                                     03220000
      2  ENP3VALO  CHARACTER (8),                                       03230000
      2  DFHMS56 FIXED BINARY (15,0),                                   03240000
      2  ENP3HNMA    CHARACTER (1),                                     03250000
      2  ENP3HNMO  CHARACTER (20),                                      03260000
      2  DFHMS57 FIXED BINARY (15,0),                                   03270000
      2  ENP3HNOA    CHARACTER (1),                                     03280000
      2  ENP3HNOO  CHARACTER (4),                                       03290000
      2  DFHMS58 FIXED BINARY (15,0),                                   03300000
      2  ENP3HPCA    CHARACTER (1),                                     03310000
      2  ENP3HPCO  CHARACTER (8),                                       03320000
      2  DFHMS59 FIXED BINARY (15,0),                                   03330000
      2  ENP3OPTA    CHARACTER (1),                                     03340000
      2  ENP3OPTO  CHARACTER (1),                                       03350000
      2  DFHMS60 FIXED BINARY (15,0),                                   03360000
      2  ERP3FLDA    CHARACTER (1),                                     03370000
      2  ERP3FLDO  CHARACTER (40),                                      03380000
      2 FILL0401  CHARACTER (1);                                        03390000
                                                                        03400000
 DECLARE 1 SSMAPP4I AUTOMATIC UNALIGNED,                                03410000
       2  DFHMS61 CHARACTER (12),                                       03420000
      2  ENP4PNOL    FIXED BINARY (15,0),                               03430000
      2  ENP4PNOF    CHARACTER (1),                                     03440000
      2  ENP4PNOI  CHARACTER (10),                                      03450000
      2  ENP4CNOL    FIXED BINARY (15,0),                               03460000
      2  ENP4CNOF    CHARACTER (1),                                     03470000
      2  ENP4CNOI  CHARACTER (10),                                      03480000
      2  ENP4IDAL    FIXED BINARY (15,0),                               03490000
      2  ENP4IDAF    CHARACTER (1),                                     03500000
      2  ENP4IDAI  CHARACTER (10),                                      03510000
      2  ENP4EDAL    FIXED BINARY (15,0),                               03520000
      2  ENP4EDAF    CHARACTER (1),                                     03530000
      2  ENP4EDAI  CHARACTER (10),                                      03540000
      2  ENP4ADDL    FIXED BINARY (15,0),                               03550000
      2  ENP4ADDF    CHARACTER (1),                                     03560000
      2  ENP4ADDI  CHARACTER (25),                                      03570000
      2  ENP4HPCL    FIXED BINARY (15,0),                               03580000
      2  ENP4HPCF    CHARACTER (1),                                     03590000
      2  ENP4HPCI  CHARACTER (8),                                       03600000
      2  ENP4LATL    FIXED BINARY (15,0),                               03610000
      2  ENP4LATF    CHARACTER (1),                                     03620000
      2  ENP4LATI  CHARACTER (11),                                      03630000
      2  ENP4LONL    FIXED BINARY (15,0),                               03640000
      2  ENP4LONF    CHARACTER (1),                                     03650000
      2  ENP4LONI  CHARACTER (11),                                      03660000
      2  ENP4CUSL    FIXED BINARY (15,0),                               03670000
      2  ENP4CUSF    CHARACTER (1),                                     03680000
      2  ENP4CUSI  CHARACTER (25),                                      03690000
      2  ENP4PTYL    FIXED BINARY (15,0),                               03700000
      2  ENP4PTYF    CHARACTER (1),                                     03710000
      2  ENP4PTYI  CHARACTER (25),                                      03720000
      2  ENP4FPEL    FIXED BINARY (15,0),                               03730000
      2  ENP4FPEF    CHARACTER (1),                                     03740000
      2  ENP4FPEI  CHARACTER (4),                                       03750000
      2  ENP4FPRL    FIXED BINARY (15,0),                               03760000
      2  ENP4FPRF    CHARACTER (1),                                     03770000
      2  ENP4FPRI  CHARACTER (8),                                       03780000
      2  ENP4CPEL    FIXED BINARY (15,0),                               03790000
      2  ENP4CPEF    CHARACTER (1),                                     03800000
      2  ENP4CPEI  CHARACTER (4),                                       03810000
      2  ENP4CPRL    FIXED BINARY (15,0),                               03820000
      2  ENP4CPRF    CHARACTER (1),                                     03830000
      2  ENP4CPRI  CHARACTER (8),                                       03840000
      2  ENP4XPEL    FIXED BINARY (15,0),                               03850000
      2  ENP4XPEF    CHARACTER (1),                                     03860000
      2  ENP4XPEI  CHARACTER (4),                                       03870000
      2  ENP4XPRL    FIXED BINARY (15,0),                               03880000
      2  ENP4XPRF    CHARACTER (1),                                     03890000
      2  ENP4XPRI  CHARACTER (8),                                       03900000
      2  ENP4WPEL    FIXED BINARY (15,0),                               03910000
      2  ENP4WPEF    CHARACTER (1),                                     03920000
      2  ENP4WPEI  CHARACTER (4),                                       03930000
      2  ENP4WPRL    FIXED BINARY (15,0),                               03940000
      2  ENP4WPRF    CHARACTER (1),                                     03950000
      2  ENP4WPRI  CHARACTER (8),                                       03960000
      2  ENP4STAL    FIXED BINARY (15,0),                               03970000
      2  ENP4STAF    CHARACTER (1),                                     03980000
      2  ENP4STAI  CHARACTER (4),                                       03990000
      2  ENP4REJL    FIXED BINARY (15,0),                               04000000
      2  ENP4REJF    CHARACTER (1),                                     04010000
      2  ENP4REJI  CHARACTER (25),                                      04020000
      2  ENP4OPTL    FIXED BINARY (15,0),                               04030000
      2  ENP4OPTF    CHARACTER (1),                                     04040000
      2  ENP4OPTI  CHARACTER (1),                                       04050000
      2  ERP4FLDL    FIXED BINARY (15,0),                               04060000
      2  ERP4FLDF    CHARACTER (1),                                     04070000
      2  ERP4FLDI  CHARACTER (40),                                      04080000
      2 FILL0501  CHARACTER (1);                                        04090000
 DECLARE 1 SSMAPP4O BASED(ADDR(SSMAPP4I)) UNALIGNED,                    04100000
       2  DFHMS62 CHARACTER (12),                                       04110000
      2  DFHMS63 FIXED BINARY (15,0),                                   04120000
      2  ENP4PNOA    CHARACTER (1),                                     04130000
      2  ENP4PNOO  CHARACTER (10),                                      04140000
      2  DFHMS64 FIXED BINARY (15,0),                                   04150000
      2  ENP4CNOA    CHARACTER (1),                                     04160000
      2  ENP4CNOO  CHARACTER (10),                                      04170000
      2  DFHMS65 FIXED BINARY (15,0),                                   04180000
      2  ENP4IDAA    CHARACTER (1),                                     04190000
      2  ENP4IDAO  CHARACTER (10),                                      04200000
      2  DFHMS66 FIXED BINARY (15,0),                                   04210000
      2  ENP4EDAA    CHARACTER (1),                                     04220000
      2  ENP4EDAO  CHARACTER (10),                                      04230000
      2  DFHMS67 FIXED BINARY (15,0),                                   04240000
      2  ENP4ADDA    CHARACTER (1),                                     04250000
      2  ENP4ADDO  CHARACTER (25),                                      04260000
      2  DFHMS68 FIXED BINARY (15,0),                                   04270000
      2  ENP4HPCA    CHARACTER (1),                                     04280000
      2  ENP4HPCO  CHARACTER (8),                                       04290000
      2  DFHMS69 FIXED BINARY (15,0),                                   04300000
      2  ENP4LATA    CHARACTER (1),                                     04310000
      2  ENP4LATO  CHARACTER (11),                                      04320000
      2  DFHMS70 FIXED BINARY (15,0),                                   04330000
      2  ENP4LONA    CHARACTER (1),                                     04340000
      2  ENP4LONO  CHARACTER (11),                                      04350000
      2  DFHMS71 FIXED BINARY (15,0),                                   04360000
      2  ENP4CUSA    CHARACTER (1),                                     04370000
      2  ENP4CUSO  CHARACTER (25),                                      04380000
      2  DFHMS72 FIXED BINARY (15,0),                                   04390000
      2  ENP4PTYA    CHARACTER (1),                                     04400000
      2  ENP4PTYO  CHARACTER (25),                                      04410000
      2  DFHMS73 FIXED BINARY (15,0),                                   04420000
      2  ENP4FPEA    CHARACTER (1),                                     04430000
      2  ENP4FPEO  CHARACTER (4),                                       04440000
      2  DFHMS74 FIXED BINARY (15,0),                                   04450000
      2  ENP4FPRA    CHARACTER (1),                                     04460000
      2  ENP4FPRO  CHARACTER (8),                                       04470000
      2  DFHMS75 FIXED BINARY (15,0),                                   04480000
      2  ENP4CPEA    CHARACTER (1),                                     04490000
      2  ENP4CPEO  CHARACTER (4),                                       04500000
      2  DFHMS76 FIXED BINARY (15,0),                                   04510000
      2  ENP4CPRA    CHARACTER (1),                                     04520000
      2  ENP4CPRO  CHARACTER (8),                                       04530000
      2  DFHMS77 FIXED BINARY (15,0),                                   04540000
      2  ENP4XPEA    CHARACTER (1),                                     04550000
      2  ENP4XPEO  CHARACTER (4),                                       04560000
      2  DFHMS78 FIXED BINARY (15,0),                                   04570000
      2  ENP4XPRA    CHARACTER (1),                                     04580000
      2  ENP4XPRO  CHARACTER (8),                                       04590000
      2  DFHMS79 FIXED BINARY (15,0),                                   04600000
      2  ENP4WPEA    CHARACTER (1),                                     04610000
      2  ENP4WPEO  CHARACTER (4),                                       04620000
      2  DFHMS80 FIXED BINARY (15,0),                                   04630000
      2  ENP4WPRA    CHARACTER (1),                                     04640000
      2  ENP4WPRO  CHARACTER (8),                                       04650000
      2  DFHMS81 FIXED BINARY (15,0),                                   04660000
      2  ENP4STAA    CHARACTER (1),                                     04670000
      2  ENP4STAO  CHARACTER (4),                                       04680000
      2  DFHMS82 FIXED BINARY (15,0),                                   04690000
      2  ENP4REJA    CHARACTER (1),                                     04700000
      2  ENP4REJO  CHARACTER (25),                                      04710000
      2  DFHMS83 FIXED BINARY (15,0),                                   04720000
      2  ENP4OPTA    CHARACTER (1),                                     04730000
      2  ENP4OPTO  CHARACTER (1),                                       04740000
      2  DFHMS84 FIXED BINARY (15,0),                                   04750000
      2  ERP4FLDA    CHARACTER (1),                                     04760000
      2  ERP4FLDO  CHARACTER (40),                                      04770000
      2 FILL0501  CHARACTER (1);                                        04780000
                                                                        04790000
 DECLARE 1 SSMAPP5I AUTOMATIC UNALIGNED,                                04800000
       2  DFHMS85 CHARACTER (12),                                       04810000
      2  ENP5LNOL    FIXED BINARY (15,0),                               04820000
      2  ENP5LNOF    CHARACTER (1),                                     04830000
      2  ENP5LNOI  CHARACTER (10),                                      04840000
      2  ENP5PNOL    FIXED BINARY (15,0),                               04850000
      2  ENP5PNOF    CHARACTER (1),                                     04860000
      2  ENP5PNOI  CHARACTER (10),                                      04870000
      2  ENP5CNOL    FIXED BINARY (15,0),                               04880000
      2  ENP5CNOF    CHARACTER (1),                                     04890000
      2  ENP5CNOI  CHARACTER (10),                                      04900000
      2  ENP5CDAL    FIXED BINARY (15,0),                               04910000
      2  ENP5CDAF    CHARACTER (1),                                     04920000
      2  ENP5CDAI  CHARACTER (10),                                      04930000
      2  ENP5PADL    FIXED BINARY (15,0),                               04940000
      2  ENP5PADF    CHARACTER (1),                                     04950000
      2  ENP5PADI  CHARACTER (10),                                      04960000
      2  ENP5VALL    FIXED BINARY (15,0),                               04970000
      2  ENP5VALF    CHARACTER (1),                                     04980000
      2  ENP5VALI  CHARACTER (10),                                      04990000
      2  ENP5CAUL    FIXED BINARY (15,0),                               05000000
      2  ENP5CAUF    CHARACTER (1),                                     05010000
      2  ENP5CAUI  CHARACTER (25),                                      05020000
      2  ENP5OBSL    FIXED BINARY (15,0),                               05030000
      2  ENP5OBSF    CHARACTER (1),                                     05040000
      2  ENP5OBSI  CHARACTER (25),                                      05050000
      2  ENP5OPTL    FIXED BINARY (15,0),                               05060000
      2  ENP5OPTF    CHARACTER (1),                                     05070000
      2  ENP5OPTI  CHARACTER (1),                                       05080000
      2  ERP5FLDL    FIXED BINARY (15,0),                               05090000
      2  ERP5FLDF    CHARACTER (1),                                     05100000
      2  ERP5FLDI  CHARACTER (40),                                      05110000
      2 FILL0601  CHARACTER (1);                                        05120000
 DECLARE 1 SSMAPP5O BASED(ADDR(SSMAPP5I)) UNALIGNED,                    05130000
       2  DFHMS86 CHARACTER (12),                                       05140000
      2  DFHMS87 FIXED BINARY (15,0),                                   05150000
      2  ENP5LNOA    CHARACTER (1),                                     05160000
      2  ENP5LNOO  CHARACTER (10),                                      05170000
      2  DFHMS88 FIXED BINARY (15,0),                                   05180000
      2  ENP5PNOA    CHARACTER (1),                                     05190000
      2  ENP5PNOO  CHARACTER (10),                                      05200000
      2  DFHMS89 FIXED BINARY (15,0),                                   05210000
      2  ENP5CNOA    CHARACTER (1),                                     05220000
      2  ENP5CNOO  CHARACTER (10),                                      05230000
      2  DFHMS90 FIXED BINARY (15,0),                                   05240000
      2  ENP5CDAA    CHARACTER (1),                                     05250000
      2  ENP5CDAO  CHARACTER (10),                                      05260000
      2  DFHMS91 FIXED BINARY (15,0),                                   05270000
      2  ENP5PADA    CHARACTER (1),                                     05280000
      2  ENP5PADO  CHARACTER (10),                                      05290000
      2  DFHMS92 FIXED BINARY (15,0),                                   05300000
      2  ENP5VALA    CHARACTER (1),                                     05310000
      2  ENP5VALO  CHARACTER (10),                                      05320000
      2  DFHMS93 FIXED BINARY (15,0),                                   05330000
      2  ENP5CAUA    CHARACTER (1),                                     05340000
      2  ENP5CAUO  CHARACTER (25),                                      05350000
      2  DFHMS94 FIXED BINARY (15,0),                                   05360000
      2  ENP5OBSA    CHARACTER (1),                                     05370000
      2  ENP5OBSO  CHARACTER (25),                                      05380000
      2  DFHMS95 FIXED BINARY (15,0),                                   05390000
      2  ENP5OPTA    CHARACTER (1),                                     05400000
      2  ENP5OPTO  CHARACTER (1),                                       05410000
      2  DFHMS96 FIXED BINARY (15,0),                                   05420000
      2  ERP5FLDA    CHARACTER (1),                                     05430000
      2  ERP5FLDO  CHARACTER (40),                                      05440000
      2 FILL0601  CHARACTER (1);                                        05450000