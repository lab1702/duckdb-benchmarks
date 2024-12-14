-- cat show_hardware.sql | duckdb

FROM duckdb_settings() WHERE name LIKE '%thread%' OR name LIKE '%memory%';
