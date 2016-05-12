set linesize 150
set pagesize 80
set feedback off

ttitle on
ttitle center 'Read/Write Ratios' -
    skip -
    center '(can be valuable information for ssd usage)' -
    skip2


column file_name         format a35         heading 'File Name'
column lg_rd_mb          format 9,999,999   heading 'LG Rd MB'
column lg_wr_mb          format 9,999,999   heading 'LG Wr MB'
column sm_rd_mb          format 9,999,999   heading 'SM Rd MB'
column sm_wr_mb          format 9,999,999   heading 'SM Wr MB'
column tot_rd_mb         format 9,999,999   heading 'Tot Rd MB'
column tot_wr_mb         format 9,999,999   heading 'Tot Wr MB'
column tot_rd_ratio_pct  format 999.00      heading 'Tot Rd|Ratio %'
column tot_wr_ratio_pct  format 999.00      heading 'Tot Wr|Ratio %'
column lg_rd_ratio_pct   format 999.00      heading 'LG Rd|Ratio %'
column lg_wr_ratio_pct   format 999.00      heading 'LG Wr|Ratio %'
column sm_rd_ratio_pct   format 999.00      heading 'SM Rd|Ratio %'
column sm_wr_ratio_pct   format 999.00      heading 'SM Wr|Ratio %'

break on report
compute avg of tot_rd_ratio_pct    on report
compute avg of tot_wr_ratio_pct    on report
compute avg of lg_rd_ratio_pct     on report
compute avg of lg_wr_ratio_pct     on report
compute avg of sm_rd_ratio_pct     on report
compute avg of sm_wr_ratio_pct     on report

select	file_name,
	lg_rd_mb, sm_rd_mb, lg_wr_mb, sm_wr_mb,
	lg_rd_mb + sm_rd_mb tot_rd_mb,
	lg_wr_mb + sm_wr_mb tot_wr_mb,
	case when lg_rd_mb + sm_rd_mb = 0 then 0
	     else ( lg_rd_mb + sm_rd_mb ) / ( lg_rd_mb + sm_rd_mb + lg_wr_mb + sm_wr_mb ) * 100 end tot_rd_ratio_pct,
	case when lg_wr_mb + sm_wr_mb = 0 then 0
	     else ( lg_wr_mb + sm_wr_mb ) / ( lg_rd_mb + sm_rd_mb + lg_wr_mb + sm_wr_mb ) * 100 end tot_wr_ratio_pct,
	case when lg_rd_mb = 0 then 0
	     else ( lg_rd_mb ) / ( lg_rd_mb + lg_wr_mb ) * 100 end lg_rd_ratio_pct,
	case when lg_wr_mb = 0 then 0
	     else ( lg_wr_mb ) / ( lg_rd_mb + lg_wr_mb ) * 100 end lg_wr_ratio_pct,
	case when sm_rd_mb = 0 then 0
	     else ( sm_rd_mb ) / ( sm_rd_mb + sm_wr_mb ) * 100 end sm_rd_ratio_pct,
	case when sm_wr_mb = 0 then 0
	     else ( sm_wr_mb ) / ( sm_rd_mb + sm_wr_mb ) * 100 end sm_wr_ratio_pct
from    (
	select  df.file_name,
		sum( ios.large_read_megabytes ) lg_rd_mb,
		sum( ios.small_read_megabytes ) sm_rd_mb,
		sum( ios.large_write_megabytes ) lg_wr_mb,
		sum( ios.small_write_megabytes ) sm_wr_mb
	from    v$iostat_file ios, dba_data_files df
	where   ios.filetype_name = 'Data File'
	and     df.file_id = ios.file_no
	group by df.file_name )
order by 8 desc;

clear breaks
set linesize 115
ttitle center 'Read/Write Ratio Totals' skip2

ttitle skip 2 center 'Read/Write Ratio Totals' -
    skip -
    center '(these may not match numbers above due to rounding)' -
    skip -
    center '(these numbers are more acurate)' -
    skip2

select	lg_rd_mb, sm_rd_mb, lg_wr_mb, sm_wr_mb,
	lg_rd_mb + sm_rd_mb tot_rd_mb,
	lg_wr_mb + sm_wr_mb tot_wr_mb,
	( lg_rd_mb + sm_rd_mb ) / ( lg_rd_mb + sm_rd_mb + lg_wr_mb + sm_wr_mb ) * 100 tot_rd_ratio_pct,
	( lg_wr_mb + sm_wr_mb ) / ( lg_rd_mb + sm_rd_mb + lg_wr_mb + sm_wr_mb ) * 100 tot_wr_ratio_pct,
	( lg_rd_mb ) / ( lg_rd_mb + lg_wr_mb ) * 100 lg_rd_ratio_pct,
	( lg_wr_mb ) / ( lg_rd_mb + lg_wr_mb ) * 100 lg_wr_ratio_pct,
	( sm_rd_mb ) / ( sm_rd_mb + sm_wr_mb ) * 100 sm_rd_ratio_pct,
	( sm_wr_mb ) / ( sm_rd_mb + sm_wr_mb ) * 100 sm_wr_ratio_pct
from	(
	select  sum( ios.large_read_megabytes ) lg_rd_mb,
	        sum( ios.small_read_megabytes ) sm_rd_mb,
	        sum( ios.large_write_megabytes ) lg_wr_mb,
	        sum( ios.small_write_megabytes ) sm_wr_mb
	from    v$iostat_file ios, dba_data_files df
	where   ios.filetype_name = 'Data File'
	and     df.file_id = ios.file_no );

