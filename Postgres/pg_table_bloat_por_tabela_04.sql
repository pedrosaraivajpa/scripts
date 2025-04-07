--psql -p 8881 -h localhost -d lendico_workflow -U root -f $(find ~/ -name pg_table_bloat.sql) -W -o pg_table_bloat.sql.log

SELECT current_database(), schemaname, tblname as tablename, pg_size_pretty( (bs*tblpages)::bigint ) AS real_size,
  /*pg_size_pretty( ((tblpages-est_tblpages)*bs)::bigint ) AS extra_size,
  CASE WHEN tblpages - est_tblpages > 0
    THEN 100 * (tblpages - est_tblpages)/tblpages::float
    ELSE 0
  END AS extra_ratio ,*/
  fillfactor,
  CASE WHEN tblpages - est_tblpages_ff > 0
    THEN pg_size_pretty( ((tblpages-est_tblpages_ff)*bs)::numeric(50,2) )
    ELSE '0'
  END AS bloat_size,
  CASE WHEN tblpages - est_tblpages_ff > 0
    THEN (100 * (tblpages - est_tblpages_ff)/tblpages::float)::numeric(50,2)
    ELSE 0
  END AS bloat_ratio,"%_hot_upd_rate", is_na
  -- , tpl_hdr_size, tpl_data_size, (pst).free_percent + (pst).dead_tuple_percent AS real_frag -- (DEBUG INFO)
    ,PG_SIZE_PRETTY( SUM( CASE WHEN tblpages - est_tblpages_ff > 0 THEN ((tblpages-est_tblpages_ff)*bs)::numeric(50,2) ELSE 0 END ) OVER (ORDER BY  CASE WHEN tblpages - est_tblpages_ff > 0 THEN ((tblpages-est_tblpages_ff)*bs)::numeric(50,2) ELSE 0 END ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) )  AS total_bloat_size

FROM (
  SELECT ceil( reltuples / ( (bs-page_hdr)/tpl_size ) ) + ceil( toasttuples / 4 ) AS est_tblpages,
    ceil( reltuples / ( (bs-page_hdr)*fillfactor/(tpl_size*100) ) ) + ceil( toasttuples / 4 ) AS est_tblpages_ff,
    tblpages, fillfactor, bs, tblid, schemaname, tblname, heappages, toastpages, is_na,"%_hot_upd_rate"
    -- , tpl_hdr_size, tpl_data_size, pgstattuple(tblid) AS pst -- (DEBUG INFO)
  FROM (
    SELECT
      ( 4 + tpl_hdr_size + tpl_data_size + (2*ma)
        - CASE WHEN tpl_hdr_size%ma = 0 THEN ma ELSE tpl_hdr_size%ma END
        - CASE WHEN ceil(tpl_data_size)::int%ma = 0 THEN ma ELSE ceil(tpl_data_size)::int%ma END
      ) AS tpl_size, bs - page_hdr AS size_per_block, (heappages + toastpages) AS tblpages, heappages,
      toastpages, reltuples, toasttuples, bs, page_hdr, tblid, schemaname, tblname, fillfactor, is_na,"%_hot_upd_rate"
      -- , tpl_hdr_size, tpl_data_size
    FROM (
      SELECT
        tbl.oid AS tblid, ns.nspname AS schemaname, tbl.relname AS tblname, tbl.reltuples,
        tbl.relpages AS heappages, coalesce(toast.relpages, 0) AS toastpages,
        coalesce(toast.reltuples, 0) AS toasttuples,
        coalesce(substring(
          array_to_string(tbl.reloptions, ' ')
          FROM 'fillfactor=([0-9]+)')::smallint, 100) AS fillfactor,
        current_setting('block_size')::numeric AS bs,
        CASE WHEN version()~'mingw32' OR version()~'64-bit|x86_64|ppc64|ia64|amd64' THEN 8 ELSE 4 END AS ma,
        24 AS page_hdr,
        23 + CASE WHEN MAX(coalesce(s.null_frac,0)) > 0 THEN ( 7 + count(s.attname) ) / 8 ELSE 0::int END
           + CASE WHEN bool_or(att.attname = 'oid' and att.attnum < 0) THEN 4 ELSE 0 END AS tpl_hdr_size,
        sum( (1-coalesce(s.null_frac, 0)) * coalesce(s.avg_width, 0) ) AS tpl_data_size,
        bool_or(att.atttypid = 'pg_catalog.name'::regtype)
          OR sum(CASE WHEN att.attnum > 0 THEN 1 ELSE 0 END) <> count(s.attname) AS is_na,
		  --0 as "%_hot_upd_rate"
		  ( (MAX (SUT.n_tup_hot_upd) FILTER (WHERE SUT.n_tup_upd >0 ) )::numeric(40,5) / (MAX( SUT.n_tup_upd ) FILTER (WHERE SUT.n_tup_upd >0 ) )::numeric(40,5) *100 )::numeric(40,2) as "%_hot_upd_rate"
		  
      FROM pg_attribute AS att
        JOIN pg_class AS tbl ON att.attrelid = tbl.oid
		JOIN pg_stat_user_tables SUT ON SUT.relid=tbl.oid
        JOIN pg_namespace AS ns ON ns.oid = tbl.relnamespace
        LEFT JOIN pg_stats AS s ON s.schemaname=ns.nspname
          AND s.tablename = tbl.relname AND s.inherited=false AND s.attname=att.attname
        LEFT JOIN pg_class AS toast ON tbl.reltoastrelid = toast.oid
      WHERE NOT att.attisdropped
        AND tbl.relkind in ('r','m')
      GROUP BY 1,2,3,4,5,6,7,8,9,10
      ORDER BY 2,3
    ) AS s
  ) AS s2
) AS s3
WHERE 1=1
AND schemaname !~* '^(pg|information)'
AND tblpages - est_tblpages_ff > 0
AND (bs*tblpages)::bigint > 100000000 -- > 100 MB
--AND (100 * (tblpages - est_tblpages_ff)/tblpages::float) > 40  -- bloat > 40 %
--AND   CASE WHEN tblpages - est_tblpages_ff > 0    THEN 100 * (tblpages - est_tblpages_ff)/tblpages::float    ELSE 0  END > 30
--AND "%_hot_upd_rate" < 50
--AND tblname in ('prospects') --' -- 'billing_entry' --'order_delivery'
--AND NOT is_na
--   AND tblpages*((pst).free_percent + (pst).dead_tuple_percent)::float4/100 >= 1
--AND tblname ~* '^(cd03_produto|cd03a_produto_revisao)$'
--AND tblname ~ '^(sale|sale_partner_sale|sale_item|sale_item_choice|sale_status_history|sale_delivery|nfe|nfe_item)$'

--ORDER BY bloat_ratio DESC LIMIT 40;
--ORDER BY "%_hot_upd_rate" DESC LIMIT 30;
ORDER BY ((tblpages-est_tblpages_ff)*bs)::numeric(50,2) DESC;-- LIMIT 40;

