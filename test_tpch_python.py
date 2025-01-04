import duckdb
import time


# Function to measure the time taken to execute a statement
def measure_time(statement_callable):
    # Record the start CPU time and real time
    start_cpu_time = time.process_time()
    start_real_time = time.monotonic()

    # Execute the statement callable and store the result
    print(statement_callable())

    # Record the end CPU time and real time
    end_cpu_time = time.process_time()
    end_real_time = time.monotonic()

    # Calculate the CPU time used and real time elapsed
    cpu_used = end_cpu_time - start_cpu_time
    real_elapsed = end_real_time - start_real_time
    cores_used = cpu_used / real_elapsed

    # Report the CPU time used and real time elapsed
    print(f"{cpu_used}, {real_elapsed}, {cores_used}")

    # End of function
    return


# Function to run the TPC-H queries
def run_tpch(con):
    for i in range(1, 23):
        print(con.sql(f"PRAGMA tpch({i})"))
    
    # End of function
    return


with duckdb.connect() as con:
    # Measure the time taken to initialize the TPC-H database
    measure_time(lambda: con.sql("CALL dbgen(sf = 10)"))

    # Measure the time taken to run the TPC-H queries
    measure_time(lambda: run_tpch(con))
