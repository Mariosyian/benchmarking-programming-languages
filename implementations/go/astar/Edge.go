package main

import "fmt"

// Represents the encapsulation of a `Node` with a weight, so it can be
// represented as a connected component with a heuristic in a graph.
//
// params:
//  - node {Node} The node this edge leads to.
//  - weight {int} The weight/cost to travel this edge.
type Edge struct {
	weight int
	source *Node
	target *Node
}

func CreateEdge(source Node, target Node, weight int) *Edge {
	edge := new(Edge)
	edge.source = &source
	edge.target = &target
	edge.weight = weight

	return edge
}

func (edge Edge) String() string {
	return fmt.Sprintf("%d->%d (%d)", edge.source.id, edge.target.id, edge.weight)
}
