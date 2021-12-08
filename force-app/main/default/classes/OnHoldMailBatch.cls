/* Copyright © 2021 MaxVal Group. All Rights Reserved.
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Saranyaa C, October 2021
 */
global class OnHoldMailBatch implements Database.Batchable<sObject>, Database.AllowsCallouts
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
       return Database.getQueryLocator([select Renewal_Admin_Email__c from Renewal_Configuration__c where  name = 'RenewalConfiguration']);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope)
	{ 
        string strAuditTrailLogText = 'Started > ';
        list<string> recipientList = new list<string>();
        integer reminder1 = 1, reminder2 = 2, reminder3 = 3;
        try
        {            
            if(scope.size()>0)
            {
                list<Renewal_Configuration__c> objRenewalConfigurationList =  (List<Renewal_Configuration__c>)scope;
                for(Renewal_Configuration__c objRenewalConfiguration : objRenewalConfigurationList)
                {
                    recipientList.add(objRenewalConfiguration.Renewal_Admin_Email__c);
                }  
                //Send Reminder 1 - X days before On Hold date
                Date reminder1Date = date.today().adddays(-5);
        		boolean reminder1MailStatus = false;
	        	List<Annuity_Payment_v2__c> objRenewalListForReminder1ToUpdate = NEW List<Annuity_Payment_v2__c>();
                //Get renewals list
                List<Annuity_Payment_v2__c> objRenewalListForReminder1 = [select Id,Application_No__c,LastModifiedDate,Term__c,Patent_No__c,Patent__r.SymphonyIPM__Docket_No__c,Country_Code__c,Due_Date__c,Window_Close_Date__c,Hold_Date__c,Is_Reminder1_sent__c FROM Annuity_Payment_v2__c where Instruction__c = 'On Hold' AND Is_Reminder1_sent__c = false AND Hold_Date__c =: reminder1Date];                        
                if(objRenewalListForReminder1.size() > 0){  
                    //Send mail
                    reminder1MailStatus = SendReminderBeforeDDD(objRenewalListForReminder1,recipientList,reminder1);
                    if(reminder1MailStatus){                
                        strAuditTrailLogText+='||Reminder1 Sent successfully'; 
                        for(Annuity_Payment_v2__c objRenewal: objRenewalListForReminder1){
                            //Update flag to avoid sending reminder again
                            objRenewal.Is_Reminder1_sent__c = true;
                            objRenewalListForReminder1ToUpdate.add(objRenewal);
                        }
                        update objRenewalListForReminder1ToUpdate;
                    }else{
                        strAuditTrailLogText+='||Failed to send Reminder1'; 
                    }
                }
                
                //Send Reminder 2 - X days before Due date
                Date reminder2Date = date.today().adddays(-5);
        		boolean reminder2MailStatus = false;
	        	List<Annuity_Payment_v2__c> objRenewalListForReminder2ToUpdate = NEW List<Annuity_Payment_v2__c>();
                //Get renewals list
                List<Annuity_Payment_v2__c> objRenewalListForReminder2 = [select Id,Application_No__c,LastModifiedDate,Term__c,Patent_No__c,Patent__r.SymphonyIPM__Docket_No__c,Country_Code__c,Due_Date__c,Window_Close_Date__c,Hold_Date__c,Is_Reminder2_sent__c FROM Annuity_Payment_v2__c where Instruction__c = 'On Hold' AND Is_Reminder2_sent__c = false AND Due_Date__c =: reminder2Date];                        
                if(objRenewalListForReminder2.size() > 0){  
                    //Send mail
                    reminder2MailStatus = SendReminderBeforeDDD(objRenewalListForReminder2,recipientList,reminder2);
                    if(reminder2MailStatus){                
                        strAuditTrailLogText+='||Reminder2 Sent successfully'; 
                        for(Annuity_Payment_v2__c objRenewal: objRenewalListForReminder2){
                            //Update flag to avoid sending reminder again
                            objRenewal.Is_Reminder2_sent__c = true;
                            objRenewalListForReminder2ToUpdate.add(objRenewal);
                        }
                        update objRenewalListForReminder2ToUpdate;
                    }else{
                        strAuditTrailLogText+='||Failed to send Reminder2'; 
                    }
                }
                
                //Send Reminder 3 - X days before drop dead date
                Date reminder3Date = date.today().adddays(-5);
        		boolean reminder3MailStatus = false;
	        	List<Annuity_Payment_v2__c> objRenewalListForReminder3ToUpdate = NEW List<Annuity_Payment_v2__c>();
                //Get renewals list
                List<Annuity_Payment_v2__c> objRenewalListForReminder3 = [select Id,Application_No__c,LastModifiedDate,Term__c,Patent_No__c,Patent__r.SymphonyIPM__Docket_No__c,Country_Code__c,Due_Date__c,Window_Close_Date__c,Hold_Date__c,Is_Reminder3_sent__c FROM Annuity_Payment_v2__c where Instruction__c = 'On Hold' AND Is_Reminder3_sent__c = false AND Window_Close_Date__c =: reminder3Date];                        
                if(objRenewalListForReminder3.size() > 0){  
                    //Send mail
                    reminder3MailStatus = SendReminderBeforeDDD(objRenewalListForReminder3,recipientList,reminder3);
                    if(reminder3MailStatus){                
                        strAuditTrailLogText+='||Reminder3 Sent successfully'; 
                        for(Annuity_Payment_v2__c objRenewal: objRenewalListForReminder3){
                            //Update flag to avoid sending reminder again
                            objRenewal.Is_Reminder3_sent__c = true;
                            objRenewalListForReminder3ToUpdate.add(objRenewal);
                        }
                        update objRenewalListForReminder3ToUpdate;
                    }else{
                        strAuditTrailLogText+='||Failed to send Reminder3'; 
                    }
                }
                
                //Send Reminder after Drop Dead Date
        		boolean mailStatus = false;
	        	List<Annuity_Payment_v2__c> objRenewalListToUpdate = NEW List<Annuity_Payment_v2__c>();
                //Get renewals list
                List<Annuity_Payment_v2__c> objRenewalList = [select Id,Application_No__c,LastModifiedDate,Term__c,Patent_No__c,Patent__r.SymphonyIPM__Docket_No__c,Country_Code__c,Due_Date__c,Window_Close_Date__c,Hold_Date__c,Is_Reminder3_sent__c FROM Annuity_Payment_v2__c where Instruction__c = 'On Hold' AND Is_Reminder3_sent__c = false AND Window_Close_Date__c <= TODAY];                        
                if(objRenewalList.size() > 0){  
                    //Send mail
                    mailStatus = SendReminderAfterDDD(objRenewalList,recipientList);
                    if(mailStatus){                
                        strAuditTrailLogText+='||Mail Sent successfully'; 
                        for(Annuity_Payment_v2__c objRenewal: objRenewalList){
                            //Update flag to avoid sending reminder again
                            objRenewal.Is_Reminder3_sent__c = true;
                            objRenewalListToUpdate.add(objRenewal);
                        }
                        update objRenewalListToUpdate;
                    }else{
                        strAuditTrailLogText+='||Failed to send mail'; 
                    }
                }
            }
            
        }
        catch(Exception exp)
        {            
        	system.debug(exp.getMessage() +'|' +exp.getStacktraceString());
            strAuditTrailLogText += 'Error:' + exp.getMessage() +'|' +exp.getStacktraceString();
            system.debug(strAuditTrailLogText);	
        }
        finally
        {
            HelperAudit.updateAudit('OnHoldMailBatch', strAuditTrailLogText, true);
        }
	}
    public boolean SendReminderBeforeDDD(List<Annuity_Payment_v2__c> objRenewalList,list<string> recipientList, integer reminderNo){
        string strAuditTrailLogText = '';
        String subject=null;
        String emailBody =null;
        boolean status=false;
        String patentNo = '';
        try{
            subject = 'ACTION REQUIRED - On Hold Items approaching critical deadlines';

            emailBody = '</br></br>Dear User,</b><br/><br/>';            
            if(reminderNo == 1)
                emailBody +='</br></br>The following patent(s) are approaching the On Hold deadline that you have specified:</b><br/><br/>';                    
            else if (reminderNo == 2)
                emailBody += 'The following patent(s) that are On Hold, are approaching the renewal Due Date:';
            else if (reminderNo == 3)
                emailBody += 'The following patent(s)  that  are On Hold, are approaching the renewal Grace Period End Date:';
            emailBody +='<table border="0" cellpadding="0" cellspacing="0" width="287" style="border-collapse: collapse; width: 215pt;">';
            emailBody +='<colgroup><col width="100" style="width: 75pt;">';
            emailBody +='<col width="69" style="width: 52pt;">';
            emailBody +='<col width="39" style="width: 29pt;">';
            emailBody +='<col width="79" style="width: 59pt;">';
            emailBody +='</colgroup><tbody><tr height="20" style="height: 15pt;">';
            emailBody +='<td class="gmail-xl65" width="69" style="border-left: 0.5pt solid windowtext; width: 52pt; font-weight: 700; border-top: 0.5pt solid windowtext; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; padding-top: 1px; padding-right: 1px; padding-left: 1px; color: black; font-size: 11pt; font-family: Calibri, sans-serif; vertical-align: bottom; white-space: nowrap;">Docket No.</td>';
            emailBody +='<td class="gmail-xl65" width="69" style="border-left: none; width: 52pt; font-weight: 700; border-top: 0.5pt solid windowtext; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; padding-top: 1px; padding-right: 1px; padding-left: 1px; color: black; font-size: 11pt; font-family: Calibri, sans-serif; vertical-align: bottom; white-space: nowrap;">Application No.</td>';
            emailBody +='<td class="gmail-xl65" width="69" style="border-left: none; width: 52pt; font-weight: 700; border-top: 0.5pt solid windowtext; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; padding-top: 1px; padding-right: 1px; padding-left: 1px; color: black; font-size: 11pt; font-family: Calibri, sans-serif; vertical-align: bottom; white-space: nowrap;">Patent No.</td>';
            emailBody +='<td class="gmail-xl65" width="69" style="border-left: none; width: 52pt; font-weight: 700; border-top: 0.5pt solid windowtext; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; padding-top: 1px; padding-right: 1px; padding-left: 1px; color: black; font-size: 11pt; font-family: Calibri, sans-serif; vertical-align: bottom; white-space: nowrap;">Jurisdiction</td>';
            emailBody +='<td class="gmail-xl65" width="69" style="border-left: none; width: 52pt; font-weight: 700; border-top: 0.5pt solid windowtext; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; padding-top: 1px; padding-right: 1px; padding-left: 1px; color: black; font-size: 11pt; font-family: Calibri, sans-serif; vertical-align: bottom; white-space: nowrap;">Term</td>';
            emailBody +='<td class="gmail-xl65" width="69" style="border-left: none; width: 52pt; font-weight: 700; border-top: 0.5pt solid windowtext; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; padding-top: 1px; padding-right: 1px; padding-left: 1px; color: black; font-size: 11pt; font-family: Calibri, sans-serif; vertical-align: bottom; white-space: nowrap;">Due Date</td>';
            emailBody +='<td class="gmail-xl65" width="69" style="border-left: none; width: 52pt; font-weight: 700; border-top: 0.5pt solid windowtext; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; padding-top: 1px; padding-right: 1px; padding-left: 1px; color: black; font-size: 11pt; font-family: Calibri, sans-serif; vertical-align: bottom; white-space: nowrap;">Grace Period End Date</td>';
            if(reminderNo == 1)
                emailBody +='<td class="gmail-xl65" width="69" style="border-left: none; width: 52pt; font-weight: 700; border-top: 0.5pt solid windowtext; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; padding-top: 1px; padding-right: 1px; padding-left: 1px; color: black; font-size: 11pt; font-family: Calibri, sans-serif; vertical-align: bottom; white-space: nowrap;">Oh Hold Until Date</td>';                
            else if (reminderNo == 2 || reminderNo == 3)
                emailBody +='<td class="gmail-xl65" width="69" style="border-left: none; width: 52pt; font-weight: 700; border-top: 0.5pt solid windowtext; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; padding-top: 1px; padding-right: 1px; padding-left: 1px; color: black; font-size: 11pt; font-family: Calibri, sans-serif; vertical-align: bottom; white-space: nowrap;">Expiration Date</td>';                
                        
            emailBody +='</tr>';
            strAuditTrailLogText += 'Asset id list: ';
            for(Annuity_Payment_v2__c objRenewal: objRenewalList){
                strAuditTrailLogText += objRenewal.id + ' , ';
                emailBody +='<tr height="20" style="height: 15pt;">';
                emailBody +='<td class="gmail-xl63" style="border-top: none; border-left: none; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; padding-top: 1px; padding-right: 1px; padding-left: 1px; color: black; font-size: 11pt; font-family: Calibri, sans-serif; vertical-align: bottom; white-space: nowrap;">'+ objRenewal.Patent__r.SymphonyIPM__Docket_No__c +'</td>';
                emailBody +='<td class="gmail-xl63" style="border-top: none; border-left: none; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; padding-top: 1px; padding-right: 1px; padding-left: 1px; color: black; font-size: 11pt; font-family: Calibri, sans-serif; vertical-align: bottom; white-space: nowrap;">'+ objRenewal.Application_No__c +'</td>';
                patentNo = objRenewal.Patent_No__c != null ? objRenewal.Patent_No__c : '';
                emailBody +='<td class="gmail-xl63" style="border-top: none; border-left: none; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; padding-top: 1px; padding-right: 1px; padding-left: 1px; color: black; font-size: 11pt; font-family: Calibri, sans-serif; vertical-align: bottom; white-space: nowrap;">'+ patentNo +'</td>';
                emailBody +='<td class="gmail-xl63" style="border-top: none; border-left: none; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; padding-top: 1px; padding-right: 1px; padding-left: 1px; color: black; font-size: 11pt; font-family: Calibri, sans-serif; vertical-align: bottom; white-space: nowrap;">'+ objRenewal.Country_Code__c +'</td>';
                emailBody +='<td class="gmail-xl63" style="border-top: none; border-left: none; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; padding-top: 1px; padding-right: 1px; padding-left: 1px; color: black; font-size: 11pt; font-family: Calibri, sans-serif; vertical-align: bottom; white-space: nowrap;">'+ objRenewal.Term__c +'</td>';
                emailBody +='<td class="gmail-xl63" style="border-top: none; border-left: none; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; padding-top: 1px; padding-right: 1px; padding-left: 1px; color: black; font-size: 11pt; font-family: Calibri, sans-serif; vertical-align: bottom; white-space: nowrap;">'+ objRenewal.Due_Date__c +'</td>';
                emailBody +='<td class="gmail-xl63" style="border-top: none; border-left: none; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; padding-top: 1px; padding-right: 1px; padding-left: 1px; color: black; font-size: 11pt; font-family: Calibri, sans-serif; vertical-align: bottom; white-space: nowrap;">'+ objRenewal.Window_Close_Date__c +'</td>';
                emailBody +='<td class="gmail-xl63" style="border-top: none; border-left: none; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; padding-top: 1px; padding-right: 1px; padding-left: 1px; color: black; font-size: 11pt; font-family: Calibri, sans-serif; vertical-align: bottom; white-space: nowrap;">'+ objRenewal.Hold_Date__c +'</td>';                    
                emailBody +='</tr>';
            }
            emailBody +='</tbody></table><br/><br/>';     
            emailBody += '</br></br>Please note that renewals will not be processed unless you instruct us to make the renewal payments.</b><br/><br/>';
            emailBody += '</br></br>Please contact us at renewals@maxval.com if you need any assistance.</b><br/><br/>';
            emailBody += '</br></br>DO NOT REPLY TO THIS EMAIL. THIS EMAIL IS SENT FROM A MAILBOX THAT IS NOT MONITORED.</b><br/><br/>';
            emailBody +='</br></br><br/>Sincerely,</br></br><br>MaxVal Renewals Team</br>';
            strAuditTrailLogText += 'Sending...';
            status = EmailController.SendEmail(recipientList,subject,emailBody);
        }
        catch(Exception exp)
        {            
        	system.debug(exp.getMessage() +'|' +exp.getStacktraceString());
            strAuditTrailLogText += 'Error:' + exp.getMessage() +'|' +exp.getStacktraceString();
            system.debug(strAuditTrailLogText);	
        }
        finally
        {
            HelperAudit.updateAudit('OnHoldMailBatch-SendReminderBeforeDDD', strAuditTrailLogText, true);
        }
        return status;
    }
    public boolean SendReminderAfterDDD(List<Annuity_Payment_v2__c> objRenewalList,list<string> recipientList){
        string strAuditTrailLogText = '';
        String subject=null;
        String emailBody =null;
        boolean status=false;
        String patentNo = '';
        try{
            subject = 'FYI - On Hold Items past the Grace period';
            emailBody = '</br></br>Dear User,</b><br/><br/>';
            emailBody +='</br></br>The following patent(s) are now past the renewal Grace Period:</b><br/><br/>';                    
            emailBody +='<table border="0" cellpadding="0" cellspacing="0" width="287" style="border-collapse: collapse; width: 215pt;">';
            emailBody +='<colgroup><col width="100" style="width: 75pt;">';
            emailBody +='<col width="69" style="width: 52pt;">';
            emailBody +='<col width="39" style="width: 29pt;">';
            emailBody +='<col width="79" style="width: 59pt;">';
            emailBody +='</colgroup><tbody><tr height="20" style="height: 15pt;">';
            emailBody +='<td class="gmail-xl65" width="69" style="border-left: 0.5pt solid windowtext; width: 52pt; font-weight: 700; border-top: 0.5pt solid windowtext; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; padding-top: 1px; padding-right: 1px; padding-left: 1px; color: black; font-size: 11pt; font-family: Calibri, sans-serif; vertical-align: bottom; white-space: nowrap;">Docket No.</td>';
            emailBody +='<td class="gmail-xl65" width="69" style="border-left: none; width: 52pt; font-weight: 700; border-top: 0.5pt solid windowtext; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; padding-top: 1px; padding-right: 1px; padding-left: 1px; color: black; font-size: 11pt; font-family: Calibri, sans-serif; vertical-align: bottom; white-space: nowrap;">Application No.</td>';
            emailBody +='<td class="gmail-xl65" width="69" style="border-left: none; width: 52pt; font-weight: 700; border-top: 0.5pt solid windowtext; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; padding-top: 1px; padding-right: 1px; padding-left: 1px; color: black; font-size: 11pt; font-family: Calibri, sans-serif; vertical-align: bottom; white-space: nowrap;">Patent No.</td>';
            emailBody +='<td class="gmail-xl65" width="69" style="border-left: none; width: 52pt; font-weight: 700; border-top: 0.5pt solid windowtext; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; padding-top: 1px; padding-right: 1px; padding-left: 1px; color: black; font-size: 11pt; font-family: Calibri, sans-serif; vertical-align: bottom; white-space: nowrap;">Jurisdiction</td>';
            emailBody +='<td class="gmail-xl65" width="69" style="border-left: none; width: 52pt; font-weight: 700; border-top: 0.5pt solid windowtext; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; padding-top: 1px; padding-right: 1px; padding-left: 1px; color: black; font-size: 11pt; font-family: Calibri, sans-serif; vertical-align: bottom; white-space: nowrap;">Term</td>';
            emailBody +='<td class="gmail-xl65" width="69" style="border-left: none; width: 52pt; font-weight: 700; border-top: 0.5pt solid windowtext; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; padding-top: 1px; padding-right: 1px; padding-left: 1px; color: black; font-size: 11pt; font-family: Calibri, sans-serif; vertical-align: bottom; white-space: nowrap;">Due Date</td>';
            emailBody +='<td class="gmail-xl65" width="69" style="border-left: none; width: 52pt; font-weight: 700; border-top: 0.5pt solid windowtext; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; padding-top: 1px; padding-right: 1px; padding-left: 1px; color: black; font-size: 11pt; font-family: Calibri, sans-serif; vertical-align: bottom; white-space: nowrap;">Grace Period End Date</td>';
            emailBody +='<td class="gmail-xl65" width="69" style="border-left: none; width: 52pt; font-weight: 700; border-top: 0.5pt solid windowtext; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; padding-top: 1px; padding-right: 1px; padding-left: 1px; color: black; font-size: 11pt; font-family: Calibri, sans-serif; vertical-align: bottom; white-space: nowrap;">Expiration Date</td>';                
            emailBody +='</tr>';
            strAuditTrailLogText += 'Asset id list: ';
            for(Annuity_Payment_v2__c objRenewal: objRenewalList){
                strAuditTrailLogText += objRenewal.id + ' , ';
                emailBody +='<tr height="20" style="height: 15pt;">';
                emailBody +='<td class="gmail-xl63" style="border-top: none; border-left: none; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; padding-top: 1px; padding-right: 1px; padding-left: 1px; color: black; font-size: 11pt; font-family: Calibri, sans-serif; vertical-align: bottom; white-space: nowrap;">'+ objRenewal.Patent__r.SymphonyIPM__Docket_No__c +'</td>';
                emailBody +='<td class="gmail-xl63" style="border-top: none; border-left: none; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; padding-top: 1px; padding-right: 1px; padding-left: 1px; color: black; font-size: 11pt; font-family: Calibri, sans-serif; vertical-align: bottom; white-space: nowrap;">'+ objRenewal.Application_No__c +'</td>';
                patentNo = objRenewal.Patent_No__c != null ? objRenewal.Patent_No__c : '';
                emailBody +='<td class="gmail-xl63" style="border-top: none; border-left: none; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; padding-top: 1px; padding-right: 1px; padding-left: 1px; color: black; font-size: 11pt; font-family: Calibri, sans-serif; vertical-align: bottom; white-space: nowrap;">'+ patentNo +'</td>';
                emailBody +='<td class="gmail-xl63" style="border-top: none; border-left: none; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; padding-top: 1px; padding-right: 1px; padding-left: 1px; color: black; font-size: 11pt; font-family: Calibri, sans-serif; vertical-align: bottom; white-space: nowrap;">'+ objRenewal.Country_Code__c +'</td>';
                emailBody +='<td class="gmail-xl63" style="border-top: none; border-left: none; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; padding-top: 1px; padding-right: 1px; padding-left: 1px; color: black; font-size: 11pt; font-family: Calibri, sans-serif; vertical-align: bottom; white-space: nowrap;">'+ objRenewal.Term__c +'</td>';
                emailBody +='<td class="gmail-xl63" style="border-top: none; border-left: none; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; padding-top: 1px; padding-right: 1px; padding-left: 1px; color: black; font-size: 11pt; font-family: Calibri, sans-serif; vertical-align: bottom; white-space: nowrap;">'+ objRenewal.Due_Date__c +'</td>';
                emailBody +='<td class="gmail-xl63" style="border-top: none; border-left: none; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; padding-top: 1px; padding-right: 1px; padding-left: 1px; color: black; font-size: 11pt; font-family: Calibri, sans-serif; vertical-align: bottom; white-space: nowrap;">'+ objRenewal.Window_Close_Date__c +'</td>';
                emailBody +='<td class="gmail-xl63" style="border-top: none; border-left: none; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; padding-top: 1px; padding-right: 1px; padding-left: 1px; color: black; font-size: 11pt; font-family: Calibri, sans-serif; vertical-align: bottom; white-space: nowrap;">'+ objRenewal.Hold_Date__c +'</td>';                    
                emailBody +='</tr>';
            }
            emailBody +='</tbody></table><br/><br/>';     
            emailBody += '</br></br>Please contact us at renewals@maxval.com if you need any assistance.</b><br/><br/>';
            emailBody += '</br></br>DO NOT REPLY TO THIS EMAIL. THIS EMAIL IS SENT FROM A MAILBOX THAT IS NOT MONITORED.</b><br/><br/>';
            emailBody +='</br></br><br/>Sincerely,</br></br><br>MaxVal Renewals Team</br>';
            strAuditTrailLogText += 'Sending...';
            status = EmailController.SendEmail(recipientList,subject,emailBody);
        }
        catch(Exception exp)
        {            
        	system.debug(exp.getMessage() +'|' +exp.getStacktraceString());
            strAuditTrailLogText += 'Error:' + exp.getMessage() +'|' +exp.getStacktraceString();
            system.debug(strAuditTrailLogText);	
        }
        finally
        {
            HelperAudit.updateAudit('OnHoldMailBatch-SendReminderAfterDDD', strAuditTrailLogText, true);
        }
        return status;
    }
    global void finish(Database.BatchableContext BC)
    {
        
    }
}