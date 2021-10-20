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
    public static WindowConfigurationWrapper GetWindowDates(Id ClientId)
    {
        Date StartDate = null;
        WindowConfigurationWrapper objWindowConfigurationWrapper = new WindowConfigurationWrapper();
        List<Window_Configuration__c> objWindowConfigurationList = [SELECT Window_Type__c, Sub_Type__c, Schedule_From__c, Quarter__c, Month__c, Day__c FROM Window_Configuration__c WHERE Client__c = :ClientId AND (Sub_Type__c = 'Start' OR Sub_Type__c = 'Close')];
        for(Window_Configuration__c objWindowConfiguration : objWindowConfigurationList)
        {
            if (objWindowConfiguration.Window_Type__c == 'Instruction Window')
            {
                if (objWindowConfiguration.Sub_Type__c == 'Start')
                {
                    objWindowConfigurationWrapper.InstructionWindowStartDate = StartDate(objWindowConfiguration.Schedule_From__c);
                    objWindowConfigurationWrapper.InstructionWindowStartDate = AddQMD(objWindowConfigurationWrapper.InstructionWindowStartDate, objWindowConfiguration.Quarter__c, objWindowConfiguration.Month__c, objWindowConfiguration.Day__c);
                }
                else if (objWindowConfiguration.Sub_Type__c == 'Close')
                {
                    objWindowConfigurationWrapper.InstructionWindowCloseDate = StartDate(objWindowConfiguration.Schedule_From__c);
                    objWindowConfigurationWrapper.InstructionWindowCloseDate = AddQMD(objWindowConfigurationWrapper.InstructionWindowCloseDate, objWindowConfiguration.Quarter__c, objWindowConfiguration.Month__c, objWindowConfiguration.Day__c);
                }
            }
            else if (objWindowConfiguration.Window_Type__c == 'Payment Window')
            {
                if (objWindowConfiguration.Sub_Type__c == 'Start')
                {
                    objWindowConfigurationWrapper.PaymentWindowStartDate = StartDate(objWindowConfiguration.Schedule_From__c);
                    objWindowConfigurationWrapper.PaymentWindowStartDate = AddQMD(objWindowConfigurationWrapper.PaymentWindowStartDate, objWindowConfiguration.Quarter__c, objWindowConfiguration.Month__c, objWindowConfiguration.Day__c);
                } 
                else if (objWindowConfiguration.Sub_Type__c == 'Close')
                {
                    objWindowConfigurationWrapper.PaymentWindowCloseDate = StartDate(objWindowConfiguration.Schedule_From__c);
                    objWindowConfigurationWrapper.PaymentWindowCloseDate = AddQMD(objWindowConfigurationWrapper.PaymentWindowCloseDate, objWindowConfiguration.Quarter__c, objWindowConfiguration.Month__c, objWindowConfiguration.Day__c);
                }
            }
            else if (objWindowConfiguration.Window_Type__c == 'Renewal Window')
            {
                if (objWindowConfiguration.Sub_Type__c == 'Start')
                {
                    objWindowConfigurationWrapper.RenewalWindowStartDate = StartDate(objWindowConfiguration.Schedule_From__c);
                    objWindowConfigurationWrapper.RenewalWindowStartDate = AddQMD(objWindowConfigurationWrapper.RenewalWindowStartDate, objWindowConfiguration.Quarter__c, objWindowConfiguration.Month__c, objWindowConfiguration.Day__c);
                }                
                else if (objWindowConfiguration.Sub_Type__c == 'Close')
                {
                    objWindowConfigurationWrapper.RenewalWindowCloseDate = StartDate(objWindowConfiguration.Schedule_From__c);
                    objWindowConfigurationWrapper.RenewalWindowCloseDate = AddQMD(objWindowConfigurationWrapper.RenewalWindowCloseDate, objWindowConfiguration.Quarter__c, objWindowConfiguration.Month__c, objWindowConfiguration.Day__c);
                }
            }
            else if (objWindowConfiguration.Window_Type__c == 'Invoicing Window')
            {
                if (objWindowConfiguration.Sub_Type__c == 'Start')
                {
                    objWindowConfigurationWrapper.InvoicingWindowStartDate = StartDate(objWindowConfiguration.Schedule_From__c);
                    objWindowConfigurationWrapper.InvoicingWindowStartDate= AddQMD(objWindowConfigurationWrapper.InvoicingWindowStartDate, objWindowConfiguration.Quarter__c, objWindowConfiguration.Month__c, objWindowConfiguration.Day__c);
                }                
                else if (objWindowConfiguration.Sub_Type__c == 'Close')
                {
                    objWindowConfigurationWrapper.InvoicingWindowCloseDate = StartDate(objWindowConfiguration.Schedule_From__c);
                    objWindowConfigurationWrapper.InvoicingWindowCloseDate = AddQMD(objWindowConfigurationWrapper.InvoicingWindowCloseDate, objWindowConfiguration.Quarter__c, objWindowConfiguration.Month__c, objWindowConfiguration.Day__c);
                }
            }
        }
        return objWindowConfigurationWrapper;
    }
}