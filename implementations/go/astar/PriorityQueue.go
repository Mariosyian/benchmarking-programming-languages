package main

import (
	"container/heap"
	"fmt"
)

// A PriorityQueue implements heap.Interface and holds `Node`s.
type PriorityQueue []*QueueNode

func CreatePriorityQueue() *PriorityQueue {
	pq := new(PriorityQueue)
	heap.Init(pq)
	return pq
}

func (pq PriorityQueue) Len() int {
	return len(pq)
}

func (pq PriorityQueue) Less(node1 int, node2 int) bool {
	return pq[node1].node.costOfNode > pq[node2].node.costOfNode
}

func (pq PriorityQueue) Swap(node1 int, node2 int) {
	pq[node1], pq[node2] = pq[node2], pq[node1]
	pq[node1].index = node1
	pq[node2].index = node2
}

func (pq *PriorityQueue) Push(x interface{}) {
	node := x.(*Node)
	qNode := node.qNode
	qNode.index = len(*pq)
	*pq = append(*pq, qNode)
	heap.Fix(pq, qNode.index)
}

func (pq *PriorityQueue) Pop() interface{} {
	old := *pq
	node := old[len(old) - 1]
	pq.Remove(node)
	return *node
}

func (pq *PriorityQueue) Remove(qNode *QueueNode) {
	new := []*QueueNode{}
	for _, n := range *pq {
		if n.id != qNode.id {
			new = append(new, n)
		}
	}
	*pq = new
	heap.Fix(pq, qNode.index)
}

func (pq PriorityQueue) Contains(qNode QueueNode) bool {
	for _, n := range pq {
		if n.id == qNode.id {
			return true
		}
	}
	return false
}

func (pq PriorityQueue) PrintQueue() {
	fmt.Println("Number of elements in the queue:", len(pq))
	for _, node := range pq {
		fmt.Println("Node ID:{", node.node.id, "}, Index:{", node.index, "}")
		if node.node.parent != nil {
			fmt.Println("     Heuristic:{", node.node.heuristic, "}, ParentID:{", node.node.parent.id, "}")
		} else {
			fmt.Println("     Heuristic:{", node.node.heuristic, "}, ParentID:{N/A}")
		}
		fmt.Println("     DistToSrc:{", node.node.distanceToStartNode, "}, Cost:{", node.node.costOfNode, "}")
	}
	fmt.Println("-------------------------------------------------")
}
