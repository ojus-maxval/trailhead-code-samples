@isTest
public class GetCreditMemoDetailsTest {
    @isTest 
    public static void TestMethod1()
    {       
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
        
        API_Auth_Detail__c apiAuth = new API_Auth_Detail__c();
        apiAuth.Type_Of_Credential__c ='QB Credential';
        insert apiAuth;
        
        Clients__c  Cl =new Clients__c ();
        Cl.Client_Name__c = 'Test Status';
        Cl.Contact_Email_Id__c ='juveria.b@maxval.com';
        Insert Cl;
        
        QB_Account__c acc = new QB_Account__c();
        acc.QB_Account_Id__c = '1';
        acc.Client__c = Cl.Id;
        insert acc;
        
        QB_Customer__c cus = new QB_Customer__c();
        cus.QB_Customer_Id__c = '1';
        cus.Client__c = Cl.Id;
        insert cus;
        
        Credit_Memo__c  cmRec  = new Credit_Memo__c();
        cmRec.API_Status__c = 'Requested';
        insert cmRec;
        
        Test.startTest();
        Credit_Memo__c cm =[Select name from Credit_Memo__c limit 1];
        String jsonMsg = JSON.serialize(cm);
        RestRequest req = new RestRequest();
        req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
        req.requestURI = '/renewal/creditmemo/'+ cm.Name +'/details';
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueof(jsonMsg); // Add JSON Message as a POST
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        Test.setMock(HttpCalloutMock.class, new GetCreditMemoDetailsMockErrorResponse());
        GetCreditMemoDetails.doget();
        Test.stopTest();
    }
    @isTest 
    public static void TestMethod2()
    {       
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
        
        API_Auth_Detail__c apiAuth = new API_Auth_Detail__c();
        apiAuth.Type_Of_Credential__c ='QB Credential';
        insert apiAuth;
        
        Clients__c  Cl =new Clients__c ();
        Cl.Client_Name__c = 'Test Status';
        Cl.Contact_Email_Id__c ='juveria.b@maxval.com';
        Insert Cl;
        
        QB_Account__c acc = new QB_Account__c();
        acc.QB_Account_Id__c = '1';
        acc.Client__c = Cl.Id;
        insert acc;
        
        QB_Customer__c cus = new QB_Customer__c();
        cus.QB_Customer_Id__c = '1';
        cus.Client__c = Cl.Id;
        insert cus;
        
        Test.startTest();
        RestRequest req = new RestRequest();
        req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
        req.requestURI = '/renewal/creditmemo/'+ 'CM-00001' +'/details';
        req.httpMethod = 'GET';
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        Test.setMock(HttpCalloutMock.class, new GetCreditMemoDetailsMockErrorResponse());
        GetCreditMemoDetails.doget();
        Test.stopTest();
    }
     @isTest 
    public static void TestMethod3()
    {       
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
        
        API_Auth_Detail__c apiAuth = new API_Auth_Detail__c();
        apiAuth.Type_Of_Credential__c ='QB Credential';
        insert apiAuth;
        
        Test.startTest();
        RestRequest req = new RestRequest();
        req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
        req.requestURI = '/renewal/creditmemo/'+ 'CM-00001';
        req.httpMethod = 'GET';
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        Test.setMock(HttpCalloutMock.class, new GetCreditMemoDetailsMockErrorResponse());
        GetCreditMemoDetails.doget();
        Test.stopTest();
    }
    @isTest 
    public static void TestMethod4()
    {       
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
        
        API_Auth_Detail__c apiAuth = new API_Auth_Detail__c();
        apiAuth.Type_Of_Credential__c ='QB Credential';
        insert apiAuth;
        
        Clients__c  Cl =new Clients__c ();
        Cl.Client_Name__c = 'Test Status';
        Cl.Contact_Email_Id__c ='juveria.b@maxval.com';
        Insert Cl;
        
        QB_Account__c acc = new QB_Account__c();
        acc.QB_Account_Id__c = '1';
        acc.Client__c = Cl.Id;
        insert acc;
        
        QB_Customer__c cus = new QB_Customer__c();
        cus.QB_Customer_Id__c = '1';
        cus.Client__c = Cl.Id;
        insert cus;
        
        Order__c order = new Order__c();
        order.Client__c = Cl.Id;
        insert order;
        
        Order_Item__c oi1 = new Order_Item__c();
        oi1.Order__c = order.Id;
        oi1.Patent_No__c = 'US12345';
        oi1.Application_No__c = 'US1234567';
        oi1.Payment_Status__c = 'Asset Renewed';
        oi1.CreditMemo_Amount__c = 1800.00;
        oi1.CreditMemo_Comments__c = 'fluctuation';
        insert oi1;
        
        Credit_Memo__c  cmRec  = new Credit_Memo__c();
        cmRec.API_Status__c = 'Requested';
        insert cmRec;
        
        oi1.Credit_Memo__c = cmRec.Id;
        update oi1;
        
        Test.startTest();
        Credit_Memo__c cm =[Select name from Credit_Memo__c limit 1];
        String jsonMsg = JSON.serialize(cm);
        RestRequest req = new RestRequest();
        req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
        req.requestURI = '/renewal/creditmemo/'+ cm.Name +'/details';
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueof(jsonMsg); // Add JSON Message as a POST
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        Test.setMock(HttpCalloutMock.class, new GetCreditMemoDetailsMockResponse());
        GetCreditMemoDetails.doget();
        Test.stopTest();
    }
    
}