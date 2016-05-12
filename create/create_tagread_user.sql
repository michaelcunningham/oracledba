
CREATE USER tagread IDENTIFIED BY "gd356days"
DEFAULT TABLESPACE "USERS"
TEMPORARY TABLESPACE "TEMP"
ACCOUNT UNLOCK ;

GRANT CONNECT, RESOURCE , SELECT ANY TABLE TO tagread;

ALTER USER "TAGREAD" QUOTA UNLIMITED ON users;

ALTER USER "TAGREAD" DEFAULT ROLE "CONNECT","RESOURCE";
GRANT UNLIMITED TABLESPACE TO tagread;

