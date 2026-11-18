/* =====================================================================
   03_views_function_validation.sql  ·  Warehouse: WH_EV_Gold  ·  Day 5
   Views and a function = reusable SQL for analysts.
   Validation queries = proof the Gold layer matches the Power BI report.
   ===================================================================== */

/* ---------- View: site performance by year (ports counted from their first session) ---------- */
CREATE   VIEW gold.vw_site_year_kpis
AS
WITH port_days AS (
    SELECT st.site_code, d.[year], COUNT(*) AS port_days
    FROM gold.dim_station st
    INNER JOIN gold.dim_date d ON d.[date] >= st.first_session_date      -- each port, each day in service
    GROUP BY st.site_code, d.[year]
),
usage AS (
    SELECT st.site_code, d.[year],
           COUNT(*)                 AS sessions,
           SUM(f.energy_kwh)        AS energy_kwh,
           SUM(f.total_min)         AS plugged_min,
           SUM(f.idle_min)          AS idle_min,
           SUM(f.fee_usd)           AS revenue_usd
    FROM gold.fact_sessions f
    INNER JOIN gold.dim_station st ON st.station_key = f.station_key
    INNER JOIN gold.dim_date d     ON d.date_key = f.date_key
    GROUP BY st.site_code, d.[year]
)
SELECT p.site_code, p.[year], p.port_days,
       COALESCE(u.sessions, 0)                                      AS sessions,
       CAST(COALESCE(u.energy_kwh, 0) / 1000 AS decimal(12,1))      AS energy_mwh,
       CAST(COALESCE(u.energy_kwh, 0) / p.port_days AS decimal(9,1)) AS kwh_per_port_day,
       CAST(100.0 * COALESCE(u.plugged_min, 0) / (p.port_days * 1440.0) AS decimal(5,1)) AS utilisation_pct,
       CAST(100.0 * u.idle_min / NULLIF(u.plugged_min, 0) AS decimal(5,1))              AS idle_share_pct,
       COALESCE(u.revenue_usd, 0)                                   AS revenue_usd
FROM port_days p
LEFT JOIN usage u ON u.site_code = p.site_code AND u.[year] = p.[year];

GO