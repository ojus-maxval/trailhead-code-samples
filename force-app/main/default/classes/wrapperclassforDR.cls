global  with sharing class wrapperclassforDR{
   global Integer page {get;set;}
   global List<Docketing_Rule_Engine__c> rules{get;set;}
   global wrapperclassforDR(Integer pageint,List<Docketing_Rule_Engine__c> ruleslst)
   {
       page =pageint;
       rules=ruleslst;
   }
}