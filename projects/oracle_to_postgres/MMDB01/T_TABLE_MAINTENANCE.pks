CREATE OR REPLACE PACKAGE TAG.T_TABLE_MAINTENANCE AUTHID CURRENT_USER is

PROCEDURE truncate_t_tables(intable                   IN       varchar2,
                                            inPkey                    IN        NUMBER,
                                            inRotationTime        IN       NUMBER,
                                            inTotalTTables        IN      NUMBER,
                                            inWaitPeriodTime    IN       NUMBER DEFAULT 0);

PROCEDURE check_t_tables(intable                    IN       varchar2,
                                         inPkey                    IN        NUMBER,
                                         inRotationTime        IN       NUMBER,
                                         inTotalTTables        IN       NUMBER,
                                         inWaitPeriodTime    IN       NUMBER  DEFAULT 0);

FUNCTION   get_next_t_table(
                                   inRotationTime        IN       NUMBER,
                                   inWaitPeriodTime    IN       NUMBER,
                                   inTotalTTables        IN      NUMBER) RETURN NUMBER;
FUNCTION DATE_UNIX_TS(inDays         IN    NUMBER) RETURN NUMBER;
end T_TABLE_MAINTENANCE;
/