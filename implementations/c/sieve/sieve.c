#include "sieve.h"

#include <stdio.h>
#include <stdlib.h>

#define ARRAY_SIZE_MULTIPLIER 2

#define FALSE 0
#define TRUE 1

int static arraySize = 1;

int isPrime(int number) {
	if (number < 2) {
		return FALSE;
	}

    int i = 2;
	for (i = 2; i < number; i ++) {
		if (number%i == 0) {
			return FALSE;
		}
	}

	return TRUE;
}

int elementExists(int element, int size, int* array) {
    int i = 0;
    for (; i < size; i ++) {
        if (array[i] == element) {
            return TRUE;
        }
    }

    return FALSE;
}

int* extendArray(int* array) {
    int *newArray = malloc(arraySize * ARRAY_SIZE_MULTIPLIER * sizeof(int));
    if (newArray == NULL) {
        printf("Memory allocation to (newArray) failed.");
        exit(1);
    }

    int index = 0;
    for (index = 0; index < arraySize; index ++) {
        newArray[index] = array[index];
    }

    arraySize = arraySize * ARRAY_SIZE_MULTIPLIER;
    return newArray;
}

int* run(int upperBound) {
    int *primes = malloc(arraySize * sizeof(int));
    if (primes == NULL) {
        printf("Memory allocation to (primes) failed.");
        exit(1);
    }

    if (upperBound == 0 || upperBound == 1) {
        return primes;
    } else if (upperBound == 2) {
        primes[0] = 2;
        return primes;
    }

    int index = 0;
    int i = 2;
    int j = 0;
    for (i = 2; i < upperBound; i ++) {
        if (index >= arraySize) {
            extendArray(primes);
        }
        for (j = 0; j < i; j ++) {
            int currentNum = i * j;
            if (currentNum > upperBound || elementExists(currentNum, index, primes) == TRUE) {
                continue;
            }

            if (isPrime(currentNum)) {
                primes[index] = currentNum;
                index ++;
            }
        }
    }

    return primes;
}
