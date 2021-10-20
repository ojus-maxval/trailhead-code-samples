public with sharing class AttachmentController
{
    @AuraEnabled
    public static List<ContentVersion> getAttachedDocuments(Id LinkedEntityId) 
    {
        try
        {
            List<ContentVersion> lstContentVersions = new List<ContentVersion>();
            List<Id> lstLinkedEntityIds = new List<Id>();
            lstLinkedEntityIds.add(LinkedEntityId);
            Map<Id, List<ContentVersion>> mapContentVersionReviewer = HelperAttachments.getAttachmentsForDocuments(lstLinkedEntityIds);
            if (mapContentVersionReviewer.containsKey(LinkedEntityId))
                lstContentVersions = mapContentVersionReviewer.get(LinkedEntityId);
            return lstContentVersions;
        }
        catch(Exception exp)
        {
            throw exp;
        }
    }
    @AuraEnabled
    public static List<ContentVersion> getCurrentAttachedDocuments(Id LinkedEntityId, List<Id> lstDocumentId) 
    {
        try
        {
            List<ContentVersion> lstContentVersions = new List<ContentVersion>();
            List<Id> lstLinkedEntityIds = new List<Id>();
            lstLinkedEntityIds.add(LinkedEntityId);
            Map<Id, List<ContentVersion>> mapContentVersionReviewer = HelperAttachments.getCurrentAttachmentsForDocuments(lstLinkedEntityIds, lstDocumentId);
            if (mapContentVersionReviewer.containsKey(LinkedEntityId))
                lstContentVersions = mapContentVersionReviewer.get(LinkedEntityId);
            return lstContentVersions;
        }
        catch(Exception exp)
        {
            throw exp;
        }
    }
    @AuraEnabled
    public static string deleteAttachment(Id contentVersionId) 
    {
        try
        {
            string contentDocumentId = '';
            List<Id> idContentDocuments = new List<Id>();
            List<ContentVersion> objContentVersionList = new List<ContentVersion>();
            if(Schema.sObjectType.ContentVersion.isAccessible() && ContentVersion.sObjectType.getDescribe().isAccessible())
                objContentVersionList = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =:contentVersionId];
            for(ContentVersion objContentVersion : objContentVersionList)
            {
                idContentDocuments.add(objContentVersion.ContentDocumentId); 
            }
            List<ContentDocument> objContentDocumentList = new List<ContentDocument>();
            if(Schema.sObjectType.ContentDocument.isAccessible() && ContentDocument.sObjectType.getDescribe().isAccessible())
                objContentDocumentList = [SELECT Id FROM ContentDocument WHERE Id IN :idContentDocuments];
            if (objContentDocumentList != null && objContentDocumentList.size()>0 && Schema.sObjectType.ContentDocument.isDeletable()  && ContentDocument.sObjectType.getDescribe().isDeletable())
            {
                contentDocumentId = objContentDocumentList[0].Id;
                DELETE objContentDocumentList ;
            }
            return contentDocumentId;
        }
        catch(Exception exp)
        {
            return 'Fail';
        }
        
    }
}