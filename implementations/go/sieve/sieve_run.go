package main

var known = map[int]int{
	1:     0,
	10:    4,
	100:   25,
	1000:  168,
	10000: 1229,
}

func main() {
	for key := range known {
		sieve(key)
	}
}
