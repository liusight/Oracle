-- | PURPOSE  : Report on Shared / Java Pool within SG

SELECT
    f.pool
  , f.name
  , s.sgasize "Allocated"
  , f.bytes  "Free"
  , ROUND(f.bytes/s.sgasize*100, 2) "% Free"
FROM
    (SELECT SUM(bytes) sgasize, pool FROM v$sgastat GROUP BY pool) s
  , v$sgastat f
WHERE
    f.name = 'free memory'
  AND f.pool = s.pool
/

