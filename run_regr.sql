-- cat run_regr.sql | duckdb

.timer on

CREATE OR REPLACE TABLE testdata AS
    FROM generate_series(1, 1_000_000_000)
    SELECT
        generate_series AS x,
        (x * random())::int64 AS y,
        (100 * random())::int64 AS z
;

PRAGMA database_size
;

SUMMARIZE testdata
;

FROM testdata
SELECT
    regr_intercept(x, y) AS intercept_y,
    regr_slope(x, y) AS slope_y,
    regr_r2(x, y) AS r2_y,
    regr_intercept(x, z) AS intercept_z,
    regr_slope(x, z) AS slope_z,
    regr_r2(x, z) AS r2_z
;
