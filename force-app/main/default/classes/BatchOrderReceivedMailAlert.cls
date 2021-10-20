global with sharing class BatchOrderReceivedMailAlert implements Database.Batchable<sObject>, Database.AllowsCallouts
{
    global string BatchId {get;set;}
    global BatchOrderReceivedMailAlert()
    {
    }
    global BatchOrderReceivedMailAlert(string strBatchId)
    {
        BatchId = strBatchId;
    }
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        if (BatchId != null)
            return Database.getQueryLocator([SELECT Id, Parent_Id__c FROM Batch_Queue__c WHERE Name = 'Order Received Mail Alert' AND Status__c = 'To Do' AND Id =:BatchId]);
        else
            return Database.getQueryLocator([SELECT Id, Parent_Id__c FROM Batch_Queue__c WHERE Name = 'Order Received Mail Alert' AND Status__c = 'To Do']);                   
    }
    global void execute(Database.BatchableContext BC, List<sObject> objScopeObjectList)
    {
        try
        {
            //Read the Mail Receivers
            List<string> Receivers = EmailHelper.GetEmailIds(true, true, true);
            
            //Read the Batches & Orders
            Map<Id, Id> mapOrderIds = new Map<Id, Id>();
            List<Batch_Queue__c> objBatchQueueListToBeUpdated = new List<Batch_Queue__c>();
            for(sObject objScopeObject : objScopeObjectList)
            {
                Batch_Queue__c objBatchQueue = (Batch_Queue__c)objScopeObject;
                if (mapOrderIds.containsKey(objBatchQueue.Parent_Id__c)==false)
                {
                    mapOrderIds.put(objBatchQueue.Parent_Id__c, objBatchQueue.Parent_Id__c);
                    objBatchQueueListToBeUpdated.add(objBatchQueue); 
                }
            }
            List<Order__c> objOrderList = [SELECT  Id, Name, Payment_Status__c, Order_Number__c, Order_Date__c, Total_Renewals__c, Client__r.Client_Name__c, Order_Amount_USD_Total__c, Order_Amount_EUR__c FROM Order__c WHERE Id IN :mapOrderIds.keySet()];
            string strMessageBody = EmailHelper.Body_WhenNewOrderReceived(objOrderList);            
            
            Messaging.SingleEmailMessage objMail = new Messaging.SingleEmailMessage();
            objMail.setSubject(objOrderList.size() +  ' new orders received from clients');
            objMail.setToAddresses(Receivers);
            objMail.setHtmlBody(strMessageBody); 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { objMail});
            
            UPDATE objBatchQueueListToBeUpdated;
        }
        catch(Exception exp)
        {
        }
        finally
        {
        }
    }
    global void finish(Database.BatchableContext BC)
    {
    }
}