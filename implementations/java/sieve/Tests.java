import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;

import org.junit.Before;
import org.junit.Test;

import static org.junit.Assert.assertArrayEquals;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

public class Tests {
    private sieve s = null;

    @Before
    public void init() {
        s = new sieve();
    }

    @Test
    public void testIsPrimeReturnsTrueForPrimeNumbers() {
        int[] primes = {
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
        for (int prime : primes) {
            assertTrue(s.isPrime(prime));
        }
    }

    @Test
    public void testIsPrimeReturnsFalseForNonPrimeNumbers() {
        int[] non_primes = {
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
        for (int non_prime : non_primes) {
            assertFalse(s.isPrime(non_prime));
        }
    }

    @Test
    public void testSieveReturnsTheCorrectNumberOfPrimeNumbersGivenN() {
        HashMap<Integer, Integer> limits = new HashMap<Integer, Integer>();
        limits.put(1, 0);
        limits.put(10, 4);
        limits.put(100, 25);
        limits.put(1000, 168);
        limits.put(10000, 1229);

        for (int limit : limits.keySet()) {
            assertEquals((int) s.run(limit).size(), (int) limits.get(limit));
        }
    }

    @Test
    public void testSieveReturnsTheCorrectListOfPrimeNumbersGivenN() {
        HashMap<Integer, int[]> limits = new HashMap<Integer, int[]>();
        limits.put(1, new int[]{});
        limits.put(10, new int[]{2, 3, 5, 7});
        limits.put(100, new int[]{2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97});

        for (int limit : limits.keySet()) {
            int[] expected = limits.get(limit);
            int[] actual = s.run(limit).stream().mapToInt(x -> x).toArray();
            Arrays.sort(actual);
            assertArrayEquals(expected, actual);
        }
    }
}
