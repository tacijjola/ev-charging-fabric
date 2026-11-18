/* =====================================================================
   02_stored_procedures.sql  ·  Warehouse: WH_EV_Gold  ·  Day 5
   Builds the Gold star schema from the Lakehouse Silver tables with
   cross-database queries (LH_EV.dbo.<table>) — no data copied by hand.

   Sources
     LH_EV.dbo.silver_sessions        (nb_02_silver_transform)
     stg.site_reference               (Dataflow Gen2, Day 6)   -- fallback: see 00_fallback_stage_from_lakehouse
     stg.site_reference_change
     stg.end_reason_mapping
     stg.site_managers

   Run order: EXEC gold.sp_run_gold_load;   (calls everything below)
   ===================================================================== */

/* ---------- 0 · Fallback: stage reference data from the lakehouse ----------
   Use only if the Dataflow Gen2 is not built yet (nb_01 lands ref_ tables). */
CREATE   PROCEDURE stg.sp_stage_reference_from_lakehouse
AS
BEGIN
    DROP TABLE IF EXISTS stg.site_reference;
    CREATE TABLE stg.site_reference AS
    SELECT site_code, site_name, address, postal_code,
           CAST(latitude AS float) AS latitude, CAST(longitude AS float) AS longitude,
           CAST(port_count AS int) AS port_count, CAST(first_session_date AS date) AS first_session_date,
           fee_policy
    FROM LH_EV.dbo.ref_site_reference;

    DROP TABLE IF EXISTS stg.site_reference_change;
    CREATE TABLE stg.site_reference_change AS
    SELECT site_code, fee_policy, CAST(effective_date AS date) AS effective_date
    FROM LH_EV.dbo.ref_site_reference_change_2017_08_01;

    DROP TABLE IF EXISTS stg.end_reason_mapping;
    CREATE TABLE stg.end_reason_mapping AS
    SELECT ended_by, end_reason_group, CAST(is_fault AS int) AS is_fault
    FROM LH_EV.dbo.ref_end_reason_mapping;

    DROP TABLE IF EXISTS stg.site_managers;
    CREATE TABLE stg.site_managers AS
    SELECT site_code, manager_upn FROM LH_EV.dbo.ref_site_managers;
END;

GO