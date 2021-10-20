/* Copyright © 2021 MaxVal Group. All Rights Reserved.
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Sanjay Ram M, July 2021
 */


global class RenewalCancellation
{   
    //Sending mail to ADU and ADU manager if a Renewal is Cancelled 
    global void SendNotificationtoADU()
    { 
        string cancellationRequestLink;
        String subject = '';
        String mailBody = '';
        boolean status=false;
        List<User> aduUsers = [SELECT Email FROM User WHERE User.Profile.Name = 'ADU'];
        List<String> toMailId = new List<String>();
        for (User mailrecipient : aduUsers)
        {
            toMailId.add(mailrecipient.Email);
        }
        List<ListView> listView=[SELECT Id, Name, DeveloperName, SobjectType FROM ListView where DeveloperName='Cancellation_Requests'];
        if(listView.size()>0)
        cancellationRequestLink='/lightning/o/'+listView[0].SobjectType+'/list?filterName='+listView[0].Id;
        string strAuditTrailLogText = 'Started to notify ADU and ADU Manager for Renewal cancellation> ';
        try
        {
            subject = 'ACTION REQUIRED: Request for renewal cancellation';
            mailBody += '</br>Dear User,</b><br/><br/>';
            mailBody +='</br></br>We have received a request for renewal cancellation.  You are required to review and process the request.</b><br/><br/>';
            mailBody += '</br></br><a href="' + URL.getSalesforceBaseUrl().toExternalForm() + cancellationRequestLink + '">Click here</a> to review the request.</b><br/><br/>';
            mailBody +='</br></br>Note: This is an automated email. Please do not reply to this email.';
            status = SendMail(toMailId,subject,mailBody);
            
            if(status)
                strAuditTrailLogText +='Mail sent to ADU';
            else
                strAuditTrailLogText +='Mail Failed';
        }
        catch(Exception exp)
        {
            strAuditTrailLogText +='Error:' + exp.getMessage() + exp.getStacktraceString();
        }
        finally
        {
             AuditTrailHelper.UpdateAudit('Notification to ADU',strAuditTrailLogText,'None');
        }
    }
    public static boolean SendMail(List<String> toMailId,String subject ,String mailBody)
    {
        string strAuditTrailLogText;
        Boolean status = False;
        if(test.isRunningTest())
        {
            toMailId=new List<String>();
            toMailId.add('sanjayram.m@maxval.com');
        }  
        /*toMailId.add('sanjayram.m@maxval.com');
        toMailId.add('praveen.a@maxval.com');*/
        strAuditTrailLogText +='Mail id -'+toMailId;
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toMailId);
        mail.setSenderDisplayName('MaRS Notifications');
        mail.setSubject(subject);
        mail.setHtmlBody(mailBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        status =True;
        AuditTrailHelper.UpdateAudit('Notification to ADU',strAuditTrailLogText,'None');
        Return status; 
    }
}