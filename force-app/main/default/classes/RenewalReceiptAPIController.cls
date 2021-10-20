@RestResource(urlMapping='/renewalreceipt/*')
global class RenewalReceiptAPIController
{
    @HttpGet
    global static string getMessage() 
    {
        RestRequest req = System.RestContext.request;
        String RenewalId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        return RenewalId ;
    }
    
    /*
    @HttpGet
    global static string getAttachmentsForDocuments()
    {
        string RenewalId = '';
        List<Id> lstPatentAttachmentIds = new List<Id>();
        lstPatentAttachmentIds.add(Id.valueOf(RenewalId));
        
        Map<id,List<ContentVersion>> mapPatentDocumentDocuments = new Map<Id, List<ContentVersion>>();
        try
        {
            //Get list of ContentDocumentIds of PatentDocumentIds
            List<ContentDocumentLink> objContentDocumentLinkList = new List<ContentDocumentLink>();
            List<Id> idContentDocumentLinkList = new List<Id>();
            Map<id, Id> mapPatentDocumentContentDocuments = new Map<Id, Id>();    
            if (lstPatentAttachmentIds!=null && lstPatentAttachmentIds.size()>0)
            {
                if(Schema.sObjectType.ContentDocumentLink.isAccessible() && ContentDocumentLink.sObjectType.getDescribe().isAccessible())
                    objContentDocumentLinkList = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :lstPatentAttachmentIds];
                if (objContentDocumentLinkList!= null && objContentDocumentLinkList.size()>0)
                {
                    if (Schema.sObjectType.ContentDocumentLink .fields.ContentDocumentId.isAccessible() && Schema.sObjectType.ContentDocumentLink .fields.LinkedEntityId.isAccessible())
                    {
                        for(ContentDocumentLink objContentDocumentLink : objContentDocumentLinkList)
                        {
                            idContentDocumentLinkList.add(objContentDocumentLink.ContentDocumentId);
                            if (mapPatentDocumentContentDocuments.containsKey(objContentDocumentLink.ContentDocumentId)==false)
                                mapPatentDocumentContentDocuments.put(objContentDocumentLink.ContentDocumentId, objContentDocumentLink.LinkedEntityId);
                        }
                    }
                }
                
                //Get list of ContentVersionIds of ContentDocumentIds
                List<ContentVersion> objContentDocumentList = new List<ContentVersion>();
                
                if(Schema.sObjectType.ContentVersion.isAccessible() && ContentVersion.sObjectType.getDescribe().isAccessible())
                    objContentDocumentList =[SELECT Id, Title, FileExtension, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :idContentDocumentLinkList ORDER BY CreatedDate];
                if (objContentDocumentList!=null && objContentDocumentList.size()>0)
                {
                    for(ContentVersion objContentVersion : objContentDocumentList)
                    {
                        if (Schema.sObjectType.ContentVersion.fields.ContentDocumentId.isAccessible() && mapPatentDocumentContentDocuments.containsKey(objContentVersion.ContentDocumentId)==true)
                        {
                            Id idPatentDocumentid = mapPatentDocumentContentDocuments.get(objContentVersion.ContentDocumentId);
                            if (mapPatentDocumentDocuments.containsKey(idPatentDocumentid)==false)
                            {
                                List<ContentVersion> lstContentVersion = new List<ContentVersion>();
                                if (lstContentVersion!= null)
                                    lstContentVersion.add(objContentVersion);
                                mapPatentDocumentDocuments.put(idPatentDocumentid, lstContentVersion);
                                
                            }
                            else
                            {
                                List<ContentVersion> lstContentVersion = mapPatentDocumentDocuments.get(idPatentDocumentid);
                                if (lstContentVersion!= null)
                                    lstContentVersion.add(objContentVersion);
                            }
                        }
                    }
                }
            }
            //return mapPatentDocumentDocuments.get(RenewalId);
            return 'Success';
        }
        catch(Exception exp)
        {
            return null;
        }
    }
    */
}