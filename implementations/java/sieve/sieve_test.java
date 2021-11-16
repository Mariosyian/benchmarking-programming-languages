import org.junit.runner.JUnitCore;
import org.junit.runner.Result;
import org.junit.runner.notification.Failure;


public class sieve_test {
   public static void main(String[] args) {
      Result results = JUnitCore.runClasses(Tests.class);
      if (results.wasSuccessful()) {
         System.exit(0);
      }
      for (Failure failure : results.getFailures()) {
         System.out.println(failure.toString());
      }
      System.exit(1);
   }
}
