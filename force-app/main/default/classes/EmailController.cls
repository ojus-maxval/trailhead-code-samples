public with sharing class EmailController
{
    public static void SendToADU_WhenNewOrderReceived(List<Id> lstOrderId)
    {
        string strAuditText = '';
        try
        {
            List<String> Receivers = EmailHelper.GetEmailIds(true, true, false);
            List<Order__c> objOrderList = [SELECT  Id, Name, Payment_Status__c, Order_Number__c, Order_Date__c, Total_Renewals__c, Client__r.Client_Name__c, Order_Amount_USD_Total__c, Order_Amount_EUR__c FROM Order__c WHERE Id IN :lstOrderId];
            string strMessageBody = EmailHelper.Body_WhenNewOrderReceived(objOrderList);
            
            Messaging.SingleEmailMessage objMail = new Messaging.SingleEmailMessage();
            objMail.setSubject(objOrderList.size() +  ' new orders received from clients');
            objMail.setToAddresses(Receivers);
            objMail.setHtmlBody(strMessageBody); 
            if(!test.isRunningTest()){
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { objMail});
            }
        }
        catch(Exception exp)
        {
            strAuditText += '[Exceptionr raised. Message:' + exp.getMessage() + ', Other:' + exp.getStacktraceString() + ']';
        }
        finally
        {
            AuditTrailHelper.UpdateAudit('EmailController.SendToADU_WhenNewOrderReceived', strAuditText, 'None');
        }
    }
    public static void SendToClient_WhenNewOrderReceived(List<Id> lstOrderId)
    {
        Map<Id, List<Order__c>> mapClientOrders = new Map<Id, List<Order__c>>();
        Map<Id, string> mapClientEmail = new Map<Id, string>();
        List<Order__c> objOrderList = [SELECT  Id, Name, Payment_Status__c, Order_Number__c, Order_Date__c, Total_Renewals__c, Client__c, Client__r.Client_Name__c, Client__r.Contact_Email_Id__c, Order_Amount_USD_Total__c, Order_Amount_EUR__c FROM Order__c WHERE Id IN :lstOrderId];
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
        if(!test.isRunningTest()){
        	Messaging.sendEmail(objMessageList);
        }
    }
    public static void SendToADU_WhenPaymentRequested(List<Id> lstOrderId)
    {
        List<String> Receivers = EmailHelper.GetEmailIds(true, true, false);
        List<Invoice__c> objInvoiceList = [SELECT Id, Order__r.Order_Date__c, Order__r.Client__r.Client_Name__c, Invoice_No__c, Order__r.Order_Number__c, Invoice_Currency__c, Invoice_Amount__c FROM Invoice__c WHERE Order__c IN :lstOrderId];
        string strMessageBody = EmailHelper.Body_WhenPaymentRequested(objInvoiceList);
        
        Messaging.SingleEmailMessage objMail = new Messaging.SingleEmailMessage();
        objMail.setSubject('Invoice generated and payment requested from clients');
        objMail.setToAddresses(Receivers);
        objMail.setHtmlBody(strMessageBody); 
        if(!test.isRunningTest()){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { objMail});
        }
    }
    public static void SendToClient_WhenPaymentRequested(List<Id> lstOrderId)
    {
        Map<Id, List<Invoice__c>> mapClientInvoices = new Map<Id, List<Invoice__c>>();
        Map<Id, string> mapClientEmail = new Map<Id, string>();
        List<Invoice__c> objInvoiceList = [SELECT Id, Order__r.Order_Date__c, Order__r.Client__c, Order__r.Client__r.Client_Name__c, Order__r.Client__r.Contact_Email_Id__c, Invoice_No__c, Order__r.Order_Number__c, Invoice_Currency__c, Invoice_Amount__c FROM Invoice__c WHERE Order__c IN :lstOrderId];
        system.debug(objInvoiceList.size());        
        //List<Order__c> objOrderList = [SELECT  Id, Name, Payment_Status__c, Order_Number__c, Order_Date__c, Total_Renewals__c, Client__c, Client__r.Client_Name__c, Client__r.Contact_Email_Id__c, Order_Amount_USD_Total__c, Order_Amount_EUR__c FROM Order__c WHERE Id IN :lstOrderId];
        for(Invoice__c objInvoice : objInvoiceList)
        {
            if (mapClientInvoices.containsKey(objInvoice.Order__r.Client__c)==false)
            {
                List<Invoice__c> objClientInvoiceList =  new List<Invoice__c>();
                objClientInvoiceList.add(objInvoice);
                mapClientInvoices.put(objInvoice.Order__r.Client__c,objClientInvoiceList);
                mapClientEmail.put(objInvoice.Order__r.Client__c, objInvoice.Order__r.Client__r.Contact_Email_Id__c);
            }
            else
            {
                List<Invoice__c> objClientInvoiceList =  mapClientInvoices.get(objInvoice.Order__r.Client__c);
                objClientInvoiceList.add(objInvoice);
                mapClientInvoices.put(objInvoice.Order__r.Client__c,objClientInvoiceList);
            }
        }
        
        List<Messaging.SingleEmailMessage> objMessageList = new List<Messaging.SingleEmailMessage>();
        Set<Id> objClientIds = mapClientInvoices.keySet();
        system.debug(objClientIds);        
        for(Id ClientId : objClientIds)
        {
            if (mapClientInvoices.containsKey(ClientId))
            {
                List<Invoice__c> objClientInvoiceList = mapClientInvoices.get(ClientId); 
                List<String> Receivers = new List<String>();
                if (mapClientEmail.containsKey(ClientId))
                    Receivers.add(mapClientEmail.get(ClientId));
                
                string strMessageBody = EmailHelper.Body_Client_WhenPaymentRequested(objClientInvoiceList);
                Messaging.SingleEmailMessage objMail = new Messaging.SingleEmailMessage();
                objMail.setSubject('Invoices generated for your order');
                objMail.setToAddresses(Receivers);
                objMail.setHtmlBody(strMessageBody); 
                objMessageList.add(objMail);
            }
        }
        system.debug(objMessageList.size()); 
        if(!test.isRunningTest()){
            Messaging.sendEmail(objMessageList);
        }
    }
    
}