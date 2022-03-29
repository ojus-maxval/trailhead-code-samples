@isTest
public class ScheduleBatchValidateWithPTOTest {
	static testMethod void testMethod1() 
    {
        Test.startTest();
        ScheduleBatchValidateWithPTO sbrtppt = new ScheduleBatchValidateWithPTO();
        String sch = '0 0 23 * * ?';
        system.schedule('Test', sch , sbrtppt );
        Test.stopTest();
    }
}