Rem
Rem $Header: spcreate.sql 16-apr-2002.11:22:55 vbarrier Exp $
Rem
Rem spcreate.sql
Rem
Rem Copyright (c) 1999, 2002, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      spcreate.sql - Statistics Create
Rem
Rem    DESCRIPTION
Rem	 SQL*PLUS command file which creates the STATSPACK user, 
Rem      tables and package for the performance diagnostic tool STATSPACK
Rem
Rem    NOTES
Rem      Note the script connects INTERNAL and so must be run from
Rem      an account which is able to connect internal.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cdialeri    02/16/00 - 1191805
Rem    cdialeri    12/06/99 - 1103031
Rem    cdialeri    08/13/99 - Created
Rem

--
--  Create PERFSTAT user and required privileges
@@spcusr_tdc

--
--  Build the tables and synonyms
connect perfstat/&&perfstat_password
@@?/rdbms/admin/spctab
--  Create the statistics Package
@@?/rdbms/admin/spcpkg
exit;

