/* Copyright © 2021 MaxVal Group. All Rights Reserved.
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Sneha B, April 2021
 */


/*
This is the service class which updates the bill creation status and bill number
*/ 
@RestResource(urlMapping='/renewal/bill/status/*')
global class BillCreationStatusServiceClass {
    /*
    This function is used to update the bill creation Status and bill number
    */
    @HttpPost
    global static BillCreationStatusEntity.BillCreationStatusResponse BillCreationStatus() {
        PTOValidationUtility utility=new PTOValidationUtility();
        BillCreationStatusEntity.BillCreationStatusResponse response = new BillCreationStatusEntity.BillCreationStatusResponse();
        try 
        {
            BillCreationStatusEntity.Error error = new BillCreationStatusEntity.Error();
            if(RestContext.request.requestBody != null)
            {
                system.debug('BillCreationStatusServiceClass service called');
                string jsonString = RestContext.request.requestBody.toString();
                system.debug('Response json from MaxvalAPI for Bill Creation Status - '+jsonString);
                JSONParser parser = JSON.createParser(jsonString);
                BillCreationStatusEntity.BillCreationStatusRequest billCreationStatus = (BillCreationStatusEntity.BillCreationStatusRequest)parser.readValueAs(BillCreationStatusEntity.BillCreationStatusRequest.class);
                system.debug('Validation started for the request parameters');
                error = utility.ValidateBillCreationStatusRequest(billCreationStatus);
                if(error.Status == 1)
                {
                    system.debug('Validation successful.RequestId - '+billCreationStatus.RequestID);
                    error=UpdateBillStatus(billCreationStatus);
                    if(error.Status == 1){
                        response.Error=error.ErrorDetails;
                        response.Status = true;
                        RestContext.response.statusCode = 200;
                    }
                    else{
                        response.Error=error.ErrorDetails;
                        response.Status = false;
                        RestContext.response.statusCode = 400;
                    }
                }
                else {
                    response.Error=error.ErrorDetails;
                    response.Status = false;
                    RestContext.response.statusCode = 400;
                }   
            }
        }
        catch (Exception e) {
            system.debug('Unexpected exception occured - '+e.getMessage());
            List<BillCreationStatusEntity.ErrorDetail> exceptionList=new List<BillCreationStatusEntity.ErrorDetail>();
            BillCreationStatusEntity.ErrorDetail exceptionMsg=new BillCreationStatusEntity.ErrorDetail();
            Constants.MarsErrors errors=new Constants.MarsErrors();
            exceptionMsg.Code='MARS.PTO-EX.006';
            exceptionMsg.Description=String.format(errors.MARSPTOEX001, new List<String>{e.getMessage()});
            exceptionList.add(exceptionMsg);
            response.Error=exceptionList;
            response.Status = false;
            RestContext.response.statusCode = 500;
        }        
        return response;
    }

    /*
    This function is used to concatenate the error message in order to show in Mars UI
    */
    public static string ConcatenateBillError(List<BillCreationStatusEntity.ErrorDetail> reqBillError)
    {
        string billError = '';
        if(reqBillError.size()>0)
        {
            for(BillCreationStatusEntity.ErrorDetail errorDetail :reqBillError)
            {
                if(billError == '')
                    billError = errorDetail.Code+'-'+errorDetail.Description;
                else
                    billError += ', '+errorDetail.Code+'-'+errorDetail.Description;
            }
            system.debug('Concatenated the errors - '+billError);
        }
        return billError;
    }

    /*
    This function is used to update the billStatus and the bill number in the respected fields
    */
    public static BillCreationStatusEntity.Error UpdateBillStatus(BillCreationStatusEntity.BillCreationStatusRequest billCreationStatus)
    {
        string billError=ConcatenateBillError(billCreationStatus.Error);
        string requestId = billCreationStatus.RequestID;
        Constants.MarsErrors errors=new Constants.MarsErrors();
        BillCreationStatusEntity.Error error = new BillCreationStatusEntity.Error();
        BillCreationStatusEntity.ErrorDetail errorDetail = new BillCreationStatusEntity.ErrorDetail(); 
        List<BillCreationStatusEntity.ErrorDetail> errorDetails = new List<BillCreationStatusEntity.ErrorDetail>();
        Payment_Confirmation__c[] paymentConfirmation= [SELECT Id,Bill_Request_ID__c,Payment_API_Message__c,Status__c,BillNo__c FROM Payment_Confirmation__c WHERE Bill_Request_ID__c =: requestId];
		Order_Item__c[] orderItem = [SELECT Bill_API_Message__c,Bill_No__c,Bill_Status__c FROM Order_Item__c WHERE Payment_Confirmation__c =: paymentConfirmation[0].Id];        
        if(paymentConfirmation.size()>0)
        {
            /* MARS-813 Bill Number, Bill Status, Bill API Message not reflected in Asset Detail view
            Order Item updated with Bill_No__c, Bill_Status__c and Bill_API_Message__c
             */
            if(billCreationStatus.Status == 3)
            {
                paymentConfirmation[0].Status__c='Created';
                orderItem[0].Bill_Status__c = 'Created';
                system.debug('Bill creation is successfull.');
                paymentConfirmation[0].BillNo__c=billCreationStatus.BillNo;
                orderItem[0].Bill_No__c =billCreationStatus.BillNo;
                orderItem[0].Bill_API_Message__c = 'Bill creation is successful';
                system.debug('Updated the Bill No. - '+billCreationStatus.BillNo);
            }            
            else if(billCreationStatus.Status == 6)
            {
                paymentConfirmation[0].Status__c='Failed';
                orderItem[0].Bill_Status__c = 'NotCreated';
                orderItem[0].Bill_No__c =billCreationStatus.BillNo;
                orderItem[0].Bill_API_Message__c = 'Bill creation failed. Error: ' + billError;
                system.debug('Bill creation failed.');
                paymentConfirmation[0].Payment_API_Message__c=billError;
            }
            update paymentConfirmation;
            update orderItem;
            system.debug('Updated the bill creation status.');
            error.Status = 1;
        }
        else {
            errorDetail.Code='MARS.PTO.008';
            errorDetail.Description=String.format(errors.MARSPTO008, new List<String>{requestId});
            errorDetails.add(errorDetail);
            error.ErrorDetails.addAll(errorDetails);
        }
       return error; 
    }
}