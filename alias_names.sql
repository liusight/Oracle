SELECT
    g.name               disk_group_name
  , a.name               alias_name
  , a.file_number        file_number
  , a.file_incarnation   file_incarnation
  , a.alias_index        alias_index
  , a.alias_incarnation  alias_incarnation
  , a.parent_index       parent_index
  , a.reference_index    reference_index
  , a.alias_directory    alias_directory
  , a.system_created     system_created
FROM
    v$asm_alias a JOIN v$asm_diskgroup g USING (group_number)
ORDER BY
    g.name
  , a.file_number