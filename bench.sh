#!/bin/bash
#
#
#    Usage: $0 {setup|benchmark}
#
# Copyright (c) 2025, Hironobu Suzuki @ interdb.jp

set -eu -o pipefail

#--------------------
# Set Variables
#--------------------
BASE=`pwd`
SOURCE_DIR=${BASE}/postgres
PGSQL_DIR=${BASE}/pgsql
DB_NAME="testdb"

COMMIT="6a46089e458f2d700dd3b8c3f6fc782de933529a"


#--------------------
# Common
#--------------------
git_reset() {
    cd $SOURCE_DIR
    git reset --hard HEAD
    if [ $? -ne 0 ]; then
	echo "Error: Failed to execute 'git reset --hard HEAD'."
	exit 1
    fi
    git reset --hard $COMMIT
    if [ $? -ne 0 ]; then
	echo "Error: Failed to execute 'git reset --hard $COMMIT'."
	exit 1
    fi
    cd $BASE
}

make_clean() {
    cd $SOURCE_DIR
    if [ -f $SOURCE_DIR/config.log ]; then
	make clean
	if [ $? -ne 0 ]; then
	    echo "Warning: Failed to execute 'make clean'."
	fi
    fi
}

#--------------------
# Setup
#--------------------

setup() {
    # 1. git clone postgres
    if ! git -v >/dev/null 2>&1; then
	echo "Error: git command not found." >&2
	exit 1
    fi

    if [ ! -d $SOURCE_DIR ]; then
	git clone https://github.com/postgres/postgres.git
	if [ $? -ne 0 ]; then
	    echo "Error: Failed to clone PostgreSQL repository."
	    exit 1
	fi
    fi

    # 2. git reset
    git_reset

    # 3. configure && make && make install
    make_clean

    ./configure --prefix=$PGSQL_DIR --without-icu CFLAGS="-O3 -g"
    make -j4 && make install

    # 4. initdb
    cd $PGSQL_DIR

    if [ ! -d $PGSQL_DIR/data ]; then
	./bin/initdb -D data
	if [ $? -eq 0 ]; then
            echo "Database cluster created successfully."
	else
	    echo "Error: Failed to execute 'initdb'."
	    exit 1
	fi

	echo "include 'custom_settings.conf'" >> $PGSQL_DIR/data/postgresql.conf

	echo "shared_buffers = 512MB" > $PGSQL_DIR/data/custom_settings.conf
	echo "max_parallel_workers_per_gather = 0" >> $PGSQL_DIR/data/custom_settings.conf
	echo "max_parallel_workers = 0" >> $PGSQL_DIR/data/custom_settings.conf
	echo "parallel_leader_participation = off" >> $PGSQL_DIR/data/custom_settings.conf
    fi

    # 5. pg_ctl start
    cd $PGSQL_DIR
    if ./bin/psql -l >/dev/null 2>&1; then
	echo "==========================================="
	echo "Error: Other PostgreSQL is already running."
	echo "       Stop the server and try setup again."
	echo "==========================================="
	exit 1
    fi

    ./bin/pg_ctl -D data start
    if [ $? -ne 0 ]; then
	echo "Error: Failed to execute 'pg_ctl -D data start'."
	exit 1
    fi

    # 6. createdb
    cd $PGSQL_DIR
    if ./bin/psql -lqt | cut -d \| -f 1 | grep -qw "$DB_NAME"; then
	echo "Database '$DB_NAME' already exists."
    else
	echo "Database '$DB_NAME' does not exist. Creating..."
	./bin/createdb "$DB_NAME"
	if [ $? -eq 0 ]; then
            echo "Database '$DB_NAME' created successfully."
	else
            echo "Error: Failed to create database '$DB_NAME'."
            exit 1
	fi
    fi

    # 7. create tables and indexes
    cd $PGSQL_DIR
    ./bin/psql -d $DB_NAME -c "DROP TABLE IF EXISTS test1, test2, test3;
    	CREATE TABLE test1 (id int, data int);
    	CREATE INDEX test1_id_idx ON test1 (id);
    	CREATE TABLE test2 (id int PRIMARY KEY, data int);
    	CREATE TABLE test3 (id int PRIMARY KEY, data int);
    	INSERT INTO test1 (id, data) SELECT i, i % 51  FROM generate_series(1, 150000) AS i;
    	INSERT INTO test1 (id, data) SELECT i, i % 51 FROM generate_series(1, 5000) AS i;
    	INSERT INTO test2 (id, data) SELECT i, floor(random() * 50 + 1)::int FROM generate_series(1, 50000) AS i;
    	INSERT INTO test3 (id, data) SELECT i, i FROM generate_series(1, 35000) AS i;
    	ANALYZE;"
    if [ $? -nq 0 ]; then
        echo "Error: Failed to create tables in '$DB_NAME'."
        exit 1
    fi

    ./bin/pg_ctl -D data stop

    echo "==========================="
    echo "Setup completed!"
    echo "==========================="
}

#--------------------
# benchmark
#--------------------

bench() {
    local title=$1
    local batch=$2
    local log=$3

    cd $PGSQL_DIR
    ./bin/pg_ctl -D data start
    echo "== $title =="
    ./bin/psql -d $DB_NAME -e -f ../batches/$batch 2>&1 | tee $log
    ./bin/pg_ctl -D data stop
}

step0_bench() {
    make_clean
    cd $SOURCE_DIR
    ./configure --prefix=$PGSQL_DIR --without-icu CFLAGS="-O3 -g"
    make -j4 && make install
    cd $PGSQL_DIR
    bench "STEP0" "batch-with-time.sql" "step0.log"
}

step1_bench() {
    make_clean
    git_reset
    cd $SOURCE_DIR
    patch -p1 < ../patches/step1-improved-explain-analyze.patch
    ./configure --prefix=$PGSQL_DIR --without-icu CFLAGS="-O3 -g"
    make -j4 && make install
    cd $PGSQL_DIR
    bench "STEP1" "batch-with-time.sql" "step1.log"
}

step2_bench() {
    make_clean
    git_reset
    cd $SOURCE_DIR
    patch -p1 < ../patches/step1-improved-explain-analyze.patch
    patch -p1 < ../patches/step2-improved-explain-analyze.patch
    ./configure --prefix=$PGSQL_DIR --without-icu CFLAGS="-O3 -g"
    make -j4 && make install
    cd $PGSQL_DIR
    bench "STEP2" "batch.sql" "step2.log"
}

step3_bench() {
    make_clean
    git_reset
    cd $SOURCE_DIR
    patch -p1 < ../patches/step1-improved-explain-analyze.patch
    patch -p1 < ../patches/step2-improved-explain-analyze.patch
    patch -p1 < ../patches/step3-improved-explain-analyze.patch
    ./configure --prefix=$PGSQL_DIR --without-icu CFLAGS="-O3 -g"
    make -j4 && make install
    cd $PGSQL_DIR
    bench "STEP3" "batch.sql" "step3.log"
}

step3_lli_bench() {
    make_clean
    git_reset
    cd $SOURCE_DIR
    patch -p1 < ../patches/step1-improved-explain-analyze.patch
    patch -p1 < ../patches/step2-improved-explain-analyze.patch
    patch -p1 < ../patches/step3-improved-explain-analyze.patch
    ./configure --prefix=$PGSQL_DIR --without-icu CFLAGS="-O3 -g -DDOUBLE_TO_LONG_LONG_INT"
    make -j4 && make install
    cd $PGSQL_DIR
    bench "STEP3 long long int" "batch.sql" "step3-longlongint.log"
}


benchmark() {
    #
    # 1. check postgres repo
    #
    if [ ! -d $SOURCE_DIR ]; then
	echo "Error: PostgreSQL repository not found."
	exit 1
    fi

    git_reset

    #
    # 2. check data_dir
    #
    if [ ! -d $PGSQL_DIR ]; then
	echo "Error: $PGSQL_DIR not found."
	exit 1
    fi

    #
    # 3.  do benchmark
    #
    case "$1" in
	step0)
	    echo "STEP0"
	    step0_bench
            ;;
	step1)
	    echo "STEP1"
	    step1_bench
            ;;
	step2)
	    echo "STEP2"
	    step2_bench
            ;;
	step3)
	    echo "STEP3"
	    step3_bench
            ;;
	#step3-lli)
	#    echo "STEP3-lli"
	#    step3_lli_bench
        #    ;;
	ALL)
	    echo "ALL"
	    step0_bench
	    step1_bench
	    step2_bench
	    step3_bench
	    #step3_lli_bench
	    ;;
	*)
	    echo "Error: '$1' is not a valid argument."
	    exit 1
    esac
	    
    echo "==========================="
    echo "Benchmark completed!"
    echo "==========================="
}

#--------------------
# main
#--------------------

if [ $# -ne 1 ] && [ $# -ne 2 ]; then
    #echo "Usage: $0 {setup|benchmark} [step0|step1|step2|step3|step3-lli]"
    echo "Usage: $0 {setup|benchmark} [step0|step1|step2|step3]"
    exit 1
fi

PARAM="ALL"
if [ $# -eq 2 ]; then
    case "$2" in
	#"step0" | "step1" | "step2" | "step3" | "step3-lli")
	"step0" | "step1" | "step2" | "step3")
	    PARAM=$2
	    ;;
	*)
	    #echo "Usage: $0 {setup|benchmark} [step0|step1|step2|step3|step3-lli]"
	    echo "Usage: $0 {setup|benchmark} [step0|step1|step2|step3]"
	    exit 1
	    ;;
    esac
fi


case "$1" in
    setup)
        setup
        ;;
    benchmark)
	echo -n "Confirm that no other PostgreSQL server is active. Do you want to continue? [y/N]: "
	read answer
	cd $PGSQL_DIR
	if ./bin/psql -l >/dev/null 2>&1; then
	    echo "==========================================="
	    echo "Error: Other PostgreSQL is already running."
	    echo "       Stop the server and try setup again."
	    echo "==========================================="
	    exit 1
	fi

	case "$answer" in
	    y|Y|yes|Yes|YES)
		echo -n "This benchmark will take a few hours. Do you want to continue? [y/N]: "
		read answer

		case "$answer" in
		    y|Y|yes|Yes|YES)
			echo "Continuing..."
			benchmark $PARAM
			;;
		    *)
			echo "Exiting."
			exit 1
			;;
		esac
		;;
	    *)
		echo "Exiting."
		exit 1
		;;
	esac
        ;;
    help)
	echo "Usage: $0 {setup|benchmark}"
	;;
    *)
        echo "Error: Invalid argument. Use 'setup' or 'benchmark'."
        exit 1
        ;;
esac
