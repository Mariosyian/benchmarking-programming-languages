// Example code for implementing the A-Star algorithm.
//
// The purpose of this program is to create a list of interconnected nodes (a graph),
// and then take a `start` and `target` node to calculate the shortest path between
// them.
//
// input:
// 	- start {Node} The node to start searching from.
//	- target {Node} The node to find a path towards from `start`.
// returns:
// 	- {Node} The target node if found, the `nil` value otherwise.
//
// author: Marios Yiannakou
//
package main

// import "fmt"

// Given a start and finish node, derives the shortest path (if any) between them.
//
// inputs:
// - start {Node} The node to start searching from.
// - target {Node} The node to find a path towards from `start`.
//
// returns:
// The target node if found, the `null` value otherwise.
func astar(start Node, target Node) *Node {
	finishedNodes := CreatePriorityQueue()
	visitedNodes := CreatePriorityQueue()

	start.costOfNode = start.distanceToStartNode + start.GetHeuristic()
	visitedNodes.Push(start)

	for visitedNodes.Len() > 0 {
		currentNode := visitedNodes.Pop().(Node)
		if currentNode.Equals(target) {
			return &currentNode
		}

		for _, edge := range currentNode.neighbours {
			neighbour := *(edge.target)
			totalWeight := currentNode.distanceToStartNode + edge.weight

			if !visitedNodes.Contains(neighbour) {
				neighbour.parent = &currentNode
				neighbour.distanceToStartNode = totalWeight
				neighbour.costOfNode = neighbour.distanceToStartNode + neighbour.GetHeuristic()
				visitedNodes.Push(neighbour)
			} else {
				if totalWeight < neighbour.distanceToStartNode {
					neighbour.parent = &currentNode
					neighbour.distanceToStartNode = totalWeight
					neighbour.costOfNode = neighbour.distanceToStartNode + neighbour.GetHeuristic()

					if finishedNodes.Contains(neighbour) {
						finishedNodes.Remove(&neighbour)
						visitedNodes.Push(neighbour)
					}
				}
			}
		}

		visitedNodes.Remove(&currentNode)
		finishedNodes.Push(currentNode)
	}

	return nil
}
