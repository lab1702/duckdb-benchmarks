-- cat run_all_tpch.sql | duckdb

.timer on

CALL dbgen(sf = 20);

PRAGMA database_size;

.mode trash

PRAGMA tpch(1);
PRAGMA tpch(2);
PRAGMA tpch(3);
PRAGMA tpch(4);
PRAGMA tpch(5);
PRAGMA tpch(6);
PRAGMA tpch(7);
PRAGMA tpch(8);
PRAGMA tpch(9);
PRAGMA tpch(10);
PRAGMA tpch(11);
PRAGMA tpch(12);
PRAGMA tpch(13);
PRAGMA tpch(14);
PRAGMA tpch(15);
PRAGMA tpch(16);
PRAGMA tpch(17);
PRAGMA tpch(18);
PRAGMA tpch(19);
PRAGMA tpch(20);
PRAGMA tpch(21);
PRAGMA tpch(22);
