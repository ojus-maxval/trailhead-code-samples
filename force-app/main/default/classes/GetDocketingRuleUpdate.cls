@RestResource(urlMapping='/v1/GetDocketingRuleUpdates/*')
   global with sharing class GetDocketingRuleUpdate{
     @Httpget
      global static list<Docketing_Rule_Engine__c> FetchDocketingRules(){
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
      
       
        Integer offsetnumber = Integer.valueof(req.requestURI.substring(req.requestURI.lastIndexOf('/')+1));
        
        Decimal LatestRuleUpdatedDate = [select id,RuleUpdatedOn__c from Docketing_Rule_Engine__c Order by RuleUpdatedOn__c DESC LIMIT 1].RuleUpdatedOn__c;
        system.debug(LatestRuleUpdatedDate);
        list<Docketing_Rule_Engine__c> LatestRules = new list<Docketing_Rule_Engine__c>();
        LatestRules = [select id,RuleUpdatedOn__c,AdjustmentType__c,Adjust_to_a_Specific_Date__c,Asset_Type__c,Base_Date_1__c,Base_Date__c,Case_Type__c,CCount1__c,CCount__c,Classification__c,CloseYearsToCal__c,Close_Count1__c,Close_Count__c,Close_Operator1__c,Close_Operator__c,Close_Period_Type1__c,Close_Period_Type__c,Compound_Selection__c,COperator1__c,COperator__c,Count1__c,Country_Code__c,Count__c,CPeriod_Type1__c,CPeriod_Type__c,Custom_Rule__c,CYearsToCal__c,Docket_Action__c,Due__c,D_Base_Date_Compound_Calculation__c,D_Base_Type_Rule_Calculation__c,Extension_of__c,Importance__c,Life_Cycle_Stage__c,Manual_Due_Date__c,Mark_Closed__c,Mark_Completed__c,Name,Notes_Extension__c,Notes_General__c,Notes_Rule_Calculation_Description__c,Notes_Source__c,Operator1__c,Operator__c,Period_Type1__c,Period_Type__c,Rule_Active__c,Rule_Base_date__c,Rule_End_Date__c,Rule_Start_Date__c,Rule_Type__c,StartYearsToCal__c,Start_Count1__c,Start_Count__c,Start_Operator1__c,Start_Operator__c,Start_Period_Type1__c,Start_Period_Type__c,Term_Id__c,Trigger_Type__c,Trigger__c,Unique_Id__c,YearsToCal__c from Docketing_Rule_Engine__c where RuleUpdatedOn__c =: LatestRuleUpdatedDate LIMIT 100 OFFSET:offsetnumber];
        //LatestRules = [select id,RuleUpdatedOn__c,Name,Unique_Id__c,Base_Date__c,Case_Type__c from Docketing_Rule_Engine__c where RuleUpdatedOn__c =: LatestRuleUpdatedDate];
        system.debug(LatestRules.size());
        return LatestRules;
      }
   }