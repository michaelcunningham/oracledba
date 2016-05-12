set head off 


select value from v$parameter where name='processes';
host ipcs -ls

