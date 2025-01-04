library(dplyr)
library(duckdb)


# Create in-memory DuckdDB database
con <- dbConnect(duckdb())

# Install TPC-DS extension and generate test data
dbExecute(con, "INSTALL tpcds; LOAD tpcds;")

# Generate test data
setup_timing <- system.time(
  dbExecute(con, "CALL dsdgen(sf = 30);"),
  gcFirst = TRUE
)

# Check memory usage
db_size <- dbGetQuery(con, "PRAGMA database_size;")

# Run each test
tpcds_timings <- lapply(
  1:99,
  function(i) {
    message("Running ", i)
    system.time(
      dbExecute(con, paste0("PRAGMA tpcds(", i, ");")),
      gcFirst = TRUE
    )
  }
)

# Remove database instance
dbDisconnect(con)

# Combine list of results into a data frame and label the rows
tpcds_df <- bind_rows(tpcds_timings, .id = "step")

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

tpcds_df |>
  summarise(
    sum.user.self = sum(user.self),
    sum.sys.self = sum(sys.self),
    sum.cpu.time = sum.user.self + sum.sys.self,
    sum.elapsed = sum(elapsed),
    cpu.per.elapsed = sum.cpu.time / sum.elapsed
  )

