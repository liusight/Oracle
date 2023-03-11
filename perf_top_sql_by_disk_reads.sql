SELECT
    UPPER(b.username)                                       username
  , a.disk_reads                                            disk_reads
  , a.executions                                            executions
  , a.disk_reads / decode(a.executions, 0, 1, a.executions) reads_per_exec
  , sql_text || chr(10) || chr(10)                          sql 
FROM 
    sys.v_$sqlarea a
  , dba_users b
WHERE
      a.parsing_user_id = b.user_id 
  AND a.disk_reads > 1000
  AND b.username NOT IN ('SYS','SYSTEM')
ORDER BY
    disk_reads desc;