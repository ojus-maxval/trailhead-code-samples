global with sharing class OrderItemBatch implements Database.Batchable<sObject>, Database.AllowsCallouts
{
    public List<Id> SelectedOrderItemIds {get;set;}
    global OrderItemBatch  ()
    {
    }
    global OrderItemBatch  (List<Id> lstSelectedOrderItemIds)
    {
        SelectedOrderItemIds = lstSelectedOrderItemIds;
    }
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        if (SelectedOrderItemIds !=null && SelectedOrderItemIds.size()>0) 
            return Database.getQueryLocator([SELECT Id, Jurisdiction__c, Path__c, Order__c, Order__r.Client__c, Order__r.Client__r.Invoice_Type__c, Invoice_Type_Name__c, Due_Date__c, Payment_Mode__c, Suggested_Open_Date_To_Pay__c,Suggested_Close_Date_To_Pay__c, Instruction_Date_From__c, Instruction_Date_To__c, Instructed_Date__c, Billing_Currency__c, Fee_Currency__c, Fee_Unit_Rate_When_Pay__c, Service_Fee_Currency__c, Service_Fee_Unit_Rate_When_Pay__c, Agent_Fee_Currency__c, Agent_Fee_Unit_Rate_When_Pay__c FROM Order_Item__c WHERE Id IN :SelectedOrderItemIds]);
        else
            return Database.getQueryLocator([SELECT Id, Jurisdiction__c, Path__c, Order__c, Order__r.Client__c, Order__r.Client__r.Invoice_Type__c, Invoice_Type_Name__c, Due_Date__c, Payment_Mode__c, Suggested_Open_Date_To_Pay__c,Suggested_Close_Date_To_Pay__c, Instruction_Date_From__c, Instruction_Date_To__c, Instructed_Date__c, Billing_Currency__c, Fee_Currency__c, Fee_Unit_Rate_When_Pay__c, Service_Fee_Currency__c, Service_Fee_Unit_Rate_When_Pay__c, Agent_Fee_Currency__c, Agent_Fee_Unit_Rate_When_Pay__c FROM Order_Item__c]);              
    }
    global void execute(Database.BatchableContext BC, List<sObject> objScopeObjectList)
    {
        AuditTrailHelper.UpdateAudit('OrderItemBatch - execution start', 'Start', 'None');
        string strAuditText = '';
        try
        { 
            strAuditText+='Size of items-'+objScopeObjectList.size();
            Map<string, Currency__c> mapCurrency = new Map<string, Currency__c>();
            Payment_Schedule__c paymentSchedule=new Payment_Schedule__c();
            Map<string, Payment_Schedule__c> paymentScheduleMap = new Map<string, Payment_Schedule__c>();
            List<Payment_Schedule__c> objPaymentScheduleList = [SELECT Jurisdiction__c, Payment_Mode__c, Schedule_From__c, Schedule_Date_From__c, Schedule_Date_To__c FROM Payment_Schedule__c];
            List<Currency__c> objCurrencyList = [SELECT Id, Name, Exchange_Rate__c FROM Currency__c];
            for(Currency__c objCurrency : objCurrencyList)
            {
                if (mapCurrency.containsKey(objCurrency.Name)==false)
                    mapCurrency.put(objCurrency.Name, objCurrency);
            }
            for(Payment_Schedule__c objPaymentSchedule:objPaymentScheduleList)
            {
                if (!paymentScheduleMap.containsKey(objPaymentSchedule.Jurisdiction__c))
                    paymentScheduleMap.put(objPaymentSchedule.Jurisdiction__c, objPaymentSchedule);
            }
            Map<Id, Id> mapOrders = new Map<Id, Id>();
            Map<Id, string> mapOrderItemIds = new Map<Id, string>();
            List<Order_Item__c> objOrderItemList = new List<Order_Item__c>();
            for(sObject objScopeObject : objScopeObjectList)
            {
                Order_Item__c objOrderItem = (Order_Item__c) objScopeObject;
                
                if (mapOrders.containsKey(objOrderItem.Order__c)==false)
                    mapOrders.put(objOrderItem.Order__c, objOrderItem.Order__c);
                if(paymentScheduleMap.containsKey(objOrderItem.Jurisdiction__c))
                {
                    paymentSchedule=paymentScheduleMap.get(objOrderItem.Jurisdiction__c);
                    strAuditText+='paymentSchedule-'+paymentSchedule;
                    PaymentScheduleWrapper objPaymentScheduleWrapper = PaymentScheduleHelper.GetScheduledDates(paymentSchedule.Schedule_From__c, objOrderItem.Due_Date__c, Integer.valueOf(paymentSchedule.Schedule_Date_From__c), Integer.valueOf(paymentSchedule.Schedule_Date_To__c));
                    objOrderItem.Suggested_Open_Date_To_Pay__c = objPaymentScheduleWrapper.ScheduleStartDate;
                    objOrderItem.Suggested_Close_Date_To_Pay__c = objPaymentScheduleWrapper.ScheduleCloseDate;
                    objOrderItem.Payment_Mode__c = paymentSchedule.Payment_Mode__c;
                }
                else
                    strAuditText +='Payment Schedule is not available for '+objOrderItem.Jurisdiction__c+' jurisdiction||';
                
                /*List<Payment_Schedule__c> objPaymentSchedule = [SELECT Jurisdiction__c, Payment_Mode__c, Schedule_From__c, Schedule_Date_From__c, Schedule_Date_To__c FROM Payment_Schedule__c WHERE Jurisdiction__c =:objOrderItem.Jurisdiction__c LIMIT 1];
                if(objPaymentSchedule.size()>0){
                    PaymentScheduleWrapper objPaymentScheduleWrapper = PaymentScheduleHelper.GetScheduledDates(objPaymentSchedule[0].Schedule_From__c, objOrderItem.Due_Date__c, Integer.valueOf(objPaymentSchedule[0].Schedule_Date_From__c), Integer.valueOf(objPaymentSchedule[0].Schedule_Date_To__c));
                    objOrderItem.Suggested_Open_Date_To_Pay__c = objPaymentScheduleWrapper.ScheduleStartDate;
                    objOrderItem.Suggested_Close_Date_To_Pay__c = objPaymentScheduleWrapper.ScheduleCloseDate;
                    objOrderItem.Payment_Mode__c = objPaymentSchedule[0].Payment_Mode__c;
                }*/
                                
                strAuditText +='objOrderItem.Billing_Currency__c:' + objOrderItem.Billing_Currency__c;
                if (mapCurrency.containsKey(objOrderItem.Billing_Currency__c))
                {
                    objOrderItem.Billing_Currency_Unit_Rate_When_Pay__c = mapCurrency.get(objOrderItem.Billing_Currency__c).Exchange_Rate__c;
                    strAuditText +='Yes';
                }
                strAuditText +='No';
                if (mapCurrency.containsKey(objOrderItem.Fee_Currency__c))
                    objOrderItem.Fee_Unit_Rate_When_Pay__c = mapCurrency.get(objOrderItem.Fee_Currency__c).Exchange_Rate__c;
                if (mapCurrency.containsKey(objOrderItem.Service_Fee_Currency__c))
                    objOrderItem.Service_Fee_Unit_Rate_When_Pay__c = mapCurrency.get(objOrderItem.Service_Fee_Currency__c).Exchange_Rate__c;
                if (mapCurrency.containsKey(objOrderItem.Agent_Fee_Currency__c))
                    objOrderItem.Agent_Fee_Unit_Rate_When_Pay__c = mapCurrency.get(objOrderItem.Agent_Fee_Currency__c).Exchange_Rate__c;    
                
                WindowConfigurationWrapper objWindowConfigurationWrapper = WindowConfigurationHelper.GetWindowDates(objOrderItem.Order__r.Client__c);
                objOrderItem.Instruction_Date_From__c = objWindowConfigurationWrapper.InstructionWindowStartDate;
                objOrderItem.Instruction_Date_To__c = objWindowConfigurationWrapper.InstructionWindowCloseDate ;
                objOrderItem.Instructed_Date__c = Date.Today();

                //Update UniqueId
                /*
                if (objOrderItem.Path__c == null)
                    objOrderItem.Path__c = '';
                if (objOrderItem.Order__r.Client__r.Invoice_Type__c == 'Regular Invoice')
                    objOrderItem.Invoice_Type_Name__c = objOrderItem.Order__r.Client__c + '_' + objOrderItem.Order__c + '_' + objOrderItem.Billing_Currency__c;
                else if (objOrderItem.Order__r.Client__r.Invoice_Type__c == 'BU Wise')    
                    objOrderItem.Invoice_Type_Name__c = objOrderItem.Order__r.Client__c + '_' + objOrderItem.Order__c + '_' + objOrderItem.Path__c + '_' + objOrderItem.Billing_Currency__c;            
                */
                objOrderItemList.add(objOrderItem);
                
                
                
                if (mapOrderItemIds.containsKey(objOrderItem.Id)==false)
                    mapOrderItemIds.put(objOrderItem.Id, string.valueOf(objOrderItem.Id));
            }
            UPDATE objOrderItemList;
            
            //Read the clients
            Set<Id> setOrderIds = mapOrders.keySet();
            Map<Id, Clients__c> mapClients =  new Map<Id, Clients__c>();
            List<Clients__c> objClients = [SELECT Id, Late_fee_per_asset__c, Late_Fee_Minimum__c, Late_Fee_Maximum__c, Rush_Fee_per_Order__c FROM Clients__c WHERE Id IN (SELECT Client__c FROM Order__c WHERE Id IN :setOrderIds)];
            for(Clients__c objClient : objClients)
            {
                if (mapClients.containsKey(objClient.Id)==false)
                    mapClients.put(objClient.Id, objClient);
            }
            
            //Read the Orders
            List<Order__c> objOrders = [SELECT Id, Client__c, nRenewals_after_Instruction_Window__c, Late_Fee__c, nRush_Renewals__c, Rush_Fee__c  FROM Order__c WHERE Id IN :setOrderIds];
            for(Order__c objOrder : objOrders)
            {
                Clients__c objClient = mapClients.get(objOrder.Client__c);
                if (objOrder.nRenewals_after_Instruction_Window__c >0)
                {
                    decimal LateFeeTotal = objOrder.nRenewals_after_Instruction_Window__c * objClient.Late_fee_per_asset__c;
                    if (LateFeeTotal < objClient.Late_Fee_Minimum__c)
                        LateFeeTotal = objClient.Late_Fee_Minimum__c; 
                    if (LateFeeTotal > objClient.Late_Fee_Maximum__c)
                        LateFeeTotal = objClient.Late_Fee_Maximum__c; 
                    objOrder.Late_Fee__c = LateFeeTotal;
                }
                if (objOrder.nRush_Renewals__c >0)
                    objOrder.Rush_Fee__c= objOrder.nRush_Renewals__c * objClient.Rush_Fee_per_Order__c;
                objOrder.Job_Status__c='Completed';
            }
            UPDATE objOrders;
            strAuditText+='|updated orders|';
             
            List<string> strOrderItemIds = mapOrderItemIds.values();
            if (strOrderItemIds!= null && strOrderItemIds.size()>0)
            {
                List<Batch_Queue__c> objBatchQueueList = [SELECT Id, Status__c FROM Batch_Queue__c WHERE Parent_Id__c IN :strOrderItemIds AND Name = 'Order Item'];
                for(Batch_Queue__c objBatchQueue :objBatchQueueList )
                {
                    objBatchQueue.Status__c = 'Completed';
                }
                if (objBatchQueueList != null && objBatchQueueList.size()>0)
                    UPDATE objBatchQueueList;
            }
            
        }
        catch(Exception exp)
        {
             strAuditText += 'Error:' + exp.getMessage() + '|' + exp.getStackTraceString()+'|'+ exp.getLineNumber();
        }
        finally
        {
            AuditTrailHelper.UpdateAudit('OrderItemBatch', strAuditText, 'None');
        }
    }
    global void finish(Database.BatchableContext BC)
    {
        //AuditTrailHelper.UpdateAudit('Order Item batch', 'SelectedOrderItemIds:' + SelectedOrderItemIds , 'None');
    }
    
}