package main

type QueueNode struct {
	id	  int
	index int
	node  *Node
}

func CreateQueueNode(id int, heuristic int) *QueueNode {
	qNode := new(QueueNode)
	qNode.id = id
	qNode.index = 0
	qNode.node = CreateNode(id, heuristic, qNode)

	return qNode
}
