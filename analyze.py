"""
 analyze.py

 Usage: python analyze.py [file|dir]

 Copyright (c) 2025, Hironobu Suzuki @ interdb.jp
"""

import sys
import os


# Calculate avg and unbiased variance.
def calc(d):
    N = 0
    S = 0.0
    V = 0.0

    for x in d:
        N += 1
        S += x
        # Youngs and Cramer method
        if 1 < N:
            V += (x * N - S) ** 2 / (N * (N - 1))

    avg = (S / N) if N > 0 else None
    var = (V / (N - 1)) if N > 1 else None

    return avg, var


def preprocess(datalist):
    _mode = True

    data1 = []
    data2 = []
    data3 = []
    length = len(datalist)

    _timing = False
    i = -1
    while i < length - 1:
        i += 1

        line = datalist[i]

        # Check Mode
        if i == 0:
            _d = datalist[i].split()
            if _d[1] == "FALSE":
                _mode = False
            continue

        # Skip lines 2 through 7 (6 lines) to omit warm-up and checkpoint data.
        if i < 7:
            continue

        if line.startswith("SELECT"):
            i += 1
            _d = datalist[i].split()
            data1.append(float(_d[1]) / 1000)  # msec -> sec
        elif line.startswith("EXPLAIN"):
            i += 1
            _d = datalist[i].split()

            if _mode == True:
                if _timing == True:
                    data3.append(float(_d[1]) / 1000)  # msec -> sec
                    _timing = False
                else:
                    data2.append(float(_d[1]) / 1000)  # msec -> sec
                    _timing = True
            else:
                data2.append(float(_d[1]) / 1000)  # msec -> sec

        elif line.startswith("CHECKPOINT;"):
            pass
        elif line.startswith("CHECKPOINT"):
            i += 1
        else:
            print("Error: {}".format(line))
            sys.exit(1)

    return [data1, data2, data3]


def displayHeader():
    print("\tDuration[s] (var. [s^2]) \tOverhead[%]")
    print("-----------------------------------------------------")


def displaySingleBench(query1, query2, query3=None):
    [avg1, var1] = query1
    [avg2, var2] = query2
    print("Query1\t{:.4f} \t({:.4f})\tN/A".format(avg1, var1))
    print(
        "Query2\t{:.4f} \t({:.4f})\t{:.2f}".format(
            avg2, var2, 100 * (avg2 - avg1) / avg1
        )
    )
    if query3:
        [avg3, var3] = query3
        print(
            "Query3\t{:.4f} \t({:.4f})\t{:.2f}".format(
                avg3, var3, 100 * (avg3 - avg1) / avg1
            )
        )


if __name__ == "__main__":

    BASE_DIR = "pgsql"

    if len(sys.argv) != 1 and len(sys.argv) != 2:
        print("Usage: python analyze.py [file|dir]")
        sys.exit(-1)

    if len(sys.argv) == 2:

        if os.path.isfile(sys.argv[1]):
            # file
            try:
                fd = open(sys.argv[1], "r")
                datalist = fd.readlines()
                fd.close()
            except Exception as e:
                print("Error: {}".format(e))
                sys.exit(1)

            [data1, data2, data3] = preprocess(datalist)
            [avg1, var1] = calc(data1)
            [avg2, var2] = calc(data2)
            displayHeader()
            if data3 != []:
                [avg3, var3] = calc(data3)
                displaySingleBench([avg1, var1], [avg2, var2], [avg3, var3])
            else:
                displaySingleBench([avg1, var1], [avg2, var2], None)

            sys.exit(0)

        elif os.path.isdir(sys.argv[1]):
            # dir
            BASE_DIR = sys.argv[1]

        else:
            print("Error: {} not found.".format(sys.argv[1]))
            sys.exit(1)

    files = [
        # [title, file]
        ["Original", BASE_DIR + "/step0.log"],
        ["Step 1", BASE_DIR + "/step1.log"],
        ["Step 2", BASE_DIR + "/step2.log"],
        ["Step 3", BASE_DIR + "/step3.log"],
        # ["Step 3 (LongLongInt)", BASE_DIR + "/step3-longlongint.log"],
    ]

    displayHeader()

    for title, filename in files:
        try:
            fd = open(filename, "r")
            datalist = fd.readlines()
            fd.close()
        except Exception as e:
            print("Error: {}".format(e))
            sys.exit(1)

        [data1, data2, data3] = preprocess(datalist)
        print("**** {}:".format(title))
        [avg1, var1] = calc(data1)
        [avg2, var2] = calc(data2)
        if data3 != []:
            [avg3, var3] = calc(data3)
            displaySingleBench([avg1, var1], [avg2, var2], [avg3, var3])
        else:
            displaySingleBench([avg1, var1], [avg2, var2], None)
