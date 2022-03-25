@isTest
public class trgOrderTest {
    @testSetup static void setup() {
        
        Clients__c clients = new Clients__c();
        insert clients;
        
        Invoice_Type_Configuration__c invoice =new Invoice_Type_Configuration__c();
        invoice.Client__c = clients.Id;
        invoice.Contact_Persons__c = 'ojus.gupta@maxval.com';
        Insert invoice;
        
        Group__c grp = new Group__c();
        grp.Name = 'Group1';
        insert grp;
        
        Order__c cand = new Order__c();
        cand.Client__c = clients.Id;
        cand.Is_Sent_Invoice__c = true;
        cand.Payment_Status__c = 'Invoiced';
        cand.Renewal_Team__c = null;
        insert cand;        
         System.debug('cand1: '+ cand);
        
        Order__c ord1 = new Order__c();
        ord1.Client__c = clients.Id;
        ord1.Is_Sent_Invoice__c = false;
        ord1.Payment_Status__c = 'To be Invoiced';
        ord1.Renewal_Team__c = null;
        insert ord1;  
        
        Order_Item__c orditem = new Order_Item__c();
        orditem.Order__c = cand.Id;
        orditem.Cancellation_Approval__c = 'Requested';
        insert orditem;
        
    }
    @isTest public static void TestMethod1()
    {
     test.startTest();
     Group__c grp = [SELECT Name FROM Group__c WHERE Name = 'Group1'];
     //List<Order__c> testCand = [SELECT Client__c, Payment_Status__c FROM Order__c WHERE Payment_Status__c = 'To be Invoiced'];
     Order__c cand = [SELECT Client__c, Payment_Status__c, Renewal_Team__c FROM Order__c WHERE Payment_Status__c = 'Invoiced'];
     cand.Payment_Status__c = 'To be Invoiced';
     cand.Renewal_Team__c = grp.Id;
     update cand;
        
        System.debug('cand2: '+ cand);
     test.stopTest();
     System.assertEquals('To be Invoiced', cand.Payment_Status__c);
     System.assertEquals(grp.Id, cand.Renewal_Team__c);
    }
    
    @isTest public static void TestMethod2()
    {
     test.startTest();
     //List<Order__c> testCand = [SELECT Client__c, Payment_Status__c FROM Order__c WHERE Payment_Status__c = 'To be Invoiced'];
     Order__c ord1 = [SELECT Client__c, Payment_Status__c FROM Order__c WHERE Payment_Status__c = 'To be Invoiced'];
     ord1.Payment_Status__c = 'Invoiced';
     ord1.Is_Sent_Invoice__c = true;
     update ord1;
        
     Order_Item__c orditem = [SELECT Cancellation_Approval__c FROM Order_Item__c WHERE Cancellation_Approval__c = 'Requested'];
     orditem.Cancellation_Approval__c = 'Approved';
     update orditem;
       
     test.stopTest();
     System.assertEquals('Invoiced', ord1.Payment_Status__c);
     System.assertEquals(true, ord1.Is_Sent_Invoice__c);
    }
}