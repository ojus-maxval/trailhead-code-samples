@isTest
public class scheduledbatchRequestingToPayPTOTest {
	static testMethod void testMethod1() 
    {
        Test.startTest();
        scheduledbatchRequestingToPayPTO sbrtppt = new scheduledbatchRequestingToPayPTO();
        Clients__c  Cl =new Clients__c ();
        Cl.Client_Name__c = 'Test Status';
        Cl.Contact_Email_Id__c ='juveria.b@maxval.com';
        Insert Cl;
        String sch = '0 0 23 * * ?';
        system.schedule('Test', sch , sbrtppt );
        
        Test.stopTest();
    }
}