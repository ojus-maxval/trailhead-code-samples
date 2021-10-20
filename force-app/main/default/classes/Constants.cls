/* Copyright © 2021 MaxVal Group. All Rights Reserved.
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Sneha B, April 2021
 */
global class Constants {    
    public class MarsErrors
    {
        //PTO errors
        public string MARSPTO001 = 'ClientRequestHandle is null or empty.';
        public string MARSPTO002 = 'RequestID is null or empty.';
        public string MARSPTO003 = 'Invalid Status.It cannot be 0.';
        public string MARSPTO004 = 'BillNo is null or empty.';
        public string MARSPTO005 = 'Error list should be empty when the Status is 3(Created).';
        public string MARSPTO006 = 'Error list cannot be empty when the Status is 6(Failed).';
        public string MARSPTO007 = 'Invalid Status. It can be either Created(3) or Failed(6).';
        public string MARSPTOEX001 = 'Exception occured.Message - {0}.';
        public string MARSPTO008 = 'Record does not exist for the RequestId : {0}';
        
        //CreditMemo errors
        public string MARSCreditMemo001 = 'ClientRequestHandle is null or empty.';
        public string MARSCreditMemo002 = 'RequestID is null or empty.';
        public string MARSCreditMemo003 = 'Data is null or empty.';
        public string MARSCreditMemo004 = 'The given CreditMemo References are not found.';
        public string MARSCreditMemo005 = 'No data found.';
        public string MARSCreditMemoEX001 = 'Exception occured. Message - {0}.';
    }
    public class BillConstants
    {
        public List<Integer> status=new List<Integer>{3,6};
    }
    
    global class BatchQueueItems{
        Public String OrderPlacedMailAlert = '1';
        Public String OrderReceivedMailAlert = '2';
        Public String OrderItem = '3';
        Public String GenerateInvoice = '4';
        Public String GenerateCreditMemo = '5';
        Public String RecordPayments = '6';
        Public String PTOValidationRequest = '7';
        Public String PTOValidationDocument = '8';
    }
    
    global class Status
    {
        public String Completed = '3';
        public String Failed = '6';
        
    }
    
}