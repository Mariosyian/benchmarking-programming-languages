from sieve_run import run

from sieve import is_prime, sieve


# Test is_prime
def test_is_prime_returns_true_for_prime_numbers():
    # First 50 known prime numbers
    primes = [
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
    ]
    for prime in primes:
        assert is_prime(prime)


def test_is_prime_returns_false_for_non_prime_numbers():
    # Non-prime numbers from 0 to 50
    non_primes = [
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
    ]
    for non_prime in non_primes:
        assert not is_prime(non_prime)


def test_sieve_returns_the_correct_number_of_prime_numbers_given_n():
    # Known number of prime numbers given the dictionary key as an upper bound.
    # limits = { 1: 0, 10 : 4, 100 : 25, 1000 : 168, 10000 : 1229, 100000 : 9592, 1000000 : 78498, 10000000 : 664579, 100000000 : 5761455 }
    limits = {0: 0, 1: 0, 2: 1, 10: 4, 100: 25, 1000: 168, 10000: 1229}
    for limit in limits:
        assert len(sieve(limit)) == limits[limit]


def test_sieve_returns_the_correct_list_of_prime_numbers_given_n():
    # Known list of prime numbers given the dictionary key as an upper bound.
    limits = {
        0: [],
        1: [],
        2: [2],
        10: [2, 3, 5, 7],
        100: [
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
        ],
    }
    for limit in limits:
        assert list(sieve(limit)) == limits[limit]
