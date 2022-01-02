#include "../../../dependencies/unity/unity.h"
#include "sieve.h"

#define FALSE 0
#define TRUE 1

void setUp(void) {
    // Nothing to do here
}

void tearDown(void) {
    // Nothing to do here
}

void test_elementExists_returns_true_for_existing_element(void) {
    int elements[5] = {0, 1, 2, 3, 4};
    int i = 0;
    for (; i < 5; i ++) {
        TEST_ASSERT_EQUAL_INT(TRUE, elementExists(elements[i], 5, elements));
    }
}

void test_elementExists_returns_false_for_non_existing_element(void) {
    int elements[5] = {0, 1, 2, 3, 4};
    int i = 0;
    for (; i < 5; i ++) {
        TEST_ASSERT_EQUAL_INT(FALSE, elementExists(6, 5, elements));
    }
}

void test_isPrime_returns_true_for_prime_numbers(void) {
    int primes[50] = {
        2,
        3,
        5,
        7,
        11,
        13,
        17,
        19,
        23,
        29,
        31,
        37,
        41,
        43,
        47,
        53,
        59,
        61,
        67,
        71,
        73,
        79,
        83,
        89,
        97,
        101,
        103,
        107,
        109,
        113,
        127,
        131,
        137,
        139,
        149,
        151,
        157,
        163,
        167,
        173,
        179,
        181,
        191,
        193,
        197,
        199,
        211,
        223,
        227,
        229,
    };
    int index = 0;
    for (; index < 50; index ++) {
        TEST_ASSERT_EQUAL_INT64(isPrime(primes[index]), TRUE);
    }
}


void test_isPrime_returns_false_for_non_prime_numbers(void) {
    int nonPrimes[35] = {
        0,
        1,
        4,
        6,
        8,
        10,
        12,
        14,
        15,
        16,
        18,
        20,
        21,
        22,
        24,
        25,
        26,
        27,
        28,
        30,
        32,
        33,
        34,
        35,
        36,
        38,
        39,
        40,
        42,
        44,
        45,
        46,
        48,
        49,
        50,
    };
    int index = 0;
    for (; index < 35; index ++) {
        TEST_ASSERT_EQUAL_INT64(isPrime(nonPrimes[index]), FALSE);
    }
}

void test_sieve_returns_the_correct_number_of_prime_numbers_given_n(void) {
    int limits[7][2] = {
        {0, 0},
        {1, 0},
        {2, 1},
        {10, 4},
        {100, 25},
        {1000, 168},
        {10000, 1229},
    };

    int i = 0;
    for (; i < 7; i ++) {
        int* result = run(limits[i][0]);
        int numOfElements = 0;
        while (*result != 0) {
            numOfElements ++;
            *result ++;
        }
        TEST_ASSERT_EQUAL_INT64(limits[i][1], numOfElements);
    }
}

void test_sieve_returns_the_correct_list_of_prime_numbers_given_n(void) {
    int limits[5] = {0, 1, 2, 10, 100};
    int values[5][25] = {
        {},
        {},
        {2},
        {2, 3, 5, 7},
        {
            2,
            3,
            5,
            7,
            11,
            13,
            17,
            19,
            23,
            29,
            31,
            37,
            41,
            43,
            47,
            53,
            59,
            61,
            67,
            71,
            73,
            79,
            83,
            89,
            97,
        }
    };
    int numOfElements[5] = {0, 0, 1, 4, 25};

    int i = 0;
    for (; i < 5; i ++) {
        TEST_ASSERT_EQUAL_INT_ARRAY(values[i], run(limits[i]), numOfElements[i]);
    }
}

int main(void) {
    UNITY_BEGIN();
    RUN_TEST(test_elementExists_returns_true_for_existing_element);
    RUN_TEST(test_elementExists_returns_false_for_non_existing_element);
    RUN_TEST(test_isPrime_returns_true_for_prime_numbers);
    RUN_TEST(test_isPrime_returns_false_for_non_prime_numbers);
    RUN_TEST(test_sieve_returns_the_correct_number_of_prime_numbers_given_n);
    RUN_TEST(test_sieve_returns_the_correct_list_of_prime_numbers_given_n);
    return UNITY_END();
}
