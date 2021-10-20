@RestResource(urlMapping='/renewalstatus/*')
global class RenewalStatusAPIController
{
    @HttpPost
    global static void GetRenewalStatus() 
    {
        //Read the Request
        APIRenewalStatusRequest MarsRenewalIdRequest= (APIRenewalStatusRequest) JSON.deserialize(RestContext.request.requestBody.toString(), APIRenewalStatusRequest.Class);
        
        //Intiate Response Object
        APIRenewalStatusResponse objMarsRenewalIdResponse = new APIRenewalStatusResponse();
        objMarsRenewalIdResponse.IsSuccess = true;
        objMarsRenewalIdResponse.Messages =  new List<APIMessage>();
        objMarsRenewalIdResponse.MarsRenewalIds = new List<APIRenewalStatusLineItemResponse>();
        
        //Read error messages
        Map<string, APIMessage__c> mapMessages = APIMessageController.GetAllMessages();
        
        
        if (MarsRenewalIdRequest!=null && MarsRenewalIdRequest.MarsRenewalIds != null && MarsRenewalIdRequest.MarsRenewalIds.size()>0)
        {
            //Validation.1. Checck no. of renewals upto 10 in one request
            if (MarsRenewalIdRequest.MarsRenewalIds.size()>10)
            {
                objMarsRenewalIdResponse.IsSuccess = false;
                objMarsRenewalIdResponse.Messages.add(APIMessage.GetMessage(mapMessages, 'API.RS.001'));
            }
            
            //Process
            if (objMarsRenewalIdResponse.IsSuccess)
            {
                List<string> lstMarRenewalIds = RenewalStatusHelper.GetRequestedMarsRenewalIds(MarsRenewalIdRequest);
                Map<string, Order_Item__c> mapOrderItems = RenewalStatusHelper.GetOrderItemsForRequestedMarsRenewalIds(lstMarRenewalIds);
                
                for(APIRenewalStatusLineItemRequest objRequest : MarsRenewalIdRequest.MarsRenewalIds)
                {
                    APIRenewalStatusLineItemResponse objLineItemResponse = new APIRenewalStatusLineItemResponse();
                    objLineItemResponse.IsSuccess = true;
                    objLineItemResponse.MarsRenewalId = objRequest.MarsRenewalId;
                    objLineItemResponse.Messages = new List<APIMessage>();
                    
                    if (mapOrderItems.containsKey(objRequest.MarsRenewalId))
                    {
                        Order_Item__c objOrderItem = mapOrderItems.get(objRequest.MarsRenewalId);
                        if (objOrderItem != null)
                        {
                            objLineItemResponse.RenewalInstruction = objOrderItem.Renewal_Instruction__c;
                            objLineItemResponse.PaymentStatus = objOrderItem.Payment_Status__c;
                            if (objOrderItem.Cancellation_Approval__c == 'Requested')
                            {
                                objLineItemResponse.Messages.add(APIMessage.GetMessage(mapMessages, 'API.RS.003'));
                            }
                            else if (objOrderItem.Renewal_Instruction__c == 'Cancel')
                            {
                                objLineItemResponse.Messages.add(APIMessage.GetMessage(mapMessages, 'API.RS.004'));
                            }
                        }
                        else
                        {
                            objLineItemResponse.IsSuccess = false;
                            objLineItemResponse.Messages.add(APIMessage.GetMessage(mapMessages, 'API.RS.002'));
                        }
                    }
                    else
                    {
                        objLineItemResponse.IsSuccess = false;
                        objLineItemResponse.Messages.add(APIMessage.GetMessage(mapMessages, 'API.RS.002'));
                    }
                    objMarsRenewalIdResponse.MarsRenewalIds.add(objLineItemResponse);
                }
            }
        }
        else
        {
            objMarsRenewalIdResponse.IsSuccess = false;
            objMarsRenewalIdResponse.Messages.add(APIMessage.GetMessage(mapMessages, 'API.CMN.001'));
        }
        
        
        //Set the response
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(objMarsRenewalIdResponse));
        //RestContext.response.responseBody = Blob.valueOf('{ "status" : "' + RenewalStatus + '", "message" : "' + Message + '"  }');
    }
    global static void GetRenewalStatus_notfound(string MarsRenewalId) 
    {
        //Renewal Status
        string RenewalStatus = '';
        string Message = '';
        Order_Item__c objOrderItem = null;
        List<Order_Item__c> objOrderItems = [SELECT Id, Cancellation_Approval__c, Renewal_Instruction__c, Payment_Status__c FROM Order_Item__c WHERE Name=:MarsRenewalId];
        if (objOrderItems != null && objOrderItems.size()>0) 
           objOrderItem = objOrderItems[0];

        string strResult = '';
        if (objOrderItem != null)
        {
            if (objOrderItem.Cancellation_Approval__c == 'Requested')
            {
                Message = 'Cancellation Request Received';
            }
            else if (objOrderItem.Renewal_Instruction__c == 'Cancel')
            {
                Message = 'Cancelled';
                RenewalStatus = objOrderItem.Renewal_Instruction__c ;
            }
            else
            {
                RenewalStatus = objOrderItem.Payment_Status__c;
            }
        }
        else
        {
            Message = 'Invalid request';
        }
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf('{ "status" : "' + RenewalStatus + '", "message" : "' + Message + '"  }');
    }
}