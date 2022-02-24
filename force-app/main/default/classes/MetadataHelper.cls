public with sharing class MetadataHelper
{
    public static List<LEDESClientId__mdt> GetLEDESDetails(string client){      
        List<LEDESClientId__mdt> ledesClientIds = new List<LEDESClientId__mdt>();
         ledesClientIds   = [SELECT LineItemExpensesCode__c,ClientId__c,MatterId__c,MatterName__c,LawFirmMatterId__c,MasterLabel FROM LEDESClientId__mdt WHERE MasterLabel =:client LIMIT 1];
       	return ledesClientIds;
    }    
}