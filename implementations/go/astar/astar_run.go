package main

import "fmt"

func main() {
	start := CreateNode(0, 3)
	start.distanceToStartNode = 0

	n1 := CreateNode(1, 2)
	n2 := CreateNode(2, 6)
	n3 := CreateNode(3, 2)
	n4 := CreateNode(4, 5)
	n5 := CreateNode(5, 7)
	n6 := CreateNode(6, 1)
	n7 := CreateNode(7, 3)
	n8 := CreateNode(8, 9)
	n9 := CreateNode(9, 8)
	target := CreateNode(10, 0)

	start.AddEdge(*n1, 2)
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

	fmt.Println(target)
	for target.parent != nil {
		fmt.Println("Parent of ", target.id, " is ", target.parent.id)
		ids = append(ids, target.id)
		target = *target.parent
	}
	ids = append(ids, target.id)

	for _, id := range ids {
		fmt.Print(id, " ")
	}
	fmt.Println("")
}
