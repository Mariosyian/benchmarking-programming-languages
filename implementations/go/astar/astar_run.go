package main

import "fmt"

func main() {
	start := CreateQueueNode(0, 3)
	start.node.distanceToStartNode = 0

	n1 := CreateQueueNode(1, 2)
	n2 := CreateQueueNode(2, 6)
	n3 := CreateQueueNode(3, 2)
	n4 := CreateQueueNode(4, 5)
	n5 := CreateQueueNode(5, 7)
	n6 := CreateQueueNode(6, 1)
	n7 := CreateQueueNode(7, 3)
	n8 := CreateQueueNode(8, 9)
	n9 := CreateQueueNode(9, 8)
	target := CreateQueueNode(10, 0)

	start.node.AddEdge(*n1.node, 2)
	start.node.AddEdge(*n2.node, 5)
	start.node.AddEdge(*n4.node, 3)
	n1.node.AddEdge(*n2.node, 1)
	n1.node.AddEdge(*n4.node, 1)
	n2.node.AddEdge(*n3.node, 2)
	n2.node.AddEdge(*n4.node, 7)
	n2.node.AddEdge(*n5.node, 4)
	n3.node.AddEdge(*n2.node, 2)
	n3.node.AddEdge(*n5.node, 5)
	n3.node.AddEdge(*n6.node, 8)
	n3.node.AddEdge(*n8.node, 4)
	n4.node.AddEdge(*start.node, 2)
	n4.node.AddEdge(*n1.node, 1)
	n4.node.AddEdge(*n3.node, 6)
	n4.node.AddEdge(*n5.node, 1)
	n5.node.AddEdge(*n7.node, 5)
	n6.node.AddEdge(*n8.node, 2)
	n6.node.AddEdge(*n9.node, 3)
	n7.node.AddEdge(*n3.node, 1)
	n7.node.AddEdge(*target.node, 3)
	n8.node.AddEdge(*n7.node, 3)
	n8.node.AddEdge(*n9.node, 2)
	n8.node.AddEdge(*target.node, 1)
	n9.node.AddEdge(*n7.node, 1)
	n9.node.AddEdge(*target.node, 5)

	result := astar(*start.node, *target.node)
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
