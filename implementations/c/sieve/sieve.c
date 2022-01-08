#include "sieve.h"

#include <stdio.h>
#include <stdlib.h>

#define ARRAY_SIZE_MULTIPLIER 2

#define FALSE 0
#define TRUE 1

int isPrime(int number) {
	if (number < 2) {
		return FALSE;
	}

    int i;
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
        if (*(array + i) == element) {
            return TRUE;
        }
    }

    return FALSE;
}

int* extendArray(int* array, int currentSize) {
    int newSize = currentSize * ARRAY_SIZE_MULTIPLIER;
    int *newArray = malloc(newSize * sizeof(int));
    if (newArray == NULL) {
        printf("Memory allocation to (newArray) failed.");
        exit(1);
    }

    int index;
    for (index = 0; index < currentSize; index ++) {
        *(newArray + index) = *(array + index);
    }
    for (index = currentSize; index < newSize; index ++) {
        *(newArray + index) = 0;
    }

    return newArray;
}

int* run(int upperBound) {
    int arraySize = 1;
    int *primes = malloc(arraySize * sizeof(int));
    if (primes == NULL) {
        printf("Memory allocation to (primes) failed.");
        exit(1);
    }

    if (upperBound == 0 || upperBound == 1) {
        *(primes + 0) = 0;
        return primes;
    } else if (upperBound == 2) {
        *(primes + 0) = 2;
        return primes;
    }

    int index = 0;
    int i = 2;
    int j = 0;
    for (i = 2; i < upperBound; i ++) {
        if (index >= arraySize) {
            extendArray(primes, arraySize);
            arraySize = arraySize * ARRAY_SIZE_MULTIPLIER;
        }
        for (j = 0; j < i; j ++) {
            int currentNum = i * j;
            if (currentNum > upperBound) {
                continue;
            }
            if (elementExists(currentNum, arraySize, primes) == TRUE) {
                continue;
            }

            if (isPrime(currentNum)) {
                *(primes + index) = currentNum;
                index ++;
            }
        }
    }

    // Fill rest of data structure with zeros
    if (index < arraySize) {
        for (; index < arraySize; index ++) {
            *(primes + index) = 0;
        }
    }

    return primes;
}
