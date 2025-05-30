SELECT o.rolname AS owner, c.usename AS user, o.qt AS qt_obj, c.qt AS qt_conn
FROM 
    (SELECT rolname, count(1) AS qt 
        FROM pg_class c JOIN pg_roles a ON c.relowner = a.oid JOIN pg_namespace n ON c.relnamespace = n.oid 
        WHERE n.nspname NOT IN ('pg_catalog', 'pg_toast','information_schema') 
        GROUP BY rolname) AS O
    LEFT JOIN (SELECT usename, count(1) AS qt FROM pg_stat_activity WHERE pid != pg_backend_pid() GROUP by usename ORDER BY usename) AS c
        ON o.rolname = c.usename
ORDER BY o.qt;
