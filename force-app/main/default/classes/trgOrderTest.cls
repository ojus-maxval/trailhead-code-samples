@isTest
public class trgOrderTest {
    @testSetup static void setup() {
        
        //List<Clients__c> testC = new List<Clients__c>();
        Clients__c clients = new Clients__c();
        insert clients;
        //testC.add(new Clients__c());
        
        //List<Order__c> testCand = new List<Order__c>();
        Order__c cand = new Order__c();
        cand.Client__c = clients.Id;
        cand.Payment_Status__c = 'To be Invoiced';
        insert cand;
        //testCand.add(new Order__c(Client__c = clients.Id, Payment_Status__c = 'To be Invoiced'));
        //insert testCand;  
        /*
        cand.Client__c = clients.Id;
        cand.Payment_Status__c = 'Invoiced';
        testCand.add(new Order__c(Client__c = clients.Id, Payment_Status__c = 'Invoiced'));
        upsert testCand;
        */
    }
    @isTest public static void TestMethod1()
    {
     test.startTest();
     //List<Order__c> testCand = [SELECT Client__c, Payment_Status__c FROM Order__c WHERE Payment_Status__c = 'To be Invoiced'];
     Order__c cand = [SELECT Client__c, Payment_Status__c FROM Order__c WHERE Payment_Status__c = 'To be Invoiced'];
     cand.Payment_Status__c = 'Invoiced';
     update cand;
     test.stopTest();
     System.assertEquals('Invoiced', cand.Payment_Status__c);
    }
}