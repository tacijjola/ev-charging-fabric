# Fabric notebook source


# MARKDOWN ********************

# # nb_03_quality_and_profiling
# **Purpose:** prove the Silver layer reconciles to the validated Power BI report, and profile the data.
# Part A is PySpark (automated checks, written to a `dq_results` table the report can show).
# Part B is pandas + statistics — deliberately Python, for your Python/statistics study.
# 
# DP-600 skills: profile data · descriptive and diagnostic analytics · identify duplicates, missing data and nulls.

# CELL ********************

from pyspark.sql import functions as F
from datetime import datetime

s = spark.table("silver_sessions")

# MARKDOWN ********************

# ## Part A · Automated reconciliation (each check = one row in `dq_results`)

# CELL ********************

port_first = s.groupBy("station_name").agg(F.min("session_date").alias("first_date"))
port_days = port_first.select(F.sum(F.datediff(F.lit("2020-12-31"), "first_date") + 1).alias("pd")).first()["pd"]
agg = s.agg(F.count("*").alias("rows"), F.sum("energy_kwh").alias("kwh"), F.sum("fee_usd").alias("fee"),
            F.sum("total_min").alias("tot"), F.sum("idle_min").alias("idle"),
            F.countDistinct("user_id").alias("users")).first()

checks = [
    ("R01", "Raw rows in bronze",              spark.table("bronze_sessions").count(), 259415, 0),
    ("R04", "Rows in silver",                  agg["rows"],                            259384, 0),
    ("R05", "Rows rejected",                   spark.table("silver_qa_rejected").count(), 31, 0),
    ("R09", "Energy (MWh)",                    round(agg["kwh"] / 1000, 2),            2216.27, 0.01),
    ("R10", "Revenue (USD)",                   round(float(agg["fee"]), 2),            284692.08, 0.01),
    ("R11", "Active users",                    agg["users"],                           21436, 0),
    ("R14", "Port-days",                       port_days,                              65363, 0),
    ("R15", "kWh per port per day",            round(agg["kwh"] / port_days, 1),       33.9, 0.05),
    ("R16", "Port-time utilisation %",         round(100 * agg["tot"] / (port_days * 1440), 1), 41.1, 0.1),
    ("R17", "Idle share %",                    round(100 * agg["idle"] / agg["tot"], 1),        19.6, 0.1),
]
run_at = datetime.utcnow()
rows = [(c, m, float(a), float(e), float(t), abs(float(a) - float(e)) <= t, run_at) for c, m, a, e, t in checks]
dq = spark.createDataFrame(rows, "check_id string, metric string, actual double, expected double, tolerance double, passed boolean, run_at timestamp")
dq.write.format("delta").mode("append").saveAsTable("dq_results")
display(dq)
assert all(r[5] for r in rows), "Reconciliation failed — read the table above before going further."

# MARKDOWN ********************

# ## Part B · Profiling and statistics in pandas
# 259k rows × a few columns fits comfortably in memory, so pandas is the right tool here.
# Rule of thumb you can quote: **Spark for volume, pandas for the analysis on a sample or aggregate.**

# CELL ********************

import pandas as pd
import numpy as np

pdf = (s.select("site_code", "start_ts", "total_min", "charging_min", "idle_min", "energy_kwh", "fee_usd", "is_paid")
         .toPandas())
pdf["fee_usd"] = pdf["fee_usd"].astype(float)

# Column profile: nulls, distinct, min/max — the same view as Power Query's column profile
profile = pd.DataFrame({
    "dtype": pdf.dtypes.astype(str),
    "nulls": pdf.isna().sum(),
    "null_%": (pdf.isna().mean() * 100).round(2),
    "distinct": pdf.nunique(),
})
display(profile)
display(pdf.describe(percentiles=[.25, .5, .75, .95, .99]).T.round(2))

# MARKDOWN ********************

# ### Distribution: session energy is right-skewed → the median describes a "typical" session better than the mean

# CELL ********************

e = pdf["energy_kwh"]
print(f"mean {e.mean():.2f} kWh · median {e.median():.2f} kWh · skewness {e.skew():.2f}")

# Outliers with the IQR rule (Tukey fences) — a standard, explainable method
q1, q3 = e.quantile([.25, .75]); iqr = q3 - q1
upper = q3 + 1.5 * iqr
print(f"IQR fence: > {upper:.1f} kWh → {(e > upper).mean():.1%} of sessions flagged as high-energy outliers")

# MARKDOWN ********************

# ### Diagnostic question: did sessions change after fees started on 1 Aug 2017?
# Compare 12 months before vs 12 months after. Report it as **"coincided with"**, not "caused" —
# the same wording rule as the Power BI report.

# CELL ********************

pre  = pdf[(pdf.start_ts >= "2016-08-01") & (pdf.start_ts < "2017-08-01")]
post = pdf[(pdf.start_ts >= "2017-08-01") & (pdf.start_ts < "2018-08-01")]
summary = pd.DataFrame({
    "sessions": [len(pre), len(post)],
    "median_total_min": [pre.total_min.median(), post.total_min.median()],
    "mean_idle_min": [pre.idle_min.mean(), post.idle_min.mean()],
    "mean_kwh": [pre.energy_kwh.mean(), post.energy_kwh.mean()],
}, index=["12m before fees", "12m after fees"]).round(1)
display(summary)

# Mann-Whitney U: do idle times differ between the two periods? (non-parametric: idle time is not normal)
try:
    from scipy.stats import mannwhitneyu
    stat, p = mannwhitneyu(pre.idle_min.dropna(), post.idle_min.dropna(), alternative="two-sided")
    print(f"Mann-Whitney U p-value = {p:.2e}  → the difference is very unlikely to be chance;"
          " it still does not prove the fee caused it (ports, sites and demand changed too).")
except ImportError:
    print("scipy not available in this runtime — skip the test, keep the medians.")
