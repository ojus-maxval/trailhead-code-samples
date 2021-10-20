global with sharing class APIRenewalStatusLineItemResponse
{
    global string MarsRenewalId {get;set;}
    global string PaymentStatus {get;set;}
    global string RenewalInstruction {get;set;}
    global boolean IsSuccess {get;set;}
    global List<APIMessage> Messages {get;set;}
    global APIRenewalStatusLineItemResponse()
    {
    }
    global APIRenewalStatusLineItemResponse(string strMarsRenewalId, boolean bIsSuccess, List<APIMessage> lstMessages)
    {
        MarsRenewalId = strMarsRenewalId;
        IsSuccess = bIsSuccess;
        Messages = lstMessages;
    }
}