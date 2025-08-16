"""
 Create batch files

 Usage: python create_batches.py

 Copyright (c) 2025, Hironobu Suzuki @ interdb.jp
"""

import os
import sys

QUERY = "SELECT count(*) FROM test1 AS a, test2 AS b, test3 AS c WHERE a.id = c.id;"


BatchFile = "batch.sql"
BatchFile2 = "batch-with-time.sql"
EXPLAIN = "EXPLAIN (ANALYZE TRUE, TIMING FALSE, BUFFERS FALSE) "
EXPLAIN2 = "EXPLAIN (ANALYZE TRUE, TIMING TRUE, BUFFERS FALSE) "

Header = "--\n-- ./bin/psql -d testdb -e -f batch.sql\n--\n\n"

REPEAT = 10


def commands(explain=False, timing=False):
    ret = []
    ret.append("\\o output.txt\n")
    if explain == True:
        if timing == True:
            ret.append(str(EXPLAIN2) + str(QUERY) + "\n")
        else:
            ret.append(str(EXPLAIN) + str(QUERY) + "\n")
    else:
        ret.append(str(QUERY) + "\n")
    ret.append("\\o\n")
    ret.append("CHECKPOINT;\n\n")
    return ret


def writeBatch(timing=False):

    try:
        if timing == True:
            fd = open(BatchFile2, "w", encoding="UTF-8")
        else:
            fd = open(BatchFile, "w", encoding="UTF-8")

        fd.write(Header)
        if timing == True:
            fd.write("\\echo TIMING TRUE\n")
        else:
            fd.write("\\echo TIMING FALSE\n")

        fd.write("\\timing\n\n")

        fd.write("-- warm-up\n")
        """ SELECT """
        fd.writelines(commands(False))

        for i in range(REPEAT):
            comment = "-- " + str(i + 1) + "\n"
            fd.write(comment)
            """ SELECT """
            fd.writelines(commands(False))
            """ EXPLAIN (ANALYZE TRUE, TIMING FALSE) """
            fd.writelines(commands(True, False))
            if timing == True:
                """EXPLAIN (ANALYZE TRUE, TIMING TRUE)"""
                fd.writelines(commands(True, True))

        fd.close()

    except Exception as e:
        print("Error: {}".format(e))
        return


def checkFilename(filename="batch.sql"):
    current_file = str(filename)

    if not os.path.exists(current_file):
        # not exist yet.
        return

    base_backup_name = str(filename) + str(".old")  # e.g., "batch.sql.old"
    backup_name = base_backup_name
    counter = 2

    while os.path.exists(backup_name):
        backup_name = f"{base_backup_name}{counter}"
        counter += 1

    try:
        os.rename(current_file, backup_name)
        print("Renamed {} to {}".format(current_file, backup_name))
        return
    except Exception as e:
        print("Error: {}".format(e))
        sys.exit(1)


if __name__ == "__main__":

    checkFilename(BatchFile)
    checkFilename(BatchFile2)
    writeBatch(True)
    writeBatch(False)
