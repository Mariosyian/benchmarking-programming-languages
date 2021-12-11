mod sieve;

use std::collections::HashMap;
use std::collections::HashSet;
use std::iter::FromIterator;

#[test]
fn test_is_prime_returns_true_for_prime_numbers() {
    // First 50 known prime numbers
    let primes = [
        2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89,
        97, 101, 103, 107, 109, 113, 127, 131, 137, 139, 149, 151, 157, 163, 167, 173, 179, 181,
        191, 193, 197, 199, 211, 223, 227, 229,
    ];
    for prime in primes {
        assert_eq!(true, sieve::is_prime(prime))
    }
}

#[test]
fn test_is_prime_returns_false_for_non_prime_numbers() {
    // Non-prime numbers from 0 to 50
    let non_primes = [
        0, 1, 4, 6, 8, 10, 12, 14, 15, 16, 18, 20, 21, 22, 24, 25, 26, 27, 28, 30, 32, 33, 34, 35,
        36, 38, 39, 40, 42, 44, 45, 46, 48, 49, 50,
    ];
    for non_prime in non_primes {
        assert_eq!(false, sieve::is_prime(non_prime))
    }
}

#[test]
fn test_sieve_returns_the_correct_number_of_prime_numbers_given_n() {
    // Known number of prime numbers given the dictionary key as an upper bound.
    let mut limits = HashMap::new();
    limits.insert(1, 0);
    limits.insert(10, 4);
    limits.insert(100, 25);
    limits.insert(1000, 168);
    limits.insert(10000, 1229);
    for (key, value) in limits {
        assert_eq!(sieve::sieve(key).len(), value)
    }
}

#[test]
fn test_sieve_returns_the_correct_list_of_prime_numbers_given_n() {
    // Known list of prime numbers given the dictionary key as an upper bound.
    let mut limits = HashMap::new();
    limits.insert(1, vec![]);
    limits.insert(10, vec![2, 3, 5, 7]);
    limits.insert(
        100,
        vec![
            2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83,
            89, 97,
        ],
    );

    for (key, value) in limits {
        assert_eq!(sieve::sieve(key), HashSet::from_iter(value))
    }
}
