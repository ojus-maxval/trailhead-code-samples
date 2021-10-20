public class EmailToClientOnReceivedOrder 
{
    public static void SendEmail()
    {
        string clientEmail;
        string status;
        string OrderNo;
        Datetime OrderDate;
        List<Order__c> query =new List<Order__c>();
        query = [SELECT  id,Name,Payment_Status__c,Order_Number__c,Order_Date__c,Client__c,Client__r.Contact_Email_Id__c FROM Order__c];
        for(Order__c Ord1:query)
        {
            clientEmail= Ord1.Client__r.Contact_Email_Id__c;
            status = Ord1.Payment_Status__c;
            OrderNo = Ord1.Order_Number__c;
            OrderDate = Ord1.Order_Date__c;
        }
        integer RenewalsCount = [SELECT count() FROM Order_Item__c];
        if (status == 'To be Invoiced')
        {
            List<String> toAddresses = new List<String>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSubject('Order Received');
            toAddresses.add(clientEmail);
            mail.setToAddresses(toAddresses);
            String messageBody = '<html><body>Hi,<p>The order has been received successfully.</p><p>Order details</p><br>No of Renewals :'+RenewalsCount+'<br>Order Number :'+OrderNo+'<br>Order Date :'+OrderDate+'<p>Regards,</p><p>MARS</p></body></html>';
            mail.setHtmlBody(messageBody); 
            if(!test.isRunningTest())
            	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
        }

    }
}