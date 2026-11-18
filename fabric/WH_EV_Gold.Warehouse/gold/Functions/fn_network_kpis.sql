/* ---------- Inline table-valued function: KPIs for any date range ---------- */
CREATE   FUNCTION gold.fn_network_kpis (@from date, @to date)
RETURNS TABLE
AS
RETURN
    WITH pd AS (
        SELECT SUM(CASE WHEN st.first_session_date > @to THEN 0
                        ELSE DATEDIFF(day, CASE WHEN st.first_session_date > @from THEN st.first_session_date ELSE @from END, @to) + 1
                   END) AS port_days
        FROM gold.dim_station st
    )
    SELECT COUNT(*)                                                    AS sessions,
           CAST(SUM(f.energy_kwh) / 1000 AS decimal(12,1))             AS energy_mwh,
           CAST(SUM(f.energy_kwh) / MAX(pd.port_days) AS decimal(9,1)) AS kwh_per_port_day,
           CAST(100.0 * SUM(f.total_min) / (MAX(pd.port_days) * 1440.0) AS decimal(5,1)) AS utilisation_pct,
           CAST(100.0 * SUM(f.idle_min) / SUM(f.total_min) AS decimal(5,1))              AS idle_share_pct
    FROM gold.fact_sessions f
    INNER JOIN gold.dim_date d ON d.date_key = f.date_key
    CROSS JOIN pd
    WHERE d.[date] BETWEEN @from AND @to;

GO