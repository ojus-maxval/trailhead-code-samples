@RestResource(urlMapping='/renewals/InstructRenewal/*')
global class RenewalAPIController
{
    
    @HttpGet
    global static string getMessge() 
    {
        return 'Success';
    }
    //@HttpPost
    //global static string doPost(string AppNo, string DocketNo) 
    //{
    //    return AppNo + '-' + DocketNo;
    //}
    
    //global static string InstructRenewal
    @HttpPost
    global static resp InstructRenewal()
    {
        string strAudit = '';
        //string ReturnValue = '';
        resp ReturnValue = new resp();
        String jsonString = RestContext.request.requestBody.toString();
        JSONParser parser = JSON.createParser(jsonString);
        requestbody res = (requestbody)parser.readValueAs(requestbody.class);
        strAudit+='response - '+res;
        system.debug(res);
        try
        {
            //Check Unique Name
            boolean CanProceedFurther = true;
            boolean CanProceedToUpdate = false;
            string orderItemId = '';
            string orderItemName = '';
            string strUniqueName = res.ClientOrgId + '_' + res.ApplicationNo + '_' + res.PatentNo + '_' + res.TermName;
            system.debug('inside try - unique-'+strUniqueName);
            Order_Item__c objExistingOrderItem = null;
            List<Order_Item__c> objOrderItemList = [SELECT Id, Name, Renewal_Instruction__c, Payment_Status__c, Cancellation_Approval__c,Unique_Name__c FROM Order_Item__c WHERE Unique_Name__c=:strUniqueName];
            if (objOrderItemList != null && objOrderItemList.size()>0)
            {
                ReturnValue.IsSuccess = true;
                objExistingOrderItem = objOrderItemList[0];
                orderItemId = objOrderItemList[0].id;
                orderItemName = objOrderItemList[0].Name;
                if (objExistingOrderItem.Renewal_Instruction__c == 'Renew' && res.RenewalInstruction == 'Cancel')
                {
                    if (objExistingOrderItem.Payment_Status__c == 'Waiting to Invoice' || objExistingOrderItem.Payment_Status__c == 'Payment Requested' || objExistingOrderItem.Payment_Status__c == 'Payment Received')
                    {
                        objExistingOrderItem.Cancellation_Approval__c = 'Requested';
                        UPDATE objExistingOrderItem;
                        ReturnValue.Message = 'Message: Your request will be processed soon';
                        CanProceedFurther = false;
                    }
                    else
                    {
                        ReturnValue.Message = 'Message: PTO fee payment process is in progress. Unable to cancel';
                        CanProceedFurther = false;
                    }
                }
                else if (res.MaRSRenewalID!='-' && res.MaRSRenewalID!=null && res.MaRSRenewalID!='' && objExistingOrderItem.Renewal_Instruction__c == 'Renew' && res.RenewalInstruction == 'Renew' && objExistingOrderItem.Name == res.MaRSRenewalID)
                {
                    //ReturnValue.Message = 'Message: Aleady instructed this renewal';
                    CanProceedFurther = false;
                    CanProceedToUpdate = true;
                } 
                else if (objExistingOrderItem.Renewal_Instruction__c == 'Renew' && res.RenewalInstruction == 'Renew')
                {
                    ReturnValue.Message = 'Message: Already instructed this renewal';
                    ReturnValue.Status = 'Instruct Failed';
                    CanProceedFurther = false;
                } 
            }
            
            //Get the client Details
            Clients__c objClient = null;
            List<Clients__c> objClients = [SELECT Id,Name FROM Clients__c WHERE Symphony_Org_Id__c= :res.ClientOrgId];
            system.debug('clients-'+objClients);
            if (objClients!= null && objClients.size()>0)
                 objClient = objClients[0];
            if (CanProceedFurther)
            {
                system.debug('CanProceedFurther');
                //Create order for the instructions
                Order__c objOrder = null;
                List<Order__c> objOrders = [SELECT Id,Total_Asset__c FROM Order__c WHERE Client_Order_Id__c = :res.ClientOrderId AND Client__c = :objClient.Id];
                system.debug('order-'+objOrders);
                if (objOrders != null && objOrders.size()>0)
                     objOrder = objOrders[0];
                if (objOrder == null)
                {
                    objOrder = new Order__c();
                    objOrder.Client_Order_Id__c = res.ClientOrderId;
                    objOrder.Order_Date__c =  system.now();//Date.Today();
                    objOrder.Client__c = objClient.Id; 
                    objOrder.Order_Status__c = 'Order Placed';
                    objOrder.Payment_Status__c = 'To be Invoiced';
                    objOrder.Instruction_Type__c=res.InstructionType;
                    objOrder.Total_Asset__c  = res.TotalAssets;
                    INSERT objOrder;            
                }
                AuditTrailHelper.UpdateAudit('InstructRenewal-API', 'objOrder:' + objOrder, 'None');
                
                //Create instructions against the order for the instructions
                Order_Item__c objOrderItem = new Order_Item__c();
               
                objOrderItem.Jurisdiction__c = res.Jurisdiction;
                objOrderItem.Application_No__c = res.ApplicationNo;
                /*MARS-728 - Publication number should be added in Asset Detail view in MaRS*/
                /*Modified by Saranyaa*/
                objOrderItem.Publication_No__c = res.PublicationNo;
                objOrderItem.Docket_No__c = res.DocketNo;
                //strAudit += ' ApplicationDate :'+res.ApplicationDate;
                //Modified by Sneha - MARS-816- Filing Date should be passed to MaRS and display in Asset Detail view
                //if(res.ApplicationDate !=null && res.ApplicationDate!='')
                    //objOrderItem.Application_Date__c = Date.valueOf(res.ApplicationDate);
                if(res.FilingDate !=null && res.FilingDate!='')
                    objOrderItem.Filing_Date__c = Date.valueOf(res.FilingDate);
                strAudit += ' IssueDate :'+res.IssueDate;
                if(res.IssueDate !=null && res.IssueDate!='')
                    objOrderItem.Issue_Date__c = Date.valueOf(res.IssueDate);                
                //Added by Sneha - MARS-778-Add Asset Expiration Field in MaRS system 
                strAudit += 'ExpirationDate :'+res.ExpirationDate;
                objOrderItem.Expiration_Date__c = Date.valueOf(res.ExpirationDate);
                //Added by Sanjay MARS-857 -- Add Adjusted Expiration Date field in Renewals tab
                objOrderItem.Adjusted_Expiration_Date__c = Date.valueOf(res.AdjustedExpirationDate);
                objOrderItem.Patent_No__c = res.PatentNo;
                objOrderItem.Title__c = res.Title;
                objOrderItem.Path__c = res.Path;
                objOrderItem.Term_Name__c = res.TermName;
                //Added by Sneha(MARS-974)
                objOrderItem.Asset_Index__c =res.AssetIndex;
                objOrderItem.Renewal_Instruction__c = res.RenewalInstruction;
                objOrderItem.Entity_Type_Name__c = res.EntityTypeName;
                objOrderItem.Instructed_By__c = res.InstructedBy;
                objOrderItem.Instructed_Date__c = Date.Today();
                //Added by Sneha - MARS-812-Passing Symphony IPM and MaRS extension Package version from Symphony to MaRS
                objOrderItem.Extension_Package_Version__c = res.ExtensionPackage;
                objOrderItem.SymphonyIPM_Version__c = res.SymphonyIPM;
                
                objOrderItem.Fee_Currency__c = res.FeeCurrency;
                objOrderItem.Fee__c = res.Fee;
                objOrderItem.Surcharge__c = res.Surcharge;
                objOrderItem.Claim_Fee__c = res.ClaimFee;
                objOrderItem.Fee_Unit_Rate__c = res.FeeUnitRate;
                
                objOrderItem.Service_Fee_Currency__c = res.ServiceFeeCurrency;
                objOrderItem.Service_Fee__c = res.ServiceFee;
                objOrderItem.Service_Fee_Unit_Rate__c = res.ServiceFeeUnitRate;
                
                objOrderItem.Agent_Fee_Currency__c = res.AgentFeeCurrency;
                objOrderItem.Agent_Fee__c = res.AgentFee;
                objOrderItem.Agent_Fee_Unit_Rate__c = res.AgentFeeUnitRate;
                
                objOrderItem.CE_Markup_Percentage__c = res.MarkupPercentage;
                
                objOrderItem.Billing_Currency__c = res.BillingCurrency;
                objOrderItem.Billing_Amount__c = res.BillingAmount;
                objOrderItem.Billing_Currency_Unit_Rate__c = res.BillingCurrencyUnitRate;
                objOrderItem.Invoice_Type_Name__c= res.InvoiceTypeName;
                
                objOrderItem.Due_Date__c = res.DueDate;
                objOrderItem.Drop_Dead_Date__c = res.DropDeadDate;
                
                objOrderItem.Client_Renewal_Id__c = res.ClientRenewalId;
                
                objOrderItem.Order__c = objOrder.Id;
                objOrderItem.Payment_Status__c = 'Waiting to Invoice';
                INSERT objOrderItem;
                strAudit +=' objOrderItem: '+objOrderItem.id;                             
                //Returning
                Order_Item__c objOrderItemCreated = [SELECT Id, Name FROM Order_Item__c WHERE Id =: objOrderItem.Id];
                ReturnValue.MaRSRenewalID = objOrderItemCreated.Name;
                strAudit +=' MaRSRenewalID : '+ReturnValue.MaRSRenewalID;
                ReturnValue.IsSuccess = true;
                
            	if(objOrder.Total_Asset__c==objOrderItem.Asset_Index__c)
                {
                    List<Order_Item__c> newItemList=[SELECT Id FROM Order_Item__c WHERE Order__c=:objOrder.Id];
                    List<id> orderItemIds=new List<id>();
                    for(Order_Item__c item:newItemList)
                    {
                        orderItemIds.add(item.Id);
                    }
                    OrderItemBatch itemBatch=new OrderItemBatch(orderItemIds);
                    database.executeBatch(itemBatch,1);
                    strAudit+='OrderItemBatch Called||';
                }
            }
            if(CanProceedToUpdate == true && orderItemId!='')
            {
                //Update instruction
                Order_Item__c objOrderItem = new Order_Item__c();
                objOrderItem.id = orderItemId;
               
                objOrderItem.Jurisdiction__c = res.Jurisdiction;
                objOrderItem.Application_No__c = res.ApplicationNo;
                /*MARS-728 - Publication number should be added in Asset Detail view in MaRS*/
                /*Modified by Saranyaa*/
                objOrderItem.Publication_No__c = res.PublicationNo;
                objOrderItem.Docket_No__c = res.DocketNo;
                //Added by Sneha(MARS-974)
                objOrderItem.Asset_Index__c =res.AssetIndex;
                
                //Modified by Sneha - MARS-816- Filing Date should be passed to MaRS and display in Asset Detail view
                //if(res.ApplicationDate !=null && res.ApplicationDate!='')
                    //objOrderItem.Application_Date__c = Date.valueOf(res.ApplicationDate);
                if(res.FilingDate !=null && res.FilingDate!='')
                    objOrderItem.Filing_Date__c = Date.valueOf(res.FilingDate);
                if(res.IssueDate !=null && res.IssueDate!='')
                    objOrderItem.Issue_Date__c = Date.valueOf(res.IssueDate);
                //Added by Sneha - MARS-778-Add Asset Expiration Field in MaRS system
                objOrderItem.Expiration_Date__c = Date.valueOf(res.ExpirationDate);
                //Added by Sanjay MARS-857 -- Add Adjusted Expiration Date field in Renewals tab
                objOrderItem.Adjusted_Expiration_Date__c = Date.valueOf(res.AdjustedExpirationDate);
                objOrderItem.Patent_No__c = res.PatentNo;
                objOrderItem.Title__c = res.Title;
                objOrderItem.Path__c = res.Path;
                objOrderItem.Term_Name__c = res.TermName;
                //Added by Sneha - MARS-812-Passing Symphony IPM and MaRS extension Package version from Symphony to MaRS
                objOrderItem.Extension_Package_Version__c = res.ExtensionPackage;
                objOrderItem.SymphonyIPM_Version__c = res.SymphonyIPM;
                
                objOrderItem.Renewal_Instruction__c = res.RenewalInstruction;
                objOrderItem.Entity_Type_Name__c = res.EntityTypeName;
                objOrderItem.Instructed_By__c = res.InstructedBy;
                objOrderItem.Instructed_Date__c = Date.Today();
                
                objOrderItem.Fee_Currency__c = res.FeeCurrency;
                objOrderItem.Fee__c = res.Fee;
                objOrderItem.Surcharge__c = res.Surcharge;
                objOrderItem.Claim_Fee__c = res.ClaimFee;
                objOrderItem.Fee_Unit_Rate__c = res.FeeUnitRate;
                
                objOrderItem.Service_Fee_Currency__c = res.ServiceFeeCurrency;
                objOrderItem.Service_Fee__c = res.ServiceFee;
                objOrderItem.Service_Fee_Unit_Rate__c = res.ServiceFeeUnitRate;
                
                objOrderItem.Agent_Fee_Currency__c = res.AgentFeeCurrency;
                objOrderItem.Agent_Fee__c = res.AgentFee;
                objOrderItem.Agent_Fee_Unit_Rate__c = res.AgentFeeUnitRate;
                
                objOrderItem.CE_Markup_Percentage__c = res.MarkupPercentage;
                
                objOrderItem.Billing_Currency__c = res.BillingCurrency;
                objOrderItem.Billing_Amount__c = res.BillingAmount;
                objOrderItem.Billing_Currency_Unit_Rate__c = res.BillingCurrencyUnitRate;
                
                objOrderItem.Due_Date__c = res.DueDate;
                objOrderItem.Drop_Dead_Date__c = res.DropDeadDate;
                
                objOrderItem.Client_Renewal_Id__c = res.ClientRenewalId;
                
                //objOrderItem.Order__c = objOrder.Id;
                objOrderItem.Payment_Status__c = 'Waiting to Invoice';
                update objOrderItem;
                ReturnValue.IsSuccess = true;  
                ReturnValue.MaRSRenewalID = orderItemName;            
            }
                
        }
        catch(Exception exp)
        {
            ReturnValue.IsSuccess = false;
            strAudit += exp.getMessage() + '| ' + exp.getStacktraceString();
            ReturnValue.ErrorDescription = 'Error' + ' : ' +exp.getMessage();
        }
        finally
        {
            AuditTrailHelper.UpdateAudit('InstructRenewal', strAudit, '');
        }
        return ReturnValue;
    }
    global class resp
    {
        public boolean IsSuccess{set;get;}
        public string MaRSRenewalID{set;get;}
        public string Status{set;get;}
        public string Message{set;get;}
        public string ErrorCode{set;get;}
        public string ErrorDescription{set;get;}
    }
    public class requestbody
    {
        public string Jurisdiction{set;get;}
        public string ApplicationNo{set;get;} 
        public string PublicationNo{set;get;} 
        public string DocketNo{set;get;} 
        public string PatentNo{set;get;} 
        public string Title{set;get;} 
        public string Path{set;get;} 
        public string TermName{set;get;} 
        public string RenewalInstruction{set;get;} 
        public string EntityTypeName{set;get;} 
        public string InstructedBy{set;get;} 
        public string FeeCurrency{set;get;} 
        public decimal Fee{set;get;} 
        public decimal Surcharge{set;get;} 
        public decimal ClaimFee{set;get;} 
        public decimal FeeUnitRate{set;get;} 
        public string ServiceFeeCurrency{set;get;} 
        public decimal ServiceFee{set;get;} 
        public decimal ServiceFeeUnitRate{set;get;} 
        public string AgentFeeCurrency{set;get;} 
        public decimal AgentFee{set;get;} 
        public decimal AgentFeeUnitRate{set;get;} 
        public decimal MarkupPercentage{set;get;} 
        public string BillingCurrency{set;get;} 
        public decimal BillingAmount{set;get;} 
        public decimal BillingCurrencyUnitRate{set;get;} 
        public string InvoiceTypeName{set;get;} 
        public Date DueDate{set;get;} 
        public Date DropDeadDate{set;get;} 
        public Date ExpirationDate{set;get;}
        public Date AdjustedExpirationDate{set;get;}
        public string ClientOrgId{set;get;} 
        public string ClientOrderId{set;get;} 
        public string ClientRenewalId {set;get;} 
        public string MaRSRenewalID{set;get;} 
        //public string ApplicationDate{set;get;}
        public string FilingDate{set;get;}
        public string IssueDate{set;get;}
        public string ExtensionPackage{set;get;}
        public string SymphonyIPM{set;get;}
        public integer AssetIndex{set;get;}
        public integer TotalAssets{set;get;}
        public string InstructionType{set;get;}
    }
}