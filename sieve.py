MAX = 723
primes = set()
non_primes = set()
def is_prime(num):
    if num < 2:
        return False
    for i in range(2, num):
        if num % i == 0:
            return False
    
    return True

for i in range(2, MAX + 1):
    for j in range(i):
        current_num = i * j
        if current_num > MAX:
            continue
        if not is_prime(current_num):
            non_primes.add(current_num)
        else:
            primes.add(current_num)
