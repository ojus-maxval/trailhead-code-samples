public with sharing class RenewalStatusHelper
{
    public static List<string> GetRequestedMarsRenewalIds(APIRenewalStatusRequest MarsRenewalIdRequest)
    {
        List<string> lstMarRenewalIds= new List<string>();
        for(APIRenewalStatusLineItemRequest objRequest : MarsRenewalIdRequest.MarsRenewalIds)
        {
            lstMarRenewalIds.add(objRequest.MarsRenewalId);
        }
        return lstMarRenewalIds;
    }
    public static Map<string, Order_Item__c> GetOrderItemsForRequestedMarsRenewalIds(List<string> lstMarRenewalIds)
    {
        Map<string, Order_Item__c> mapOrderItems = new Map<string, Order_Item__c>();
        List<Order_Item__c> objOrderItems = [SELECT Id, Cancellation_Approval__c, Renewal_Instruction__c, Payment_Status__c FROM Order_Item__c WHERE Name IN :lstMarRenewalIds];
        for(Order_Item__c objOrderItem : objOrderItems)
        {
            if (mapOrderItems.containsKey(objOrderItem.Name)==false)
            {
                mapOrderItems.put(objOrderItem.Name, objOrderItem); 
            }
        }
        return mapOrderItems;
    }
}