@RestResource(urlMapping='/renewalreinstruct/*')
global class RenewalReinstructController
{
    @HttpPost
    global static string ReinstructRenewal(string MarsRenewalId, string RenewalInstruction, string ClientOrgId) 
    {
        Clients__c objClient = null;
        List<Clients__c> objClients = [SELECT Id FROM Clients__c WHERE Symphony_Org_Id__c= :ClientOrgId];
        if (objClients!= null && objClients.size()>0)
             objClient = objClients[0];
             
        //Client_Order_Id
        Order_Item__c objOrderItem = null;
        List<Order_Item__c> objOrderItems = [SELECT Id, Renewal_Instruction__c FROM Order_Item__c WHERE Name=:MarsRenewalId];
        if (objOrderItems != null && objOrderItems.size()>0) 
           objOrderItem = objOrderItems[0];

        string strResult = '';
        if (objOrderItem != null)
        {
            if (RenewalInstruction == 'Cancel')
            {
                objOrderItem.Cancellation_Approval__c = 'Requested';
                objOrderItem.Cancellation_Requested_On__c = System.today();
                UPDATE objOrderItem;
                strResult = 'Message: Cancellation request received';
            }
            else
            {
                strResult = 'Message: Invalid request';
            }
        }
        else
        {
            strResult = 'Message: Invalid request';
        }
        
        return strResult ;
    }
}