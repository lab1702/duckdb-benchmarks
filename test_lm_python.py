#
# Billion row linear model in DuckDB
#

import duckdb
import time

# Function to measure the time taken to execute a statement
def measure_time(statement_callable):
    # Record the start CPU time and real time
    start_cpu_time = time.process_time()
    start_real_time = time.monotonic()

    # Execute the statement callable
    print(statement_callable())

    # Record the end CPU time and real time
    end_cpu_time = time.process_time()
    end_real_time = time.monotonic()

    # Calculate the CPU time used and real time elapsed
    cpu_used = end_cpu_time - start_cpu_time
    real_elapsed = end_real_time - start_real_time
    cores_used = cpu_used / real_elapsed

    # End of function
    return cpu_used, real_elapsed, cores_used


with duckdb.connect() as con:
    # Measure the time taken to initialize the database
    setup_cpu_used, setup_real_elapsed, setup_cores_used = measure_time(
        lambda: con.sql(
            """
            CREATE OR REPLACE TABLE testdata AS
            FROM generate_series(1, 1_000_000_000)
            SELECT
                generate_series AS x,
                (x * random())::int64 AS y,
                (-x * random())::int64 AS z;
            """
        )
    )

    # Measure the time it takes to summarize the generated table
    summarize_cpu_used, summarize_real_elapsed, summarize_cores_used = measure_time(
        lambda: con.sql(
            """
            SUMMARIZE testdata;
            """
        )
    )

    # Measure the time taken to run the query
    lm_cpu_used, lm_real_elapsed, lm_cores_used = measure_time(
        lambda: con.sql(
            """
            FROM testdata
            SELECT
                regr_intercept(x, y) AS y_intercept,
                regr_slope(x, y) AS y_slope,
                regr_r2(x, y) AS y_r2,
                regr_intercept(x, z) AS z_intercept,
                regr_slope(x, z) AS z_slope,
                regr_r2(x, z) AS z_r2;
            """
        )
    )

# Print timing results
print(f"    Setup: {setup_cpu_used}, {setup_real_elapsed}, {setup_cores_used}")
print(f"Summarize: {summarize_cpu_used}, {summarize_real_elapsed}, {summarize_cores_used}")
print(f"       LM: {lm_cpu_used}, {lm_real_elapsed}, {lm_cores_used}")
