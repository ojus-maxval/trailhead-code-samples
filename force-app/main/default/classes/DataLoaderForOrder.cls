public class DataLoaderForOrder
{
    public DataLoaderForOrder()
    {
    }
    public static boolean CleanupOrders()
    {
        List<Payment__c> objPayments =  [SELECT Id FROM Payment__c];
        DELETE objPayments;
        
        List<Order_Item__c> objOrderItems = [SELECT Id FROM Order_Item__c];
        DELETE objOrderItems;
        
        List<Order__c> objOrders = [SELECT Id FROM Order__c];
        DELETE objOrders;
        
        return true;
    }
    public static Order__c CreateOrder(string BillingCurrency, Id ClientId, decimal LateFee, string OrderName, decimal OrderAmountClient, string PaymentStatus, decimal RushFee)
    {
        Order__c objOrder = new Order__c();
        //objOrder.Billing_Currency__c = BillingCurrency;
        objOrder.Client__c = ClientId;
        objOrder.Late_Fee__c = LateFee;
        //objOrder.Name = OrderName;
        //objOrder.Order_Amount_Client__c = OrderAmountClient;
        objOrder.Order_Date__c = DateTime.Now();
        objOrder.Payment_Status__c = PaymentStatus;
        objOrder.Rush_Fee__c = RushFee;
        INSERT objOrder;
        return objOrder;
    }
    


    public static Order_Item__c CreateOrderItem (Id OrderId, string Jurisdiction, string ApplicationNo, string DocketNo, string PatentNo, string DueDate, string DropDeadDate, string PaymentStatus, string RenewalInstruction, string RenewalRecordId, string SuggestedOpenDateToPay,string SuggestedCloseDateToPay, string TermName, string Title, string InstructedBy,string FeeCurrency, decimal Fee, decimal ClaimFee, decimal Surcharge, decimal FeeUnitRateWhenInstruct, decimal FeeUnitRateWhenPay, string ServiceFeeCurrency, decimal ServiceFee, decimal ServiceFeeUnitRateWhenInstruct , decimal ServiceFeeUnitRateWhenPay, string AgentFeeCurrency, decimal AgentFee, decimal AgentFeeUnitRateWhenInstruct, decimal AgentFeeUnitRateWhenPay, decimal CEMarkupPercentage)
    {
        Order_Item__c objOrderItem = new Order_Item__c();
        objOrderItem.Order__c =OrderId;
        
        objOrderItem.Agent_Fee_Currency__c = AgentFeeCurrency;
        //objOrderItem.Agent_Fee_Unit_Rate_When_Instruct__c = AgentFeeUnitRateWhenInstruct;
        objOrderItem.Agent_Fee_Unit_Rate_When_Pay__c = AgentFeeUnitRateWhenPay;
        objOrderItem.Agent_Fee__c = AgentFee;
        
        objOrderItem.Application_No__c = ApplicationNo;
        objOrderItem.CE_Markup_Percentage__c = CEMarkupPercentage;
        objOrderItem.Claim_Fee__c = ClaimFee;
        objOrderItem.Docket_No__c = DocketNo;
        objOrderItem.Drop_Dead_Date__c = Date.valueOf(DropDeadDate);
        objOrderItem.Due_Date__c = Date.valueOf(DueDate);
        
        objOrderItem.Fee_Currency__c = FeeCurrency;
        objOrderItem.Fee_Unit_Rate__c = FeeUnitRateWhenInstruct;
        objOrderItem.Fee_Unit_Rate_When_Pay__c = FeeUnitRateWhenPay;
        
        objOrderItem.Fee__c = Fee;
        objOrderItem.Instructed_By__c = InstructedBy;
        objOrderItem.Jurisdiction__c = Jurisdiction;
        objOrderItem.Patent_No__c = PatentNo;
        objOrderItem.Payment_Status__c = PaymentStatus;
        objOrderItem.Renewal_Instruction__c = RenewalInstruction;
        objOrderItem.Renewal_Record_Id__c = RenewalRecordId;
        
        objOrderItem.Service_Fee_Currency__c = ServiceFeeCurrency;
        objOrderItem.Service_Fee_Unit_Rate__c = ServiceFeeUnitRateWhenInstruct;
        objOrderItem.Service_Fee_Unit_Rate_When_Pay__c = ServiceFeeUnitRateWhenPay;
        objOrderItem.Service_Fee__c = ServiceFee;
        
        objOrderItem.Suggested_Close_Date_To_Pay__c = Date.valueOf(SuggestedCloseDateToPay);
        objOrderItem.Suggested_Open_Date_To_Pay__c = Date.valueOf(SuggestedOpenDateToPay);
        objOrderItem.Surcharge__c = Surcharge;
        objOrderItem.Term_Name__c = TermName;
        objOrderItem.Title__c = Title;
        INSERT objOrderItem;
        return objOrderItem;
    }
    
    public static void SetupData()
    {
        CleanupOrders();
        Clients__c objClient = [SELECT Id FROM Clients__c WHERE Name='APL' LIMIT 1];
        Order__c objOrder = DataLoaderForOrder.CreateOrder('USD', objClient.Id, 0, 'ORD-1', 1310, 'To be Invoiced', 0);
        DataLoaderForOrder.CreateOrderItem(objOrder.Id, 'US','APP-US-001', 'DKT-US-001', 'PAT-US-001', '2020-06-30', '2020-12-30', 'Waiting to Invoice', 'Renew', '1', '2020-6-20', '2020-6-29', 'Year 3.5', 'Title-US-001', 'Sanjay Ram', 'USD', 1300, 0, 0, 1, 1, 'USD', 10, 1, 1,'USD', 0, 1, 1, 4);
    }
}
//Clients__c objClient = [SELECT Id FROM Clients__c WHERE Name='APL' LIMIT 1];
//Order__c objOrder = DataLoaderForOrder.CreateOrder('USD', objClient.Id, 0, 'ORD-4', 2650, 'To be Invoiced', 0);
//DataLoaderForOrder.CreateOrderItem(objOrder.Id, 'USD', 1, 1, 0, 'US13/123,456', 4, 0, 'DKT-US-004', '2020-12-30', '2020-06-30', 'USD', 1, 1, 1300, 'Sanjay Ram', 'US', 'US-SAM-001', 'Waiting to Invoice', 'Renew', '123', 'USD', 1, 1, 10, '2020-6-29', '2020-6-20', 0, 'Year 3.5', 'US-001-Title');