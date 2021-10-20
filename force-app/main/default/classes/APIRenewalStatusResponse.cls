global with sharing class APIRenewalStatusResponse
{
    global boolean IsSuccess {get;set;}
    global List<APIMessage> Messages {get;set;}
    global List<APIRenewalStatusLineItemResponse> MarsRenewalIds{get;set;}
}