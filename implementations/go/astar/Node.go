package main

import (
	"fmt"
	"math"
)

// Represents a standalone node of a graph.
//
// params:
//  - id {int} The unique identifier of the node.
//  - heuristic {int} The heuristic of the node.
type Node struct {
	id                  int
	index				int
	heuristic           int
	parent              *Node
	neighbours          []*Edge
	costOfNode          int
	distanceToStartNode int
}

func CreateNode(id int, heuristic int) *Node {
	node := new(Node)
	node.id = id
	node.index = 0
	node.heuristic = heuristic
	node.parent = nil
	node.neighbours = []*Edge{}
	node.costOfNode = math.MaxInt
	node.distanceToStartNode = math.MaxInt

	return node
}

func (node *Node) GetHeuristic() int {
	return node.heuristic
}

func (node *Node) AddEdge(target Node, weight int) {
	edge := new(Edge)
	edge.weight = weight
	edge.source = node
	edge.target = &target
	node.neighbours = append(node.neighbours, edge)
}

func (node *Node) Equals(n *Node) bool {
	return node.id == n.id
}

func (node Node) String() string {
	return fmt.Sprintf("%d (%d) costs %d and is %d units from the source", node.id, node.heuristic, node.costOfNode, node.distanceToStartNode)
}

func (node Node) PrintNeighbours() {
	fmt.Print("[")
	for _, edge := range node.neighbours {
		fmt.Print(edge.target.id, " ")
	}
	fmt.Println("]")
}
