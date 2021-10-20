public without sharing class Send_invoice_asset{
 @AuraEnabled
    public static string Send_invoice(String parentRecId) {

        String resultStr = '';
        
        try {
             List < Order_Item__c> Lstorder = [select id,Is_it_renewed_in_PTO__c from Order_Item__c where id =: parentRecId ];
            system.debug('^^^' + Lstorder .size());
            if (Lstorder .size() ==1  ){
                if(Lstorder[0].Is_it_renewed_in_PTO__c==false){
                  Order_Item__c orderupdate=new Order_Item__c ();
                  orderupdate.id=parentRecId;
                  orderupdate.Is_it_renewed_in_PTO__c=true;
                  update orderupdate;
                 resultStr = 'successfully renewed.';
                } else {
                    resultStr = 'ERROR:We cant renewe as it is already renewed';
                }
            } else {
                resultStr = 'ERROR:please select only one record to to renew';
            }

        }
        Catch(Exception Ex) {
            resultStr = 'ERROR:' + Ex.getMessage();
        }
        return resultStr;
    }


}