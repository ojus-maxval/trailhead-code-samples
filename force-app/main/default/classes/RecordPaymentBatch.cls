global with sharing class RecordPaymentBatch implements Database.Batchable<sObject>, Database.AllowsCallouts
{
    public List<Id> SelectedOrderItemIds {get;set;}
    global RecordPaymentBatch ()
    {
    }
    global RecordPaymentBatch (List<Id> lstSelectedOrderItemIds)
    {
        SelectedOrderItemIds = lstSelectedOrderItemIds;
    }
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator([SELECT Id, Payment_Status__c, Payment_Received_from_Client__c FROM Order_Item__c WHERE Id IN :SelectedOrderItemIds]);
    }
    global void execute(Database.BatchableContext BC, List<sObject> objScopeObjectList)
    {
        Map<Id, string> mapOrderItemIds =  new Map<Id, string>();
        List<Order_Item__c> objOrderItemList = new List<Order_Item__c>();
        for(sObject objScopeObject : objScopeObjectList)
        {
            Order_Item__c objOrderItem = (Order_Item__c) objScopeObject;
            objOrderItem.Payment_Status__c = 'Payment Received';
            objOrderItem.Payment_Received_from_Client__c = true;
            objOrderItem.Send_for_approval_to_pay_PTO_fee__c = false;
            objOrderItemList.add(objOrderItem);
            
            if (mapOrderItemIds.containsKey(objOrderItem.Id)==false)
                    mapOrderItemIds.put(objOrderItem.Id, string.valueOf(objOrderItem.Id));
        }
        UPDATE objOrderItemList;
        
        List<string> strOrderItemIds = mapOrderItemIds.values();
        if (strOrderItemIds!= null && strOrderItemIds.size()>0)
        {
            List<Batch_Queue__c> objBatchQueueList = [SELECT Id, Status__c FROM Batch_Queue__c WHERE Parent_Id__c IN :strOrderItemIds AND Name = 'Record Payments'];
            for(Batch_Queue__c objBatchQueue :objBatchQueueList )
            {
                objBatchQueue.Status__c = 'Completed';
            }
            if (objBatchQueueList != null && objBatchQueueList.size()>0)
                UPDATE objBatchQueueList;
        }
        
    }
    global void finish(Database.BatchableContext BC)
    {
    }
    
}