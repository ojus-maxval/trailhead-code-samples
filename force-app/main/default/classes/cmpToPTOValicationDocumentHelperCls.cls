public class cmpToPTOValicationDocumentHelperCls {
	@auraenabled
    public static wrpData getRecord(string assetId)
    {    
        wrpData wd = NEW wrpData();
        List<Order_Item__c> ois = [select id, PTO_Validation_Document__c FROM Order_Item__c where id =: assetId];
        if(ois.size() > 0)
        {
            string FileId = '';
            if(ois[0].PTO_Validation_Document__c!=null)
            {
                List<ContentVersion> cv = [SELECT ID,Title,FileExtension,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId =: ois[0].PTO_Validation_Document__c ];
                if(cv.size()>0)
                {
                    wd.fileId = cv[0].id;
                    wd.fileConDocId = cv[0].ContentDocumentId;
                    wd.fileName = cv[0].Title+'.'+cv[0].FileExtension;
                }
            }
            return wd;
        }
        else
            return wd;
    }
    public class wrpData
    {
        @auraenabled public string fileId{set;get;}
        @auraenabled public string fileConDocId{set;get;}
        @auraenabled public string fileName{set;get;}
    }
}