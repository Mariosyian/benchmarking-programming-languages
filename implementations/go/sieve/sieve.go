// Example code for implementing a basic prime number sieve (Sieve of Eratosthenes).
//
// The purpose of this program is to take a number, and find all the prime numbers that
// are less or equal to that number.
//
// input:
// 	- upperBound {int} - The integer to act as the upper bound for the program.
// returns:
// 	- {bool} True if the number of prime numbers calculated is the same as the
//		historical data, False otherwise.
//
// author: Marios Yiannakou
//
package main

// Evaluates if the given number is a prime number.
//
// param number {int} - The integer to evaluate.
//
// returns {bool} True if the number is a prime, false otherwise.
func isPrime(number int) bool {
	if number < 2 {
		return false
	}

	for i := 2; i < number; i++ {
		if number%i == 0 {
			return false
		}
	}

	return true
}

// Evaluates if the given number exists in the given array.
//
// param element {int} - The element to check.
// param array {[]int} - The array of integers to check against.
//
// returns {bool} True if the number exists in the array, false otherwise.
func elementExists(element int, array []int) bool {
	for _, el := range array {
		if element == el {
			return true
		}
	}

	return false
}

// Checks all integer numbers from 2 up to, and including, `upperBound` and computes
// all the prime numbers, then returns them.
//
// This algorithm goes through the multiples of each number as it ranges up to the
// `upperBound` number, placing each prime number in a set, and non prime numbers
// in a different set. This is because accessing a set element is faster than
// re-calculating if a number is prime or not.
//
// param upperBound {int} - The integer to act as an upper bound for the program to
//     check up, and including, to.
//
// returns {[]int} An unsorted array of all the prime numbers that are less or equal to
//     `upperBound`.
func sieve(upperBound int) []int {
	// As of today 28/12/2021 Go does not natively support sets
	var primes []int
	var nonPrimes []int
	for i := 2; i <= upperBound; i++ {
		for j := 0; j < i; j++ {
			currentNumber := i * j
			if currentNumber > upperBound || elementExists(currentNumber, primes) {
				continue
			}

			if isPrime(currentNumber) {
				primes = append(primes, currentNumber)
			} else {
				nonPrimes = append(nonPrimes, currentNumber)
			}
		}
	}

	return primes
}
