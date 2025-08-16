# Benchmark for faster EXPLAIN ANALYZE

This repository stores the tools and results for benchmarking Faster EXPLAIN ANALYZE,
as described in [my blog post](http://www.interdb.jp/blog/post/pgsql/explain_analyze_01/).

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
$ bash ./bench.sh benchmark [step0|step1|step2|step3]
```

After the benchmark is complete, you can use analyze.py to aggregate and display the results:

```
$ python3 ./analyze.py
	Duration[s] (var. [s^2]) 	Overhead[%]
-----------------------------------------------------
**** Original:
Query1	45.4885 	(0.0062)	N/A
Query2	58.8461 	(0.0064)	29.36
Query3	160.8744 	(0.1695)	253.66
**** Step 1:
Query1	45.5090 	(0.0454)	N/A
Query2	54.8780 	(0.0292)	20.59
Query3	158.1066 	(0.3472)	247.42
**** Step 2:
Query1	45.5785 	(0.0082)	N/A
Query2	50.4877 	(0.0097)	10.77
**** Step 3:
Query1	45.9527 	(0.0095)	N/A
Query2	47.6872 	(0.0089)	3.77
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
