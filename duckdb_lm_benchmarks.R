#
# Billion row linear model in DuckDB
#

library(dplyr)
library(duckdb)


# Create in-memory DuckdDB database
con <- dbConnect(duckdb())

# Generate test data
setup_timing <- system.time(
  dbExecute(con, "
    CREATE OR REPLACE TABLE testdata AS
      FROM generate_series(1, 1_000_000_000)
      SELECT
        generate_series AS x,
        (x * random())::int64 AS y,
        (100 * random())::int64 AS z;
  ")
)

# Summarize the data
summarize_timing <- system.time(
  print(dbGetQuery(con, "SUMMARIZE testdata;"))
)

# Run the test
lm_timing <- system.time(
  print(dbGetQuery(con, "
    FROM testdata
    SELECT
      regr_intercept(x, y) AS y_intercept,
      regr_slope(x, y) AS y_slope,
      regr_r2(x, y) AS y_r2,
      regr_intercept(x, z) AS z_intercept,
      regr_slope(x, z) AS z_slope,
      regr_r2(x, z) AS z_r2;
  "))
)

# Remove database instance
dbDisconnect(con)

# Summarize times
bind_rows(
  list(
    Setup = setup_timing,
    Summarize = summarize_timing,
    LM = lm_timing
  ),
  .id = "step"
) |>
  transmute(
    step,
    user.self,
    sys.self,
    cpu.time = user.self + sys.self,
    elapsed,
    cpu.per.elapsed = cpu.time / elapsed
  )
