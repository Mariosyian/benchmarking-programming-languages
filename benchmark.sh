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

LANGUAGES=(rust go java python)
ALGORITHMS=(sieve)

INTERVAL=1

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

    # Print the results into the benchmark file
    echo -e "${language}|${algorithm}|${ELAPSED_TIME}|${AVERAGE_CPU}|${AVERAGE_RSS}|${AVERAGE_VMS}" >> $BENCHMARKS_FILE

    # Cleanup
    # - Delete temporary file(s)
    # - Reset the IFS
    rm $TEMP_FILE
    IFS=$OG_IFS

    echo $ELAPSED_TIME
}

echo -e "LANGUAGE|ALGORITHM|ELAPSED (s)|Avg. CPU (%)|Avg. RSS (KB)|Avg. VMS (KB)" > $BENCHMARKS_FILE
for language in "${LANGUAGES[@]}"; do
    cd $PROGRAMS_DIR/$language

    for algorithm in "${ALGORITHMS}"; do
        cd $algorithm

        if [ $language == "rust" ]
        then
            # Compile
            rustc "${algorithm}_run.rs" -o "${algorithm}_run"
            # Run algorithm
            COMMAND="./${algorithm}_run"
            # Run tests
            # rustc --test "${algorithm}_test.rs" -o "${algorithm}_test"
            # ./${algorithm}_test
        elif [ $language == "go" ]
        then
            # Run algorithm
            COMMAND="go run ."
            # Run tests
            # TODO
        elif [ $language == "java" ]
        then
            # Compile
            javac -cp .:$JUNIT:$HAMCREST *.java
            # Run algorithm
            COMMAND="java -cp .:${JUNIT}:${HAMCREST} ${algorithm}_run"
            # Run tests
            # java -cp .:${JUNIT}:${HAMCREST} ${algorithm}_test
        elif [ $language == "python" ]
        then
            COMMAND="python ${algorithm}_run.py"
        fi

        echo -ne "[${language}/${algorithm}]\t..."
        TIME_TAKEN=$(time_taken ${COMMAND})
        echo $TIME_TAKEN
        cd ..
        sleep $INTERVAL
    done
done
cd $PROGRAMS_DIR
cat $BENCHMARKS_FILE | column -t -s "|" | tee $BENCHMARKS_FILE > /dev/null
echo "Results written to $BENCHMARKS_FILE"
