--MOSTRA AS INFORMAÇÕES SOBRE INDICES INVALIDOS
select 
distinct 
idxs.schemaname as Schema,
idxs.tablename as Tabela,
idxs.indexname as Index,
case
    when idx.indisvalid = 't' then 'valid'
    else 'Invalido'
  end as Index_Status,
'DROP INDEX CONCURRENTLY ' || i.relname || ';' as Comando_Acao_drop, 
idxs.indexdef as comando_acao_create
from 
  pg_index as idx
    join pg_class as i
         on i.oid = idx.indexrelid
      join pg_namespace as s
           on i.relnamespace=s.oid
      join pg_indexes idxs
           on s.nspname=idxs.schemaname
           and i.relname=idxs.indexname 
           and idxs.schemaname ilike 'saj'
      join pg_stat_user_indexes ui 
      	   on ui.schemaname = idxs.schemaname 
      	   and ui.relname = idxs.tablename
where idx.indisvalid = 'f';