import org.junit.runner.JUnitCore;
import org.junit.runner.Result;
import org.junit.runner.notification.Failure;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import java.io.ByteArrayOutputStream;
import java.io.PrintStream;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class astar_test {

    private astar astar = null;

    // Capture stdout: https://stackoverflow.com/questions/1119385/junit-test-for-system-out-println
    private final ByteArrayOutputStream outContent = new ByteArrayOutputStream();
    private final PrintStream originalOut = System.out;

    @Before
    public void setUpStreams() {
        System.setOut(new PrintStream(outContent));
    }

    @After
    public void restoreStreams() {
        System.setOut(originalOut);
    }

    @Before
    public void setUp() {
        this.astar = new astar();
    }

    @Test
    public void testAddEdgeSuccessfullyCreatesAndAddsAnEdgeToANodesNeihboursList() {
        Node node = new Node(1);
        Node neighbour = new Node(2);
        node.addEdge(neighbour, 1);

        assertTrue(node.neighbours.size() == 1);
        assertTrue(node.neighbours.get(0).node.id == neighbour.id);
    }

    @Test
    public void testAstarReturnsTheCorrectPath() {
        Node source = new Node(1);
        Node node = new Node(2);
        Node target = new Node(0);

        source.addEdge(node, 1);
        node.addEdge(target, 1);

        this.astar.run(source, target);
        assertEquals(target.parent.id, node.id);
        assertEquals(node.parent.id, source.id);
    }

    @Test
    public void testPrintPathPrintsTheCorrectPathGivenATargetNode() {
        Node source = new Node(1);
        Node node = new Node(2);
        Node target = new Node(0);

        source.addEdge(node, 1);
        node.addEdge(target, 1);

        this.astar.run(source, target);
        astar_run.printPath(target);
        assertEquals(String.format("%d %d %d", source.id, node.id, target.id), outContent.toString().strip());
    }

    @Test
    public void testGetHeuristicReturnsTheNodesHeuristic() {
        double heuristic = 0;
        Node node = new Node(heuristic);

        assertTrue(node.getHeuristic() == heuristic);
    }

    @Test
    public void testEqualsCorrectlyComparesTwoNodes() {
        Node node = new Node(0);
        Node node2 = new Node(0);

        assertTrue(node.equals(node));
        assertFalse(node.equals(node2));
    }

    @Test
    public void testCompareToCorrectlyComparesTwoNodes() {
        Node node = new Node(0);
        node.costOfNode = 0;
        Node node2 = new Node(1);
        node.costOfNode = 1;

        assertTrue(node.compareTo(node) == 0);
        assertTrue(node.compareTo(node2) < 0);
        assertTrue(node2.compareTo(node) > 0);
    }

    public static void main(String[] args) {
        Result result = JUnitCore.runClasses(astar_test.class);
        
        for (Failure failure : result.getFailures()) {
            System.out.println(failure.toString());
        }
        
        System.out.println(result.wasSuccessful());
    }
}
