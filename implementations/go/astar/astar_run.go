package main

import "fmt"

func main() {
	start := NewNode(0, 0, 3)
	start.distanceToStartNode = 0

	n1 := NewNode(1, 1, 2)
	n2 := NewNode(2, 2, 6)
	n3 := NewNode(3, 3, 2)
	n4 := NewNode(4, 4, 5)
	n5 := NewNode(5, 5, 7)
	n6 := NewNode(6, 6, 1)
	n7 := NewNode(7, 7, 3)
	n8 := NewNode(8, 8, 9)
	n9 := NewNode(9, 9, 8)
	target := NewNode(10, 10, 0)

	start.AddEdge(*n1, 1)
	start.AddEdge(*n2, 5)
	start.AddEdge(*n4, 3)
	n1.AddEdge(*n2, 1)
	n1.AddEdge(*n4, 1)
	n2.AddEdge(*n3, 2)
	n2.AddEdge(*n4, 7)
	n2.AddEdge(*n5, 4)
	n3.AddEdge(*n2, 2)
	n3.AddEdge(*n5, 5)
	n3.AddEdge(*n6, 8)
	n3.AddEdge(*n8, 4)
	n4.AddEdge(*start, 2)
	n4.AddEdge(*n1, 1)
	n4.AddEdge(*n3, 6)
	n4.AddEdge(*n5, 1)
	n5.AddEdge(*n7, 5)
	n6.AddEdge(*n8, 2)
	n6.AddEdge(*n9, 3)
	n7.AddEdge(*n3, 1)
	n7.AddEdge(*target, 3)
	n8.AddEdge(*n7, 3)
	n8.AddEdge(*n9, 2)
	n8.AddEdge(*target, 1)
	n9.AddEdge(*n7, 1)
	n9.AddEdge(*target, 5)

	result := astar(*start, *target)
	if result == nil {
		fmt.Println("No route was found")
		return
	}
	printPath(*result)
}

func printPath(target Node) {
	ids := []int{}

	for target.parent != nil {
		ids = append(ids, target.id)
		target = *target.parent
	}
	ids = append(ids, target.id)
	// Collections.reverse(ids)

	for _, id := range ids {
		fmt.Print(id, " ")
	}
	fmt.Println("")
}
