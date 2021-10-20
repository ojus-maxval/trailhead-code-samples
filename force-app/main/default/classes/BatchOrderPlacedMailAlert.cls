global with sharing class BatchOrderPlacedMailAlert implements Database.Batchable<sObject>, Database.AllowsCallouts
{
    global string BatchId {get;set;}
    global BatchOrderPlacedMailAlert()
    {
    }
    global BatchOrderPlacedMailAlert (string strBatchId)
    {
        BatchId = strBatchId;
    }
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        if (BatchId != null)
            return Database.getQueryLocator([SELECT Id, Parent_Id__c FROM Batch_Queue__c WHERE Name = 'Order Placed Mail Alert' AND Status__c = 'To Do' AND Id =:BatchId]);
        else
            return Database.getQueryLocator([SELECT Id, Parent_Id__c FROM Batch_Queue__c WHERE Name = 'Order Placed Mail Alert' AND Status__c = 'To Do']);                   
    }
    global void execute(Database.BatchableContext BC, List<sObject> objScopeObjectList)
    {
        try
        {
            //Read the Batches & Clients
            Map<Id, Id> mapClientIds = new Map<Id, Id>();
            List<Batch_Queue__c> objBatchQueueListToBeUpdated = new List<Batch_Queue__c>();
            for(sObject objScopeObject : objScopeObjectList)
            {
                Batch_Queue__c objBatchQueue = (Batch_Queue__c)objScopeObject;
                if (mapClientIds.containsKey(objBatchQueue.Parent_Id__c)==false)
                {
                    mapClientIds.put(objBatchQueue.Parent_Id__c, objBatchQueue.Parent_Id__c);
                    objBatchQueueListToBeUpdated.add(objBatchQueue); 
                }
            }
            
            Map<Id, List<Order__c>> mapClientOrders = new Map<Id, List<Order__c>>();
            Map<Id, string> mapClientEmail = new Map<Id, string>();
            List<Order__c> objOrderList = [SELECT  Id, Name, Payment_Status__c, Order_Number__c, Order_Date__c, Total_Renewals__c, Client__c, Client__r.Client_Name__c, Client__r.Contact_Email_Id__c, Order_Amount_USD_Total__c, Order_Amount_EUR__c FROM Order__c WHERE Client__c IN :mapClientIds.keySet()];
            for(Order__c objOrder : objOrderList)
            {
                if (mapClientOrders.containsKey(objOrder.Client__c)==false)
                {
                    List<Order__c> objClientOrderList =  new List<Order__c>();
                    objClientOrderList.add(objOrder);
                    mapClientOrders.put(objOrder.Client__c,objClientOrderList);
                    mapClientEmail.put(objOrder.Client__c, objOrder.Client__r.Contact_Email_Id__c);
                }
                else
                {
                    List<Order__c> objClientOrderList =  mapClientOrders.get(objOrder.Client__c);
                    objClientOrderList.add(objOrder);
                    mapClientOrders.put(objOrder.Client__c,objClientOrderList);
                }
            }
            
            List<Messaging.SingleEmailMessage> objMessageList = new List<Messaging.SingleEmailMessage>();
            Set<Id> objClientIds = mapClientOrders.keySet();
            for(Id ClientId : objClientIds)
            {
                if (mapClientOrders.containsKey(ClientId))
                {
                    List<Order__c> objClientOrderList = mapClientOrders.get(ClientId); 
                    List<String> Receivers = new List<String>();
                    if (mapClientEmail.containsKey(ClientId))
                        Receivers.add(mapClientEmail.get(ClientId));
                    
                    string strMessageBody = EmailHelper.Body_Client_WhenNewOrderReceived(objClientOrderList);
                    Messaging.SingleEmailMessage objMail = new Messaging.SingleEmailMessage();
                    objMail.setSubject('Orders placed to MaxVal successfully');
                    objMail.setToAddresses(Receivers);
                    objMail.setHtmlBody(strMessageBody); 
                    objMessageList.add(objMail);
                }
            }
            Messaging.sendEmail(objMessageList);
            
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