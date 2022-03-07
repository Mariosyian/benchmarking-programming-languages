package main

import (
	"math"
)

// Represents a standalone node of a graph.
//
// params:
//  - id {int} The unique identifier of the node.
//  - heuristic {int} The heuristic of the node.
type Node struct {
	id                  int
	index               int
	heuristic           int
	parent              *Node
	neighbours          []*Edge
	costOfNode          int
	distanceToStartNode int
}

func NewNode(id int, index int, heuristic int) *Node {
	node := new(Node)
	node.id = id
	node.index = index
	node.heuristic = heuristic
	node.parent = nil
	// node.neighbours = []Edge{}
	node.costOfNode = math.MaxInt
	node.distanceToStartNode = math.MaxInt

	return node
}

func (node *Node) GetHeuristic() int {
	return node.heuristic
}

func (node *Node) AddEdge(n Node, weight int) {
	edge := new(Edge)
	edge.weight = weight
	edge.node = &n
	node.neighbours = append(node.neighbours, edge)
}

func (node *Node) Equals(n Node) bool {
	return node.id == n.id
}
