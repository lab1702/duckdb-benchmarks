library(dplyr)
library(duckdb)


# Create in-memory DuckdDB database
con <- dbConnect(duckdb())

# Install TPC-DS extension and generate test data
dbExecute(con, "INSTALL tpch; LOAD tpch;")

# Generate test data
setup_timing <- system.time(
  dbExecute(con, "CALL dbgen(sf = 30);"),
  gcFirst = TRUE
)

# Check memory usage
db_size <- dbGetQuery(con, "PRAGMA database_size;")

# Run each test
tpch_timings <- lapply(
  1:22,
  function(i) {
    message("Running ", i)
    system.time(
      dbExecute(con, paste0("PRAGMA tpch(", i, ");")),
      gcFirst = TRUE
    )
  }
)

# Remove database instance
dbDisconnect(con)

# Combine list of results into a data frame and label the rows
tpch_df <- bind_rows(tpch_timings, .id = "step")

# Show memory usage
db_size

# Summarize times
bind_rows(setup_timing) |>
  summarise(
    sum.user.self = sum(user.self),
    sum.sys.self = sum(sys.self),
    sum.cpu.time = sum.user.self + sum.sys.self,
    sum.elapsed = sum(elapsed),
    cpu.per.elapsed = sum.cpu.time / sum.elapsed
  )

tpch_df |>
  summarise(
    sum.user.self = sum(user.self),
    sum.sys.self = sum(sys.self),
    sum.cpu.time = sum.user.self + sum.sys.self,
    sum.elapsed = sum(elapsed),
    cpu.per.elapsed = sum.cpu.time / sum.elapsed
  )
