# Benchmark for faster EXPLAIN ANALYZE

This repository stores the tools and results for benchmarking Faster EXPLAIN ANALYZE, as described in my blog posts:
+ [The 3 Steps to a Faster EXPLAIN ANALYZE](http://www.interdb.jp/blog/pgsql/explain_analyze_01/)
+ [Two More Steps to a Faster EXPLAIN ANALYZE](http://www.interdb.jp/blog/pgsql/explain_analyze_02/)

## Requirements

1. PostgreSQL development environment (gcc, make, flex, bison, etc.)
2. git
3. Python3

## Setup

```
$ git clone https://github.com/s-hironobu/explain_analyze_bench.git
$ cd explain_analyze_bench
$ bash ./bench.sh setup
```

#### Remark:
This shell script does not contain any `rm` commands. It only uses `cd`, `echo`, `git`, `make`, and `patch`, as well as `pg_ctl`, `createdb`, and `psql`.


## Benckmark

Run all benchmarks at once with the following command:

```
$ bash ./bench.sh benchmark
```

If you want to run them step-by-step, specify the option:

```
$ bash ./bench.sh benchmark [step0|step1|step2|step3|step4|step5]
```

After the benchmark is complete, you can use analyze.py to aggregate and display the results:

```
$ python3 ./analyze.py
	Duration[s] (var. [s^2]) 	Overhead[%]
-----------------------------------------------------
**** Original:
Query1	45.2046 	(0.0070)	N/A
Query2	58.6842 	(0.0153)	29.82
Query3	160.8744 	(0.1695)	253.66
**** Step 1:
Query1	45.1979 	(0.0033)	N/A
Query2	54.6081 	(0.0104)	20.82
**** Step 2:
Query1	45.1916 	(0.0065)	N/A
Query2	50.5348 	(0.0433)	11.82
**** Step 3:
Query1	45.4063 	(0.0023)	N/A
Query2	47.6129 	(0.0006)	4.86
**** Step 4:
Query1	45.7337 	(0.0026)	N/A
Query2	47.1306 	(0.0018)	3.05
**** Step 5:
Query1	45.7726 	(0.0018)	N/A
Query2	45.8361 	(0.0010)	0.14
```

If you want to analyze only specific results, specify the data file:

```
$ python3 ./analyze.py ./pgsql/step1.log
```

## Others

### Running a custom benchmark
If you want to run a different benchmark query, perform the following steps:

1. Define the necessary tables in testdb.
2. Update the QUERY variable in batches/create_batches.py to your desired query.

```
QUERY = "SELECT count(*) FROM test1 AS a, test2 AS b, test3 AS c WHERE a.id = c.id;"
```

3. Run create_batches.py:

```
$ cd batches
$ python3 create_batches.py
```

## Change Log
- 16 Aug 2025: Version 1.0 released.
- 07 Sep 2025: Version 1.1 released.
