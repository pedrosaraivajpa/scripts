SELECT
     relname AS tabela, schemaname AS "Esquema",
     to_char(n_tup_upd,'999G999G999G999') AS "UPDATEs", 
     to_char(n_tup_hot_upd, '999G999G999G999') AS "HOT UPD",
     to_char(n_tup_hot_upd::numeric *100 / n_tup_upd,'990D9') AS "HOT UPD %",
     CASE WHEN fillfactor IS NULL THEN '100' ELSE fillfactor END AS fillfactor
FROM 
    pg_stat_user_tables t
    LEFT JOIN (SELECT trim('fillfactor=' FROM reloptions) fillfactor, oid
        FROM (SELECT unnest(reloptions) reloptions, oid FROM pg_class WHERE reloptions IS NOT NULL) i
        WHERE reloptions LIKE 'fillfactor=%') c ON t.relid = c.oid
WHERE
    n_live_tup > 10000 AND
    n_tup_upd > 10000 AND
    n_tup_hot_upd *100 / n_tup_upd < 90
ORDER BY n_tup_hot_upd *100 / n_tup_upd, n_tup_upd DESC, relname, schemaname
LIMIT 40;
