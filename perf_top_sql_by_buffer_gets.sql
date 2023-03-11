SELECT
    UPPER(b.username)                                        username
  , a.buffer_gets                                            buffer_gets
  , a.executions                                             executions
  , a.buffer_gets / decode(a.executions, 0, 1, a.executions) gets_per_exec
  , sql_text || chr(10) || chr(10)                           sql 
FROM 
    sys.v_$sqlarea a
  , dba_users b
WHERE
      a.parsing_user_id = b.user_id 
  AND a.buffer_gets > 1000
  AND b.username NOT IN ('SYS','SYSTEM')
ORDER BY
    buffer_gets desc;