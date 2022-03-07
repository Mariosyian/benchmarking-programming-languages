package main

// A PriorityQueue implements heap.Interface and holds `Node`s.
type PriorityQueue []*Node

func NewPriorityQueue() *PriorityQueue {
	return new(PriorityQueue)
}

func (pq PriorityQueue) Len() int {
	return len(pq)
}

func (pq PriorityQueue) Less(node1 int, node2 int) bool {
	return pq[node1].costOfNode < pq[node2].costOfNode
}

func (pq PriorityQueue) Swap(node1 int, node2 int) {
	pq[node1], pq[node2] = pq[node2], pq[node1]
	pq[node1].index = node2
	pq[node2].index = node1
}

func (pq *PriorityQueue) Push(x interface{}) {
	node := x.(*Node)
	n := len(*pq)
	if n == 0 {
		node.index = n
	} else {
		node.index = -1
	}
	*pq = append(*pq, node)
}

func (pq *PriorityQueue) Pop() interface{} {
	old := *pq
	n := len(old)
	node := old[n-1]
	old[n-1] = nil // avoid memory leak
	// node.index = -1
	*pq = old[0 : n-1]
	return *node
}

// func (pq PriorityQueue) Remove(node Node) {
// 	pq[node.index] = nil
// }

func (pq PriorityQueue) Contains(node Node) bool {
	for _, n := range pq {
		if n.id == node.id {
			return true
		}
	}
	return false
}
