set echo on time on timing on
set heading on
set serveroutput on
spool /mnt/dba/projects/DBA-6082/logs/pdb_layout_update.log


delete from pdb_layout where PDB like 'MMDB%'
/

update pdb_layout 
SET PDB='SPDB01'
where PARTITION_NO <=7;
commit;
update pdb_layout 
SET PDB='SPDB05'
where PARTITION_NO >=8 and PARTITION_NO <=15;
commit;

update pdb_layout 
SET PDB='SPDB02'
where PARTITION_NO >=16 and PARTITION_NO <=23;
commit;
update pdb_layout 
SET PDB='SPDB06'
where PARTITION_NO >=24 and PARTITION_NO <=31;
commit;
update pdb_layout 
SET PDB='SPDB03'
where PARTITION_NO >=32 and PARTITION_NO <=39;
commit;
update pdb_layout 
SET PDB='SPDB07'
where PARTITION_NO >=40 and PARTITION_NO <=47;
commit;
update pdb_layout 
SET PDB='SPDB04'
where PARTITION_NO >=48 and PARTITION_NO <=55;
commit;
update pdb_layout 
SET PDB='SPDB08'
where PARTITION_NO >=56 and PARTITION_NO <=63;
commit;
