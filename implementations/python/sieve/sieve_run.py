from sieve import sieve

known = {
    1: 0,
    10: 4,
    100: 25,
    1000: 168,
    10000: 1229,
}


def run():
    for n in known.keys():
        sieve(n)


run()
