/* Copyright © 2021 MaxVal Group. All Rights Reserved.
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */
public with sharing class WindowConfigurationWrapper
{
    public Date InstructionWindowStartDate {get; set;}
    public Date InstructionWindowCloseDate {get; set;}
    
    public Date PaymentWindowStartDate {get; set;}
    public Date PaymentWindowCloseDate {get; set;}
    
    public Date RenewalWindowStartDate {get; set;}
    public Date RenewalWindowCloseDate {get; set;}
    
    public Date InvoicingWindowStartDate {get; set;}
    public Date InvoicingWindowCloseDate {get; set;}
}