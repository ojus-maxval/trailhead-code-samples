@isTest
public class GenerateCreditMemoBatchTest {
 static testMethod void testMethod1() 
    {
        API_Auth_Detail__c API =new API_Auth_Detail__c();
        API.Type_Of_Credential__c ='QB Credential';
        Insert API;
        
    	API_Credentials__c ObjAPI1 = new API_Credentials__c();
        ObjAPI1.Password__c ='Test@1234';
        ObjAPI1.Username__c ='MaxvalAPI';
        ObjAPI1.Name = 'Renewal CreditMemo Create';
        ObjAPI1.URL__c ='https://api-qa.maxval.com/v1/renewal/creditmemo/create';
        insert ObjAPI1;
        
        List<Id> ClList =new List<Id>();
        Credit_Memo__c  cm =new Credit_Memo__c ();
        cm.API_Status__c = 'Requested';
        cm.API_Request_ID__c = 'test';
        insert cm;
        ClList.add(cm.Id);
        
        Test.startTest();
    
        GenerateCreditMemoBatch obj = new GenerateCreditMemoBatch(ClList);
        DataBase.executeBatch(obj); 
        test.stopTest();
        
        }
    
    static testMethod void testMethod2() 
    {
        Clients__c  Cl =new Clients__c ();
        Cl.Client_Name__c = 'Sample';
        Cl.Invoice_Type__c = 'Regular Invoice';
        Insert Cl;

        Order__c  Ord =new Order__c ();
        Ord.Client__c =Cl.id;
        Ord.Payment_Status__c = 'Invoiced';
        Insert Ord;
        
        Order_Item__c OI =new Order_Item__c();
        OI.Order__c =Ord.Id;
        OI.Billing_Currency__c = 'USD';
        Insert OI;
        
        API_Auth_Detail__c API =new API_Auth_Detail__c();
        API.Type_Of_Credential__c ='QB Credential';
        Insert API;
        
    	API_Credentials__c ObjAPI1 = new API_Credentials__c();
        ObjAPI1.Password__c ='Test@1234';
        ObjAPI1.Username__c ='MaxvalAPI';
        ObjAPI1.Name = 'Renewal CreditMemo Create';
        ObjAPI1.URL__c ='https://api-qa.maxval.com/v1/renewal/creditmemo/create';
        insert ObjAPI1;
        
        List<Id> CmList =new List<Id>();
        Credit_Memo__c  cm =new Credit_Memo__c ();
        cm.Client__c = Cl.Id;
        cm.API_Status__c = 'Requested';
        cm.API_Request_ID__c = 'test';
        insert cm;
        CmList.add(cm.Id);
        
        Batch_Queue__c objBatchQueue = new  Batch_Queue__c();
        objBatchQueue.Name = 'Generate CreditMemo';
        objBatchQueue.Status__c = 'To Do' ;
        objBatchQueue.Parent_Id__c = cm.id;
        insert objBatchQueue;
        
        Test.startTest();
    
        GenerateCreditMemoBatch obj = new GenerateCreditMemoBatch(CmList);
        DataBase.executeBatch(obj,1); 
        test.stopTest();
        }
     static testMethod void testMethod3() 
     {
         
         Test.startTest();
    
        GenerateCreditMemoBatch obj = new GenerateCreditMemoBatch();
        DataBase.executeBatch(obj,1); 
        test.stopTest();
     }
}