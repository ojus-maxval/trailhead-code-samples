/* Copyright © 2021 MaxVal Group. All Rights Reserved.
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */
public with sharing class BatchQueueHelper
{
    public static void CreateBatchQueueForOrderPlaced(Set<Id> setClientIds)
    {
        //Fetch the old values
        List<Batch_Queue__c> objBatchQueueList = new List<Batch_Queue__c>();
        for (Id ClientId: setClientIds)
        {
            Batch_Queue__c objBatchQueue = new Batch_Queue__c();
            objBatchQueue.Name = 'Order Placed Mail Alert';
            objBatchQueue.Parent_Id__c = ClientId;
            objBatchQueue.Status__c = 'To Do';
            objBatchQueueList.add(objBatchQueue);
        }
        INSERT objBatchQueueList;
    } 
    public static void CreateBatchQueueForOrderReceived(Set<Id> setOrderIds)
    {
        //Fetch the old values
        List<Batch_Queue__c> objBatchQueueList = new List<Batch_Queue__c>();
        for (Id OrderId: setOrderIds)
        {
            Batch_Queue__c objBatchQueue = new Batch_Queue__c();
            objBatchQueue.Name = 'Order Received Mail Alert';
            objBatchQueue.Parent_Id__c = OrderId;
            objBatchQueue.Status__c = 'To Do';
            objBatchQueueList.add(objBatchQueue);
        }
        INSERT objBatchQueueList;
    } 
    public static void CreateBatchQueueForOrderItem(List<Order_Item__c> lstNewOrderItems)
    {
        //Fetch the old values
        List<Batch_Queue__c> objBatchQueueList = new List<Batch_Queue__c>();
        for (Order_Item__c objOrderItem : lstNewOrderItems)
        {
            Batch_Queue__c objBatchQueue = new Batch_Queue__c();
            objBatchQueue.Name = 'Order Item';
            objBatchQueue.Parent_Id__c = objOrderItem.Id;
            objBatchQueue.Status__c = 'To Do';
            objBatchQueueList.add(objBatchQueue);
        }
        INSERT objBatchQueueList;
    } 
    public static void CreateBatchQueueForInvoiceGeneration(List<Id> lstOrderIds)
    {
        //Fetch the old values
        string strAuditText = ' > ';
        List<Batch_Queue__c> objBatchQueueList = new List<Batch_Queue__c>();
        for (Id orderId : lstOrderIds)
        {
            Batch_Queue__c objBatchQueue = new Batch_Queue__c();
            objBatchQueue.Name = 'Generate Invoice';
            objBatchQueue.Parent_Id__c = orderId;
            objBatchQueue.Status__c = 'To Do';
            objBatchQueueList.add(objBatchQueue);
            strAuditText += ' orderId: ' + orderId + ' > ';
        }
        INSERT objBatchQueueList;
        AuditTrailHelper.UpdateAudit('BatchQueue-InvoiceGeneration', strAuditText, 'None');
    }   
    public static void CreateBatchQueueForCreditMemoGeneration(List<Id> lstCreditMemoIds)
    {
        //Fetch the old values
        string strAuditText = '';
        List<Batch_Queue__c> objBatchQueueList = new List<Batch_Queue__c>();
        for (Id creditMemoId : lstCreditMemoIds)
        {
            Batch_Queue__c objBatchQueue = new Batch_Queue__c();
            objBatchQueue.Name = 'Generate CreditMemo';
            objBatchQueue.Parent_Id__c = creditMemoId;
            objBatchQueue.Status__c = 'To Do';
            objBatchQueueList.add(objBatchQueue);
            strAuditText += 'creditMemoId: ' + creditMemoId + ' | ';
        }
        INSERT objBatchQueueList;
        strAuditText += 'Added to BatchQueue | ';
        AuditTrailHelper.UpdateAudit('BatchQueue-CreditMemoGeneration', strAuditText, 'None');
    }   
    public static void CreateBatchQueueForRecordPayment(List<Order_Item__c> lstOldOrderItems, List<Order_Item__c> lstNewOrderItems)
    {
        //Fetch the old values
        Map<Id,Order_Item__c> mapOldOrderItems = new Map<Id,Order_Item__c>();
        for (Order_Item__c objOrderItem : lstOldOrderItems)
        {
            if (mapOldOrderItems.containsKey(objOrderItem.Id)==false) 
                mapOldOrderItems.put(objOrderItem.Id, objOrderItem);
        }
        List<Batch_Queue__c> objBatchQueueList = new List<Batch_Queue__c>();
        for (Order_Item__c objNewOrderItem : lstNewOrderItems)
        {
            Order_Item__c objOldOrderItem = null;
            if (mapOldOrderItems.containsKey(objNewOrderItem.Id)==true)
                objOldOrderItem = mapOldOrderItems.get(objNewOrderItem.Id);
            if (objOldOrderItem.Payment__c == null && objNewOrderItem.Payment__c != null)
            {
                Batch_Queue__c objBatchQueue = new Batch_Queue__c();
                objBatchQueue.Name = 'Record Payments';
                objBatchQueue.Parent_Id__c = objNewOrderItem.Id;
                objBatchQueue.Status__c = 'To Do';
                objBatchQueueList.add(objBatchQueue);
            }
        }
        INSERT objBatchQueueList;
    }
    //Harsha add on 25-08-2020
    public static void BatchQueueForOrderItemForPTOvalidation(Set<Id> setClientIds)
    {
        //Fetch the old values
        List<Batch_Queue__c> objBatchQueueList = new List<Batch_Queue__c>();
        for (string objClientid : setClientIds)
        {
            Batch_Queue__c objBatchQueue = new Batch_Queue__c();
            objBatchQueue.Name = 'PTO Validation Request';
            objBatchQueue.Parent_Id__c = objClientid;
            objBatchQueue.Status__c = 'To Do';
            objBatchQueueList.add(objBatchQueue);
        }
        INSERT objBatchQueueList;
    }
    public static void ForOrderItemForPTOvalidationDocument(Set<Id> setClientIds)
    {
        system.debug('ForOrderItemForPTOvalidationDocument:'+setClientIds);
        //Fetch the old values
        List<Batch_Queue__c> objBatchQueueList = new List<Batch_Queue__c>();
        for (string objClientid : setClientIds)
        {
            Batch_Queue__c objBatchQueue = new Batch_Queue__c();
            objBatchQueue.Name = 'PTO Validation Document';
            objBatchQueue.Parent_Id__c = objClientid;
            objBatchQueue.Status__c = 'To Do';
            objBatchQueueList.add(objBatchQueue);
        }
        INSERT objBatchQueueList;
    }
}