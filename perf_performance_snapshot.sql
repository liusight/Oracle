-- | PURPOSE  : This script will generate a small performance overview report   |
-- |            checking all key database performance indicators.               |

/*  
 +-----------------------------------+
 | Database Startup Date/Time        |
 +-----------------------------------+
 */

SELECT
    instance   "Instance Name"
  , open_time  "Open Date/Time"
FROM
  v$thread
/

 
/*  +-----------------------------------+
 | Buffer Cache Hit Ratio            |
 +-----------------------------------+ */


SELECT
  TRUNC( ( 1 - ( SUM(decode(name,'physical reads',value,0)) /
                 ( SUM(DECODE(name,'db block gets',value,0))
                   +
                   (SUM(DECODE(name,'consistent gets',value,0)))
                 )
               )
         ) * 100
       ) "Buffer Hit Ratio"
FROM v$sysstat
/

SELECT
    a.value + b.value                          "Logical reads"
  , c.value                                    "Physical Reads"
  , d.value                                    "Physical Writes"
  , ROUND (100 * ( (a.value+b.value)-c.value) / (a.value+b.value)
           )                                   "Buffer Hit Ratio"
  , ROUND(c.value * 100 / (a.value + b.value)) "% Missed"
FROM
    v$sysstat a
  , v$sysstat b
  , v$sysstat c
  , v$sysstat d
WHERE
      a.statistic#=37
  AND b.statistic#=38
  AND c.statistic#=39
  AND d.statistic#=40
/

 
/*  +-----------------------------------+
 | Data Dictionary Hit Ratio         |
 +-----------------------------------+ */


SELECT
    SUM(gets)                                 "Data Dict. Gets"
  , SUM(getmisses)                            "Data Dict. Cache Misses"
  , ROUND((1-(sum(getmisses)/SUM(gets)))*100) "Data Dict Cache Hit Ratio"
  , ROUND(SUM(getmisses)*100/SUM(gets))       "% Missed"
FROM
  v$rowcache
/

 
/*  +-----------------------------------+
 | Library Cache Miss Ratio          |
 +-----------------------------------+ */


SELECT
    SUM(pins)                               "Executions"
  , SUM(reloads)                            "Cache Misses"
  , ROUND((1-(SUM(reloads)/SUM(pins)))*100) "Library Cache Hit Ratio"
  , ROUND(SUM(reloads)*100/SUM(pins))       "% Missed"        
FROM
  v$librarycache
/

SELECT
    namespace                 "Namespace"
  , TRUNC(gethitratio*100)    "Hit Ratio"
  , TRUNC(pinhitratio*100)    "Pin Hit Ratio"
  , reloads                   "Reloads"
  , invalidations             "Invalidations"
FROM
  v$librarycache
/


/*  +-----------------------------------+
 | Redo Log Buffer                   |
 +-----------------------------------+ */


SELECT
    SUBSTR(name,1,30)            "Name"
  , TO_CHAR(value, '999,999')    "Bytes"
FROM
    v$sysstat
WHERE
    name ='redo log space requests'
/

SELECT
    name                              "Name"
  , TO_CHAR(bytes, '999,999,999,999') "Bytes"
FROM
    v$sgastat
WHERE
    name ='free memory'
/

SELECT
    TO_CHAR(SUM(executions), '999,999,999,999,999,999')  "Tot SQL since startup"
  , TO_CHAR(SUM(users_executing), '999,999,999,999,999') "SQL executing now"
FROM
    v$sqlarea
/

/* 
 +--------------------------------------------------------+
 | If miss_ratio or immediate_miss_ratio > 1 then latch   |
 | contention exists, decrease LOG_SMALL_ENTRY_MAX_SIZE   |
 +--------------------------------------------------------+ */


SELECT
    SUBSTR(ln.name,1,30)                            "Name"
  , (misses/(gets+.001)) * 100                      "Miss Ratio"
  , (immediate_misses/(immediate_gets+.001)) * 100  "Immd. Miss Ratio"
FROM
    v$latch     l
  , v$latchname ln
WHERE
      l.latch# = ln.latch#
  AND ( (( misses / (gets+.001)) * 100 > .1 )
        OR
        (( immediate_misses / (immediate_gets+.001)) * 100 > .1)
      )
ORDER BY
  ln.name
/       

/* 
 +--------------------------------------------------------+
 | If these are < 1% of Total Number of requests for data |
 | then extra rollback segments are needed.               |
 +--------------------------------------------------------+ */


SELECT
    class    "Class"
  , count    "Count"
FROM
    v$waitstat 
WHERE
  class IN (   'free list'
             , 'system undo header'
             , 'system undo block'
             , 'undo header'
             , 'undo block') 
GROUP BY
    class
  , count
/

 
/*  +-----------------------------------+
 | Total Number of Requests for Data |
 +-----------------------------------+ */


SELECT  TO_CHAR(SUM(value), '999,999,999,999,999') "Total Requests"
FROM    v$sysstat 
WHERE   name IN ('db block gets','consistent gets')
/

