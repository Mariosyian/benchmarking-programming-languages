"""
Example code for implementing a basic prime number sieve (Sieve of Eratosthenes).

The purpose of this program is to take a number, and find all the prime numbers that
are less or equal to that number.

input:
    - upper_bound: The integer to act as the upper bound for the program.
returns:
    - True if the number of prime numbers calculated is the same as the historical
        data, False otherwise.

author: Marios Yiannakou
"""


def is_prime(num):
    """
    Computes if the given number is a prime or not.

    :param num: The number to check.
    :returns: True if the number is prime, False otherwise.
    """
    if num < 2:
        return False
    for i in range(2, num):
        if num % i == 0:
            return False

    return True


def sieve(upper_bound):
    """
    Checks all integer numbers from 2 up to, and including, `upper_bound` and computes
    all the prime numbers, then returns them.

    This algorithm goes through the multiples of each number as it ranges up to the
    `upper_bound` number, placing each prime number in a set, and non prime numbers
    in a different set. This is because accessing a set element is faster than
    re-calculating if a number is prime or not.

    :param upper_bound: The integer to act as an upper bound for the program to
        check up, and including, to.
    :returns: An unsorted set of all the prime numbers that are less or equal to
        `upper_bound`.
    """
    if upper_bound == 0 or upper_bound == 1:
        return []
    elif upper_bound == 2:
        return [2]

    primes = set()
    non_primes = set()
    for i in range(2, upper_bound + 1):
        for j in range(i):
            current_num = i * j
            if (current_num > upper_bound) or (current_num in non_primes):
                continue

            if is_prime(current_num):
                primes.add(current_num)
            else:
                non_primes.add(current_num)

    return primes
