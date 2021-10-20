global with sharing class APIMessage
{
    global string Code {get;set;}
    global string Type {get;set;}
    global string Message {get;set;}
    public static APIMessage GetMessage(Map<string, APIMessage__c> mapMessages, string Code)
    {
        APIMessage objAPIMessage = new APIMessage();
        if (mapMessages.containsKey(Code))
        {
            APIMessage__c objAPIMessageCO = mapMessages.get(code);
            objAPIMessage.Code = objAPIMessageCO.Name;
            objAPIMessage.Message = objAPIMessageCO.Message__c;
            objAPIMessage.Type = objAPIMessageCO.Message_Type__c; 
        }
        return objAPIMessage;
    }
}