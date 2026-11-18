# Fabric notebook source

# METADATA ********************

# META {
# META   "kernel_info": {
# META     "name": "synapse_pyspark"
# META   },
# META   "dependencies": {
# META     "lakehouse": {
# META       "default_lakehouse": "a42e0e22-76d4-4ca4-a363-88f4a5e06735",
# META       "default_lakehouse_name": "LH_EV",
# META       "default_lakehouse_workspace_id": "ffb7a8a2-5e81-4faf-8d12-ece0214fe2f1",
# META       "known_lakehouses": [
# META         {
# META           "id": "a42e0e22-76d4-4ca4-a363-88f4a5e06735"
# META         }
# META       ]
# META     }
# META   }
# META }

# MARKDOWN ********************

# # nb_01_bronze_ingest
# **Layer:** Bronze (raw, as delivered) · **Lakehouse:** `LH_EV` · **Language:** PySpark
# 
# Reads the yearly CSV files from `Files/landing/sessions/` and appends them to the Delta table
# `bronze_sessions` — every value kept as text, column names made Delta-safe, lineage columns added.
# 
# **Re-runnable:** loading a year twice replaces that year's partition (`replaceWhere`), it never duplicates it.
# 
# DP-600 skills: ingest data with a notebook · implement file partitioning · Delta tables.

# PARAMETERS CELL ********************

# Parameter cell — a pipeline overrides these values (Toggle "parameter cell" in the cell's ... menu).
load_years = "2011,2012,2013,2014,2015,2016,2017,2018,2019"   # comma-separated; "2020" on Day 3 as the late file
landing_folder = "Files/landing/sessions"
load_reference = True                                           # also land the reference CSVs as ref_ tables

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

import re
from pyspark.sql import functions as F

def delta_safe(name: str) -> str:
    """'Energy (kWh)' -> 'energy_kwh'. Delta rejects spaces and brackets in column names."""
    name = name.replace("﻿", "").strip().lower()
    name = re.sub(r"[^a-z0-9]+", "_", name)
    return name.strip("_")

years = [int(y) for y in str(load_years).split(",") if y.strip()]
print("Years to load:", years)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

def table_exists(name: str) -> bool:
    return spark.catalog.tableExists(name)

for y in years:
    path = f"{landing_folder}/ev_sessions_{y}.csv"
    raw = (spark.read
           .option("header", True)
           .option("inferSchema", False)        # bronze keeps text; typing is Silver's job
           .option("multiLine", False)
           .option("encoding", "UTF-8")
           .csv(path))

    raw = raw.toDF(*[delta_safe(c) for c in raw.columns])

    bronze = (raw
              .withColumn("_source_file", F.col("_metadata.file_path"))
              .withColumn("_ingested_at", F.current_timestamp())
              .withColumn("load_year", F.lit(y)))

    writer = bronze.write.format("delta").partitionBy("load_year")
    if table_exists("bronze_sessions"):
        writer.mode("overwrite").option("replaceWhere", f"load_year = {y}").saveAsTable("bronze_sessions")
    else:
        writer.mode("overwrite").saveAsTable("bronze_sessions")
    print(f"{y}: {bronze.count():,} rows written")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# ### Reference data (optional fallback)
# On Day 6 a **Dataflow Gen2** loads these files into the Warehouse — that is the version to show.
# This cell lands them in the lakehouse too, so Day 5 is never blocked.

# CELL ********************

if load_reference:
    for f in ["site_reference", "site_reference_change_2017-08-01", "end_reason_mapping", "site_managers"]:
        df = spark.read.option("header", True).csv(f"Files/landing/reference/{f}.csv")
        tname = "ref_" + delta_safe(f)
        df.write.format("delta").mode("overwrite").option("overwriteSchema", True).saveAsTable(tname)
        print(tname, df.count())

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

# Check: expected 259,415 rows once all ten years are loaded (reconciliation target R01)
display(spark.sql("""
    SELECT load_year, COUNT(*) AS rows, MIN(_ingested_at) AS first_ingested
    FROM bronze_sessions GROUP BY load_year ORDER BY load_year
"""))
print("Total bronze rows:", spark.table("bronze_sessions").count())

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
