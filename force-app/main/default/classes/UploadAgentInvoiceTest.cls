@isTest
public class UploadAgentInvoiceTest {
    @isTest 
    public static void Method1()
    {
	API_Credentials__c cre=new API_Credentials__c();
        cre.name='PTO Payment Validate';
        cre.Username__c='test';
        cre.URL__c='https://google.com';
        cre.Password__c='test';
        insert cre;
        Clients__c objclient =new Clients__c();
        objclient.Name='QCOMM';
        Insert objclient ;
        order__c Objorder = new order__c();
        Objorder.Client__c=objclient.id;
        Insert Objorder;
        Order_Item__c Objorderitem = new Order_Item__c();
        Objorderitem.order__c=Objorder.id; 
        //Objorderitem.Client__c=objclient.id;
        //Objorderitem.Suggested_Open_Date_To_Pay__c=system.today()-1; 
        Objorderitem.Suggested_Close_Date_To_Pay__c=system.today()-1; 
        Objorderitem.Payment_Status__c='Payment Received'; 
        Objorderitem.Paid_Status__c=null;
        Objorderitem.Renewal_Instruction__c='Renew';
        Insert Objorderitem;
        Attachment oAttachment = new Attachment();
        oAttachment.parentId = Objorderitem.id;
        
        oAttachment.Body = EncodingUtil.base64Decode('base64Data');
        oAttachment.Name = 'fileName';
        oAttachment.ContentType = 'pdf'; 
        
        insert oAttachment;  
        list<String> ListOfStr =new list<String>{Objorderitem.id};
            String Str = '[ '+Objorderitem.id+','+Objorderitem.id+' ]';
        UploadAgentInvoice.ValidationCheck(Str);
        UploadAgentInvoice.saveTheFile(Objorderitem.id, 'fileName', 'base64Data', 'pdf');
        UploadAgentInvoice.saveFile(Objorderitem.id, 'fileName', 'base64Data', 'pdf', '');
        UploadAgentInvoice.appendToFile(oAttachment.id, 'base64Data');
        
    }
}