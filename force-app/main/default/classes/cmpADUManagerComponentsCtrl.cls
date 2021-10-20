public with sharing class cmpADUManagerComponentsCtrl{
    @auraenabled
    public static string getRecords(string assetId)
    {
        string cmts = ''; 
        cmts = [select id, Comments__c from Order_Item__c where id =: assetId].Comments__c;
        if(cmts == null)
            return '';
        else
            return cmts;
    }
    @auraenabled
    public static string updateRecords(string assetId,string cmts,string newCmts)
    {
        string message = 'Success';
        try
        {
            Order_Item__c oi = NEW Order_Item__c();
            oi.id = assetId;
            oi.Comments__c = cmts+'\n\n'+UserInfo.getName()+'-'+System.now().format( 'yyyy-MM-dd hh:mm:ss a' )+'\n'+newCmts.trim();
            update oi;
        }
        catch(exception e)
        {
            message = e.getMessage();
        }
        return message;
    }
}