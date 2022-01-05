global with sharing class GenerateInvoiceBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful
{
    public List<Id> SelectedOrderIds {get;set;}
    public List<Id> ClientIDSForCreate {get;set;}
    public List<Id> ClientIDSForUpdate {get;set;}
    public Id idSelectedOrderId {get;set;}
    public List<ID>InvoicedAssets {get;set;}
    //public Set<Id> assetIdPtoValidation{get;set;}
    global GenerateInvoiceBatch()
    {
        if(test.isRunningTest())
        {
            SelectedOrderIds = NEW List<Id>();
            ClientIDSForCreate = new List<Id>();
            ClientIDSForUpdate = new List<Id>();
            InvoicedAssets = new List<Id>();
        	//assetIdPtoValidation =new Set<Id>();
        }
    }
    global GenerateInvoiceBatch(Id idSelectedOrderIds)
    {
        if(test.isRunningTest())
        {
            SelectedOrderIds = NEW List<Id>();
        }
        else{
            SelectedOrderIds = NEW List<Id>();
        }
        ClientIDSForCreate = new List<Id>();
        ClientIDSForUpdate = new List<Id>();
        InvoicedAssets = new List<Id>();
        //assetIdPtoValidation =new Set<Id>();
        idSelectedOrderId = idSelectedOrderIds;
    }
    global GenerateInvoiceBatch(List<Id> lstSelectedOrderIds)
    {
        ClientIDSForCreate = new List<Id>();
        ClientIDSForUpdate = new List<Id>();
        InvoicedAssets = new List<Id>();
        //assetIdPtoValidation =new Set<Id>();
        SelectedOrderIds = lstSelectedOrderIds;
    }
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        AuditTrailHelper.UpdateAudit('GenerateInvoiceBatch-Start', 'idSelectedOrderId:' + idSelectedOrderId +'>SelectedOrderIds:'+SelectedOrderIds.size(), 'None');
        if(SelectedOrderIds.size() > 0)
        {
            return Database.getQueryLocator([
            SELECT 
            Id
            , Client__c
            , Payment_Status__c
            , Order_Status__c
            , Is_Sent_Invoice__c 
            , Late_Fee__c
            , Rush_Fee__c
            FROM Order__c
            WHERE Id IN:SelectedOrderIds ]);
        }
        else{
        return Database.getQueryLocator([
            SELECT 
            Id
            , Client__c
            , Payment_Status__c
            , Order_Status__c
            , Is_Sent_Invoice__c 
            , Late_Fee__c
            , Rush_Fee__c
            FROM Order__c
            WHERE Id =:idSelectedOrderId ]);
        }
    }
    global void execute(Database.BatchableContext BC, List<sObject> objScopeObjectList)
    {
        string strAuditText = ' > ';
        decimal RushFeePerAsset =0;
        Boolean USDAsset =false;
        decimal LateFeePerOrder= 0;
        try
        {
            Map<string, Currency__c> mapCurrency = new Map<string, Currency__c>();
            List<Currency__c> objCurrencyList = [SELECT Id, Name, Exchange_Rate__c FROM Currency__c];
            for(Currency__c objCurrency : objCurrencyList)
            {
                if (mapCurrency.containsKey(objCurrency.Name)==false)
                    mapCurrency.put(objCurrency.Name, objCurrency);
            }
            //Reading first order
            Order__c objOrder = null;
            for(sObject objScopeObject : objScopeObjectList)
            {
                objOrder = (Order__c) objScopeObject;
            }
            strAuditText += ' Order Id:' + objOrder.Id + ' > ';
            
            //Reading existing invoices and order items
            List<Invoice__c> objInvoiceList = [SELECT Id, name,Order__c, Invoice_Date__c, Invoice_Status__c, Is_Active__c, Invoice_Currency__c, Invoice_Amount__c, Invoice_No__c, Invoice_Type_Name__c,Invoice_Config_Type__c, Is_Late_Rush_Fee_Included__c, API_Status__c FROM Invoice__c WHERE Order__c = :objOrder.Id and Order__r.Payment_Status__c != 'Invoiced Variance Amount'];
            List<Order_Item__c> objOrderItemList = [SELECT Id, Order__r.nRush_Renewals__c,Variance__c,Variance_Amount__c,Order__r.Payment_status__c,Order__c,Is_Instructed_during_Rush__c,CE_Markup_Percentage__c, Order__r.Client__r.Rush_Fee_per_Order__c,Invoice_Type_Name__c,Order__r.Client__c,Order__r.Client__r.QB_Customer__r.Currency_Reference__c, Invoice_Type_Name_Value__c, Billing_Currency__c, Billing_Amount__c, Invoice__c, Invoice_Amount_When_Pay__c, Payment_Status__c,Client__c FROM Order_Item__c WHERE Order__c = :objOrder.Id AND Payment_Status__c!='Cancelled'];
            
          	/*if(objOrderItemList.size()>0)
          	{
              	for(Order_Item__c item:objOrderItemList)
              	{
                  	assetIdPtoValidation.add(item.Id);
              	}
              strAuditText+='assetId-'+assetIdPtoValidation;
          	}*/
               
            //Reading the existing Invoices for the selected orders
            Map<string, Invoice__c> mapExistingInvoices = new Map<string, Invoice__c>();


            for(Invoice__c objInvoice : objInvoiceList)
            {


                if (mapExistingInvoices.containsKey(objInvoice.Invoice_Type_Name__c)==false)
                    
                {
                    mapExistingInvoices.put(objInvoice.Invoice_Type_Name__c, objInvoice);
                }
            }
            //Read Order Items and create invoice if not exists and update invoice if exists
            
            Map<string, Invoice__c> mapInvoicesToUpdate = new Map<string, Invoice__c>();
            Map<string, Invoice__c> mapInvoicesToInsert = new Map<string, Invoice__c>();
            for(Order_Item__c objOrderItem : objOrderItemList)
            {
                strAuditText+='OrderItemList - '+objOrderItemList.size()+'>';
                Invoice__c objInvoice = null;
                  if (mapExistingInvoices.containsKey(objOrderItem.Invoice_Type_Name_Value__c)==true)       
                //if (mapExistingInvoices.containsKey(objOrderItem.Invoice_Type_Name__c)==true)     
                {       
                      strAuditText += ' objOrderItemInvoicetypename:' + objOrderItem.id + ' > ';   
                    objInvoice = mapExistingInvoices.get(objOrderItem.Invoice_Type_Name_Value__c);      
                   // objInvoice = mapExistingInvoices.get(objOrderItem.Invoice_Type_Name__c);  
                    objInvoice.Order__c = objOrderItem.Order__c;    
                    objInvoice.Invoice_Date__c = DateTime.Now();    
                    objInvoice.Invoice_Status__c = 'Created';   
                    objInvoice.Is_Active__c = true;     
                    objInvoice.Invoice_Type_Name__c = objOrderItem.Invoice_Type_Name_Value__c;  
                    objInvoice.Invoice_Type__c = objOrderItem.Invoice_Type_Name__c; 
                    if(objOrderItem.Invoice_Type_Name__c == '-')
                    {
                        objInvoice.Invoice_Config_Type__c ='Regular';
                    }
                    else if(objOrderItem.Invoice_Type_Name__c.endsWith('_'))
                    {
                         objInvoice.Invoice_Config_Type__c ='BU';
                    }
                    else if(objOrderItem.Invoice_Type_Name__c.startsWith('_'))
                    {
                         objInvoice.Invoice_Config_Type__c ='Currency';
                    }
                    
                    objInvoice.Invoice_Currency__c = objOrderItem.Billing_Currency__c; 	
                    //invoice currency should be Invoice configuration's QB customer currency i.e,[Invoice_Type_Configuration__r.QB_Customer__r.Currency_Reference__c]	
                    ////invoice type configuration currency == QB_Customer__r.Currency_Reference__c [if matches then get QB_Customer__r.Currency_Reference__c and assign to objInvoice.Invoice_Currency__c ]	
                    //objInvoice.Invoice_Currency__c = objOrderItem.Order__r.Client__r.QB_Customer__r.Currency_Reference__c; 
                    objInvoice.Invoice_Amount__c = 0;
                    objInvoice.Invoice_No__c = '-'; 
                    objInvoice.Is_Late_Rush_Fee_Included__c = false;
                    objInvoice.API_Status__c = 'Send Update Request';
                    //ClientIDSForUpdate.add(objOrderItem.Client__c);
                    ClientIDSForUpdate.add(objOrderItem.Order__r.Client__c);
                    //strAuditText += ' objOrderItem:' + objOrderItem.id + ' > ';
                    strAuditText += ' objOrderItem.Order__r:' + objOrderItem.Order__c + ' > ';
                    strAuditText += ' objOrderItem.Order__r.Client__c:' + objOrderItem.Order__r.Client__c + ' > ';
                    if (mapInvoicesToUpdate.containsKey(objOrderItem.Invoice_Type_Name_Value__c)==false)
                        mapInvoicesToUpdate.put(objOrderItem.Invoice_Type_Name_Value__c, objInvoice);
                }
                else
                {
                    objInvoice =  new Invoice__c();
                    objInvoice.Order__c = objOrderItem.Order__c;
                    objInvoice.Invoice_Date__c = DateTime.Now();
                    objInvoice.Invoice_Status__c = 'Created'; 
                    objInvoice.Is_Active__c = true; 
                    objInvoice.Invoice_Type_Name__c = objOrderItem.Invoice_Type_Name_Value__c; 	
                    objInvoice.Invoice_Type__c = objOrderItem.Invoice_Type_Name__c; 
                     if(objOrderItem.Invoice_Type_Name__c == '-')
                    {
                        objInvoice.Invoice_Config_Type__c ='Regular';
                    }
                    else if(objOrderItem.Invoice_Type_Name__c.endsWith('_'))
                    {
                         objInvoice.Invoice_Config_Type__c ='BU';
                    }
                    else if(objOrderItem.Invoice_Type_Name__c.startsWith('_'))
                    {
                         objInvoice.Invoice_Config_Type__c ='Currency';
                    }
                    objInvoice.Invoice_Currency__c = objOrderItem.Billing_Currency__c; 	
                    //objInvoice.Invoice_Currency__c = objOrderItem.Order__r.Client__r.QB_Customer__r.Currency_Reference__c;  
                    objInvoice.Invoice_No__c = '-'; 
                    objInvoice.Is_Late_Rush_Fee_Included__c = false;
                    objInvoice.API_Status__c = 'Send Create Request';
                    if(objInvoice.Invoice_Amount__c == null){
                        objInvoice.Invoice_Amount__c = 0;
                    }
                    strAuditText+='status:'+objOrderItem.Payment_Status__c;
                    if(objOrderItem.Payment_Status__c != 'Waiting to Invoice'){
                        strAuditText += 'creating invoice with variance..: '+ objOrderItem.Variance_Amount__c+'>';
                        objInvoice.Invoice_Amount__c += objOrderItem.Variance_Amount__c == null ? 0 : objOrderItem.Variance_Amount__c;
                        strAuditText += 'Invoice Amount: ' + objInvoice.Invoice_Amount__c + '>';
                    }else{                        
                    	objInvoice.Invoice_Amount__c += 0;
                    }
                    //ClientIDSForCreate.add(objOrderItem.Client__c);
                    ClientIDSForCreate.add(objOrderItem.Order__r.Client__c);
                    //strAuditText += ' objOrderItem:' + objOrderItem + ' > ';
                    strAuditText += ' objOrderItem.Order__r:' + objOrderItem.Order__c + ' > ';
                    strAuditText += ' objOrderItem.Order__r.Client__c:' + objOrderItem.Order__r.Client__c + ' > ';
                    //ClientIDSForCreate.add(objOrderItem.Order__r.Client__c);
                    if (mapInvoicesToInsert.containsKey(objOrderItem.Invoice_Type_Name_Value__c)==false)
                        mapInvoicesToInsert.put(objOrderItem.Invoice_Type_Name_Value__c, objInvoice);
                }
            }
            INSERT mapInvoicesToInsert.values();
            System.debug('MapToInsert'+ mapInvoicesToInsert.values());
            UPDATE mapInvoicesToUpdate.values();
            System.debug('MapToUpdate'+ mapInvoicesToUpdate.values());
            strAuditText += ' mapInvoicesToInsert:' + mapInvoicesToInsert.values() + ' > ';
            strAuditText += ' mapInvoicesToUpdate:' + mapInvoicesToUpdate.values() + ' > ';
            
            //Read the Invoices after inserted and updated
            Map<string, Invoice__c> mapUpdatedInvoices = new Map<string, Invoice__c>();
            objInvoiceList = [SELECT Id,name, Order__c, Invoice_Date__c, Invoice_Status__c, Is_Active__c, Invoice_Currency__c, Invoice_Amount__c, Invoice_No__c, Invoice_Type_Name__c FROM Invoice__c WHERE Order__c = :objOrder.Id order by Invoice_date__c desc];
            for(Invoice__c objInvoice : objInvoiceList)
            {
                objInvoice.Invoice_Amount__c = 0;   
                if (mapUpdatedInvoices.containsKey(objInvoice.Invoice_Type_Name__c)==false)
                {
                    mapUpdatedInvoices.put(objInvoice.Invoice_Type_Name__c, objInvoice);
                }
            }
            UPDATE mapUpdatedInvoices.values();
            strAuditText += 'Updated mapUpdatedInvoices: > ';
            
            //Update the Orders and Order Items details
            Map<Id,List<Order_Item__c>> mapInvoiceOrderItems = new Map<Id,List<Order_Item__c>>();
            for(Order_Item__c objOrderItem : objOrderItemList)
            {
                System.debug(objOrderItem);
                Invoice__c objInvoice = null;
                if (mapUpdatedInvoices.containsKey(objOrderItem.Invoice_Type_Name_Value__c)==true)
                {
                    System.debug(mapUpdatedInvoices.containsKey(objOrderItem.Invoice_Type_Name_Value__c));
                    objInvoice = mapUpdatedInvoices.get(objOrderItem.Invoice_Type_Name_Value__c);
                }
                if (objInvoice != null)
                {
                    if(objOrderItem.Order__r.Payment_status__c == 'Invoiced Variance Amount'){
                        if(objOrderItem.Variance__c > 0){
                            objInvoice.Invoice_Amount__c += objOrderItem.Variance_Amount__c == null ? 0 : objOrderItem.Variance_Amount__c;
                            strAuditText += 'Variance Amount: ' + objOrderItem.Variance_Amount__c;                          
                            objInvoice.Is_Variance__c = true;
                    		objOrderItem.Invoice_with_Variance__c = objInvoice.Id;
                        }
                    }
                    else if(objOrderItem.Order__r.nRush_Renewals__c > 0)
                    {
                        if(objOrderItem.Is_Instructed_during_Rush__c)
                        {
                            decimal BillingCurrencyRate = mapCurrency.get(objOrderItem.Billing_Currency__c).Exchange_Rate__c;
                            strAuditText += ' BillingCurrencyRateRushfee:' + BillingCurrencyRate+ ' > ';
                            RushFeePerAsset= BillingCurrencyRate * objOrderItem.Order__r.Client__r.Rush_Fee_per_Order__c;
                            objInvoice.Invoice_Amount__c +=RushFeePerAsset;
                        }
                    }
                    else
                    {
                        objInvoice.Invoice_Amount__c += objOrderItem.Billing_Amount__c;
                    }
                    if(objOrderItem.Order__r.Payment_status__c != 'Invoiced Variance Amount')
                    	objOrderItem.Invoice__c = objInvoice.Id; 
                    strAuditText +='objOrderItem-'+objOrderItem;
                    strAuditText += '  objInvoice.Invoice_Amount__c:' +  objInvoice.Invoice_Amount__c+ ' > ';
                    InvoicedAssets.add(objInvoice.Id);
                    objOrderItem.Payment_Status__c ='Payment Requested';
                    if(objOrderItem.Billing_Currency__c == 'USD')
                    {
                    USDAsset =true;
                    }	
                    
                    strAuditText += 'Invoice Amount: ' + objInvoice.Invoice_Amount__c;
                    //objInvoice.Invoice_Amount__c += objOrderItem.Invoice_Amount_When_Pay__c;
                }
            }
            
            UPDATE objOrderItemList;
            UPDATE mapUpdatedInvoices.values();
            strAuditText += ' >objOrderItemList:' + objOrderItemList.size() + ' > ';
            
            strAuditText += ' ClientIDSForCreate:'+ClientIDSForCreate.size() + ' > ';
            strAuditText += ' mapUpdatedInvoices:' + mapUpdatedInvoices.size() + ' > ';
            
            //if (objOrder.Late_Fee__c>0 || objOrder.Rush_Fee__c>0)
            if (objOrder.Late_Fee__c>0 && objOrder.Payment_status__c != 'Invoiced Variance Amount')
            {
                strAuditText += ' LateRush:true > ';
                boolean IsLateRushFeeIncluded = false;
                objInvoiceList = [SELECT Id, name,Invoice_Amount__c FROM Invoice__c WHERE Order__c = :objOrder.Id AND Is_Late_Rush_Fee_Included__c = true];
                if (objInvoiceList != null && objInvoiceList.size()>0)
                {
                    Invoice__c objLRFeeInvoice = objInvoiceList[0];
                    objLRFeeInvoice.Invoice_Amount__c += objOrder.Late_Fee__c + objOrder.Rush_Fee__c;
                    IsLateRushFeeIncluded = true;
                    UPDATE objLRFeeInvoice;
                    strAuditText += ' objLRFeeInvoice1:' + objLRFeeInvoice.Id +' > ';
                }
                
              /*  if (IsLateRushFeeIncluded == false)
                {
                    objInvoiceList = [SELECT Id, Invoice_Amount__c FROM Invoice__c WHERE Order__c = :objOrder.Id AND Invoice_Currency__c = 'USD' ORDER BY Invoice_Amount__c ASC];
                    if (objInvoiceList != null && objInvoiceList.size()>0)
                    {
                        Invoice__c objLRFeeInvoice = objInvoiceList[0];
                        objLRFeeInvoice.Invoice_Amount__c += objOrder.Late_Fee__c + objOrder.Rush_Fee__c;
                        objLRFeeInvoice.Is_Late_Rush_Fee_Included__c = true;
                        IsLateRushFeeIncluded = true;
                        UPDATE objLRFeeInvoice;
                        strAuditText += ' objLRFeeInvoice2:' + objLRFeeInvoice +' > ';
                    }                   
                }*/
                if (USDAsset == true)
                {
                    objInvoiceList = [SELECT Id, name,Invoice_Amount__c,Invoice_Currency__c FROM Invoice__c WHERE Order__c = :objOrder.Id AND Invoice_Currency__c = 'USD' ORDER BY Invoice_Amount__c ASC];
                    if (objInvoiceList != null && objInvoiceList.size()>0 && objOrder.Payment_status__c != 'Invoiced Variance Amount')
                    {
                        Invoice__c objLRFeeInvoice = objInvoiceList[0];
                        if(objLRFeeInvoice.Invoice_Amount__c == null)
                            objLRFeeInvoice.Invoice_Amount__c = 0;
                        objLRFeeInvoice.Invoice_Amount__c += objOrder.Late_Fee__c ;
                        objLRFeeInvoice.Is_Late_Rush_Fee_Included__c = true;
                        IsLateRushFeeIncluded = true;
                        UPDATE objLRFeeInvoice;
                        strAuditText += ' objLRFeeInvoice2:' + objLRFeeInvoice.Id +' > ';
                    } 
                }
                else if(USDAsset == false)
                {
                    objInvoiceList = [SELECT Id, name,Invoice_Amount__c,Order__r.Late_Fee__c,Invoice_Currency__c FROM Invoice__c WHERE Order__c = :objOrder.Id AND Invoice_Currency__c != 'USD' ORDER BY Invoice_Amount__c ASC];
                    if (objInvoiceList != null && objInvoiceList.size()>0 && objOrder.Payment_status__c != 'Invoiced Variance Amount')
                    {
                        Invoice__c objLRFeeInvoice = objInvoiceList[0];
                        if(objOrder.Late_Fee__c> 0)
                        {
                            decimal BillingCurrencyRate = mapCurrency.get(objInvoiceList[0].Invoice_Currency__c).Exchange_Rate__c;
                            LateFeePerOrder= BillingCurrencyRate * objOrder.Late_Fee__c;
                            objLRFeeInvoice.Invoice_Amount__c +=LateFeePerOrder;
                        }
                        else
                            objLRFeeInvoice.Invoice_Amount__c += objOrder.Late_Fee__c;
                        objLRFeeInvoice.Is_Late_Rush_Fee_Included__c = true;
                        IsLateRushFeeIncluded = true;
                        UPDATE objLRFeeInvoice;
                        strAuditText += ' objLRFeeInvoice3:' + objLRFeeInvoice.Id +' > ';
                    } 
                }
                
               /* if (IsLateRushFeeIncluded == false)
                {
                    Invoice__c objLRFeeInvoice =  new Invoice__c();
                    objLRFeeInvoice.Order__c = objOrder.Id;
                    objLRFeeInvoice.Invoice_Date__c = DateTime.Now();
                    objLRFeeInvoice.Invoice_Status__c = 'Created'; 
                    objLRFeeInvoice.Is_Active__c = true; 
                    objLRFeeInvoice.Invoice_Type_Name__c = ''; 
                    objLRFeeInvoice.Invoice_Currency__c = 'USD'; 

objLRFeeInvoice.Invoice_Amount__c = objOrder.Late_Fee__c + objOrder.Rush_Fee__c;
                    objLRFeeInvoice.Is_Late_Rush_Fee_Included__c = true;
                    objLRFeeInvoice.Invoice_No__c = '-'; 
                    INSERT objLRFeeInvoice;
                    strAuditText += ' objLRFeeInvoice3:' + objLRFeeInvoice +' > ';
                }*/
            }
            
            //Update Order
            if(objOrder.Payment_status__c != 'Invoiced Variance Amount')
            	objOrder.Payment_Status__c = 'Invoiced';
            objOrder.Order_Status__c = 'In Progress';
            //objOrder.Is_Sent_Invoice__c = false;
            UPDATE objOrder;
            
            List<Batch_Queue__c> objBatchQueueList = [SELECT Id, Status__c FROM Batch_Queue__c WHERE Parent_Id__c = :objOrder.Id AND Name = 'Generate Invoice'];
            for(Batch_Queue__c objBatchQueue :objBatchQueueList )
            {
                objBatchQueue.Status__c = 'Completed';
            }
            if (objBatchQueueList != null && objBatchQueueList.size()>0)
                UPDATE objBatchQueueList;
            
        }
        catch(Exception exp)
        {
            strAuditText += ' ERROR1:' + exp.getMessage() + '|' + exp.getStackTraceString() + ' > ';
            system.debug('strAuditText :'+strAuditText);
        }
        finally
        {
            AuditTrailHelper.UpdateAudit('GenerateInvoiceBatch', strAuditText, 'None');
        }
    }
    global void finish(Database.BatchableContext BC)
    {
        try{
        System.debug(' GenerateInvoiceBatch Finish: | ClientIDSForCreate: '+ClientIDSForCreate+' |ClientIDSForUpdate:'+ClientIDSForUpdate);
        if(ClientIDSForCreate.size()>0)
        {
            SEt<ID> setIDS = NEW SET<ID>(ClientIDSForCreate);
            batchRenewalInvoiceCreate createInvoiceReq = NEW batchRenewalInvoiceCreate(new List<ID>(setIDS));
            database.executeBatch(createInvoiceReq,1);
        }
            
        
        if(ClientIDSForUpdate.size()>0)
        {
            SEt<ID> setID = NEW SET<ID>(ClientIDSForUpdate);
            batchRenewalInvoiceUpdate updateInvoiceReq = NEW batchRenewalInvoiceUpdate(new List<ID>(setID));
            database.executeBatch(updateInvoiceReq,1);
        }
            //if(assetIdPtoValidation.size() > 0)
                //BatchQueueHelper.BatchQueueForOrderItemForPTOvalidation(assetIdPtoValidation);
        }catch(Exception exp)
        {
                        AuditTrailHelper.UpdateAudit('GenerateInvoiceBatch', exp.getMessage() + '|' + exp.getStackTraceString(), 'None');

        }
    }
}