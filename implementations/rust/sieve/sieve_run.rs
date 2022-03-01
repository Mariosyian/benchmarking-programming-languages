mod sieve;

fn main() {
    let known = [1, 10, 100, 1000, 10000];

    for value in known {
        sieve::sieve(value);
    }
}
