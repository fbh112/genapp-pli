1
 ***************************************************************************
 **  CICS RDO OFF-LINE UTILITY PROGRAM DFHCSDUP RELEASE:0720 PTF:UI60564 .**
 ***************************************************************************





   LIST LIST(GENALIST) OBJECTS




 DFH5120 I PRIMARY CSD OPENED;  DDNAME: DFHCSD   - DSNAME: CTS550P8.ADDICSD.DFHCSD
1CICS RDO OFF-LINE UTILITY PROGRAM DFHCSDUP RELEASE:0720 PTF:UI60564 .             TIME 10:12 DATE 20.170      PAGE 0001
-DFHCSDUP:   CICS OFF-LINE UTILITY (LIST)                                                         CURRENT RELEASE: 7.2.0

                                              CONTENTS OF CICS SYSTEM DEFINITION FILE (CSD)
                                              ---------------------------------------------

 CSD CREATED BY RELEASE: 7.2.0                                                               DATE CREATED:   20.170 10:09
                                                                                             LAST UPDATED:   20.170 10:12


 ************************************************************************************************************************

 SUMMARY OF LISTS                                                     UTILITY COMMAND:    LIST LIST(GENALIST)     OBJECTS

 ************************************************************************************************************************

 LIST NAME:     GENALIST
 ----------

    ELEMENT     NAME      DATE ADDED
    -------     ----      ----------

     GROUP      GENA      20.170 10:11
1CICS RDO OFF-LINE UTILITY PROGRAM DFHCSDUP RELEASE:0720 PTF:UI60564 .             TIME 10:12 DATE 20.170      PAGE 0002
-
 ************************************************************************************************************************

 OBJECTS IN GROUPS IN LIST                                            UTILITY COMMAND:    LIST LIST(GENALIST)     OBJECTS

 ************************************************************************************************************************

 GROUP NAME: GENA
 ----------

 FILE(KSDSCUST)         GROUP(GENA)     DESCRIPTION()                                                        20.170 10:11
                        VSAM-PARAMETERS

                                        DSNAME(ADAPPL.GENAPP.KSDSCUST)
                                        RLSACCESS(NO)          LSRPOOLNUM(1)          READINTEG(UNCOMMITTED)
                                        DSNSHARING(ALLREQS)    STRINGS(1)             NSRGROUP()
                        REMOTE-ATTRIBUTES
                                        REMOTESYSTEM()         REMOTENAME()
                        REMOTE-AND-CFDATATABLE-PARAMETERS
                                        RECORDSIZE(82)         KEYLENGTH(10)
                        INITIAL-STATUS
                                        STATUS(ENABLED)        OPENTIME(FIRSTREF)     DISPOSITION(SHARE)
                        BUFFERS
                                        DATABUFFERS(2)         INDEXBUFFERS(1)
                        DATATABLE-PARAMETERS
                                        TABLE(NO)              MAXNUMRECS(NOLIMIT)
                        CFDATATABLE-PARAMETERS
                                        CFDTPOOL()             TABLENAME()            UPDATEMODEL(LOCKING)
                                        LOAD(NO)
                        DATA-FORMAT
                                        RECORDFORMAT(V)
                        OPERATIONS
                                        ADD(YES)               BROWSE(YES)            DELETE(NO)
                                        READ(YES)              UPDATE(YES)
                        AUTO-JOURNALLING
                                        JOURNAL(NO)            JNLREAD(NONE)          JNLSYNCREAD(NO)
                                        JNLUPDATE(NO)          JNLADD(NONE)           JNLSYNCWRITE(YES)
                        RECOVERY-PARAMETERS
                                        RECOVERY(NONE)         FWDRECOVLOG(NO)        BACKUPTYPE(STATIC)
                        DEFINITION-SIGNATURE

                                        DEFINETIME(20/06/18 10:11:41)
                                        CHANGETIME(20/06/18 10:11:41)
                                        CHANGEUSRID(BONNERR)   CHANGEAGENT(CSDBATCH)  CHANGEAGREL(0720)

 FILE(KSDSPOLY)         GROUP(GENA)     DESCRIPTION()                                                        20.170 10:11
                        VSAM-PARAMETERS

                                        DSNAME(ADAPPL.GENAPP.KSDSPOLY)
                                        RLSACCESS(NO)          LSRPOOLNUM(1)          READINTEG(UNCOMMITTED)
                                        DSNSHARING(ALLREQS)    STRINGS(1)             NSRGROUP()
                        REMOTE-ATTRIBUTES
                                        REMOTESYSTEM()         REMOTENAME()
                        REMOTE-AND-CFDATATABLE-PARAMETERS
                                        RECORDSIZE(64)         KEYLENGTH(21)
                        INITIAL-STATUS
                                        STATUS(ENABLED)        OPENTIME(FIRSTREF)     DISPOSITION(SHARE)
1CICS RDO OFF-LINE UTILITY PROGRAM DFHCSDUP RELEASE:0720 PTF:UI60564 .             TIME 10:12 DATE 20.170      PAGE 0003
-                       BUFFERS
                                        DATABUFFERS(2)         INDEXBUFFERS(1)
                        DATATABLE-PARAMETERS
                                        TABLE(NO)              MAXNUMRECS(NOLIMIT)
                        CFDATATABLE-PARAMETERS
                                        CFDTPOOL()             TABLENAME()            UPDATEMODEL(LOCKING)
                                        LOAD(NO)
                        DATA-FORMAT
                                        RECORDFORMAT(V)
                        OPERATIONS
                                        ADD(YES)               BROWSE(YES)            DELETE(YES)
                                        READ(YES)              UPDATE(YES)
                        AUTO-JOURNALLING
                                        JOURNAL(NO)            JNLREAD(NONE)          JNLSYNCREAD(NO)
                                        JNLUPDATE(NO)          JNLADD(NONE)           JNLSYNCWRITE(YES)
                        RECOVERY-PARAMETERS
                                        RECOVERY(NONE)         FWDRECOVLOG(NO)        BACKUPTYPE(STATIC)
                        DEFINITION-SIGNATURE

                                        DEFINETIME(20/06/18 10:11:41)
                                        CHANGETIME(20/06/18 10:11:41)
                                        CHANGEUSRID(BONNERR)   CHANGEAGENT(CSDBATCH)  CHANGEAGREL(0720)

 PROGRAM(LGACDB01)      GROUP(GENA)     DESCRIPTION()          LANGUAGE(COBOL)        RELOAD(NO)             20.170 10:11
                                        RESIDENT(NO)           USAGE(NORMAL)          USELPACOPY(NO)
                                        STATUS(ENABLED)        CEDF(YES)              DATALOCATION(ANY)
                                        EXECKEY(USER)          CONCURRENCY(QUASIRENT) API(CICSAPI)
                        REMOTE-ATTRIBUTES
                                        DYNAMIC(NO)            REMOTESYSTEM()         REMOTENAME()
                                        TRANSID()              EXECUTIONSET(FULLAPI)
                        JVM-ATTRIBUTES
                                        JVM(NO)                JVMCLASS()             JVMSERVER()
                        DEFINITION-SIGNATURE

                                        DEFINETIME(20/06/18 10:11:41)
                                        CHANGETIME(20/06/18 10:11:41)
                                        CHANGEUSRID(BONNERR)   CHANGEAGENT(CSDBATCH)  CHANGEAGREL(0720)

 PROGRAM(LGACDB02)      GROUP(GENA)     DESCRIPTION()          LANGUAGE(COBOL)        RELOAD(NO)             20.170 10:11
                                        RESIDENT(NO)           USAGE(NORMAL)          USELPACOPY(NO)
                                        STATUS(ENABLED)        CEDF(YES)              DATALOCATION(ANY)
                                        EXECKEY(USER)          CONCURRENCY(QUASIRENT) API(CICSAPI)
                        REMOTE-ATTRIBUTES
                                        DYNAMIC(NO)            REMOTESYSTEM()         REMOTENAME()
                                        TRANSID()              EXECUTIONSET(FULLAPI)
                        JVM-ATTRIBUTES
                                        JVM(NO)                JVMCLASS()             JVMSERVER()
                        DEFINITION-SIGNATURE

                                        DEFINETIME(20/06/18 10:11:41)
                                        CHANGETIME(20/06/18 10:11:41)
                                        CHANGEUSRID(BONNERR)   CHANGEAGENT(CSDBATCH)  CHANGEAGREL(0720)

 PROGRAM(LGACUS01)      GROUP(GENA)     DESCRIPTION()          LANGUAGE(COBOL)        RELOAD(NO)             20.170 10:11
                                        RESIDENT(NO)           USAGE(NORMAL)          USELPACOPY(NO)
                                        STATUS(ENABLED)        CEDF(YES)              DATALOCATION(ANY)
                                        EXECKEY(USER)          CONCURRENCY(QUASIRENT) API(CICSAPI)
1CICS RDO OFF-LINE UTILITY PROGRAM DFHCSDUP RELEASE:0720 PTF:UI60564 .             TIME 10:12 DATE 20.170      PAGE 0004
-                       REMOTE-ATTRIBUTES
                                        DYNAMIC(NO)            REMOTESYSTEM()         REMOTENAME()
                                        TRANSID()              EXECUTIONSET(FULLAPI)
                        JVM-ATTRIBUTES
                                        JVM(NO)                JVMCLASS()             JVMSERVER()
                        DEFINITION-SIGNATURE

                                        DEFINETIME(20/06/18 10:11:41)
                                        CHANGETIME(20/06/18 10:11:41)
                                        CHANGEUSRID(BONNERR)   CHANGEAGENT(CSDBATCH)  CHANGEAGREL(0720)

 PROGRAM(LGACVS01)      GROUP(GENA)     DESCRIPTION()          LANGUAGE(COBOL)        RELOAD(NO)             20.170 10:11
                                        RESIDENT(NO)           USAGE(NORMAL)          USELPACOPY(NO)
                                        STATUS(ENABLED)        CEDF(YES)              DATALOCATION(ANY)
                                        EXECKEY(USER)          CONCURRENCY(QUASIRENT) API(CICSAPI)
                        REMOTE-ATTRIBUTES
                                        DYNAMIC(NO)            REMOTESYSTEM()         REMOTENAME()
                                        TRANSID()              EXECUTIONSET(FULLAPI)
                        JVM-ATTRIBUTES
                                        JVM(NO)                JVMCLASS()             JVMSERVER()
                        DEFINITION-SIGNATURE

                                        DEFINETIME(20/06/18 10:11:41)
                                        CHANGETIME(20/06/18 10:11:41)
                                        CHANGEUSRID(BONNERR)   CHANGEAGENT(CSDBATCH)  CHANGEAGREL(0720)

 PROGRAM(LGAPBR01)      GROUP(GENA)     DESCRIPTION()          LANGUAGE(COBOL)        RELOAD(NO)             20.170 10:11
                                        RESIDENT(NO)           USAGE(NORMAL)          USELPACOPY(NO)
                                        STATUS(ENABLED)        CEDF(YES)              DATALOCATION(ANY)
                                        EXECKEY(USER)          CONCURRENCY(QUASIRENT) API(CICSAPI)
                        REMOTE-ATTRIBUTES
                                        DYNAMIC(NO)            REMOTESYSTEM()         REMOTENAME()
                                        TRANSID()              EXECUTIONSET(FULLAPI)
                        JVM-ATTRIBUTES
                                        JVM(NO)                JVMCLASS()             JVMSERVER()
                        DEFINITION-SIGNATURE

                                        DEFINETIME(20/06/18 10:11:41)
                                        CHANGETIME(20/06/18 10:11:41)
                                        CHANGEUSRID(BONNERR)   CHANGEAGENT(CSDBATCH)  CHANGEAGREL(0720)

 PROGRAM(LGAPDB01)      GROUP(GENA)     DESCRIPTION()          LANGUAGE(COBOL)        RELOAD(NO)             20.170 10:11
                                        RESIDENT(NO)           USAGE(NORMAL)          USELPACOPY(NO)
                                        STATUS(ENABLED)        CEDF(YES)              DATALOCATION(ANY)
                                        EXECKEY(USER)          CONCURRENCY(QUASIRENT) API(CICSAPI)
                        REMOTE-ATTRIBUTES
                                        DYNAMIC(NO)            REMOTESYSTEM()         REMOTENAME()
                                        TRANSID()              EXECUTIONSET(FULLAPI)
                        JVM-ATTRIBUTES
                                        JVM(NO)                JVMCLASS()             JVMSERVER()
                        DEFINITION-SIGNATURE

                                        DEFINETIME(20/06/18 10:11:41)
                                        CHANGETIME(20/06/18 10:11:41)
                                        CHANGEUSRID(BONNERR)   CHANGEAGENT(CSDBATCH)  CHANGEAGREL(0720)

 PROGRAM(LGAPOL01)      GROUP(GENA)     DESCRIPTION()          LANGUAGE(COBOL)        RELOAD(NO)             20.170 10:11
1CICS RDO OFF-LINE UTILITY PROGRAM DFHCSDUP RELEASE:0720 PTF:UI60564 .             TIME 10:12 DATE 20.170      PAGE 0005
-                                       RESIDENT(NO)           USAGE(NORMAL)          USELPACOPY(NO)
                                        STATUS(ENABLED)        CEDF(YES)              DATALOCATION(ANY)
                                        EXECKEY(USER)          CONCURRENCY(QUASIRENT) API(CICSAPI)
                        REMOTE-ATTRIBUTES
                                        DYNAMIC(NO)            REMOTESYSTEM()         REMOTENAME()
                                        TRANSID()              EXECUTIONSET(FULLAPI)
                        JVM-ATTRIBUTES
                                        JVM(NO)                JVMCLASS()             JVMSERVER()
                        DEFINITION-SIGNATURE

                                        DEFINETIME(20/06/18 10:11:41)
                                        CHANGETIME(20/06/18 10:11:41)
                                        CHANGEUSRID(BONNERR)   CHANGEAGENT(CSDBATCH)  CHANGEAGREL(0720)

 PROGRAM(LGAPVS01)      GROUP(GENA)     DESCRIPTION()          LANGUAGE(COBOL)        RELOAD(NO)             20.170 10:11
                                        RESIDENT(NO)           USAGE(NORMAL)          USELPACOPY(NO)
                                        STATUS(ENABLED)        CEDF(YES)              DATALOCATION(ANY)
                                        EXECKEY(USER)          CONCURRENCY(QUASIRENT) API(CICSAPI)
                        REMOTE-ATTRIBUTES
                                        DYNAMIC(NO)            REMOTESYSTEM()         REMOTENAME()
                                        TRANSID()              EXECUTIONSET(FULLAPI)
                        JVM-ATTRIBUTES
                                        JVM(NO)                JVMCLASS()             JVMSERVER()
                        DEFINITION-SIGNATURE

                                        DEFINETIME(20/06/18 10:11:41)
                                        CHANGETIME(20/06/18 10:11:41)
                                        CHANGEUSRID(BONNERR)   CHANGEAGENT(CSDBATCH)  CHANGEAGREL(0720)

 PROGRAM(LGASTAT1)      GROUP(GENA)     DESCRIPTION()          LANGUAGE()             RELOAD(NO)             20.170 10:12
                                        RESIDENT(NO)           USAGE(NORMAL)          USELPACOPY(NO)
                                        STATUS(ENABLED)        CEDF(YES)              DATALOCATION(ANY)
                                        EXECKEY(USER)          CONCURRENCY(QUASIRENT) API(CICSAPI)
                        REMOTE-ATTRIBUTES
                                        DYNAMIC(NO)            REMOTESYSTEM()         REMOTENAME()
                                        TRANSID()              EXECUTIONSET(FULLAPI)
                        JVM-ATTRIBUTES
                                        JVM(NO)                JVMCLASS()             JVMSERVER()
                        DEFINITION-SIGNATURE

                                        DEFINETIME(20/06/18 10:12:25)
                                        CHANGETIME(20/06/18 10:12:25)
                                        CHANGEUSRID(BONNERR)   CHANGEAGENT(CSDBATCH)  CHANGEAGREL(0720)

 PROGRAM(LGDPDB01)      GROUP(GENA)     DESCRIPTION()          LANGUAGE(COBOL)        RELOAD(NO)             20.170 10:11
                                        RESIDENT(NO)           USAGE(NORMAL)          USELPACOPY(NO)
                                        STATUS(ENABLED)        CEDF(YES)              DATALOCATION(ANY)
                                        EXECKEY(USER)          CONCURRENCY(QUASIRENT) API(CICSAPI)
                        REMOTE-ATTRIBUTES
                                        DYNAMIC(NO)            REMOTESYSTEM()         REMOTENAME()
                                        TRANSID()              EXECUTIONSET(FULLAPI)
                        JVM-ATTRIBUTES
                                        JVM(NO)                JVMCLASS()             JVMSERVER()
                        DEFINITION-SIGNATURE

                                        DEFINETIME(20/06/18 10:11:41)
                                        CHANGETIME(20/06/18 10:11:41)
1CICS RDO OFF-LINE UTILITY PROGRAM DFHCSDUP RELEASE:0720 PTF:UI60564 .             TIME 10:12 DATE 20.170      PAGE 0006
-                                       CHANGEUSRID(BONNERR)   CHANGEAGENT(CSDBATCH)  CHANGEAGREL(0720)

 PROGRAM(LGDPOL01)      GROUP(GENA)     DESCRIPTION()          LANGUAGE(COBOL)        RELOAD(NO)             20.170 10:11
                                        RESIDENT(NO)           USAGE(NORMAL)          USELPACOPY(NO)
                                        STATUS(ENABLED)        CEDF(YES)              DATALOCATION(ANY)
                                        EXECKEY(USER)          CONCURRENCY(QUASIRENT) API(CICSAPI)
                        REMOTE-ATTRIBUTES
                                        DYNAMIC(NO)            REMOTESYSTEM()         REMOTENAME()
                                        TRANSID()              EXECUTIONSET(FULLAPI)
                        JVM-ATTRIBUTES
                                        JVM(NO)                JVMCLASS()             JVMSERVER()
                        DEFINITION-SIGNATURE

                                        DEFINETIME(20/06/18 10:11:41)
                                        CHANGETIME(20/06/18 10:11:41)
                                        CHANGEUSRID(BONNERR)   CHANGEAGENT(CSDBATCH)  CHANGEAGREL(0720)

 PROGRAM(LGDPVS01)      GROUP(GENA)     DESCRIPTION()          LANGUAGE(COBOL)        RELOAD(NO)             20.170 10:11
                                        RESIDENT(NO)           USAGE(NORMAL)          USELPACOPY(NO)
                                        STATUS(ENABLED)        CEDF(YES)              DATALOCATION(ANY)
                                        EXECKEY(USER)          CONCURRENCY(QUASIRENT) API(CICSAPI)
                        REMOTE-ATTRIBUTES
                                        DYNAMIC(NO)            REMOTESYSTEM()         REMOTENAME()
                                        TRANSID()              EXECUTIONSET(FULLAPI)
                        JVM-ATTRIBUTES
                                        JVM(NO)                JVMCLASS()             JVMSERVER()
                        DEFINITION-SIGNATURE

                                        DEFINETIME(20/06/18 10:11:41)
                                        CHANGETIME(20/06/18 10:11:41)
                                        CHANGEUSRID(BONNERR)   CHANGEAGENT(CSDBATCH)  CHANGEAGREL(0720)

 PROGRAM(LGICDB01)      GROUP(GENA)     DESCRIPTION()          LANGUAGE(COBOL)        RELOAD(NO)             20.170 10:11
                                        RESIDENT(NO)           USAGE(NORMAL)          USELPACOPY(NO)
                                        STATUS(ENABLED)        CEDF(YES)              DATALOCATION(ANY)
                                        EXECKEY(USER)          CONCURRENCY(QUASIRENT) API(CICSAPI)
                        REMOTE-ATTRIBUTES
                                        DYNAMIC(NO)            REMOTESYSTEM()         REMOTENAME()
                                        TRANSID()              EXECUTIONSET(FULLAPI)
                        JVM-ATTRIBUTES
                                        JVM(NO)                JVMCLASS()             JVMSERVER()
                        DEFINITION-SIGNATURE

                                        DEFINETIME(20/06/18 10:11:41)
                                        CHANGETIME(20/06/18 10:11:41)
                                        CHANGEUSRID(BONNERR)   CHANGEAGENT(CSDBATCH)  CHANGEAGREL(0720)

 PROGRAM(LGICUS01)      GROUP(GENA)     DESCRIPTION()          LANGUAGE(COBOL)        RELOAD(NO)             20.170 10:11
                                        RESIDENT(NO)           USAGE(NORMAL)          USELPACOPY(NO)
                                        STATUS(ENABLED)        CEDF(YES)              DATALOCATION(ANY)
                                        EXECKEY(USER)          CONCURRENCY(QUASIRENT) API(CICSAPI)
                        REMOTE-ATTRIBUTES
                                        DYNAMIC(NO)            REMOTESYSTEM()         REMOTENAME()
                                        TRANSID()              EXECUTIONSET(FULLAPI)
                        JVM-ATTRIBUTES
                                        JVM(NO)                JVMCLASS()             JVMSERVER()
                        DEFINITION-SIGNATURE
1CICS RDO OFF-LINE UTILITY PROGRAM DFHCSDUP RELEASE:0720 PTF:UI60564 .             TIME 10:12 DATE 20.170      PAGE 0007
-
                                        DEFINETIME(20/06/18 10:11:41)
                                        CHANGETIME(20/06/18 10:11:41)
                                        CHANGEUSRID(BONNERR)   CHANGEAGENT(CSDBATCH)  CHANGEAGREL(0720)

 PROGRAM(LGICVS01)      GROUP(GENA)     DESCRIPTION()          LANGUAGE(COBOL)        RELOAD(NO)             20.170 10:11
                                        RESIDENT(NO)           USAGE(NORMAL)          USELPACOPY(NO)
                                        STATUS(ENABLED)        CEDF(YES)              DATALOCATION(ANY)
                                        EXECKEY(USER)          CONCURRENCY(QUASIRENT) API(CICSAPI)
                        REMOTE-ATTRIBUTES
                                        DYNAMIC(NO)            REMOTESYSTEM()         REMOTENAME()
                                        TRANSID()              EXECUTIONSET(FULLAPI)
                        JVM-ATTRIBUTES
                                        JVM(NO)                JVMCLASS()             JVMSERVER()
                        DEFINITION-SIGNATURE

                                        DEFINETIME(20/06/18 10:11:41)
                                        CHANGETIME(20/06/18 10:11:41)
                                        CHANGEUSRID(BONNERR)   CHANGEAGENT(CSDBATCH)  CHANGEAGREL(0720)

 PROGRAM(LGIPDB01)      GROUP(GENA)     DESCRIPTION()          LANGUAGE(COBOL)        RELOAD(NO)             20.170 10:11
                                        RESIDENT(NO)           USAGE(NORMAL)          USELPACOPY(NO)
                                        STATUS(ENABLED)        CEDF(YES)              DATALOCATION(ANY)
                                        EXECKEY(USER)          CONCURRENCY(QUASIRENT) API(CICSAPI)
                        REMOTE-ATTRIBUTES
                                        DYNAMIC(NO)            REMOTESYSTEM()         REMOTENAME()
                                        TRANSID()              EXECUTIONSET(FULLAPI)
                        JVM-ATTRIBUTES
                                        JVM(NO)                JVMCLASS()             JVMSERVER()
                        DEFINITION-SIGNATURE

                                        DEFINETIME(20/06/18 10:11:41)
                                        CHANGETIME(20/06/18 10:11:41)
                                        CHANGEUSRID(BONNERR)   CHANGEAGENT(CSDBATCH)  CHANGEAGREL(0720)

 PROGRAM(LGIPOL01)      GROUP(GENA)     DESCRIPTION()          LANGUAGE(COBOL)        RELOAD(NO)             20.170 10:11
                                        RESIDENT(NO)           USAGE(NORMAL)          USELPACOPY(NO)
                                        STATUS(ENABLED)        CEDF(YES)              DATALOCATION(ANY)
                                        EXECKEY(USER)          CONCURRENCY(QUASIRENT) API(CICSAPI)
                        REMOTE-ATTRIBUTES
                                        DYNAMIC(NO)            REMOTESYSTEM()         REMOTENAME()
                                        TRANSID()              EXECUTIONSET(FULLAPI)
                        JVM-ATTRIBUTES
                                        JVM(NO)                JVMCLASS()             JVMSERVER()
                        DEFINITION-SIGNATURE

                                        DEFINETIME(20/06/18 10:11:41)
                                        CHANGETIME(20/06/18 10:11:41)
                                        CHANGEUSRID(BONNERR)   CHANGEAGENT(CSDBATCH)  CHANGEAGREL(0720)

 PROGRAM(LGIPVS01)      GROUP(GENA)     DESCRIPTION()          LANGUAGE(COBOL)        RELOAD(NO)             20.170 10:11
                                        RESIDENT(NO)           USAGE(NORMAL)          USELPACOPY(NO)
                                        STATUS(ENABLED)        CEDF(YES)              DATALOCATION(ANY)
                                        EXECKEY(USER)          CONCURRENCY(QUASIRENT) API(CICSAPI)
                        REMOTE-ATTRIBUTES
                                        DYNAMIC(NO)            REMOTESYSTEM()         REMOTENAME()
                                        TRANSID()              EXECUTIONSET(FULLAPI)
1CICS RDO OFF-LINE UTILITY PROGRAM DFHCSDUP RELEASE:0720 PTF:UI60564 .             TIME 10:12 DATE 20.170      PAGE 0008
-                       JVM-ATTRIBUTES
                                        JVM(NO)                JVMCLASS()             JVMSERVER()
                        DEFINITION-SIGNATURE

                                        DEFINETIME(20/06/18 10:11:41)
                                        CHANGETIME(20/06/18 10:11:41)
                                        CHANGEUSRID(BONNERR)   CHANGEAGENT(CSDBATCH)  CHANGEAGREL(0720)

 PROGRAM(LGSETUP)       GROUP(GENA)                                                                          20.170 10:11
                                        DESCRIPTION(Initial setup of TSQueue)
                                        LANGUAGE(COBOL)        RELOAD(NO)             RESIDENT(NO)
                                        USAGE(NORMAL)          USELPACOPY(NO)         STATUS(ENABLED)
                                        CEDF(YES)              DATALOCATION(ANY)      EXECKEY(USER)
                                        CONCURRENCY(QUASIRENT) API(CICSAPI)
                        REMOTE-ATTRIBUTES
                                        DYNAMIC(NO)            REMOTESYSTEM()         REMOTENAME()
                                        TRANSID()              EXECUTIONSET(FULLAPI)
                        JVM-ATTRIBUTES
                                        JVM(NO)                JVMCLASS()             JVMSERVER()
                        DEFINITION-SIGNATURE

                                        DEFINETIME(20/06/18 10:11:41)
                                        CHANGETIME(20/06/18 10:11:41)
                                        CHANGEUSRID(BONNERR)   CHANGEAGENT(CSDBATCH)  CHANGEAGREL(0720)

 PROGRAM(LGSTSQ)        GROUP(GENA)                                                                          20.170 10:11
                                        DESCRIPTION(Message output to TSQueues)
                                        LANGUAGE(COBOL)        RELOAD(NO)             RESIDENT(NO)
                                        USAGE(NORMAL)          USELPACOPY(NO)         STATUS(ENABLED)
                                        CEDF(YES)              DATALOCATION(ANY)      EXECKEY(USER)
                                        CONCURRENCY(QUASIRENT) API(CICSAPI)
                        REMOTE-ATTRIBUTES
                                        DYNAMIC(NO)            REMOTESYSTEM()         REMOTENAME()
                                        TRANSID()              EXECUTIONSET(FULLAPI)
                        JVM-ATTRIBUTES
                                        JVM(NO)                JVMCLASS()             JVMSERVER()
                        DEFINITION-SIGNATURE

                                        DEFINETIME(20/06/18 10:11:41)
                                        CHANGETIME(20/06/18 10:11:41)
                                        CHANGEUSRID(BONNERR)   CHANGEAGENT(CSDBATCH)  CHANGEAGREL(0720)

 PROGRAM(LGTESTC1)      GROUP(GENA)                                                                          20.170 10:11
                                        DESCRIPTION(Solution Customer Menu)
                                        LANGUAGE(COBOL)        RELOAD(NO)             RESIDENT(NO)
                                        USAGE(NORMAL)          USELPACOPY(NO)         STATUS(ENABLED)
                                        CEDF(YES)              DATALOCATION(ANY)      EXECKEY(USER)
                                        CONCURRENCY(QUASIRENT) API(CICSAPI)
                        REMOTE-ATTRIBUTES
                                        DYNAMIC(NO)            REMOTESYSTEM()         REMOTENAME()
                                        TRANSID()              EXECUTIONSET(FULLAPI)
                        JVM-ATTRIBUTES
                                        JVM(NO)                JVMCLASS()             JVMSERVER()
                        DEFINITION-SIGNATURE

                                        DEFINETIME(20/06/18 10:11:41)
                                        CHANGETIME(20/06/18 10:11:41)
1CICS RDO OFF-LINE UTILITY PROGRAM DFHCSDUP RELEASE:0720 PTF:UI60564 .             TIME 10:12 DATE 20.170      PAGE 0009
-                                       CHANGEUSRID(BONNERR)   CHANGEAGENT(CSDBATCH)  CHANGEAGREL(0720)

 PROGRAM(LGTESTP1)      GROUP(GENA)                                                                          20.170 10:11
                                        DESCRIPTION(Solution Motor Policy Menu)
                                        LANGUAGE(COBOL)        RELOAD(NO)             RESIDENT(NO)
                                        USAGE(NORMAL)          USELPACOPY(NO)         STATUS(ENABLED)
                                        CEDF(YES)              DATALOCATION(ANY)      EXECKEY(USER)
                                        CONCURRENCY(QUASIRENT) API(CICSAPI)
                        REMOTE-ATTRIBUTES
                                        DYNAMIC(NO)            REMOTESYSTEM()         REMOTENAME()
                                        TRANSID()              EXECUTIONSET(FULLAPI)
                        JVM-ATTRIBUTES
                                        JVM(NO)                JVMCLASS()             JVMSERVER()
                        DEFINITION-SIGNATURE

                                        DEFINETIME(20/06/18 10:11:41)
                                        CHANGETIME(20/06/18 10:11:41)
                                        CHANGEUSRID(BONNERR)   CHANGEAGENT(CSDBATCH)  CHANGEAGREL(0720)

 PROGRAM(LGTESTP2)      GROUP(GENA)                                                                          20.170 10:11
                                        DESCRIPTION(Solution Life Policy Menu)
                                        LANGUAGE(COBOL)        RELOAD(NO)             RESIDENT(NO)
                                        USAGE(NORMAL)          USELPACOPY(NO)         STATUS(ENABLED)
                                        CEDF(YES)              DATALOCATION(ANY)      EXECKEY(USER)
                                        CONCURRENCY(QUASIRENT) API(CICSAPI)
                        REMOTE-ATTRIBUTES
                                        DYNAMIC(NO)            REMOTESYSTEM()         REMOTENAME()
                                        TRANSID()              EXECUTIONSET(FULLAPI)
                        JVM-ATTRIBUTES
                                        JVM(NO)                JVMCLASS()             JVMSERVER()
                        DEFINITION-SIGNATURE

                                        DEFINETIME(20/06/18 10:11:41)
                                        CHANGETIME(20/06/18 10:11:41)
                                        CHANGEUSRID(BONNERR)   CHANGEAGENT(CSDBATCH)  CHANGEAGREL(0720)

 PROGRAM(LGTESTP3)      GROUP(GENA)                                                                          20.170 10:11
                                        DESCRIPTION(Solution House Policy Menu)
                                        LANGUAGE(COBOL)        RELOAD(NO)             RESIDENT(NO)
                                        USAGE(NORMAL)          USELPACOPY(NO)         STATUS(ENABLED)
                                        CEDF(YES)              DATALOCATION(ANY)      EXECKEY(USER)
                                        CONCURRENCY(QUASIRENT) API(CICSAPI)
                        REMOTE-ATTRIBUTES
                                        DYNAMIC(NO)            REMOTESYSTEM()         REMOTENAME()
                                        TRANSID()              EXECUTIONSET(FULLAPI)
                        JVM-ATTRIBUTES
                                        JVM(NO)                JVMCLASS()             JVMSERVER()
                        DEFINITION-SIGNATURE

                                        DEFINETIME(20/06/18 10:11:41)
                                        CHANGETIME(20/06/18 10:11:41)
                                        CHANGEUSRID(BONNERR)   CHANGEAGENT(CSDBATCH)  CHANGEAGREL(0720)

 PROGRAM(LGTESTP4)      GROUP(GENA)                                                                          20.170 10:11
                                        DESCRIPTION(Solution Commercial Policy Menu)
                                        LANGUAGE(COBOL)        RELOAD(NO)             RESIDENT(NO)
                                        USAGE(NORMAL)          USELPACOPY(NO)         STATUS(ENABLED)
1CICS RDO OFF-LINE UTILITY PROGRAM DFHCSDUP RELEASE:0720 PTF:UI60564 .             TIME 10:12 DATE 20.170      PAGE 0010
-                                       CEDF(YES)              DATALOCATION(ANY)      EXECKEY(USER)
                                        CONCURRENCY(QUASIRENT) API(CICSAPI)
                        REMOTE-ATTRIBUTES
                                        DYNAMIC(NO)            REMOTESYSTEM()         REMOTENAME()
                                        TRANSID()              EXECUTIONSET(FULLAPI)
                        JVM-ATTRIBUTES
                                        JVM(NO)                JVMCLASS()             JVMSERVER()
                        DEFINITION-SIGNATURE

                                        DEFINETIME(20/06/18 10:11:41)
                                        CHANGETIME(20/06/18 10:11:41)
                                        CHANGEUSRID(BONNERR)   CHANGEAGENT(CSDBATCH)  CHANGEAGREL(0720)

 PROGRAM(LGUCDB01)      GROUP(GENA)     DESCRIPTION()          LANGUAGE(COBOL)        RELOAD(NO)             20.170 10:11
                                        RESIDENT(NO)           USAGE(NORMAL)          USELPACOPY(NO)
                                        STATUS(ENABLED)        CEDF(YES)              DATALOCATION(ANY)
                                        EXECKEY(USER)          CONCURRENCY(QUASIRENT) API(CICSAPI)
                        REMOTE-ATTRIBUTES
                                        DYNAMIC(NO)            REMOTESYSTEM()         REMOTENAME()
                                        TRANSID()              EXECUTIONSET(FULLAPI)
                        JVM-ATTRIBUTES
                                        JVM(NO)                JVMCLASS()             JVMSERVER()
                        DEFINITION-SIGNATURE

                                        DEFINETIME(20/06/18 10:11:41)
                                        CHANGETIME(20/06/18 10:11:41)
                                        CHANGEUSRID(BONNERR)   CHANGEAGENT(CSDBATCH)  CHANGEAGREL(0720)

 PROGRAM(LGUCUS01)      GROUP(GENA)     DESCRIPTION()          LANGUAGE(COBOL)        RELOAD(NO)             20.170 10:11
                                        RESIDENT(NO)           USAGE(NORMAL)          USELPACOPY(NO)
                                        STATUS(ENABLED)        CEDF(YES)              DATALOCATION(ANY)
                                        EXECKEY(USER)          CONCURRENCY(QUASIRENT) API(CICSAPI)
                        REMOTE-ATTRIBUTES
                                        DYNAMIC(NO)            REMOTESYSTEM()         REMOTENAME()
                                        TRANSID()              EXECUTIONSET(FULLAPI)
                        JVM-ATTRIBUTES
                                        JVM(NO)                JVMCLASS()             JVMSERVER()
                        DEFINITION-SIGNATURE

                                        DEFINETIME(20/06/18 10:11:41)
                                        CHANGETIME(20/06/18 10:11:41)
                                        CHANGEUSRID(BONNERR)   CHANGEAGENT(CSDBATCH)  CHANGEAGREL(0720)

 PROGRAM(LGUCVS01)      GROUP(GENA)     DESCRIPTION()          LANGUAGE(COBOL)        RELOAD(NO)             20.170 10:11
                                        RESIDENT(NO)           USAGE(NORMAL)          USELPACOPY(NO)
                                        STATUS(ENABLED)        CEDF(YES)              DATALOCATION(ANY)
                                        EXECKEY(USER)          CONCURRENCY(QUASIRENT) API(CICSAPI)
                        REMOTE-ATTRIBUTES
                                        DYNAMIC(NO)            REMOTESYSTEM()         REMOTENAME()
                                        TRANSID()              EXECUTIONSET(FULLAPI)
                        JVM-ATTRIBUTES
                                        JVM(NO)                JVMCLASS()             JVMSERVER()
                        DEFINITION-SIGNATURE

                                        DEFINETIME(20/06/18 10:11:41)
                                        CHANGETIME(20/06/18 10:11:41)
                                        CHANGEUSRID(BONNERR)   CHANGEAGENT(CSDBATCH)  CHANGEAGREL(0720)
1CICS RDO OFF-LINE UTILITY PROGRAM DFHCSDUP RELEASE:0720 PTF:UI60564 .             TIME 10:12 DATE 20.170      PAGE 0011
-
 PROGRAM(LGUPDB01)      GROUP(GENA)     DESCRIPTION()          LANGUAGE(COBOL)        RELOAD(NO)             20.170 10:11
                                        RESIDENT(NO)           USAGE(NORMAL)          USELPACOPY(NO)
                                        STATUS(ENABLED)        CEDF(YES)              DATALOCATION(ANY)
                                        EXECKEY(USER)          CONCURRENCY(QUASIRENT) API(CICSAPI)
                        REMOTE-ATTRIBUTES
                                        DYNAMIC(NO)            REMOTESYSTEM()         REMOTENAME()
                                        TRANSID()              EXECUTIONSET(FULLAPI)
                        JVM-ATTRIBUTES
                                        JVM(NO)                JVMCLASS()             JVMSERVER()
                        DEFINITION-SIGNATURE

                                        DEFINETIME(20/06/18 10:11:41)
                                        CHANGETIME(20/06/18 10:11:41)
                                        CHANGEUSRID(BONNERR)   CHANGEAGENT(CSDBATCH)  CHANGEAGREL(0720)

 PROGRAM(LGUPOL01)      GROUP(GENA)     DESCRIPTION()          LANGUAGE(COBOL)        RELOAD(NO)             20.170 10:11
                                        RESIDENT(NO)           USAGE(NORMAL)          USELPACOPY(NO)
                                        STATUS(ENABLED)        CEDF(YES)              DATALOCATION(ANY)
                                        EXECKEY(USER)          CONCURRENCY(QUASIRENT) API(CICSAPI)
                        REMOTE-ATTRIBUTES
                                        DYNAMIC(NO)            REMOTESYSTEM()         REMOTENAME()
                                        TRANSID()              EXECUTIONSET(FULLAPI)
                        JVM-ATTRIBUTES
                                        JVM(NO)                JVMCLASS()             JVMSERVER()
                        DEFINITION-SIGNATURE

                                        DEFINETIME(20/06/18 10:11:41)
                                        CHANGETIME(20/06/18 10:11:41)
                                        CHANGEUSRID(BONNERR)   CHANGEAGENT(CSDBATCH)  CHANGEAGREL(0720)

 PROGRAM(LGUPVS01)      GROUP(GENA)     DESCRIPTION()          LANGUAGE(COBOL)        RELOAD(NO)             20.170 10:11
                                        RESIDENT(NO)           USAGE(NORMAL)          USELPACOPY(NO)
                                        STATUS(ENABLED)        CEDF(YES)              DATALOCATION(ANY)
                                        EXECKEY(USER)          CONCURRENCY(QUASIRENT) API(CICSAPI)
                        REMOTE-ATTRIBUTES
                                        DYNAMIC(NO)            REMOTESYSTEM()         REMOTENAME()
                                        TRANSID()              EXECUTIONSET(FULLAPI)
                        JVM-ATTRIBUTES
                                        JVM(NO)                JVMCLASS()             JVMSERVER()
                        DEFINITION-SIGNATURE

                                        DEFINETIME(20/06/18 10:11:41)
                                        CHANGETIME(20/06/18 10:11:41)
                                        CHANGEUSRID(BONNERR)   CHANGEAGENT(CSDBATCH)  CHANGEAGREL(0720)

 PROGRAM(LGWEBST5)      GROUP(GENA)     DESCRIPTION()          LANGUAGE()             RELOAD(NO)             20.170 10:12
                                        RESIDENT(NO)           USAGE(NORMAL)          USELPACOPY(NO)
                                        STATUS(ENABLED)        CEDF(YES)              DATALOCATION(ANY)
                                        EXECKEY(USER)          CONCURRENCY(QUASIRENT) API(CICSAPI)
                        REMOTE-ATTRIBUTES
                                        DYNAMIC(NO)            REMOTESYSTEM()         REMOTENAME()
                                        TRANSID()              EXECUTIONSET(FULLAPI)
                        JVM-ATTRIBUTES
                                        JVM(NO)                JVMCLASS()             JVMSERVER()
                        DEFINITION-SIGNATURE

1CICS RDO OFF-LINE UTILITY PROGRAM DFHCSDUP RELEASE:0720 PTF:UI60564 .             TIME 10:12 DATE 20.170      PAGE 0012
-                                       DEFINETIME(20/06/18 10:12:25)
                                        CHANGETIME(20/06/18 10:12:25)
                                        CHANGEUSRID(BONNERR)   CHANGEAGENT(CSDBATCH)  CHANGEAGREL(0720)

 PROGRAM(SSMAP)         GROUP(GENA)     DESCRIPTION(BMS Map)   LANGUAGE(COBOL)        RELOAD(NO)             20.170 10:11
                                        RESIDENT(NO)           USAGE(NORMAL)          USELPACOPY(NO)
                                        STATUS(ENABLED)        CEDF(YES)              DATALOCATION(ANY)
                                        EXECKEY(USER)          CONCURRENCY(QUASIRENT) API(CICSAPI)
                        REMOTE-ATTRIBUTES
                                        DYNAMIC(NO)            REMOTESYSTEM()         REMOTENAME()
                                        TRANSID()              EXECUTIONSET(FULLAPI)
                        JVM-ATTRIBUTES
                                        JVM(NO)                JVMCLASS()             JVMSERVER()
                        DEFINITION-SIGNATURE

                                        DEFINETIME(20/06/18 10:11:41)
                                        CHANGETIME(20/06/18 10:11:41)
                                        CHANGEUSRID(BONNERR)   CHANGEAGENT(CSDBATCH)  CHANGEAGREL(0720)

 TRANSACTION(LGCF)      GROUP(GENA)     DESCRIPTION()          PROGRAM(LGICVS01)      TWASIZE(0)             20.170 10:11
                                        PROFILE(DFHCICST)      PARTITIONSET()         STATUS(ENABLED)
                                        TASKDATALOC(ANY)       TASKDATAKEY(USER)      STORAGECLEAR(NO)
                                        RUNAWAY(SYSTEM)        SHUTDOWN(DISABLED)     ISOLATE(YES)
                                        BREXIT()
                        REMOTE-ATTRIBUTES
                                        DYNAMIC(NO)            ROUTABLE(NO)           REMOTESYSTEM()
                                        REMOTENAME()           TRPROF()               LOCALQ()
                        SCHEDULING
                                        PRIORITY(1)            TRANCLASS(DFHTCL00)
                        ALIASES
                                        ALIAS()                TASKREQ()              XTRANID()
                                        TPNAME()               XTPNAME()
                        RECOVERY
                                        DTIMOUT(NO)            RESTART(NO)            SPURGE(YES)
                                        TPURGE(YES)            DUMP(YES)              TRACE(YES)
                                        CONFDATA(NO)           OTSTIMEOUT(NO)
                        INDOUBT-ATTRIBUTES
                                        ACTION(BACKOUT)        WAIT(YES)              WAITTIME(0,0,0)
                        SECURITY
                                        RESSEC(NO)             CMDSEC(NO)
                        DEFINITION-SIGNATURE

                                        DEFINETIME(20/06/18 10:11:41)
                                        CHANGETIME(20/06/18 10:11:41)
                                        CHANGEUSRID(BONNERR)   CHANGEAGENT(CSDBATCH)  CHANGEAGREL(0720)

 TRANSACTION(LGPF)      GROUP(GENA)     DESCRIPTION()          PROGRAM(LGIPVS01)      TWASIZE(0)             20.170 10:11
                                        PROFILE(DFHCICST)      PARTITIONSET()         STATUS(ENABLED)
                                        TASKDATALOC(ANY)       TASKDATAKEY(USER)      STORAGECLEAR(NO)
                                        RUNAWAY(SYSTEM)        SHUTDOWN(DISABLED)     ISOLATE(YES)
                                        BREXIT()
                        REMOTE-ATTRIBUTES
                                        DYNAMIC(NO)            ROUTABLE(NO)           REMOTESYSTEM()
                                        REMOTENAME()           TRPROF()               LOCALQ()
                        SCHEDULING
                                        PRIORITY(1)            TRANCLASS(DFHTCL00)
                        ALIASES
1CICS RDO OFF-LINE UTILITY PROGRAM DFHCSDUP RELEASE:0720 PTF:UI60564 .             TIME 10:12 DATE 20.170      PAGE 0013
-                                       ALIAS()                TASKREQ()              XTRANID()
                                        TPNAME()               XTPNAME()
                        RECOVERY
                                        DTIMOUT(NO)            RESTART(NO)            SPURGE(YES)
                                        TPURGE(YES)            DUMP(YES)              TRACE(YES)
                                        CONFDATA(NO)           OTSTIMEOUT(NO)
                        INDOUBT-ATTRIBUTES
                                        ACTION(BACKOUT)        WAIT(YES)              WAITTIME(0,0,0)
                        SECURITY
                                        RESSEC(NO)             CMDSEC(NO)
                        DEFINITION-SIGNATURE

                                        DEFINETIME(20/06/18 10:11:41)
                                        CHANGETIME(20/06/18 10:11:41)
                                        CHANGEUSRID(BONNERR)   CHANGEAGENT(CSDBATCH)  CHANGEAGREL(0720)

 TRANSACTION(LGSE)      GROUP(GENA)     DESCRIPTION()          PROGRAM(LGSETUP)       TWASIZE(0)             20.170 10:11
                                        PROFILE(DFHCICST)      PARTITIONSET()         STATUS(ENABLED)
                                        TASKDATALOC(ANY)       TASKDATAKEY(USER)      STORAGECLEAR(NO)
                                        RUNAWAY(SYSTEM)        SHUTDOWN(DISABLED)     ISOLATE(YES)
                                        BREXIT()
                        REMOTE-ATTRIBUTES
                                        DYNAMIC(NO)            ROUTABLE(NO)           REMOTESYSTEM()
                                        REMOTENAME()           TRPROF()               LOCALQ()
                        SCHEDULING
                                        PRIORITY(1)            TRANCLASS(DFHTCL00)
                        ALIASES
                                        ALIAS()                TASKREQ()              XTRANID()
                                        TPNAME()               XTPNAME()
                        RECOVERY
                                        DTIMOUT(NO)            RESTART(NO)            SPURGE(YES)
                                        TPURGE(YES)            DUMP(YES)              TRACE(YES)
                                        CONFDATA(NO)           OTSTIMEOUT(NO)
                        INDOUBT-ATTRIBUTES
                                        ACTION(BACKOUT)        WAIT(YES)              WAITTIME(0,0,0)
                        SECURITY
                                        RESSEC(NO)             CMDSEC(NO)
                        DEFINITION-SIGNATURE

                                        DEFINETIME(20/06/18 10:11:41)
                                        CHANGETIME(20/06/18 10:11:41)
                                        CHANGEUSRID(BONNERR)   CHANGEAGENT(CSDBATCH)  CHANGEAGREL(0720)

 TRANSACTION(LGST)      GROUP(GENA)     DESCRIPTION()          PROGRAM(LGASTAT1)      TWASIZE(0)             20.170 10:12
                                        PROFILE(DFHCICST)      PARTITIONSET()         STATUS(ENABLED)
                                        TASKDATALOC(ANY)       TASKDATAKEY(USER)      STORAGECLEAR(NO)
                                        RUNAWAY(SYSTEM)        SHUTDOWN(DISABLED)     ISOLATE(YES)
                                        BREXIT()
                        REMOTE-ATTRIBUTES
                                        DYNAMIC(NO)            ROUTABLE(NO)           REMOTESYSTEM()
                                        REMOTENAME()           TRPROF()               LOCALQ()
                        SCHEDULING
                                        PRIORITY(1)            TRANCLASS(DFHTCL00)
                        ALIASES
                                        ALIAS()                TASKREQ()              XTRANID()
                                        TPNAME()               XTPNAME()
                        RECOVERY
1CICS RDO OFF-LINE UTILITY PROGRAM DFHCSDUP RELEASE:0720 PTF:UI60564 .             TIME 10:12 DATE 20.170      PAGE 0014
-                                       DTIMOUT(NO)            RESTART(NO)            SPURGE(YES)
                                        TPURGE(YES)            DUMP(YES)              TRACE(YES)
                                        CONFDATA(NO)           OTSTIMEOUT(NO)
                        INDOUBT-ATTRIBUTES
                                        ACTION(BACKOUT)        WAIT(YES)              WAITTIME(0,0,0)
                        SECURITY
                                        RESSEC(NO)             CMDSEC(NO)
                        DEFINITION-SIGNATURE

                                        DEFINETIME(20/06/18 10:12:25)
                                        CHANGETIME(20/06/18 10:12:25)
                                        CHANGEUSRID(BONNERR)   CHANGEAGENT(CSDBATCH)  CHANGEAGREL(0720)

 TRANSACTION(SSC1)      GROUP(GENA)     DESCRIPTION()          PROGRAM(LGTESTC1)      TWASIZE(0)             20.170 10:11
                                        PROFILE(DFHCICST)      PARTITIONSET()         STATUS(ENABLED)
                                        TASKDATALOC(ANY)       TASKDATAKEY(USER)      STORAGECLEAR(NO)
                                        RUNAWAY(SYSTEM)        SHUTDOWN(DISABLED)     ISOLATE(YES)
                                        BREXIT()
                        REMOTE-ATTRIBUTES
                                        DYNAMIC(NO)            ROUTABLE(NO)           REMOTESYSTEM()
                                        REMOTENAME()           TRPROF()               LOCALQ()
                        SCHEDULING
                                        PRIORITY(1)            TRANCLASS(DFHTCL00)
                        ALIASES
                                        ALIAS()                TASKREQ()              XTRANID()
                                        TPNAME()               XTPNAME()
                        RECOVERY
                                        DTIMOUT(NO)            RESTART(NO)            SPURGE(YES)
                                        TPURGE(YES)            DUMP(YES)              TRACE(YES)
                                        CONFDATA(NO)           OTSTIMEOUT(NO)
                        INDOUBT-ATTRIBUTES
                                        ACTION(BACKOUT)        WAIT(YES)              WAITTIME(0,0,0)
                        SECURITY
                                        RESSEC(NO)             CMDSEC(NO)
                        DEFINITION-SIGNATURE

                                        DEFINETIME(20/06/18 10:11:41)
                                        CHANGETIME(20/06/18 10:11:41)
                                        CHANGEUSRID(BONNERR)   CHANGEAGENT(CSDBATCH)  CHANGEAGREL(0720)

 TRANSACTION(SSP1)      GROUP(GENA)     DESCRIPTION()          PROGRAM(LGTESTP1)      TWASIZE(0)             20.170 10:11
                                        PROFILE(DFHCICST)      PARTITIONSET()         STATUS(ENABLED)
                                        TASKDATALOC(ANY)       TASKDATAKEY(USER)      STORAGECLEAR(NO)
                                        RUNAWAY(SYSTEM)        SHUTDOWN(DISABLED)     ISOLATE(YES)
                                        BREXIT()
                        REMOTE-ATTRIBUTES
                                        DYNAMIC(NO)            ROUTABLE(NO)           REMOTESYSTEM()
                                        REMOTENAME()           TRPROF()               LOCALQ()
                        SCHEDULING
                                        PRIORITY(1)            TRANCLASS(DFHTCL00)
                        ALIASES
                                        ALIAS()                TASKREQ()              XTRANID()
                                        TPNAME()               XTPNAME()
                        RECOVERY
                                        DTIMOUT(NO)            RESTART(NO)            SPURGE(YES)
                                        TPURGE(YES)            DUMP(YES)              TRACE(YES)
                                        CONFDATA(NO)           OTSTIMEOUT(NO)
1CICS RDO OFF-LINE UTILITY PROGRAM DFHCSDUP RELEASE:0720 PTF:UI60564 .             TIME 10:12 DATE 20.170      PAGE 0015
-                       INDOUBT-ATTRIBUTES
                                        ACTION(BACKOUT)        WAIT(YES)              WAITTIME(0,0,0)
                        SECURITY
                                        RESSEC(NO)             CMDSEC(NO)
                        DEFINITION-SIGNATURE

                                        DEFINETIME(20/06/18 10:11:41)
                                        CHANGETIME(20/06/18 10:11:41)
                                        CHANGEUSRID(BONNERR)   CHANGEAGENT(CSDBATCH)  CHANGEAGREL(0720)

 TRANSACTION(SSP2)      GROUP(GENA)     DESCRIPTION()          PROGRAM(LGTESTP2)      TWASIZE(0)             20.170 10:11
                                        PROFILE(DFHCICST)      PARTITIONSET()         STATUS(ENABLED)
                                        TASKDATALOC(ANY)       TASKDATAKEY(USER)      STORAGECLEAR(NO)
                                        RUNAWAY(SYSTEM)        SHUTDOWN(DISABLED)     ISOLATE(YES)
                                        BREXIT()
                        REMOTE-ATTRIBUTES
                                        DYNAMIC(NO)            ROUTABLE(NO)           REMOTESYSTEM()
                                        REMOTENAME()           TRPROF()               LOCALQ()
                        SCHEDULING
                                        PRIORITY(1)            TRANCLASS(DFHTCL00)
                        ALIASES
                                        ALIAS()                TASKREQ()              XTRANID()
                                        TPNAME()               XTPNAME()
                        RECOVERY
                                        DTIMOUT(NO)            RESTART(NO)            SPURGE(YES)
                                        TPURGE(YES)            DUMP(YES)              TRACE(YES)
                                        CONFDATA(NO)           OTSTIMEOUT(NO)
                        INDOUBT-ATTRIBUTES
                                        ACTION(BACKOUT)        WAIT(YES)              WAITTIME(0,0,0)
                        SECURITY
                                        RESSEC(NO)             CMDSEC(NO)
                        DEFINITION-SIGNATURE

                                        DEFINETIME(20/06/18 10:11:41)
                                        CHANGETIME(20/06/18 10:11:41)
                                        CHANGEUSRID(BONNERR)   CHANGEAGENT(CSDBATCH)  CHANGEAGREL(0720)

 TRANSACTION(SSP3)      GROUP(GENA)     DESCRIPTION()          PROGRAM(LGTESTP3)      TWASIZE(0)             20.170 10:11
                                        PROFILE(DFHCICST)      PARTITIONSET()         STATUS(ENABLED)
                                        TASKDATALOC(ANY)       TASKDATAKEY(USER)      STORAGECLEAR(NO)
                                        RUNAWAY(SYSTEM)        SHUTDOWN(DISABLED)     ISOLATE(YES)
                                        BREXIT()
                        REMOTE-ATTRIBUTES
                                        DYNAMIC(NO)            ROUTABLE(NO)           REMOTESYSTEM()
                                        REMOTENAME()           TRPROF()               LOCALQ()
                        SCHEDULING
                                        PRIORITY(1)            TRANCLASS(DFHTCL00)
                        ALIASES
                                        ALIAS()                TASKREQ()              XTRANID()
                                        TPNAME()               XTPNAME()
                        RECOVERY
                                        DTIMOUT(NO)            RESTART(NO)            SPURGE(YES)
                                        TPURGE(YES)            DUMP(YES)              TRACE(YES)
                                        CONFDATA(NO)           OTSTIMEOUT(NO)
                        INDOUBT-ATTRIBUTES
                                        ACTION(BACKOUT)        WAIT(YES)              WAITTIME(0,0,0)
                        SECURITY
1CICS RDO OFF-LINE UTILITY PROGRAM DFHCSDUP RELEASE:0720 PTF:UI60564 .             TIME 10:12 DATE 20.170      PAGE 0016
-                                       RESSEC(NO)             CMDSEC(NO)
                        DEFINITION-SIGNATURE

                                        DEFINETIME(20/06/18 10:11:41)
                                        CHANGETIME(20/06/18 10:11:41)
                                        CHANGEUSRID(BONNERR)   CHANGEAGENT(CSDBATCH)  CHANGEAGREL(0720)

 TRANSACTION(SSP4)      GROUP(GENA)     DESCRIPTION()          PROGRAM(LGTESTP4)      TWASIZE(0)             20.170 10:11
                                        PROFILE(DFHCICST)      PARTITIONSET()         STATUS(ENABLED)
                                        TASKDATALOC(ANY)       TASKDATAKEY(USER)      STORAGECLEAR(NO)
                                        RUNAWAY(SYSTEM)        SHUTDOWN(DISABLED)     ISOLATE(YES)
                                        BREXIT()
                        REMOTE-ATTRIBUTES
                                        DYNAMIC(NO)            ROUTABLE(NO)           REMOTESYSTEM()
                                        REMOTENAME()           TRPROF()               LOCALQ()
                        SCHEDULING
                                        PRIORITY(1)            TRANCLASS(DFHTCL00)
                        ALIASES
                                        ALIAS()                TASKREQ()              XTRANID()
                                        TPNAME()               XTPNAME()
                        RECOVERY
                                        DTIMOUT(NO)            RESTART(NO)            SPURGE(YES)
                                        TPURGE(YES)            DUMP(YES)              TRACE(YES)
                                        CONFDATA(NO)           OTSTIMEOUT(NO)
                        INDOUBT-ATTRIBUTES
                                        ACTION(BACKOUT)        WAIT(YES)              WAITTIME(0,0,0)
                        SECURITY
                                        RESSEC(NO)             CMDSEC(NO)
                        DEFINITION-SIGNATURE

                                        DEFINETIME(20/06/18 10:11:41)
                                        CHANGETIME(20/06/18 10:11:41)
                                        CHANGEUSRID(BONNERR)   CHANGEAGENT(CSDBATCH)  CHANGEAGREL(0720)

 TRANSACTION(SSST)      GROUP(GENA)     DESCRIPTION()          PROGRAM(LGWEBST5)      TWASIZE(0)             20.170 10:12
                                        PROFILE(DFHCICST)      PARTITIONSET()         STATUS(ENABLED)
                                        TASKDATALOC(ANY)       TASKDATAKEY(USER)      STORAGECLEAR(NO)
                                        RUNAWAY(SYSTEM)        SHUTDOWN(DISABLED)     ISOLATE(YES)
                                        BREXIT()
                        REMOTE-ATTRIBUTES
                                        DYNAMIC(NO)            ROUTABLE(NO)           REMOTESYSTEM()
                                        REMOTENAME()           TRPROF()               LOCALQ()
                        SCHEDULING
                                        PRIORITY(1)            TRANCLASS(DFHTCL00)
                        ALIASES
                                        ALIAS()                TASKREQ()              XTRANID()
                                        TPNAME()               XTPNAME()
                        RECOVERY
                                        DTIMOUT(NO)            RESTART(NO)            SPURGE(YES)
                                        TPURGE(YES)            DUMP(YES)              TRACE(YES)
                                        CONFDATA(NO)           OTSTIMEOUT(NO)
                        INDOUBT-ATTRIBUTES
                                        ACTION(BACKOUT)        WAIT(YES)              WAITTIME(0,0,0)
                        SECURITY
                                        RESSEC(NO)             CMDSEC(NO)
                        DEFINITION-SIGNATURE

1CICS RDO OFF-LINE UTILITY PROGRAM DFHCSDUP RELEASE:0720 PTF:UI60564 .             TIME 10:12 DATE 20.170      PAGE 0017
-                                       DEFINETIME(20/06/18 10:12:25)
                                        CHANGETIME(20/06/18 10:12:25)
                                        CHANGEUSRID(BONNERR)   CHANGEAGENT(CSDBATCH)  CHANGEAGREL(0720)

 ENQMODEL(GENAMOD)      GROUP(GENA)                                                                          20.170 10:11
                                        DESCRIPTION(GRS for GENAPP)
                                        ENQSCOPE(GENA)         STATUS(ENABLED)        ENQNAME(GENACNTL)
                        DEFINITION-SIGNATURE

                                        DEFINETIME(20/06/18 10:11:41)
                                        CHANGETIME(20/06/18 10:11:41)
                                        CHANGEUSRID(BONNERR)   CHANGEAGENT(CSDBATCH)  CHANGEAGREL(0720)

 BUNDLE(GENAEV01)       GROUP(GENA)     DESCRIPTION()          STATUS(ENABLED)                               20.170 10:12
                                        BUNDLEDIR(/u/s8smith/genapp/genapp)
                                        BASESCOPE()
                        DEFINITION-SIGNATURE

                                        DEFINETIME(20/06/18 10:12:25)
                                        CHANGETIME(20/06/18 10:12:25)
                                        CHANGEUSRID(BONNERR)   CHANGEAGENT(CSDBATCH)  CHANGEAGREL(0720)

 ************************************************************************************************************************


 ************************************************************************************************************************
1CICS RDO OFF-LINE UTILITY PROGRAM DFHCSDUP RELEASE:0720 PTF:UI60564 .             TIME 10:12 DATE 20.170      PAGE 0018
-
 DFH5101 I LIST COMMAND EXECUTED SUCCESSFULLY.
 DFH5123 I PRIMARY CSD CLOSED;  DDNAME: DFHCSD   - DSNAME: CTS550P8.ADDICSD.DFHCSD




 DFH5107 I COMMANDS EXECUTED SUCCESSFULLY: 1     COMMANDS GIVING WARNING(S): 0     COMMANDS IN ERROR: 0
 DFH5108 I COMMANDS NOT EXECUTED AFTER ERROR(S): 0
 DFH5109 I END OF DFHCSDUP UTILITY JOB. HIGHEST RETURN CODE WAS: 0
