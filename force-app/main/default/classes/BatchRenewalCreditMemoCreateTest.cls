@isTest
public class BatchRenewalCreditMemoCreateTest {
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
        
        API_Credentials__c ObjAPI11 = new API_Credentials__c();
        ObjAPI11.Password__c ='Test1234';
        ObjAPI11.Username__c ='iyvchffclv0ixuuu';
        ObjAPI11.Name = 'MaxvalAPI';
        ObjAPI11.URL__c ='https://api-conqa.maxval.com/services/oauth2/token';
        insert ObjAPI11;
        
        List<Id> ClList =new List<Id>();
        Credit_Memo__c  cm =new Credit_Memo__c ();
        cm.API_Status__c = 'Requested';
        cm.API_Request_ID__c = 'test';
        insert cm;
        ClList.add(cm.Id);
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new RenewalCreditMemoCreateMockResponse());
        MaxValAPIAuthenticaionHelper.MaxValAPIAuthenticaionHelper();
        BatchRenewalCreditMemoCreate   ObjBatch =new BatchRenewalCreditMemoCreate(ClList);
        Database.executeBatch(ObjBatch, 1);
        Test.stopTest();
    }
    
    static testMethod void testMethod2() 
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
        
        API_Credentials__c ObjAPI11 = new API_Credentials__c();
        ObjAPI11.Password__c ='Test1234';
        ObjAPI11.Username__c ='iyvchffclv0ixuuu';
        ObjAPI11.Name = 'MaxvalAPI';
        ObjAPI11.URL__c ='https://api-conqa.maxval.com/services/oauth2/token';
        insert ObjAPI11;
        
        List<Id> ClList =new List<Id>();
        Credit_Memo__c  cm =new Credit_Memo__c ();
        cm.API_Status__c = 'Requested';
        cm.API_Request_ID__c = 'test';
        insert cm;
        ClList.add(cm.Id);
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new RenewalCreditMemoCreateMockErrorResponse());
        MaxValAPIAuthenticaionHelper.MaxValAPIAuthenticaionHelper();
        BatchRenewalCreditMemoCreate   ObjBatch =new BatchRenewalCreditMemoCreate(ClList);
        Database.executeBatch(ObjBatch, 1);
        Test.stopTest();
    }
    
    static testMethod void testMethod3() 
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
        
        API_Credentials__c ObjAPI11 = new API_Credentials__c();
        ObjAPI11.Password__c ='Test1234';
        ObjAPI11.Username__c ='iyvchffclv0ixuuu';
        ObjAPI11.Name = 'MaxvalAPI';
        ObjAPI11.URL__c ='https://api-conqa.maxval.com/services/oauth2/token';
        insert ObjAPI11;
        
        List<Id> ClList =new List<Id>();
        Credit_Memo__c  cm =new Credit_Memo__c ();
        cm.API_Status__c = 'Requested';
        cm.API_Request_ID__c = 'test';
        insert cm;
        ClList.add(cm.Id);
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new RenewalCreditMemoCreateMockErrorResponse());
        MaxValAPIAuthenticaionHelper.MaxValAPIAuthenticaionHelper();
        BatchRenewalCreditMemoCreate   ObjBatch =new BatchRenewalCreditMemoCreate(ClList);
        Database.executeBatch(ObjBatch, 1);
        Test.stopTest();
    }
}