/* ---------- 1 · dim_date and dim_time (generated, no source needed) ---------- */
CREATE   PROCEDURE gold.sp_load_dim_date_time
AS
BEGIN
    TRUNCATE TABLE gold.dim_date;

    -- 10 x 10 x 10 x 10 = 10,000 numbers; keep the 3,653 days of 2011-2020 (whole years)
    WITH d AS (SELECT v FROM (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) AS t(v)),
    n AS (SELECT a.v + 10*b.v + 100*c.v + 1000*e.v AS i FROM d a CROSS JOIN d b CROSS JOIN d c CROSS JOIN d e),
    cal AS (SELECT DATEADD(day, i, CAST('2011-01-01' AS date)) AS dt FROM n
            WHERE DATEADD(day, i, CAST('2011-01-01' AS date)) <= '2020-12-31')
    INSERT INTO gold.dim_date
    SELECT
        YEAR(dt)*10000 + MONTH(dt)*100 + DAY(dt),
        dt,
        YEAR(dt),
        'Q' + CAST(DATEPART(quarter, dt) AS varchar(1)),
        MONTH(dt),
        LEFT(DATENAME(month, dt), 3),
        CONVERT(varchar(7), dt, 126),                         -- yyyy-mm
        YEAR(dt)*100 + MONTH(dt),
        (DATEDIFF(day, '1900-01-01', dt) % 7) + 1,            -- 1900-01-01 was a Monday → Monday = 1, independent of DATEFIRST
        LEFT(DATENAME(weekday, dt), 3),
        CASE WHEN (DATEDIFF(day, '1900-01-01', dt) % 7) >= 5 THEN 1 ELSE 0 END,
        CASE WHEN MONTH(dt) IN (12,1,2) THEN 'Winter' WHEN MONTH(dt) IN (3,4,5) THEN 'Spring'
             WHEN MONTH(dt) IN (6,7,8) THEN 'Summer' ELSE 'Autumn' END
    FROM cal;

    TRUNCATE TABLE gold.dim_time;
    WITH h AS (SELECT a.v + 10*b.v AS hr
               FROM (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) a(v)
               CROSS JOIN (VALUES (0),(1),(2)) b(v))
    INSERT INTO gold.dim_time
    SELECT hr,
           RIGHT('0' + CAST(hr AS varchar(2)), 2) + ':00',
           CASE WHEN hr < 6 THEN 'Night (00-05)' WHEN hr < 12 THEN 'Morning (06-11)'
                WHEN hr < 18 THEN 'Midday (12-17)' ELSE 'Evening (18-23)' END
    FROM h WHERE hr <= 23;
END;

GO