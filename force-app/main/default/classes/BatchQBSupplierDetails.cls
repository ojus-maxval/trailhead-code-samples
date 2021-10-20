public class BatchQBSupplierDetails implements Database.Batchable<QBSupplierDetails.Vendor>,Database.AllowsCallouts,Database.Stateful{
    public List<QBSupplierDetails.Vendor> ListSupDetails{get;set;}
    public String accesstoken{get;set;}
    public API_Credentials__c credentials{set;get;}
    public Set<String> UniqueKeyParam = new Set<String>();
    public map<string, string> MapOfQBSuppid = new map<string, string>();
    public iterable<QBSupplierDetails.Vendor> start(Database.BatchableContext bc)
    {
        QBSupplierDetails SuppDet =new QBSupplierDetails();
        String accesstoken=SuppDet.accesstoken;
        ListSupDetails = SuppDet.getSupplierDetails(accesstoken);
         
            for(QBSupplierDetails.Vendor GetUniqueKey: ListSupDetails)
            {
                UniqueKeyParam.add(GetUniqueKey.Id);
                MapOfQBSuppid.put(GetUniqueKey.Id,GetUniqueKey.Id);
            }
        System.debug(ListSupDetails.size());
        return  ListSupDetails;
    }
    public void execute(Database.BatchableContext bc, List<QBSupplierDetails.Vendor> ListSupDetails)
    {
        List<QB_Supplier__c> ListOfSupRcd =new List<QB_Supplier__c>();
        map<string, string> MapOfQBSuppid = new map<string, string>();
        list<QB_Supplier__c> ListOfDeletedRecordsInQB = new List<QB_Supplier__c>();
        Set<String> SetOfDeletedRcdIds = new Set<String>();
        string strAuditTrail = '';
        string status = 'Success';
        strAuditTrail += 'QB Supplier Record Creation: ';
        strAuditTrail += ListSupDetails;
        try
        {
            map<string, string> ExistingRecordsSupplierid = new map<string, string>();
           
            List<QB_Supplier__c> ListOfExistingQBAccount = [SELECT Id,Name,QB_Supplier_Id__c FROM QB_Supplier__c WHERE QB_Supplier_Id__c IN:UniqueKeyParam AND IsDeleted_In_QB__c =false];
            for(QB_Supplier__c SupRcd :ListOfExistingQBAccount)
            {
                ExistingRecordsSupplierid.put(SupRcd.QB_Supplier_Id__c, SupRcd.Id);
                System.debug('ExistingRecordsSupplierid'+ExistingRecordsSupplierid);
               
                
            }
            List<QB_Supplier__c> ListOfDeletedQBSupplierRcds = [SELECT Id,Name,QB_Supplier_Id__c FROM QB_Supplier__c WHERE QB_Supplier_Id__c NOT IN:UniqueKeyParam AND IsDeleted_In_QB__c =false];
            for(QB_Supplier__c SupRcd :ListOfDeletedQBSupplierRcds)
            {
                SetOfDeletedRcdIds.add(SupRcd.id);
                //System.debug('ExistingRecordsCustomerid'+ExistingRecordsCustomerid);
            }
            for(QBSupplierDetails.Vendor Rcd :ListSupDetails)
            {
                QB_Supplier__c Sup = new QB_Supplier__c();
                Sup.Name = Rcd.CompanyName;
                Sup.Active__c = Rcd.Active;
                Sup.QB_Supplier_Id__c = Rcd.Id;
                if(Rcd.PrimaryEmailAddr != null && Rcd.PrimaryEmailAddr.Address != '')
                	Sup.Primary_Email__c = Rcd.PrimaryEmailAddr.Address;
                String formatedDt = Rcd.MetaData.CreateTime;
                DateTime date1 = (DateTime)Json.deserialize('"'+formatedDt+'"', DateTime.class);
                Sup.Record_Create_Time__c = date1;
                String formatedUpdateDt = Rcd.MetaData.LastUpdatedTime;
                DateTime LastUpdatedTime = (DateTime)Json.deserialize('"'+formatedUpdateDt+'"', DateTime.class);
                Sup.Last_Updated_Time__c =LastUpdatedTime;
                if(ExistingRecordsSupplierid.get(Rcd.Id) != NULL )
                {
                    Sup.Id = ExistingRecordsSupplierid.get(Rcd.Id);
                }
                ListOfSupRcd.add(Sup);
                
            }
            if(ListOfSupRcd.size() > 0)
            {
                upsert ListOfSupRcd;
            }
             if(SetOfDeletedRcdIds.size() > 0)
            {
                List<QB_Supplier__c> ListOfExistingQBSupplier = [SELECT Id,IsDeleted_In_QB__c FROM QB_Supplier__c WHERE Id IN:SetOfDeletedRcdIds AND IsDeleted_In_QB__c =false];
				 for(QB_Supplier__c Supp: ListOfExistingQBSupplier)
                {
                    Supp.IsDeleted_In_QB__c = true;
                    ListOfDeletedRecordsInQB.add(Supp);
                }
                if(ListOfDeletedRecordsInQB.size() > 0)
                {
                    update ListOfDeletedRecordsInQB;
                } 
            }
        }
        catch(Exception e)
        {
            strAuditTrail += ' || Error :'+e.getMessage() + ' | at Line No: ' + e.getLineNumber();
            status = 'Fail';
        }
        finally
        {
            system.debug(strAuditTrail);
            AuditTrailHelper.UpdateAudit('batchQBSupplierDetails',strAuditTrail,status);
        }
    }
    public void finish(Database.BatchableContext bc)
    {
        
    }
   

	

}