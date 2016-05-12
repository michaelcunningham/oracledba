create user gpackrisamy 
identified by password
default tablespace oasis_data
temporary tablespace temp
quota 1024k on oasis_data
profile oasis ;
grant oasis_user to gpackrisamy ;
grant create session to gpackrisamy ;
alter user gpackrisamy identified by newpswd ;
alter user gpackrisamy identified by xMDVORVC ;

update fpicusr.pfuser
set department = 'CLAIMS'
where userid = 'GPACKRISAMY' ;
