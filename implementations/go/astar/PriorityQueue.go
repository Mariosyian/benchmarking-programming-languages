package main

import (
	"container/heap"
	"fmt"
)

// A PriorityQueue implements heap.Interface and holds `Node`s.
type PriorityQueue []*Node

func CreatePriorityQueue() *PriorityQueue {
	pq := new(PriorityQueue)
	heap.Init(pq)
	return pq
}

func (pq PriorityQueue) Len() int {
	return len(pq)
}

func (pq PriorityQueue) Less(node1 int, node2 int) bool {
	return pq[node1].costOfNode > pq[node2].costOfNode
}

func (pq PriorityQueue) Swap(node1 int, node2 int) {
	pq[node1], pq[node2] = pq[node2], pq[node1]
	pq[node1].index = node1
	pq[node2].index = node2
}

func (pq *PriorityQueue) Push(x interface{}) {
	node := x.(Node)
	node.index = len(*pq)
	*pq = append(*pq, &node)
	heap.Fix(pq, node.index)
	fmt.Println(node)
}

func (pq *PriorityQueue) Pop() interface{} {
	old := *pq
	node := old[len(old) - 1]
	pq.Remove(node)	// Calls heap.Fix
	return *node
}

func (pq *PriorityQueue) Remove(node *Node) {
	new := []*Node{}
	for _, n := range *pq {
		if n.id != node.id {
			new = append(new, n)
		}
	}
	*pq = new
	// If the node removed is the last one, then an index
	// out of bounds error is thrown
	if node.index < len(*pq) - 1 {
		heap.Fix(pq, node.index)
	}
}

func (pq PriorityQueue) Contains(node Node) bool {
	for _, n := range pq {
		if n.id == node.id {
			return true
		}
	}
	return false
}

func (pq PriorityQueue) PrintQueue() {
	fmt.Println("Number of elements in the queue:", len(pq))
	for _, node := range pq {
		fmt.Println("Node ID:{", node.id, "}, Index:{", node.index, "}")
		if node.parent != nil {
			fmt.Println("     Heuristic:{", node.heuristic, "}, ParentID:{", node.parent.id, "}")
		} else {
			fmt.Println("     Heuristic:{", node.heuristic, "}, ParentID:{N/A}")
		}
		fmt.Println("     DistToSrc:{", node.distanceToStartNode, "}, Cost:{", node.costOfNode, "}")
	}
	fmt.Println("-------------------------------------------------")
}

func (pq PriorityQueue) PrintNodes() {
	fmt.Print("[")
	for _, node := range pq {
		fmt.Print(node.id, " ")
	}
	fmt.Println("]")
}
