-- cat run_regr.sql | duckdb

.timer on

CREATE OR REPLACE TABLE testdata AS
    FROM generate_series(1, 1_000_000_000)
    SELECT
        generate_series AS x,
        (x * random())::int64 AS y
;

PRAGMA database_size
;

FROM testdata
LIMIT 3
;

FROM testdata
SELECT
    regr_intercept(x, y),
    regr_slope(x, y),
    regr_r2(x, y)
;
