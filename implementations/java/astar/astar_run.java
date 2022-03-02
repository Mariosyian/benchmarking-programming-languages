import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class astar_run {

    public static void main(String[] args) {
        astar astar = new astar();

        Node head = new Node(3);
        head.g = 0;

        Node n1 = new Node(2);
        Node n2 = new Node(2);
        Node n3 = new Node(2);

        head.addEdge(1, n1);
        head.addEdge(5, n2);
        head.addEdge(2, n3);
        n3.addEdge(1, n2);

        Node n4 = new Node(1);
        Node n5 = new Node(1);
        Node target = new Node(0);

        n1.addEdge(7, n4);
        n2.addEdge(4, n5);
        n3.addEdge(6, n4);

        n4.addEdge(3, target);
        n5.addEdge(1, n4);
        n5.addEdge(3, target);

        Node res = astar.run(head, target);
        printPath(res);
    }

    public static void printPath(Node target) {
        Node n = target;
    
        if (n == null) {
            return;
        }
    
        List<Integer> ids = new ArrayList<Integer>();
    
        while (n.parent != null) {
            ids.add(n.id);
            n = n.parent;
        }
        ids.add(n.id);
        Collections.reverse(ids);
    
        for (int id : ids) {
            System.out.print(id + " ");
        }
        System.out.println("");
    }    
}