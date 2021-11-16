import java.util.HashSet;

public class sieve {

    /**
     * Checks all integer numbers from 2 up to, and including, `upperBound` and computes
     *  all the prime numbers, then returns them.
     *
     *  This algorithm goes through the multiples of each number as it ranges up to the
     *  `upperBound` number, placing each prime number in a set, and non prime numbers
     *  in a different set. This is because accessing a set element is faster than
     *  re-calculating if a number is prime or not.
     *
     *  param int {upperBound} The integer to act as an upper bound for the program to
     *      check up, and including, to.
     *  returns An unsorted set of all the prime numbers that are less or equal to
     *      `upperBound`.
     */
    public HashSet<Integer> run(int upperBound) {
        if (upperBound == 0 || upperBound == 1) {
            return new HashSet<Integer>();
        } else if (upperBound == 2) {
            HashSet<Integer> result = new HashSet<Integer>();
            result.add(2);
            return result;
        }

        HashSet<Integer> primes = new HashSet<Integer>();
        HashSet<Integer> nonPrimes = new HashSet<Integer>();
        for (int i = 2; i <= upperBound; i ++) {
            for (int j = 1; j <= i; j ++) {
                int currentNumber = i * j;
                if ((currentNumber > upperBound) || (nonPrimes.contains(currentNumber))) {
                    continue;
                }

                if (isPrime(currentNumber)) {
                    primes.add(currentNumber);
                } else {
                    nonPrimes.add(currentNumber);
                }
            }
        }
        return primes;
    }

    /**
     * Computes if the given number is a prime or not.
     *
     * param int {num} The number to check.
     * returns `true` if the number is prime, `false` otherwise.
     */
    public boolean isPrime(int num) {
        if (num < 2) {
            return false;
        }
        for (int i = 2; i < num; i ++) {
            if (num % i == 0) {
                return false;
            }
        }
        return true;
    }
}
