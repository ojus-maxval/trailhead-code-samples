/* Copyright © 2022 MaxVal Group. All Rights Reserved.
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Sneha B, January 2022
 */
@isTest
public class InvoiceForMaxvalTest {
@isTest public static void TestMethod1()
{
        PTO_Credentials__c PTO =new PTO_Credentials__c();
        PTO.Country_Code__c ='US';
        //PTO.Name = 'US';
        Insert PTO;
        
        API_Auth_Detail__c API =new API_Auth_Detail__c();
        API.Type_Of_Credential__c ='QB Credential';
        Insert API;
        
        API_Credentials__c ObjAPI1 = new API_Credentials__c();
        ObjAPI1.Password__c ='Test@1234';
        ObjAPI1.Username__c ='MaxvalAPI';
        ObjAPI1.Name = 'Renewal Invoice Update';
        ObjAPI1.URL__c ='https://login.salesforce.com/services/oauth2/token';
        insert ObjAPI1;
        
        API_Credentials__c ObjAPI11 = new API_Credentials__c();
        ObjAPI11.Password__c ='Test@1234';
        ObjAPI11.Username__c ='MaxvalAPI';
        ObjAPI11.Name = 'MaxvalAPI';
        ObjAPI11.URL__c ='https://login.salesforce.com/services/oauth2/token';
        insert ObjAPI11;
        
        API_Credentials__c ObjAPI2 = new API_Credentials__c();
        ObjAPI2.Password__c ='Test@1234';
        ObjAPI2.Username__c ='MaxvalAPI';
        ObjAPI2.Name = 'PTO Payment Validate';
        ObjAPI2.URL__c ='https://login.salesforce.com/services/oauth2/token';
        insert ObjAPI2;
        
        QB_Customer__c QBC1 =New QB_Customer__c();
        // QBC.Client__c =Cl.id;
        QBC1.Currency_Reference__c ='USD';
        Insert QBC1;
        
        List<Id > ClList =new List<Id>();
        Clients__c  Cl =new Clients__c ();
        Cl.Client_Name__c = 'Test Status';
        cl.QB_Customer__c =QBC1.id;
        cl.Billing_Address__c ='hbjhb';
        cl.Client_ID__c='Sample';
        cl.Client_Matter_ID__c='MatterId';
        cl.Client_Type__c='Quarterly';
        cl.Is_LEDES_Required__c=true;
        cl.Law_Firm_Matter_ID__c='LawFirmMatterId';
        cl.Line_Item_Expense_Code__c='E117';
        Insert Cl;
        ClList.add(Cl.id);
        Invoice_Type_Configuration__c ITC =new Invoice_Type_Configuration__c();
        ITC.Contact_Persons__c = 'juveria.b@maxval.com';
        ITC.Client__c =Cl.id;
        insert ITC;
        List<Id> ListOrd =new List<Id>();
        Set<Id > OrdSet =new Set<Id>();
        
        Order__c  Ord =new Order__c ();
        Ord.Client__c =Cl.id;
        Ord.PO_Number__c ='1213';
        Ord.Late_Fee__c =78.0;
        Ord.Rush_Fee__c=78.0;
        Insert Ord;
        OrdSet.add(Ord.id);
        ListOrd.add(Ord.id);
        
        Payment__c PY =new Payment__c ();
        PY.Payment_Amount__c =5800.0;
        Insert PY;
        
        
        
        Invoice__c  Inv =new Invoice__c ();
        Inv.Invoice_Amount__c = 2000.0;
        Inv.API_Status__c =	'Requested';
        Inv.Invoice_Type_Name__c ='_';
    	Inv.Is_Variance__c=true;
    	Inv.Invoice_Date__c=system.today();
        Inv.Order__c = Ord.id;
    
        Inv.Invoice_Currency__c ='USD';
        insert Inv;
    	Order_Item__c OI =new Order_Item__c();
        OI.Order__c =Ord.Id;
        OI.Payment__c =PY.id;
        OI.Payment_Status__c ='Payment Received';
        OI.Invoice__c=Inv.id;
   	 	OI.Cancellation_Approval__c='';
    	OI.Billing_Amount__c=340.00;
    	OI.Jurisdiction__c='US';
        Insert OI;
        List<String> OIList =new List<String>();
        OIList.add(OI.id);
        
    
        QB_Account__c QBA =new QB_Account__c();
        QBA.Account_Type__c ='Income';
        QBA.QB_Account_Id__c='85';
        QBA.Client__c=Cl.id;
   
        Insert QBA;
        
        QB_Customer__c QBC =New QB_Customer__c();
        QBC.Client__c =Cl.id;
        QBC.Currency_Reference__c =Inv.Invoice_Currency__c;
        Insert QBC;
    
        Test.startTest();
    	Invoice__c InvObj =[Select name from Invoice__c limit 1];
   		String JSONMsg= JSON.serialize(Inv);
		RestRequest req = new RestRequest();
		req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
		req.requestURI = '/renewal/invoice/'+InvObj.Name+'/details';
		req.httpMethod = 'GET';
		req.requestBody = Blob.valueof(JSONMsg); // Add JSON Message as a POST
		RestResponse res = new RestResponse();
		RestContext.request = req;
		RestContext.response = res;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    	InvoiceForMaxval.doget();
    	Test.stopTest();
}
    @isTest public static void TestMethod2()
{
        PTO_Credentials__c PTO =new PTO_Credentials__c();
        PTO.Country_Code__c ='US';
        //PTO.Name = 'US';
        Insert PTO;
        
        API_Auth_Detail__c API =new API_Auth_Detail__c();
        API.Type_Of_Credential__c ='QB Credential';
        Insert API;
        
        API_Credentials__c ObjAPI1 = new API_Credentials__c();
        ObjAPI1.Password__c ='Test@1234';
        ObjAPI1.Username__c ='MaxvalAPI';
        ObjAPI1.Name = 'Renewal Invoice Update';
        ObjAPI1.URL__c ='https://login.salesforce.com/services/oauth2/token';
        insert ObjAPI1;
        
        API_Credentials__c ObjAPI11 = new API_Credentials__c();
        ObjAPI11.Password__c ='Test@1234';
        ObjAPI11.Username__c ='MaxvalAPI';
        ObjAPI11.Name = 'MaxvalAPI';
        ObjAPI11.URL__c ='https://login.salesforce.com/services/oauth2/token';
        insert ObjAPI11;
        
        API_Credentials__c ObjAPI2 = new API_Credentials__c();
        ObjAPI2.Password__c ='Test@1234';
        ObjAPI2.Username__c ='MaxvalAPI';
        ObjAPI2.Name = 'PTO Payment Validate';
        ObjAPI2.URL__c ='https://login.salesforce.com/services/oauth2/token';
        insert ObjAPI2;
        
        QB_Customer__c QBC1 =New QB_Customer__c();
        QBC1.Currency_Reference__c ='USD';
        Insert QBC1;
        
        List<Id > ClList =new List<Id>();
        Clients__c  Cl =new Clients__c ();
        Cl.Client_Name__c = 'Dropbox';
        cl.QB_Customer__c =QBC1.id;
        cl.Billing_Address__c ='hbjhb';
        cl.Client_ID__c='Sample';
        cl.Client_Matter_ID__c='MatterId';
        cl.Client_Type__c='Monthly';
        cl.Is_LEDES_Required__c=true;
        cl.Law_Firm_Matter_ID__c='LawFirmMatterId';
        cl.Line_Item_Expense_Code__c='E117';
        Insert Cl;
        ClList.add(Cl.id);
        Invoice_Type_Configuration__c ITC =new Invoice_Type_Configuration__c();
        ITC.Contact_Persons__c = 'juveria.b@maxval.com';
        ITC.Client__c =Cl.id;
        insert ITC;
        List<Id> ListOrd =new List<Id>();
        Set<Id > OrdSet =new Set<Id>();
        
        Order__c  Ord =new Order__c ();
        Ord.Client__c =Cl.id;
        Ord.PO_Number__c ='1213';
        Ord.Late_Fee__c =78.0;
        Ord.Rush_Fee__c=78.0;
        Insert Ord;
        OrdSet.add(Ord.id);
        ListOrd.add(Ord.id);
        
        Payment__c PY =new Payment__c ();
        PY.Payment_Amount__c =5800.0;
        Insert PY;
        Invoice__c  Inv =new Invoice__c ();
        Inv.Invoice_Amount__c = 2000.0;
        Inv.API_Status__c =	'Requested';
        Inv.Invoice_Type_Name__c ='_';
    	Inv.Is_Variance__c=false;
    	Inv.Invoice_Date__c=system.today();
        Inv.Order__c = Ord.id;
    
        Inv.Invoice_Currency__c ='USD';
        insert Inv;
    	Order_Item__c OI =new Order_Item__c();
        OI.Order__c =Ord.Id;
        OI.Payment__c =PY.id;
        OI.Payment_Status__c ='Payment Received';
        OI.Invoice__c=Inv.id;
   	 	OI.Cancellation_Approval__c='';
    	OI.Billing_Amount__c=340.00;
    	OI.Docket_No__c='SYMP/009/009889';
    	OI.Patent_No__c='EP0099880.1';
    	OI.Term_Name__c='Year 3';
    	OI.Due_Date__c=system.today();
        Insert OI;
        List<String> OIList =new List<String>();
        OIList.add(OI.id);
        
    
        QB_Account__c QBA =new QB_Account__c();
        QBA.Account_Type__c ='Income';
        QBA.QB_Account_Id__c='85';
        QBA.Client__c=Cl.id;
   
        Insert QBA;
        
        QB_Customer__c QBC =New QB_Customer__c();
        QBC.Client__c =Cl.id;
        QBC.Currency_Reference__c =Inv.Invoice_Currency__c;
        Insert QBC;
    
        Test.startTest();
    	Invoice__c InvObj =[Select name from Invoice__c limit 1];
   		String JSONMsg= JSON.serialize(Inv);
		RestRequest req = new RestRequest();
		req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
		req.requestURI = '/renewal/invoice/'+InvObj.Name+'/details';
		req.httpMethod = 'GET';
		req.requestBody = Blob.valueof(JSONMsg); // Add JSON Message as a POST
		RestResponse res = new RestResponse();
		RestContext.request = req;
		RestContext.response = res;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    	InvoiceForMaxval.doget();
    	Test.stopTest();
}
    @isTest public static void TestMethod3()
    {
        Test.startTest();
        RestRequest req = new RestRequest();
        req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
        req.requestURI = '/renewal/invoice/INV-123/details';
        req.httpMethod = 'GET'; // Add JSON Message as a POST
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        InvoiceForMaxval.doget();
        Test.stopTest();
    }
}