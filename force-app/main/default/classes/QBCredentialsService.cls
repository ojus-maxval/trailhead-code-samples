@RestResource(urlMapping ='/auth/*')
global class QBCredentialsService 
{
    
    @HttpGet
    global static WrapperAuthorizationDetail getCredentials() 
    {
        User UserDetails;
        Data WrapperOfData ;
         Api ApiDetails ;
        List<API_Auth_Detail__c> QBAPIcreds =new List<API_Auth_Detail__c>(); 
        List<User_Auth_Details__c> QBUsercreds =new List<User_Auth_Details__c>(); 
        List<Error> errors = NEW List<Error>();
        String UniqueName = '';
        String StrAuthtype ='';
        RestRequest restReq = RestContext.request;
        RestResponse restRes = RestContext.response;
        // Reading parametrs from URL
        system.debug('Req URL: '+restReq.requestURI);
        string req =  restReq.requestURI;
        integer li= req.lastIndexOf('/detail');
        string s = req.substring(0, li);
        UniqueName =s.substring(s.lastIndexOf('/') + 1);
        system.debug('1 : '+UniqueName);
        Integer Authtype =req.lastIndexOf('/'+ UniqueName);
        String AuthSubStr =req.substring(0,Authtype);
        StrAuthtype =AuthSubStr.substring(AuthSubStr.lastIndexOf('/') + 1);
        System.debug('User/API Detail>>'+StrAuthtype);
        
        WrapperAuthorizationDetail reslst = NEW WrapperAuthorizationDetail();
        //List<Totp> UserOtp =new List<Totp>();
        if(StrAuthtype == 'API')
        {
            QBAPIcreds = [SELECT Id, Name, ClientId__c, Client_Secret__c, Auth_Code__c, 
                          Refresh_Token__c, Refresh_Token_Expiry__c, GrantType__c, LastModifiedDate FROM API_Auth_Detail__c WHERE Name =: UniqueName];
        }
        else if(StrAuthtype == 'User')
        {
            QBUsercreds = [SELECT Id, Name, User_Name__c, Password__c, Secret_Key__c FROM User_Auth_Details__c WHERE Name =: UniqueName];
        }
        else
        {
            Error er = NEW Error();
            er.Code = 'INVALID';
            er.Description= 'Invalid type provided.';
            errors.add(er);
        }
        
           
        try
        {
            if(StrAuthtype =='User' || StrAuthtype == 'API')
            {
                WrapperOfData =new Data();
        		reslst.Status = true;     
                WrapperOfData.AuthReference = UniqueName;
                if (QBAPIcreds != null && QBAPIcreds.size()>0)
                {  
                     ApiDetails = new Api();
                    if(QBAPIcreds[0].ClientId__c != null && QBAPIcreds[0].ClientId__c != '')
                        ApiDetails.ClientId = QBAPIcreds[0].ClientId__c;
                    if(QBAPIcreds[0].Client_Secret__c != null && QBAPIcreds[0].Client_Secret__c != '')
                        ApiDetails.ClientSecret = QBAPIcreds[0].Client_Secret__c;
                    //reslst.CompanyReference = QBAPIcreds[0].Company_Reference__c;
                    if(QBAPIcreds[0].Auth_Code__c != null && QBAPIcreds[0].Auth_Code__c != '')
                        ApiDetails.AuthCode = QBAPIcreds[0].Auth_Code__c;
                    if(QBAPIcreds[0].Refresh_Token__c != null && QBAPIcreds[0].Refresh_Token__c != '')
                        ApiDetails.RefreshToken = QBAPIcreds[0].Refresh_Token__c;
                    if(QBAPIcreds[0].Refresh_Token_Expiry__c != null && QBAPIcreds[0].Refresh_Token_Expiry__c != '')
                        ApiDetails.RefreshTokenExpiry = QBAPIcreds[0].Refresh_Token_Expiry__c;
                    if(QBAPIcreds[0].GrantType__c != null && QBAPIcreds[0].GrantType__c != '')
                        ApiDetails.GrantType = QBAPIcreds[0].GrantType__c;
                    Datetime dt = QBAPIcreds[0].LastModifiedDate;
                    Datetime GetUTCDateAndTime = Datetime.newInstanceGmt(
                                                                            dt.year(),
                                                                            dt.month(), 
                                                                            dt.day(),
                                                                            dt.hour(), 
                                                                            dt.minute(),
                                                                            dt.second()
                                                                        );
                    
                    ApiDetails.LastModifiedDate = String.valueOf(GetUTCDateAndTime);
                    //system.debug(Json.serialize(reslst));
                }
                else if(QBUsercreds != null && QBUsercreds.size()>0)
                {
                    UserDetails = new User();
                    UserDetails.UserName = QBUsercreds[0].User_Name__c;
                    UserDetails.Password = QBUsercreds[0].Password__c;
                    UserDetails.SecretKey = QBUsercreds[0].Secret_Key__c;
                    
                }
                else
                {
                    Error er = NEW Error();
                    er.Code = 'NOT_FOUND';
                    er.Description= 'Invalid authreference provided.';
                    errors.add(er);
                }
            }
        }
        catch(exception e)
        {
            Error er = NEW Error();
            er.Code = '-';
            er.Description= e.getMessage();
            errors.add(er);
			System.debug('Get Error>>>'+e.getLineNumber());
			System.debug('Get Error>>>'+e.getMessage());             
        }
        finally
        {
            //UserDetails.Totp =UserOtp;
            if(ApiDetails != null)
            WrapperOfData.Api = ApiDetails;
            if(UserDetails != null)
            WrapperOfData.User =UserDetails;   
            if(errors != null)
            reslst.error = errors;
            if(WrapperOfData != null)
            reslst.Data = WrapperOfData;

            if(errors.size()>0)
                reslst.Status = false;            
        }
        return  reslst;
        //return  Json.serialize(reslst);
    }
    @httpput
    global static WrapperAuthorizationDetailUpdate UpdateAuthorizationDetails()
    {
      
        List<API_Auth_Detail__c> QBAPIcreds =new List<API_Auth_Detail__c>();
        List<User_Auth_Details__c> QBUsercreds =new List<User_Auth_Details__c>(); 
        List<Error> errors = NEW List<Error>();
       /*WrapperAuthorizationDetail Response = NEW WrapperAuthorizationDetail();
        Data WrapperOfData =new Data();
        WrapperOfData.Api = ApiDetails;
        WrapperOfData.User =UserDetails;  
        System.debug('API Detail'+WrapperOfData.Api); 
        System.debug('WrapperOfData'+WrapperOfData); */
        
        
        String jsonString = RestContext.request.requestBody.toString();
        system.debug('Req Body: '+jsonString );
        JSONParser parser = JSON.createParser(jsonString);
        DetailedUpdate res = (DetailedUpdate)parser.readValueAs(DetailedUpdate.class);
        String UniqueName = '';
        String StrAuthtype ='';
        RestRequest restReq = RestContext.request;
        RestResponse restRes = RestContext.response;
        // Getting the request URI
        String QBRequestURI = restReq.requestURI;
        System.debug('URL'+QBRequestURI);
        // Getting the QB id from the request URI
        integer li= QBRequestURI.lastIndexOf('/update');
        string s = QBRequestURI.substring(0, li);
        UniqueName =s.substring(s.lastIndexOf('/') + 1);
        Integer Authtype =QBRequestURI.lastIndexOf('/'+ UniqueName);
        String AuthSubStr =QBRequestURI.substring(0,Authtype);
        StrAuthtype =AuthSubStr.substring(AuthSubStr.lastIndexOf('/') + 1);
        System.debug('User/API Detail>>'+StrAuthtype);
        // Initializing QB to upsert
        
        if(StrAuthtype == 'API')
        {
            QBAPIcreds = [SELECT Id, Name, ClientId__c, Client_Secret__c, Auth_Code__c, 
                          Refresh_Token__c, Refresh_Token_Expiry__c, GrantType__c, LastModifiedDate FROM API_Auth_Detail__c WHERE Name =: UniqueName];
        }
        else if(StrAuthtype == 'User')
        {
            QBUsercreds = [SELECT Id, Name, User_Name__c, Password__c, Secret_Key__c FROM User_Auth_Details__c WHERE Name =: UniqueName];
        }
        else
        {
            Error er = NEW Error();
            er.Code = 'INVALID';
            er.Description= 'Invalid type provided.';
            errors.add(er);
        }
       
        WrapperAuthorizationDetailUpdate reslst = NEW WrapperAuthorizationDetailUpdate();
        string strAuditTrail = '';
        string status = 'Success';
        strAuditTrail += 'QB Authorization Details(Update): ';
        strAuditTrail += res;
        try
        {
            reslst.Status = true;  
           
                if (QBAPIcreds != null && QBAPIcreds.size()>0)
                { 
                    QBAPIcreds[0].Id = QBAPIcreds[0].Id;
                    QBAPIcreds[0].ClientId__c = res.Api.ClientId;
                    QBAPIcreds[0].Client_Secret__c = res.Api.ClientSecret;
                    QBAPIcreds[0].Auth_Code__c = res.Api.AuthCode;
                    QBAPIcreds[0].Refresh_Token__c = res.Api.RefreshToken;
                    QBAPIcreds[0].Refresh_Token_Expiry__c = res.Api.RefreshTokenExpiry;
                    QBAPIcreds[0].GrantType__c =res.Api.GrantType;
                    update QBAPIcreds[0];
                    //UpdateQBAPIcreds.add(QBAPIcreds[0]);
                }
               /* else
                {
                    API_Auth_Detail__c APIAuth = new API_Auth_Detail__c();
                    APIAuth.ClientId__c = res.Api.ClientId;
                    APIAuth.Client_Secret__c = res.Api.ClientSecret;
                    APIAuth.Auth_Code__c = res.Api.AuthCode;
                    APIAuth.Refresh_Token__c = res.Api.RefreshToken;
                    APIAuth.Refresh_Token_Expiry__c = res.Api.RefreshTokenExpiry;
                    UpdateQBAPIcreds.add(APIAuth);
                }
                if(UpdateQBAPIcreds.size() > 0)
                {
                    upsert UpdateQBAPIcreds;
                }*/
            else if(QBUsercreds != null && QBUsercreds.size()>0)
            {
                QBUsercreds[0].Id = QBUsercreds[0].Id;
                QBUsercreds[0].User_Name__c = res.User.UserName;
                QBUsercreds[0].Password__c = res.User.Password;
                QBUsercreds[0].Secret_Key__c = res.User.SecretKey;
                update QBUsercreds[0];
            }
            else
            {
                Error er = NEW Error();
                er.Code = 'NOT_FOUND';
                er.Description= 'Invalid authreference provided.';
                errors.add(er);
            }
        }
        catch(exception e)
        {
            Error er = NEW Error();
            er.Code = '-';
            er.Description= e.getMessage();
            errors.add(er);  
            
            strAuditTrail += ' || Error :'+e.getMessage();
            status = 'Fail';
        }
        finally
        {
            system.debug(strAuditTrail);
            AuditTrailHelper.UpdateAudit('QB Authorization Details',strAuditTrail,status);
            reslst.error = errors;
            if(errors.size()>0)
                reslst.Status = false;            
        }
        return  reslst;
        
    }  
    
    
    
    
    
    
    
  
    global class WrapperAuthorizationDetail 
    {
        public boolean Status{set;get;}
        public Data Data;
        Public List<Error> Error{set;get;}
    }
    global class WrapperAuthorizationDetailUpdate 
    {
        public boolean Status{set;get;}
        Public List<Error> Error{set;get;}
    }
    global class DetailedUpdate 
    {
        public Api Api;
		public User User;
    }
    global class Data {
		public String AuthReference;
		public Api Api;
		public User User;
	}

	global class Api {
		public String ClientId;
		public String ClientSecret;
		public String AuthCode;
		public String RefreshToken;
		public String RefreshTokenExpiry;
		public String GrantType;
		public String LastModifiedDate;
	}
	global class User {
		public String UserName;
		public String Password;
		public String SecretKey;
		//public List<Totp> Totp;
		//public String LastModifiedDate;
	}
	global class Totp {
		public String Otp;
		public String GeneratedTime;
	}
	public class Error {
		public String Code;
		public String Description;
	}


    
    
    
    
}