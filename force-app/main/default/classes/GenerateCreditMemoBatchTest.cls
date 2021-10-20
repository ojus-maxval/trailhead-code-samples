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
    
    
}