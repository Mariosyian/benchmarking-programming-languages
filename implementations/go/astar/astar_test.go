package main

import "testing"

func TestIsPrimeReturnsTrueForPrimeNumbers(t *testing.T) {
	// First 50 known prime numbers
	primes := [50]int{
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
	}
	for _, prime := range primes {
		if !isPrime(prime) {
			t.Errorf("Error: Expected %d to be prime.", prime)
		}
	}
}

func TestIsPrimeReturnsFalseForNonPrimeNumbers(t *testing.T) {
	// Non-prime numbers from 0 to 50
	non_primes := [35]int{
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
	}
	for _, non_prime := range non_primes {
		if isPrime(non_prime) {
			t.Errorf("Error: Expected %d to be non prime.", non_prime)
		}
	}
}

func TestSieveReturnsTheCorrectNumberOfPrimeNumbersGivenN(t *testing.T) {
	// Known number of prime numbers given the dictionary key as an upper bound.
	// limits = { 1: 0, 10 : 4, 100 : 25, 1000 : 168, 10000 : 1229, 100000 : 9592, 1000000 : 78498, 10000000 : 664579, 100000000 : 5761455 }
	limits := map[int]int{0: 0, 1: 0, 2: 1, 10: 4, 100: 25, 1000: 168, 10000: 1229}
	for limit := range limits {
		var result int = len(sieve(limit))
		if result != limits[limit] {
			t.Errorf("Error: Expected the list of primes for %d to be %d but was %d.", limit, result, limits[limit])
		}
	}
}

func TestSieveReturnsTheCorrectListOfPrimeNumbersGivenN(t *testing.T) {
	// Known list of prime numbers given the dictionary key as an upper bound.
	var limits = map[int][]int{
		0:  {},
		1:  {},
		2:  {2},
		10: {2, 3, 5, 7},
		100: {
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
		},
	}
	for limit := range limits {
		var result []int = sieve(limit)
		for index, element := range result {
			if element != limits[limit][index] {
				t.Errorf("Error: Expected key %d to return %v but got %v.", element, limits[limit], result)
			}
		}
	}
}

func TestElementExistsReturnsTrueForExistingElements(t *testing.T) {
	elements := []int{1, 2, 3, 4, 5}
	for _, element := range elements {
		if !elementExists(element, elements) {
			t.Errorf("Error: Expected %d to exist in %v.", element, elements)
		}
	}
}

func TestElementExistsReturnsFalseForNonExistingElements(t *testing.T) {
	elements := []int{1, 2, 3, 4, 5}
	nonExistingElements := [5]int{6, 7, 8, 9, 10}
	for _, element := range nonExistingElements {
		if elementExists(element, elements) {
			t.Errorf("Error: Expected %d to not exist in %v.", element, nonExistingElements)
		}
	}
}

func TestSieveRunMain(t *testing.T) {
	// Simply run this class for coverage
	// TODO: Learn how to exclude from coverage
	main()
}
