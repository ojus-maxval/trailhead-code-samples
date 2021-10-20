public with sharing class cmpAssetFilingReceiptUploadDownloadCtrl
{
    @auraenabled
    public static wrpData getRecord(string assetId)
    {
    
        wrpData wd = NEW wrpData();
        List<Order_Item__c> ois = [select id, Filing_Receipt_Uploaded__c, Filing_Receipt_File_Id__c FROM Order_Item__c where id =: assetId];
        if(ois.size() > 0)
        {
            string FileId = '';
            if(ois[0].Filing_Receipt_File_Id__c!=null && ois[0].Filing_Receipt_Uploaded__c)
            {
                List<ContentVersion> cv = [SELECT ID,Title,FileExtension,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId =: ois[0].Filing_Receipt_File_Id__c ];
                if(cv.size()>0)
                {
                    wd.fileId = cv[0].id;
                    wd.fileConDocId = cv[0].ContentDocumentId;
                    wd.fileName = cv[0].Title+'.'+cv[0].FileExtension;
                    wd.fileuploaded = ois[0].Filing_Receipt_Uploaded__c;
                }
                else
                    wd.fileuploaded = false;
            }
            else
                wd.fileuploaded = false;
            return wd;
        }
        else
            return wd;
    }
    @auraenabled
    public static wrpData updateRecord(string assetId, string fileId)
    {
        List<ContentVersion> cv = [SELECT ID,Title,FileExtension,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId=: fileId Limit 1 ] ;
        wrpData wd = NEW wrpData();
        
        Order_Item__c oi = NEW Order_Item__c();
        oi.id = assetId;
        oi.Filing_Receipt_File_Id__c = fileId;
        oi.Filing_Receipt_Uploaded__c = true;
        update oi;
        if(cv.size()>0)
        {
            wd.fileId = cv[0].id ;
            wd.fileConDocId = cv[0].ContentDocumentId;
            wd.fileName = cv[0].Title+'.'+cv[0].FileExtension;
            wd.fileuploaded = oi.Filing_Receipt_Uploaded__c;
        }
        else
            wd.fileuploaded = false;
        return wd;
    }
    @auraenabled
    public static wrpData deleteFileRecord(string assetId, string fileId, string fileDocId)
    {
        ContentDocument cd = NEW ContentDocument();
        cd.id = fileDocId;
        delete cd;
        
        wrpData wd = NEW wrpData();
        
        Order_Item__c oi = NEW Order_Item__c();
        oi.id = assetId;
        oi.Filing_Receipt_File_Id__c = null;
        oi.Filing_Receipt_Uploaded__c = false;
        update oi;
        
        wd.fileId = null ;
        wd.fileName = null;
        wd.fileuploaded = false;
        return wd;
    }
    public class wrpData
    {
        @auraenabled public string fileId{set;get;}
        @auraenabled public string fileConDocId{set;get;}
        @auraenabled public string fileName{set;get;}
        @auraenabled public boolean fileuploaded{set;get;}
    }
}