#!/bin/bash
# Author: Marios Yiannakou
#
# Runs all benchmarks in the `implementations` directory sequentially, and creates a report inside `benchmarks`.
#
# Usage:
# - Navigate to the repository's root directory.
# - Run the `benchmark.sh` script.
#
# Contributing:
# Each language has it's own directory, and each algorithm/program has it's own sub-directory
#   inside the appropriate language directory. Please ensure that each program is consistently
#   named across all directories (e.g. The prime sieve program is under a directory called
#   `sieve` regardless of the language implementing it).
# Each algorithm should have three files (at least) associated with it:
#   - A file that is named after the algorithm itself containing the logic.
#   - A file with the `_test` postfix to indicate this is the test file
#   - A file with the `_run` postfix which is a file that imports and calls the algorithm.
#   - Optional: Any helper libraries required to run the algorithm.
#
# Example directory structure
# implementations
# |
# |__ python
# |   |
# |   |__ sieve
# |   |   |
# |   |   |__ sieve.py          <-- The algorithm to be run.
# |   |   |
# |   |   |__ sieve_tests.py    <-- Make sure to test your solutions!
# |   |   |
# |   |   |__ sieve_run.py      <-- A call to the algorithm.
# |   |
# |   |__ binary_tree
# |
# |__ c
# ...
#
# For existing languages:
# - If a solution exists for the language and algorithm you wish to create, replace the existing
#   one with your own locally and run the benchmark against it. If the score is higher, or any
#   attributes are of higher quality (i.e. less memory consumed, fewer lines of code, etc),
#   feel free to open a pull-request explaining why your solution is better.
# - If you want to implement a new algorithm then please follow the existing directory structure.
#
# For other languages:
# Even though this is a university project, I am planning on leaving it as an open-source project
#   for future development and most certainly welcome any new implementations in any language. It
#   will be fun to see what the community comes up with. Feel free to create a new directory under
#   `implementations` named after the language used, following the file structure mentioned above.
#
# To include any new language/algorithm in the benchmark you will need to update this script to
#   recognise, and run it:
#   - Include your language in the LANGUAGES list / algorithm in the ALGORITHMS list.
#   - Update the EXTENSIONS list with a key:value pair of the language:file extension

CURRENT_DIR=$(pwd)
PROGRAMS_DIR="${CURRENT_DIR}/implementations"
BENCHMARKS_DIR="${CURRENT_DIR}/benchmarks"
BENCHMARKS_FILE="${BENCHMARKS_DIR}/benchmarks"

DEPENDENCIES_DIR="${CURRENT_DIR}/dependencies"
SYRUPY="${DEPENDENCIES_DIR}/syrupy/syrupy.py"
JUNIT="${DEPENDENCIES_DIR}/junit/junit-4.10.jar"
HAMCREST="${DEPENDENCIES_DIR}/hamcrest/hamcrest-2.2.jar"
UNITY="${DEPENDENCIES_DIR}/unity/unity.c"

LANGUAGES=(rust go java c python haxe)
ALGORITHMS=(sieve)

INTERVAL=1

# Capture any CL flags provided
TEST=0
BENCHMARK=1
while test $# -gt 0
do
  case "$1" in
    -h|--help)
        echo "The Computer Language Benchmarks Game"
        echo "Author: Marios Yiannakou"
        echo ""
        echo "This script executes and measures the performance of all algorithms"
        echo "written in the implementations directory. The script compiles and runs"
        echo "all language implementations of one algorithm, before moving to the next."
        echo ""
        echo "Usage: ./benchmarks.sh [-h|--help] [-t|--test] [--test-and-benchmark]"
        echo ""
        echo "Options:"
        echo "-h, --help            show this help message and exit"
        echo "-t, --test            run tests for all algorithms without running the benchmark"
        echo "--test-and-benchmark  run tests and benchmarks for all algorithms (breaks if any tests fail)"
        exit 0
        ;;
    -t|--test)
        shift
        TEST=1
        BENCHMARK=0
        shift
        ;;
    --test-and-benchmark)
        shift
        TEST=1
        BENCHMARK=1
        shift
        ;;
  esac
done

# Casts a float number to an integer.
# Note: This function simply cuts off the decimal point.
#
# Parameters:
#   - The floating number to convert to an integer.
# Returns:
#   The provided number as an integer.
function float_to_int() {
    printf "%.0f\n" "$1"
}

# Retrieves the CPU brand and model name of the host machine from the `/proc/cpuinfo`
# file.
#
# Parameters:
#   N/A
# Returns:
#   The brand and model of the current machine.
function get_cpu_name() {
    CPU_MODEL=$(cat /proc/cpuinfo | grep 'model name' | head -n 1 | awk '{for (i=4;i<=NF;i++) printf "%s ", $i}')
    CPU_BRAND=$(echo $CPU_MODEL | awk '{print $1}')

    if [ $CPU_BRAND == "AMD" ]
    then
        echo $CPU_MODEL | awk '{printf "%s %s %s %s\n", $1, $2, $3, $4}'
    elif [ $CPU_BRAND == "Intel(R)" ]
    then
        echo $CPU_MODEL | awk '{printf "%s %s %s %s %s\n", $1, $2, $3, $4, $5}'
    else
        echo $CPU_MODEL
    fi
}

# Retrieves the number of logical processors of the host machine from the
# `/proc/cpuinfo` file.
#
# Parameters:
#   N/A
# Returns:
#   The number of logical processors (threads) of the host machine.
function get_num_of_processors() {
    NUM_OF_CORES=$(cat /proc/cpuinfo | grep 'processor' | tail -n 1 | awk '{print $3}')
    echo $(($NUM_OF_CORES + 1))
}

# Retrieves the number of physical processors of the host machine from the
# `/proc/cpuinfo` file.
#
# Parameters:
#   N/A
# Returns:
#   The number of physical processors (cores) of the host machine.
function get_num_of_cores() {
    echo $(cat /proc/cpuinfo  | grep 'core id' | sort | uniq | wc -l)
}

# Retrieves the total amount of RAM of the host machine from the
# `/proc/meminfo` file.
#
# Parameters:
#   N/A
# Returns:
#   The amount of primary memory of the host machine in GBs.
function get_ram_in_gb() {
    MEMORY_IN_kB=$(cat /proc/meminfo | grep 'MemTotal' | awk '{print $2}')
    echo $(($MEMORY_IN_kB / 1024 / 1024))
}

# Calculates the processes elapsed time (s), CPU usage (%), the RSS (KB), and VMS (KB)
# using the `syrupy` script. The function then writes the results to the benchmarks
# file.
#
# Parameters:
#   - The command to be run.
# Returns:
#   The elapsed time between the execution of the given command and the time it finished.
function time_taken() {
    # Set the internal field separator to the new line character
    # By default a bash for loop splits a line by whitespace
    OG_IFS=$IFS
    IFS=$'\n'

    TEMP_FILE="tmp_bench"
    
    # Get the command output and cut the top line (header line)
    { python $SYRUPY -S -C --no-raw-process-log "$@" 2> /dev/null; } | sed 1d > $TEMP_FILE

    LAST_LINE=$(tail $TEMP_FILE -n 1)
    ELAPSED_TIME=$(echo $LAST_LINE | awk '{print $4}')
    readarray -d ":" -t ELAPSED_TIME_ARR <<< $ELAPSED_TIME
    ELAPSED_TIME=$((${ELAPSED_TIME_ARR[0]} * 60 + ${ELAPSED_TIME_ARR[1]}))
    AVERAGE_CPU=$(float_to_int $(echo $LAST_LINE | awk '{print $5}'))
    AVERAGE_RSS=$(echo $LAST_LINE | awk '{print $7}')
    AVERAGE_VMS=$(echo $LAST_LINE | awk '{print $8}')

    # Cut the last line from the file as it is only used for the total elapsed time
    # of the process under investigation.
    # Accumulate the sum of all readings for each measurement
    for line in $(cat $TEMP_FILE | sed \$d); do
        CURRENT_CPU=$(float_to_int $(echo $line | awk '{print $5}'))
        AVERAGE_CPU=$(($AVERAGE_CPU + $CURRENT_CPU))

        CURRENT_RSS=$(echo $line | awk '{print $7}')
        AVERAGE_RSS=$(($AVERAGE_RSS + $CURRENT_RSS))

        CURRENT_VMS=$(echo $line | awk '{print $8}')
        AVERAGE_VMS=$(($AVERAGE_VMS + $CURRENT_VMS))
    done

    # Calculate the average of each measurement
    NUM_OF_LINES=$(wc -l $TEMP_FILE | awk '{print $1}')
    if [ $NUM_OF_LINES -ne 0 ]
    then
        AVERAGE_CPU=$(($AVERAGE_CPU / $NUM_OF_LINES))
        AVERAGE_RSS=$(($AVERAGE_RSS / $NUM_OF_LINES))
        AVERAGE_VMS=$(($AVERAGE_VMS / $NUM_OF_LINES))
    fi

    # Calculate the score
    # The score is out of 100 with a weighted distribution on each of the four measured
    # properties as follows:
    # - Time contributes to 40% (lower is better)
    #   - 100% = 1 second
    #   - 0% = 10 seconds+ TODO: Review again after more algorithms are introduced
    # - Average CPU utilisation contributes to 30% (lower is better)
    #   - 100% = 1%
    #   - 5% = 100%
    # - Average RSS contributes to 15% (lower is better)
    #   - 100% = <=3000 ?? Based on algorithm ??
    #   - 0% = >=10,000
    # - Average VMS contributes to 15% (lower is better)
    #   - 100% = <=6000 ?? Based on algorithm ??
    #   - 0% = >=100,000
    TIME_SCORE=$(((10 / $ELAPSED_TIME) * 40))
    CPU_SCORE=$(((100 / $AVERAGE_CPU) * 30))
    RSS_SCORE=$(((3000 / $AVERAGE_RSS) * 15))
    VMS_SCORE=$(((3000 / $AVERAGE_VMS) * 15))

    # Print the results into the benchmark file
    echo -e "${language}|${algorithm}|${ELAPSED_TIME}|${AVERAGE_CPU}|${AVERAGE_RSS}|${AVERAGE_VMS}|$(($TIME_SCORE + $CPU_SCORE + $RSS_SCORE + $VMS_SCORE))" >> $BENCHMARKS_FILE

    # Cleanup
    # - Delete temporary file(s)
    # - Reset the IFS
    rm $TEMP_FILE
    IFS=$OG_IFS

    echo $ELAPSED_TIME
}

# TODO: Add --clean flag to cleanup compiled files
# FILES_TO_CLEANUP = ()
cat /dev/null > $BENCHMARKS_FILE
echo -e "LANGUAGE|ALGORITHM|ELAPSED (s)|Avg. CPU (%)|Avg. RSS (KB)|Avg. VMS (KB)|Score" >> $BENCHMARKS_FILE
for language in "${LANGUAGES[@]}"; do
    cd $PROGRAMS_DIR/$language

    for algorithm in "${ALGORITHMS}"; do
        cd $algorithm

        case $language in
            "rust")
                rustc "${algorithm}_run.rs" -o "${algorithm}_run"
                COMMAND="./${algorithm}_run"
                if [ $TEST -eq 1 ]
                then
                    echo "> Running Rust tests for $algorithm"
                    rustc --test "${algorithm}_test.rs" -o "${algorithm}_test"
                    ./${algorithm}_test
                    if [ $(echo $?) -ne 0 ]
                    then
                        exit 1
                    fi
                fi
                ;;
            "go")
                COMMAND="go run ."
                if [ $TEST -eq 1 ]
                then
                    echo "> Running Go tests for $algorithm"
                    go test "${algorithm}_test.go"
                    if [ $(echo $?) -ne 0 ]
                    then
                        exit 1
                    fi
                fi
                ;;
            "java")
                javac -cp .:$JUNIT:$HAMCREST *.java
                COMMAND="java -cp .:${JUNIT}:${HAMCREST} ${algorithm}_run"
                if [ $TEST -eq 1 ]
                then
                    echo "> Running Java tests for $algorithm"
                    java -cp .:${JUNIT}:${HAMCREST} ${algorithm}_test
                    if [ $(echo $?) -ne 0 ]
                    then
                        exit 1
                    fi
                fi
                ;;
            "c")
                gcc -Wall -c "${algorithm}.c" "${algorithm}_run.c"
                gcc -o "${algorithm}_run" "${algorithm}.o" "${algorithm}_run.o"
                COMMAND="./${algorithm}_run"
                if [ $TEST -eq 1 ]
                then
                    echo "> Running C tests for $algorithm"
                    gcc -Wall -c "${algorithm}.c" "${algorithm}_test.c" $UNITY
                    gcc -o "${algorithm}_test" "${algorithm}.o" "${algorithm}_test.o" "unity.o"
                    ./${algorithm}_test
                    if [ $(echo $?) -ne 0 ]
                    then
                        exit 1
                    fi
                fi
                ;;
            "python")
                COMMAND="python ${algorithm}_run.py"
                if [ $TEST -eq 1 ]
                then
                    echo "> Running Python tests for $algorithm"
                    pytest .
                    if [ $(echo $?) -ne 0 ]
                    then
                        exit 1
                    fi
                fi
                ;;
            "haxe")
                HAXE_ALGORITHM=($algorithm)
                COMMAND="haxe --main ${HAXE_ALGORITHM[*]^}_Run.hx"
                if [ $TEST -eq 1 ]
                then
                    echo "> Running Haxe tests for $algorithm"
                    haxe --main "${HAXE_ALGORITHM[*]^}_Test.hx" --library utest --interp -D UTEST_PRINT_TESTS
                    if [ $(echo $?) -ne 0 ]
                    then
                        exit 1
                    fi
                fi
                ;;
        esac

        if [ $BENCHMARK -eq 1 ]
        then
            echo -ne "[${language}/${algorithm}]\t..."
            TIME_TAKEN=$(time_taken ${COMMAND})
            echo "${TIME_TAKEN}s"
        fi
        cd ..
        sleep $INTERVAL
    done
done
cd $PROGRAMS_DIR

if [ $BENCHMARK -eq 1 ]
then
    cat $BENCHMARKS_FILE | column -t -s "|" | tee $BENCHMARKS_FILE > /dev/null
    echo "Results written to $BENCHMARKS_FILE"

    # Host machine information
    AVG_SCORE=0
    SCORES="$(cat $BENCHMARKS_FILE | sed 1d | awk '{print $7}')"
    readarray -d ' ' -t SCORES <<< $SCORES
    COUNTER=0
    for score in $SCORES; do
        AVG_SCORE=$(($AVG_SCORE + $score))
        COUNTER=$(($COUNTER + 1))
    done
    AVG_SCORE=$(($AVG_SCORE / $COUNTER))

    echo -e "" >> $BENCHMARKS_FILE
    echo -e "CPU: \t\t$(get_cpu_name)" >> $BENCHMARKS_FILE
    echo -e "Processors: \t$(get_num_of_cores) Cores / $(get_num_of_processors) Threads" >> $BENCHMARKS_FILE
    echo -e "Memory: \t~$(get_ram_in_gb) GB" >> $BENCHMARKS_FILE
    echo -e "Average Score: \t$AVG_SCORE" >> $BENCHMARKS_FILE
fi
