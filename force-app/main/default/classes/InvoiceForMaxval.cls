@RestResource(urlMapping = '/renewal/invoice/*')
global with sharing class InvoiceForMaxval 
{
    //Modified by Sneha B - MARS-343,MARS-1016
    @HttpGet
    global static void doget() 
    {
        string status ='';
        Boolean CCInfoIsAvailable = false;
        Boolean AccIncomeIsAvailable = false;
        Boolean QBCustomerIsAvailable = false;
        String StrPONum;
        String DefaultInvoiceType = 'Annuity Payments for';
        string strAuditTrail = '';
        try
        {
            string InvItemDetails='';
            String UniqueName = '';
            String strLeadSource = '';
            RestRequest restReq = RestContext.request;
            RestResponse restRes = RestContext.response;
            // Reading parametrs from URL
            strAuditTrail+='InvoiceDetails endpoint invoked - '+restReq.requestURI+'|';
            string req =  restReq.requestURI;
            integer li= req.lastIndexOf('/details');
            string s = req.substring(0, li);
            UniqueName =s.substring(s.lastIndexOf('/') + 1);
            strAuditTrail+='UniqueName - '+UniqueName+'|';
            strLeadSource = restReq.requestURI.substring(restReq.requestURI.lastIndexOf('&') + 1);
            
            string q1 = 'SELECT Name,Id,Is_Variance__c,Invoice_Date__c,order__c,Invoice_Type_Name__c,Order__r.Payment_Status__c,Order__r.Client__r.QB_Customer__c,Order__r.Client__r.QB_Customer__r.Currency_Reference__c,Order__r.Client__r.QB_Customer__r.Name,Order__r.Client__r.QB_Customer__r.QB_Customer_Id__c,Invoice_Currency__c,order__r.PO_Number__c,Order__r.Client__r.name,Order__r.Client__r.Billing_Address__c,Order__r.name,Invoice_Amount__c,Order__r.Late_Fee__c,order__r.Rush_Fee__c,Invoice_Type__c FROM Invoice__c WHERE name =:UniqueName limit 1'; 
            list<Invoice__c> ObjInvoiceList = Database.query(q1);            
            strAuditTrail+='InvoiceList Size-'+ObjInvoiceList.size()+'|';
            if(ObjInvoiceList.size()>0)
            {
                List<Clients__c> clientConfig =[SELECT 	Client_ID__c,Client_Matter_ID__c,Client_Name__c,Client_Type__c,Is_LEDES_Required__c,Line_Item_Expense_Code__c FROM Clients__c WHERE id=: ObjInvoiceList[0].Order__r.Client__c];
                list<QB_Account__c> ListOfIA =[SELECT Id,Name,QB_Account_Id__c, Client__c FROM QB_Account__c WHERE Client__c = : ObjInvoiceList[0].Order__r.Client__c  AND Account_Type__c IN ('Income', 'Other Current Liability') LIMIT 1];   
                list<QB_Customer__c> CustomerName =[SELECT Id,Name,QB_Customer_Id__c, Client__c FROM QB_Customer__c WHERE Client__c = : ObjInvoiceList[0].Order__r.Client__c AND Currency_Reference__c=:ObjInvoiceList[0].Invoice_Currency__c  LIMIT 1];               //boolean values to handle index out of bound exception in ternary syntax
                
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
                if(ObjInvoiceList[0].Invoice_Type_Name__c.startsWith('_')){
                        DefaultInvoiceType ='USD currency patents - Annuity Payments -';
                    }
                }
                list<Order_Item__c > ListOfOItems=
                    [select Due_Date__c
                     ,Term_Name__c
                     ,id,name,Invoice_Amount_When_Pay__c
                     ,Patent_No__c
                     ,Application_No__c                      
                     ,Docket_No__c
                     ,Jurisdiction__c
                     ,Renewal_Instruction__c
                     ,Billing_Amount__c
                     ,Filing_Receipt_File_Id__c
                     ,Billing_Currency_Unit_Rate_When_Pay__c
                     ,Invoice__c
                     ,Invoice__r.Is_Variance__c
                     ,Payment_Status__c
                     ,Variance_Amount__c
                     FROM Order_Item__c WHERE (Invoice__c=:ObjInvoiceList[0].id or (Invoice_with_Variance__c=:ObjInvoiceList[0].id)) and Payment_Status__c !=: 'Cancelled' and Cancellation_Approval__c !=: 'Approved'];
                	
                
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
                gen.writeStringField('BillToRef',CustomerName[0].QB_Customer_Id__c !=null?CustomerName[0].QB_Customer_Id__c:'');	
                gen.writeStringField('CompanyName',CustomerName[0].Name !=null?CustomerName[0].Name:'');
                gen.writeEndObject();
                
                gen.writeStringField('SendEmail','SENDLATER');
                gen.writeStringField('Message',''); 
                gen.writeEndObject();
                
                gen.writeFieldName('Details');
                gen.writeStartObject();
                gen.writeStringField('PONumber',ObjInvoiceList[0].order__r.PO_Number__c!=null?ObjInvoiceList[0].order__r.PO_Number__c:'');
                
                decimal TotalAmount=0;
                string jurisdiction = '';
                if(ObjInvoiceList[0].Is_Variance__c){
                	gen.writeStringField('OrderNum','');
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
                        patentId = orderItem.Patent_No__c!=null && orderItem.Patent_No__c!='-' ?orderItem.Patent_No__c:'';
                        if(patentId!='-' && !patentId.startsWith(jurisdiction))
                            patentId = jurisdiction + patentId;                        
                        gen.writeStringField('Description','Currency fluctuation for Patent# - '+ patentId +' Order# - '+ ObjInvoiceList[0].Order__r.name +' Invoice date - '+ string.valueOf(invoiceDate) );
                        gen.writeStringField('Class','Maxval Group 10.100 - Services:126 - AP');                                                                       
                        gen.writeStringField('Amount',string.valueof(orderItem.Variance_Amount__c));
                        TotalAmount += orderItem.Variance_Amount__c;
                        gen.writeEndObject(); 
                    }                    
                    gen.writeEndArray(); 
                }
                else{
                	gen.writeStringField('OrderNum',ObjInvoiceList[0].Order__r.name);
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
                    gen.writeStringField('Description',strItem);
                    gen.writeStringField('Class','Maxval Group 10.100 - Services:126 - AP');                                                                       
                    gen.writeStringField('Amount',string.valueof(TotalAmount));
                    gen.writeEndObject(); 
                    
                    gen.writeEndArray();
                }
                
                gen.writeStringField('Currency',ObjInvoiceList[0].Invoice_Currency__c);
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
                    jurisdiction = orderItem.Jurisdiction__c!=null?orderItem.Jurisdiction__c:'';
                    string patentId = '-';
                    patentId = orderItem.Patent_No__c!=null && orderItem.Patent_No__c!='-' ?orderItem.Patent_No__c:'';
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
                    if(ObjInvoiceList[0].Is_Variance__c){
                        gen.writeStringField('Amount',orderItem.Variance_Amount__c!=null?string.valueof(orderItem.Variance_Amount__c):'');
                    }else{
                        gen.writeStringField('Amount',orderItem.Billing_Amount__c!=null?string.valueof(orderItem.Billing_Amount__c):'');
                    }
                    gen.writeEndObject();
                }
                gen.writeEndArray();
                gen.writeFieldName('Fee');
                gen.writeStartObject();
                if(ObjInvoiceList[0].Is_Variance__c){
                    gen.writeStringField('LateFees','');
                	gen.writeStringField('RushFees','');
                }else{
                    gen.writeStringField('LateFees',ObjInvoiceList[0].Order__r.Late_Fee__c!=null?string.valueof(ObjInvoiceList[0].Order__r.Late_Fee__c):'');
                	gen.writeStringField('RushFees',ObjInvoiceList[0].Order__r.Rush_Fee__c !=null?string.valueof(ObjInvoiceList[0].Order__r.Rush_Fee__c ):'');
                }
                
                gen.writeEndObject();
                gen.writeStringField('InvoiceTotal',string.valueof(TotalAmount));
                gen.writeEndObject();
                gen.writeEndArray();
                if(clientConfig.size()>0 && clientConfig[0].Is_LEDES_Required__c)
                {
                    DateTime currentDate=datetime.now();
                    Date invoiceDate = date.newinstance(ObjInvoiceList[0].Invoice_Date__c.year(), ObjInvoiceList[0].Invoice_Date__c.month(), ObjInvoiceList[0].Invoice_Date__c.day());
                    gen.writeFieldName('LEDESDetails');
                	gen.writeStartObject();
                    gen.writeFieldName('Header');
                    gen.writeStartObject();
                    gen.writeStringField('InvoiceDate',invoiceDate!=null?string.valueOf(invoiceDate):'');
                    if(clientConfig[0].Client_Name__c.contains('Dropbox') && (jurisdiction=='US' || jurisdiction=='CA'))
                    {
                        gen.writeStringField('LineItemExpenseCode','E117');
                        //MARS-1164 MaRS - LEDES csv generation failed for Dropbox client
                        string clientId = MetadataHelper.GetLEDESClientId('Dropbox');
                        gen.writeStringField('ClientId',clientId);//to be shared by kavithmani
                        gen.writeStringField('ClientName',clientConfig[0].Client_Name__c!=null?clientConfig[0].Client_Name__c:'');
                        gen.writeStringField('ClientMatterId','BF_M#48539');
                        gen.writeStringField('MatterName','MaxVal Patent Annuities (North America)');
                        gen.writeStringField('LawFirmMatterId','sampleID');//to be shared by kavithamani based on jurisdiction
                    }
                    else
                    {
                        gen.writeStringField('ClientId',clientConfig[0].Client_ID__c!=null?clientConfig[0].Client_ID__c:'');
                        gen.writeStringField('ClientMatterId',clientConfig[0].Client_Matter_ID__c!=null?clientConfig[0].Client_Matter_ID__c:'');
                        if(clientConfig[0].Client_Name__c.contains('Dropbox'))
                        { 
                    		gen.writeStringField('ClientName',clientConfig[0].Client_Name__c!=null?clientConfig[0].Client_Name__c:'');
                            gen.writeStringField('MatterName','MaxVal Patent Annuities (Rest of the World)');
                            gen.writeStringField('LawFirmMatterId','sampleID');//to be shared by kavithmani based on jurisdiction
                        }         
                        else
                        {
                            gen.writeStringField('ClientName','');
                            gen.writeStringField('MatterName','');


                            gen.writeStringField('LawFirmMatterId',clientConfig[0].Law_Firm_Matter_ID__c!=null?clientConfig[0].Law_Firm_Matter_ID__c:'');//to be shared by kavithmani based on jurisdiction

                        }  
                    }
                    
                    gen.writeStringField('InvoiceTotal',string.valueof(TotalAmount));
                    gen.writeStringField('BillingStartDate',invoiceDate!=null?string.valueOf(invoiceDate.toStartOfMonth()):'');
					gen.writeStringField('BillingEndDate',invoiceDate!=null?string.valueOf(invoiceDate):'');
                    if(clientConfig[0].Client_Type__c=='Monthly')
                    	gen.writeStringField('InvoiceDescription','Annuity payment for '+currentDate.format('MMM')+' '+currentDate.year());
                    else if(clientConfig[0].Client_Type__c=='Quarterly')
                    {
                        Integer quarter=math.round((currentDate.month()+1)/3.0);
                        gen.writeStringField('InvoiceDescription','Annuity payment for ' +currentDate.year()+' Q'+quarter);
                    }
                    	
                    gen.writeStringField('LineItemExpenseCode','');
                    gen.writeStringField('Exp/Fee/InvAdjType','E');
                    gen.writeNumberField('LineItemNumberOfUnits',1);
                    gen.writeNumberField('LineItemAdjustmentAmount',0);
                    gen.writeStringField('LineItemDate',invoiceDate!=null?string.valueOf(invoiceDate):'');
                    gen.writeStringField('LineItemTaskCode','');
                    gen.writeStringField('LineItemExpenseCode','E117');
                    gen.writeStringField('LineItemActivityCode','');
                    gen.writeStringField('TimekeeperId','JB');
                    gen.writeStringField('LawFirmId','20-0674603');
                    gen.writeStringField('TimekeeperName','');
                    gen.writeStringField('TimekeeperClassification','');
                    gen.writeStringField('ClientTaxId','');
                    gen.writeStringField('TimekeeperClassification','');
                    gen.writeStringField('InvoiceTaxTotal','');
                    gen.writeStringField('InvoiceNetTotal',string.valueof(TotalAmount));
                    gen.writeStringField('InvoiceCurrency',ObjInvoiceList[0].Invoice_Currency__c!=null?ObjInvoiceList[0].Invoice_Currency__c:'');
                    gen.writeStringField('TimekeeperLastName','');
                    gen.writeStringField('TimekeeperFirstName','');
                    gen.writeStringField('AccountType','');
                    gen.writeStringField('LawFirmName','MaxVal Group Inc.');
                    gen.writeStringField('LawFirmAddress_1','2251 Grant Road');
                    gen.writeStringField('LawFirmAddress_2','Suite B');
                    gen.writeStringField('LawFirmCity','Los Altos');
                    gen.writeStringField('LawFirmStateorregion','CA');
                    gen.writeStringField('LawFirmPostcode','94024');
					gen.writeStringField('LawFirmCountry','US');
                    gen.writeStringField('ClientAddress_1','');
                    gen.writeStringField('ClientAddress_2','');
                    gen.writeStringField('ClientCity','');
                    gen.writeStringField('ClientStateorregion','');
                    gen.writeStringField('ClientPostcode','');
					gen.writeStringField('ClientCountry','');
                    gen.writeNumberField('LineItemTaxRate',0);
                    gen.writeNumberField('LineItemTaxTotal',0);
                    gen.writeStringField('LineItemTaxType','GST');
                    gen.writeStringField('InvoiceReportedTaxTotal','GST');
                    gen.writeStringField('InvoiceTaxCurrency','USD');
                    gen.writeEndObject();
                    gen.writeFieldName('LineItems');
                    gen.writeStartArray();
                	Integer lineItemNumber=1;
                    for(Order_Item__c orderItem: ListOfOItems)
                    {  
                        gen.writeStartObject();
                    	Datetime dueDate = orderItem.Due_Date__c;
                        jurisdiction = orderItem.Jurisdiction__c!=null?orderItem.Jurisdiction__c:'';
                        string patentId = '-';
                        patentId = orderItem.Patent_No__c!=null && orderItem.Patent_No__c!='-' ?orderItem.Patent_No__c:'';
                        if(patentId!='-' && !patentId.startsWith(jurisdiction))
                            patentId = jurisdiction + patentId;
                        string applicationNo = '-';
                        applicationNo = orderItem.Application_No__c!=null?orderItem.Application_No__c:'';
                        if(applicationNo!='-' && !applicationNo.startsWith(jurisdiction))
                            applicationNo = jurisdiction + applicationNo;
                        gen.writeStringField('Pat No./Pub No.',patentId);
                        gen.writeStringField('ApplicationNo',applicationNo);
                        gen.writeNumberField('LineItemNumber',lineItemNumber);
                        gen.writeStringField('LineItemDescription','Annuity Payment for '+jurisdiction+' '+orderItem.Docket_No__c+' '+orderItem.Patent_No__c+' '+orderItem.Term_Name__c+' '+dueDate.format('MMM-dd-yyyy'));
                        gen.writeStringField('LineItemUnitCost',orderItem.Billing_Amount__c!=null?string.valueof(orderItem.Billing_Amount__c):'');
                        gen.writeStringField('LineItemTotal',orderItem.Billing_Amount__c!=null?string.valueof(orderItem.Billing_Amount__c):'');
                        gen.writeEndObject(); 
                        lineItemNumber+=1;
                    }
                    gen.writeEndArray();
                    gen.writeEndObject();
                }
                gen.writeEndObject();
                gen.writeEndObject(); 
                InvItemDetails = gen.getAsString();
            }
            else
            { 
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
            strAuditTrail+='ResponseBody - '+RestContext.response.responseBody;
            status='Success';
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
            
            strAuditTrail += ' || Error :'+e.getMessage()+'|Stacktrace:'+e.getStackTraceString()+'|Linenumber:'+e.getLineNumber();
            status = 'Fail';
        }
        finally
        {
           system.debug(strAuditTrail);
           AuditTrailHelper.UpdateAudit('InvoiceForMaxval',strAuditTrail,status);
        }
    }
}