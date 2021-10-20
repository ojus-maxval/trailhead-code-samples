/* Copyright © 2021 MaxVal Group. All Rights Reserved.
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Saranyaa C, August 2021
 */
global with sharing class GenerateCreditMemoBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful
{
    Public List<Id> lstGenerateCreditMemoIds = new List<Id>();
    String strAuditText = '';
    global GenerateCreditMemoBatch()
    {
    }
    global GenerateCreditMemoBatch(List<Id> Ids)
    {        
        lstGenerateCreditMemoIds = Ids;
    }
     global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator([
            SELECT 
            Id
            FROM Credit_Memo__c
            WHERE Id =:lstGenerateCreditMemoIds ]);
    }
    
    /*
     * Gets all creditmemorefs for processing.
	*/
     global void execute(Database.BatchableContext BC, List<sObject> Ids)
    {
        strAuditText += 'GenerateCreditMemoBatch execution started | ';
        List<Credit_Memo__c> creditMemos = new List<Credit_Memo__c>();
        creditMemos = [SELECT Id,Name FROM Credit_Memo__c WHERE Id IN: lstGenerateCreditMemoIds];
        strAuditText += 'No of creditmemo ids: ' + string.valueOf(creditMemos.size() + ' | ');        
    }
    
    /*
     * Calls Batch process.
	*/
    global void finish(Database.BatchableContext BC)
    {        
        BatchRenewalCreditMemoCreate objBatchRenewalCreditMemoCreate =  new BatchRenewalCreditMemoCreate(lstGenerateCreditMemoIds);
        Database.executeBatch(objBatchRenewalCreditMemoCreate, 1);
        strAuditText += 'GenerateCreditMemoBatch execution completed | ';
    }

}