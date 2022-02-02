public class batchValidateWithPTO implements Database.AllowsCallouts,Database.Batchable<sObject>, Database.Stateful
{
    public string query{set;get;}
    public List<ptoValidationReqWrapper> mapData{set;get;}
    public List<string> orderIds{set;get;}
    public List<Id> assetIds{set;get;}
    List<Order__c> orders{set;get;}
    public Map<string,List<Order_Item__c>> mapOrderItem{set;get;}
    public string strAuditTrail{set;get;}
    public string status{set;get;}
    public batchValidateWithPTO()
    {
        query = '';
        mapData = NEW List<ptoValidationReqWrapper>();
        orderIds = NEW List<string>();
        orders = NEW List<Order__c>();
        mapOrderItem = NEW Map<string,List<Order_Item__c>>();
        orders = [SELECT Id,Validation_Request_Status__c FROM Order__c WHERE Order_Status__c=:'Order Placed' AND Validation_Request_Status__c!='Success'];
        for(Order__c order:orders)
        {
            orderIds.add(order.Id);
        }
        query = 'Select id,Name,Order__r.Client__c,PTO_Validation_Request_ID__c,Paid_Status__c,Surcharge__c,'+
                    'Payment_Status__c,Order_Number__c,Client__c,Jurisdiction__c,Billing_Currency__c,Entity_Type_Name__c,'+
                    'Fee_Amount_When_Pay__c,Fee__c,Application_No__c,Patent_No__c,MV_API_Ref_Id__c,Filing_Date__c,'+
                    'Invoice_Type_Name_Value__c,Invoice__c,Invoice__r.Name,Term_Name__c FROM Order_Item__c '+
                    'WHERE Order__c IN: orderIds';
    }
    public batchValidateWithPTO(List<Id> assetId)
    {
        assetIds = NEW List<Id>(); 
        assetIds=assetId;
        orders = NEW List<Order__c>();
        orderIds = NEW List<string>();
        query = '';
        mapData = NEW List<ptoValidationReqWrapper>();
        mapOrderItem = NEW Map<string,List<Order_Item__c>>();
        query = 'Select id,Name,Order__r.Client__c,PTO_Validation_Request_ID__c,Paid_Status__c,Surcharge__c,'+
                    'Payment_Status__c,Order_Number__c,Client__c,Jurisdiction__c,Billing_Currency__c,Entity_Type_Name__c,'+
                    'Fee_Amount_When_Pay__c,Fee__c,Application_No__c,Patent_No__c,MV_API_Ref_Id__c,Filing_Date__c,'+
                    'Invoice_Type_Name_Value__c,Invoice__c,Invoice__r.Name,Term_Name__c FROM Order_Item__c '+
                    'WHERE Id IN: assetIds';
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Order_Item__c> scope)
    {
        strAuditTrail='BatchValidateWithPTO class invoked|';
        strAuditTrail+='New OrderIds - '+orderIds+'|';
        for(Order_Item__c oi : scope)
        {
            List<Order_Item__c> temp = mapOrderItem.get(oi.Jurisdiction__c);
            if(temp != null)
            {
                temp.add(oi);
            }
            else
            {
                mapOrderItem.put(oi.Jurisdiction__c, new List<Order_Item__c>{oi});
            }
        }
        strAuditTrail+='scopeSize - '+scope.size()+'|';
    }
    public void finish(Database.BatchableContext BC)
    {
        List<Order__c> orderToBeUpdated=new List<Order__c>();
        try
        {
            if(mapOrderItem.size()>0)
            {
                for(string cc : mapOrderItem.keyset())
                {
                    List<Order_Item__c> items = mapOrderItem.get(cc);
                    ptoValidationReqWrapper wrp = NEW ptoValidationReqWrapper();
                    wrp.countryCode = cc;
                    wrp.countryAssets = items;
                    mapData.add(wrp);
                }
                status='Success';
                for(Order__c order:orders)
                {
                    order.Validation_Request_Status__c='Success';
                    orderToBeUpdated.add(order);
                }
                batchPtoPaymentValidateAPI cls = NEW batchPtoPaymentValidateAPI(mapData);
                database.executeBatch(cls,1);
                if(orderToBeUpdated.size()>0)
                	update orderToBeUpdated;
            }
        }
        catch(exception e)
        {
            for(Order__c order:orders)
            {
                order.Validation_Request_Status__c='Failed';
                orderToBeUpdated.add(order);
            }
            if(orderToBeUpdated.size()>0)
            	update orderToBeUpdated;
            status = 'Fail';
            strAuditTrail += ' || Error :'+e.getMessage()+' | Line No:'+e.getLineNumber()+' | Cause: '+e.getCause();
            system.debug('Error :'+e.getMessage()+' | Line No:'+e.getLineNumber()+' | Cause: '+e.getCause());
        }
        finally
        {
            system.debug(strAuditTrail);
            AuditTrailHelper.UpdateAudit('BatchValidateWithPTO',strAuditTrail,status);
        }
    }
}