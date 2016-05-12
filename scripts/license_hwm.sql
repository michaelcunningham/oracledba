select (select name from v$database) dbname, sessions_highwater from v$license;
