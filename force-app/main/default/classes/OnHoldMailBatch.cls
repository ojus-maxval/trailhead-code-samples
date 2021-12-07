global class OnHoldMailBatch implements Database.Batchable<sObject>, Database.AllowsCallouts
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
       return Database.getQueryLocator([select Application_No__c,LastModifiedDate,Term__c,Patent_No__c,Patent__r.SymphonyIPM__Docket_No__c,Country_Code__c,Due_Date__c, FROM Annuity_Payment_v2__c where Instruction__c = 'On Hold']);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope)
	{ 
        string strAuditTrailLogText = 'Started > ';
        list<string> recipientList = new list<string>();
        try
        {
            String emailBody =null;
            if(scope.size()>0)
            {
                List<Annuity_Payment_v2__c> objRenewalList = (List<Annuity_Payment_v2__c>)scope;
                list<Renewal_Configuration__c> objRenewalConfigurationList = [select Renewal_Admin_Email__c from Renewal_Configuration__c where  name = 'RenewalConfiguration'];
                for(Renewal_Configuration__c objRenewalConfiguration : objRenewalConfigurationList)
                {
                    recipientList.add(objRenewalConfiguration.Renewal_Admin_Email__c);
                }                
                String subject=null;
                boolean status=false;
                subject = 'ACTION REQUIRED - On Hold Items approaching critical deadlines';
                emailBody = '</br></br>Dear User,</b><br/><br/>';
                emailBody +='</br></br>The following patent(s) are approaching the On Hold deadline that you have specified:</b><br/><br/>';                    
                emailBody +='<table border="0" cellpadding="0" cellspacing="0" width="287" style="border-collapse: collapse; width: 215pt;">';
                emailBody +='<colgroup><col width="100" style="width: 75pt;">';
                emailBody +='<col width="69" style="width: 52pt;">';
                emailBody +='<col width="39" style="width: 29pt;">';
                emailBody +='<col width="79" style="width: 59pt;">';
                emailBody +='</colgroup><tbody><tr height="20" style="height: 15pt;">';
                emailBody +='<td class="gmail-xl65" width="69" style="border-left: none; width: 52pt; font-weight: 700; border-top: 0.5pt solid windowtext; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; padding-top: 1px; padding-right: 1px; padding-left: 1px; color: black; font-size: 11pt; font-family: Calibri, sans-serif; vertical-align: bottom; white-space: nowrap;">Docket No.</td>';
                emailBody +='<td class="gmail-xl65" width="69" style="border-left: none; width: 52pt; font-weight: 700; border-top: 0.5pt solid windowtext; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; padding-top: 1px; padding-right: 1px; padding-left: 1px; color: black; font-size: 11pt; font-family: Calibri, sans-serif; vertical-align: bottom; white-space: nowrap;">Application No.</td>';
                emailBody +='<td class="gmail-xl65" width="69" style="border-left: none; width: 52pt; font-weight: 700; border-top: 0.5pt solid windowtext; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; padding-top: 1px; padding-right: 1px; padding-left: 1px; color: black; font-size: 11pt; font-family: Calibri, sans-serif; vertical-align: bottom; white-space: nowrap;">Patent No.</td>';
                emailBody +='<td class="gmail-xl65" width="69" style="border-left: none; width: 52pt; font-weight: 700; border-top: 0.5pt solid windowtext; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; padding-top: 1px; padding-right: 1px; padding-left: 1px; color: black; font-size: 11pt; font-family: Calibri, sans-serif; vertical-align: bottom; white-space: nowrap;">Jurisdiction</td>';
                emailBody +='<td class="gmail-xl65" width="69" style="border-left: none; width: 52pt; font-weight: 700; border-top: 0.5pt solid windowtext; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; padding-top: 1px; padding-right: 1px; padding-left: 1px; color: black; font-size: 11pt; font-family: Calibri, sans-serif; vertical-align: bottom; white-space: nowrap;">Term</td>';
                emailBody +='</tr>';
                for(Annuity_Payment_v2__c objRenewal: objRenewalList){
                    emailBody +='<tr height="20" style="height: 15pt;">';
                    emailBody +='<td class="gmail-xl63" style="border-top: none; border-left: none; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; padding-top: 1px; padding-right: 1px; padding-left: 1px; color: black; font-size: 11pt; font-family: Calibri, sans-serif; vertical-align: bottom; white-space: nowrap;">'+ objRenewal.Patent__r.SymphonyIPM__Docket_No__c +'</td>';
                    emailBody +='<td class="gmail-xl63" style="border-top: none; border-left: none; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; padding-top: 1px; padding-right: 1px; padding-left: 1px; color: black; font-size: 11pt; font-family: Calibri, sans-serif; vertical-align: bottom; white-space: nowrap;">'+ objRenewal.Application_No__c +'</td>';
                    emailBody +='<td class="gmail-xl63" style="border-top: none; border-left: none; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; padding-top: 1px; padding-right: 1px; padding-left: 1px; color: black; font-size: 11pt; font-family: Calibri, sans-serif; vertical-align: bottom; white-space: nowrap;">'+ objRenewal.Patent_No__c +'</td>';
                    emailBody +='<td class="gmail-xl63" style="border-top: none; border-left: none; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; padding-top: 1px; padding-right: 1px; padding-left: 1px; color: black; font-size: 11pt; font-family: Calibri, sans-serif; vertical-align: bottom; white-space: nowrap;">'+ objRenewal.Term__c +'</td>';
                    emailBody +='<td class="gmail-xl63" style="border-top: none; border-left: none; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; padding-top: 1px; padding-right: 1px; padding-left: 1px; color: black; font-size: 11pt; font-family: Calibri, sans-serif; vertical-align: bottom; white-space: nowrap;">'+ objRenewal.Country_Code__c +'</td>';                    
                    emailBody +='</tr>';
                }
                emailBody +='</tbody></table><br/><br/>';     
                emailBody += '</br></br>Please note that renewals will not be processed unless you instruct us to make the renewal payments.</b><br/><br/>';
                emailBody += '</br></br>Please contact us at renewals@maxval.com if you need any assistance.</b><br/><br/>';
                emailBody += '</br></br>DO NOT REPLY TO THIS EMAIL. THIS EMAIL IS SENT FROM A MAILBOX THAT IS NOT MONITORED.</b><br/><br/>';
                emailBody +='</br></br><br/>Sincerely,</br></br><br>MaxVal Renewals Team</br>';
                strAuditTrailLogText+='||EmailBody : '+emailBody;                   
                status = EmailController.SendEmail(recipientList,subject,emailBody);
                if(status)
                    strAuditTrailLogText+='||Email Sent successfully';
            }
            
        }
        catch(Exception exp)
        {
            strAuditTrailLogText += 'Error:' + exp.getMessage() +'|' +exp.getStacktraceString();
            system.debug(strAuditTrailLogText);	
        }
        finally
        {
            HelperAudit.updateAudit('AssetsOnHold', strAuditTrailLogText, true);
        }
	}
    global void finish(Database.BatchableContext BC)
    {
        
    }
}