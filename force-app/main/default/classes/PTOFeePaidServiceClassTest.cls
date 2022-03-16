@istest public class PTOFeePaidServiceClassTest {
@isTest public static void TestMethod1()
{
    API_Credentials__c cre=new API_Credentials__c();
        cre.name='PTO Payment Validate';
        cre.Username__c='test';
        cre.URL__c='https://google.com';
        cre.Password__c='test';
        insert cre;
        Clients__c objclient =new Clients__c();
        objclient.Name='QCOMM';
        Insert objclient ;
        order__c Objorder = new order__c();
        Objorder.Client__c=objclient.id;
        Insert Objorder;
        Order_Item__c Objorderitem = new Order_Item__c();
        Objorderitem.order__c=Objorder.id; 
        Objorderitem.Jurisdiction__c='US';
        //Objorderitem.Suggested_Open_Date_To_Pay__c=system.today()-1; 
        Objorderitem.Suggested_Close_Date_To_Pay__c=system.today()-1; 
        Objorderitem.Payment_Status__c='Payment Received'; 
        Objorderitem.Paid_Status__c=null;
        Objorderitem.Renewal_Instruction__c='Renew';
    Objorderitem.Patent_No__c='US232434';
    Objorderitem.Application_No__c ='US1233234';
        Objorderitem.Application_Date__c =System.today();
	    Objorderitem.PTO_Validation_Request_ID__c ='28c30658-9c8d-4c43-8135-4afc2e649d6f';
        Insert Objorderitem;
    
        Test.startTest();
        RestRequest req =new RestRequest();
        RestResponse res = RestContext.response;
        //User_Auth_Details__c ObjAOql =[select name from User_Auth_Details__c limit 1];
        req.requestURI = '/services/apexrest/pto/payment/validate/status/';  //Request URL
        req.httpMethod = 'PUT';//HTTP Request Type
        RestContext.request = req;
        String JSONMsg ='{"ClientRequestHandle":"d0cb82fc-a85a-42ea-b549-27ee7a3d3669","RequestID":"28c30658-9c8d-4c43-8135-4afc2e649d6f","Status":3,"Items":[{"ApplicationNumber":"14513841","PatentNumber":"10565402","Status":"VP","Error":[]},{"ApplicationNumber":"78901234","PatentNumber":"8543217","FeeCode":"1551","Status":"VF","Error":[{"Description":"Amount is missing"}]}],"BillDetails":{"Status":"True","BillNo":"B202011001","Error":[{"Description":"Amount is missing"}]},"Error":[{"Description":"Amount is missing"}],"Warning":[{"Description":"Amount is missing"}]}';
        req.requestBody = Blob.valueof(JSONMsg);
        PTOFeePaidServiceClass.PTOFeePaid();
        Test.stopTest();
}
@isTest public static void TestMethod2()
{
    API_Credentials__c cre=new API_Credentials__c();
        cre.name='PTO Payment Validate';
        cre.Username__c='test';
        cre.URL__c='https://google.com';
        cre.Password__c='test';
        insert cre;
        Clients__c objclient =new Clients__c();
        objclient.Name='QCOMM';
        Insert objclient ;
        order__c Objorder = new order__c();
        Objorder.Client__c=objclient.id;
        Insert Objorder;
     	List<Order_Item__c> Objorderitem = new List<Order_Item__c>{new Order_Item__c(order__c=Objorder.id,Jurisdiction__c='US',Suggested_Close_Date_To_Pay__c=system.today()-1,Payment_Status__c='Payment Received',Paid_Status__c=null,Renewal_Instruction__c='Renew',Patent_No__c='US232434',Application_No__c ='US1233234',Application_Date__c =System.today(),PTO_Validation_Request_ID__c ='PTO-21545455221445551'),
            new Order_Item__c(order__c=Objorder.id,Jurisdiction__c='US',Suggested_Close_Date_To_Pay__c=system.today()-1,Payment_Status__c='Payment Received',Paid_Status__c=null,Renewal_Instruction__c='Renew',Patent_No__c='US8543217',Application_No__c ='US78901234',Application_Date__c =System.today(),PTO_Validation_Request_ID__c ='PTO-21545455221445551'),
            new Order_Item__c(order__c=Objorder.id,Jurisdiction__c='US',Suggested_Close_Date_To_Pay__c=system.today()-1,Payment_Status__c='Payment Received',Paid_Status__c=null,Renewal_Instruction__c='Renew',Patent_No__c='US1233234',Application_No__c ='US1233234',Application_Date__c =System.today(),PTO_Validation_Request_ID__c ='PTO-21545455221445551')};
        INSERT Objorderitem;
    
        Test.startTest();
        RestRequest req =new RestRequest();
        RestResponse res = RestContext.response;
        req.requestURI = '/services/apexrest/pto/payment/validate/status/';  //Request URL
        req.httpMethod = 'PUT';//HTTP Request Type
        RestContext.request = req;
        String JSONMsg ='{"ClientRequestHandle":"d0cb82fc-a85a-42ea-b549-27ee7a3d3669","RequestID":"PTO-21545455221445551","Status":3,"Items":[{"ApplicationNumber":"1233234","PatentNumber":"232434","Status":"VP","Error":[]},{"ApplicationNumber":"1233230","PatentNumber":"1233234","Status":"VP","Error":[]},{"ApplicationNumber":"78901234","PatentNumber":"8543217","FeeCode":"1551","Status":"VF","Error":[{"Description":"Amount is missing"}]}],"BillDetails":{"Status":"True","BillNo":"B202011001","Error":[{"Description":"Amount is missing"}]},"Error":[{"Description":"Amount is missing"}],"Warning":[{"Description":"Amount is missing"}]}';
        req.requestBody = Blob.valueof(JSONMsg);
        PTOFeePaidServiceClass.PTOFeePaid();
        Test.stopTest();
}
@isTest public static void TestMethod3()
{
    API_Credentials__c cre=new API_Credentials__c();
        cre.name='PTO Payment Validate';
        cre.Username__c='test';
        cre.URL__c='https://google.com';
        cre.Password__c='test';
        insert cre;
        Clients__c objclient =new Clients__c();
        objclient.Name='QCOMM';
        Insert objclient ;
        order__c Objorder = new order__c();
        Objorder.Client__c=objclient.id;
        Insert Objorder;
     	List<Order_Item__c> Objorderitem = new List<Order_Item__c>{new Order_Item__c(order__c=Objorder.id,Jurisdiction__c='US',Suggested_Close_Date_To_Pay__c=system.today()-1,Payment_Status__c='Payment Received',Paid_Status__c=null,Renewal_Instruction__c='Renew',Patent_No__c='US232434',Application_No__c ='US1233234',Application_Date__c =System.today(),PTO_Validation_Request_ID__c ='PTO-21545455221445551'),
            new Order_Item__c(order__c=Objorder.id,Jurisdiction__c='US',Suggested_Close_Date_To_Pay__c=system.today()-1,Payment_Status__c='Payment Received',Paid_Status__c=null,Renewal_Instruction__c='Renew',Patent_No__c='US8543217',Application_No__c ='US78901234',Application_Date__c =System.today(),PTO_Validation_Request_ID__c ='PTO-21545455221445551'),
            new Order_Item__c(order__c=Objorder.id,Jurisdiction__c='US',Suggested_Close_Date_To_Pay__c=system.today()-1,Payment_Status__c='Payment Received',Paid_Status__c=null,Renewal_Instruction__c='Renew',Patent_No__c='US1233234',Application_No__c ='US1233234',Application_Date__c =System.today(),PTO_Validation_Request_ID__c ='PTO-21545455221445551'),
        	new Order_Item__c(order__c=Objorder.id,Jurisdiction__c='US',Suggested_Close_Date_To_Pay__c=system.today()-1,Payment_Status__c='Payment Received',Paid_Status__c=null,Renewal_Instruction__c='Renew',Patent_No__c='US1230234',Application_No__c ='US1234234',Application_Date__c =System.today(),PTO_Validation_Request_ID__c ='PTO-21545455221445551')};
                INSERT Objorderitem;
    
        Test.startTest();
        RestRequest req =new RestRequest();
        RestResponse res = RestContext.response;
        req.requestURI = '/services/apexrest/pto/payment/validate/status/';  //Request URL
        req.httpMethod = 'PUT';//HTTP Request Type
        RestContext.request = req;
        String JSONMsg ='{"ClientRequestHandle":"d0cb82fc-a85a-42ea-b549-27ee7a3d3669","RequestID":"PTO-21545455221445551","Status":3,"Items":[{"ApplicationNumber":"1233230","PatentNumber":"1233234","Status":"VP","Error":[]},{"ApplicationNumber":"7890234","PatentNumber":"853217","FeeCode":"1551","Status":"VF","Error":[{"Description":"Amount is missing"}]}],"BillDetails":{"Status":"True","BillNo":"B202011001","Error":[{"Description":"Amount is missing"}]},"Error":[{"Description":"Amount is missing"}],"Warning":[{"Description":"Amount is missing"}],{"ApplicationNumber":"1234234","PatentNumber":"1230234","Status":"VP","Error":[]},{"ApplicationNumber":"78901234","PatentNumber":"8543217","FeeCode":"1551","Status":"VF","Error":[{"Description":"Amount is missing"}]}],"BillDetails":{"Status":"True","BillNo":"B202011001","Error":[{"Description":"Amount is missing"}]},"Error":[{"Description":"Amount is missing"}],"Warning":[{"Description":"Amount is missing"}}';
        req.requestBody = Blob.valueof(JSONMsg);
        PTOFeePaidServiceClass.PTOFeePaid();
        Test.stopTest();
}
    @isTest public static void TestMethod4()
{
    API_Credentials__c cre=new API_Credentials__c();
        cre.name='PTO Payment Validate';
        cre.Username__c='test';
        cre.URL__c='https://google.com';
        cre.Password__c='test';
        insert cre;
        Clients__c objclient =new Clients__c();
        objclient.Name='QCOMM';
        Insert objclient ;
        order__c Objorder = new order__c();
        Objorder.Client__c=objclient.id;
        Insert Objorder;
     	List<Order_Item__c> Objorderitem = new List<Order_Item__c>{new Order_Item__c(order__c=Objorder.id,Jurisdiction__c='US',Suggested_Close_Date_To_Pay__c=system.today()-1,Payment_Status__c='Payment Received',Paid_Status__c=null,Renewal_Instruction__c='Renew',Patent_No__c='US232434',Application_No__c ='US1233234',Application_Date__c =System.today(),PTO_Validation_Request_ID__c ='PTO-21545455221445551'),
            new Order_Item__c(order__c=Objorder.id,Jurisdiction__c='US',Suggested_Close_Date_To_Pay__c=system.today()-1,Payment_Status__c='Payment Received',Paid_Status__c=null,Renewal_Instruction__c='Renew',Patent_No__c='US8543217',Application_No__c ='US7890134',Application_Date__c =System.today(),PTO_Validation_Request_ID__c ='PTO-21545455221445551'),
            new Order_Item__c(order__c=Objorder.id,Jurisdiction__c='US',Suggested_Close_Date_To_Pay__c=system.today()-1,Payment_Status__c='Payment Received',Paid_Status__c=null,Renewal_Instruction__c='Renew',Patent_No__c='US1233234',Application_No__c ='US12334',Application_Date__c =System.today(),PTO_Validation_Request_ID__c ='PTO-21545455221445551'),
        	new Order_Item__c(order__c=Objorder.id,Jurisdiction__c='US',Suggested_Close_Date_To_Pay__c=system.today()-1,Payment_Status__c='Payment Received',Paid_Status__c=null,Renewal_Instruction__c='Renew',Patent_No__c='US1230234',Application_No__c ='US1234',Application_Date__c =System.today(),PTO_Validation_Request_ID__c ='PTO-21545455221445551')};
                INSERT Objorderitem;
    
        Test.startTest();
        RestRequest req =new RestRequest();
        RestResponse res = RestContext.response;
        req.requestURI = '/services/apexrest/pto/payment/validate/status/';  //Request URL
        req.httpMethod = 'PUT';//HTTP Request Type
        RestContext.request = req;
        String JSONMsg ='{"ClientRequestHandle":"d0cb82fc-a85a-42ea-b549-27ee7a3d3669","RequestID":"PTO-2154545522144551","Status":3,"Items":[{"ApplicationNumber":"1233230","PatentNumber":"1233234","Status":"VP","Error":[]},{"ApplicationNumber":"7890234","PatentNumber":"853217","FeeCode":"1551","Status":"VF","Error":[{"Description":"Amount is missing"}]}],"BillDetails":{"Status":"True","BillNo":"B202011001","Error":[{"Description":"Amount is missing"}]},"Error":[{"Description":"Amount is missing"}],"Warning":[{"Description":"Amount is missing"}],{"ApplicationNumber":"1234234","PatentNumber":"1230234","Status":"VP","Error":[]},{"ApplicationNumber":"78901234","PatentNumber":"8543217","FeeCode":"1551","Status":"VF","Error":[{"Description":"Amount is missing"}]}],"BillDetails":{"Status":"True","BillNo":"B202011001","Error":[{"Description":"Amount is missing"}]},"Error":[{"Description":"Amount is missing"}],"Warning":[{"Description":"Amount is missing"}}';
        req.requestBody = Blob.valueof(JSONMsg);
        PTOFeePaidServiceClass.PTOFeePaid();
        Test.stopTest();
}
    @isTest public static void TestMethod5()
{
    	API_Credentials__c cre=new API_Credentials__c();
        cre.name='PTO Payment Validate';
        cre.Username__c='test';
        cre.URL__c='https://google.com';
        cre.Password__c='test';
        insert cre;
        Clients__c objclient =new Clients__c();
        objclient.Name='QCOMM';
        Insert objclient ;
        order__c Objorder = new order__c();
        Objorder.Client__c=objclient.id;
        Insert Objorder;
     	List<Order_Item__c> Objorderitem = new List<Order_Item__c>{new Order_Item__c(order__c=Objorder.id,Jurisdiction__c='US',Suggested_Close_Date_To_Pay__c=system.today()-1,Payment_Status__c='Payment Received',Paid_Status__c=null,Renewal_Instruction__c='Renew',Patent_No__c='US232434',Application_No__c ='US1233234',Application_Date__c =System.today(),PTO_Validation_Request_ID__c ='PTO-21545455221445551'),
            new Order_Item__c(order__c=Objorder.id,Jurisdiction__c='US',Suggested_Close_Date_To_Pay__c=system.today()-1,Payment_Status__c='Payment Received',Paid_Status__c=null,Renewal_Instruction__c='Renew',Patent_No__c='US8543217',Application_No__c ='US7890134',Application_Date__c =System.today(),PTO_Validation_Request_ID__c ='PTO-21545455221445551'),
            new Order_Item__c(order__c=Objorder.id,Jurisdiction__c='US',Suggested_Close_Date_To_Pay__c=system.today()-1,Payment_Status__c='Payment Received',Paid_Status__c=null,Renewal_Instruction__c='Renew',Patent_No__c='US1233234',Application_No__c ='US12334',Application_Date__c =System.today(),PTO_Validation_Request_ID__c ='PTO-21545455221445551'),
        	new Order_Item__c(order__c=Objorder.id,Jurisdiction__c='US',Suggested_Close_Date_To_Pay__c=system.today()-1,Payment_Status__c='Payment Received',Paid_Status__c=null,Renewal_Instruction__c='Renew',Patent_No__c='US1230234',Application_No__c ='US1234',Application_Date__c =System.today(),PTO_Validation_Request_ID__c ='PTO-21545455221445551')};
                INSERT Objorderitem;
        Test.startTest();
        RestRequest req =new RestRequest();
        RestResponse res = RestContext.response;
        req.requestURI = '/services/apexrest/pto/payment/validate/status/';  //Request URL
        req.httpMethod = 'PUT';//HTTP Request Type
        RestContext.request = req;
        String JSONMsg ='{"ClientRequestHandle":null,"RequestID":null,"Status":3,"Items":[{"ApplicationNumber":"1233","PatentNumber":"123334","Status":"VP","Error":""},{"ApplicationNumber":"US7890134","PatentNumber":"US8543217","Status":"VP","Error":""},{"ApplicationNumber":"78234","PatentNumber":"8532","FeeCode":"1551","Status":"VF","Error":[{"Description":"Amount is missing"}]}],"BillDetails":{"Status":"True","BillNo":"B202011001","Error":[{"Description":"Amount is missing"}]},"Error":[{"Description":"Amount is missing"}],"Warning":[{"Description":"Amount is missing"}],{"ApplicationNumber":"1234234","PatentNumber":"1230234","Status":"VP","Error":[]},{"ApplicationNumber":"78901234","PatentNumber":"8543217","FeeCode":"1551","Status":"VF","Error":[{"Description":"Amount is missing"}]}],"BillDetails":{"Status":"True","BillNo":"B202011001","Error":[{"Description":"Amount is missing"}]},"Error":[{"Description":"Amount is missing"}],"Warning":[{"Description":"Amount is missing"}}';
        req.requestBody = Blob.valueof(JSONMsg);
        PTOFeePaidServiceClass.PTOFeePaid();
        Test.stopTest();
}
    @isTest public static void TestMethod6()
{
    API_Credentials__c cre=new API_Credentials__c();
        cre.name='PTO Payment Validate';
        cre.Username__c='test';
        cre.URL__c='https://google.com';
        cre.Password__c='test';
        insert cre;
        Clients__c objclient =new Clients__c();
        objclient.Name='QCOMM';
        Insert objclient ;
        order__c Objorder = new order__c();
        Objorder.Client__c=objclient.id;
        Insert Objorder;
     	List<Order_Item__c> Objorderitem = new List<Order_Item__c>{new Order_Item__c(order__c=Objorder.id,Jurisdiction__c='US',Suggested_Close_Date_To_Pay__c=system.today()-1,Payment_Status__c='Payment Received',Paid_Status__c=null,Renewal_Instruction__c='Renew',Patent_No__c='US232434A',Application_No__c ='US1233234A',Application_Date__c =System.today(),PTO_Validation_Request_ID__c ='PTO-21545455221445551'),
            new Order_Item__c(order__c=Objorder.id,Jurisdiction__c='US',Suggested_Close_Date_To_Pay__c=system.today()-1,Payment_Status__c='Payment Received',Paid_Status__c=null,Renewal_Instruction__c='Renew',Patent_No__c='US8543217A2',Application_No__c ='US78901234A2',Application_Date__c =System.today(),PTO_Validation_Request_ID__c ='PTO-21545455221445551'),
            new Order_Item__c(order__c=Objorder.id,Jurisdiction__c='US',Suggested_Close_Date_To_Pay__c=system.today()-1,Payment_Status__c='Payment Received',Paid_Status__c=null,Renewal_Instruction__c='Renew',Patent_No__c='US1233234',Application_No__c ='US1233234',Application_Date__c =System.today(),PTO_Validation_Request_ID__c ='PTO-21545455221445551')};
        INSERT Objorderitem;
    
        Test.startTest();
        RestRequest req =new RestRequest();
        RestResponse res = RestContext.response;
        req.requestURI = '/services/apexrest/pto/payment/validate/status/';  //Request URL
        req.httpMethod = 'PUT';//HTTP Request Type
        RestContext.request = req;
        String JSONMsg ='{"ClientRequestHandle":"d0cb82fc-a85a-42ea-b549-27ee7a3d3669","RequestID":"PTO-21545455221445551","Status":3,"Items":[{"ApplicationNumber":"US1233234A","PatentNumber":"US232434A","Status":"VP","Error":[]},{"ApplicationNumber":"1233230","PatentNumber":"1233234","Status":"VP","Error":[]},{"ApplicationNumber":"US78901234A2","PatentNumber":"US8543217A2","FeeCode":"1551","Status":"VF","Error":[{"Description":"Amount is missing"}]}],"BillDetails":{"Status":"True","BillNo":"B202011001","Error":[{"Description":"Amount is missing"}]},"Error":[{"Description":"Amount is missing"}],"Warning":[{"Description":"Amount is missing"}]}';
        req.requestBody = Blob.valueof(JSONMsg);
        PTOFeePaidServiceClass.PTOFeePaid();
        Test.stopTest();
}
    @isTest public static void TestMethod7()
{
    API_Credentials__c cre=new API_Credentials__c();
        cre.name='PTO Payment Validate';
        cre.Username__c='test';
        cre.URL__c='https://google.com';
        cre.Password__c='test';
        insert cre;
        Clients__c objclient =new Clients__c();
        objclient.Name='QCOMM';
        Insert objclient ;
        order__c Objorder = new order__c();
        Objorder.Client__c=objclient.id;
        Insert Objorder;
     	List<Order_Item__c> Objorderitem = new List<Order_Item__c>{new Order_Item__c(order__c=Objorder.id,Jurisdiction__c='US',Suggested_Close_Date_To_Pay__c=system.today()-1,Payment_Status__c='Payment Received',Paid_Status__c=null,Renewal_Instruction__c='Renew',Patent_No__c='US232434A',Application_No__c ='US1233234A',Application_Date__c =System.today(),PTO_Validation_Request_ID__c ='PTO-2154545522144555'),
            new Order_Item__c(order__c=Objorder.id,Jurisdiction__c='US',Suggested_Close_Date_To_Pay__c=system.today()-1,Payment_Status__c='Payment Received',Paid_Status__c=null,Renewal_Instruction__c='Renew',Patent_No__c='US8543217A2',Application_No__c ='US78901234A2',Application_Date__c =System.today(),PTO_Validation_Request_ID__c ='PTO-2154545522144555'),
            new Order_Item__c(order__c=Objorder.id,Jurisdiction__c='US',Suggested_Close_Date_To_Pay__c=system.today()-1,Payment_Status__c='Payment Received',Paid_Status__c=null,Renewal_Instruction__c='Renew',Patent_No__c='US1233234',Application_No__c ='US1233234',Application_Date__c =System.today(),PTO_Validation_Request_ID__c ='PTO-2154545522144555')};
        INSERT Objorderitem;
    
        Test.startTest();
        RestRequest req =new RestRequest();
        RestResponse res = RestContext.response;
        req.requestURI = '/services/apexrest/pto/payment/validate/status/';  //Request URL
        req.httpMethod = 'PUT';//HTTP Request Type
        RestContext.request = req;
    String JSONMsg ='{"ClientRequestHandle":"d0cb82fc-a85a-42ea-b549-27ee7a3d3669","RequestID":"PTO-21545455221445551","Status":3,"Items":[{"ApplicationNumber":"US1233234A","PatentNumber":"US232434A","Status":"VP","Error":[]},{"ApplicationNumber":"1233230","PatentNumber":"1233234","Status":"VP","Error":[]},{"ApplicationNumber":"US78901234A2","PatentNumber":"US8543217A2","FeeCode":"1551","Status":"VF","Error":[{"Description":"Amount is missing"}]}],"BillDetails":{"Status":"True","BillNo":"B202011001","Error":[{"Description":"Amount is missing"},{"Description":"Code is missing"}]},"Error":[{"Description":"Amount is missing"}],"Warning":[{"Description":"Amount is missing"}]}';
        req.requestBody = Blob.valueof(JSONMsg);
        PTOFeePaidServiceClass.PTOFeePaid();
        Test.stopTest();
}
    @isTest public static void TestMethod8()
	{
		Test.startTest();
        RestRequest req =new RestRequest();
        RestResponse res = RestContext.response;
        req.requestURI = '/services/apexrest/pto/payment/validate/status/';  //Request URL
        req.httpMethod = 'PUT';//HTTP Request Type
        RestContext.request = req;
        String JSONMsg ='{"ClientRequestHandle":"","RequestID":"","Status":3,"Items":[{"ApplicationNumber":"US1233234A","PatentNumber":"US232434A","Status":"VP","Error":[]},{"ApplicationNumber":"1233230","PatentNumber":"1233234","Status":"VP","Error":[]},{"ApplicationNumber":"US78901234A2","PatentNumber":"US8543217A2","FeeCode":"1551","Status":"VF","Error":[{"Description":"Amount is missing"}]}],"BillDetails":{"Status":"True","BillNo":"B202011001","Error":[{"Description":"Amount is missing"}]},"Error":[{"Description":"Amount is missing"}],"Warning":[{"Description":"Amount is missing"}]}';
        req.requestBody = Blob.valueof(JSONMsg);
        PTOFeePaidServiceClass.PTOFeePaid();
        Test.stopTest();    
	}
    @isTest public static void TestMethod9()
	{
		Test.startTest();
        RestRequest req =new RestRequest();
        RestResponse res = RestContext.response;
        req.requestURI = '/services/apexrest/pto/payment/validate/status/';  //Request URL
        req.httpMethod = 'PUT';//HTTP Request Type
        RestContext.request = req;
        String JSONMsg ='{"ClientRequestHandle":"sample","RequestID":"","Status":3,"Items":[{"ApplicationNumber":"US1233234A","PatentNumber":"US232434A","Status":"VP","Error":[]},{"ApplicationNumber":"1233230","PatentNumber":"1233234","Status":"VP","Error":[]},{"ApplicationNumber":"US78901234A2","PatentNumber":"US8543217A2","FeeCode":"1551","Status":"VF","Error":[{"Description":"Amount is missing"}]}],"BillDetails":{"Status":"True","BillNo":"B202011001","Error":[{"Description":"Amount is missing"}]},"Error":[{"Description":"Amount is missing"}],"Warning":[{"Description":"Amount is missing"}]}';
        req.requestBody = Blob.valueof(JSONMsg);
        PTOFeePaidServiceClass.PTOFeePaid();
        Test.stopTest();    
	}
    @isTest public static void TestMethod10()
{
    API_Credentials__c cre=new API_Credentials__c();
        cre.name='PTO Payment Validate';
        cre.Username__c='test';
        cre.URL__c='https://google.com';
        cre.Password__c='test';
        insert cre;
        Clients__c objclient =new Clients__c();
        objclient.Name='Dropbox';
        Insert objclient ;
        order__c Objorder = new order__c();
        Objorder.Client__c=objclient.id;
        Insert Objorder;
        Order_Item__c Objorderitem1 = new Order_Item__c();
        Objorderitem1.order__c=Objorder.id; 
        Objorderitem1.Jurisdiction__c='EP';
        //Objorderitem.Suggested_Open_Date_To_Pay__c=system.today()-1; 
        Objorderitem1.Suggested_Close_Date_To_Pay__c=system.today()-1; 
        Objorderitem1.Payment_Status__c='Payment Received'; 
        Objorderitem1.Paid_Status__c=null;
        Objorderitem1.Renewal_Instruction__c='Renew';
    Objorderitem1.Patent_No__c='US232434';
    Objorderitem1.Application_No__c ='US1233234';
        Objorderitem1.Application_Date__c =System.today();
	    Objorderitem1.PTO_Validation_Request_ID__c ='28c30658-9c8d-4c43-8135-4afc2e649d6f';
    	Objorderitem1.PTO_Validation_Status__c = 'Validation Passed';
        Insert Objorderitem1;
        Test.startTest();
        RestRequest req =new RestRequest();
        RestResponse res = RestContext.response;
        //User_Auth_Details__c ObjAOql =[select name from User_Auth_Details__c limit 1];
        req.requestURI = '/services/apexrest/pto/payment/validate/status/';  //Request URL
        req.httpMethod = 'PUT';//HTTP Request Type
        RestContext.request = req;
        String JSONMsg ='{"ClientRequestHandle":"d0cb82fc-a85a-42ea-b549-27ee7a3d3669","RequestID":"28c30658-9c8d-4c43-8135-4afc2e649d6f","Status":3,"Items":[{"ApplicationNumber":"14513841","PatentNumber":"10565402","Status":"VP","Error":[]},{"ApplicationNumber":"78901234","PatentNumber":"8543217","FeeCode":"1551","Status":"VF","Error":[{"Description":"Amount is missing"}]}],"BillDetails":{"Status":"True","BillNo":"B202011001","Error":[{"Description":"Amount is missing"}]},"Error":[{"Description":"Amount is missing"}],"Warning":[{"Description":"Amount is missing"}]}';
        req.requestBody = Blob.valueof(JSONMsg);
        PTOFeePaidServiceClass.PTOFeePaid();
        Test.stopTest();
}
    @isTest public static void TestMethod11()
{
    API_Credentials__c cre=new API_Credentials__c();
        cre.name='PTO Payment Validate';
        cre.Username__c='test';
        cre.URL__c='https://google.com';
        cre.Password__c='test';
        insert cre;
        Clients__c objclient =new Clients__c();
        objclient.Name='QCOMM';
        Insert objclient ;
        order__c Objorder = new order__c();
        Objorder.Client__c=objclient.id;
        Insert Objorder;
        Order_Item__c Objorderitem = new Order_Item__c();
        Objorderitem.order__c=Objorder.id; 
        Objorderitem.Jurisdiction__c='US';
        //Objorderitem.Suggested_Open_Date_To_Pay__c=system.today()-1; 
        Objorderitem.Suggested_Close_Date_To_Pay__c=system.today()-1; 
        Objorderitem.Payment_Status__c='Payment Received'; 
        Objorderitem.Paid_Status__c=null;
        Objorderitem.Renewal_Instruction__c='Renew';
    Objorderitem.Patent_No__c='US232434';
    Objorderitem.Application_No__c ='US1233234';
        Objorderitem.Application_Date__c =System.today();
	    Objorderitem.PTO_Validation_Request_ID__c ='28c30658-9c8d-4c43-8135-4afc2e649d6f';
        Insert Objorderitem;
    
        Test.startTest();
        RestRequest req =new RestRequest();
        RestResponse res = RestContext.response;
        //User_Auth_Details__c ObjAOql =[select name from User_Auth_Details__c limit 1];
        req.requestURI = '/services/apexrest/pto/payment/validate/status/';  //Request URL
        req.httpMethod = 'PUT';//HTTP Request Type
        RestContext.request = req;
    	String JSONMsg ='{"ClientRequestHandle":"d0cb82fc-a85a-42ea-b549-27ee7a3d3669","RequestID":"28c30658-9c8d-4c43-8135-4afc2e649d6f","Status":3,"Items":[{"ApplicationNumber":"14513841","PatentNumber":"10565402","FeeCode":"1551","Status":"VP","Error":[]},{"ApplicationNumber":"14513841","PatentNumber":"10565402","FeeCode":"1551","Status":"VP","Error":[]}]}';
        req.requestBody = Blob.valueof(JSONMsg);
        PTOFeePaidServiceClass.PTOFeePaid();
        Test.stopTest();
}
    @isTest public static void TestMethod12()
{
    API_Credentials__c cre=new API_Credentials__c();
        cre.name='PTO Payment Validate';
        cre.Username__c='test';
        cre.URL__c='https://google.com';
        cre.Password__c='test';
        insert cre;
        Clients__c objclient =new Clients__c();
        objclient.Name='Dropbox';
        Insert objclient ;
        order__c Objorder = new order__c();
        Objorder.Client__c=objclient.id;
        Insert Objorder;
        Order_Item__c Objorderitem1 = new Order_Item__c();
        Objorderitem1.order__c=Objorder.id; 
        Objorderitem1.Jurisdiction__c='US';
        //Objorderitem.Suggested_Open_Date_To_Pay__c=system.today()-1; 
        Objorderitem1.Suggested_Close_Date_To_Pay__c=system.today()-1; 
        Objorderitem1.Payment_Status__c='Payment Received'; 
        Objorderitem1.Paid_Status__c=null;
        Objorderitem1.Renewal_Instruction__c='Renew';
    Objorderitem1.Patent_No__c='US232434';
    Objorderitem1.Application_No__c ='1234S5';
        Objorderitem1.Application_Date__c =System.today();
	    Objorderitem1.PTO_Validation_Request_ID__c ='28c30658-9c8d-4c43-8135-4afc2e649d6f';
        Insert Objorderitem1;
        Test.startTest();
        RestRequest req =new RestRequest();
        RestResponse res = RestContext.response;
        //User_Auth_Details__c ObjAOql =[select name from User_Auth_Details__c limit 1];
        req.requestURI = '/services/apexrest/pto/payment/validate/status/';  //Request URL
        req.httpMethod = 'PUT';//HTTP Request Type
        RestContext.request = req;
        String JSONMsg ='{"ClientRequestHandle":"d0cb82fc-a85a-42ea-b549-27ee7a3d3669","RequestID":"28c30658-9c8d-4c43-8135-4afc2e649d6f","Status":3,"Items":[{"ApplicationNumber":"14513841","PatentNumber":"10565402","Status":"VP","Error":[]},{"ApplicationNumber":"78901234","PatentNumber":"8543217","FeeCode":"1551","Status":"VF","Error":[{"Description":"Amount is missing"}]}],"BillDetails":{"Status":"True","BillNo":"B202011001","Error":[{"Description":"Amount is missing"}]},"Error":[{"Description":"Amount is missing"}],"Warning":[{"Description":"Amount is missing"}]}';
        req.requestBody = Blob.valueof(JSONMsg);
        PTOFeePaidServiceClass.PTOFeePaid();
        Test.stopTest();
}
    @isTest public static void TestMethod13()
{
    
        Test.startTest();
        
    	PTOFeePaidServiceClass.responcebody rb = new PTOFeePaidServiceClass.responcebody();
    	rb.MVRefId = 'ABC123';
    	rb.Status = 'VP';
    
    	PTOFeePaidServiceClass.requestbody reqb = new PTOFeePaidServiceClass.requestbody();
    	reqb.Status = 3;
    	reqb.Error = null;
    	reqb.Warning = null;
    
    	PTOFeePaidServiceClass.requestbodyItem rbi = new PTOFeePaidServiceClass.requestbodyItem();
    	rbi.Status = 'VF';
    	rbi.Error = null;
    
    	PTOFeePaidServiceClass.errorbody eb = new PTOFeePaidServiceClass.errorbody();
    	eb.Description = 'Empty';
    
    	PTOFeePaidServiceClass.error er = new PTOFeePaidServiceClass.error();
    	er.Description = 'Empty';
    	er.Staus = 'Error123';
           
    	PTOFeePaidServiceClass.warning warn = new PTOFeePaidServiceClass.warning();
    	warn.Description = 'Empty';
    
    	PTOFeePaidServiceClass.reqBillDetails rbd = new PTOFeePaidServiceClass.reqBillDetails();
    	rbd.Status = 'VF';
    	rbd.BillNo = 'ABC123';
    	rbd.Warning = null;
    
        Test.stopTest();
}
}