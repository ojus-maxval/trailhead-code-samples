public with sharing class APIMessageController
{
    public static Map<string, APIMessage__c> GetAllMessages()
    {
        Map<string, APIMessage__c> mapMessages =  new Map<string, APIMessage__c>();
        List<APIMessage__c> objMessages = [SELECT Id, Name, Message__c, Message_Type__c FROM APIMessage__c];
        for(APIMessage__c objMessage : objMessages)
        {
            if (mapMessages.containsKey(objMessage.Name) == false)
            {
                mapMessages.put(objMessage.Name, objMessage);
            }
        }
        return mapMessages;
    }
}