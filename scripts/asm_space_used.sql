column diskgroup format a16
column total_gig format 9999.99
column free_gig format 9999.99 
column pct_free format 99.99
select substr(name,1,15) diskgroup,round(total_mb/1024,2) total_gig,round(usable_file_mb/1024,2) free_gig, round((usable_file_mb/total_mb)*100,2) pct_free from v$asm_diskgroup;
