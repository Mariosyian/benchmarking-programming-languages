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
#
# Exit values:
#   0 - OK
#   1 - Test failure
#   2 - Erroneous input

CURRENT_DIR=$(pwd)
PROGRAMS_DIR="${CURRENT_DIR}/implementations"
BENCHMARKS_DIR="${CURRENT_DIR}/benchmarks"
BENCHMARKS_FILE="${BENCHMARKS_DIR}/benchmarks_$(date +%F_%R)"
MARKDOWN_DIR="${CURRENT_DIR}/markdown-parser"

DEPENDENCIES_DIR="${CURRENT_DIR}/dependencies"
SYRUPY="${DEPENDENCIES_DIR}/syrupy/syrupy.py"
JUNIT="${DEPENDENCIES_DIR}/junit/junit-4.10.jar"
HAMCREST="${DEPENDENCIES_DIR}/hamcrest/hamcrest-2.2.jar"
UNITY="${DEPENDENCIES_DIR}/unity/unity.c"

LANGUAGES=(rust go java c python haxe)
ALGORITHMS=(sieve)
MARKDOWNS=(python haxe)

INTERVAL=1

# Capture any CL flags provided
BENCHMARK=1
DISPLAY=0
RUNS=10
TEST=0
VERBOSE=0
CSV=0
while test $# -gt 0; do
  case "$1" in
  --csv)
        shift
        CSV=1
        BENCHMARKS_FILE="${BENCHMARKS_FILE}.csv"
        ;;
    -d|--display)
        shift
        DISPLAY=1
        ;;
    -h|--help)
        echo "The Computer Language Benchmarks Game"
        echo "Author: Marios Yiannakou"
        echo ""
        echo "This script executes and measures the performance of all algorithms"
        echo "written in the implementations directory. The script compiles and runs"
        echo "all language implementations of one algorithm, before moving to the next."
        echo ""
        echo "Usage: ./benchmarks.sh [--csv] [-d|--display-report] [-h|--help] [-r 10|--runs 10] [-t|--test] [-v|--verbose] [--test-and-benchmark]"
        echo ""
        echo "Options:"
        echo "--csv                 save the benchmark results as a CSV file"
        echo "-d, --display-report  display the benchmark report after completion"
        echo "-h, --help            show this help message and exit"
        echo "-r, --runs            the amount of times to run each algorithm. Defaults to 10"
        echo "-t, --test            run tests for all algorithms without benchmarking (exits if any tests fail)"
        echo "-v, --verbose         save the report for each run of each algorithm instead of their final average"
        echo "--test-and-benchmark  run tests and benchmarks for all algorithms (exits if any tests fail)"
        exit 0
        ;;
    -r|--runs)
        shift
        # TODO: Until a regex can be matched in the case statement
        #       trust that the user will not give erroneous input.
        RUNS=$1
        shift
        ;;
    -t|--test)
        shift
        TEST=1
        BENCHMARK=0
        ;;
    -v|--verbose)
        shift
        VERBOSE=1
        ;;
    --test-and-benchmark)
        shift
        TEST=1
        BENCHMARK=1
        ;;
    *)
        echo "Invalid option. Run 'benchmark.sh --help' for usage help"
        exit 2
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

    if [ $CPU_BRAND == "AMD" ]; then
        echo $CPU_MODEL | awk '{printf "%s %s %s %s\n", $1, $2, $3, $4}'
    elif [ $CPU_BRAND == "Intel(R)" ]; then
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
# using the `syrupy` script.
#
# Parameters:
#   - The command to be run.
# Returns:
#   A space delimeted string containing:
#       - The elapsed time between the execution of the given command and the time it finished.
#       - The average CPU usage of the given command.
#       - The average RSS memory usage of the given command.
#       - The average VMS memory usage of the given command.
#       - The time score of the given command.
#       - The CPU score of the given command.
#       - The RSS score of the given command.
#       - The VMS score of the given command.
function time_taken() {
    # Set the internal field separator to the new line character
    # By default a bash for loop splits a line by whitespace
    OG_IFS=$IFS
    IFS=$'\n'

    TEMP_FILE="tmp_bench"
    TEMP_TIME_FILE="tmp_time"

    # Get the command output and cut the top line (header line)
    { python $SYRUPY -S -C --no-raw-process-log "$@" 2> $TEMP_TIME_FILE; } | sed 1d > $TEMP_FILE
    # TODO: New benchmark tool `/usr/bin/time`
    # /usr/bin/time -f "Unshared:%D\nElapsed real time (s):%e\nAvg Total Mem: %K\nMax RSS: %M\nAvg RSS: %t\nCPU%%: %P\nCPU sec (sys):%S\nCPU sec (usr):%U"
    # Unshared:0, Elapsed real time (s):171.79, Avg Total Mem: 0, Max RSS: 183932, Avg RSS: 0, CPU%: 46%, CPU sec (sys):2.86, CPU sec (usr):77.24

    LAST_LINE=$(tail $TEMP_FILE -n 1)
    ELAPSED_TIME=$(echo $LAST_LINE | awk '{print $4}')
    readarray -d ":" -t ELAPSED_TIME_ARR <<< $ELAPSED_TIME
    ELAPSED_TIME=$((${ELAPSED_TIME_ARR[0]} * 60 + ${ELAPSED_TIME_ARR[1]}))
    # ELAPSED_TIME_HOURS=$(cat $TEMP_TIME_FILE | grep "Total run time" | awk '{print $5}')
    # ELAPSED_TIME_MINUTES=$(cat $TEMP_TIME_FILE | grep "Total run time" | awk '{print $7}')
    # ELAPSED_TIME_SECONDS=$(cat $TEMP_TIME_FILE | grep "Total run time" | awk '{print $9}')
    # ELAPSED_TIME=$(bc <<< "$ELAPSED_TIME_HOURS * 3600 + $ELAPSED_TIME_MINUTES * 60 + $ELAPSED_TIME_SECONDS")

    LOCAL_AVERAGE_CPU=$(float_to_int $(echo $LAST_LINE | awk '{print $5}'))
    LOCAL_AVERAGE_RSS=$(echo $LAST_LINE | awk '{print $7}')
    LOCAL_AVERAGE_VMS=$(echo $LAST_LINE | awk '{print $8}')

    # Cut the last line from the file as it is only used for the total elapsed time
    # of the process under investigation.
    # Accumulate the sum of all readings for each measurement
    for line in $(cat $TEMP_FILE | sed \$d); do
        CURRENT_CPU=$(float_to_int $(echo $line | awk '{print $5}'))
        LOCAL_AVERAGE_CPU=$(($LOCAL_AVERAGE_CPU + $CURRENT_CPU))

        CURRENT_RSS=$(echo $line | awk '{print $7}')
        LOCAL_AVERAGE_RSS=$(($LOCAL_AVERAGE_RSS + $CURRENT_RSS))

        CURRENT_VMS=$(echo $line | awk '{print $8}')
        LOCAL_AVERAGE_VMS=$(($LOCAL_AVERAGE_VMS + $CURRENT_VMS))
    done

    # Calculate the average of each measurement
    NUM_OF_LINES=$(wc -l $TEMP_FILE | awk '{print $1}')
    if [ $NUM_OF_LINES -ne 0 ]; then
        LOCAL_AVERAGE_CPU=$(($LOCAL_AVERAGE_CPU / $NUM_OF_LINES))
        LOCAL_AVERAGE_RSS=$(($LOCAL_AVERAGE_RSS / $NUM_OF_LINES))
        LOCAL_AVERAGE_VMS=$(($LOCAL_AVERAGE_VMS / $NUM_OF_LINES))
    fi

    # Safeguard against fractions rounded to 0.
    if [ $LOCAL_AVERAGE_CPU -le 1 ]; then
        LOCAL_AVERAGE_CPU=1
    fi
    if [ $LOCAL_AVERAGE_RSS -le 1 ]; then
        LOCAL_AVERAGE_RSS=1
    fi
    if [ $LOCAL_AVERAGE_VMS -le 1 ]; then
        LOCAL_AVERAGE_VMS=1
    fi

    # Calculate the score
    # The score is out of 100 with a weighted distribution on each of the four measured
    # properties as follows:
    # - Time contributes to 50% (lower is better)
    #   - 100% = 1 second
    #   - 0% = 10 seconds+ TODO: Review again after more algorithms are introduced
    # - Average CPU utilisation contributes to 30% (lower is better)
    #   - 100% = 1%
    #   - 5% = 100%
    # - Average RSS contributes to 10% (lower is better)
    #   - 100% = <=3000 ?? Based on algorithm ??
    #   - 0% = >=10,000
    # - Average VMS contributes to 10% (lower is better)
    #   - 100% = <=6000 ?? Based on algorithm ??
    #   - 0% = >=100,000
    TIME_SCORE=$(((10 / $ELAPSED_TIME) * 50))
    # TIME_SCORE=$(bc <<< "(10 / $ELAPSED_TIME) * 50")
    CPU_SCORE=$(((100 / $LOCAL_AVERAGE_CPU) * 30))
    RSS_SCORE=$(((3000 / $LOCAL_AVERAGE_RSS) * 10))
    VMS_SCORE=$(((6000 / $LOCAL_AVERAGE_VMS) * 10))

    # Cleanup
    # - Delete temporary file(s)
    # - Reset the IFS
    rm $TEMP_FILE
    rm $TEMP_TIME_FILE
    IFS=$OG_IFS

    echo "$ELAPSED_TIME $LOCAL_AVERAGE_CPU $LOCAL_AVERAGE_RSS $LOCAL_AVERAGE_VMS $(($TIME_SCORE + $CPU_SCORE + $RSS_SCORE + $VMS_SCORE))"
}

# Updates the global variables required to calculate the score of a language.
#
# Parameters:
#   - The list of global variable values to update in the order:
#     TIME_TAKEN, GLOBAL_AVERAGE_CPU, GLOBAL_AVERAGE_RSS, GLOBAL_AVERAGE_VMS, SCORE
# Returns:
#   N/A
function update_globals() {
    TIME_TAKEN=$(($TIME_TAKEN + $1))
    # TIME_TAKEN=$(bc <<< "$TIME_TAKEN + $1")
    GLOBAL_AVERAGE_CPU=$(($GLOBAL_AVERAGE_CPU + $2))
    GLOBAL_AVERAGE_RSS=$(($GLOBAL_AVERAGE_RSS + $3))
    GLOBAL_AVERAGE_VMS=$(($GLOBAL_AVERAGE_VMS + $4))
    SCORE=$(($SCORE + $5))
}

# Resets the global variables required to calculate the score of a language.
#
# Parameters:
#   N/A
# Returns:
#   N/A
function reset_globals() {
    GLOBAL_AVERAGE_CPU=0
    GLOBAL_AVERAGE_RSS=0
    GLOBAL_AVERAGE_VMS=0
    SCORE=0
}

# Runs the toy programs
#
# Parameters:
#   N/A
# Returns:
#   N/A
function bench_toy_programs() {
    cd $PROGRAMS_DIR
    for language in "${LANGUAGES[@]}"; do
        if [ -d $language ]; then
            cd $language
        else
            continue
        fi
        for algorithm in "${ALGORITHMS[@]}"; do
            if [ -d $algorithm ]; then
                cd $algorithm
            else
                continue
            fi

            case $language in
                "rust")
                    rustc "${algorithm}_run.rs" -o "${algorithm}_run"
                    COMMAND="./${algorithm}_run"
                    if [ $TEST -eq 1 ]; then
                        echo "> Running Rust tests for $algorithm"
                        rustc --test "${algorithm}_test.rs" -o "${algorithm}_test"
                        ./${algorithm}_test
                        if [ $(echo $?) -ne 0 ]; then
                            exit 1
                        fi
                    fi
                    ;;
                "go")
                    go build -o "${algorithm}_run" .
                    COMMAND="./${algorithm}_run"
                    if [ $TEST -eq 1 ]; then
                        echo "> Running Go tests for $algorithm"
                        go test "${algorithm}_test.go"
                        if [ $(echo $?) -ne 0 ]; then
                            exit 1
                        fi
                    fi
                    ;;
                "java")
                    javac -cp .:$JUNIT:$HAMCREST *.java
                    COMMAND="java -cp .:${JUNIT}:${HAMCREST} ${algorithm}_run"
                    if [ $TEST -eq 1 ]; then
                        echo "> Running Java tests for $algorithm"
                        java -cp .:${JUNIT}:${HAMCREST} ${algorithm}_test
                        if [ $(echo $?) -ne 0 ]; then
                            exit 1
                        fi
                    fi
                    ;;
                "c")
                    # TODO: Try to implement both the normal executable and the -O2 optimisation
                    gcc -Wall -c "${algorithm}.c" "${algorithm}_run.c"
                    gcc -o "${algorithm}_run" "${algorithm}.o" "${algorithm}_run.o"
                    COMMAND="./${algorithm}_run"
                    if [ $TEST -eq 1 ]; then
                        echo "> Running C tests for $algorithm"
                        gcc -Wall -c "${algorithm}.c" "${algorithm}_test.c" $UNITY
                        gcc -o "${algorithm}_test" "${algorithm}.o" "${algorithm}_test.o" "unity.o"
                        ./${algorithm}_test
                        if [ $(echo $?) -ne 0 ]; then
                            exit 1
                        fi
                    fi
                    ;;
                "python")
                    COMMAND="python ${algorithm}_run.py"
                    if [ $TEST -eq 1 ]; then
                        echo "> Running Python tests for $algorithm"
                        pytest .
                        if [ $(echo $?) -ne 0 ]; then
                            exit 1
                        fi
                    fi
                    ;;
                "haxe")
                    COMMAND="haxe --main ${algorithm^}_Run.hx --interp"
                    if [ $TEST -eq 1 ]; then
                        echo "> Running Haxe tests for $algorithm"
                        haxe --main "${algorithm^}_Test.hx" --library utest --interp -D UTEST_PRINT_TESTS
                        if [ $(echo $?) -ne 0 ]; then
                            exit 1
                        fi
                    fi
                    ;;
                *)
                    echo "($language) has no compilation steps. Did you forget to update the benchmark script?"
                    ;;
            esac

            if [ $BENCHMARK -eq 1 ]; then
                reset_globals
                for count in $(eval echo {1..$RUNS}); do
                    echo -ne "[${language}/${algorithm}-$(seq -f "%0${#RUNS}g" $count $count)]\t...\r"
                    # https://stackoverflow.com/questions/23564995/how-to-modify-a-global-variable-within-a-function-in-bash
                    readarray -d " " -t TIME_FNC <<< $(time_taken ${COMMAND})
                    update_globals ${TIME_FNC[@]}
                    if [ $VERBOSE -eq 1 ]; then
                        if [ $CSV -eq 1 ]; then
                            echo -e "${language},${algorithm},$(seq -f "%0${#RUNS}g" $count $count),${TIME_TAKEN},${GLOBAL_AVERAGE_CPU},${GLOBAL_AVERAGE_RSS},${GLOBAL_AVERAGE_VMS},$SCORE" >> $BENCHMARKS_FILE 
                        else
                            echo -e "${language}|${algorithm}|$(seq -f "%0${#RUNS}g" $count $count)|${TIME_TAKEN}|${GLOBAL_AVERAGE_CPU}|${GLOBAL_AVERAGE_RSS}|${GLOBAL_AVERAGE_VMS}|$SCORE" >> $BENCHMARKS_FILE
                        fi
                        reset_globals
                    fi
                done

                echo -e "[${language}/${algorithm}-$(seq -f "%0${#RUNS}g" ${RUNS} ${RUNS})]\t...${TIME_TAKEN}s"
                if [ $VERBOSE -eq 0 ]; then
                    GLOBAL_AVERAGE_CPU=$(( ${GLOBAL_AVERAGE_CPU} / $RUNS))
                    GLOBAL_AVERAGE_RSS=$(( ${GLOBAL_AVERAGE_RSS} / $RUNS))
                    GLOBAL_AVERAGE_VMS=$(( ${GLOBAL_AVERAGE_VMS} / $RUNS))
                    SCORE=$(( ${SCORE} / $RUNS))
                    if [ $CSV -eq 1 ]; then
                        echo -e "${language},${algorithm},${RUNS},${TIME_TAKEN},${GLOBAL_AVERAGE_CPU},${GLOBAL_AVERAGE_RSS},${GLOBAL_AVERAGE_VMS},$SCORE" >> $BENCHMARKS_FILE
                    else
                        echo -e "${language}|${algorithm}|${RUNS}|${TIME_TAKEN}|${GLOBAL_AVERAGE_CPU}|${GLOBAL_AVERAGE_RSS}|${GLOBAL_AVERAGE_VMS}|$SCORE" >> $BENCHMARKS_FILE
                    fi
                fi
                TIME_TAKEN=0
            fi
            cd ..
            sleep $INTERVAL
        done
        cd ..
    done
    cd $PROGRAMS_DIR
}

# Runs the markdown parser
#
# Parameters:
#   N/A
# Returns:
#   N/A
function bench_markdowns() {
    cd $MARKDOWN_DIR
    for language in "${MARKDOWNS[@]}"; do
        cd $language
        case $language in
            "python")
                COMMAND="python markdown_parser.py --demo"
                if [ $TEST -eq 1 ]; then
                    echo "> Running Python tests for markdown parser"
                    pytest .
                    if [ $(echo $?) -ne 0 ]; then
                        exit 1
                    fi
                fi
                ;;
            "haxe")
                COMMAND="haxe --run Markdown_Parser.hx --demo"
                if [ $TEST -eq 1 ]; then
                    echo "> Running Haxe tests for markdown parser"
                    haxe --main "Markdown_Parser_Test.hx" --library utest --interp -D UTEST_PRINT_TESTS
                    if [ $(echo $?) -ne 0 ]; then
                        exit 1
                    fi
                fi
                ;;
            *)
                echo "($language) has no compilation steps. Did you forget to update the benchmark script?"
                ;;
        esac
        if [ $BENCHMARK -eq 1 ]; then
            reset_globals
            for count in $(eval echo {1..$RUNS}); do
                echo -ne "[${language}/markdown-parser-$(seq -f "%0${#RUNS}g" $count $count)]\t...\r"
                # https://stackoverflow.com/questions/23564995/how-to-modify-a-global-variable-within-a-function-in-bash
                readarray -d " " -t TIME_FNC <<< $(time_taken ${COMMAND})
                update_globals ${TIME_FNC[@]}
                if [ $VERBOSE -eq 1 ]; then
                    if [ $CSV -eq 1 ]; then
                        echo -e "${language},markdown-parser,$(seq -f "%0${#RUNS}g" $count $count),${TIME_TAKEN},${GLOBAL_AVERAGE_CPU},${GLOBAL_AVERAGE_RSS},${GLOBAL_AVERAGE_VMS},$SCORE" >> $BENCHMARKS_FILE 
                    else
                        echo -e "${language}|markdown-parser|$(seq -f "%0${#RUNS}g" $count $count)|${TIME_TAKEN}|${GLOBAL_AVERAGE_CPU}|${GLOBAL_AVERAGE_RSS}|${GLOBAL_AVERAGE_VMS}|$SCORE" >> $BENCHMARKS_FILE
                    fi
                    reset_globals
                fi
            done

            echo -e "[${language}/markdown-parser-$(seq -f "%0${#RUNS}g" ${RUNS} ${RUNS})]\t...${TIME_TAKEN}s"
            if [ $VERBOSE -eq 0 ]; then
                GLOBAL_AVERAGE_CPU=$(( ${GLOBAL_AVERAGE_CPU} / $RUNS))
                GLOBAL_AVERAGE_RSS=$(( ${GLOBAL_AVERAGE_RSS} / $RUNS))
                GLOBAL_AVERAGE_VMS=$(( ${GLOBAL_AVERAGE_VMS} / $RUNS))
                SCORE=$(( ${SCORE} / $RUNS))
                if [ $CSV -eq 1 ]; then
                    echo -e "${language},markdown-parser,${RUNS},${TIME_TAKEN},${GLOBAL_AVERAGE_CPU},${GLOBAL_AVERAGE_RSS},${GLOBAL_AVERAGE_VMS},$SCORE" >> $BENCHMARKS_FILE
                else
                    echo -e "${language}|markdown-parser|${RUNS}|${TIME_TAKEN}|${GLOBAL_AVERAGE_CPU}|${GLOBAL_AVERAGE_RSS}|${GLOBAL_AVERAGE_VMS}|$SCORE" >> $BENCHMARKS_FILE
                fi
            fi
            TIME_TAKEN=0
            # File created from the markdown parser.
            rm "parsed.html"
        fi
        cd ..
        sleep $INTERVAL
    done
    cd $CURRENT_DIR
}

# TODO: Add --clean flag to cleanup compiled files
# FILES_TO_CLEANUP = ()
TIME_TAKEN=0
cat /dev/null > $BENCHMARKS_FILE
if [ $CSV -eq 1 ]; then
    echo -e "LANGUAGE,ALGORITHM,RUN,ELAPSED (s),Avg. CPU (%),Avg. RSS (KB),Avg. VMS (KB),SCORE" >> $BENCHMARKS_FILE
else
    echo -e "LANGUAGE|ALGORITHM|RUN|ELAPSED (s)|Avg. CPU (%)|Avg. RSS (KB)|Avg. VMS (KB)|SCORE" >> $BENCHMARKS_FILE
fi
# ******************************************
# ********** RUN THE TOY PROGRAMS **********
# ******************************************
bench_toy_programs

# ******************************************
# ******** RUN THE MARKDOWN PARSERS ********
# ******************************************
bench_markdowns

if [ $BENCHMARK -eq 1 ] && [ $CSV -eq 0 ]; then
    BENCHMARKS_FILE_B="${BENCHMARKS_FILE}_B"
    cat $BENCHMARKS_FILE | column -t -s "|" > ${BENCHMARKS_FILE_B}

    AVERAGE_SCORE=0
    SCORES=$(cat $BENCHMARKS_FILE_B | sed 1d | awk '{print $8}')
    readarray -d ' ' -t SCORES <<< $SCORES
    COUNTER=0
    for score in $SCORES; do
        AVERAGE_SCORE=$(($AVERAGE_SCORE + $score))
        COUNTER=$(($COUNTER + 1))
    done
    if [ $COUNTER -eq 0 ]; then
        AVERAGE_SCORE=0
    else
        AVERAGE_SCORE=$(($AVERAGE_SCORE / $COUNTER))
    fi

    # Host machine information
    echo -e "" >> $BENCHMARKS_FILE_B
    echo -e "CPU:            $(get_cpu_name)" >> $BENCHMARKS_FILE_B
    echo -e "Processors:     $(get_num_of_cores) Cores / $(get_num_of_processors) Threads" >> $BENCHMARKS_FILE_B
    echo -e "Memory:         ~$(get_ram_in_gb) GB" >> $BENCHMARKS_FILE_B
    echo -e "Average Score:  $AVERAGE_SCORE" >> $BENCHMARKS_FILE_B

    mv $BENCHMARKS_FILE_B $BENCHMARKS_FILE

    echo "Results written to $BENCHMARKS_FILE"
elif [ $BENCHMARK -eq 1 ] && [ $CSV -eq 1 ]; then
    echo "Results written to $BENCHMARKS_FILE"
fi

if [ $BENCHMARK -eq 1 ] && [ $DISPLAY -eq 1 ]; then
    echo "                         -----------------------------------"
    cat $BENCHMARKS_FILE
fi
