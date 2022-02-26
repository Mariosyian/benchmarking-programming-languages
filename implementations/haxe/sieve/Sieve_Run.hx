class Sieve_Run {
	public static function main() {
		var known:Map<Int, Int> = [1 => 0, 10 => 4, 100 => 25, 1000 => 168, 10000 => 1229,];

		var sieve:Sieve = new Sieve();
		for (k => _ in known) {
			sieve.sieve(k);
		}
	}
}
