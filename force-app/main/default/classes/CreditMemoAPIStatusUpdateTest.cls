@isTest 
public class CreditMemoAPIStatusUpdateTest {
    @isTest 
    public static void TestMethod1()
    {       
        Credit_Memo__c  cmRec  = new Credit_Memo__c();
        cmRec.API_Status__c = 'Requested';
        cmRec.CreditMemo_Status__c='Todo';
        cmRec.API_Message__c = '';
        cmRec.CreditMemo__c = '';
        insert cmRec;
        
        Test.startTest();
        String jsonMsg1 = '{"ClientRequestHandle":"8bd2ee6c-ab07-4793-8078-56e338614025","RequestID":"CREDITMEMO-1234567890","Status":"3","Error":[],"Data":[]';
        RestRequest req = new RestRequest();
        req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
        req.requestURI = '/renewal/creditmemo/request/status/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonMsg1); // Add JSON Message as a POST
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        Test.setMock(HttpCalloutMock.class, new CreditMemoAPIStatusUpdateMockResponse());
        CreditMemoAPIStatusUpdate.CreditMemoStatus();
        Test.stopTest();
    }
	@isTest 
    public static void TestMethod8()
    {       
        Credit_Memo__c  cmRec  = new Credit_Memo__c();
        cmRec.API_Status__c = 'Requested';
        cmRec.CreditMemo_Status__c='Todo';
        cmRec.API_Message__c = '';
        cmRec.CreditMemo__c = '';
        insert cmRec;
        
        Test.startTest();
        String jsonMsg8 = '{"ClientRequestHandle":"8bd2ee6c-ab07-4793-8078-56e338614025","RequestID":"CREDITMEMO-1234567890","Status":"3","Error":[],"Data":[{"Status":"3","CreditMemoRef":"'+ cmRec.Name +'","CreditMemoNo":"C202108014","Error":[],"Warning":[]}]}';
        RestRequest req = new RestRequest();
        req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
        req.requestURI = '/renewal/creditmemo/request/status/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonMsg8); // Add JSON Message as a POST
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        Test.setMock(HttpCalloutMock.class, new CreditMemoAPIStatusUpdateMockResponse());
        CreditMemoAPIStatusUpdate.CreditMemoStatus();
        Test.stopTest();
    }
    @isTest 
    public static void TestMethod2()
    {       
        Credit_Memo__c  cmRec  = new Credit_Memo__c();
        cmRec.API_Status__c = 'Requested';
        cmRec.CreditMemo_Status__c='Todo';
        cmRec.API_Message__c = '';
        cmRec.CreditMemo__c = '';
        insert cmRec;
        
        Test.startTest();
        String jsonMsg2 = '{"ClientRequestHandle":"","RequestID":"CREDITMEMO-132712542808805772","Status":"2","Error":[],"Data":[{"Status":"6","CreditMemoRef":"'+cmRec.Name+'","CreditMemoNo":"","Error":[{"Code":"API.CreditMemoG.039","Description":"Failed to get Credit Memo details from the URL - https://marsff-dev-ed.lightning.force.com/services/apexrest/renewal/creditmemo/63463/details"}],"Warning":[]}]}';
        RestRequest req = new RestRequest();
        req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
        req.requestURI = '/renewal/creditmemo/request/status/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonMsg2); // Add JSON Message as a POST
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        Test.setMock(HttpCalloutMock.class, new CreditMemoAPIStatusUpdateMockResponse());
        CreditMemoAPIStatusUpdate.CreditMemoStatus();
        Test.stopTest();
    }
     @isTest 
    public static void TestMethod3()
    {   
        Credit_Memo__c  cmRec  = new Credit_Memo__c();
        cmRec.API_Status__c = 'Requested';
        cmRec.CreditMemo_Status__c='Todo';
        cmRec.API_Message__c = '';
        cmRec.CreditMemo__c = '';
        insert cmRec;
        
        Test.startTest();
        String jsonMsg3 = '{"ClientRequestHandle":"8bd2ee6c-ab07-4793-8078-56e338614025","RequestID":"CREDITMEMO-132712542808805772","Status":"2","Error":[],"Data":[{"Status":"6","CreditMemoRef":"'+cmRec.Name+'","CreditMemoNo":"","Error":[{"Code":"API.CreditMemoG.039","Description":"Failed to get Credit Memo details from the URL - https://marsff-dev-ed.lightning.force.com/services/apexrest/renewal/creditmemo/63463/details"}],"Warning":[]}]}';
        RestRequest req = new RestRequest();
        req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
        req.requestURI = '/renewal/creditmemo/request/status/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonMsg3); // Add JSON Message as a POST
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        Test.setMock(HttpCalloutMock.class, new CreditMemoAPIStatusUpdateMockResponse());
        CreditMemoAPIStatusUpdate.CreditMemoStatus();
        Test.stopTest();
    }
    @isTest 
    public static void TestMethod4()
    {               
        Credit_Memo__c  cmRec  = new Credit_Memo__c();
        cmRec.API_Status__c = 'Requested';
        cmRec.CreditMemo_Status__c='Todo';
        cmRec.API_Message__c = '';
        cmRec.CreditMemo__c = '';
        insert cmRec;
        
        Test.startTest();
        String jsonMsg4 = '{"ClientRequestHandle":"8bd2ee6c-ab07-4793-8078-56e338614025","RequestID":"CREDITMEMO-132727062962347256","Status":3,"Error":[],"Data":[{"Status":3,"CreditMemoRef":'+cmRec.Name+',"CreditMemoNo":"C202108014","Error":[],"Warning":[{"Code":"API.CreditMemoWG.017","Description":"The CustomerName - PayPal for the given BillToRef - 200 does not match with that in QB. CustomerName in QB - ORD-577"},{"Code":"API.CreditMemoWG.011","Description":"Attachment Section does not exist in Credit Memo Details url response"}]}]}';
        RestRequest req = new RestRequest();
        req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
        req.requestURI = '/renewal/creditmemo/request/status/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonMsg4); // Add JSON Message as a POST
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        Test.setMock(HttpCalloutMock.class, new CreditMemoAPIStatusUpdateMockResponse());
        CreditMemoAPIStatusUpdate.CreditMemoStatus();
        Test.stopTest();
    }
    @isTest 
    public static void TestMethod5()
    {       
        Credit_Memo__c  cmRec  = new Credit_Memo__c();
        cmRec.API_Status__c = 'Requested';
        cmRec.CreditMemo_Status__c='Todo';
        cmRec.API_Message__c = '';
        cmRec.CreditMemo__c = '';
        insert cmRec;
        
        Test.startTest();
        String jsonMsg5 = '{"ClientRequestHandle":"8bd2ee6c-ab07-4793-8078-56e338614025","RequestID":"CREDITMEMO-1234567890","Status":"3","Error":[]';
        RestRequest req = new RestRequest();
        req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
        req.requestURI = '/renewal/creditmemo/request/status/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonMsg5); // Add JSON Message as a POST
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        Test.setMock(HttpCalloutMock.class, new CreditMemoAPIStatusUpdateMockResponse());
        CreditMemoAPIStatusUpdate.CreditMemoStatus();
        Test.stopTest();
    }
    
    @isTest 
    public static void TestMethod6()
    {       
        Credit_Memo__c  cmRec  = new Credit_Memo__c();
        cmRec.API_Status__c = 'Requested';
        cmRec.CreditMemo_Status__c='Todo';
        cmRec.API_Message__c = '';
        cmRec.CreditMemo__c = '';
        insert cmRec;
        
        Test.startTest();
        String jsonMsg6 = '{"ClientRequestHandle":"8bd2ee6c-ab07-4793-8078-56e338614025","RequestID":"CREDITMEMO-1234567890","Status":"3","Error":[],"Data":[{"Status":"2","CreditMemoRef":"'+ cmRec.Name +'","CreditMemoNo":"C202108014","Error":[],"Warning":[]}]}';
        RestRequest req = new RestRequest();
        req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
        req.requestURI = '/renewal/creditmemo/request/status/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonMsg6); // Add JSON Message as a POST
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        Test.setMock(HttpCalloutMock.class, new CreditMemoAPIStatusUpdateMockResponse());
        CreditMemoAPIStatusUpdate.CreditMemoStatus();
        Test.stopTest();
    }
    
    @isTest 
    public static void TestMethod7()
    {       
        Credit_Memo__c  cmRec  = new Credit_Memo__c();
        cmRec.API_Status__c = 'Requested';
        cmRec.CreditMemo_Status__c='Todo';
        cmRec.API_Message__c = '';
        cmRec.CreditMemo__c = '';
        insert cmRec;
        
        Test.startTest();
        String jsonMsg7 = '{"ClientRequestHandle":"8bd2ee6c-ab07-4793-8078-56e338614025","RequestID":"","Status":"3","Error":[],"Data":[{"Status":"2","CreditMemoRef":"'+ cmRec.Name +'","CreditMemoNo":"C202108014","Error":[],"Warning":[]}]}';
        RestRequest req = new RestRequest();
        req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
        req.requestURI = '/renewal/creditmemo/request/status/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonMsg7); // Add JSON Message as a POST
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        Test.setMock(HttpCalloutMock.class, new CreditMemoAPIStatusUpdateMockResponse());
        CreditMemoAPIStatusUpdate.CreditMemoStatus();
        Test.stopTest();
    }

    
}