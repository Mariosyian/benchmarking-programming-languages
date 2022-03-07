package main

// Represents the encapsulation of a `Node` with a weight, so it can be
// represented as a connected component with a heuristic in a graph.
//
// params:
//  - node {Node} The node this edge leads to.
//  - weight {int} The weight/cost to travel this edge.
type Edge struct {
	weight int
	node   *Node
}

func CreateEdge(node Node, weight int) *Edge {
	edge := new(Edge)
	edge.node = &node
	edge.weight = weight

	return edge
}
