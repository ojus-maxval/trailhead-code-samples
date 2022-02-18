/* Copyright © 2021 MaxVal Group. All Rights Reserved.
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */
public with sharing class WindowConfigurationHelper
{
    public static string GetLEDESClientId(string client){
        string ledesClientId = '';
        List<LEDESClientId__mdt> ledesClientIds = [SELECT ClientId__c,MasterLabel FROM LEDESClientId__mdt WHERE MasterLabel =:client LIMIT 1];
        if(ledesClientIds.size() > 0)
            ledesClientId = ledesClientIds[0].ClientId__c;
       	return ledesClientId;
    }
}
