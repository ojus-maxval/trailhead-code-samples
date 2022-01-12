/* Copyright © 2022 MaxVal Group. All Rights Reserved.
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Sneha B, January 2022
 */
@isTest
public class InvoiceStatusRequestTest 
{
    public static Invoice__c Inv;
    public static testmethod void InvoiceResponseTest()
    {
        PTO_Credentials__c PTO =new PTO_Credentials__c();
        PTO.Country_Code__c ='US';
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
        
        QB_Customer__c QBC1 =New QB_Customer__c();
        QBC1.Currency_Reference__c ='USD';
        Insert QBC1;
        
        List<Id > ClList =new List<Id>();
        Clients__c  Cl =new Clients__c ();
        Cl.Client_Name__c = 'Test Status';
        cl.QB_Customer__c =QBC1.id;
        cl.Billing_Address__c ='address';
        Insert Cl;
        ClList.add(Cl.id);
        Invoice_Type_Configuration__c ITC =new Invoice_Type_Configuration__c();
        ITC.Contact_Persons__c = 'sneha.b@maxval.com';
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
        
        Order_Item__c OI =new Order_Item__c();
        OI.Order__c =Ord.Id;
        OI.Payment__c =PY.id;
        OI.Payment_Status__c ='Payment Received';
        Insert OI;
        List<String> OIList =new List<String>();
        OIList.add(OI.id);
        
        Inv =new Invoice__c ();
        Inv.Invoice_Amount__c = 2000.0;
        Inv.API_Status__c =	'Requested';
        Inv.Invoice_Type_Name__c ='-';
        Inv.Order__c = Ord.id;
        Inv.Invoice_Currency__c ='USD';
        insert Inv;
        
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
      	List<Invoice__c> invoice=[Select name from Invoice__c where id=:Inv.id];
   		String json = '{"ClientRequestHandle": "a002E00000k8s3p_a022E00000bMtUd_USD","RequestID": "28c30658-28c30658-28c30658-28c30658","Status": 4,"Error":[],"Data":[{"InvoiceRef":"'+invoice[0].name+'","Status":4,"InvoiceNo":"A202009119","Error":[],"Warning":[]}]}';
    	RestRequest req = new RestRequest();
		req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
		req.requestURI = 'renewal/invoice/request/status';
		req.httpMethod = 'POST';
		req.requestBody = Blob.valueOf(json); // Add JSON Message as a POST
		RestResponse res = new RestResponse();
		RestContext.request = req;
		RestContext.response = res;
    	InvoiceStatusRequest.InvoiceStatus();
    	Test.stopTest();
	}
    public static testmethod void LedesResponseTest()
    {
        PTO_Credentials__c PTO =new PTO_Credentials__c();
        PTO.Country_Code__c ='US';
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
        
        QB_Customer__c QBC1 =New QB_Customer__c();
        QBC1.Currency_Reference__c ='USD';
        Insert QBC1;
        
        List<Id > ClList =new List<Id>();
        Clients__c  Cl =new Clients__c ();
        Cl.Client_Name__c = 'Test Status';
        cl.QB_Customer__c =QBC1.id;
        cl.Billing_Address__c ='address';
        Insert Cl;
        ClList.add(Cl.id);
        Invoice_Type_Configuration__c ITC =new Invoice_Type_Configuration__c();
        ITC.Contact_Persons__c = 'sneha.b@maxval.com';
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
        
        Order_Item__c OI =new Order_Item__c();
        OI.Order__c =Ord.Id;
        OI.Payment__c =PY.id;
        OI.Payment_Status__c ='Payment Received';
        Insert OI;
        List<String> OIList =new List<String>();
        OIList.add(OI.id);
        
        Inv =new Invoice__c ();
        Inv.Invoice_Amount__c = 2000.0;
        Inv.API_Status__c =	'Requested';
        Inv.Invoice_Type_Name__c ='-';
        Inv.Order__c = Ord.id;
        Inv.Invoice_Currency__c ='USD';
        insert Inv;
        
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
        List<Invoice__c> invoice=[Select name from Invoice__c where id=:Inv.id];
   		String json = '{"ClientRequestHandle":"a065f000002QKp6AAG","RequestID":"INV-132844502652784617","Status":3,"Error":[],"Data":[{"Status":3,"InvoiceRef":"'+invoice[0].name+'","InvoiceNo":"202112061","Error":[],"Warning":[{"Code":"API.INVWG.003","Description":"PO Number Section does not exist in Invoice Details url response"}],"LEDESResponse":{"LEDESStatus":"Failed","Warning":[{"Code":"API.INVWG.028","Description":"Following field(s) does not exist in the LEDESdetails section - PatentID"},{"Code":"API.INVWG.028","Description":"Following field(s) does not exist in the LEDESdetails section - PatentID"}]}}]}';
    	RestRequest req = new RestRequest();
		req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
		req.requestURI = 'renewal/invoice/request/status';  
		req.httpMethod = 'POST';
		req.requestBody = Blob.valueOf(json); // Add JSON Message as a POST
		RestResponse res = new RestResponse();
		RestContext.request = req;
		RestContext.response = res;
    	InvoiceStatusRequest.InvoiceStatus();
    	Test.stopTest();
}
    public static testmethod void NegativeCase1()
    {
        PTO_Credentials__c PTO =new PTO_Credentials__c();
        PTO.Country_Code__c ='US';
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
        
        QB_Customer__c QBC1 =New QB_Customer__c();
        QBC1.Currency_Reference__c ='USD';
        Insert QBC1;
        
        List<Id > ClList =new List<Id>();
        Clients__c  Cl =new Clients__c ();
        Cl.Client_Name__c = 'Test Status';
        cl.QB_Customer__c =QBC1.id;
        cl.Billing_Address__c ='address';
        Insert Cl;
        ClList.add(Cl.id);
        Invoice_Type_Configuration__c ITC =new Invoice_Type_Configuration__c();
        ITC.Contact_Persons__c = 'sneha.b@maxval.com';
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
        
        Order_Item__c OI =new Order_Item__c();
        OI.Order__c =Ord.Id;
        OI.Payment__c =PY.id;
        OI.Payment_Status__c ='Payment Received';
        Insert OI;
        List<String> OIList =new List<String>();
        OIList.add(OI.id);
        
        Inv =new Invoice__c ();
        Inv.Invoice_Amount__c = 2000.0;
        Inv.API_Status__c =	'Requested';
        Inv.Invoice_Type_Name__c ='-';
        Inv.Order__c = Ord.id;
        Inv.Invoice_Currency__c ='USD';
        insert Inv;
        
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
        List<Invoice__c> invoice=[Select name from Invoice__c where id=:Inv.id];
   		String json = '{"ClientRequestHandle":"a065f000002QKp6AAG","RequestID":"INV-84347636438","Status":6,"Error":[],"Data":[{"Status":6,"InvoiceRef":"'+invoice[0].name+'","InvoiceNo":"202112061","Error":[{"Code":"API.INV.003","Description":"Error response"}],"Warning":[{"Code":"API.INVWG.003","Description":"PO Number Section does not exist in Invoice Details url response"}],"LEDESResponse":{"LEDESStatus":"Failed","Warning":[{"Code":"API.INVWG.028","Description":"Following field(s) does not exist in the LEDESdetails section - PatentID"}]}}]}';
    	RestRequest req = new RestRequest();
		req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
		req.requestURI = 'renewal/invoice/request/status';  
		req.httpMethod = 'POST';
		req.requestBody = Blob.valueOf(json); // Add JSON Message as a POST
		RestResponse res = new RestResponse();
		RestContext.request = req;
		RestContext.response = res;
    	InvoiceStatusRequest.InvoiceStatus();
    	Test.stopTest();
}
    public static testmethod void NegativeCase2()
    {
        PTO_Credentials__c PTO =new PTO_Credentials__c();
        PTO.Country_Code__c ='US';
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
        
        QB_Customer__c QBC1 =New QB_Customer__c();
        QBC1.Currency_Reference__c ='USD';
        Insert QBC1;
        
        List<Id > ClList =new List<Id>();
        Clients__c  Cl =new Clients__c ();
        Cl.Client_Name__c = 'Test Status';
        cl.QB_Customer__c =QBC1.id;
        cl.Billing_Address__c ='address';
        Insert Cl;
        ClList.add(Cl.id);
        Invoice_Type_Configuration__c ITC =new Invoice_Type_Configuration__c();
        ITC.Contact_Persons__c = 'sneha.b@maxval.com';
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
        
        Order_Item__c OI =new Order_Item__c();
        OI.Order__c =Ord.Id;
        OI.Payment__c =PY.id;
        OI.Payment_Status__c ='Payment Received';
        Insert OI;
        List<String> OIList =new List<String>();
        OIList.add(OI.id);
        
        Inv =new Invoice__c ();
        Inv.Invoice_Amount__c = 2000.0;
        Inv.API_Status__c =	'Requested';
        Inv.Invoice_Type_Name__c ='-';
        Inv.Order__c = Ord.id;
        Inv.Invoice_Currency__c ='USD';
        insert Inv;
        
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
        List<Invoice__c> invoice=[Select name from Invoice__c where id=:Inv.id];
   		String json = '{"ClientRequestHandle":"a065f000002QKp6AAG","RequestID":"INV-84347636438","Status":5,"Error":[],"Data":[{"Status":5,"InvoiceRef":"'+invoice[0].name+'","InvoiceNo":"202112061","Error":[{"Code":"API.INV.003","Description":"Error response"}],"Warning":[{"Code":"API.INVWG.003","Description":"PO Number Section does not exist in Invoice Details url response"}],"LEDESResponse":{"LEDESStatus":"Failed","Warning":[{"Code":"API.INVWG.028","Description":"Following field(s) does not exist in the LEDESdetails section - PatentID"}]}}]}';
    	RestRequest req = new RestRequest();
		req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
		req.requestURI = 'renewal/invoice/request/status';  
		req.httpMethod = 'POST';
		req.requestBody = Blob.valueOf(json); // Add JSON Message as a POST
		RestResponse res = new RestResponse();
		RestContext.request = req;
		RestContext.response = res;
    	InvoiceStatusRequest.InvoiceStatus();
    	Test.stopTest();
}
    public static testmethod void RequestHandleNullValidation()
    {
     	Test.startTest();
   		String json = '{"ClientRequestHandle":"","RequestID":"INV-7473989388373728","Status":6,"Error":[],"Data":[{"Status":3,"InvoiceRef":"INV-23","InvoiceNo":"202112061","Error":[{"Code":"API.INV.003","Description":"Error response"}],"Warning":[{"Code":"API.INVWG.003","Description":"PO Number Section does not exist in Invoice Details url response"}],"LEDESResponse":{"LEDESStatus":"Failed","Warning":[{"Code":"API.INVWG.028","Description":"Following field(s) does not exist in the LEDESdetails section - PatentID"}]}}]}';
    	RestRequest req = new RestRequest();
		req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
		req.requestURI = 'renewal/invoice/request/status';  
		req.httpMethod = 'POST';
		req.requestBody = Blob.valueOf(json); // Add JSON Message as a POST
		RestResponse res = new RestResponse();
		RestContext.request = req;
		RestContext.response = res;
    	InvoiceStatusRequest.InvoiceStatus();
    	Test.stopTest();
	}
    public static testmethod void RequestIdNullValidation()
    {
     	Test.startTest();
   		String json = '{"ClientRequestHandle":"fdhgftetdyhehd","RequestID":"","Status":4,"Error":[],"Data":[{"Status":3,"InvoiceRef":"INV-23","InvoiceNo":"202112061","Error":[{"Code":"API.INV.003","Description":"Error response"}],"Warning":[{"Code":"API.INVWG.003","Description":"PO Number Section does not exist in Invoice Details url response"}],"LEDESResponse":{"LEDESStatus":"Failed","Warning":[{"Code":"API.INVWG.028","Description":"Following field(s) does not exist in the LEDESdetails section - PatentID"}]}}]}';
    	RestRequest req = new RestRequest();
		req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
		req.requestURI = 'renewal/invoice/request/status';  
		req.httpMethod = 'POST';
		req.requestBody = Blob.valueOf(json); // Add JSON Message as a POST
		RestResponse res = new RestResponse();
		RestContext.request = req;
		RestContext.response = res;
    	InvoiceStatusRequest.InvoiceStatus();
    	Test.stopTest();
	}
}