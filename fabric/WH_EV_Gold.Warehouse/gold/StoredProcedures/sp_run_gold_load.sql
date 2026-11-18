/* ---------- 5 · Orchestrator (this is what the pipeline calls) ---------- */
CREATE   PROCEDURE gold.sp_run_gold_load
AS
BEGIN
    DECLARE @run varchar(64) = CONVERT(varchar(64), NEWID());

    EXEC gold.sp_load_dim_date_time;
    EXEC gold.sp_load_dim_site_scd2;
    EXEC gold.sp_load_dims_type1;
    EXEC gold.sp_load_fact_sessions;

    TRUNCATE TABLE gold.security_site_manager;
    INSERT INTO gold.security_site_manager SELECT site_code, manager_upn FROM stg.site_managers;

    INSERT INTO gold.load_log
    SELECT @run, 'fact_sessions', COUNT_BIG(*), SYSUTCDATETIME() FROM gold.fact_sessions
    UNION ALL SELECT @run, 'dim_site versions', COUNT_BIG(*), SYSUTCDATETIME() FROM gold.dim_site
    UNION ALL SELECT @run, 'dim_station', COUNT_BIG(*), SYSUTCDATETIME() FROM gold.dim_station;

    SELECT * FROM gold.load_log WHERE run_id = @run;
END;

GO