import java.util.HashMap;

public class sieve_run {

    private static HashMap<Integer, Integer> known = new HashMap<Integer, Integer>();

    public static void main(String[] args) {
        known.put(1, 0);
        known.put(10, 4);
        known.put(100, 25);
        known.put(1000, 168);
        known.put(10000, 1229);

        sieve sieve = new sieve();
        for (int n : known.keySet()) {
            sieve.run(n);
        }
    }
}
