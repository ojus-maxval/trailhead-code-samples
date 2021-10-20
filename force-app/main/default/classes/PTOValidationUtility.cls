/* Copyright © 2021 MaxVal Group. All Rights Reserved.
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Sneha B, April 2021
 */
global class PTOValidationUtility {
    public Constants.MarsErrors errors;
    /*
    This function validates all the request parameters
    */
    public BillCreationStatusEntity.Error ValidateBillCreationStatusRequest(BillCreationStatusEntity.BillCreationStatusRequest billCreationStatus)
    {
        BillCreationStatusEntity.Error error = new BillCreationStatusEntity.Error();
        if(billCreationStatus!=null)
        {
            error.ErrorDetails.addAll(ValidateClientRequestHandle(billCreationStatus.ClientRequestHandle));
            error.ErrorDetails.addAll(ValidateRequestID(billCreationStatus.RequestID));
            error.ErrorDetails.addAll(ValidateBillCreationStatus(billCreationStatus));
            error.ErrorDetails.addAll(ValidateBillNo(billCreationStatus.Status,billCreationStatus.BillNo));                
        }
        if (error.ErrorDetails.size() == 0)
            error.Status = 1;
        return error;
    }

    /*
    This function performs null validation for ClientRequestHandle
    */
    public List<BillCreationStatusEntity.ErrorDetail> ValidateClientRequestHandle(string clientRequestHandle)
    {
        errors=new Constants.MarsErrors();
        BillCreationStatusEntity.ErrorDetail error = new BillCreationStatusEntity.ErrorDetail(); 
        List<BillCreationStatusEntity.ErrorDetail> errorDetail = new List<BillCreationStatusEntity.ErrorDetail>();       
        if(String.isBlank(clientRequestHandle))
        {
            error.Code='MARS.PTO.001';
            error.Description=errors.MARSPTO001;
            errorDetail.add(error);
        }
        return errorDetail;
    }
    
    /*
    This function performs null validation for RequestID
    */
    public List<BillCreationStatusEntity.ErrorDetail> ValidateRequestID(string requestID)
    {
        errors=new Constants.MarsErrors();
        BillCreationStatusEntity.ErrorDetail error = new BillCreationStatusEntity.ErrorDetail(); 
        List<BillCreationStatusEntity.ErrorDetail> errorDetail = new List<BillCreationStatusEntity.ErrorDetail>();       
        if(String.isBlank(requestID))
        {
            error.Code='MARS.PTO.002';
            error.Description=errors.MARSPTO002;
            errorDetail.add(error);
        }        
        return errorDetail;
    }

    /*
    This function performs null validation for BillNo when status is 3
    */
    public List<BillCreationStatusEntity.ErrorDetail> ValidateBillNo(Integer status,string billNo)
    {
        errors=new Constants.MarsErrors();
        BillCreationStatusEntity.ErrorDetail error = new BillCreationStatusEntity.ErrorDetail(); 
        List<BillCreationStatusEntity.ErrorDetail> errorDetail = new List<BillCreationStatusEntity.ErrorDetail>();       
        if(status == 3 && String.isBlank(billNo))
        {
            error.Code='MARS.PTO.004';
            error.Description=errors.MARSPTO004;
            errorDetail.add(error);
        }       
        return errorDetail;
    }

    /*
    This function validates the bill creation status with different cases
    */
    public List<BillCreationStatusEntity.ErrorDetail> ValidateBillCreationStatus(BillCreationStatusEntity.BillCreationStatusRequest billCreationStatus)
    {
        errors=new Constants.MarsErrors();
        Constants.BillConstants constants = new Constants.BillConstants();
        BillCreationStatusEntity.ErrorDetail error = new BillCreationStatusEntity.ErrorDetail(); 
        List<BillCreationStatusEntity.ErrorDetail> errorDetail = new List<BillCreationStatusEntity.ErrorDetail>();       
        if(billCreationStatus.Status == 0)
        {
            error.Code='MARS.PTO.003';
            error.Description=errors.MARSPTO003;
            errorDetail.add(error);
        }
        else if(billCreationStatus.Status==3 && billCreationStatus.Error.size()>0) 
        {
            error.Code='MARS.PTO.005';
            error.Description=errors.MARSPTO005;
            errorDetail.add(error);
        }
        else if(billCreationStatus.Status==6 && billCreationStatus.Error.size()==0)
        {
            error.Code='MARS.PTO.006';
            error.Description=errors.MARSPTO006;
            errorDetail.add(error);
        }
        else if(!constants.status.contains(billCreationStatus.Status))
        {
            error.Code='MARS.PTO.007';
            error.Description=errors.MARSPTO007;
            errorDetail.add(error);
        }        
        return errorDetail;
    }
}