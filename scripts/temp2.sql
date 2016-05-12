column parameter format a20
column path format a50
column object_name format a32
set linesize 130
set pagesize 100

-- select volume_id, path from novaprd.lu_dm_volume order by 1;

--@utlrp
--@shinvalid

--select owner, object_name, object_type from dba_objects where object_name = 'UTL_MAIL';

--grant execute on utl_recomp to public;

--select * from dba_profiles where resource_name = 'PASSWORD_LIFE_TIME';

--alter profile default limit password_life_time unlimited;

--select name, exptime from user$ where exptime > sysdate - 7;

--select username from dba_users where username like 'WR%';

--select	( select count(*) from novaprd.am_agency where edoc_admin_email_addr not like '%TEST'
--          and edoc_admin_email_addr is not null and lower( edoc_admin_email_addr ) not like '%@thedoctors.com' ) NOT_TEST,
--	( select count(*) from novaprd.am_agency ) TOTAL_ROWS
--from	dual;

column tablespace_name format a30
column total_bytes format 999,999,999,999

        select  replace( replace( replace( ddf.tablespace_name, 'IX' ), '_INDEX' ), '_DATA' ) tablespace_name,
                sum( trunc(bytes/1024/1024) ) total_bytes
        from    dba_data_files ddf,
                (
                select  file_id, sum( bytes ) free_bytes
                from    dba_free_space
                group by file_id
                ) dfs
        where   dfs.file_id(+) = ddf.file_id
	and	ddf.tablespace_name in( 'FPIC_DATA', 'FPIC_INDEX', 'STG_DATA', 'STG_INDEX', 'NOVA', 'NOVAIX' )
        group by replace( replace( replace( ddf.tablespace_name, 'IX' ), '_INDEX' ), '_DATA' )
        order by 1;

exit;
