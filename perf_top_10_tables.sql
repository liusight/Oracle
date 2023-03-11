SELECT
    ctyp "Command Type"
  , obj  "Object Name"
  , 0 - exem  "Number of Executions"
  , gets  "Buffer Gets"
  , rowp   "Rows Processed"
FROM (
    select distinct exem, ctyp, obj, gets, rowp 
    from (select
              DECODE(   s.command_type
                      , 2,  'Insert into '
                      , 3,  'Select from '
                      , 6,  'Update  of  '
                      , 7,  'Delete from '
                      , 26, 'Lock    of  ')   ctyp
            , o.owner || '.' || o.name        obj
            , SUM(0 - s.executions)           exem
            , SUM(s.buffer_gets)              gets
            , SUM(s.rows_processed)           rowp
          from
              v$sql                s
            , v$object_dependency  d
            , v$db_object_cache    o 
          where
                s.command_type  IN (2,3,6,7,26) 
            and d.from_address  = s.address 
            and d.to_owner      = o.owner 
            and d.to_name       = o.name   
            and o.type          = 'TABLE' 
          group by
              s.command_type
            , o.owner
            , o.name
    )
)
WHERE rownum <= 10;
order by "Buffer Gets" desc;