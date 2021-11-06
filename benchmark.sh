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

LANGUAGES=(python)
ALGORITHMS=(sieve)

EXTENSIONS=(["python"]="py")
# EXTENSIONS["c"]="c"

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

# Calculates the processes elapsed time, CPU usage, and the RSS and VMS in KB
# using the `syrupy` script. The function then writes the results to the benchmarks
# file.
#
# Parameters:
#   - The language being used (language command e.g. `python` for python).
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
    { python $SYRUPY -S -C --no-raw-process-log $1 $2 2> /dev/null; } | sed 1d > $TEMP_FILE

    ELAPSED_TIME=$(tail $TEMP_FILE -n 1 | awk '{print $4}')

    AVERAGE_CPU=0
    AVERAGE_RAM=0
    AVERAGE_RSS=0
    AVERAGE_VMS=0
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
    echo -e "\t${language}\t\t|\t${algorithm}\t\t|\t${ELAPSED_TIME}\t\t|\t${AVERAGE_CPU}\t\t|\t${AVERAGE_RSS}\t\t|\t${AVERAGE_VMS}\t\t" >> $BENCHMARKS_FILE

    # Cleanup
    # - Delete temporary file(s)
    # - Reset the IFS
    rm $TEMP_FILE
    IFS=$OG_IFS

    echo $ELAPSED_TIME
}

echo -e "\tLANGUAGE\t|\tALGORITHM\t|\tELAPSED (s)\t|\tAvg. CPU (%)\t|\tAvg. RSS (KB)\t|\tAvg. VMS (KB)" > $BENCHMARKS_FILE
for language in "${LANGUAGES[@]}"; do
    cd $PROGRAMS_DIR/$language
    EXTENSION=${EXTENSIONS[${language}]}

    for algorithm in "${ALGORITHMS}"; do
        cd $algorithm

        echo -n "Running ${language}/${algorithm}..."
        TIME_TAKEN=$(time_taken $language ${PROGRAMS_DIR}/${language}/${algorithm}/${algorithm}_run.${EXTENSION})
        echo $TIME_TAKEN

        cd ..
        sleep $INTERVAL
    done
done
cd $PROGRAMS_DIR
