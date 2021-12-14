public with sharing class WindowConfigurationHelper
{
    public static Date AddQMD(Date DateValue, decimal nQuarter, decimal nMonth, decimal nDay)
    {
        DateValue = DateValue.addMonths((Integer.valueOf(nQuarter)*3) + Integer.valueOf(nMonth)).addDays(Integer.valueOf(nDay));
        return DateValue;
    }
    public static Date StartDate(string ScheduleFrom)
    {
        Date StartDate = null;
        if (ScheduleFrom == 'Current Quarter')
            StartDate = [SELECT startdate FROM Period WHERE type = 'Quarter' and StartDate = THIS_FISCAL_QUARTER].startdate;
        else if (ScheduleFrom == 'Next Quarter')
            StartDate = [SELECT startdate FROM Period WHERE type = 'Quarter' and StartDate = NEXT_FISCAL_QUARTER].startdate;
        else if (ScheduleFrom == 'Current Month')
            StartDate = Date.Today().toStartOfMonth();
        else if (ScheduleFrom == 'Next Month')
            StartDate = Date.Today().toStartOfMonth().addMonths(1);
        return StartDate;
    }
    public static WindowConfigurationWrapper GetWindowDates()
    {
        Date StartDate = null;
        WindowConfigurationWrapper objWindowConfigurationWrapper = new WindowConfigurationWrapper();
        List<WindowConfiguration__mdt> objWindowConfigurationList = [SELECT MasterLabel,Window_Type__c, Sub_Type__c, Schedule_From__c, Quarter__c, Month__c, Day__c FROM WindowConfiguration__mdt];
        for(WindowConfiguration__mdt objWindowConfiguration : objWindowConfigurationList)
        {
            if (objWindowConfiguration.Window_Type__c == 'Instruction Window' && objWindowConfiguration.Sub_Type__c == 'Start')
            {
                objWindowConfigurationWrapper.InstructionWindowStartDate = StartDate(objWindowConfiguration.Schedule_From__c);
                objWindowConfigurationWrapper.InstructionWindowStartDate = AddQMD(objWindowConfigurationWrapper.InstructionWindowStartDate, objWindowConfiguration.Quarter__c, objWindowConfiguration.Month__c, objWindowConfiguration.Day__c);
            }
            else if(objWindowConfiguration.Window_Type__c == 'Instruction Window' && objWindowConfiguration.Sub_Type__c == 'Reminder')
            {
                objWindowConfigurationWrapper.InstructionReminder1 = StartDate(objWindowConfiguration.Schedule_From__c);
                objWindowConfigurationWrapper.InstructionReminder1 = AddQMD(objWindowConfigurationWrapper.InstructionReminder1, objWindowConfiguration.Quarter__c, objWindowConfiguration.Month__c, objWindowConfiguration.Day__c);                
            }                
            else if (objWindowConfiguration.Window_Type__c == 'Instruction Window' && objWindowConfiguration.Sub_Type__c == 'Close')
            {
                objWindowConfigurationWrapper.InstructionWindowCloseDate = StartDate(objWindowConfiguration.Schedule_From__c);
                objWindowConfigurationWrapper.InstructionWindowCloseDate = AddQMD(objWindowConfigurationWrapper.InstructionWindowCloseDate, objWindowConfiguration.Quarter__c, objWindowConfiguration.Month__c, objWindowConfiguration.Day__c);
            }
            else if (objWindowConfiguration.Window_Type__c == 'Payment Window' && objWindowConfiguration.Sub_Type__c == 'Start')
            {
                objWindowConfigurationWrapper.PaymentWindowStartDate = StartDate(objWindowConfiguration.Schedule_From__c);
                objWindowConfigurationWrapper.PaymentWindowStartDate = AddQMD(objWindowConfigurationWrapper.PaymentWindowStartDate, objWindowConfiguration.Quarter__c, objWindowConfiguration.Month__c, objWindowConfiguration.Day__c);
            }
            else if (objWindowConfiguration.Window_Type__c == 'Payment Window' && objWindowConfiguration.Sub_Type__c == 'Close')
            {
                objWindowConfigurationWrapper.PaymentWindowCloseDate = StartDate(objWindowConfiguration.Schedule_From__c);
                objWindowConfigurationWrapper.PaymentWindowCloseDate = AddQMD(objWindowConfigurationWrapper.PaymentWindowCloseDate, objWindowConfiguration.Quarter__c, objWindowConfiguration.Month__c, objWindowConfiguration.Day__c);
            }
            else if (objWindowConfiguration.Window_Type__c == 'Renewal Window' && objWindowConfiguration.Sub_Type__c == 'Start')
            {
                objWindowConfigurationWrapper.RenewalWindowStartDate = StartDate(objWindowConfiguration.Schedule_From__c);
                objWindowConfigurationWrapper.RenewalWindowStartDate = AddQMD(objWindowConfigurationWrapper.RenewalWindowStartDate, objWindowConfiguration.Quarter__c, objWindowConfiguration.Month__c, objWindowConfiguration.Day__c);
                
                if (objWindowConfiguration.Schedule_From__c == 'Current Quarter')
                    objWindowConfigurationWrapper.NextRenewalWindowStartDate = StartDate('Next Quarter');
                else if (objWindowConfiguration.Schedule_From__c == 'Current Month')    
                    objWindowConfigurationWrapper.NextRenewalWindowStartDate = StartDate('Next Month');
                objWindowConfigurationWrapper.NextRenewalWindowStartDate = AddQMD(objWindowConfigurationWrapper.NextRenewalWindowStartDate, objWindowConfiguration.Quarter__c, objWindowConfiguration.Month__c, objWindowConfiguration.Day__c);
            }
            else if (objWindowConfiguration.Window_Type__c == 'Renewal Window' && objWindowConfiguration.Sub_Type__c == 'Close')
            {
                objWindowConfigurationWrapper.RenewalWindowCloseDate = StartDate(objWindowConfiguration.Schedule_From__c);
                objWindowConfigurationWrapper.RenewalWindowCloseDate = AddQMD(objWindowConfigurationWrapper.RenewalWindowCloseDate, objWindowConfiguration.Quarter__c, objWindowConfiguration.Month__c, objWindowConfiguration.Day__c);
                
                if (objWindowConfiguration.Schedule_From__c == 'Current Quarter')
                    objWindowConfigurationWrapper.NextRenewalWindowCloseDate = StartDate('Next Quarter');
                else if (objWindowConfiguration.Schedule_From__c == 'Current Month')    
                    objWindowConfigurationWrapper.NextRenewalWindowCloseDate = StartDate('Next Month');
                objWindowConfigurationWrapper.NextRenewalWindowCloseDate = AddQMD(objWindowConfigurationWrapper.NextRenewalWindowCloseDate, objWindowConfiguration.Quarter__c, objWindowConfiguration.Month__c, objWindowConfiguration.Day__c);
            }
            else if (objWindowConfiguration.Window_Type__c == 'OnHold' && objWindowConfiguration.Sub_Type__c == 'Reminder')
            {
                if (objWindowConfiguration.MasterLabel == 'OnHold-Reminder1')
                	objWindowConfigurationWrapper.OnHoldReminder1 = objWindowConfiguration.Day__c;
                if (objWindowConfiguration.MasterLabel == 'OnHold-Reminder2')
                	objWindowConfigurationWrapper.OnHoldReminder2 = objWindowConfiguration.Day__c;
                if (objWindowConfiguration.MasterLabel == 'OnHold-Reminder3')
                	objWindowConfigurationWrapper.OnHoldReminder3 = objWindowConfiguration.Day__c;
            }
        }
        return objWindowConfigurationWrapper;
    }
}
}