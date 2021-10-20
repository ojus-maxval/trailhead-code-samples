public class BatchQBAccountDetails implements Database.Batchable<QBAccountDetails.Account>,Database.AllowsCallouts,Database.Stateful{
    public List<QBAccountDetails.Account> ListAccDetails{get;set;}
    public String accesstoken{get;set;}
    public API_Credentials__c credentials{set;get;}
    public map<string, string> MapOfQBAcctid = new map<string, string>();
    public Set<String> UniqueKeyParam = new Set<String>();
    public iterable<QBAccountDetails.Account> start(Database.BatchableContext bc)
    {
        QBAccountDetails AccDet =new QBAccountDetails();
        String accesstoken=AccDet.accesstoken;
        ListAccDetails = AccDet.getAccountDetails(accesstoken);
        for(QBAccountDetails.Account GetUniqueKey: ListAccDetails)
        {
            UniqueKeyParam.add(GetUniqueKey.Id);
            MapOfQBAcctid.put(GetUniqueKey.Id,GetUniqueKey.Id);
        }
        System.debug(ListAccDetails.size());
        return  ListAccDetails;
    }
    public void execute(Database.BatchableContext bc, List<QBAccountDetails.Account> ListAccDetails)
    {
        List<QB_Account__c> ListOfAccRcd =new List<QB_Account__c>();
        
        list<QB_Account__c> ListOfDeletedRecordsInQB = new List<QB_Account__c>();
        Set<String> SetOfDeletedRcdIds = new Set<String>();
        string strAuditTrail = '';
        string status = 'Success';
        strAuditTrail += 'QB Account Record Creation: ';
        strAuditTrail += ListAccDetails;
        try
        {
            map<string, string> ExistingRecordsAccountid = new map<string, string>();
            
            
            List<QB_Account__c> ListOfExistingQBAccount = [SELECT Id,Name,QB_Account_Id__c FROM QB_Account__c WHERE QB_Account_Id__c IN:UniqueKeyParam AND IsDeleted_In_QB__c =false];
            for(QB_Account__c ActRcd :ListOfExistingQBAccount)
            {
                ExistingRecordsAccountid.put(ActRcd.QB_Account_Id__c, ActRcd.Id);
                //System.debug('ExistingRecordsAccountid'+ExistingRecordsAccountid);
                
            }
            List<QB_Account__c> ListOfDeletedQBAccountRcds = [SELECT Id,Name,QB_Account_Id__c FROM QB_Account__c WHERE QB_Account_Id__c NOT IN:UniqueKeyParam AND IsDeleted_In_QB__c =false];
            for(QB_Account__c ActRcd :ListOfDeletedQBAccountRcds)
            {
                SetOfDeletedRcdIds.add(ActRcd.id);
            }
            System.debug('SetOfDeletedRcdIds>>>'+SetOfDeletedRcdIds.size());
            for(QBAccountDetails.Account Rcd :ListAccDetails)
            {
                QB_Account__c Acc = new QB_Account__c();
                Acc.Name = Rcd.Name;
                Acc.Active__c = Rcd.Active;
                Acc.QB_Account_Id__c = Rcd.Id;
                Acc.Account_Type__c =Rcd.AccountType;
                if(ExistingRecordsAccountid.get(Rcd.Id) != NULL )
                {
                    Acc.Id = ExistingRecordsAccountid.get(Rcd.Id);
                }
                ListOfAccRcd.add(Acc);
                
            }
            if(ListOfAccRcd.size() > 0)
            {
                upsert ListOfAccRcd;
            }
            if(SetOfDeletedRcdIds.size() > 0)
            {
                List<QB_Account__c> ListOfDeletedQBAccount = [SELECT Id,IsDeleted_In_QB__c FROM QB_Account__c WHERE Id IN:SetOfDeletedRcdIds AND IsDeleted_In_QB__c =false];
                for(QB_Account__c Acct: ListOfDeletedQBAccount)
                {
                    Acct.IsDeleted_In_QB__c = true;
                    ListOfDeletedRecordsInQB.add(Acct);
                }
                if(ListOfDeletedRecordsInQB.size() > 0)
                {
                    update ListOfDeletedRecordsInQB;
                } 
            }
        }
        catch(Exception e)
        {
            strAuditTrail += ' || Error :'+e.getMessage();
            status = 'Fail';
        }
        finally
        {
            system.debug(strAuditTrail);
            AuditTrailHelper.UpdateAudit('batchQBAccountDetails',strAuditTrail,status);
        }
    }
    public void finish(Database.BatchableContext bc)
    {
        
    }
   

	

}