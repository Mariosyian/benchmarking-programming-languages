#!/bin/bash
ROOT_DIR=$(pwd)
PROGRAMS_DIR="${ROOT_DIR}/implementations"
DEPENDENCIES_DIR="${ROOT_DIR}/dependencies"

JUNIT="${DEPENDENCIES_DIR}/junit/junit-4.10.jar"
HAMCREST="${DEPENDENCIES_DIR}/hamcrest/hamcrest-2.2.jar"
UNITY="${DEPENDENCIES_DIR}/unity/unity.c"

ALGORITHMS=(sieve)

while test $# -gt 0
do
    case "$1" in
        --go)
            shift
            gofmt -l .

            for algorithm in "${ALGORITHMS[@]}"
            do
                cd "$PROGRAMS_DIR/go/$algorithm"

                go test -cover "${ROOT_DIR}/implementations/go/**/*.go"

                go run ${algorithm}_run.go $algorithm.go
            done
            ;;
        --rust)
            shift
            rustfmt --check "${ROOT_DIR}/implementations/rust/**/*.rs"

            for algorithm in "${ALGORITHMS[@]}"
            do
                cd "$PROGRAMS_DIR/rust/$algorithm"
                rustc --test ${algorithm}_test.rs -o ${algorithm}_test
                ./${algorithm}_test

                rm ${algorithm}_run ${algorithm}_test

                rustc ${algorithm}_run.rs -o ${algorithm}_run
                ./${algorithm}_run
            done
            ;;
        --java)
            shift
            for algorithm in "${ALGORITHMS[@]}"
            do
                cd "$PROGRAMS_DIR/java/$algorithm"
                javac -cp $PROGRAMS_DIR/java/${algorithm}:$JUNIT:$HAMCREST $PROGRAMS_DIR/java/${algorithm}/*.java
                java -cp $PROGRAMS_DIR/java/${algorithm}:$JUNIT:$HAMCREST ${algorithm}_test

                java -cp $PROGRAMS_DIR/java/${algorithm}:$JUNIT:$HAMCREST ${algorithm}_run
            done
            ;;
        --c)
            shift
            for algorithm in "${ALGORITHMS[@]}"
            do
                cd "$PROGRAMS_DIR/c/$algorithm"
                gcc -Wall -c ${algorithm}.c ${algorithm}_test.c $UNITY
                gcc -o ${algorithm}_test ${algorithm}.o ${algorithm}_test.o unity.o
                ./${algorithm}_test

                rm ${algorithm}.o ${algorithm}_run.o ${algorithm}_test.o unity.o ${algorithm}_run ${algorithm}_test

                gcc -Wall -c ${algorithm}.c ${algorithm}_run.c
                gcc -o ${algorithm}_run $algorithm.o ${algorithm}_run.o
                ./${algorithm}_run
            done
            ;;
        --haxe)
            shift
            for file in $(ls $PROGRAMS_DIR/haxe/**/*.hx)
            do
                haxelib run formatter --check $file
            done

            for algorithm in "${ALGORITHMS[@]}"
            do
                cd "$PROGRAMS_DIR/haxe/$algorithm"
                $HAXE --main "${HAXE_ALGORITHM[*]^}_Test.hx" --library utest --interp -D UTEST_PRINT_TESTS

                HAXE="$ROOT_DIR/haxe_20211022152000_ab0c054/haxe"
                HAXE_ALGORITHM=($algorithm)
                $HAXE --main ${HAXE_ALGORITHM[*]^}_Run.hx
            done
            ;;
        --python)
            shift
            black --check .
            isort --check .

            for algorithm in "${ALGORITHMS[@]}"
            do
                cd "$PROGRAMS_DIR/python/$algorithm"
                pytest --cov "${ROOT_DIR}/implementations/" --cov-branch "${ROOT_DIR}/implementations/" --cov-report term-missing --cov-fail-under 100
                pytest --cov "${ROOT_DIR}/markdown-parser/" --cov-branch "${ROOT_DIR}/markdown-parser/" --cov-report term-missing --cov-fail-under 80

                python "${algorithm}_run.py"
            done
            ;;
        *)
            echo "No entry for ($1). Try updating the circleCI script and try again."
            exit 1
            ;;
    esac
done
exit 0
