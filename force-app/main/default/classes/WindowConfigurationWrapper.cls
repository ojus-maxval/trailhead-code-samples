public with sharing class WindowConfigurationWrapper
{
    public Date InstructionWindowStartDate {get; set;}
    public Date InstructionWindowCloseDate {get; set;}
    public Date InstructionReminder1 {get;set;}
    
    public Date PaymentWindowStartDate {get; set;}
    public Date PaymentWindowCloseDate {get; set;}
    
    public Date RenewalWindowStartDate {get; set;}
    public Date RenewalWindowCloseDate {get; set;}
    
    public Date NextRenewalWindowStartDate {get; set;}
    public Date NextRenewalWindowCloseDate {get; set;}
    
    public Decimal OnHoldReminder1 {get; set;}
    public Decimal OnHoldReminder2 {get; set;}
    public Decimal OnHoldReminder3 {get;set;}
}