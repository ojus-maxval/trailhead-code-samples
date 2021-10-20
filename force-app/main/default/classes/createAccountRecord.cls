@RestResource(urlMapping='/createAccountRecord/*')

   global with sharing class createAccountRecord {

     @HttpPost
     global Static string createAccount()
     {
          RestRequest req = RestContext.request;
          RestResponse res = Restcontext.response;
          string jsonString=req.requestBody.tostring();
          responseWrapper wResp=(responseWrapper) JSON.deserialize(jsonString,responseWrapper.class);
       
          Account obj=new Account();
          obj.Name=wResp.name;
          Insert obj;
          return 'Success';
      }
      
      global class responseWrapper
      {
           global string name;
      }

   }