public with sharing class PaymentScheduleHelper
{
    
    public static PaymentScheduleWrapper GetScheduledDates(string ScheduleFrom, Date DueDate, integer ScheduleDateFrom, integer ScheduleDateTo)
    {
        PaymentScheduleWrapper objPaymentScheduleWrapper = new PaymentScheduleWrapper();
        if (ScheduleFrom == 'Due Date')
        {
            objPaymentScheduleWrapper.ScheduleStartDate = DueDate.addDays(ScheduleDateFrom);
            objPaymentScheduleWrapper.ScheduleCloseDate = DueDate.addDays(ScheduleDateTo);
        }
        else if (ScheduleFrom == 'First Day of Week of Due Date')
        {
            objPaymentScheduleWrapper.ScheduleStartDate = DueDate.toStartOfWeek().addDays(ScheduleDateFrom);
            objPaymentScheduleWrapper.ScheduleCloseDate = DueDate.toStartOfWeek().addDays(ScheduleDateTo);
        }
        else if (ScheduleFrom == 'Last Day of Week of Due Date')
        {
            objPaymentScheduleWrapper.ScheduleStartDate = DueDate.toStartOfWeek().addDays(ScheduleDateFrom + 7);
            objPaymentScheduleWrapper.ScheduleCloseDate = DueDate.toStartOfWeek().addDays(ScheduleDateTo + 7);
        }
        else if (ScheduleFrom == 'Last Day of Month of Due Date')
        {
            objPaymentScheduleWrapper.ScheduleStartDate = DueDate.toStartOfMonth().addMonths(1).addDays(ScheduleDateFrom - 1);
            objPaymentScheduleWrapper.ScheduleCloseDate = DueDate.toStartOfMonth().addMonths(1).addDays(ScheduleDateTo - 1);
        }
        else if (ScheduleFrom == 'First Day of Month of Due Date')
        {
            objPaymentScheduleWrapper.ScheduleStartDate = DueDate.toStartOfMonth().addDays(ScheduleDateFrom);
            objPaymentScheduleWrapper.ScheduleCloseDate = DueDate.toStartOfMonth().addDays(ScheduleDateTo);
        }
        return objPaymentScheduleWrapper;
    }
    
}