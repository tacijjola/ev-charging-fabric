/* ---------- 2 · dim_site — Slowly Changing Dimension Type 2 ----------
   Tracked attribute: fee_policy. Fees started on 1 Aug 2017 at the eight older sites, so
   their sessions before that date join to the 'Free' version and later ones to 'Paid'.
   Sherman opened on 9 Dec 2020 already charging, so its only version starts as 'Paid'.
   Re-running is safe: a change that is already applied is not applied twice.        */
CREATE   PROCEDURE gold.sp_load_dim_site_scd2
AS
BEGIN
    DECLARE @max_key int;

    /* 2a · New sites → first version, open-ended */
    SELECT @max_key = COALESCE(MAX(site_key), 0) FROM gold.dim_site;

    INSERT INTO gold.dim_site
    SELECT @max_key + ROW_NUMBER() OVER (ORDER BY r.site_code),
           r.site_code, r.site_name, r.address, r.postal_code, r.latitude, r.longitude,
           r.port_count, r.first_session_date, r.fee_policy,
           CAST('1900-01-01' AS date), CAST('9999-12-31' AS date), 1
    FROM stg.site_reference AS r
    WHERE NOT EXISTS (SELECT 1 FROM gold.dim_site d WHERE d.site_code = r.site_code);

    /* 2b · Type 1 attributes (corrections, no history): overwrite on every version */
    UPDATE d
    SET d.site_name = r.site_name, d.address = r.address, d.postal_code = r.postal_code,
        d.latitude = r.latitude, d.longitude = r.longitude,
        d.port_count = r.port_count, d.first_session_date = r.first_session_date
    FROM gold.dim_site AS d
    INNER JOIN stg.site_reference AS r ON r.site_code = d.site_code;

    /* 2c · Type 2 changes: capture them BEFORE closing the old version */
    DROP TABLE IF EXISTS stg.work_site_changes;
    CREATE TABLE stg.work_site_changes AS
    SELECT d.site_key AS old_site_key, d.site_code, d.site_name, d.address, d.postal_code,
           d.latitude, d.longitude, d.port_count, d.first_session_date,
           c.fee_policy AS new_fee_policy, CAST(c.effective_date AS date) AS effective_date
    FROM gold.dim_site AS d
    INNER JOIN stg.site_reference_change AS c ON c.site_code = d.site_code
    WHERE d.is_current = 1
      AND d.fee_policy <> c.fee_policy
      AND CAST(c.effective_date AS date) > d.valid_from;

    /* close the current version the day before the change */
    UPDATE d
    SET d.valid_to = DATEADD(day, -1, w.effective_date), d.is_current = 0
    FROM gold.dim_site AS d
    INNER JOIN stg.work_site_changes AS w ON w.old_site_key = d.site_key;

    /* open the new version */
    SELECT @max_key = COALESCE(MAX(site_key), 0) FROM gold.dim_site;
    INSERT INTO gold.dim_site
    SELECT @max_key + ROW_NUMBER() OVER (ORDER BY w.site_code),
           w.site_code, w.site_name, w.address, w.postal_code, w.latitude, w.longitude,
           w.port_count, w.first_session_date, w.new_fee_policy,
           w.effective_date, CAST('9999-12-31' AS date), 1
    FROM stg.work_site_changes AS w;

    DROP TABLE IF EXISTS stg.work_site_changes;
END;

GO