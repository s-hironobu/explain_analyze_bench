--
-- ./bin/psql -d testdb -e -f batch.sql
--

\echo TIMING FALSE
\timing

-- warm-up
\o output.txt
SELECT count(*) FROM test1 AS a, test2 AS b, test3 AS c WHERE a.id = c.id;
\o
CHECKPOINT;

-- 1
\o output.txt
SELECT count(*) FROM test1 AS a, test2 AS b, test3 AS c WHERE a.id = c.id;
\o
CHECKPOINT;

\o output.txt
EXPLAIN (ANALYZE TRUE, TIMING FALSE, BUFFERS FALSE) SELECT count(*) FROM test1 AS a, test2 AS b, test3 AS c WHERE a.id = c.id;
\o
CHECKPOINT;

-- 2
\o output.txt
SELECT count(*) FROM test1 AS a, test2 AS b, test3 AS c WHERE a.id = c.id;
\o
CHECKPOINT;

\o output.txt
EXPLAIN (ANALYZE TRUE, TIMING FALSE, BUFFERS FALSE) SELECT count(*) FROM test1 AS a, test2 AS b, test3 AS c WHERE a.id = c.id;
\o
CHECKPOINT;

-- 3
\o output.txt
SELECT count(*) FROM test1 AS a, test2 AS b, test3 AS c WHERE a.id = c.id;
\o
CHECKPOINT;

\o output.txt
EXPLAIN (ANALYZE TRUE, TIMING FALSE, BUFFERS FALSE) SELECT count(*) FROM test1 AS a, test2 AS b, test3 AS c WHERE a.id = c.id;
\o
CHECKPOINT;

-- 4
\o output.txt
SELECT count(*) FROM test1 AS a, test2 AS b, test3 AS c WHERE a.id = c.id;
\o
CHECKPOINT;

\o output.txt
EXPLAIN (ANALYZE TRUE, TIMING FALSE, BUFFERS FALSE) SELECT count(*) FROM test1 AS a, test2 AS b, test3 AS c WHERE a.id = c.id;
\o
CHECKPOINT;

-- 5
\o output.txt
SELECT count(*) FROM test1 AS a, test2 AS b, test3 AS c WHERE a.id = c.id;
\o
CHECKPOINT;

\o output.txt
EXPLAIN (ANALYZE TRUE, TIMING FALSE, BUFFERS FALSE) SELECT count(*) FROM test1 AS a, test2 AS b, test3 AS c WHERE a.id = c.id;
\o
CHECKPOINT;

-- 6
\o output.txt
SELECT count(*) FROM test1 AS a, test2 AS b, test3 AS c WHERE a.id = c.id;
\o
CHECKPOINT;

\o output.txt
EXPLAIN (ANALYZE TRUE, TIMING FALSE, BUFFERS FALSE) SELECT count(*) FROM test1 AS a, test2 AS b, test3 AS c WHERE a.id = c.id;
\o
CHECKPOINT;

-- 7
\o output.txt
SELECT count(*) FROM test1 AS a, test2 AS b, test3 AS c WHERE a.id = c.id;
\o
CHECKPOINT;

\o output.txt
EXPLAIN (ANALYZE TRUE, TIMING FALSE, BUFFERS FALSE) SELECT count(*) FROM test1 AS a, test2 AS b, test3 AS c WHERE a.id = c.id;
\o
CHECKPOINT;

-- 8
\o output.txt
SELECT count(*) FROM test1 AS a, test2 AS b, test3 AS c WHERE a.id = c.id;
\o
CHECKPOINT;

\o output.txt
EXPLAIN (ANALYZE TRUE, TIMING FALSE, BUFFERS FALSE) SELECT count(*) FROM test1 AS a, test2 AS b, test3 AS c WHERE a.id = c.id;
\o
CHECKPOINT;

-- 9
\o output.txt
SELECT count(*) FROM test1 AS a, test2 AS b, test3 AS c WHERE a.id = c.id;
\o
CHECKPOINT;

\o output.txt
EXPLAIN (ANALYZE TRUE, TIMING FALSE, BUFFERS FALSE) SELECT count(*) FROM test1 AS a, test2 AS b, test3 AS c WHERE a.id = c.id;
\o
CHECKPOINT;

-- 10
\o output.txt
SELECT count(*) FROM test1 AS a, test2 AS b, test3 AS c WHERE a.id = c.id;
\o
CHECKPOINT;

\o output.txt
EXPLAIN (ANALYZE TRUE, TIMING FALSE, BUFFERS FALSE) SELECT count(*) FROM test1 AS a, test2 AS b, test3 AS c WHERE a.id = c.id;
\o
CHECKPOINT;

