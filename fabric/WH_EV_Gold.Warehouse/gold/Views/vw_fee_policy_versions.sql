/* ---------- View: SCD2 in action — sessions and revenue by fee-policy version ---------- */
CREATE   VIEW gold.vw_fee_policy_versions
AS
SELECT s.site_name, s.fee_policy, s.valid_from, s.valid_to, s.is_current,
       COUNT(f.session_id)     AS sessions,
       SUM(f.fee_usd)          AS revenue_usd,
       AVG(f.idle_min * 1.0)   AS avg_idle_min
FROM gold.dim_site s
LEFT JOIN gold.fact_sessions f ON f.site_key = s.site_key
GROUP BY s.site_name, s.fee_policy, s.valid_from, s.valid_to, s.is_current;

GO