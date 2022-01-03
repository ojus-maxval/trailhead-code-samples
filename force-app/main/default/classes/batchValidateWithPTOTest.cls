@isTest public class batchValidateWithPTOTest {
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
            
            List<Id > ClList =new List<Id>();
            Clients__c  Cl =new Clients__c ();
            Cl.Client_Name__c = 'Test Status';
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
            Insert Ord;
            OrdSet.add(Ord.id);
            ListOrd.add(Ord.id);
            
            Payment__c PY =new Payment__c ();
            PY.Payment_Amount__c =5800.0;
            Insert PY;
            List<Order_Item__c> listOI = NEW List<Order_Item__c>();
            Order_Item__c OI =new Order_Item__c();
            OI.Order__c =Ord.Id;
            OI.Payment__c =PY.id;
            OI.Payment_Status__c ='Payment Received';
            Insert OI;
            List<String> OIList =new List<String>();
            OIList.add(OI.id);
            
            Invoice__c  Inv =new Invoice__c ();
            Inv.Invoice_Amount__c = 2000.0;
            Inv.API_Status__c =	'Send Update Request';
            Inv.Order__c = Ord.id;
            Inv.Invoice_Currency__c ='USD';
            insert Inv;
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            //SymphonyAuthenticaionHelper sA =new SymphonyAuthenticaionHelper();
            MaxValAPIAuthenticaionHelper.MaxValAPIAuthenticaionHelper();
            batchValidateWithPTO   ObjBatch =new batchValidateWithPTO(OIList);
            Database.executeBatch(ObjBatch, 1);
           
            Test.stopTest();
    }
        @isTest public static void TestMethod2()
        {
                PTO_Credentials__c PTO =new PTO_Credentials__c();
                PTO.Country_Code__c ='US';
                Insert PTO;
                API_Credentials__c ObjApi = new API_Credentials__c();
                ObjApi.Password__c ='Test@1234';
                ObjApi.Username__c ='MaxvalAPI';
                ObjApi.Name = 'MaxvalAPI';
                ObjApi.URL__c ='https://login.salesforce.com/services/oauth2/token';
                insert ObjApi;
                API_Credentials__c ObjAPI2 = new API_Credentials__c();
                ObjAPI2.Password__c ='Test@1234';
                ObjAPI2.Username__c ='MaxvalAPI';
                ObjAPI2.Name = 'PTO Payment Validate';
                ObjAPI2.URL__c ='https://login.salesforce.com/services/oauth2/token';
                insert ObjAPI2;
                
                List<Id > ClList =new List<Id>();
                Clients__c  Cl =new Clients__c ();
                Cl.Client_Name__c = 'Sample';
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
                Ord.Validation_Request_Status__c='';
                Ord.Order_Status__c='Order Placed';
                Insert Ord;
                OrdSet.add(Ord.id);
                ListOrd.add(Ord.id);
                
                Payment__c PY =new Payment__c ();
                PY.Payment_Amount__c =5800.0;
                Insert PY;
                List<Order_Item__c> listOI = NEW List<Order_Item__c>();
                Order_Item__c OI =new Order_Item__c();
                OI.Order__c =Ord.Id;
                OI.Payment__c =PY.id;
                OI.Payment_Status__c ='Payment Received';
                Insert OI;
                List<String> OIList =new List<String>();
                OIList.add(OI.id);
                
                Test.startTest();
                Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
                MaxValAPIAuthenticaionHelper.MaxValAPIAuthenticaionHelper();
                batchValidateWithPTO ObjBatch =new batchValidateWithPTO();
                Database.executeBatch(ObjBatch, 1);
               
                Test.stopTest();
        }
         @isTest public static void TestMethod3()
        {
                PTO_Credentials__c PTO =new PTO_Credentials__c();
                PTO.Country_Code__c ='US';
                Insert PTO;
                List<Id > ClList =new List<Id>();
                Clients__c  Cl =new Clients__c ();
                Cl.Client_Name__c = 'Sample1';
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
                Ord.Validation_Request_Status__c='';
                Ord.Order_Status__c='Order Placed';
                Insert Ord;
                OrdSet.add(Ord.id);
                ListOrd.add(Ord.id);
                
                Payment__c PY =new Payment__c ();
                PY.Payment_Amount__c =5800.0;
                Insert PY;
                List<Order_Item__c> listOI = NEW List<Order_Item__c>();
                Order_Item__c OI =new Order_Item__c();
                OI.Order__c =Ord.Id;
                OI.Payment__c =PY.id;
                OI.Payment_Status__c ='Payment Received';
                Insert OI;
                List<String> OIList =new List<String>();
                OIList.add(OI.id);
                
                Test.startTest();
                Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
                MaxValAPIAuthenticaionHelper.MaxValAPIAuthenticaionHelper();
                batchValidateWithPTO ObjBatch =new batchValidateWithPTO();
                Database.executeBatch(ObjBatch, 1);
                Test.stopTest();
        }
    }