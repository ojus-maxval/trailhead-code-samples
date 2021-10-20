trigger trgBatchQueue on Batch_Queue__c (after insert) 
{
    string strAuditText = '';
    if (Trigger.isAfter)
    {
        List<Id> lstOrderItemIds = new List<Id>();
        List<Id> lstGenerateInvoiceIds = new List<Id>();
        List<Id> lstRecordPaymentIds = new List<Id>();
        List<Id> lstOrderItemCIdsForPV = new List<Id>();
        List<Id> lstOrderItemCIdsForPVD = new List<Id>();
        List<Id> orderItemStatusUpdateId = new List<Id>();
        List<Id> lstGenerateCreditMemoIds = new List<Id>();
        if (Trigger.isInsert)
        {
            for(Batch_Queue__c objBatchQueue : Trigger.New)
            {
                strAuditText += 'Triggered BatchQueue | ';
                if (objBatchQueue.Name == 'Order Item')
                    lstOrderItemIds.add(Id.valueOf(objBatchQueue.Parent_Id__c));
                if (objBatchQueue.Name == 'Generate Invoice')
                    lstGenerateInvoiceIds.add(Id.valueOf(objBatchQueue.Parent_Id__c));
                if (objBatchQueue.Name == 'Record Payments')
                    lstRecordPaymentIds.add(Id.valueOf(objBatchQueue.Parent_Id__c));
                if (objBatchQueue.Name == 'PTO Validation Request')
                {
                    if(objBatchQueue.Parent_Id__c != null)
                    	lstOrderItemCIdsForPV.add(Id.valueOf(objBatchQueue.Parent_Id__c));
                }
                if (objBatchQueue.Name == 'PTO Validation Document')
                {
                    if(objBatchQueue.Parent_Id__c != null)
                    	lstOrderItemCIdsForPVD.add(Id.valueOf(objBatchQueue.Parent_Id__c));
                }if (objBatchQueue.Name == 'Generate CreditMemo')
                {
            		strAuditText += 'CreditMemo requests are there in queue | ';
                    lstGenerateCreditMemoIds.add(Id.valueOf(objBatchQueue.Parent_Id__c));
                }
            }
            //Order Item
            if (lstOrderItemIds!=null && lstOrderItemIds.size()>0)
            {
                OrderItemBatch objOrderItemBatch  =  new OrderItemBatch(lstOrderItemIds);
                Database.executeBatch(objOrderItemBatch, 1);
            }
            //Generate Invoices            
            if (lstGenerateInvoiceIds!=null && lstGenerateInvoiceIds.size()>0)
            {
                strAuditText += 'Calling GenerateInvoiceBatch | ';
                //for(Id GenerateInvoiceId : lstGenerateInvoiceIds)
                //{
                    GenerateInvoiceBatch objGenerateInvoiceBatch =  new GenerateInvoiceBatch(lstGenerateInvoiceIds);
                    Database.executeBatch(objGenerateInvoiceBatch, 1);
                //}
            }
            //Generate CreditMemos            
            if (lstGenerateCreditMemoIds!=null && lstGenerateCreditMemoIds.size()>0)
            {
                //for(Id GenerateInvoiceId : lstGenerateCreditMemoIds)
                //{                
                strAuditText += 'Calling GenerateCreditMemoBatch | ';
                GenerateCreditMemoBatch objGenerateCreditMemoBatch =  new GenerateCreditMemoBatch(lstGenerateCreditMemoIds);
                Database.executeBatch(objGenerateCreditMemoBatch, 1);
                //}
            }
            //Record Payments
            if (lstRecordPaymentIds!=null && lstRecordPaymentIds.size()>0)
            {
                RecordPaymentBatch objRecordPaymentBatch =  new RecordPaymentBatch(lstRecordPaymentIds);
                Database.executeBatch(objRecordPaymentBatch, 1);
            }
            //PTO Validation
            if (lstOrderItemCIdsForPV !=null && lstOrderItemCIdsForPV.size()>0)
            {
                //batchPtoPaymentValidate PtoPaymentValidatecls =  new batchPtoPaymentValidate(lstOrderItemCIdsForPV);
                //Database.executeBatch(PtoPaymentValidatecls, 1);
                batchValidateWithPTO ValidateWithPTO = NEW batchValidateWithPTO(lstOrderItemCIdsForPV);
                Database.executeBatch(ValidateWithPTO);
            }
            //PTO Validation Document
            if (lstOrderItemCIdsForPVD !=null && lstOrderItemCIdsForPVD.size()>0)
            {
                batchPTOPaymentFile PTOPaymentFilecls =  new batchPTOPaymentFile(lstOrderItemCIdsForPVD);
                Database.executeBatch(PTOPaymentFilecls, 1);
            }
        }
    }
    
    AuditTrailHelper.UpdateAudit('trgBatchQueue', strAuditText, 'None');
}