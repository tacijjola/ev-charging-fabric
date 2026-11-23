# ev-charging-fabric
EV Charging on Microsoft Fabric

An end-to-end Fabric build on 259,415 Palo Alto EV charging sessions (2011–2020): PySpark lakehouse, T-SQL warehouse with an SCD Type 2 site dimension, Direct Lake semantic model, and an orchestrated pipeline.

Status: notebooks were run end-to-end locally on Spark 3.5 and reconcile to the Power BI report. The T-SQL and DAX have been written for Fabric but not yet run end to end there. Test as role is blocked by single sign-on, so row-level security is verified by reading the DAX filter and the role mapping.
