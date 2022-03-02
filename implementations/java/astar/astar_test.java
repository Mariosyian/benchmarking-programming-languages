import org.junit.runner.JUnitCore;
import org.junit.runner.Result;
import org.junit.runner.notification.Failure;

import static org.junit.Assert.assertArrayEquals;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import java.util.Arrays;
import java.util.HashMap;

import org.junit.Before;
import org.junit.Test;

public class astar_test {

    private astar astar = null;

    @Before
    public void setUp() {
        this.astar = new astar();
    }

    @Test
    public void testAddEdgeSuccessfullyCreatesAndAddsAnEdgeToANodesNeihboursList() {
        Node node = new Node(1);
        Node neighbour = new Node(2);
        node.addEdge(1, neighbour);

        assertTrue(node.neighbours.size() == 1);
        assertTrue(node.neighbours.get(0).node.id == neighbour.id);
    }

    public static void main(String[] args) {
        Result result = JUnitCore.runClasses(astar_test.class);
        
        for (Failure failure : result.getFailures()) {
            System.out.println(failure.toString());
        }
        
        System.out.println(result.wasSuccessful());
    }
}
