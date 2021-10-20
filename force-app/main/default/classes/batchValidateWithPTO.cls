public class batchValidateWithPTO implements Database.AllowsCallouts,Database.Batchable<sObject>, Database.Stateful
{
    public string query{set;get;}
    public List<ptoValidationReqWrapper> mapData{set;get;}
    public List<string> assetIDS{set;get;}
    public Map<string,List<Order_Item__c>> mapOrderItem{set;get;}
    public batchValidateWithPTO(List<string> recIds)
    {
        query = '';
        mapData = NEW List<ptoValidationReqWrapper>();
        assetIDS = NEW List<string>();
        mapOrderItem = NEW Map<string,List<Order_Item__c>>();
        
        assetIDS = recIds;
        query = 'Select id,Name,Order__r.Client__c,PTO_Validation_Request_ID__c,Paid_Status__c,Surcharge__c,'+
                    'Payment_Status__c,Order_Number__c,Client__c,Jurisdiction__c,Billing_Currency__c,Entity_Type_Name__c,'+
                    'Fee_Amount_When_Pay__c,Fee__c,Application_No__c,Patent_No__c,Publication_No__c,MV_API_Ref_Id__c,Filing_Date__c,'+
                    'Invoice_Type_Name_Value__c,Invoice__c,Invoice__r.Name,Term_Name__c FROM Order_Item__c '+
                    'WHERE ID IN: assetIDS';
    }
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
        system.debug(query+' - '+ assetIDS);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Order_Item__c> scope)
    {        
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
        system.debug(scope.size());
    }
    public void finish(Database.BatchableContext BC)
    {
        if(mapOrderItem.size()>0)
        {
            for(string cc : mapOrderItem.keyset())
            {
                List<Order_Item__c> items = mapOrderItem.get(cc);
                system.debug(items.size());
                integer a= 0;
                List<Order_Item__c> protoList = items.clone();
                protoList.clear();
                List<Order_Item__c> tempList = items.clone();
                Integer index = 0, count = 0, size = items.size();
                while(index < size) {
                    tempList.add(items.get(index++));
                    ++count;
                    if(count == 50) 
                    {
                        a = a+1;
                        ptoValidationReqWrapper wrp = NEW ptoValidationReqWrapper();
                        wrp.countryCode = cc;
                        wrp.countryAssets = tempList;
                        mapData.add(wrp);
                        system.debug(a+'-'+tempList[0].id+'>>'+tempList[tempList.size()-1].id);
                        tempList = protoList.clone();
                        count = 0;
                    }
                }
                if(!tempList.isEmpty()) {
                    a = a+1;   
                    Set<Order_Item__c> mytemp = NEW Set<Order_Item__c>();
                    mytemp.addAll(tempList);
                    tempList.clear();
                    tempList.addAll(mytemp); 
                    ptoValidationReqWrapper wrp = NEW ptoValidationReqWrapper();
                    wrp.countryCode = cc;
                    wrp.countryAssets = tempList;
                    mapData.add(wrp);
                    system.debug('Last batch: '+a+'-'+tempList[0].id+'>>'+tempList[tempList.size()-1].id+' Size:'+tempList.size());
                }
            }
            batchPtoPaymentValidateAPI cls = NEW batchPtoPaymentValidateAPI(mapData);
            database.executeBatch(cls,1);
            //batchPtoPaymentValidateBill cls = NEW batchPtoPaymentValidateBill(mapData);
            //database.executeBatch(cls,1);
        }
    }
}