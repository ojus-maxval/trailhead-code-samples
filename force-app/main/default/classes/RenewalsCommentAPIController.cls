@RestResource(urlMapping='/comments/*')
global class RenewalsCommentAPIController 
{
    @HttpPost
    global static void CommentRenewals( string Message) //, string sendBy, string ClientOrgId
    {
        Message__c objmessage = new Message__c();
        objmessage.Text_Message__c =  Message;
        
        INSERT  objmessage;
        
        /*Message__c MessageCreated = [SELECT Id, Text_Message__c FROM Message__c WHERE Id = :objmessage.Id];
        return 'Success';*/
    }
        
        

}