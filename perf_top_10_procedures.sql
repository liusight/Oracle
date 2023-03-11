SELECT
    ptyp  "Object Type"
  , obj  "Object Name"
  , 0 - exem "Number of Executions"
FROM ( select distinct exem, ptyp, obj  
       from ( select
                  o.type                    ptyp
                , o.owner || '.' || o.name  obj
                , 0 - o.executions          exem
              from  v$db_object_cache O 
              where o.type in ('FUNCTION','PACKAGE','PACKAGE BODY','PROCEDURE','TRIGGER')
	   )
     )
WHERE rownum <= 10;
