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

# # nb_04_table_maintenance
# **Purpose:** show you can find and fix Delta file-size problems.
# Ten yearly appends + a MERGE leave many small Parquet files. Small files slow Spark, the SQL endpoint and Direct Lake.
# 
# DP-600 skills: identify and resolve issues with Delta table file sizes · implement performance improvements in notebooks.

# CELL ********************

tables = ["bronze_sessions", "silver_sessions", "silver_qa_rejected"]

def file_stats(t):
    d = spark.sql(f"DESCRIBE DETAIL {t}").select("numFiles", "sizeInBytes").first()
    return d["numFiles"], round(d["sizeInBytes"] / 1024 / 1024, 1)

before = {t: file_stats(t) for t in tables}
for t, (n, mb) in before.items():
    print(f"BEFORE  {t:22s} files={n:5d}  size={mb} MB  avg={mb / max(n,1):.2f} MB/file")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# ### OPTIMIZE (bin-compaction) with V-Order
# V-Order is Fabric's Parquet write optimisation for fast reads by the SQL endpoint and Direct Lake.
# Screenshot before/after — it is a good portfolio visual.

# CELL ********************

for t in tables:
    spark.sql(f"OPTIMIZE {t} VORDER")

after = {t: file_stats(t) for t in tables}
for t, (n, mb) in after.items():
    print(f"AFTER   {t:22s} files={n:5d}  size={mb} MB  (was {before[t][0]} files)")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# ### History and VACUUM
# `DESCRIBE HISTORY` is your audit trail (each MERGE/OPTIMIZE is a version — time travel works on it).
# VACUUM removes files no longer referenced, older than the retention period (default 7 days = 168 h).
# Do **not** lower retention below 7 days on real projects; it breaks time travel and concurrent readers.

# CELL ********************

display(spark.sql("DESCRIBE HISTORY silver_sessions").select("version", "timestamp", "operation", "operationMetrics"))

# Time travel example: row count as at the first version
print("Rows at version 0:", spark.sql("SELECT COUNT(*) c FROM silver_sessions VERSION AS OF 0").first()["c"])

for t in tables:
    spark.sql(f"VACUUM {t}")      # default 168 hours

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
