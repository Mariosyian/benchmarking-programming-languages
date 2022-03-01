import org.junit.runner.JUnitCore;
import org.junit.runner.Result;
import org.junit.runner.notification.Failure;

import static org.junit.Assert.assertArrayEquals;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import java.util.Arrays;
import java.util.HashMap;

import org.junit.Before;
import org.junit.Test;

public class sieve_test {

   private sieve sieve = null;

   @Before
   public void setUp() {
      this.sieve = new sieve();
   }

   @Test
   public void testIsPrimeReturnsTrueForPrimeNumbers() {
      // First 50 known prime numbers
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
         assertTrue(this.sieve.isPrime(prime));
      }
   }
   
   @Test
   public void testIsPrimeReturnsFalseForNonPrimeNumbers() {
      // Non-prime numbers from 0 to 50
      int[] non_primes =  {
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
         assertFalse(this.sieve.isPrime(non_prime));
      }
   }
   
   @Test
   public void testSieveReturnsTheCorrectNumberOfPrimeNumbersGivenN() {
      // Known number of prime numbers given the dictionary key as an upper bound.
      // limits = { 1: 0, 10 : 4, 100 : 25, 1000 : 168, 10000 : 1229, 100000 : 9592, 1000000 : 78498, 10000000 : 664579, 100000000 : 5761455 }
      HashMap<Integer, Integer> limits = new HashMap<Integer, Integer>();
      limits.put(0, 0);
      limits.put(1, 0);
      limits.put(2, 1);
      limits.put(10, 4);
      limits.put(100, 25);
      limits.put(1000, 168);
      limits.put(10000, 1229);
      for (int key : limits.keySet()) {
         assertEquals(this.sieve.run(key).size(), (int) limits.get(key));
      }
   }
   
   @Test
   public void testSieveReturnsTheCorrectListOfPrimeNumbersGivenN() {
      // Known list of prime numbers given the dictionary key as an upper bound.
      HashMap<Integer, int[]> limits = new HashMap<Integer, int[]>();
      limits.put(0, new int[]{});
      limits.put(1, new int[]{});
      limits.put(2, new int[]{2});
      limits.put(10, new int[]{2, 3, 5, 7});
      limits.put(100, new int[]{2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97});
      for (int key : limits.keySet()) {
         int[] results = this.sieve.run(key).stream().mapToInt(Number::intValue).toArray();
         Arrays.sort(results);
         assertArrayEquals(results, limits.get(key));
      }
   }

   public static void main(String[] args) {
      Result result = JUnitCore.runClasses(sieve_test.class);
		
      for (Failure failure : result.getFailures()) {
         System.out.println(failure.toString());
      }
		
      System.out.println(result.wasSuccessful());
   }
}


