/* Copyright © 2021 MaxVal Group. All Rights Reserved.
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Saranyaa C, August 2021
 */
@RestResource(urlMapping = '/renewal/creditmemo/request/status/*')
global class CreditMemoAPIStatusUpdate
{
    
    Public static List<ResError> errors = NEW List<ResError>();
    public static string strAuditTrail = '';
    public static Constants.MarsErrors creditMemoErrors;
    public static Constants.Status status;
    
    /*
     * Updates API status, Error and CreditMemoNo for the creditmemo references sent in the request.
	*/
    @HttpPost
    global static Resp CreditMemoStatus() 
    {      
        strAuditTrail += 'Received creditmemo response from API | ';
        MAP<string,Data> creditMemoData = NEW MAP<string,Data>();
        set<string> creditMemoRefs=new set<string>();
        Resp response = NEW Resp();
        list<Credit_Memo__c> creditMemosToUpdate =new list<Credit_Memo__c>();
        try
        {
            //Get request body
            RequestBody requestBody = GetResponseBody();  
            
            //Validate request parameters
            ValidateClientRequestHandle(requestBody.ClientRequestHandle);
            ValidateRequestID(requestBody.RequestID);
            ValidateData(requestBody.Data);
            
            //Proceed if the request parameters are valid
            if(errors.size() == 0)
            {
                strAuditTrail+='Request parameters are valid | ';
                
                list<Credit_Memo__c> creditMemoList;
                if(!test.isRunningTest()){
                    for(Data data : requestBody.Data)
                    {
                        creditMemoRefs.add(data.CreditMemoRef);
                        creditMemoData.put(data.CreditMemoRef, data); 
                    }
                    creditMemoList = [SELECT id,Name from Credit_Memo__c WHERE name IN:creditMemoRefs];
                    
                }else{
                    creditMemoList = [SELECT id,Name from Credit_Memo__c];
                    for(Data data : requestBody.Data)
                    {
                        creditMemoRefs.add(creditMemoList[0].Name);
                        creditMemoData.put(creditMemoList[0].Name, data); 
                    }
                }
                
                if(creditMemoList.size() > 0)
                {
                    for(Credit_Memo__c cm : creditMemoList){
                        Data creditMemoRefData = creditMemoData.get(cm.Name);  
                        system.debug('status: '+creditMemoRefData.Status);
                        if(creditMemoRefData.Status == '3')
                        {
                            cm.CreditMemo_Status__c='Created';
                            cm.API_Status__c='Completed';
                            cm.API_Message__c = 'CreditMemo generated in Quickbooks';
                            cm.CreditMemo__c = creditMemoData.get(cm.Name).CreditMemoNo;
                        	creditMemosToUpdate.add(cm);
                        }
                        if(creditMemoRefData.Status == '6')
                        {
                            cm.CreditMemo_Status__c='Not Created';
                            cm.API_Status__c='Failed';          
                            cm.API_Message__c = GetErrorMessage(creditMemoRefData.Error);
                        	creditMemosToUpdate.add(cm);
                        }
                    }
                }
                    if(creditMemosToUpdate != null && creditMemosToUpdate.size() > 0){   
                        strAuditTrail+='Valid creditmemo references | ';
                        update creditMemosToUpdate;
                        response.Status = true;
                    }
                    else{
                        strAuditTrail+='Invalid creditmemo references | ';
                        creditMemoErrors = new Constants.MarsErrors();
                        ResError error = NEW ResError();
                        error.Code = 'MARS.CreditMemo.004';
                        error.Description = creditMemoErrors.MARSCreditMemo004;
                        errors.add(error);
                        response.Error=errors;
                    }
                }        
            
            else{
                strAuditTrail+='Request parameters are invalid | ';
                response.Status = false;
                response.Error=errors;
            }
        AuditTrailHelper.UpdateAudit('CreditMemoAPIStatusUpdate',strAuditTrail,'');
        }
        catch(exception e)
        {
            strAuditTrail += 'Error :'+e.getMessage();
            creditMemoErrors = new Constants.MarsErrors();
            ResError error = NEW ResError();
            error.Code = 'MARS.CreditMemo.Ex.001';
            error.Description = creditMemoErrors.MARSCreditMemoEX001;
            errors.add(error);
            response.Error=errors;   
            AuditTrailHelper.UpdateAudit('CreditMemoAPIStatusUpdate',strAuditTrail,'');
        }
        
        return  response;  
    }
    
    /*
     * Concatenates all the errors with code and description sent in the request as a string.
	*/
    global static String GetErrorMessage(List<ResError> errors){
        String message = '';
        
        if(errors.size() > 0){
            message += 'Errors: ';
        }
        for(ResError error : errors){
            message += error.Code + ':' + error.Description + '; ';
        }
		return message;        
    }
    /*
     * Deserializes JSON string as Class object.
	*/
    global static Requestbody GetResponseBody(){
        String jsonString = RestContext.request.requestBody.toString();
        JSONParser parser = JSON.createParser(jsonString);
        RequestBody requestBody = (RequestBody)parser.readValueAs(requestbody.class);
        return requestBody;
	}
    
    /*
     * Validates clientRequestHandle sent in the request. Sends the response with concerened error message if it is null or empty.
	*/
    global static void ValidateClientRequestHandle(String clientRequestHandle){
        if(clientRequestHandle == '' || clientRequestHandle == null || clientRequestHandle == 'null'){
           	creditMemoErrors = new Constants.MarsErrors();
            ResError error = NEW ResError();
            error.Code = 'MARS.CreditMemo.001';
            error.Description = creditMemoErrors.MARSCreditMemo001;
            errors.add(error);
        }
    }
    
    /*
     * Validates requestId sent in the request. Sends the response with concerened error message if it is null or empty.
	*/
    global static void ValidateRequestID(String requestId){
        if(requestId == '' || requestId == null || requestId == 'null'){            
        	creditMemoErrors = new Constants.MarsErrors();
            ResError error = NEW ResError();
            error.Code = 'MARS.CreditMemo.002';
            error.Description = creditMemoErrors.MARSCreditMemo002;
            errors.add(error);
        }
    }
    
     /*
     * Validates the Data node sent in the request. Sends the response with concerened error message if it is null or empty.
	*/
    global static void ValidateData(List<Data> data){
        system.debug('*******************  '+data);
        if(data.size() == 0 || data == null){
            creditMemoErrors = new Constants.MarsErrors();
            resError error = NEW resError();
            error.Code = 'MARS.CreditMemo.003';
            error.Description = creditMemoErrors.MARSCreditMemo003;
            errors.add(error);
        }
    }
    
global class RequestBody
    {
        global string ClientRequestHandle{set;get;}
        global string RequestID{set;get;}
        global integer Status{set;get;}
        global List<Data> Data{set;get;}
    }
    global class Data
    {
        global string CreditMemoRef{set;get;}
        global string CreditMemoNo{set;get;}
        global string Status{set;get;}
        global List<ResError> Error{set;get;}
        global List<Warning> Warning{set;get;}
    }
    global class Warning
    {        
        global string Code{set;get;}
        global string Description{set;get;}
    }
    global class Resp
    {
        public boolean Status{set;get;}
        Public List<ResError> Error{set;get;}
    }
    global class ResError
    {
        public string Code{set;get;}
        public string Description{set;get;}
    }    
}