@isTest
public class RenewalCancellationTest {
    @isTest public static void TestMethod1()
    {
        test.startTest();
        RenewalCancellation cancel=new RenewalCancellation();
        cancel.SendNotificationtoADU();
        test.stopTest();
    }
    
}