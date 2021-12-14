public with sharing class WindowConfigurationController
{
    @auraenabled
    public static Date GetNextRenewalDate()
    {
        WindowConfiguration__mdt objWindowConfiguration = [SELECT Window_Type__c, Sub_Type__c, Schedule_From__c, Quarter__c, Month__c, Day__c FROM WindowConfiguration__mdt WHERE Window_Type__c = 'Instruction Window' AND Sub_Type__c='Close' LIMIT 1];
                
        WindowConfigurationWrapper objWindowConfigurationWrapper = WindowConfigurationHelper.GetWindowDates();
        /*
        if (objWindowConfiguration.Schedule_From__c == 'Current Quarter')
        {
            objWindowConfigurationWrapper.InstructionWindowCloseDate = WindowConfigurationHelper.StartDate('Next Quarter');
            objWindowConfigurationWrapper.InstructionWindowCloseDate = WindowConfigurationHelper.AddQMD(objWindowConfigurationWrapper.InstructionWindowCloseDate, objWindowConfiguration.Quarter__c, objWindowConfiguration.Month__c, objWindowConfiguration.Day__c);
        }
        else if (objWindowConfiguration.Schedule_From__c == 'Current Month')    
        {
            objWindowConfigurationWrapper.InstructionWindowCloseDate = WindowConfigurationHelper.StartDate('Next Month');
            objWindowConfigurationWrapper.InstructionWindowCloseDate = WindowConfigurationHelper.AddQMD(objWindowConfigurationWrapper.InstructionWindowCloseDate, objWindowConfiguration.Quarter__c, objWindowConfiguration.Month__c, objWindowConfiguration.Day__c);
        }
        */
        return objWindowConfigurationWrapper.InstructionWindowCloseDate;
    }
    @auraenabled
    public static Date GetNextRenewalDateToCmp()
    {
        WindowConfiguration__mdt objWindowConfiguration = [SELECT Window_Type__c, Sub_Type__c, Schedule_From__c, Quarter__c, Month__c, Day__c FROM WindowConfiguration__mdt WHERE Window_Type__c = 'Instruction Window' AND Sub_Type__c='Close' LIMIT 1];
        WindowConfigurationWrapper objWindowConfigurationWrapper = WindowConfigurationHelper.GetWindowDates();
        date InstructDate = objWindowConfigurationWrapper.InstructionWindowCloseDate;
        if(objWindowConfiguration.Schedule_From__c =='Current Quarter' && system.today() >InstructDate)
        {
            InstructDate = InstructDate.addMonths(3);
        }
        if(objWindowConfiguration.Schedule_From__c =='Current Month' && system.today() >InstructDate)
        {
            InstructDate = InstructDate.addMonths(1);
        }
        return InstructDate;
    }
    
    //This function compares the current date and InstructionWindowStartDate and make changes accordingly based on Schedule_From__c
    //Returns the updated WindowConfigurationWrapper
    public static WindowConfigurationWrapper GetInstructionReminderDate()
    {
        WindowConfiguration__mdt objWindowConfiguration = [SELECT Window_Type__c, Sub_Type__c, Schedule_From__c, Quarter__c, Month__c, Day__c FROM WindowConfiguration__mdt WHERE Window_Type__c = 'Instruction Window' AND Sub_Type__c='Reminder' LIMIT 1];
        WindowConfigurationWrapper objWindowConfigurationWrapper = WindowConfigurationHelper.GetWindowDates();
        date InstructionDate = objWindowConfigurationWrapper.InstructionReminder1;
        system.debug('start: '+InstructionDate);
        if(objWindowConfiguration.Schedule_From__c =='Current Quarter' && system.today() >InstructionDate)
        {
            objWindowConfigurationWrapper.InstructionReminder1 = InstructionDate.addMonths(3);
        	system.debug('Current Quarter: '+InstructionDate);
        }
        if(objWindowConfiguration.Schedule_From__c =='Current Month' && system.today() >InstructionDate)
        {
            objWindowConfigurationWrapper.InstructionReminder1 = InstructionDate.addMonths(1);
        	system.debug('Current Month: '+InstructionDate);
        }
        system.debug('Final: '+objWindowConfigurationWrapper.InstructionReminder1);
        return objWindowConfigurationWrapper;
    }
    
    public static WindowConfigurationWrapper GetOnHoldReminderDates()
    {
        WindowConfiguration__mdt objWindowConfiguration = [SELECT Window_Type__c, Sub_Type__c, Schedule_From__c, Quarter__c, Month__c, Day__c FROM WindowConfiguration__mdt WHERE Window_Type__c = 'OnHold' AND Sub_Type__c='Reminder' LIMIT 1];
        WindowConfigurationWrapper objWindowConfigurationWrapper = WindowConfigurationHelper.GetWindowDates();
        return objWindowConfigurationWrapper;
    }
}