import utest.Assert;
import utest.Runner;
import utest.ui.Report;

class Sieve_Test {
	public static function main() {
		var runner = new Runner();

		runner.addCase(new TestCase());

		Report.create(runner);
		runner.run();
	}
}

class TestCase extends utest.Test {
	var sieve:Sieve = new Sieve();

	public function testIsPrimeReturnsTrueForPrimeNumbers() {
		// First 50 known prime numbers
		var primes:Array<Int> = [
			2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127, 131, 137, 139, 149,
			151, 157, 163, 167, 173, 179, 181, 191, 193, 197, 199, 211, 223, 227, 229,
		];
		for (prime in primes) {
			Assert.isTrue(sieve.isPrime(prime));
		}
	}

	public function testIsPrimeReturnsFalseForNonPrimeNumbers() {
		// Non-prime numbers from 0 to 50
		var nonPrimes:Array<Int> = [
			0, 1, 4, 6, 8, 10, 12, 14, 15, 16, 18, 20, 21, 22, 24, 25, 26, 27, 28, 30, 32, 33, 34, 35, 36, 38, 39, 40, 42, 44, 45, 46, 48, 49, 50,
		];
		for (nonPrime in nonPrimes) {
			Assert.isFalse(sieve.isPrime(nonPrime));
		}
	}

	public function testSieveReturnsTheCorrectNumberOfPrimeNumbersGivenN() {
		// Known number of prime numbers given the dictionary key as an upper bound.
		var limits:Map<Int, Int> = [1 => 0, 10 => 4, 100 => 25, 1000 => 168, 10000 => 1229];
		for (N => value in limits) {
			Assert.equals(sieve.sieve(N).length, value);
		}
	}

	public function testSieveReturnsTheCorrectListOfPrimeNumbersGivenN() {
		// Known list of prime numbers given the dictionary key as an upper bound.
		var limits:Map<Int, Array<Int>> = [
			1 => [],
			10 => [2, 3, 5, 7],
			100 => [
				2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97,
			],
		];
		for (N => elements in limits) {
			var results:Array<Int> = sieve.sieve(N);
			Assert.equals(results.length, elements.length);
			// As suggested by https://haxe.org/manual/std-unit-testing.html#comparing-complex-objects
			Assert.equals(Std.string(results), Std.string(elements));
		}
	}

	public function testContainsCorrectlyIdentifiesElementThatExistsInTheArray() {
		// Known list of prime numbers given the dictionary key as an upper bound.
		var array:Array<Int> = [1, 2, 3, 4, 5];
		for (element in array) {
			Assert.isTrue(sieve.contains(array, element));
		}
	}

	public function testContainsCorrectlyIdentifiesElementThatDoesntExistInTheArray() {
		// Known list of prime numbers given the dictionary key as an upper bound.
		var array:Array<Int> = [1, 2, 3, 4, 5];
		for (element in [6, 7, 8, 9, 10]) {
			Assert.isFalse(sieve.contains(array, element));
		}
	}
}
