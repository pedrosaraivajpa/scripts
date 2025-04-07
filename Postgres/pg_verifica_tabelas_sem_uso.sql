SELECT schemaname, relname, seq_scan, idx_scan, n_live_tup, pg_size_pretty(pg_table_size(relid)) as  size
    FROM pg_stat_user_tables
    WHERE
        seq_scan + coalesce(idx_scan, 0) < 10 AND
        schemaname NOT LIKE 'pg_%'
    ORDER BY schemaname, relname;