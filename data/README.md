## benchmark

The benchmark results used in [my blog post](http://www.interdb.jp/blog/post/pgsql/explain_analyze_01/) are saved here.

## gprof

The profiling results obtained with gprof (on Ubuntu 24.04) are saved here.

## perf

The profiling results obtained with perf (on Ubuntu 24.04), along with a flamegraph, are saved here.

## count-functions.log

This file contains the exact execution counts for the following functions:

- ExecInterpExpr
- ExecProcNodeInstr
- ExecProcNodeInstrLite
- InstrStartNode
- InstrStopNode
- InstrEndLoop

These counts were collected using the following patched binaries:

+ patches/step0_count_functions.patch
+ patches/step2-count_functions.patch
