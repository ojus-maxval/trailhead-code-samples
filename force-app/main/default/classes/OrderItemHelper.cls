public with sharing class OrderItemHelper
{
    public static void UpdateOrderAmount(Set<Id> setOrderIds)
    {
        //Fetch the newly created Orders
        Map<Id, Order__c> mapOrders = new Map<Id, Order__c>();
        List<Order__c> objOrderList = [SELECT Id FROM Order__c WHERE Id IN :setOrderIds];
        for(Order__c objOrder : objOrderList)
        {
            if (mapOrders.containsKey(objOrder.Id)==false) 
                mapOrders.put(objOrder.Id, objOrder);
        }
        
        List<Order_Item__c> objOrderItemList = [SELECT Id, Order__c, Billing_Currency__c, Billing_Amount__c FROM Order_Item__c WHERE Order__c IN :setOrderIds];
        for(Order_Item__c objOrderItem : objOrderItemList)
        {
            if (mapOrders.containsKey(objOrderItem.Order__c)==true) 
            {
                Order__c objOrder = mapOrders.get(objOrderItem.Order__c);
                //if (objOrderItem.Billing_Currency__c == 'USD')
                //    objOrder.Order_Amount_USD__c +=  objOrderItem.Billing_Amount__c; 
                //if (objOrderItem.Billing_Currency__c == 'EUR')
                //    objOrder.Order_Amount_EUR__c +=  objOrderItem.Billing_Amount__c; 
            }
        } 
        UPDATE mapOrders.values();       
        
    }
}