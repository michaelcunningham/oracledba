create tablespace datatbs
datafile  '+DATA' size 100m autoextend on next 100m maxsize 1g
extent management local
autoallocate
segment space management auto;
