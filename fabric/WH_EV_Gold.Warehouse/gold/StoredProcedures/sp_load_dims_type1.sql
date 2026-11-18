/* ---------- 3 · dim_station, dim_user, dim_end_reason (Type 1: rebuilt each run) ---------- */
CREATE   PROCEDURE gold.sp_load_dims_type1
AS
BEGIN
    TRUNCATE TABLE gold.dim_station;
    INSERT INTO gold.dim_station
    SELECT ROW_NUMBER() OVER (ORDER BY station_name),
           station_name,
           REPLACE(station_name, 'PALO ALTO CA / ', ''),
           MAX(site_code),
           MAX(port_type), MAX(plug_type),
           MAX(latitude), MAX(longitude),             -- coordinates drift per row: one pin per port
           MIN(session_date),
           DATEDIFF(day, MIN(session_date), CAST('2020-12-31' AS date)) + 1
    FROM LH_EV.dbo.silver_sessions
    GROUP BY station_name;

    /* User bands: thresholds are ASSUMED (1 / 2-9 / 10+). Align them with the bands in your
       Power BI report before you compare user-mix figures. */
    TRUNCATE TABLE gold.dim_user;
    INSERT INTO gold.dim_user
    SELECT ROW_NUMBER() OVER (ORDER BY user_id), user_id, n,
           CASE WHEN n = 1 THEN 'One-off' WHEN n < 10 THEN 'Occasional' ELSE 'Frequent' END
    FROM (SELECT user_id, COUNT(*) AS n FROM LH_EV.dbo.silver_sessions
          WHERE user_id IS NOT NULL GROUP BY user_id) AS u;
    INSERT INTO gold.dim_user VALUES (-1, '(no user id)', 0, 'Unknown');   -- 7,677 sessions have no user

    TRUNCATE TABLE gold.dim_end_reason;
    INSERT INTO gold.dim_end_reason
    SELECT ROW_NUMBER() OVER (ORDER BY ended_by), ended_by, end_reason_group, CAST(is_fault AS bit)
    FROM stg.end_reason_mapping;
END;

GO