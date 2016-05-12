CREATE OR REPLACE PACKAGE TAG.ttable_maintenance AUTHID CURRENT_USER is

PROCEDURE truncate_t_tables(intable in varchar2);
PROCEDURE check_t_tables(intable in varchar2);

end ttable_maintenance;
/