#!/bin/bash
# Author: Marios Yiannakou
#
# Runs all benchmarks in the `implementations` and `markdown-parser` directories sequentially,
# and creates a report inside `benchmarks`.
#
# Usage:
# - Navigate to the repositorys root directory.
# - Run the `benchmark.sh` script.
#
# Contributing:
# Toy programs
# ------------
# Each language has it's own directory, and each algorithm/program has it's own sub-directory
#   inside the appropriate language directory. Please ensure that each program is consistently
#   named across all directories (e.g. The prime sieve program is under a directory called
#   `sieve` regardless of the language implementing it).
# Each algorithm should have (at least) three files associated with it:
#   - A file that is named after the algorithm itself containing the logic.
#   - A file with the `_test` postfix to indicate this is the test file.
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
# Markdown Parser
# ---------------
# Each language has it's own directory. Please ensure that each program is consistently
#   named across all directories (i.e. `markdown_parser`) with only the case being different
#   according to a languages specifications (e.g. Haxe requires capitalised words).
# Each algorithm should have (at least) two files associated with it:
#   - A file that is named according to the specification mentioned above which either
#       runs the markdown parser, or calls a file that runs the markdown parser.
#   - A file with the `_test` postfix to indicate this is the test file.
#   - Optional: Any helper libraries required to run the algorithm.
#
# Example directory structure
# markdown-parser
# |
# |__ python
# |   |
# |   |__ markdown_parser.py        <-- The file to be run
# |   |
# |   |__ markdown_parser_test.py   <-- Make sure to test your solutions!
# |
# |__ haxe
# |   |
# |   |__ Markdown_Parser.hx        <-- The file to be run
# |   |
# |   |__ Markdown_Parser_Test.hx   <-- Make sure to test your solutions!
# |   |
# |   |__ MarkdownParser.hx         <-- The markdown parser implementation
# ...
#
# -------------------------------------------------------------------------------------------------
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
#   - Toy programs
#       - Make sure your language is included in the LANGUAGES list.
#           - In the case of a new language update the case statement with any
#               compilation steps and the command required to run the algorithm.
#       - Include your algorithm in the ALGORITHMS list.
#   - Markdown parser
#       - Make sure your language is included in the MARKDOWNS list.
#           - In the case of a new language update the case statement with any
#               compilation steps and the command required to run the algorithm.
#
# Exit values:
#   0 - OK
#   1 - Test failure
#   2 - Erroneous input
#   3 - Not found

CURRENT_DIR=$(pwd)
PROGRAMS_DIR="${CURRENT_DIR}/implementations"
BENCHMARKS_DIR="${CURRENT_DIR}/benchmarks"
BENCHMARKS_FILE="${BENCHMARKS_DIR}/$(date +%F_%H%M)"
MARKDOWN_DIR="${CURRENT_DIR}/markdown-parser"

DEPENDENCIES_DIR="${CURRENT_DIR}/dependencies"
SYRUPY="${DEPENDENCIES_DIR}/syrupy/syrupy.py"
JUNIT="${DEPENDENCIES_DIR}/junit/junit-4.10.jar"
HAMCREST="${DEPENDENCIES_DIR}/hamcrest/hamcrest-2.2.jar"
UNITY="${DEPENDENCIES_DIR}/unity/unity.c"

INTERVAL=1

# Capture any CL flags provided
BENCHMARK=1
DISPLAY=0
RUNS=100
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
        echo "Usage: ./benchmarks.sh [--csv] [-d|--display-report] [-h|--help] [-n|--name <file_name>] [-r 100|--runs 100] [-t|--test] [-v|--verbose] [--test-and-benchmark]"
        echo ""
        echo "Options:"
        echo "--csv                 save the benchmark results as a CSV file"
        echo "-d, --display-report  display the benchmark report after completion"
        echo "-h, --help            show this help message and exit"
        echo "-n, --name            change the name of the output file. Defaults to the current datetime"
        echo "-r, --runs            the amount of times to run each algorithm. Defaults to 100"
        echo "-t, --test            run tests for all algorithms without benchmarking (exits if any tests fail)"
        echo "-v, --verbose         save the report for each run of each algorithm instead of their final average"
        echo "--test-and-benchmark  run tests and benchmarks for all algorithms (exits if any tests fail)"
        exit 0
        ;;
    -n|--name)
        shift
        BENCHMARKS_FILE="${BENCHMARKS_DIR}/$1"
        shift
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
    CPU_MODEL=$(grep 'model name' /proc/cpuinfo | head -n 1 | awk '{for (i=4;i<=NF;i++) printf "%s ", $i}')
    CPU_BRAND=$(echo "$CPU_MODEL" | awk '{print $1}')

    if [ $CPU_BRAND == "AMD" ]; then
        echo "$CPU_MODEL" | awk '{printf "%s %s %s %s\n", $1, $2, $3, $4}'
    elif [ $CPU_BRAND == "Intel(R)" ]; then
        echo "$CPU_MODEL" | awk '{printf "%s %s %s %s %s\n", $1, $2, $3, $4, $5}'
    else
        echo "$CPU_MODEL"
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
    NUM_OF_CORES=$(grep 'processor' /proc/cpuinfo | tail -n 1 | awk '{print $3}')
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
    echo $(grep 'core id' /proc/cpuinfo | sort | uniq | wc -l)
}

# Retrieves the total amount of RAM of the host machine from the
# `/proc/meminfo` file.
#
# Parameters:
#   N/A
# Returns:
#   The amount of primary memory of the host machine in GBs.
function get_ram_in_gb() {
    MEMORY_IN_kB=$(grep 'MemTotal' /proc/meminfo | awk '{print $2}')
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
    { python $SYRUPY -S -C --no-raw-process-log $@ 2> $TEMP_TIME_FILE; } | sed 1d > $TEMP_FILE

    LAST_LINE=$(tail $TEMP_FILE -n 1)
    ELAPSED_TIME_HOURS=$(grep "Total run time" $TEMP_TIME_FILE | awk '{print $5}')
    ELAPSED_TIME_MINUTES=$(grep "Total run time" $TEMP_TIME_FILE | awk '{print $7}')
    ELAPSED_TIME_SECONDS=$(grep "Total run time" $TEMP_TIME_FILE | awk '{print $9}')
    elapsed_time=$(bc <<< "$ELAPSED_TIME_HOURS * 3600 + $ELAPSED_TIME_MINUTES * 60 + $ELAPSED_TIME_SECONDS")
    # Offset 'Total run time' with the 'real' time the program run for
    # This is to get rough estimate at a higher accuracy, rather than the run time at second accuracy
    estimate_time=$(echo $LAST_LINE | awk '{print $4}')
    readarray -d ":" -t ESTIMATE_TIME_ARR <<< $estimate_time
    estimate_time=$((10#${ESTIMATE_TIME_ARR[0]} * 60 + 10#${ESTIMATE_TIME_ARR[1]}))
    elapsed_time=$(bc <<< "$elapsed_time - ($(float_to_int $elapsed_time) - $estimate_time)")

    local_average_cpu=$(float_to_int $(echo $LAST_LINE | awk '{print $5}'))
    local_average_rss=$(echo $LAST_LINE | awk '{print $7}')
    local_average_vms=$(echo $LAST_LINE | awk '{print $8}')

    # Cut the last line from the file as it is only used for the total elapsed time
    # of the process under investigation.
    # Accumulate the sum of all readings for each measurement
    for line in $(cat $TEMP_FILE | sed \$d); do
        CURRENT_CPU=$(float_to_int $(echo $line | awk '{print $5}'))
        local_average_cpu=$(($local_average_cpu + $CURRENT_CPU))

        CURRENT_RSS=$(echo $line | awk '{print $7}')
        local_average_rss=$(($local_average_rss + $CURRENT_RSS))

        CURRENT_VMS=$(echo $line | awk '{print $8}')
        local_average_vms=$(($local_average_vms + $CURRENT_VMS))
    done

    # Calculate the average of each measurement
    NUM_OF_LINES=$(wc -l $TEMP_FILE | awk '{print $1}')
    if [ $NUM_OF_LINES -gt 2 ]; then
        local_average_cpu=$(($local_average_cpu / $NUM_OF_LINES))
        local_average_rss=$(($local_average_rss / $NUM_OF_LINES))
        local_average_vms=$(($local_average_vms / $NUM_OF_LINES))
    fi

    # Safeguard against fractions rounded to 0.
    if [ $local_average_cpu -le 1 ]; then
        local_average_cpu=1
    fi
    if [ $local_average_rss -le 1 ]; then
        local_average_rss=1
    fi
    if [ $local_average_vms -le 1 ]; then
        local_average_vms=1
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
    time_score=$(bc <<< "(10 / $elapsed_time) * 50")
    cpu_score=$(((100 / $local_average_cpu) * 30))
    rss_score=$(((3000 / $local_average_rss) * 10))
    vms_score=$(((6000 / $local_average_vms) * 10))

    # Cleanup
    # - Delete temporary file(s)
    # - Reset the IFS
    rm $TEMP_FILE
    rm $TEMP_TIME_FILE
    IFS=$OG_IFS

    echo "$elapsed_time $local_average_cpu $local_average_rss $local_average_vms $(($time_score + $cpu_score + $rss_score + $vms_score))"
}

# Updates the global variables required to calculate the score of a language.
#
# Parameters:
#   - The list of global variable values to update in the order:
#     total_time, global_average_cpu, global_average_rss, global_average_vms, score
# Returns:
#   N/A
function update_globals() {
    total_time=$(bc <<< "$total_time + $1")
    global_average_cpu=$(($global_average_cpu + $2))
    global_average_rss=$(($global_average_rss + $3))
    global_average_vms=$(($global_average_vms + $4))
    score=$(($score + $5))
}

# Resets the global variables required to calculate the score of a language.
#
# Parameters:
#   N/A
# Returns:
#   N/A
function reset_globals() {
    global_average_cpu=0
    global_average_rss=0
    global_average_vms=0
    score=0
}

# Pattern match the given string with a predefined patterm. 
#
# Parameters:
#   - The label of the directory to match.
# Returns:
#   The first part of the split regex if matched, the passed label otherwise.
function regex() {
    # Capture for '-haxe' postfix of a language or any other pattern
    # https://stackoverflow.com/a/18710850/5817020
    if [[ "$1" =~ [a-z]*-[a-zA-Z0-9]* ]]; then
        readarray -d "-" -t LANGUAGE <<< $1
        echo "${LANGUAGE[0]}"
    else
        echo "$1"
    fi
}

# Runs the toy programs
#
# Parameters:
#   N/A
# Returns:
#   N/A
function bench_toy_programs() {
    cd $PROGRAMS_DIR || exit 3
    for language in $(find ./ -maxdepth 1 -type d | sed 1d); do
        # Get rid of the leading './'
        language=${language:2:${#language}}
        lang=$(regex $language)

        cd $language || exit 3
        for algorithm in $(find ./ -maxdepth 1 -type d | sed 1d); do
           algorithm=${algorithm:2:${#algorithm}}
            cd $algorithm || exit 3
            case $lang in
                rust)
                    rustc "${algorithm}_run.rs" -o "${algorithm}_run"
                    COMMAND="./${algorithm}_run"
                    if [ $TEST -eq 1 ]; then
                        echo "> Running Rust tests for $algorithm"
                        rustc --test "${algorithm}_test.rs" -o "${algorithm}_test"
                        ./${algorithm}_test
                        if [ $? -ne 0 ]; then
                            exit 1
                        fi
                    fi
                    ;;
                go)
                    go build -o "${algorithm}_run" .
                    COMMAND="./${algorithm}_run"
                    if [ $TEST -eq 1 ]; then
                        echo "> Running Go tests for $algorithm"
                        go test
                        if [ $? -ne 0 ]; then
                            exit 1
                        fi
                    fi
                    ;;
                java)
                    if [ $(find *.java 2> /dev/null | wc -l) -gt 0 ]; then
                        javac -cp .:$JUNIT:$HAMCREST *.java
                    fi
                    # COMMAND="java -cp .:${JUNIT}:${HAMCREST} ${algorithm}_run"
                    jar -cvfe "${algorithm}_run.jar" "${algorithm}_run" . > /dev/null 2> /dev/null
                    COMMAND="java -jar ${algorithm}_run.jar"
                    if [ $TEST -eq 1 ]; then
                        echo "> Running Java tests for $algorithm"
                        java -cp .:${JUNIT}:${HAMCREST} ${algorithm}_test
                        if [ $? -ne 0 ]; then
                            exit 1
                        fi
                    fi
                    ;;
                c)
                    # TODO: Try to implement both the normal executable and the -O2 optimisation
                    gcc -Wall -c "${algorithm}.c" "${algorithm}_run.c"
                    gcc -o "${algorithm}_run" "${algorithm}.o" "${algorithm}_run.o"
                    COMMAND="./${algorithm}_run"
                    if [ $TEST -eq 1 ]; then
                        echo "> Running C tests for $algorithm"
                        gcc -Wall -c "${algorithm}.c" "${algorithm}_test.c" $UNITY
                        gcc -o "${algorithm}_test" "${algorithm}.o" "${algorithm}_test.o" "unity.o"
                        ./${algorithm}_test
                        if [ $? -ne 0 ]; then
                            exit 1
                        fi
                    fi
                    ;;
                python)
                    COMMAND="python ${algorithm}_run.py"
                    if [ $TEST -eq 1 ]; then
                        echo "> Running Python tests for $algorithm"
                        pytest .
                        if [ $? -ne 0 ]; then
                            exit 1
                        fi
                    fi
                    ;;
                haxe)
                    COMMAND="haxe --main ${algorithm^}_Run.hx --interp"
                    if [ $TEST -eq 1 ]; then
                        echo "> Running Haxe tests for $algorithm"
                        haxe --main "${algorithm^}_Test.hx" --library utest --interp -D UTEST_PRINT_TESTS
                        if [ $? -ne 0 ]; then
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
                for count in $(eval echo "{1..$RUNS}"); do
                    echo -ne "[${language}/${algorithm}-$(seq -f "%0${#RUNS}g" $count $count)]\t...\r"
                    # https://stackoverflow.com/questions/23564995/how-to-modify-a-global-variable-within-a-function-in-bash
                    readarray -d " " -t TIME_FNC <<< $(time_taken ${COMMAND})
                    update_globals ${TIME_FNC[@]}
                    if [ $VERBOSE -eq 1 ]; then
                        if [ $CSV -eq 1 ]; then
                            echo -e "${language},${algorithm},$(seq -f "%0${#RUNS}g" $count $count),${total_time},${global_average_cpu},${global_average_rss},${global_average_vms},$score" >> $BENCHMARKS_FILE
                        else
                            echo -e "${language}|${algorithm}|$(seq -f "%0${#RUNS}g" $count $count)|${total_time}|${global_average_cpu}|${global_average_rss}|${global_average_vms}|$score" >> $BENCHMARKS_FILE
                        fi
                        reset_globals
                    fi
                done

                echo -e "[${language}/${algorithm}-$(seq -f "%0${#RUNS}g" ${RUNS} ${RUNS})]\t...${total_time}s"
                if [ $VERBOSE -eq 0 ]; then
                    global_average_cpu=$(($global_average_cpu / $RUNS))
                    global_average_rss=$(($global_average_rss / $RUNS))
                    global_average_vms=$(($global_average_vms / $RUNS))
                    score=$(($score / $RUNS))
                    if [ $CSV -eq 1 ]; then
                        echo -e "${language},${algorithm},${RUNS},${total_time},${global_average_cpu},${global_average_rss},${global_average_vms},$score" >> $BENCHMARKS_FILE
                    else
                        echo -e "${language}|${algorithm}|${RUNS}|${total_time}|${global_average_cpu}|${global_average_rss}|${global_average_vms}|$score" >> $BENCHMARKS_FILE
                    fi
                fi
                total_time=0
            fi
            cd .. || exit 3
            sleep $INTERVAL
        done
        cd .. || exit 3
    done
    cd $PROGRAMS_DIR || exit 3
}

# Runs the markdown parser
#
# Parameters:
#   N/A
# Returns:
#   N/A
function bench_markdowns() {
    cd $MARKDOWN_DIR || exit 3
    for language in $(find ./ -maxdepth 1 -type d | sed 1d); do
        # Get rid of the leading './'
        language=${language:2:${#language}}
        lang=$(regex $language)

        cd $language || exit 3
        case $lang in
            python)
                COMMAND="python markdown_parser.py --demo"
                if [ $TEST -eq 1 ]; then
                    echo "> Running Python tests for markdown parser"
                    pytest .
                    if [ $? -ne 0 ]; then
                        exit 1
                    fi
                fi
                ;;
            haxe)
                COMMAND="haxe --run Markdown_Parser.hx --demo"
                if [ $TEST -eq 1 ]; then
                    echo "> Running Haxe tests for markdown parser"
                    haxe --main "Markdown_Parser_Test.hx" --library utest --interp -D UTEST_PRINT_TESTS
                    if [ $? -ne 0 ]; then
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
                        echo -e "${language},markdown-parser,$(seq -f "%0${#RUNS}g" $count $count),${total_time},${global_average_cpu},${global_average_rss},${global_average_vms},$score" >> $BENCHMARKS_FILE
                    else
                        echo -e "${language}|markdown-parser|$(seq -f "%0${#RUNS}g" $count $count)|${total_time}|${global_average_cpu}|${global_average_rss}|${global_average_vms}|$score" >> $BENCHMARKS_FILE
                    fi
                    reset_globals
                fi
            done

            echo -e "[${language}/markdown-parser-$(seq -f "%0${#RUNS}g" ${RUNS} ${RUNS})]\t...${total_time}s"
            if [ $VERBOSE -eq 0 ]; then
                global_average_cpu=$(($global_average_cpu / $RUNS))
                global_average_rss=$(($global_average_rss / $RUNS))
                global_average_vms=$(($global_average_vms / $RUNS))
                score=$(($score / $RUNS))
                if [ $CSV -eq 1 ]; then
                    echo -e "${language},markdown-parser,${RUNS},${total_time},${global_average_cpu},${global_average_rss},${global_average_vms},$score" >> $BENCHMARKS_FILE
                else
                    echo -e "${language}|markdown-parser|${RUNS}|${total_time}|${global_average_cpu}|${global_average_rss}|${global_average_vms}|$score" >> $BENCHMARKS_FILE
                fi
            fi
            total_time=0
            # File created from the markdown parser.
            rm "parsed.html"
        fi
        cd .. || exit 3
        sleep $INTERVAL
    done
    cd $CURRENT_DIR || exit 3
}

# TODO: Add --clean flag to cleanup compiled files
# FILES_TO_CLEANUP = ()
total_time=0
cat /dev/null > $BENCHMARKS_FILE
if [ $CSV -eq 1 ]; then
    echo -e "LANGUAGE,ALGORITHM,RUN,ELAPSED (s),Avg. CPU (%),Avg. RSS (KB),Avg. VMS (KB),SCORE" >> $BENCHMARKS_FILE
else
    echo -e "LANGUAGE|ALGORITHM|RUN|ELAPSED (s)|Avg. CPU (%)|Avg. RSS (KB)|Avg. VMS (KB)|SCORE" >> $BENCHMARKS_FILE
fi

# RUN THE TOY PROGRAMS
bench_toy_programs
# RUN THE MARKDOWN PARSERS
bench_markdowns

if [ $BENCHMARK -eq 1 ] && [ $CSV -eq 0 ]; then
    BENCHMARKS_FILE_B="${BENCHMARKS_FILE}_B"
    cat $BENCHMARKS_FILE | column -t -s "|" > ${BENCHMARKS_FILE_B}

    average_score=0
    scores=$(cat $BENCHMARKS_FILE_B | sed 1d | awk '{print $8}')
    readarray -d ' ' -t scores <<< $scores
    counter=0
    for score in $scores; do
        average_score=$(($average_score + $score))
        counter=$(($counter + 1))
    done
    if [ $counter -eq 0 ]; then
        average_score=0
    else
        average_score=$(($average_score / $counter))
    fi

    # Host machine information
    {
        echo -e ""
        echo -e "CPU:            $(get_cpu_name)"
        echo -e "Processors:     $(get_num_of_cores) Cores / $(get_num_of_processors) Threads"
        echo -e "Memory:         ~$(get_ram_in_gb) GB"
        echo -e "Average Score:  $average_score"
    } >> "$BENCHMARKS_FILE_B"

    # Reading and writing to the same file at the same time causes data corruption
    # and an empty file.
    mv $BENCHMARKS_FILE_B $BENCHMARKS_FILE

    echo "Results written to $BENCHMARKS_FILE"
elif [ $BENCHMARK -eq 1 ] && [ $CSV -eq 1 ]; then
    echo "Results written to $BENCHMARKS_FILE"
fi

if [ $BENCHMARK -eq 1 ] && [ $DISPLAY -eq 1 ]; then
    echo ""
    cat $BENCHMARKS_FILE
fi
