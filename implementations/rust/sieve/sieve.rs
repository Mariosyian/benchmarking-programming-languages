/*
 * Example code for implementing a basic prime number sieve (Sieve of Eratosthenes).
 *
 * The purpose of this program is to take a number, and find all the prime numbers that
 * are less or equal to that number.
 *
 * input:
 *     - upper_bound {u32} The integer to act as the upper bound for the program.
 * returns:
 *     - A set of the prime numbers calculated.
 *
 * author: Marios Yiannakou
 */
use std::collections::HashSet;

/**
 * Computes if the given number is a prime or not.
 *
 * param {u32} num The number to check.
 * returns `true` if the number is prime, `false` otherwise.
 */
pub fn is_prime(num: u32) -> bool {
    if num < 2 {
        return false;
    }

    for i in 2..num {
        if num % i == 0 {
            return false;
        }
    }

    return true;
}

/**
 * Checks all integer numbers from 2 up to, and including, `upper_bound` and computes
 * all the prime numbers, then returns them.
 *
 * This algorithm goes through the multiples of each number as it ranges up to the
 * `upper_bound` number, placing each prime number in a set, and non prime numbers
 * in a different set. This is because accessing a set element is faster than
 * re-calculating if a number is prime or not.
 *
 * param {u32} upper_bound The integer to act as an upper bound for the program to
 *     check up, and including, to.
 * returns An unsorted set of all the prime numbers that are less or equal to
 *     `upper_bound`.
 */
pub fn sieve(upper_bound: u32) -> HashSet<u32> {
    if upper_bound == 0 || upper_bound == 1 {
        return HashSet::new();
    } else if upper_bound == 2 {
        return HashSet::from([2]);
    }

    let mut primes: HashSet<u32> = HashSet::new();
    let mut non_primes: HashSet<u32> = HashSet::new();

    for i in 2..upper_bound + 1 {
        for j in 0..i {
            let current_num = i * j;
            if current_num > upper_bound || non_primes.contains(&current_num) {
                continue;
            }

            if is_prime(current_num) {
                primes.insert(current_num);
            } else {
                non_primes.insert(current_num);
            }
        }
    }

    return primes;
}
