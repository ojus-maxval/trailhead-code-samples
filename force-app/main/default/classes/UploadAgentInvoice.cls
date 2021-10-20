public with sharing class UploadAgentInvoice
{
    list<string> lstid=new list<string>();
    public list<string> SelectedOrderItemIDs{get;set;}
    public UploadAgentInvoice(ApexPages.StandardSetController listcontroller)
    {
        SelectedOrderItemIDs = new list<string>{};            
        for(Order_Item__c orderItem : (Order_Item__c[])listcontroller.getSelected())
        {
            SelectedOrderItemIDs.add(orderItem.Id);
            lstid.add(orderItem.Id); 
        } 
        system.debug('>>'+SelectedOrderItemIDs+' >> '+lstid);
    }
    
  /*  @AuraEnabled
    public static string CretateAssetFilingReceipt(List<String> lstIds)
    {
        Profile p = [Select Name from Profile where Id =: userinfo.getProfileid()];
        String pname = p.name;
        List<String> objOrderItemIds = NEW List<String>();
        if(pname !='RTU')
        {
            return 'NotRTU';
        }
        else
        {
            
        }
        if(lstIds.size() > 0 && lstIds.size() < 2)
        {
            if(lstIds[0].contains('[')||lstIds[0].contains(']'))
            {
                lstIds[0] = lstIds[0].remove('[');
                lstIds[0] = lstIds[0].remove(']');
                if(lstIds[0].contains(','))
                {
                    lstIds[0] = lstIds[0].replaceAll( '\\s+', '');
                    objOrderItemIds = lstIds[0].split(',');
                }
                else
                    objOrderItemIds.add(lstIds[0]);
            }
        }
        Filing_Receipt__c fr = NEW Filing_Receipt__c();
        insert fr;
        List<Asset_Filing_Receipt__c> objAFRs = NEW List<Asset_Filing_Receipt__c>();
        List<Order_Item__c> orderItems = [Select id from Order_Item__c WHERE ID IN: objOrderItemIds];
        for(Order_Item__c oi : orderItems)
        {
            Asset_Filing_Receipt__c afr = NEW Asset_Filing_Receipt__c();
            afr.Asset__c = oi.id;
            afr.Filing_Receipt__c = fr.id;
            objAFRs.add(afr);
        }
        string result = fr.id;
        try{
            if(objAFRs.size()>0)
                insert objAFRs;
        }
        catch(Exception ex)
        {
            result = 'Error : '+ ex.getMessage();
        }
        return result;
    }
    @AuraEnabled
    public static string updateRecord(string filingReceiptID, String ListOfIds)
    {
        String result = 'Success';
        Filing_Receipt__c fr = NEW Filing_Receipt__c();
        fr.id = filingReceiptID;
       // fr.Is_Temporary__c = isTemperory;
        try{
            update fr;
        }
        catch(Exception e)
        {
            result = 'Error : '+e.getMessage();
        }
        return result;
    } 
   @AuraEnabled
    public static Id saveChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId) {
        // check if fileId id ''(Always blank in first chunk), then call the saveTheFile method,
        //  which is save the check data and return the attachemnt Id after insert, 
        //  next time (in else) we are call the appentTOFile() method
        //   for update the attachment with reamins chunks   
        if (fileId == '') {
            
                fileId = saveTheFile(parentId, fileName, base64Data, contentType);
                
        } else {
            appendToFile(fileId, base64Data);
        }
 
        return Id.valueOf(fileId);
    }
 
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) {
      		   System.debug('parentIdsaveTheFile'+parentId);
            base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
            
            Attachment oAttachment = new Attachment();
            oAttachment.parentId = parentId;
            
            oAttachment.Body = EncodingUtil.base64Decode(base64Data);
            oAttachment.Name = fileName;
            oAttachment.ContentType = contentType;
           
        insert oAttachment;
 
        return oAttachment.id;
    }
 
    private static void appendToFile(Id fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
 
        Attachment a = [
            SELECT Id, Body
            FROM Attachment
            WHERE Id =: fileId
        ];
 
        String existingBody = EncodingUtil.base64Encode(a.Body);
 
        a.Body = EncodingUtil.base64Decode(existingBody + base64Data);
 
        update a;
    }
    //Multiple FIles
     @AuraEnabled
    public static Id saveFile(String parentId, String fileName, String base64Data, String contentType, String fileId) {
        // check if fileId id ''(Always blank in first chunk), then call the saveTheFile method,
        //  which is save the check data and return the attachemnt Id after insert,
        //  next time (in else) we are call the appentTOFile() method
        //   for update the attachment with remains chunks
        if (fileId == '') {
            List<Attachment> ListOfAttachment = new List<Attachment>();
            if(parentId.contains('[') )
            {
                parentId= parentId.remove('[');
            }
            if(parentId.contains(']') )
            {
                 parentId= parentId.remove(']');
            }
             System.debug('parentId'+parentId);
            List<String> ListOfRcdIds = parentId.trim().split(',');
            System.debug(ListOfRcdIds.size());
            System.debug('ListOfRcdIds'+ListOfRcdIds[0]);
            for(Integer i=0; i<ListOfRcdIds.size(); i++)
            {
                System.debug('ListOfRcdIdsinsideFor'+ListOfRcdIds[i]);
                ID TempId =ListOfRcdIds[i];
                fileId = saveTheFile(TempId, fileName, base64Data, contentType);
            }
        } else {
            appendToFile(fileId, base64Data);
        }
          System.debug('FieldId'+Id.valueOf(fileId));
        return Id.valueOf(fileId);
    }
       @AuraEnabled
    public static Id saveFile(Id parentId, String fileName, String base64Data, String contentType, String fileId) {
        // check if fileId id ''(Always blank in first chunk), then call the saveTheFile method,
        //  which is save the check data and return the attachemnt Id after insert,
        //  next time (in else) we are call the appentTOFile() method
        //   for update the attachment with remains chunks
        if (fileId == '') {
            fileId = saveTheFile(parentId, fileName, base64Data, contentType);
              System.debug('fileId>>>'+fileId);
        } else {
           System.debug('Else>>>'+fileId);
            appendToFile(fileId, base64Data);
        }
        System.debug('testtt>>>'+Id.valueOf(fileId));
        return Id.valueOf(fileId);
    }*/
    @AuraEnabled
    public static WrapCls ValidationCheck(String listofids)
    {
        List<Id> ListOfRcdIdsToQuery =new List<Id>(); 
        Id TempId;
        Boolean ValidationOnAgentStatus = false;
        WrapCls wrp=new WrapCls();
        if(listofids.contains('[') )
        {
            listofids= listofids.remove('[');
        }
        if(listofids.contains(']') )
        {
            listofids= listofids.remove(']');
        }
        System.debug('listofids'+listofids);
        List<String> ListOfRcdIds = listofids.trim().split(',');
        System.debug(ListOfRcdIds.size());
        for(Integer i=0; i<ListOfRcdIds.size(); i++)
        {
            TempId = ListOfRcdIds[i].replaceAll( '\\s+', '');
            ListOfRcdIdsToQuery.add(TempId);
        }
        list<Order_Item__c> ListOrdItem = [Select Id,Agent_Status__c From Order_Item__c Where Id IN: ListOfRcdIdsToQuery AND Agent_Status__c ='Awaiting Agent Invoice'];
        if(ListOfRcdIdsToQuery.size() != ListOrdItem.size())
        {
           wrp.ValidationOnAgentStatus =true;
        }else
        {
            wrp.ValidationOnAgentStatus =false;
        }
         List<ListView> listviews = [SELECT Id, Name FROM ListView WHERE SobjectType = 'Order_Item__c' AND DeveloperName='Upload_Agent_Invoice' LIMIT 1];
         wrp.ListViewName =listviews[0].Id;
        return wrp;
    }
    @AuraEnabled
    public static Id saveFile(String parentId, String fileName, String base64Data, String contentType, String fileId) {
        // check if fileId id ''(Always blank in first chunk), then call the saveTheFile method,
        //  which is save the check data and return the attachemnt Id after insert,
        //  next time (in else) we are call the appentTOFile() method
        //   for update the attachment with remains chunks
         ID TempId;
        if (fileId == '') {
           // List<Attachment> ListOfAttachment = new List<Attachment>();
            if(parentId.contains('[') )
            {
                parentId= parentId.remove('[');
            }
            if(parentId.contains(']') )
            {
                 parentId= parentId.remove(']');
            }
             System.debug('parentId'+parentId);
            List<String> ListOfRcdIds = parentId.trim().split(',');
            System.debug(ListOfRcdIds.size());
            System.debug('ListOfRcdIds'+ListOfRcdIds[0]);
            list<Order_Item__c> ListOI =new list<Order_Item__c>();
            
            for(Integer i=0; i<ListOfRcdIds.size(); i++)
            {
                System.debug('ListOfRcdIdsinsideFor'+ListOfRcdIds[i]);
                TempId = ListOfRcdIds[i].replaceAll( '\\s+', '');
                fileId = saveTheFile(TempId, fileName, base64Data, contentType);
                Order_Item__c OI =new Order_Item__c();
                OI.Id =TempId;
                OI.Agent_Status__c ='Approve Agent Invoice';
                //update OI;
                ListOI.add(OI);
                TempId = Id.valueOf(fileId);
                
            }
            update ListOI;
        } else {
            appendToFile(fileId, base64Data);
        }
          //System.debug('FieldId'+Id.valueOf(fileId));
        return TempId;
    }
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        Attachment oAttachment = new Attachment();
        oAttachment.parentId = parentId;
        
        oAttachment.Body = EncodingUtil.base64Decode(base64Data);
        oAttachment.Name = fileName;
        oAttachment.ContentType = contentType;
        
        insert oAttachment;   
        
        return oAttachment.Id;
    }
    
    public static void appendToFile(Id fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');        
        Attachment a = [
            SELECT Id, Body
            FROM Attachment
            WHERE Id = : fileId
        ];
        
        String existingBody = EncodingUtil.base64Encode(a.Body);        
        a.Body = EncodingUtil.base64Decode(existingBody + base64Data);        
        update a;
    }
      public class WrapCls{
        @auraEnabled
        public boolean ValidationOnAgentStatus {get;set;}
        @auraEnabled
        public String ListViewName {get;set;}
    }
    
   

}