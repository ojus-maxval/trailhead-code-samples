global with sharing class ScheduleCurrencyService implements Schedulable
{
    global void execute(SchedulableContext SC) 
    {
        CurrencyController.GetExchangeRate();
    }
}