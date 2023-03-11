
SELECT
    a.name
  , a.bytes
  , a.bytes/(b.sum_bytes*100)  Percent  
FROM sys.v_$sgastat a
   , (SELECT SUM(value)sum_bytes FROM sys.v_$sga) b 
ORDER BY bytes DESC
/