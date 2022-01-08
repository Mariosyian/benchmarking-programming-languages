#include "sieve.h"

int main() {
    int upperBounds[5] = {1, 10, 100, 1000, 10000};
    int index = 0;
    for (index = 0; index < 5; index ++) {
        run(upperBounds[index]);
    }

    return 0;
}
