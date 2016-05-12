#!/bin/sh

cd /u01/app/oracle/product/10.2/network/admin

# DEV
scp tnsnames.ora dora02:/u01/app/oracle/product/12.1.0.2/dbhome_1/network/admin
scp tnsnames.ora dora01:/u01/app/oracle/product/12.1.0.2/dbhome_1/network/admin
scp tnsnames.ora dora10:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora dora11:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora dora12:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora dora13:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora dora14:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora dora15:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora dora16:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora dora17:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora dora18:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora dora19:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora dora20:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora dora21:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora dora22:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora dora24:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora dora25:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora dora26:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora dora27:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora dora28:/u01/app/oracle/product/12.1.0.2/dbhome_1/network/admin
scp tnsnames.ora dora29:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora dora30:/u01/app/oracle/product/12.1.0.2/dbhome_1/network/admin
scp tnsnames.ora dora31:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora dora32:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin

scp tnsnames.ora sora02:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora sora03:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora sora10:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora sora11:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora sora12:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora sora13:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora sora14:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora sora15:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora sora16:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora sora17:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora sora18:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora sora19:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora sora20:/u01/app/oracle/product/12.1.0.2/dbhome_1/network/admin
scp tnsnames.ora sora21:/u01/app/oracle/product/12.1.0.2/dbhome_1/network/admin
scp tnsnames.ora sora22:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora sora23:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora sora24:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora sora25:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora sora26:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora sora27:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin

# PDB - Primary
scp tnsnames.ora ora11:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora ora05:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora ora14:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora ora16:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora ora13:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora ora01:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora ora02:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora ora03:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin

# PDB - Standby
scp tnsnames.ora ora17:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora ora18:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora ora19:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora ora04:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora ora22:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora ora23:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora ora24:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora ora15:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin

# MMDB - Primary
scp tnsnames.ora ora25:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora ora26:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin

# MMDB - Standby
scp tnsnames.ora ora20:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora ora21:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin

# TDB - Primary
scp tnsnames.ora ora29:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora ora31:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora ora33:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora ora35:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin

# TDB - Standby
scp tnsnames.ora ora30:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora ora32:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora ora34:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora ora36:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin

# WHSE
scp tnsnames.ora ora38:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora ora39:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin

# IMDB
scp tnsnames.ora ora41:/u01/app/oracle/product/12.1.0.2/dbhome_1/network/admin
scp tnsnames.ora ora42:/u01/app/oracle/product/12.1.0.2/dbhome_1/network/admin

# TAGDB - Primary
scp tnsnames.ora ora27:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin

# TAGDB - Standby
scp tnsnames.ora ora28:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin

# Misc
scp tnsnames.ora ora37:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora ora40:/u01/app/oracle/product/12.1.0.1/dbhome_1/network/admin
scp tnsnames.ora sora04:/u01/app/oracle/product/12.1.0.2/dbhome_1/network/admin
scp tnsnames.ora sora05:/u01/app/oracle/product/12.1.0.2/dbhome_1/network/admin

# GRID
scp tnsnames.ora grid01:/u01/app/oracle/product/12.1.0/dbhome_1/network/admin
scp tnsnames.ora grid02:/u01/app/oracle/product/12.1.0/dbhome_1/network/admin

# DBBU servers
scp tnsnames.ora dbbu03:/u01/app/oracle/product/10.2/network/admin
scp tnsnames.ora dbbu04:/u01/app/oracle/product/10.2/network/admin

#scp tnsnames.ora testora01:/u01/app/oracle/product/12.1.0.2/dbhome_1/network/admin

# ETL prod

scp tnsnames.ora ora43:/u01/app/oracle/product/12.1.0.2/dbhome_1/network/admin
