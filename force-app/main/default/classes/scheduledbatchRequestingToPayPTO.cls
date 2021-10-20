global class scheduledbatchRequestingToPayPTO implements Schedulable {
    global void execute(SchedulableContext sc) {
        //batchRequestingToPayPTO b = new batchRequestingToPayPTO(); 
        List<string> cIds = NEW List<string>();
        for(clients__c client : [select id from clients__c])
        {
            cIds.add(client.id);
        }
        if(cIds.size()>0)
        {
            //batchPtoPaymentValidate b = new batchPtoPaymentValidate(cIds); 
            //database.executebatch(b,1);
            batchPtoPaymentValidateAPI b = new batchPtoPaymentValidateAPI();
            database.executebatch(b,1);
        }
    }
}