/* ---------- 4 · fact_sessions ----------
   Full reload: 259k rows takes seconds, and it keeps keys consistent with the rebuilt dims.
   At larger volume you would load only new session_ids (incremental pattern in the plan, Day 6). */
CREATE   PROCEDURE gold.sp_load_fact_sessions
AS
BEGIN
    TRUNCATE TABLE gold.fact_sessions;

    INSERT INTO gold.fact_sessions
    SELECT s.session_id,
           s.date_key,
           s.hour_of_day,
           st.station_key,
           ds.site_key,                                       -- SCD2 lookup by session date
           COALESCE(u.user_key, -1),
           er.end_reason_key,
           CASE WHEN s.total_min < 60  THEN '<1h'  WHEN s.total_min < 120 THEN '1–2h'
                WHEN s.total_min < 240 THEN '2–4h' WHEN s.total_min < 480 THEN '4–8h' ELSE '8h+' END,
           s.energy_kwh,
           CAST(s.fee_usd AS decimal(10,2)),
           s.ghg_kg,
           CAST(s.total_min AS decimal(9,1)),
           CAST(s.charging_min AS decimal(9,1)),
           CAST(s.idle_min AS decimal(9,1)),
           s.is_paid, s.is_duration_anomaly, s.is_long_session
    FROM LH_EV.dbo.silver_sessions AS s
    INNER JOIN gold.dim_station    AS st ON st.station_name = s.station_name
    INNER JOIN gold.dim_site       AS ds ON ds.site_code = s.site_code
                                        AND s.session_date BETWEEN ds.valid_from AND ds.valid_to
    LEFT  JOIN gold.dim_user       AS u  ON u.user_id = s.user_id
    INNER JOIN gold.dim_end_reason AS er ON er.ended_by = s.ended_by;
END;

GO