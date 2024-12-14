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
        (x * random())::int64 AS y;
  ")
)

# Check memory usage
db_size <- dbGetQuery(con, "PRAGMA database_size;")

# Run the test
lm_timing <- system.time(
  res <- dbGetQuery(con, "
    FROM testdata
    SELECT
      regr_intercept(x, y),
      regr_slope(x, y),
      regr_r2(x, y);
  ")
)

# Remove database instance
dbDisconnect(con)

# Show database size
db_size

# Show results
res

# Summarize times
bind_rows(list(Setup = setup_timing, LM = lm_timing), .id = "step") |>
  transmute(
    step,
    user.self,
    sys.self,
    cpu.time = user.self + sys.self,
    elapsed,
    cpu.per.elapsed = cpu.time / elapsed
  )
