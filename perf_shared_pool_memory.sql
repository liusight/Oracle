-- | PURPOSE  : Query the total memory in the Shared Pool and the amount of     |
-- |            free memory. 

SELECT
    TO_NUMBER(p.value)         "Shared Pool Size"
  , s.bytes                    "Free Bytes" 
  --, (s.bytes/p.value) * 100   "Percent Free"
FROM
    v$sgastat    s
  , v$parameter  p
WHERE
      s.name = 'free memory'
  AND s.pool = 'shared pool'
  AND p.name = 'shared_pool_size'
/