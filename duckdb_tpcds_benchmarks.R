library(dplyr)
library(duckdb)


# Create in-memory DuckdDB database
con <- dbConnect(duckdb())

# Install TPC-DS extension and generate test data
dbExecute(con, "INSTALL tpcds; LOAD tpcds; CALL dsdgen(sf = 20);")

# Check memory usage
db_size <- dbGetQuery(con, "PRAGMA database_size;")

# Run each test
tpcds_timings <- lapply(
  1:99,
  function(i) {
    message("Running ", i)
    system.time(dbExecute(con, paste0("PRAGMA tpcds(", i, ");")))
  }
)

# Remove database instance
dbDisconnect(con)

# Combine list of results into a data frame and label the rows
tpcds_df <- bind_rows(tpcds_timings, .id = "step")

# Show memory usage
db_size

# Summarize times
tpcds_df |>
  summarise(
    sum.user.self = sum(user.self),
    sum.sys.self = sum(sys.self),
    sum.cpu.time = sum.user.self + sum.sys.self,
    sum.elapsed = sum(elapsed),
    cpu.per.elapsed = sum.cpu.time / sum.elapsed
  )
