#!/bin/bash
ROOT_DIR=$(pwd)
PROGRAMS_DIR="${ROOT_DIR}/implementations"
DEPENDENCIES_DIR="${ROOT_DIR}/dependencies"

JUNIT="${DEPENDENCIES_DIR}/junit/junit-4.10.jar"
HAMCREST="${DEPENDENCIES_DIR}/hamcrest/hamcrest-2.2.jar"
UNITY="${DEPENDENCIES_DIR}/unity/unity.c"

ALGORITHMS=(sieve)

INTERVAL=1

while test $# -gt 0
do
    case "$1" in
        --go)
            shift
            for algorithm in "${ALGORITHMS[@]}"
            do
                cd "$PROGRAMS_DIR/go/$algorithm"
                go run ${algorithm}_run.go $algorithm.go
            done
            shift
            ;;
        --rust)
            shift
            for algorithm in "${ALGORITHMS[@]}"
            do
                cd "$PROGRAMS_DIR/rust/$algorithm"
                rustc ${algorithm}_run.rs -o ${algorithm}_run
                ./${algorithm}_run

                sleep $INTERVAL

                rustc --test ${algorithm}_test.rs -o ${algorithm}_test
                ./${algorithm}_test

                rm ${algorithm}_run ${algorithm}_test
            done
            shift
            ;;
        --java)
            shift
            for algorithm in "${ALGORITHMS[@]}"
            do
                cd "$PROGRAMS_DIR/java/$algorithm"
                javac -cp $PROGRAMS_DIR/java/${algorithm}:$JUNIT:$HAMCREST $PROGRAMS_DIR/java/${algorithm}/*.java
                java -cp $PROGRAMS_DIR/java/${algorithm}:$JUNIT:$HAMCREST ${algorithm}_run

                sleep $INTERVAL

                java -cp $PROGRAMS_DIR/java/${algorithm}:$JUNIT:$HAMCREST ${algorithm}_test
            done
            shift
            ;;
        --c)
            shift
            for algorithm in "${ALGORITHMS[@]}"
            do
                cd "$PROGRAMS_DIR/c/$algorithm"
                gcc -Wall -c ${algorithm}.c ${algorithm}_run.c
                gcc -o ${algorithm}_run $algorithm.o ${algorithm}_run.o
                ./${algorithm}_run

                sleep $INTERVAL

                gcc -Wall -c ${algorithm}.c ${algorithm}_test.c $UNITY
                gcc -o ${algorithm}_test ${algorithm}.o ${algorithm}_test.o unity.o
                ./${algorithm}_test

                rm ${algorithm}.o ${algorithm}_run.o ${algorithm}_test.o unity.o ${algorithm}_run ${algorithm}_test
            done
            shift
            ;;
        --haxe)
            shift
            echo "Checking formatting..."
            for file in $(ls $PROGRAMS_DIR/haxe/**/*.hx)
            do
                haxelib run formatter --check $file
            done

            for algorithm in "${ALGORITHMS[@]}"
            do
                cd "$PROGRAMS_DIR/haxe/$algorithm"
                HAXE="$ROOT_DIR/haxe_20211022152000_ab0c054/haxe"
                HAXE_ALGORITHM=($algorithm)
                $HAXE --main ${HAXE_ALGORITHM[*]^}_Run.hx

                sleep $INTERVAL

                $HAXE --main "${HAXE_ALGORITHM[*]^}_Test.hx" --library utest --interp -D UTEST_PRINT_TESTS
            done
            shift
            ;;
    esac
done
exit 0
