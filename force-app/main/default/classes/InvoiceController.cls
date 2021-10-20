public with sharing class InvoiceController
{
    public static string GenerateInvoice(List<Id> SelectedOrderIds)
    {
        string strAuditText = '';
        try
        {
            List<Order__c> objOrderList = [SELECT Id, Client__r.Invoice_Type__c, Payment_Status__c, Order_Status__c FROM Order__c WHERE Id = :SelectedOrderIds];
            Map<Id, Order__c> mapOrders = new Map<Id, Order__c>();
            for(Order__c objOrder : objOrderList)
            {
                if (mapOrders.containsKey(objOrder.Id)==false)
                    mapOrders.put(objOrder.Id, objOrder);   
            }
            
            List<Order_Item__c> objOrderItemList = [
                SELECT 
                Id
                , Order__c
                , Path__c
                , Billing_Currency__c
                , Billing_Amount__c
                , Payment_Status__c
                , Invoice__c
                FROM Order_Item__c
                WHERE Payment_Status__c= 'Waiting to Invoice'
                AND Order__c IN :SelectedOrderIds];
            strAuditText += 'SelectedOrderIds:' + SelectedOrderIds;
            strAuditText += '| objOrderItemList:' + objOrderItemList.size();
            for(Order_Item__c objOrderItem: objOrderItemList)
            {
                if (objOrderItem.Path__c == null)
                    objOrderItem.Path__c = '';
                    
                Order__c objOrder = mapOrders.get(objOrderItem.Order__c);
                string UniqueId = '';
                if (objOrder.Client__r.Invoice_Type__c == 'Regular Invoice') 
                    UniqueId = objOrderItem.Order__c + '_' + objOrderItem.Billing_Currency__c;
                else if (objOrder.Client__r.Invoice_Type__c == 'BU Wise') 
                    UniqueId = objOrderItem.Order__c + '_' + objOrderItem.Path__c + '_' + objOrderItem.Billing_Currency__c;
                
                Invoice__c objCurrentInvoice = null;
                List<Invoice__c> objInvoices = [SELECT Id, Invoice_Currency__c, Invoice_Date__c, Invoice_No__c, Invoice_Amount__c, Invoice_Status__c, Invoice_Type_Name__c, Is_Active__c, Order__c FROM Invoice__c WHERE Invoice_Type_Name__c = :UniqueId AND Is_Active__c = true];
                if (objInvoices != null && objInvoices.size()>0)
                {
                    objCurrentInvoice = objInvoices[0];
                    objCurrentInvoice.Invoice_Amount__c += objOrderItem.Billing_Amount__c;
                    UPDATE objCurrentInvoice;
                    objOrderItem.Invoice__c = objCurrentInvoice.Id;
                }
                else
                {
                    objCurrentInvoice = new Invoice__c();
                    objCurrentInvoice.Invoice_Amount__c = objOrderItem.Billing_Amount__c;
                    objCurrentInvoice.Invoice_Date__c = DateTime.Now();
                    objCurrentInvoice.Invoice_Status__c = 'Created'; 
                    objCurrentInvoice.Is_Active__c = true; 
                    objCurrentInvoice.Invoice_No__c = '-'; 
                    objCurrentInvoice.Order__c = objOrderItem.Order__c; 
                    objCurrentInvoice.Invoice_Currency__c = objOrderItem.Billing_Currency__c; 
                    objCurrentInvoice.Invoice_Type_Name__c = UniqueId; 
                    INSERT objCurrentInvoice;
                    
                    Invoice__c objCreatedInvoice = [SELECT Id FROM Invoice__c WHERE Invoice_Type_Name__c = :UniqueId LIMIT 1];
                    objOrderItem.Invoice__c = objCreatedInvoice.Id;
                }
                objOrderItem.Payment_Status__c ='Payment Requested';
            }
            UPDATE objOrderItemList;
            
            for(Order__c objOrder : objOrderList)
            {
                objOrder.Payment_Status__c = 'Invoiced';
                objOrder.Order_Status__c = 'In Progress';
            }
            UPDATE objOrderList;    
        }
        catch(Exception exp)
        {
            strAuditText += 'Error:' + exp.getMessage() + '|' + exp.getStackTraceString();
        }
        finally
        {
            AuditTrailHelper.UpdateAudit('Invoice', strAuditText, 'None');
        }
        return strAuditText;
    }
}