

-- | PURPOSE  : Report on overall redo log contention for the instance since    |
-- |            the instance was last started.  

SELECT 
    INITCAP(name) "Latch Name"
  , gets
  , misses
  , sleeps
  , immediate_gets
  , immediate_misses
FROM  sys.v_$latch
WHERE name LIKE 'redo%'
ORDER BY 1;


--Statistics

SELECT
    name
  , value
FROM
    v$sysstat
WHERE
    name LIKE 'redo%';
