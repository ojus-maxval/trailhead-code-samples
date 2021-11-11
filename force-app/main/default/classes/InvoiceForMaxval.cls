@RestResource(urlMapping = '/renewal/invoice/*')
global with sharing class InvoiceForMaxval 
{
    @HttpGet
    global static void doget() 
    {
        Boolean status =True;
        Boolean CCInfoIsAvailable = false;
        Boolean AccIncomeIsAvailable = false;
        Boolean QBCustomerIsAvailable = false;
        String StrPONum;
        String DefaultInvoiceType = 'Annuity Payments for';
        string strAuditTrail = '';
        try
        {
            //RestRequest req = RestContext.request;
            // RestResponse res = RestContext.response;
            string InvItemDetails='';
            //set<id> ObjOrderIds = new set<id>();
            // string Inv= RestContext.request.params.get('InvoiceRef'); 
            //string q1 = 'SELECT Name,Id,order_C,Invoice_Currencyc,Po_Numberc,Invoice_Items_c,Client__r.name,Order__r.name,Invoice_Amount_c FROM Invoice_c WHERE name =:Inv limit 1'; 
            // Invoice__c ObjInvoiceList[0] = Database.query(q1); 
            String UniqueName = '';
            String strLeadSource = '';
            RestRequest restReq = RestContext.request;
            RestResponse restRes = RestContext.response;
            // Reading parametrs from URL
            system.debug('Req URL: '+restReq.requestURI);
            string req =  restReq.requestURI;
            integer li= req.lastIndexOf('/details');
            string s = req.substring(0, li);
            UniqueName =s.substring(s.lastIndexOf('/') + 1);
            system.debug('1 : '+UniqueName);
            strLeadSource = restReq.requestURI.substring(restReq.requestURI.lastIndexOf('&') + 1);
            // string Inv= RestContext.request.params.get('UniqueName '); 
            
            string q1 = 'SELECT Name,Id,Is_Variance__c,Invoice_Date__c,order__c,Invoice_Type_Name__c,Order__r.Payment_Status__c,Order__r.Client__r.QB_Customer__c,Order__r.Client__r.QB_Customer__r.Currency_Reference__c,Order__r.Client__r.QB_Customer__r.Name,Order__r.Client__r.QB_Customer__r.QB_Customer_Id__c,Invoice_Currency__c,order__r.PO_Number__c,Order__r.Client__r.name,Order__r.Client__r.Billing_Address__c,Order__r.name,Invoice_Amount__c,Order__r.Late_Fee__c,order__r.Rush_Fee__c,Invoice_Type__c FROM Invoice__c WHERE name =:UniqueName limit 1'; 
            list<Invoice__c> ObjInvoiceList = Database.query(q1);
            
            //list<Client_Contact_Info__c> ListOfCCI =[SELECT Id,Name,Address_Type__c FROM Client_Contact_Info__c WHERE Client__c = : ObjInvoiceList[0].Order__r.Client__c AND Is_Default__c =TRUE AND Address_Type__c = 'Billing Address' LIMIT 1];
                list<QB_Account__c> ListOfIA =[SELECT Id,Name,QB_Account_Id__c, Client__c FROM QB_Account__c WHERE Client__c = : ObjInvoiceList[0].Order__r.Client__c  AND Account_Type__c IN ('Income', 'Other Current Liability') LIMIT 1];   
                list<QB_Customer__c> CustomerName =[SELECT Id,Name,QB_Customer_Id__c, Client__c FROM QB_Customer__c WHERE Client__c = : ObjInvoiceList[0].Order__r.Client__c AND Currency_Reference__c=:ObjInvoiceList[0].Invoice_Currency__c  LIMIT 1];               //boolean values to handle index out of bound exception in ternary syntax
            /*if(ListOfCCI.size() > 0)
            {
                CCInfoIsAvailable =true;
                System.debug('CCInfoIsAvailable????'+CCInfoIsAvailable);
            }
            if(CustomerName.size() > 0)
            {
                QBCustomerIsAvailable=true;
            }*/
                if(ListOfIA.size() > 0)
                {
                    AccIncomeIsAvailable = true; 
                }
                if(ObjInvoiceList[0].Invoice_Type_Name__c != null)
                {
                    if(ObjInvoiceList[0].Invoice_Type_Name__c.endsWith('_'))
                    {
                        DefaultInvoiceType ='Business Unit: Onset Medical/Teruma Medical Corporation  -  Annuity Payments -';
                    }
                    else if(ObjInvoiceList[0].Invoice_Type_Name__c.startsWith('_')){
                        DefaultInvoiceType ='USD currency patents - Annuity Payments -';
                    }
                }
            //Query modified by Sneha B on 25/05/2021
            if(ObjInvoiceList.size()>0)
            {
                //list<string> OrderItem=(ObjInvoiceList[0].Invoice_Items__c).split(',');
                //system.debug('OrderItem'+OrderItem);
                list<Order_Item__c > ListOfOItems=
                    [select Due_Date__c
                     ,Term_Name__c
                     ,id,name,Invoice_Amount_When_Pay__c
                     ,Patent_No__c
                     ,Application_No__c 
                     ,Publication_No__c
                     ,Docket_No__c
                     ,Jurisdiction__c
                     ,Renewal_Instruction__c
                     ,Billing_Amount__c
                     //,PoNumber__c
                     //,Order_r.Late_Fee_c
                     // ,Order_r.Rush_Fee_c
                     ,Filing_Receipt_File_Id__c
                     ,Billing_Currency_Unit_Rate_When_Pay__c
                     ,Invoice__c
                     ,Payment_Status__c
                     //,Order_r.Currency_c
                     FROM Order_Item__c WHERE Invoice__c=:ObjInvoiceList[0].id and Payment_Status__c !=: 'Cancelled' and Cancellation_Approval__c !=: 'Approved'];
                	
                
                /*  Boolean BU=false;
                Boolean InvoiceCurrency=false;
                String CustomerCurrency;
                list<Invoice_Type_Configuration__c> ListOfClientConfig = [SELECT Id, Invoice_Currency__c, Client__c, Business_Unit__c,QB_Customer__r.Currency_Reference__c, Countries__c, QB_Customer__c FROM Invoice_Type_Configuration__c Where Client__c=:ObjInvoiceList[0].Order__r.Client__c];
                for(Invoice_Type_Configuration__c ConfigObj: ListOfClientConfig)
                {
                if(BU ==false)
                {
                if(ConfigObj.Business_Unit__c != '')
                {
                CustomerCurrency =ConfigObj.QB_Customer__r.Currency_Reference__c;
                BU= true;
                }
                }
                if(InvoiceCurrency == false && BU ==false)
                { 
                for(Order_Item__c orderItem: ListOfOItems)
                {
                
                if(ConfigObj.Countries__c.Contains(orderItem.Jurisdiction__c))
                {
                CustomerCurrency =ConfigObj.QB_Customer__r.Currency_Reference__c;
                InvoiceCurrency= true;
                }
                }
                }
                else if(InvoiceCurrency == false && ConfigObj.Business_Unit__c != '')
                {
                CustomerCurrency =ConfigObj.QB_Customer__r.Currency_Reference__c;
                }
                
                }
                System.debug('CustomerCurrency>>>'+ CustomerCurrency);*/
                
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject();
                gen.writebooleanfield('Status', True);
                gen.writeFieldName('Error');
                gen.writeStartArray();
                gen.writeEndArray();
                gen.writeFieldName('Data');
                gen.writeStartObject();
                gen.writeFieldName('Header');
                //Added lines for additional changes - ticket no.543 by juveria[12/02/2020]
                gen.writeStartObject();
                gen.writeFieldName('AccountTo');
                gen.writeStartObject();
                gen.writeStringField('AccountToRef',AccIncomeIsAvailable ==true?ListOfIA[0].QB_Account_Id__c:'');
                gen.writeEndObject();
                
                gen.writeFieldName('BillTo');
                gen.writeStartObject();
                // gen.writeStringField('BillToRef',ObjInvoiceList[0].Order__r.Client__r.Billing_Address__c!=null?ObjInvoiceList[0].Order__r.Client__r.Billing_Address__c:'');                     
                 gen.writeStringField('BillToRef',CustomerName[0].QB_Customer_Id__c !=null?CustomerName[0].QB_Customer_Id__c:'');	
                //gen.writeStringField('BillToRef',ObjInvoiceList[0].Order__r.Client__r.QB_Customer__r.QB_Customer_Id__c !=null?ObjInvoiceList[0].Order__r.Client__r.QB_Customer__r.QB_Customer_Id__c:'');	
                //gen.writeStringField('CompanyName',ObjInvoiceList[0].Order__r.Client__r.QB_Customer__r.Name !=null?ObjInvoiceList[0].Order__r.Client__r.QB_Customer__r.Name:'');	
                gen.writeStringField('CompanyName',CustomerName[0].Name !=null?CustomerName[0].Name:'');
                gen.writeEndObject();
                //gen.writeStringField('Message','');        
                //gen.writeEndObject();
                
                //gen.writeStringField('BillToRef',ObjInvoiceList[0].Order__r.Client__r.Billing_Address__c!=null?ObjInvoiceList[0].Order__r.Client__r.Billing_Address__c:'');                     
                
                gen.writeStringField('SendEmail','SENDLATER');
                gen.writeStringField('Message',''); 
                gen.writeEndObject();
                
                gen.writeFieldName('Details');
                gen.writeStartObject();
                gen.writeStringField('PONumber',ObjInvoiceList[0].order__r.PO_Number__c!=null?ObjInvoiceList[0].order__r.PO_Number__c:'');
                gen.writeStringField('OrderNum',ObjInvoiceList[0].Order__r.name);
                
                decimal TotalAmount=0;
                string jurisdiction = '';
                if(ObjInvoiceList[0].Is_Variance__c){
                    gen.writeFieldName('LineItems');
                    gen.writeStartArray();
                    if(ObjInvoiceList[0].order__r.PO_Number__c !=null)
                    {
                        StrPONum ='PO- '+ObjInvoiceList[0].order__r.PO_Number__c+' under';
                    }
                    else{
                         StrPONum ='PO- NA under';
                    }
                    string strItem;
                    TotalAmount=TotalAmount+ ObjInvoiceList[0].Order__r.Late_Fee__c;
                    TotalAmount=TotalAmount+ ObjInvoiceList[0].Order__r.Rush_Fee__c ;                    
                    string strItemName='AP Deposits AP-'+ObjInvoiceList[0].Order__r.Client__r.name;    
                    Date invoiceDate = date.newinstance(ObjInvoiceList[0].Invoice_Date__c.year(), ObjInvoiceList[0].Invoice_Date__c.month(), ObjInvoiceList[0].Invoice_Date__c.day());
                    string patentId = '-';
                    strAuditTrail+='outside for';
                	for(Order_Item__c orderItem: ListOfOItems){
                        strAuditTrail+='inside for';
                    	gen.writeStartObject();
                        gen.writeStringField('ItemName', strItemName);  
                    	jurisdiction = orderItem.Jurisdiction__c!=null?orderItem.Jurisdiction__c:'';
                        patentId = '-';
                        patentId = orderItem.Patent_No__c!=null && orderItem.Patent_No__c!='-' ?orderItem.Patent_No__c:orderItem.Publication_No__c!=null && orderItem.Publication_No__c!='-' ?orderItem.Publication_No__c:'';
                        if(patentId!='-' && !patentId.startsWith(jurisdiction))
                            patentId = jurisdiction + patentId;                        
                        gen.writeStringField('Description','Currency fluctuation for Patent# - '+ patentId +' Order# - '+ ObjInvoiceList[0].Order__r.name +' Invoice date - '+ string.valueOf(invoiceDate) );
                        gen.writeStringField('Class','Maxval Group 10.100 - Services:126 - AP');                                                                       
                        gen.writeStringField('Amount',string.valueof(orderItem.Billing_Amount__c));
                        TotalAmount=TotalAmount + orderItem.Billing_Amount__c;
                        gen.writeEndObject(); 
                    }                    
                    TotalAmount=TotalAmount+ ObjInvoiceList[0].Order__r.Late_Fee__c;
                    TotalAmount=TotalAmount+ ObjInvoiceList[0].Order__r.Rush_Fee__c ;
                    gen.writeEndArray(); 
                }
                else{
                    gen.writeFieldName('LineItems');
                    gen.writeStartArray();
                    
                    
                    if(ObjInvoiceList[0].order__r.PO_Number__c !=null)
                    {
                        StrPONum ='PO- '+ObjInvoiceList[0].order__r.PO_Number__c+' under';
                    }
                    else{
                         StrPONum ='PO- NA under';
                    }
                    string strItem;
                    for(Order_Item__c orderItem: ListOfOItems){
                        TotalAmount=TotalAmount + orderItem.Billing_Amount__c;
                    }
                    TotalAmount=TotalAmount+ ObjInvoiceList[0].Order__r.Late_Fee__c;
                    TotalAmount=TotalAmount+ ObjInvoiceList[0].Order__r.Rush_Fee__c ;
                    
                    gen.writeStartObject();
                    if(ObjInvoiceList[0].order__r.PO_Number__c == null)
                        strItem=DefaultInvoiceType+' '+StrPONum+' Order- '+ObjInvoiceList[0].Order__r.name;
                    else
                        strItem= DefaultInvoiceType+' '+StrPONum+' Order- '+ObjInvoiceList[0].Order__r.name;
                    string strItemName='AP Deposits AP-'+ObjInvoiceList[0].Order__r.Client__r.name;
                    gen.writeStringField('ItemName', strItemName);
               // gen.writeStringField('Description',(ObjInvoiceList[0].Invoice_Currency__c!=null?string.valueof(ObjInvoiceList[0].Invoice_Currency__c):''));
                    gen.writeStringField('Description',strItem);
                    gen.writeStringField('Class','Maxval Group 10.100 - Services:126 - AP');                                                                       
                // gen.writeStringField('Amount',ObjInvoiceList[0].Order__r.Rush_Fee__c !=null?string.valueof(ObjInvoiceList[0].Order__r.Rush_Fee__c ):'');                                                                       
                    gen.writeStringField('Amount',string.valueof(TotalAmount));
                    gen.writeEndObject(); 
                    
                    gen.writeEndArray();
                //gen.writeEndObject();
                
                gen.writeStringField('Currency',ObjInvoiceList[0].Invoice_Currency__c);
                //gen.writeStringField('Currency',ObjInvoiceList[0].Order__r.Client__r.QB_Customer__r.Currency_Reference__c);
                gen.writeStringField('Total',string.valueof(TotalAmount));
                gen.writeStringField('Message','Please make check payable to MaxVal and mail it to the above address.' );
                gen.writeEndObject();
                gen.writeFieldName('Footer');
                gen.writeStartObject();
                gen.writeStringField('Message','');
                gen.writeEndObject();
                gen.writeFieldName('Attachment');
                gen.writeStartArray();
                
                gen.writeStartObject();
                gen.writeStringField('AttachmentRef',ObjInvoiceList[0].name);
                
                gen.writeStringField('Title','List of Assets'); 
                gen.writeFieldName('Items');                                        
                gen.writeStartArray();
                
                for(Order_Item__c orderItem: ListOfOItems)
                {
                    
                    gen.writeStartObject();
                    /*MARS-729 Publication number not available in the Invoice Attachment file (xlsx) for Renewal assets*/
                    /*Condition added by Saranyaa*/
                    jurisdiction = orderItem.Jurisdiction__c!=null?orderItem.Jurisdiction__c:'';
                    string patentId = '-';
                    patentId = orderItem.Patent_No__c!=null && orderItem.Patent_No__c!='-' ?orderItem.Patent_No__c:orderItem.Publication_No__c!=null && orderItem.Publication_No__c!='-' ?orderItem.Publication_No__c:'';
                    if(patentId!='-' && !patentId.startsWith(jurisdiction))
                        patentId = jurisdiction + patentId;
                    string applicationNo = '-';
                    applicationNo = orderItem.Application_No__c!=null?orderItem.Application_No__c:'';
                    if(applicationNo!='-' && !applicationNo.startsWith(jurisdiction))
                        applicationNo = jurisdiction + applicationNo;
                    gen.writeStringField('PatentID',patentId);
                    gen.writeStringField('ApplicationNo',applicationNo);
                    gen.writeStringField('DocketID',orderItem.Docket_No__c!=null?orderItem.Docket_No__c:'');
                    gen.writeStringField('Jurisdiction',jurisdiction);
                    gen.writeStringField('RenewalTerm',orderItem.Term_Name__c!=null?orderItem.Term_Name__c:'');
                    gen.writeStringField('RenewalDueDate',orderItem.Due_Date__c!=null?string.valueof(orderItem.Due_Date__c):'');
                    
                    gen.writeStringField('Amount',orderItem.Billing_Amount__c!=null?string.valueof(orderItem.Billing_Amount__c):'');
                    gen.writeEndObject();    
                }
                gen.writeEndArray(); 
                gen.writeFieldName('Fee');
                //for(Order_Item__c OrderItems: ListOfOItems)
                // {
                //TotalAmount=TotalAmount+ ObjInvoiceList[0].Order__r.Late_Fee__c;
                //TotalAmount=TotalAmount+ ObjInvoiceList[0].Order__r.Rush_Fee__c ;
                gen.writeStartObject();
                gen.writeStringField('LateFees',ObjInvoiceList[0].Order__r.Late_Fee__c!=null?string.valueof(ObjInvoiceList[0].Order__r.Late_Fee__c):'');
                gen.writeStringField('RushFees',ObjInvoiceList[0].Order__r.Rush_Fee__c !=null?string.valueof(ObjInvoiceList[0].Order__r.Rush_Fee__c ):'');
                gen.writeEndObject();
                // }           
                gen.writeStringField('InvoiceTotal',string.valueof(TotalAmount));
                gen.writeEndObject();
                gen.writeEndArray(); 
                gen.writeEndObject();
                gen.writeEndObject(); 
                
                InvItemDetails = gen.getAsString();
            }else{
                
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject();
                gen.writebooleanfield('Status', false);
                gen.writeStringField('errorCode', '201');
                gen.writeStringField('message', 'No Data Found');
                gen.writeEndObject();
                
                InvItemDetails = gen.getAsString();
                system.debug('InvItemDetails '+InvItemDetails );
                
            }
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(InvItemDetails); 
            system.debug('pretty'+RestContext.response.responseBody);
        }
        catch(Exception e)
        {
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writebooleanfield('Status', false);
            gen.writeStringField('errorCode', '201');
            gen.writeStringField('message', e.getMessage());
            gen.writeEndObject();
            
            string InvItemDetails1 = gen.getAsString();
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(InvItemDetails1); 
            system.debug('pretty'+RestContext.response.responseBody);
            
            strAuditTrail += ' || Error :'+e.getMessage();
            status = False;
        }
        //finally
        //{
        //    system.debug(strAuditTrail);
        //   AuditTrailHelper.UpdateAudit('InvoiceForMaxval',strAuditTrail,status);
        // }
    }
}