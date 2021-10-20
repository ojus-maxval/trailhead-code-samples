public with sharing class EmailHelper
{
    public static List<string> GetEmailIds(boolean IsAdmin, boolean IsADU, boolean IsRTU)
    {
        List<string> lstProfileName = new List<string>();
        if (IsAdmin)
            lstProfileName.add('System Administrator');
        if (IsADU)
            lstProfileName.add('ADU');
        if (IsRTU)
            lstProfileName.add('RTU');
        
        List<Id> lstProfileId = new List<Id>();
        List<Profile> lstProfile = [SELECT Id, Name FROM Profile WHERE Name IN :lstProfileName];
        for(Profile objProfile : lstProfile)
        {
            lstProfileId.add(objProfile.Id); 
        }
        
        List<string> lstUserEmailId = new List<string>();
        List<User> objUserList = [SELECT Id, Email, Is_ADU_Manager__c FROM User WHERE ProfileId IN :lstProfileId AND IsActive= true];
        for(User objUser : objUserList)
        {
            lstUserEmailId.add(objUser.Email);
        }
        return lstUserEmailId;
    }
    public static string Body_WhenNewOrderReceived(List<Order__c> objOrderList)
    {
        string MessageBody = '';
        string TableContent = '';
        string OrderDate = '';
        List<EmailTemplate> objEmailTemplateList = [SELECT Body, Subject FROM EmailTemplate WHERE DeveloperName = 'To_ADU_when_Order_Received'];
        if (objEmailTemplateList != null && objEmailTemplateList.size()>0)
        {
            MessageBody = objEmailTemplateList[0].Body;
            //MessageBody = 'Hi, order.......{!TableContent} Thanks MaRS...';
            TableContent = '<p><table cellspacing=0 cellpadding=5 border=1 style="border-collapse:collapse;border-style:dotted;border-width:1px;border-color:#888;">';
            TableContent+= '<tr>';
            TableContent+= '<td><b>Client</b></td>';
            TableContent+= '<td><b>Order No.</b></td>';
            TableContent+= '<td><b>Order Date</b></td>';
            TableContent+= '<td><b>No. of Renewals</b></td>';
            TableContent+= '<td><b>Order Amount (USD)</b></td>';
            TableContent+= '<td><b>Order Amount (EUR)</b></td>';
            TableContent+= '</tr>';
            for(Order__c objOrder : objOrderList)
            {
                if (OrderDate != null)
                {
                    string[] OrderDates = String.valueOf(objOrder.Order_Date__c).split(' ');
                    OrderDate = OrderDates[0];
                }
                TableContent+= '<tr>';
                TableContent+= '<td>' + objOrder.Client__r.Client_Name__c  + '</td>';
                TableContent+= '<td>' + objOrder.Order_Number__c + '</td>';
                TableContent+= '<td>' + OrderDate  + '</td>';
                TableContent+= '<td>' + objOrder.Total_Renewals__c + '</td>';
                TableContent += '<td>' + objOrder.Order_Amount_USD_Total__c + '</td>';
                TableContent+= '<td>' + objOrder.Order_Amount_EUR__c + '</td>';
                TableContent+= '</tr>';
            }
            TableContent+= '</table></p>';
            MessageBody = MessageBody.replace('{!TableContent}', TableContent);
        }  
        return MessageBody;     
    }
    public static string Body_WhenNewOrderReceived_ToBeDepricated(List<Order__c> objOrderList)
    {
        string MessageBody = '';
        string OrderDate = '';
        MessageBody += '<html>';
        MessageBody += '<body>';
        MessageBody += 'Hi,';
        MessageBody += '<p>New order has been received from the clients successfully</p>';
        MessageBody += '<p>Order details are given below</p>';
        MessageBody += '<table cellspacing=0 cellpadding=5 border=1 style="border-collapse:collapse;border-style:dotted;border-width:1px;border-color:#888;">';
        MessageBody += '<tr>';
        MessageBody += '<td><b>Client</b></td>';
        MessageBody += '<td><b>Order No.</b></td>';
        MessageBody += '<td><b>Order Date</b></td>';
        MessageBody += '<td><b>No. of Renewals</b></td>';
        MessageBody += '<td><b>Order Amount (USD)</b></td>';
        MessageBody += '<td><b>Order Amount (EUR)</b></td>';
        MessageBody += '</tr>';
        for(Order__c objOrder : objOrderList)
        {
            if (OrderDate != null)
            {
                string[] OrderDates = String.valueOf(objOrder.Order_Date__c).split(' ');
                OrderDate = OrderDates[0];
            }
            MessageBody += '<tr>';
            MessageBody += '<td>' + objOrder.Client__r.Client_Name__c  + '</td>';
            MessageBody += '<td>' + objOrder.Order_Number__c + '</td>';
            MessageBody += '<td>' + OrderDate  + '</td>';
            MessageBody += '<td>' + objOrder.Total_Renewals__c + '</td>';
            MessageBody += '<td>' + objOrder.Order_Amount_USD_Total__c + '</td>';
            MessageBody += '<td>' + objOrder.Order_Amount_EUR__c + '</td>';
            MessageBody += '</tr>';
        }
        MessageBody += '</table>';
        
        MessageBody += '<br/><p>Regards</p>';
        MessageBody += '<p>MARS</p>';
        MessageBody += '</body>';
        MessageBody += '</html>';
        return MessageBody;
    }
    public static string Body_Client_WhenNewOrderReceived(List<Order__c> objOrderList)
    {
        string MessageBody = '';
        string OrderDate = '';
        MessageBody += '<html>';
        MessageBody += '<body>';
        MessageBody += 'Hi,';
        MessageBody += '<p>New order(s) placed successfully</p>';
        MessageBody += '<p>Order details are given below</p>';
        MessageBody += '<table cellspacing=0 cellpadding=5 border=1 style="border-collapse:collapse;border-style:dotted;border-width:1px;border-color:#888;">';
        MessageBody += '<tr>';
        MessageBody += '<td><b>Order No.</b></td>';
        MessageBody += '<td><b>Order Date</b></td>';
        MessageBody += '<td><b>No. of Renewals</b></td>';
        MessageBody += '<td><b>Order Amount (USD)</b></td>';
        MessageBody += '<td><b>Order Amount (EUR)</b></td>';
        MessageBody += '</tr>';
        for(Order__c objOrder : objOrderList)
        {
            if (OrderDate != null)
            {
                string[] OrderDates = String.valueOf(objOrder.Order_Date__c).split(' ');
                OrderDate = OrderDates[0];
            }
            MessageBody += '<tr>';
            MessageBody += '<td>' + objOrder.Order_Number__c + '</td>';
            MessageBody += '<td>' + OrderDate  + '</td>';
            MessageBody += '<td>' + objOrder.Total_Renewals__c + '</td>';
            MessageBody += '<td>' + objOrder.Order_Amount_USD_Total__c + '</td>';
            MessageBody += '<td>' + objOrder.Order_Amount_EUR__c + '</td>';
            MessageBody += '</tr>';
        }
        MessageBody += '</table>';
        
        MessageBody += '<br/><p>Regards</p>';
        MessageBody += '<p>MARS</p>';
        MessageBody += '</body>';
        MessageBody += '</html>';
        return MessageBody;
    }
    public static string Body_WhenPaymentRequested(List<Invoice__c> objInvoiceList)
    {
        string MessageBody = '';
        string OrderDate = '';
        MessageBody += '<html>';
        MessageBody += '<body>';
        MessageBody += 'Hi,';
        MessageBody += '<p>Invoice generated for the received orders</p>';
        MessageBody += '<p>Invoice details are given below</p>';
        MessageBody += '<table cellspacing=0 cellpadding=5 border=1 style="border-collapse:collapse;border-style:dotted;border-width:1px;border-color:#888;">';
        MessageBody += '<tr>';
        MessageBody += '<td><b>Client</b></td>';
        MessageBody += '<td><b>Invoice No.</b></td>';
        MessageBody += '<td><b>Order No.</b></td>';
        MessageBody += '<td><b>Order Date</b></td>';
        MessageBody += '<td><b>Invoice Amount</b></td>';
        MessageBody += '</tr>';
        for(Invoice__c objInvoice : objInvoiceList)
        {
            if (objInvoice != null)
            {
                string[] OrderDates = String.valueOf(objInvoice.Order__r.Order_Date__c).split(' ');
                OrderDate = OrderDates[0];
            }
            MessageBody += '<tr>';
            MessageBody += '<td>' + objInvoice.Order__r.Client__r.Client_Name__c  + '</td>';
            MessageBody += '<td>' + objInvoice.Invoice_No__c + '</td>';
            MessageBody += '<td>' + objInvoice.Order__r.Order_Number__c + '</td>';
            MessageBody += '<td>' + OrderDate  + '</td>';
            MessageBody += '<td align=right>' + objInvoice.Invoice_Currency__c + ' ' + objInvoice.Invoice_Amount__c + '</td>';
            MessageBody += '</tr>';
        }
        MessageBody += '</table>';
        
        MessageBody += '<br/><p>Regards</p>';
        MessageBody += '<p>MARS</p>';
        MessageBody += '</body>';
        MessageBody += '</html>';
        return MessageBody;
    }
    public static string Body_Client_WhenPaymentRequested(List<Invoice__c> objInvoiceList)
    {
        string MessageBody = '';
        string OrderDate = '';
        MessageBody += '<html>';
        MessageBody += '<body>';
        MessageBody += 'Hi,';
        MessageBody += '<p>Invoice generated for the received orders</p>';
        MessageBody += '<p>Invoice details are given below</p>';
        MessageBody += '<table cellspacing=0 cellpadding=5 border=1 style="border-collapse:collapse;border-style:dotted;border-width:1px;border-color:#888;">';
        MessageBody += '<tr>';
        MessageBody += '<td><b>Invoice No.</b></td>';
        MessageBody += '<td><b>Order No.</b></td>';
        MessageBody += '<td><b>Order Date</b></td>';
        MessageBody += '<td><b>Invoice Amount</b></td>';
        MessageBody += '</tr>';
        for(Invoice__c objInvoice : objInvoiceList)
        {
            if (objInvoice != null)
            {
                string[] OrderDates = String.valueOf(objInvoice.Order__r.Order_Date__c).split(' ');
                OrderDate = OrderDates[0];
            }
            MessageBody += '<tr>';
            MessageBody += '<td>' + objInvoice.Invoice_No__c + '</td>';
            MessageBody += '<td>' + objInvoice.Order__r.Order_Number__c + '</td>';
            MessageBody += '<td>' + OrderDate  + '</td>';
            MessageBody += '<td align=right>' + objInvoice.Invoice_Currency__c + ' ' + objInvoice.Invoice_Amount__c + '</td>';
            MessageBody += '</tr>';
        }
        MessageBody += '</table>';
        
        MessageBody += '<br/><p>Regards</p>';
        MessageBody += '<p>MARS</p>';
        MessageBody += '</body>';
        MessageBody += '</html>';
        return MessageBody;
    }
}