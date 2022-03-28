/**
	Example code for implementing a basic prime number sieve (Sieve of Eratosthenes).

	The purpose of this program is to take a number, and find all the prime numbers that
	are less or equal to that number.

	input:
		- upper_bound: The integer to act as the upper bound for the program.

	returns:
		True if the number of prime numbers calculated is the same as the historical
		data, False otherwise.

	author: Marios Yiannakou
**/
class Sieve {
	/**
		Empty constructor
	**/
	public function new() {}

	/**
		Computes if the given number is a prime or not.

		input:
			- num: The number to check.

		returns:
			True if the number is prime, False otherwise.
	**/
	public function isPrime(num:Int):Bool {
		if (num < 2) {
			return false;
		}

		for (i in 2...num) {
			if (num % i == 0) {
				return false;
			}
		}

		return true;
	}

	/**
		Checks if the given element exists in the given array.

		input:
			- array: The array to be checked against.
			- element: The element to be checked.

		returns:
			True if the element exists in the array, false otherwise.
	**/
	public function contains(array:Array<Int>, element:Int):Bool {
		return array.indexOf(element) != -1;
	}

	/**
		Checks all integer numbers from 2 up to, and including, `upper_bound` and
		computes all the prime numbers, then returns them.

		This algorithm goes through the multiples of each number as it ranges up to the
		`upper_bound` number, placing each prime number in a set, and non prime numbers
		in a different set. This is because accessing a set element is faster than
		re-calculating if a number is prime or not.

		input:
			- upper_bound: The integer to act as an upper bound for the program to
							check up, and including, to.

		returns:
			An unsorted set of all the prime numbers that are less or equal to
			`upper_bound`.
	**/
	public function sieve(upper_bound:Int):Array<Int> {
		if (upper_bound == 0 || upper_bound == 1) {
			return [];
		}

		var primes:Array<Int> = new Array<Int>();
		var non_primes:Array<Int> = new Array<Int>();
		for (i in (2...(upper_bound + 1))) {
			for (j in 0...i) {
				var current_num:Int = i * j;
				if ((current_num > upper_bound) || contains(non_primes, current_num)) {
					continue;
				}

				if (isPrime(current_num)) {
					primes = primes.concat([current_num]);
				} else {
					non_primes = non_primes.concat([current_num]);
				}
			}
		}

		return primes;
	}
}
