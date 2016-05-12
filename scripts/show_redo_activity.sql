select trunc(first_time), count(*) from v$loghist group by trunc(first_time);
