/* Copyright © 2021 MaxVal Group. All Rights Reserved.
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Sneha B, April 2021
 */

@isTest
public class BillCreationStatusServiceClassTest {

 public static testmethod void BillCreationStatusTest1()
 {    
    Payment_Confirmation__c pc=new Payment_Confirmation__c();
    pc.Bill_Request_ID__c='BILL-9847762535243';
    insert pc;
    RestResponse res = new RestResponse();
    RestRequest req =new RestRequest();
    req.requestURI = '/services/apexrest/renewal/bill/status/';  //Request URL
    req.httpMethod = 'POST';//HTTP Request Type
    RestContext.request = req;
    RestContext.response = res;
    String JSONMsg ='{"ClientRequestHandle":"464738","RequestID":"BILL-9847762535243","Status":6,"BillNo":"B202011000","Error":[],"Warning":[{"Code":"invalid","Description":"Invalid cus ref"}]}';
    req.requestBody = Blob.valueof(JSONMsg);
    Test.startTest();
    BillCreationStatusEntity.BillCreationStatusResponse  results = BillCreationStatusServiceClass.BillCreationStatus();
    Test.stopTest(); 
 } 
    public static testmethod void BillCreationStatusTest2()
    {    
        Payment_Confirmation__c pc=new Payment_Confirmation__c();
        pc.Bill_Request_ID__c='BILL-9847762535243';
        insert pc;
        RestResponse res = new RestResponse();
        RestRequest req =new RestRequest();
        req.requestURI = '/services/apexrest/renewal/bill/status/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response = res;
        String JSONMsg ='{"ClientRequestHandle":"464738","RequestID":"BILL-9847762535243","Status":3,"BillNo":"B202011000","Error":[],"Warning":[{"Code":"invalid","Description":"Invalid cus ref"}]}';
        req.requestBody = Blob.valueof(JSONMsg);
        Test.startTest();
        BillCreationStatusEntity.BillCreationStatusResponse  results = BillCreationStatusServiceClass.BillCreationStatus();
        Test.stopTest(); 
    }
    public static testmethod void BillCreationStatusTest3()
    {    
        Payment_Confirmation__c pc=new Payment_Confirmation__c();
        pc.Bill_Request_ID__c='BILL-9847762535243';
        insert pc;
        RestResponse res = new RestResponse();
        RestRequest req =new RestRequest();
        req.requestURI = '/services/apexrest/renewal/bill/status/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response = res;
        String JSONMsg ='{"ClientRequestHandle":"464738","RequestID":"BILL-9847762535243","Status":7,"BillNo":"B202011000","Error":[{"Code":"invalid","Description":"Invalid cus ref"},{"Code":"invalid","Description":"Invalid cus ref"}],"Warning":[{"Code":"invalid","Description":"Invalid cus ref"}]}';
        req.requestBody = Blob.valueof(JSONMsg);
        Test.startTest();
        BillCreationStatusEntity.BillCreationStatusResponse  results = BillCreationStatusServiceClass.BillCreationStatus();
        Test.stopTest(); 
    }
    public static testmethod void BillCreationStatusTest4()
    {    
        Payment_Confirmation__c pc=new Payment_Confirmation__c();
        pc.Bill_Request_ID__c='BILL-9847762535243';
        insert pc;
        RestResponse res = new RestResponse();
        RestRequest req =new RestRequest();
        req.requestURI = '/services/apexrest/renewal/bill/status/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response = res;
        String JSONMsg ='{"ClientRequestHandle":"464738","RequestID":"BILL-9847762535243","Status":0,"BillNo":"B202011000","Error":[{"Code":"invalid","Description":"Invalid cus ref"},{"Code":"invalid","Description":"Invalid cus ref"}],"Warning":[{"Code":"invalid","Description":"Invalid cus ref"}]}';
        req.requestBody = Blob.valueof(JSONMsg);
        Test.startTest();
        BillCreationStatusEntity.BillCreationStatusResponse  results = BillCreationStatusServiceClass.BillCreationStatus();
        Test.stopTest(); 
    }
    public static testmethod void BillCreationStatusTest5()
    { 
        RestResponse res = new RestResponse();
        RestRequest req =new RestRequest();
        req.requestURI = '/services/apexrest/renewal/bill/status/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response = res;
        String JSONMsg ='{"ClientRequestHandle":"464738","RequestID":"BILL-0","Status":true,"BillNo":"B202011000","Error":[{"Code":"invalid","Description":"Invalid cus ref"},{"Code":"invalid","Description":"Invalid cus ref"}],"Warning":[{"Code":"invalid","Description":"Invalid cus ref"}]}';
        req.requestBody = Blob.valueof(JSONMsg);
        Test.startTest();
        BillCreationStatusEntity.BillCreationStatusResponse  results = BillCreationStatusServiceClass.BillCreationStatus();
        Test.stopTest(); 
    }
    public static testmethod void BillCreationStatusTest6()
    { 
        RestResponse res = new RestResponse();
        RestRequest req =new RestRequest();
        req.requestURI = '/services/apexrest/renewal/bill/status/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response = res;
        String JSONMsg ='{"ClientRequestHandle":"","RequestID":"","Status":3,"BillNo":"","Error":[{"Code":"invalid","Description":"Invalid cus ref"},{"Code":"invalid","Description":"Invalid cus ref"}],"Warning":[{"Code":"invalid","Description":"Invalid cus ref"}]}';
        req.requestBody = Blob.valueof(JSONMsg);
        Test.startTest();
        BillCreationStatusEntity.BillCreationStatusResponse  results = BillCreationStatusServiceClass.BillCreationStatus();
        Test.stopTest(); 
    }
    public static testmethod void BillCreationStatusTest7()
    {    
        Payment_Confirmation__c pc=new Payment_Confirmation__c();
        pc.Bill_Request_ID__c='BILL-9847762535243';
        insert pc;
        RestResponse res = new RestResponse();
        RestRequest req =new RestRequest();
        req.requestURI = '/services/apexrest/renewal/bill/status/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response = res;
        String JSONMsg ='{"ClientRequestHandle":"464738","RequestID":"BILL-9847762535243","Status":6,"BillNo":"B202011000","Error":[{"Code":"invalid","Description":"Invalid cus ref"},{"Code":"invalid","Description":"Invalid cus ref"}],"Warning":[{"Code":"invalid","Description":"Invalid cus ref"}]}';
        req.requestBody = Blob.valueof(JSONMsg);
        Test.startTest();
        BillCreationStatusEntity.BillCreationStatusResponse  results = BillCreationStatusServiceClass.BillCreationStatus();
        Test.stopTest(); 
    }
}